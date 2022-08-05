#!/usr/bin/mawk -f

BEGIN {
	print "@prefix owl: <http://www.w3.org/2002/07/owl#> ."
	print "@prefix tempo: <http://purl.org/tempo/> ."
}
/^\-un-loc:.....$/ {
	loc = substr($0, 2)
	$0 = loc " owl:sameAs " loc "_" REV " ."
	print
	$0 = loc "_" REV " tempo:validTill \"" RDT "\"^^xsd:date ."
	print
}
0