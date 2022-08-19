#!/usr/bin/mawk -f

/^\-unlcd:.....$/ &&
$0 = substr($0, 2) "\t"
