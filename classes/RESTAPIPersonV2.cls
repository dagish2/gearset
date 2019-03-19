/************************************************************************************************************************************
    Author 		: 	Krishana Tupe	
    Description : 	This class contain the business logic for Tour booking functionality.
    
    History		:
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION		DATE				AUTHOR					DETAIL
    1			18 June 2018		Krishana Tupe			Initial Developement
**************************************************************************************************************************************/
public class RESTAPIPersonV2 extends RESTAPIBase{ 
      
   /************************************************************************************************************************************
        Author 				:	Krishana Tupe
		Description         :   This method execute the post action of Person Endpoint in the salesforce.
		Created Date 		:	23 June	2018	
   **************************************************************************************************************************************/      
   public override RESTAPIResult executePost(RESTAPI.PayloadDetails payload){
        RESTAPIPersonModelsV2.Input input = (RESTAPIPersonModelsV2.Input)payload.Input;
        RESTAPIResult result = new RESTAPIResult();
        RESTAPIPersonModelsV2.Response response = RESTAPIPersonV2.managePerson(input);        
        if(response != null){
            result.setSuccess('Person Processed!', response);
        }
        return result;
    }  
    
 /************************************************************************************************************************************
    Author              :   Krishana Tupe
    Description         :   This method creates a Person record in the salesforce with the given information in payload
    Created Date  		:   23 June 2018  
 *************************************************************************************************************************************/
    public static RESTAPIPersonModelsV2.Response managePerson(RESTAPIPersonModelsV2.Input body){
        Debug.log('body==>'+body);
        RESTAPIPersonModelsV2.Response response = new RESTAPIPersonModelsV2.Response();      
        Map<String,String> mapResponse = PersonEndpointHelper.managePerson(body); 
        Debug.log('mapResponse ==>'+mapResponse );
        if(mapResponse != null){
            response.contact_sfid = mapResponse.get('contact_sfid');
            response.account_sfid = mapResponse.get('account_sfid');
            response.billing_account_sfid = mapResponse.get('billing_account_sfid');
            response.contact_uuid = mapResponse.get('contact_uuid');
        }else{               
            throw new RESTAPIPersonV2.PersonEndpointException('Required fields Email OR contact_uuid OR contact_sfid is missing.');  
        }        
        return response;
    }
   public class PersonEndpointException extends Exception {}
}