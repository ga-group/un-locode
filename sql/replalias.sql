PREFIX dct: <http://purl.org/dc/terms/>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX un-loc: <http://data.ga-group.nl/un-locode/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX fn: <http://www.w3.org/2005/xpath-functions#>

SELECT ?loc ?by ?bylias
WHERE {
	?loc dct:isReplacedBy ?by .
	?by owl:sameAs ?bylias .
}
