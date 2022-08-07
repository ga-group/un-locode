PREFIX geo: <http://www.w3.org/2003/01/geo/wgs84_pos#>
PREFIX lcc-cr: <https://www.omg.org/spec/LCC/Countries/CountryRepresentation/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX un-loc: <http://data.ga-group.nl/un-locode/>
PREFIX uncefact: <https://service.unece.org/trade/uncefact/vocabulary/uncefact#>

SELECT ?loc ?cc ?lbl ?fun ?lat ?long
WHERE {
	?_loc a uncefact:Location ;
		rdfs:label ?lbl ;
		lcc-cr:isPartOf ?_cc .
	OPTIONAL {
	?_loc	un-loc:hasFunction ?_fun
	}
	OPTIONAL {
	?_loc
		geo:lat ?lat ;
		geo:long ?long ;
	}

	FILTER(NOT EXISTS{?_loc skos:related ?something})

	BIND(localname(?_loc) AS ?loc)
	BIND(localname(?_cc) AS ?cc)
	BIND(localname(?_fun) AS ?fun)
}
