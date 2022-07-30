#!/usr/bin/mawk -f

BEGIN {
	FS = OFS = "\t"
}
($2 == "owl:sameAs") {
	$2 = "tempo:efficaciousFrom"
	NF = 2
	print
}
