global without Sharing class HoldReservableController {
    public class HoldReservableControllerException extends Exception{}
    public static Boolean isInvoker = false;
    public static Savepoint sp {get;set;}
    static {
        isInvoker = ApexDebugLog.registerRootInvoker(ApexDebugLog.InvokerType.AURA, 'HoldReservableController' + 'getsObjectPrefix', ApexDebugLog.InvokerType.AURA);        
    }
    @AuraEnabled
    public static DatabaseResult initialize(Id opportunityId){
        debug.log('Id opportunity ::'+opportunityId);
        try{
            sp = Database.setSavepoint();
            Map<String,Object> mapInitData = new Map<String,Object>();
            Setting__c settingRecord = Settings.get('HoldReservableSettings');
            Opportunity opp = [Select Id,Name,StageName,RecordType.Name,Contract_Stage__c,Building__r.Name,Building__c,Building__r.UUID__c,Billing_Account__r.UUID__c,Billing_Account__r.Name,Primary_Member__c, Primary_Member__r.UUID__c, Primary_Member__r.Email, Primary_Member__r.Phone,Primary_Member__r.Name,Account.Name From Opportunity Where Id =: opportunityId];
            mapInitData.put('Setting',settingRecord);
            mapInitData.put('OpportunityData', opp);
            mapInitData.put('LoggedInUser',UserInfo.getUserId());
            mapInitData.put('currentDate',System.today());
            return new DatabaseResult(mapInitData);
        }catch(Exception pEx){
            if(sp != null){                
                Database.rollback(sp);  
            }
			ApexDebugLog.logException(pEx,opportunityId, 'HoldReservableController', 'initialize');            
            return (new DatabaseResult(pEx));       
        }
    }
    
    //Created by    : Samadhan Kadam
    //Created Date  : 29-Nov-2017
    webservice static String isValidHold(Id oppId){
        string isValid;
        try{
            ValidHoldResultWithOpp validResult = new ValidHoldResultWithOpp();
            validResult.isValidHold = true;
            Setting__c HoldReservable = new Setting__c();
            HoldReservable = Settings.get('HoldReservableSettings'); 
            
            debug.log('HoldReservableSetting'+HoldReservable);     
            HoldReservableSettings settingData = new HoldReservableSettings();
            settingData = (HoldReservableSettings)JSON.deserialize(HoldReservable.Data__c, HoldReservableSettings.class);
            debug.log('settingData123'+settingData);
            debug.log('settingData123 stages ::'+settingData.AllowedStages);
            debug.log('AllowRecordrtypes'+settingData.AllowedRecordTyes);
            Set<String> setOfLowerStages = new Set<String>();
            Set<String> setOfLowerRecordTypes = new Set<String>();
            for(String recordTypes : settingData.AllowedRecordTyes){
                setOfLowerRecordTypes.add(recordTypes.toLowercase());
            }
            for(String stages : settingData.AllowedStages){
                setOfLowerStages.add(stages.toLowercase());
            }
            List<Opportunity> lstOpp = [SELECT Id,StageName,Type__c,Account.OwnerId,Account.Account_Type__c,(SELECT Id,Name,TeamMemberRole,User.Email,User.Id FROM OpportunityTeamMembers), OwnerId,recordTypeId,recordType.Name FROM Opportunity WHERE Id =: oppId LIMIT 1];
            Debug.log('setOfLowerStages ::'+setOfLowerStages);
            Debug.log('lstOpp ::'+lstOpp);
            debug.log('UserInfo.getUserId() ::'+UserInfo.getUserId());
            
            //Modified by Samadhan kadam for ST-2368
            if(lstOpp != null && lstOpp.size() > 0){
                if(setOfLowerStages != null && !setOfLowerStages.isEmpty() && lstOpp.size() > 0 && !lstOpp.isEmpty()){
                    if(!setOfLowerStages.contains(lstOpp[0].StageName.toLowercase())){
                        validResult.isValidHold = false;
                        validResult.errorMsg = 'Opportunity stage should be Selling,Negotiating or Closing for Reservable Hold';
                        debug.log('validResult ::'+validResult);
                        return JSON.serialize(validResult);    
                    }
                    if(lstOpp[0].Type__c=='PxWe' || lstOpp[0].Type__c=='Mixed' || lstOpp[0].Type__c=='Global Access'){
                        validResult.isValidHold = false;
                        validResult.errorMsg = 'Opportunity Product Type should be \'WeWork\'.';
                        debug.log('validResult ::'+validResult);
                        return JSON.serialize(validResult);    
                    }
                }
                //only account owner or opportunity owner can do office hold
                //Modified by Samadhan Kadam for CSI-512 Added validation for hold off.
                Set<ID> setOfTeamMemberId = new Set<ID>();
                If( lstOpp[0].OpportunityTeamMembers.size()!=null){
                    for(OpportunityTeamMember ObjOppTeamMember : lstOpp[0].OpportunityTeamMembers){
                        setOfTeamMemberId.add(ObjOppTeamMember.User.Id);
                    }
                }            
                if((lstOpp[0].OwnerId == UserInfo.getUserId()) || (setOfTeamMemberId.contains(UserInfo.getUserId()))){
                    return JSON.serialize(validResult);
                }else{
                    validResult.isValidHold = false;
                    validResult.errorMsg = 'Only Opportunity Owner Or Opportunity Team Member Can do Reservable Hold';
                    debug.log('validResult ::'+validResult);
                    return JSON.serialize(validResult);
                } 
                debug.log('validResult ::'+validResult);
                return JSON.serialize(validResult); 
            }else{
                validResult.isValidHold = false;
                validResult.errorMsg = 'Opportunity not found with Id '+oppId+'.';
                debug.log('validResult Lstopp ::'+validResult);
                return JSON.serialize(validResult);
            }
            return JSON.serialize(validResult);
        }
        Catch(Exception ex){
            Debug.log('Exception'+ex.getMessage());
            return isValid;
        }
    }
    @AuraEnabled
    public static String isValidHoldLightning(Id oppId){
        return isValidHold(oppId);
    }  
    
    webservice static String holdOffReservable(Id holdId, String sourcePage){
        debug.log('holdId ::'+holdId);
        String methodName = 'POST';
        String endPointUrl;
        Boolean validOwner = false;
        Boolean validStatus = true;
        List<Reservable_Hold__c> lstReservableHold = [SELECT Id,UUID__c,Opportunity__c, Opportunity__r.OwnerId,Approval_Status__c FROM Reservable_Hold__c WHERE Id =: holdId];
        List<Opportunity> lstopp = [SELECT ID,Name,(SELECT Id,User.Email,User.Id FROM OpportunityTeamMembers),(SELECT Id,Name,Approval_Status__c FROM Reservable_Holds__r where Id=:holdId) FROM Opportunity Where ID=:lstReservableHold[0].Opportunity__c];
        Set<ID> setOfTeamMemberId = new Set<ID>();
        If( lstOpp[0].OpportunityTeamMembers.size()!=null){
            for(OpportunityTeamMember ObjOppTeamMember : lstOpp[0].OpportunityTeamMembers){
                setOfTeamMemberId.add(ObjOppTeamMember.User.Id);
            }
        }    
        if((setOfTeamMemberId.contains(UserInfo.getUserId())) || (lstReservableHold.size()!=null && (lstReservableHold[0].Opportunity__r.OwnerId == UserInfo.getUserId()))){
            validOwner = true;
        }else{
            Debug.log('Wrong OwnerId ::');
            return JSON.serialize('{"error": "Only Opportunity Owner or Opportunity Team Member Can Release Hold."}');
        }
        //Change in validation as we changes the Approval Status picklist value-CSI-512
        if((lstReservableHold[0].Approval_Status__c.toLowerCase() == 'released')){
            validStatus = false;
            return JSON.serialize('{"error": "This Reservable is already Released."}');
        }
         if((lstReservableHold[0].Approval_Status__c.toLowerCase() == 'expired')){
            validStatus = false;
            return JSON.serialize('{"error": "This Reservable is already Expired."}');
        }
        debug.log('validStatus ::'+validStatus);
        debug.log('validOwner ::'+validOwner);
        if(validStatus && validOwner){
            Setting__c HoldReservable = Settings.get('HoldReservableSettings'); 
            debug.log('HoldReservableSetting'+HoldReservable);     
            HoldReservableSettings settingData = new HoldReservableSettings();
            settingData = (HoldReservableSettings)JSON.deserialize(HoldReservable.Data__c, HoldReservableSettings.class);
            debug.log('settingData123 ::'+settingData.HoldoffAPI);
    
            String userId = UserInfo.getUserId();
            endPointUrl = settingData.HoldoffAPI.url.replace('HOLD_UUID',lstReservableHold[0].UUID__c);
            Http h1 = new Http();
            HttpRequest req1 = new HttpRequest();
            req1.setEndpoint(endPointUrl);
            req1.setMethod(methodName);
            req1.setHeader('Content-Type','application/json');
            req1.setHeader('Authorization',settingData.HoldoffAPI.Headers.get('Authorization'));
            req1.setHeader('CONTEXT_SALESFORCE_ID',userId);
            req1.setBody('{"removed_from":"'+sourcePage+'"}');
            debug.log('req1 :: '+req1.getBody());
            debug.log('req1 :: '+req1);
            HTTPResponse res = h1.send(req1);
            debug.log('Res :: '+res.getBody());
            debug.log('Res getStatusCode:: '+res.getStatusCode());
            if(res.getStatusCode() == 200){
                lstReservableHold[0].Approval_Status__c = 'Released';
                update lstReservableHold[0];
                Debug.log('Update Hold with Status Released :: '+lstReservableHold[0]);
            }
            debug.log('Res getXmlStreamReader:: '+res.getXmlStreamReader());
            return JSON.serialize(res.getBody());
        }
        return null;
    }
     @AuraEnabled
    public static String holdOffReservableLightning(Id holdId, String sourcePage){
        return holdOffReservable(holdId, sourcePage);
    }  
    global class ValidHoldResultWithOpp{
        global Boolean isValidHold {get;set;}
        global string errorMsg {get;set;}
        global Opportunity objOpportunity {get;set;}
        global List<String> opportunityBuildings {get;set;}
    }
    global class HoldReservableSettings {
        global Set<String> AllowedStages; 
        global Set<String> ReservableType;
        global Set<String> AllowedRecordTyes;
        global Set<String> EmailsForAlerts;
        global API ReservableAvailabilityAPI;
        global API HoldReservableApi;
        global API HoldoffAPI;
       
    }
    global class API{
        global String url;
        global Map<String,String> Headers;
    }
}