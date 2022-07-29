#!/usr/bin/mawk -f

/owl:sameAs/ {
	print
	for (i = 0; getline && /tempo:/; i++);
	if (i) {
		print "	."
	}
}
1