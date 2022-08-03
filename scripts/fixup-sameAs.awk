#!/usr/bin/mawk -f

/owl:sameAs/ {
	print
	for (i = 0; getline && /tempo:/; i++);
	if (i) {
		print "	."
	}
}
(/tempo:efficaciousFrom/ || /tempo:validFrom/) && / , / {
	sub(/ ,.* ;/, " ;", $0)
}
1
