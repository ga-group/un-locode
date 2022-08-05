#!/usr/bin/mawk -f

BEGIN {
	FS = OFS = "\t"
	print	"altid","geoid","qual","code"
}
$3 == "unlc"
