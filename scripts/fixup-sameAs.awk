#!/usr/bin/mawk -f

/owl:sameAs/ {
	print
	for (i = 0; getline && /tempo:/; i++);
	if (i) {
		print "	."
	}
}
/tempo:efficaciousFrom/ && / , / {
	sub(/ ,.* ;/, " ;", $0)
}
/dct:isReplacedBy/ && / , / {
	sub(/un-loc:[A-Z]\{2\}[A-Z0-9]\{3\} , /, "", $0)
}
1
