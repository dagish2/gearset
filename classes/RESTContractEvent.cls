/**
* Name			:	ContractEventCreateOppUtility	 
* Issue No.		: 	ST-1057 
* Purpose		:	ContractEvent endpoint. Which will search required Opportunity and update if found.
* History		
	Version			Author				Date			Detail						Feature			IssueNumber
	1.0				Mayuresh Ghodke		12/4/2017		Initial Development
	2.0				Shobhit Gahlot		9/1/2018		Payload structure Change	Sellable		CSI-441
***********************************************************************************************************************************************************
*/
@RestResource(urlMapping='/contractEvent/*')
global class RESTContractEvent {
    @HttpPost
    global static Response doPost(WWTypes.ContractEvent body) {
        RestRequest request = RestContext.request;
        String UUID = (String.isNotBlank(body.membership_agreement_uuid)) ? body.membership_agreement_uuid : body.reservation_uuid;
        Boolean resultVal;        
        RESTContractEvent.Response response = new RESTContractEvent.Response();
        RESTAPIResult responseForLogging = new RESTAPIResult();
        boolean isInvoker = ApexDebugLog.registerRootInvoker(ApexDebugLog.InvokerType.API, 'RESTContractEvent' + '.doPost()', ApexDebugLog.InvokerType.API);
        Debug.log('Initial isInvoker ==>'+isInvoker);
        Debug.log('Initial pexDebugLog.isRootInvoker==>'+ApexDebugLog.isRootInvoker(ApexDebugLog.InvokerType.API));
        SavePoint sp;
        RESTAPI.PayloadDetails payloadDetails = new RESTAPI.PayloadDetails();
        try {
            Debug.log('request==>'+request);
            sp = Database.setSavePoint();
            payloadDetails.Input = body;
            payloadDetails.Service = 'Contract Event'+'-'+UUID;
            payloadDetails.Version = 1;
            Debug.log('payloadDetails==>'+payloadDetails);
            Debug.log('ContractEvent : body:: '+body);
            String result = ContractEventServices.selectContractEvent(body);
            ResponseForLogging responselog = new ResponseForLogging();
            responselog.result = result;
            Debug.log('ContractEvent : result:: '+result);
            if(result.startsWith('New Opportunity :') || result.startsWith('Update Opportunity :')){
                resultVal = true; 
                response.setSuccess(result,resultVal);
                responseForLogging.setSuccess('Contract Processed!', responselog);//This is only used for logging into REST_API_Log__c
            }else{
                responseForLogging.setFailure('Contract Failed', responselog);//This is only used for logging into REST_API_Log__c
                resultVal = false;   
            }
            ApexDebugLog.logRESTAPIResult(null, responseForLogging, payloadDetails, request);   
        }catch(Exception pEx) {
            Debug.Log('pEx message---'+pEx.getMessage());
            Debug.Log('pEx stacktrace---'+pEx.getStackTraceString());
            response.setFailure(WeworkEngine.exceptionFormatter(pEx));
            if(sp != null){
                Database.rollback(sp);
            }
            responseForLogging.setFailure('Contract Failed', pEx.getMessage());//This is only used for logging into REST_API_Log__c
            ApexDebugLog.logRESTAPIResult(pEx, responseForLogging, payloadDetails, request);            
        }	    
        return response;
    }
    
    global class Response {
        public Boolean success;
        public String message;
        public String result;
        
        public void setSuccess(Object pResult, Boolean successVal) {
            this.success = successVal; 
            this.result = pResult != null ? JSON.serializePretty(pResult) : '';
        }
        
        public void setFailure(String pMessage) {
            this.success = false; 
            this.message = pMessage;
        }
    }
    
    global class ResponseForLogging {
        public String result;        
    }
}