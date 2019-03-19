/************************************************************************************************************************************
    Author 		: 	Krishana Tupe
    Description : 	This class contains the wrappers of all versions for Tour API
    
    History		:
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION		DATE				AUTHOR					DETAIL
    1			23 June 2018		Krishana Tupe		Initial Developement
**************************************************************************************************************************************/
public class RESTAPIPersonModelsV2 extends RESTAPIModel {
 	/************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method returns the mock response for person endpoint.
        Created Date  		:   23 June 2018		
   **************************************************************************************************************************************/    
    public override object getMockModel(RESTAPI.PayloadDetails payload) {
        if(payload.Body != null){
            payload.Input = JSON.deserializeStrict(payload.Body, RESTAPIPersonModelsV2.Input.Class);
        }
        return payload.Input;
    }
	/************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This wrapper class is used to wrap the person payload from external system through REST api V2 request.
        Created Date  		:   23 June 2018		
   **************************************************************************************************************************************/    
    public class Input {
        public String contact_sfid;
        public String company_name;
        public String email;
        public String first_name;
        public String last_name;
        public String phone;
        public String type;
        public String contact_uuid;
        public String account_uuid;
        public String lead_source;
        public String lead_source_detail;
        public String utm_campaign_id; 
        public String utm_campaign;
        public String utm_content;
        public String utm_medium;
        public String utm_source;
        public String utm_term;
        public String locale;
        public String country_code;
        public String market;
        public String marketing_consent;
        public string email_opt_out;
    }
 
  /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This wrapper class is used to wrap the person enpoint response.
        Created Date  		:   23 June 2018		
   **************************************************************************************************************************************/    
    public class Response{
        public String contact_sfid;
        public String account_sfid;
        public String billing_account_sfid; 
        public String contact_uuid;
    }
}