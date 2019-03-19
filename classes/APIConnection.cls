/******************************************************************************************************************** 
Name              : APIConnection.cls 
Description       : API Connection class .

Revision History  :-
Created/Modified by         Created/Modified Date       Requested by         Technical Design Proposal
---------------------------------------------------------------------------------------------------------------------
1. Rashad Saeed (Creator)      31 DEC 2018              WeWork                
---------------------------------------------------------------------------------------------------------------------
*********************************************************************************************************************/
public class APIConnection{
    
    private HttpRequest req;
    private Integration_Data__mdt CMT;
    private Http caller;
    Private String endPoint;
    
    public APIConnection(String project) {
        CMT = [SELECT EndPoint__c, Headers__c ,Method__c 
               FROM Integration_Data__mdt 
               WHERE DeveloperName = :project AND
               		 Is_Active__c = true
               LIMIT 1] ; 
        this.endPoint = CMT.EndPoint__c;
        this.req = new HttpRequest();
        If (CMT.Headers__c <> null){
            Map<String, Object> HeadersData = (Map<String, Object>)JSON.deserializeUntyped(CMT.Headers__c);
            for (String Key :HeadersData.keySet())
                this.req.setHeader(key,(String)HeadersData.get(key));
        }
        this.caller = new Http();
    }
    
    public HttpResponse sendRequest(String messageBody) {
        req.setEndpoint(endPoint);
        req.setMethod(CMT.Method__c); 
        req.setBody(messageBody);
        HttpResponse resp = caller.send(req);
        return resp;
    }
    
    public void setEndPointParams (list <string> endPointParamsLST)
    {
        for(Integer i = 0; i < endPointParamsLST.size(); i++)
        {
            endPoint = endPoint.replace('{' + string.valueOf(i) + '}', endPointParamsLST[i]);
        }
    }
}