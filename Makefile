SHELL := /bin/zsh

sparql := /home/freundt/usr/apache-jena/bin/sparql
stardog := STARDOG_JAVA_ARGS='-Dstardog.default.cli.server=http://plutos:5820' /home/freundt/usr/stardog/bin/stardog
sdexec := $(stardog) query execute -g "http://data.ga-group.nl/un-locode/" -r -l -1 iso

include .release

all: un-locode.ttl
check: check.un-locode check.un-locode-hist
canon: un-locode-hist.ttl.canon un-locode.ttl.canon
fixup: fixup.un-locode-hist fixup.un-locode

## untar and cat CodeListPart*.csv to this file
dmp = download/release.csv

## use make all fixup check
## fix issues, then
## make decouple canon check
## make replaced canon fixup

tmp/remarks.out: un-locode.ttl

tmp/%.csv: download/%.htm scripts/rdtbl.xsl
	xsltproc --html scripts/rdtbl.xsl $< \
	> $@.t && mv $@.t $@

tmp/%.ttl: tmp/%.csv sql/mklocode.tarql
	tarql -t sql/mklocode.tarql $< \
	> $@.t && mv $@.t $@

tmp/un-locode.ttl: .release $(dmp)
	scripts/canon.R $(filter-out $<,$^) \
	| tarql -t --stdin --base '!$(REV),$(RDT)' sql/mklocode.tarql \
	> $@.t && mv $@.t $@

tmp/un-locode.seen: tmp/un-locode.ttl
	## snarf old guys
	-ttl2ttl --sortable un-locode.ttl \
	| grep -vF 'owl:sameAs' \
	| cut -f1 \
	| sort -u \
	> tmp/un-locode.prev
	# snarf new guys
	ttl2ttl --sortable $< \
	| cut -f1 \
	| sort -u \
	> $@.t && mv $@.t $@

tmp/un-locode-new.ttl: tmp/un-locode.seen
	# see who's been added in this release
	dtchanges tmp/un-locode.{prev,seen} 1 \
	| scripts/bang-new.awk -v REV=$(REV) -v RDT=$(RDT) \
	> $@.t && mv $@.t $@

tmp/un-locode-tempo.ttl: .release $(dmp)
	# rescue validFroms and efficaciousFroms of active nodes
	-ttl2ttl --sortable un-locode.ttl \
	| grep $$'^un-loc:.....\t' \
	| grep -F $$'tempo:validFrom\ntempo:efficaciousFrom' \
	> $@

tmp/un-locode.kick: tmp/un-locode.seen
	# see who's been deleted in this release
	dtchanges tmp/un-locode.{prev,seen} 1 \
	| scripts/grep-old.awk \
	> $@.t && mv $@.t $@

tmp/un-locode-hist.ttl: tmp/un-locode.kick tmp/un-locode.seen
	# see who's been deleted in this release
	dtchanges tmp/un-locode.{prev,seen} 1 \
	| scripts/kick-old.awk -v REV=$(REV) -v RDT=$(RDT) \
	> $@.t && mv $@.t $@
	# copy the bobs from un-locode.ttl
	ttl2ttl --sortable un-locode.ttl \
	| grep -Ff $< \
	| mawk -F '\t' '{$$1=$$1"_$(REV)"}1' \
	> $@.t && cat $@.t >> $@

un-locode-hist.ttl: tmp/un-locode-tempo.ttl tmp/un-locode-hist.ttl
	cat tmp/un-locode-hist.ttl >> $@
	touch $@
	$(MAKE) $@.canon

un-locode.ttl: un-locode-aux.ttl tmp/un-locode.ttl tmp/un-locode-new.ttl un-locode-hist.ttl tmp/un-locode-tempo.ttl un-locode-align.ttl
	cat $^ \
	> $@.t && mv $@.t $@
	$(MAKE) $@.canon

un-locode-align.ttl: download/alternateNamesV2.zip
	ttl2ttl --sortable un-locode-hist.ttl \
	| grep -F owl:sameAs \
	> tmp/alias
	tar xf $< -O - alternateNamesV2.txt \
	| scripts/alignify.awk \
	| tarql -t --stdin sql/mkalign.tarql \
	| ttl2ttl --sortable \
	| tee tmp/align \
	| grep -vFf <(cut -f1 tmp/alias) \
	> $@.t && mv $@.t $@
	scripts/tempoXsameAs.R tmp/ali{gn,as} \
	>> $@
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

tmp/%.out: sql/%.sql
	$(sdexec) --format CSV $< \
	> $@.t && mv $@.t $@

tmp/decouple.cand: /tmp/check.un-locode.ttl
	grep -A 2 -F 'sameAs-solitude' $< \
	| grep -F focusNode \
	| mawk -F'/' '$$0="un-loc:"substr($$NF,1,5)' \
	> $@.t && mv $@.t $@

tmp/decouple.only: un-locode.ttl tmp/decouple.cand
	ttl2ttl --sortable $< \
	| grep -Ff tmp/decouple.cand \
	| ttl2ttl \
	> $@.t && mv $@.t $@

auto.decouple: un-locode-hist.ttl tmp/decouple.cand
	ttl2ttl --sortable $< \
	| grep -Ff <(mawk '$$0=$$0"\t"' tmp/decouple.cand) \
	> .decouple.t && mv .decouple.t .decouple

decouple: .decouple
	ttl2ttl --sortable un-locode.ttl \
	| grep -Ff <(scripts/decouple.awk .decouple) \
	> $@.t
	scripts/tempoXsameAs.R --newpred tempo:efficaciousTill $@.t .decouple \
	> $@.eftl && $(RM) $@.t
	cat $@.eftl >> un-locode-hist.ttl
	cat $@.eftl >> un-locode.ttl
	$(RM) $@.eftl
	ttl2ttl --sortable un-locode-hist.ttl \
	| grep -vFf .decouple \
	| sed -f <(scripts/redirreplc.awk .decouple) \
	> $@.t && mv $@.t un-locode-hist.ttl
	ttl2ttl --sortable un-locode.ttl \
	| grep -vFf .decouple \
	> $@.t && mv $@.t un-locode.ttl

replaced: tmp/remarks.out
	scripts/snarf-replaced.R $< \
	| tarql -t --stdin sql/replaced.tarql \
	| tee -a un-locode.ttl \
	>> un-locode-hist.ttl \
	&& touch un-locode.ttl

fixup.%: %.ttl
	cat $< \
	| scripts/fixup-sameAs.awk \
	| scripts/fixup-replaced.awk \
	> $@.t && mv $@.t $*.ttl

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
