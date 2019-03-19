/************************************************************************************************************************************
    Author 		: 	Krishana Tupe	
    Description : 	This class is used to generate mock response for ApexDebugLog class methods for Mock REST Callout.
    
    History		:
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION		DATE				AUTHOR					DETAIL
    1			03 May 2018			Krishana Tupe			Initial Developement
    2			01 Aug 2018 		Krishana Tupe			Chnages for exception logging.
**************************************************************************************************************************************/
@isTest
public class MockResponseForApexDebugLog implements HttpCalloutMock {
    HttpResponse res = new HttpResponse();
    public HTTPResponse respond(HTTPRequest req) {
        if(req.getEndpoint()=='https://test.salesforce.com/services/oauth2/token'){           
            Map<String,String> mapresponse = new Map<String,String>();
            mapresponse.put('setEndpoint','https://test.salesforce.com/services/oauth2/token');
            res.setBody(JSON.serialize(mapresponse));
            res.setStatusCode(200);   
        }else if(req.getEndpoint()=='https://test.salesforce.com/executeRest'){           
            res.setBody('You called https://test.salesforce.com/executeRest method');
            res.setStatusCode(200);    
        }else if(req.getEndpoint()=='https://api.rollbar.com/api/1/item/'){
            res.setBody('You called https://api.rollbar.com/api/1/item/');
            res.setStatusCode(200);    
        }
        return res;
    }    
}