PREFIX skos: <http://www.w3.org/2004/02/skos/core#>

SELECT ?loc ?rem
WHERE {
	?loc skos:note ?rem
}
