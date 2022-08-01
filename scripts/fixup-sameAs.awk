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
1
