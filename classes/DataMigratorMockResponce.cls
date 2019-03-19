/************************************************************************************************************************************
    Author 		: Krishana Tupe
	Issue NO	: -
    Description : This class is used to generate MockResponse for the DataMigrator class.

    History:
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE				AUTHOR					DETAIL
    1.0			9 Jan 2018			Krishana Tupe			Initial Developement.
**************************************************************************************************************************************/
@isTest
global class DataMigratorMockResponce implements HttpCalloutMock {
   
    
    Map<String, HttpCalloutMock> requests;
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        Debug.log('Set Mock');
        HttpResponse res = new HttpResponse();
        Map<String,String> mapAccessToken= new Map<String,String>();
        mapAccessToken.put('access_token','SESSION_ID_REMOVED');
        mapAccessToken.put('id','https://test.salesforce.com/id/00D1g0000004YHKEA2/005F0000003KmbwIAC');
        mapAccessToken.put('instance_url','https://wework--Staging.cs96.my.salesforce.com');
        mapAccessToken.put('issued_at','1516302536561');
        mapAccessToken.put('signature','cw26ecr7W1/q7UJ4f41keytY1ZS+FWgpvULaBBQV3GU=');
        mapAccessToken.put('token_type','Bearer');
        
        if(req.getEndpoint()=='https://test.salesforce.com/services/oauth2/token'){          
            Debug.log('HttpResponse step 1 ::');
            res.setHeader('Content-Type', 'application/json');
            res.setBody(JSON.serialize(mapAccessToken));
            res.setStatusCode(200);            
        }else if(req.getEndpoint()=='https://wework--Staging.cs96.my.salesforce.com/services/apexrest/MigratorQuery')  {
          Debug.log('HttpResponse step 2 ::');
            res.setHeader('Content-Type', 'application/json');
            res.setBody('Account:{Id=0013B00000IuDuuQAF, Name=First Ctiteria, RecordTypeId=0120G000001USsTQAW, CurrencyIsoCode=USD}, Account:{Id=0013B00000IuE4NQAV, Name=WeWork, RecordTypeId=0120G000001USsTQAW, CurrencyIsoCode=USD}');
            res.setStatusCode(200);       
        }     
        return res;       
    }
}