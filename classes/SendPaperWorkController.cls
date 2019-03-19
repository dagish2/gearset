/************************************************************************************************************************************
Author      :   Priyanka Ambre
Description :   This class contain all aura methods related to SendPaperWork.
----------------------------------------------------------------------------------------------------------------------------------
VERSION     DATE                AUTHOR                  DETAIL
1           19 July 2018        Priyanka Ambre          Initial Developement
**************************************************************************************************************************************/
global without sharing class SendPaperWorkController {
    public class SendPaperWorkControllerException extends Exception{}
    public static Boolean isInvoker = false;
    public static Savepoint sp {get;set;}
    static SendPaperworkSetting sendPaperWorkSetting;
    static ValidResultWithOpp validResult;
    static {
        isInvoker = ApexDebugLog.registerRootInvoker(ApexDebugLog.InvokerType.AURA, 'SendPaperWorkController' + 'getsObjectPrefix', ApexDebugLog.InvokerType.AURA);        
        sendPaperWorkSetting = (SendPaperworkSetting)JSON.deserialize(Settings.get('SendPaperworkSetting').Data__c, SendPaperworkSetting.class);        
    } 
    
    /************************************************************************************************************************************
    Author              : Priyanka Ambre
    Description         : This method is used for check if th opportunity is valid for sendPaperWork.
    Created Date        : 18 July 2018 
    Issue No            : ST-1045, ST-2201, ST-2327. 
    **************************************************************************************************************************************/
    webservice static string isValidOppforSendPaperwork(Id oppId) {
        validResult = new ValidResultWithOpp();
        Opportunity objOpportunity = [SELECT Id,AccountId,Type__c,Account.OwnerId,Account.Account_Type__c,Billing_Account__c,Billing_Account__r.UUID__c,RecordTypeId,RecordType.Name,StageName,Contract_Stage__c,Account.uuid__c,Encoded_ID__c,Building_uuid__c,Actual_Start_Date__c,OwnerId,Locations_Interested__c,Building__c, Building__r.Name, Primary_Member__c from Opportunity WHERE Id =: oppId Limit 1];
        validResult.isValid = true;
        Set<String> setLocationIntrested =  new Set<String>();  
        if(String.isNotBlank(objOpportunity.Locations_Interested__c)){
            setLocationIntrested.addAll(objOpportunity.Locations_Interested__c.split(';')); 
        } 
        
        if(setLocationIntrested.size()>0){
            validResult.opportunityBuildings = new List<String>();
            for(Building__c objBuilding : [SELECT Id, UUID__c FROM Building__c WHERE Name IN : setLocationIntrested]) { 
                if(objBuilding.UUID__c != null)
                    validResult.opportunityBuildings.add(objBuilding.UUID__c);
            }  
        }
        
        switch on objOpportunity.RecordType.Name {
            when 'Consumer'{
                if(validResult.isValid){
                    validateStageNameContractStage(objOpportunity);
                }
                if(validResult.isValid){
                    if(objOpportunity.Building__c == null || objOpportunity.Primary_Member__c == null){
                        validResult.isValid = false; 
                        if(objOpportunity.Building__c == null){
                            validResult.errorMsg ='Building is a required field while sending the paperwork.';
                        }else if(objOpportunity.Primary_Member__c == null){
                            validResult.errorMsg ='Primary Member is a required field while sending the paperwork.';  
                        }  
                    }
                }
            }
            when 'Mid Market'{
                if(validResult.isValid){
                    validateStageNameContractStage(objOpportunity);
                }
                User loggedInUser = new User();
                if(Settings.mapUserById != null && Settings.mapUserById.size()>0 && Settings.mapUserById.containsKey(userinfo.getUserID())){
                    loggedInUser = Settings.mapUserById.get(userinfo.getUserID());
                }else{
                    loggedInUser=[Select Id, Name, Email, UserRole.Name, IsActive, ProfileId, Profile.Name from User where Id =: userinfo.getUserID()];
                } 
                if(validResult.isValid){
                    validateAllowedProfiles(loggedInUser, objOpportunity);
                }
            }
            when 'Enterprise Solutions'{
                if(validResult.isValid){
                    validateStageNameContractStage(objOpportunity);
                }
                if(validResult.isValid){
                    validateProductTypes(objOpportunity);
                }
                User loggedInUser = new User();
                if(Settings.mapUserById != null && Settings.mapUserById.size()>0 && Settings.mapUserById.containsKey(userinfo.getUserID())){
                    loggedInUser = Settings.mapUserById.get(userinfo.getUserID());
                }else{
                    loggedInUser=[Select Id, Name, Email, UserRole.Name, IsActive, ProfileId, Profile.Name from User where Id=:userinfo.getUserID()];
                }
                
                if(validResult.isValid){
                    validateAllowedProfiles(loggedInUser, objOpportunity);
                }
                //As this is duplicate, We Modified and Bypass the Stage Validation in validateAllowedEnterpriseProfiles method
                if(validResult.isValid){
                    validateAllowedEnterpriseProfiles(loggedInUser, objOpportunity);   
                }
            }
            when else {
                System.debug('default');
            }
        }
        if(!validResult.isValid){
            validResult.isValidOwner = false;
            validResult.objOpportunity = null;
        }else{
            validResult.isValid = true;
            validResult.isValidOwner = true;
            validResult.objOpportunity = objOpportunity;
            validResult.errorMsg = null;
        }
        return JSON.serialize(validResult); 
    }
    
    /************************************************************************************************************************************
    Author              : Priyanka Ambre
    Description         : This method is used to check validation for Product Type.
    Created Date        : 18 July 2018 
    Issue No            : ST-
    **************************************************************************************************************************************/
    public static void validateProductTypes(Opportunity objOpportunity){
        Map<String, String> mapExcludedProductTypes = new Map<String, String>();
        if(sendPaperWorkSetting.ExcludedProductTypes != null){
            for(String strProductType : sendPaperWorkSetting.ExcludedProductTypes){
                mapExcludedProductTypes.put(strProductType.toLowerCase(), strProductType);
            }                  
        }
        if(objOpportunity.Type__c != null && String.valueOf(objOpportunity.Type__c) != null && mapExcludedProductTypes.containsKey(String.valueOf(objOpportunity.Type__c).toLowerCase())){
            validResult.isValid = false;
            validResult.isValidOwner = false;
            validResult.objOpportunity = null;
            validResult.errorMsg ='You cannot send paperwork for this Opportunity if Product Type is \''+String.join(mapExcludedProductTypes.values(), '\' or \'')+'\'';
        }
    }
    
    /************************************************************************************************************************************
    Author              : Priyanka Ambre
    Description         : This method is used to check validation for ContractStage and stageName.
    Created Date        : 18 July 2018 
    Issue No            : ST-
    **************************************************************************************************************************************/
    public static void validateStageNameContractStage(Opportunity objOpportunity){
        if((objOpportunity.StageName == 'Closing' || objOpportunity.StageName == 'Closed Won') && (objOpportunity.Contract_Stage__c == 'Contract Sent' || objOpportunity.Contract_Stage__c == 'Contract Signed')){
            validResult.isValid = false;
            validResult.errorMsg ='Contract has already been sent.';
        }
    }
    
    /************************************************************************************************************************************
    Author              : Priyanka Ambre
    Description         : This method is used to check if user is valid or not.
    Created Date        : 18 July 2018 
    Issue No            : ST-
    **************************************************************************************************************************************/
    public static void validateAllowedProfiles(User loggedInUser, Opportunity objOpportunity){
        Map<String, String> mapExcludedProfiles = new Map<String, String>();
        if(sendPaperWorkSetting.Excludedprofiles != null){
            for(String strProfile : sendPaperWorkSetting.Excludedprofiles){
                mapExcludedProfiles.put(strProfile.toLowerCase(), strProfile);
            }
        }
        
        if(!(mapExcludedProfiles.containsKey(loggedInUser.Profile.Name.toLowerCase()))){
            stageClosingValidation(objOpportunity); 
            if(validResult.isValid  && objOpportunity.RecordTypeId != Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise Solutions').getRecordTypeId()){
                oppOwnerValidation(objOpportunity); 
            }
        }
    }
    
    /************************************************************************************************************************************
    Author              : Priyanka Ambre
    Description         : This method is used to check if user is valid or not for Enterprise profiles.
    Created Date        : 18 July 2018 
    Issue No            : ST-
    **************************************************************************************************************************************/
    public static void validateAllowedEnterpriseProfiles(User loggedInUser, Opportunity objOpportunity){
        Map<String, String> mapExcludedProfiles = new Map<String, String>();
        if(sendPaperWorkSetting.Excludedprofiles != null){
            for(String strProfile : sendPaperWorkSetting.AllowedEnterpriseProfiles){
                mapExcludedProfiles.put(strProfile.toLowerCase(), strProfile);
            }
        }
        if(!(mapExcludedProfiles.containsKey(loggedInUser.Profile.Name.toLowerCase()))){
            stageClosingValidation(objOpportunity);
            if(validResult.isValid && !(mapExcludedProfiles.containsKey(loggedInUser.Profile.Name.toLowerCase()))){ 
                oppOwnerValidation(objOpportunity); 
            }
        }
    }
    
    /************************************************************************************************************************************
    Author              : Priyanka Ambre
    Description         : This method is used for oppOwnerValidation.
    Created Date        : 18 July 2018 
    Issue No            : ST-
    **************************************************************************************************************************************/
    public static void oppOwnerValidation(Opportunity objOpportunity){
        if(UserInfo.getUserId() != objOpportunity.OwnerId){
            validResult.isValid = false; 
            validResult.errorMsg = 'You should be the owner of the opportunity to perform send paperwork.';
        }        
    }
	/************************************************************************************************************************************
    Author              : Priyanka Ambre
    Description         : This method is used for stageClosingValidation.
    Created Date        : 18 July 2018 
    Issue No            : ST-
    **************************************************************************************************************************************/
    public static void stageClosingValidation(Opportunity objOpportunity){
        if(objOpportunity.StageName != 'Closing'){
            validResult.isValid = false; 
            validResult.errorMsg = 'Opportunity stage should be closing for sending paperwork.';
        }
    }
   
  /************************************************************************************************************************************
	Author              : Shobhit Gahlot
	Description         : This function is used to generate uuid used in sendpaperwork button on opportunity
	Created Date        : 24-June-2017
	Issue No.           : ST-1298
  ***********************************************************************************************************************************
    Author              : Krishana Tupe
	Description         : Added comment structure
	Modified Date       : 28-July-2018	
   ************************************************************************************************************************************/
    webservice static String getOpportunityEncodedID(Id opportunityId) {
        Debug.log('IN getOpportunityEncodedID ==>'+opportunityId);
        return EncodingUtil.base64Encode(Blob.valueOf(opportunityId));
    }
    
  /************************************************************************************************************************************
	Author              : Shobhit Gahlot
	Description         : This function is used to generate uuid used in sendpaperwork button on opportunity
	Created Date        : 24-June-2017
	Issue No.           : ST-1298
  ***********************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult  isValidOpportunityforSendPaperwork(Id oppId) {
        try{
            return new DatabaseResult(SendPaperWorkController.isValidOppforSendPaperwork(oppId));
        } catch(Exception ex){                      
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('SendPaperWorkController','isValidOpportunityforSendPaperwork',oppId, ex)
            );
            return (new DatabaseResult(ex));        
        } 
    }
       
    
    /**************************************************************************************************************************************************
   	 Author              : Priyanka Ambre
   	 Description         : This is a Class to hold SendPaperworkSetting Details.
   	 Created Date        : - 
    ***************************************************************************************************************************************************/
    global class SendPaperWorkSetting {
        global List<OpportunityCreationSetting> OpportunityCreationSetting;
        global List<String> ExcludedProfiles;
        global List<String> ExcludedProductTypes;
        global List<String> AllowedEnterpriseProfiles;
        global String URL;
    } 
    
    /**************************************************************************************************************************************************
    Author              : Priyanka Ambre
    Description         : This is a Class to hold OpportunityCreationSetting Details.
    Created Date        : - 
    ***************************************************************************************************************************************************/
    global class OpportunityCreationSetting {
        global String RecordType;
        global String CompanySize;
    } 
    
    /**************************************************************************************************************************************************
    Author              : Priyanka Ambre
    Description         : This is a Class to hold ValidResult Details.
    Created Date        : - 
    ***************************************************************************************************************************************************/
    global class ValidResultWithOpp{
        global Boolean isValid {get;set;}
        global Boolean isBillingAccountError {get;set;}
        global Boolean isValidOwner {get;set;}
        global string errorMsg {get;set;}
        global Opportunity objOpportunity {get;set;}
        global List<String> opportunityBuildings {get;set;}
        global string settingData {get;set;}
    }
}