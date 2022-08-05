#!/usr/bin/mawk -f

/^\-un-loc:.....$/ &&
$0 = substr($0, 2) "\t"
