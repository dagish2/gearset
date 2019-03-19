/**
* Name			:	ContractEventServices	 
* Issue No.		: 	CSI-492 
* Purpose		:	This is contains the logic for recognizing the event name and redirecting to the right class.
* History		
	Version			Author				Date			Detail						Feature			IssueNumber
	1.0				Mayuresh Ghodke		12/4/2017		Initial Development							ST-1057, 1133
	2.0				Shobhit Gahlot		9/1/2018		Payload structure Change	Sellable		CSI-441
***********************************************************************************************************************************************************
*/ 

global with sharing class ContractEventServices {
    //used by RESTContractEvent contractEvent API
    public static String selectContractEvent(WWTypes.ContractEvent objContractEvent){
            Debug.log('ContractEvent : Update objContractEvent.event_name : '+objContractEvent.event_name);
            if( !String.isBlank(objContractEvent.company_uuid) && 
               !String.isBlank(objContractEvent.event_name)  &&
               (!String.isBlank(objContractEvent.reservation_uuid) || !String.isBlank(objContractEvent.membership_agreement_uuid)) && 
               (objContractEvent.move_ins != null || objContractEvent.move_outs != null)&&
               !String.isBlank(objContractEvent.primary_member_email)){

                   ContractEventUtilities.ContractEventUtilitiesVal objContractEventUtilitiesVal = ContractEventUtilities.utilityWrapperInitialize(objContractEvent); 
                   if(String.isNotBlank(objContractEvent.opportunity_id)){
                      objContractEventUtilitiesVal.objUtilityWapper.oppToUse = ContractEventFetchOpportunity.getOpportunityWithLock(new Map<String,Object>{'payload'=>objContractEvent}); 
                   }
                   /*
                    Issue No.   : ST-1389
                    Created By  : Mayuresh Ghodke
                    Date    : 25 Sept'17
                    Comment   : Synch Hotdesk Opportunity
                    */
                   if(!String.isBlank(objContractEvent.reservation_uuid) && objContractEvent.event_name.toLowerCase() == 'contract signed'){
                       return ContractEventHotDesk.hotDesk(objContractEventUtilitiesVal.objContractEvent,objContractEventUtilitiesVal.objUtilityWapper);
                   }
                   
                   if(objContractEvent.event_name.toLowerCase() == 'contract sent'){
                       return ContractEventSent.contractSent(objContractEventUtilitiesVal.objContractEvent,objContractEventUtilitiesVal.objUtilityWapper);
                   }
                   /*
                    * Name    : Mayuresh Ghodke
                    * Issue No. : ST-1428
                    * Date    : 20th Sept'17
                    * Comment : When we get event_name = 'Contract Canceled' then we need to find out the opportunity with given contract uuid or Opportunity id and will cancel that opportunity.
                    */
                   else if(objContractEvent.event_name.toLowerCase() == 'contract canceled'){
                       return ContractEventCancel.contractCanceled(objContractEventUtilitiesVal.objContractEvent,objContractEventUtilitiesVal.objUtilityWapper);
                   }
                   /*
                    * Name    : Mayuresh Ghodke
                    * Issue No. : CSI-302
                    * Date    : 2nd Nov'17
                    * Comment : When we get event_name = "Cancel Moveout" then we need to find out the opportunity with given contract uuid or Opportunity id and will search Opportunity move out for them and cancel them.
                    */
                   else if(objContractEvent.event_name.toLowerCase() == 'cancel moveout'){
                       debug.log('ContractEventServices ::'+objContractEvent.event_name.toLowerCase());
                       return ContractEventCancel.cancelMoveout(objContractEventUtilitiesVal.objContractEvent,objContractEventUtilitiesVal.objUtilityWapper);
                   }
                   else{
                       return ContractEventSignedVoidedDiscarded.contractSignedVoidedDiscarded(objContractEventUtilitiesVal.objContractEvent,objContractEventUtilitiesVal.objUtilityWapper);
                   }
               }
            else{
                String missingFields = null;
                if(objContractEvent.company_uuid == null || objContractEvent.company_uuid.length() == 0)
                    missingFields = 'company_uuid';
                if(objContractEvent.primary_member_email == null || objContractEvent.primary_member_email.length() == 0)
                    missingFields = (missingFields != null) ? '  primary_member_email ,'+missingFields : 'primary_member_email';
                if(objContractEvent.event_name == null || objContractEvent.event_name.length() == 0 )
                    missingFields = (missingFields != null) ? ' , event_name ,'+missingFields : 'event_name';
                if(objContractEvent.membership_agreement_uuid == null || objContractEvent.membership_agreement_uuid.length() == 0)
                    missingFields = (missingFields != null) ? '  membership_agreement_uuid ,'+missingFields : 'membership_agreement_uuid ';
                if(objContractEvent.move_ins == null || objContractEvent.move_outs == null)
                    missingFields = (missingFields != null) ? '  move_ins or move_outs ,'+missingFields : 'move_ins or move_outs';
                
                return missingFields+' required fields missing.';
                
            }
    }
    
    public static Decimal convertToOrgCurrency( Decimal currencyVal, Decimal ConversionRate) {
        try{
            Decimal res;
            debug.log('convertToOrgCurrency currencyVal : '+currencyVal+' ConversionRate : '+ConversionRate +' : currencyVal / ConversionRate');
            res =  currencyVal / ConversionRate;
            debug.log('convertToOrgCurrency res= ' + res);
            return res;
        } catch(Exception pEx) {
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('ContractForRef','convertToOrgCurrency', 'currencyVal == > '+ currencyVal + ' ConversionRate ==> '+ ConversionRate, pEx)
            );
            throw new ContractForRefException(pEx.getMessage());
        }
    }
    
    
    public static Decimal convertFromOrgCurrency(Decimal currencyVal, Decimal ConversionRate) {
        try{
            Decimal res;
            debug.log('convertFromOrgCurrency currencyVal : '+currencyVal+' ConversionRate : '+ConversionRate+' : currencyVal * ConversionRate');
            res =  currencyVal * ConversionRate;
            debug.log('convertFromOrgCurrency res= ' + res);
            return res;
        } catch(Exception pEx) {
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('ContractForRef','convertFromOrgCurrency',' currencyVal == > '+ currencyVal + ' ConversionRate ==> '+ ConversionRate, pEx)
            );
            throw new ContractForRefException(pEx.getMessage());
        }
    }
    
    /*
    Name    : Mayuresh G
    Issue No.   : ST-1310
    Date    : 1st Sept'17
    Comment   : Discard Contract Event : Apex: Opportunity: Enable Users to Cancel Paperwork from SFDC
    */
    webservice static String discardContractEventMethod(String contractUUID){
        JsonContractEventAPI objJSONContractAPI = new JsonContractEventAPI();
        Setting__c RecordJSONContractAPI = Settings.get('ContractEventEndpoints');
        List<Opportunity> lstOpportunities = [Select Id, Contract_Stage__c, StageName From Opportunity Where Contract_UUID__c =: contractUUID];
        objJSONContractAPI = (JsonContractEventAPI)JSON.deserialize(RecordJSONContractAPI.Data__c, JsonContractEventAPI.Class);
        String result = null;
        Debug.log('objJSONContractAPI==>'+objJSONContractAPI);
        if(objJSONContractAPI != null && objJSONContractAPI.API[0].AllowedOppStage.size()>0 && objJSONContractAPI.API[0].AllowedContractStage.size()>0){
            if(objJSONContractAPI.API[0].AllowedOppStage.contains(lstOpportunities[0].StageName) && objJSONContractAPI.API[0].AllowedContractStage.contains(lstOpportunities[0].Contract_Stage__c)){
                if(contractUUID!= null){
                    result = makeContractDiscardCallout(contractUUID);
                }
                return result;
            }else {
                return '{"meta":{"success":false},"result":{"error":"Opportunity stage should be in ' + string.join(objJSONContractAPI.API[0].AllowedOppStage,',') +' stage and Contract stage should be in ' + string.join(objJSONContractAPI.API[0].AllowedContractStage,',')+' stage to discard the contract"}}';
            }
        }
        else if(objJSONContractAPI != null && contractUUID!= null){
            result = makeContractDiscardCallout(contractUUID);
        }
        return result;
    }
     
    webservice static String makeContractDiscardCallout(String contractUUID){
        JsonContractEventAPI objJSONContractAPI = new JsonContractEventAPI();
        Setting__c RecordJSONContractAPI = Settings.get('ContractEventEndpoints');
        objJSONContractAPI = (JsonContractEventAPI)JSON.deserialize(RecordJSONContractAPI.Data__c, JsonContractEventAPI.Class);
        String result = null;
        objJSONContractAPI.API[0].url = objJSONContractAPI.API[0].url.replace('contractUUID',contractUUID);
            Http h1 = new Http();
            HttpRequest req1 = new HttpRequest();
            req1.setEndpoint(objJSONContractAPI.API[0].url);
            req1.setMethod('POST');
            req1.setHeader('Authorization', objJSONContractAPI.API[0].apikey);
            req1.setHeader('Cache-Control', 'no-cache');
            req1.setHeader('Content-Type', 'application/json');
            req1.setHeader('Access-Control-Allow-Origin', '*');
           	req1.setHeader('Access-Control-Allow-Headers', 'accept, content-type, x-parse-application-id, x-parse-rest-api-key, x-parse-session-token');
            HttpResponse res1 = h1.send(req1);
            Debug.log('Response in Response1Callback res1.getBody() :: '+res1.getBody());
            result = res1.getBody(); 
            return result;
       }

    @AuraEnabled
    public static String discardContractEvent(String contractUUID){
        return discardContractEventMethod(contractUUID);
    }
    
    webservice static String updateOppValsContractDiscard(String contractUUID){
        try{
            List<Opportunity> lstOppToUpdate = [Select Id, Contract_Stage__c, StageName, Move_outs_Closed_Lost__c,Move_Out_Building__c From Opportunity Where Contract_UUID__c =: contractUUID];
            if(lstOppToUpdate.size() > 0 && lstOppToUpdate != null){
                lstOppToUpdate[0].Contract_Stage__c = 'Contract Discarded';
                //oppToUpdate.StageName = 'Closed Lost';
                update lstOppToUpdate[0];
                return 'true';
            }
            else
                return 'false';
        }catch(Exception ex){
            return 'false';
        }
        
    }
    @AuraEnabled
    public static String updateOppContractDiscard(String contractUUID){
        return updateOppValsContractDiscard(contractUUID);
    }
    
    @AuraEnabled
    public static Opportunity getOppData(String oppId){
        Opportunity opp = new Opportunity();
        opp = [Select Id, contract_uuid__c, Move_Out_Building__c,StageName,Contract_Stage__c from Opportunity where id =: oppId];
        return opp;
    }

    webservice static String resendPaperwork(String contractUUID){
        Debug.log('In resendPaperworkMethod :: ');
        JsonContractEventAPI objJSONContractAPI = new JsonContractEventAPI();
        Setting__c RecordJSONContractAPI = Settings.get('ResendPaperwork');
        Debug.log('contractUUID :: '+ contractUUID);
        Debug.log('RecordJSONContractAPI :: '+ RecordJSONContractAPI);
        objJSONContractAPI = (JsonContractEventAPI)JSON.deserialize(RecordJSONContractAPI.Data__c, JsonContractEventAPI.Class);
        Debug.log('objJSONContractAPI :: '+ objJSONContractAPI);
        String result = null;
        if(objJSONContractAPI != null && contractUUID!= null){
            Debug.log('contractUUID :: '+contractUUID);
            Debug.log('objJSONContractAPI.API[0].url :: '+ objJSONContractAPI.API[0].url);
            objJSONContractAPI.API[0].url = objJSONContractAPI.API[0].url.replace('contractUUID',contractUUID);
            Http h1 = new Http();
            HttpRequest req1 = new HttpRequest();
            req1.setEndpoint(objJSONContractAPI.API[0].url);
            req1.setMethod('POST');
            req1.setHeader('Authorization', objJSONContractAPI.API[0].apikey);
            //req1.setHeader('Authorization', 'Token token=dIc0nYcdaPvmFzUq3e0-CQ');
            req1.setHeader('Cache-Control', 'no-cache');
            req1.setHeader('Content-Type', 'application/json');
            req1.setHeader('Access-Control-Allow-Origin', '*');
            req1.setHeader('Access-Control-Allow-Headers', 'accept, content-type, x-parse-application-id, x-parse-rest-api-key, x-parse-session-token');
            HttpResponse res1 = h1.send(req1);
            Debug.log('Response in Response1Callback res1.getBody() :: '+res1.getBody());
            result = res1.getBody(); 
        }
        return result;
    }
    @AuraEnabled
    public static String resendPaperworkLightning(String contractUUID){
        return resendPaperwork(contractUUID);
    }

    /*
    ContractEvent API setting classess
    */
    public class API {
        public String Name;
        public String url;
        public String apikey;
        public List<String> AllowedOppStage;
        public List<String> AllowedContractStage;  
    }
    
    public class JsonContractEventAPI {
        public List<API> API;
    }

    public class ContractForRefException extends Exception {}
}