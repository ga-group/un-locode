#!/usr/bin/mawk -f

(/dct:isReplacedBy/ || /rdfs:seeAlso/) && / , / {
	sub(/un-loc:[A-Z][A-Z][A-Z0-9][A-Z0-9][A-Z0-9] , /, "", $0)
}
1
