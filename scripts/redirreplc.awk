#!/usr/bin/mawk -f

BEGIN {
	FS = OFS = "\t"
}
/owl:sameAs/ {
	gsub(/ \./, "", $3)
	print "/dct:isReplacedBy/{s@" $1 " @" $3 " @}"
	print "/rdfs:seeAlso/{s@" $1 " @" $3 " @}"
}
