#!/usr/bin/mawk -f

BEGIN {
	print "@prefix tempo: <http://purl.org/tempo/> ."
	print "@prefix xsd: <http://www.w3.org/2001/XMLSchema#> ."
}
/^\+unlcd:.....$/ &&
$0 = substr($0, 2)" tempo:validFrom \"" RDT "\"^^xsd:date ."
