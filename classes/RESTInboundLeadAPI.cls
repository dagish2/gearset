/************************************************************************************************************************************
  Author     	: Pranay Jadhav.
  Description 	: This class exposes the Lead via SFDC's REST API.
   
  History		:
----------------------------------------------------------------------------------------------------------------------------------
  VERSION      	DATE        		AUTHOR          	DETAIL              	ISSUE
	1			5th June 2018   	Pranay Jadhav     	Initial Developement    ST-  	
**************************************************************************************************************************************/
@RestResource(urlMapping='/InboundLead/*')
global class RESTInboundLeadAPI {
    public static Savepoint sp {get;set;}
    global static set<Id> leadIds;
    @HttpPost 
    global static Response doPost(WWTypes.InboundLead body){
        boolean isInvoker = ApexDebugLog.registerRootInvoker(ApexDebugLog.InvokerType.API, 'RESTInboundLeadAPI' + '.doPost()', ApexDebugLog.InvokerType.API);
        RESTInboundLeadAPI.Response response = new RESTInboundLeadAPI.Response();
        Debug.log('InboundLead body==>'+body);
        try{
            sp = Database.setSavepoint();
            leadIds = new set<Id>(); 
            leadIds.add(new RESTInboundLeadAPIController(body).handlePostRequest());
            Response.setSuccess(leadIds);
        }catch(Exception pEx){
            Debug.log('RESTInboundLeadAPI StackTrace ==>  '+pEx.getStackTraceString());
            Response.setFailure(pEx);
            if(sp != null){
                Database.rollback(sp);
            }
            if(ApexDebugLog.isRootInvoker(ApexDebugLog.InvokerType.API)){
                ApexDebugLog.logException(pEx,JSON.serialize(body),'RESTInboundLeadAPI','doPost');
            }
        }
        Debug.log('RESTInboundLeadAPI response ==>  '+response);
        return response;
    }
    
    global class Response {
        public Boolean success;
        public String message;
        public String lead_sfid;
        public String contact_sfid;
        public void setSuccess(set<Id> leadIds){
            this.success = true;
            if(leadIds!=null && !leadIds.isEmpty()){
                this.lead_sfid = (new List<Id>(leadIds))[0];
                this.message = 'Lead processed!'; 
            }
        }
        public void setFailure(Exception pMessage) {
            this.success = false;
            this.message = pMessage.getMessage();
        }
    }
}