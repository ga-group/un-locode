SHELL := /bin/zsh

all:

csv = $(patsubst download/%.htm,tmp/%.csv,$(wildcard download/*.htm))
ttl = $(patsubst download/%.htm,tmp/%.ttl,$(wildcard download/*.htm))

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

%.ttl.canon: %.ttl
	rapper -i turtle $< >/dev/null
	ttl2ttl --sortable $< \
	| tr '@' '\001' \
	| sed 's@rdf:type@a@' \
	| sort -u \
	| tr '\001' '@' \
	| ttl2ttl -B \
	> $@ && mv $@ $<

un-locode.ttl: un-locode-aux.ttl $(ttl)
	cat $^ \
	> $@.t && mv $@.t $@
	$(MAKE) $@.canon
