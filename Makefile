SHELL := /bin/zsh

sparql := /home/freundt/usr/apache-jena/bin/sparql
stardog := STARDOG_JAVA_ARGS='-Dstardog.default.cli.server=http://plutos:5820' /home/freundt/usr/stardog/bin/stardog

all: un-locode.ttl

csv = $(patsubst download/%.htm,tmp/%.csv,$(wildcard download/*.htm))
ttl = $(patsubst download/%.htm,tmp/%.ttl,$(wildcard download/*.htm))
## untar and cat CodeListPart*.csv to this file
dmp = download/CodeListParts.csv

csv: $(csv)
ttl: $(ttl)

.SOMETIMES.PHONY: download/directory
download/directory:
	curl -kL https://unece.org/trade/cefact/unlocode-code-list-country-and-territory \
	| grep -F '<td' \
	| grep -o 'http[^"]*/..\.htm' \
	> $@

download: download/directory
	mawk -F'/' '$$0="curl -kL -o $@/"$$NF" \""$$0"\""' $< \
	| $(SHELL)

tmp/%.csv: download/%.htm scripts/rdtbl.xsl
	xsltproc --html scripts/rdtbl.xsl $< \
	> $@.t && mv $@.t $@

tmp/%.ttl: tmp/%.csv sql/mklocode.tarql
	tarql -t sql/mklocode.tarql $< \
	> $@.t && mv $@.t $@

tmp/un-locode.ttl: sql/mklocode-csv.tarql $(dmp)
	cat $(filter-out $<,$^) \
	| tarql -H --stdin $< \
	> $@

tmp/un-locode-tempo.ttl:
	ttl2ttl --sortable un-locode.ttl \
	| grep -F tempo:validFrom \
	> $@

un-locode-hist.ttl: tmp/un-locode.ttl
	echo '@prefix' \
	> tmp/$@
	ttl2ttl --sortable $< \
	| grep -F tempo:validTill \
	| cut -f1 \
	>> tmp/$@
	ttl2ttl --sortable $< \
	| grep -Ff tmp/$@ \
	>> $@
	$(MAKE) $@.canon

un-locode.ttl: un-locode-aux.ttl tmp/un-locode.ttl un-locode-hist.ttl
	$(MAKE) tmp/un-locode-tempo.ttl
	cat $^ tmp/un-locode-tempo.ttl \
	> $@.t && mv $@.t $@
	$(MAKE) $@.canon


%.ttl.canon: %.ttl
	rapper -i turtle $< >/dev/null
	ttl2ttl --sortable $< \
	| tr '@' '\001' \
	| sed 's@rdf:type@a@' \
	| sort -u \
	| tr '\001' '@' \
	| ttl2ttl -B \
	> $@ && mv $@ $<

check.%: %.ttl shacl/%.shacl.ttl
	truncate -s 0 /tmp/$@.ttl
	$(stardog) data add --remove-all -g "http://data.ga-group.nl/un-locode/" iso $< $(ADDITIONAL)
	$(stardog) icv report --output-format PRETTY_TURTLE -g "http://data.ga-group.nl/un-locode/" -r -l -1 iso shacl/$*.shacl.ttl \
        >> /tmp/$@.ttl || true
	$(MAKE) $*.rpt

%.rpt: /tmp/check.%.ttl
	$(sparql) --results text --data $< --query sql/valrpt.sql

setup-stardog:                                                                                                                                                                                          
	$(stardog)-admin db create -o reasoning.sameas=OFF -n iso
	$(stardog) namespace add --prefix un-loc --uri http://data.ga-group.nl/un-locode/ iso

unsetup-stardog:
	$(stardog)-admin db drop iso
