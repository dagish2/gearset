/************************************************************************************************************************************
    Author 		: 	Krishana Tupe	
    Description : 	This class contain the business logic of exception logging.
    
    History		:
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION		DATE				AUTHOR					DETAIL
    1			23 April 2018		Krishana Tupe			Initial Developement
    2			03 May 2018 		Krishana Tupe			Chnages for exception logging.
**************************************************************************************************************************************/
global without sharing class ApexDebugLog{
    
/************************************************************************************************************************************
	Author 				: 	Krishana Tupe
	Description 		: 	This method is used publish the platform event that is used to log an exception in apex debug log custom object.
	Created Date		:	03 May 2018
 	Last Modified By 	: 	Krishana Tupe
	Last Modified Date  : 	03 May 2018
**************************************************************************************************************************************/
    public static void logException(Exception ex, String listRecordIds, String strClassName, String strMethodName){
        if(TriggerSettings.mappedField.EnableLogException){
            try{
                Debug.log('Limits.getDMLRows()==>'+Limits.getDMLRows()+' Limits.getQueries()==>'+Limits.getQueries()+' Limits.getDMLStatements()==>'+Limits.getDMLStatements());
                if((Limits.getDMLRows() < Limits.getLimitDMLRows()) && (Limits.getDMLStatements() < Limits.getLimitDMLStatements())){
                    LogException__e newEvent = new LogException__e(
                        Apex_Class__c = strClassName,
                        ErrorLineNumber__c = ex.getLineNumber(),
                        Exception_Type__c = 'Error',
                        ExceptionTypeName__c =ex.getTypeName(), 
                        Message__c = ex.getMessage(),
                        Method__c = strMethodName,
                        Record__c = listRecordIds,
                        Login_User_ProfileId__c =  UserInfo.getProfileId(),
                        Login_UserId__c         =  UserInfo.getUserId(),            
                        Stack_Trace__c = ex.getStackTraceString(),
                        InstanceName__c = ApexDebugLog.getSandboxName()
                    );
                    // Call method to publish events
                    Database.SaveResult sr = EventBus.publish(newEvent);
                    Debug.log('Result of publish Event==>'+sr);  
                }else{
                    Debug.log('The Governor Limits have already been reached and hence failed to create a Log.');
                }   
            }catch(Exception pEx){
                Debug.log('Something fatal has occurred and hence failed to create a Log. Error:' + pEx.getMessage());
            }            
        } 
    }    
 
 /************************************************************************************************************************************
	Author 				: 	Milanjeet Singh
	Description 		: 	This method is used publish the platform event that is used to log an exception in apex debug log custom object.
	Created Date		:	18 June 2018
 **************************************************************************************************************************************/
    public static void logRESTAPIResult(Exception exLog, RESTAPIResult result, RESTAPI.PayloadDetails payload,RestRequest request){
        try{           
            REST_API_Log__c objRestApiLog = new REST_API_Log__c();            
            objRestApiLog.Status__c = (exLog != null) ? 'Exception' : (result != null && result.success != null && result.success) ? 'Success':'Failed';
            objRestApiLog.Result__c = (result != null)? JSON.serializePretty(result):null;
            objRestApiLog.Input_Payload__c = (payload.Input != null)? JSON.serializePretty(payload.Input):null;
            objRestApiLog.Service__c = payload.Service;
            objRestApiLog.Version__c  = payload.Version;            
            objRestApiLog.Request_URL__c = (request != null)? request.requestURI:null;
            objRestApiLog.Logged_In_User__c = UserInfo.getUserId();            
            objRestApiLog.Name = payload.Service + '-' + payload.Version;
            objRestApiLog.Stack_Trace__c = (exLog != null) ? exLog.getStackTraceString() : ''; 
            objRestApiLog.ErrorLineNumber__c = (exLog != null) ? exLog.getLineNumber() : null;
            objRestApiLog.Message__c = (exLog != null) ? exLog.getMessage() : null;
            insert objRestApiLog;          
        }catch(Exception pEx){
            Debug.log('Something fatal has occurred and hence failed to create a Log. Error:' + pEx.getMessage());
            Debug.log('Something fatal has occurred and hence failed to create a Log. Error:' + pEx.getStackTraceString());
        }          
    }
    
    
 /************************************************************************************************************************************
    Author 				: 	Krishana Tupe
    Description 		: 	This method is used to get the current instance name.
    Created Date		:	03 May 2018 	
 **************************************************************************************************************************************/
    public static string getSandboxName(){
        String sandboxname ='';
        if('00DF000000050JfMAI'== UserInfo.getOrganizationId()){
            sandboxname = 'Production';
        }else{
            String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
            Debug.log('baseUrl ==>'+baseUrl);
            Debug.log('Instance Name ==>'+baseUrl.substringBetween('--','.'));
            sandboxname = baseUrl.substringBetween('--','.');            
        }             
        Debug.log('sandboxname==>'+sandboxname.toUpperCase()); 
        return sandboxname.toUpperCase();
    } 
    
/************************************************************************************************************************************
	Author 				: 	Krishana Tupe
	Description 		: 	This method is used to rest callout to rollbar api.
	Created Date		:	29 May 2018
**************************************************************************************************************************************/    
 public static String executeRest(String endpoint,String body){
        HTTP http = new HTTP();        
        HTTPRequest request = new HTTPRequest();
        request.setEndpoint(endpoint);
        request.setHeader('Accept','application/json');
        request.setHeader('Content-type','application/json');
        request.setMethod('POST');        
        request.setBody(body);        
        HTTPResponse response = http.send(request);        
        return response.getBody();        
    }
    
 /************************************************************************************************************************************
	Author 				: 	Krishana Tupe
	Description 		: 	This method is get the access token from the salesforce org.
	Created Date		:	03 May 2018
 	Last Modified By 	: 	Krishana Tupe
	Last Modified Date  : 	03 May 2018
**************************************************************************************************************************************/
    public static Map<String,String> getAccessToken(){
        HTTP http = new HTTP();
        HTTPRequest request = new HTTPRequest();       
        Setting__c accessTokenSetting = Settings.get('AccessTokenSetting'); 
        Map<String,String> mapAccessTokenInfo;
        if(accessTokenSetting != null){
            mapAccessTokenInfo = (Map<String,String>)JSON.deserialize(accessTokenSetting.Data__c,Map<String,String>.class);   
        }  
        String strAccessTokenBody = '';
        for(String key : mapAccessTokenInfo.keySet()){
            if(key != 'setMethod' && Key != 'setEndpoint'){
                strAccessTokenBody += key+'='+mapAccessTokenInfo.get(key)+'&';   
            }           
        }
		strAccessTokenBody = strAccessTokenBody.removeEnd('&');
        request.setBody(strAccessTokenBody);
        request.setEndpoint(mapAccessTokenInfo.get('setEndpoint'));
        request.setMethod(mapAccessTokenInfo.get('setMethod'));
        HTTPResponse response = http.send(request);
        Map<String,String> body = (Map<String,String>)JSON.deserialize(response.getBody(), Map<String,String>.class);
        return body;        
    }
    
    public Enum InvokerType{Triggered, StandardUI, API,AURA}    
    static InvokerType currentInvokerType;
    static String currentInvokerName;
    public static Object currentInvoker;
    
  /************************************************************************************************************************************
	Author 				: 	Krishana Tupe
	Description 		: 	This method is used to register the invoker for transaction.
	Created Date		:	03 May 2018 	
 **************************************************************************************************************************************/ 
    public static boolean registerRootInvoker(InvokerType invokerType, String strInvokerName, Object objInvoker){       
        if(currentInvoker == null) {
            currentInvokerType = invokerType;
            currentInvoker = objInvoker;
            currentInvokerName = strInvokerName;            
            return true;
        }else{             
            return false; 
        }
    }
    
  /************************************************************************************************************************************
	Author 				: 	Krishana Tupe
	Description 		: 	This method is used to identify the transaction is root invoker or not.
	Created Date		:	03 May 2018 	
 **************************************************************************************************************************************/
    public static boolean isRootInvoker(object objInvoker){
        return objInvoker == currentInvoker;
    }
    
/************************************************************************************************************************************
	Author 				: 	Krishana Tupe
	Description 		: 	This method is used to rest callout to external as well as internal systems.
	Created Date		:	03 May 2018
 	Last Modified By 	: 	Krishana Tupe
	Last Modified Date  : 	03 May 2018
**************************************************************************************************************************************/
    public static String executeRest(String accessToken,String endpoint,String body){
        HTTP http = new HTTP();        
        HTTPRequest request = new HTTPRequest();
        request.setEndpoint(endpoint);
        request.setHeader('Authorization','Bearer '+accessToken);
        request.setHeader('Content-type','application/json');
        request.setMethod('POST');        
        request.setBody(body);        
        HTTPResponse response = http.send(request);        
        return response.getBody();        
    }

  
    public virtual class Log{
        public String Type;
        public String ApexClass;
        public String Method;
        public String ProfileId;
        public String RecordId;
        public String UserId;
        public String Message;
        public String StackTrace;
    }
    
    public class Error extends Log{
        public Error(String cls, String routine, String recId, Exception ex){
            this.Type = 'Error';
            this.ApexClass = cls;
            this.Method = routine;
            this.ProfileId = UserInfo.getProfileId();
            this.RecordId = recId;
            this.UserId = UserInfo.getUserId();
            this.Message = ex.getMessage();
            this.StackTrace = ex.getStackTraceString();
        }
    }
    
    public class Warning extends Log{
        public Warning(String cls, String routine, String recId, String msg){
            this.Type = 'Warning';
            this.ApexClass = cls;
            this.ProfileId = UserInfo.getProfileId();
            this.Method = routine;
            this.RecordId = recId;
            this.UserId = UserInfo.getUserId();
            this.Message = msg;
            this.StackTrace = NULL;
        }
    }
    
    public void createLog(Log logToCreate){
        try{
            if(TriggerSettings.mappedField.EnableLogException){
                if((Limits.getDMLRows() < Limits.getLimitDMLRows()) && (Limits.getDMLStatements() < Limits.getLimitDMLStatements())){                   
                    Apex_Debug_Log__c apexDebuglog = new Apex_Debug_Log__c(
                        Type__c         		= logToCreate.Type,
                        Apex_Class__c  			= logToCreate.ApexClass,
                        Method__c       		= logToCreate.Method,
                        Record_Id__c    		= logToCreate.RecordId,
                        Login_User_ProfileId__c	= logToCreate.ProfileId,
                        Login_UserId__c         = logToCreate.UserId,
                        Message__c     			= logToCreate.Message,
                        Stack_Trace__c  		= logToCreate.StackTrace
                    );
                    Database.insert(apexDebuglog, FALSE);
                }
                else{
                    Debug.log('The Governor Limits have already been reached and hence failed to create a Log.');
                }
            }
        } catch(DMLException ex){
            Debug.log('Something fatal has occurred and hence failed to create a Log. Error:' + ex.getMessage());
        }
    } 
    
    public class ApexLogCustomException extends Exception{}
}