global class QueueInsertGeoForBuildingMockRes  implements HttpCalloutMock{
	global HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            Debug.log('Set Mock');
            Debug.log('req---'+req.getEndpoint());
            HttpResponse res = new HttpResponse();
            if(req.getEndpoint().containsIgnoreCase('googleapis')){
                // No Contract
                Debug.log('HttpResponse step 1 ::');
                res.setHeader('Content-Type','text/csv');
                res.setBody('{ "results" : [ { "address_components" : [ { "long_name" : "Frankfurt", "short_name" : "Frankfurt", "types" : [ "locality", "political" ] }, { "long_name" : "Darmstadt", "short_name" : "DA", "types" : [ "administrative_area_level_2", "political" ] }, { "long_name" : "Hesse", "short_name" : "HE", "types" : [ "administrative_area_level_1", "political" ] }, { "long_name" : "Germany", "short_name" : "DE", "types" : [ "country", "political" ] } ], "formatted_address" : "Frankfurt, Germany", "geometry" : { "bounds" : { "northeast" : { "lat" : 50.2272095, "lng" : 8.8003977 }, "southwest" : { "lat" : 50.0152145, "lng" : 8.472729899999999 } }, "location" : { "lat" : 50.1109221, "lng" : 8.6821267 }, "location_type" : "APPROXIMATE", "viewport" : { "northeast" : { "lat" : 50.2272095, "lng" : 8.8003977 }, "southwest" : { "lat" : 50.0152145, "lng" : 8.472729899999999 } } }, "place_id" : "ChIJxZZwR28JvUcRAMawKVBDIgQ", "types" : [ "locality", "political" ] } ], "status" : "OK" }');
                res.setStatusCode(200);            
            }
            return res;
    }
    
}