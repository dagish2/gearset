/************************************************************************************************************************************
    Author 		: 	Krishana Tupe	
    Description : 	This class used to accepts the REST request from external systems and wrap data into appropriate version.
    
    History		:
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION		DATE				AUTHOR					DETAIL   
    1			14 June 2018 		Krishana Tupe			Initial Development.
**************************************************************************************************************************************/
@RestResource(urlMapping='/api/*')
global abstract class RESTAPI{
    //api/1/Tour
    //api/2/Tour?mock=true&success=true
    //api/InboundLead/1
    //api/InboundLead/2
    
  /*************************************************************************************************************************************
        Author 				: Krishana Tupe
        Description  		: This method used to accepts the REST request from external systems and wrap data into appropriate version.
        Created Date		: 14 June 2018 	       
  **************************************************************************************************************************************/
    @HttpPost
    global static void doPost(){
        RestRequest request = RestContext.request;
        SavePoint sp = Database.setSavePoint();
        RESTAPIResult result = new RESTAPIResult();
        PayloadDetails payload;
        try{
            payload = getPayload(request);
            if(payload != null && payload.ClassType != null ){
                //Check the payload for mock if its for mock, below will handle the mock call
                //Check if mock call returns success or failure response otherwise execute api
                if(payload.IsMockCall){
                    if( payload.APIModelsType != null ){
                        RESTAPIModel api = (RESTAPIModel)(payload.APIModelsType).newInstance();
                        payload.Input = api.getMockModel(payload);
                    }
                    if(payload.IsMockCallSuccessful){
                        result.setSuccess('Mock Response : Success',payload.Input);
                    }else{
                        result.setFailure('Mock Response : Failure',payload.Input);
                    }  
                }else{
                    RESTAPIBase api = (RESTAPIBase)(payload.ClassType).newInstance();
                    api.parseInput(payload);
                    result = api.executePost(payload);
                    Debug.log('RESTAPI result---'+result);
                    ApexDebugLog.logRESTAPIResult(null, result, payload, request);
                }
            }else{
                ApexDebugLog.logRESTAPIResult(null, result, payload, request);
                result.setFailure('Not Implemented');
            }
        }catch(Exception objException){            
            Debug.log('RESTAPI objException getMessage::'+objException.getMessage());
            Debug.log('RESTAPI objException getStackTraceString ::'+objException.getStackTraceString());
            Database.rollback(sp);
            result.setFailure(objException.getMessage());
            ApexDebugLog.logRESTAPIResult(objException, result,payload,request);
        }
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(result));
    }
    
    @HttpGet
    global static void doGet() {
        RestRequest req = RestContext.request;
        RESTAPIResult result = new RESTAPIResult();
        PayloadDetails payloadInfo = getPayload(req);
        if(payloadInfo != null && payloadInfo.ClassType != null ){
            RESTAPIBase itr = (RESTAPIBase)(payloadInfo.ClassType).newInstance();
            result  = itr.executeGet(payloadInfo);            
        }
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(result));        
    }
    
  /****************************************************************************************************************************
        Author 				: Krishana Tupe
        Description  		: This method used return the payload information such as service,Version,Body and ClassType.
        Created Date		: 14 June 2018 	       
   *****************************************************************************************************************************/
    global static PayloadDetails getPayload(RestRequest req){
        String body;
        Debug.log('req =>'+req);
        if(req.requestBody != null && String.isNotBlank(req.requestBody.toString())){
            body = req.requestBody.toString();
        }
        String [] url;
        if(String.isNotBlank(req.requestURI)){
            url = req.requestURI.split('/');
        }      
        String service;
        Integer version;
        if(url != null && url.size() > 3){              
            service = url[3];
            version = Integer.valueOf(url[2]);      
        }     
       
        String className = 'RESTAPI'+service+'V'+version;
        String apiModel = 'RESTAPI'+service+'Models'+'V'+version;
        Type classType = Type.forName(className);
        PayloadDetails payloadDetails = new PayloadDetails();
        payloadDetails.Service = service;
        payloadDetails.Version = version;
        payloadDetails.ClassType = classType;
        payloadDetails.ClassName = className;
        payloadDetails.APIModelsClassName = apiModel;
        payloadDetails.APIModelsType = Type.forName(apiModel);
        payloadDetails.Body = body;
        payloadDetails.IsMockCall = false; //By default mock call should be false unless mock param is sent as true in request url
        payloadDetails.IsMockCallSuccessful = true; //By default if mock call is called it should be successful
        
        if(!req.params.isEmpty() && req.params.get('mock') != null && boolean.valueOf(req.params.get('mock'))){
            //Try to parse mock and mocksuccess params to override IsMockCall and IsMockCallSuccessful
            try{ payloadDetails.IsMockCall = boolean.valueOf(req.params.get('mock')); }catch(Exception ex){}
            try{ payloadDetails.IsMockCallSuccessful = boolean.valueOf(req.params.get('mocksuccess')); }catch(Exception ex){}
        }
        Debug.log('payloadDetails ::'+payloadDetails);
        return payloadDetails;
    }
    
 /****************************************************************************************************************************
        Author 				: Krishana Tupe
        Description  		: This wrapper class is used to wrap the rest request information.
        Created Date		: 14 June 2018 	       
  *****************************************************************************************************************************/ 
    global class PayloadDetails{
        global String Service {get;set;}
        global Integer Version {get;set;}
        global String Body {get;set;}
        global Object Input {get;set;} 
        global String ClassName {get;set;}        
        global Type ClassType {get;set;}
        global Type APIModelsType {get;set;}
        global String APIModelsClassName {get;set;}
        global Boolean IsMockCall {get;set;}
        global Boolean IsMockCallSuccessful {get;set;}
    } 
}