/************************************************************************************************************************************
Author 		: 	Pragalbha Mahajan
Description : 	This class contains the business logic of ROE Account and Opportunity owner assignment.
History		:
----------------------------------------------------------------------------------------------------------------------------------
VERSION		DATE				AUTHOR					DETAIL
1			23 Jan 2019	        Pragalbha Mahajan     	Initial Development	 
**************************************************************************************************************************************/

public without sharing class AccountAssignmentController {
    
    /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method will update account owner based on Deal type When a user gets deactivate re run assignment for Accounts.
        Issue No.           :   ST-1455,ST-1755,ST-3391
        Last Modified Date  :   08 December 2017
        Last Modified By    :   Pragalbha Mahajan
    **************************************************************************************************************************************/    
    public static Map<Id, Account> mapAccountsToUpdate = new Map<Id, Account>();
    public static void setOwnerByRoeAssignment(List<sObject> lstNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems){
        if(TriggerSettings.mappedField.Opportunity_SetOwnerByDealType){
            Set<Id> setAccountIds = new Set<Id>();
            for(Opportunity opp:(List<Opportunity>)lstNewItems){
                if(String.isNotBlank(opp.AccountId)){
                    setAccountIds.add(opp.AccountId);
                }
            }
            if(!setAccountIds.isEmpty() && !lstNewItems.isEmpty()){
                if(mapNewItems == null || mapNewItems.isEmpty()){//before Insert
                    Map<Id,Account> mapAccounts = new Map<Id,Account>([Select Id, OwnerId, Owner.Name, Owner.Profile.Name, RecordTypeId, RecordType.Name, Lead_Source__c, Unomy_Company_Size__c, Number_of_Full_Time_Employees__c, Account_Market__c, Account_Market__r.TerritoryID__c, Account_Market__r.TerritoryID__r.RegionID__c, Update_HQ_Market_Status__c From Account Where Id IN: setAccountIds]);
                    Account objAccount; 
                    Id ownerId;
                    for(Opportunity objOpportunity : (List<Opportunity>)lstNewItems){
                        objAccount = mapAccounts.get(objOpportunity.AccountId);
                        if(objAccount != null && AccountAssignmentHelper.checkReferralLeadSource(objAccount.Lead_Source__c)){
                            ownerId =  roeAccountRecordTypeForNewOpportunity(objAccount, objOpportunity);
                            Debug.log('setOwnerByRoeAssignment OwnerId==>'+OwnerId);
                            if(String.isNotBlank(OwnerId)){
                                objOpportunity.OwnerId = OwnerId;
                            }
                        }
                    }
                    Debug.log('Before setOwnerByRoeAssignment mapAccountsToUpdate==>'+mapAccountsToUpdate);
                }else if(mapNewItems != null && !mapNewItems.isEmpty()){//After Insert
                    Debug.log('setOwnerByRoeAssignment mapAccountsToUpdate==>'+mapAccountsToUpdate);
                    AccountQueueServices.updateAccountQueues();
                    if(!mapAccountsToUpdate.isEmpty()){
                        Database.update(mapAccountsToUpdate.values());
                        mapAccountsToUpdate = new Map<Id, Account>();
                    }
                }
            }  
        }
    }
    
    /************************************************************************************************************************************
    Author 				: 	Pragalbha Mahajan
    Description 		: 	This method is used route to owner assignment for new opportunity.
    Issue No.			:	ST-3391
	Created Date		:	23 Jan 2019
    **************************************************************************************************************************************/ 
    public static Id roeAccountRecordTypeForNewOpportunity(Account objAccount, Opportunity objOpportunity){
        Id ownerId;
        Set<String> setAllowedRecordTypes = AccountAssignmentHelper.getAllowedRecordTypes('AllowRecordTypes');
        Map<String,RecordTypeInfo> recordTypes = AccountAssignmentHelper.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName();
        if(recordTypes.containsKey(objAccount.RecordType.Name) && setAllowedRecordTypes.contains(objAccount.RecordType.Name.toLowerCase())){
            ownerId = roeAssignmentForNewOpportunity(objAccount, objOpportunity, objAccount.RecordType.Name);
        }
        return ownerId;
    }
    
    /************************************************************************************************************************************
    Author 				: 	Pragalbha Mahajan
    Description 		: 	This method is used for routing new opportunity for assignment.
    Issue No.			:	ST-3391
	Created Date		:	23 Jan 2019
    **************************************************************************************************************************************/
    public static Id roeAssignmentForNewOpportunity(Account relatedAccount, Opportunity objOpportunity, String recordTypeName){
        Debug.log('roeAssignmentForNewOpportunity recordTypeName==>'+recordTypeName);
        Id ownerId;
        if(AccountAssignmentHelper.isValidProfileAndUserForAssignment(UserInfo.getUserId()) || AccountAssignmentHelper.checkValidUserForAssignment(relatedAccount.OwnerId)){
            ownerId = (recordTypeName == 'Enterprise Solutions') ? roeAssignmentForEnterpriseAndMidMarket(relatedAccount, objOpportunity, recordTypeName) : roeAssignmentForMLB(relatedAccount, objOpportunity, recordTypeName);
        }
        if(!AccountAssignmentHelper.isValidProfileAndUserForAssignment(UserInfo.getUserId())){
            ownerId = UserInfo.getUserId();
        }
        return ownerId;
    }
    
    /************************************************************************************************************************************
    Author 				: 	Pragalbha Mahajan
    Description 		: 	This method is used for owner assignment of mid market and consumer opportunity.
    Issue No.			:	ST-3391
	Created Date		:	23 Jan 2019
    **************************************************************************************************************************************/
    public static Id roeAssignmentForEnterpriseAndMidMarket(Account relatedAccount, Opportunity objOpportunity, String recordTypeName){
        Id ownerId;
        if(recordTypeName.equalsIgnoreCase('Mid Market') && (relatedAccount.Number_of_Full_Time_Employees__c == null || (relatedAccount.Number_of_Full_Time_Employees__c != null && relatedAccount.Number_of_Full_Time_Employees__c < 50))){
            recordTypeName = 'Consumer';
        }
        if(AccountAssignmentHelper.checkValidUserForAssignment(relatedAccount.OwnerId)){
            ownerId = (recordTypeName.equalsIgnoreCase('Enterprise Solutions')) ? getOwnerByDesksInterested(relatedAccount, objOpportunity, 'EnterpriseFTE') : (String.isNotBlank(recordTypeName) && recordTypeName.equalsIgnoreCase('Mid Market')) ? getOwnerWithAccountManagerPriority(relatedAccount, objOpportunity, recordTypeName) : getOwnerByDesksInterested(relatedAccount, objOpportunity, 'ConsumerFTE');
            Account objAccount = AccountAssignmentHelper.getAccountFromMap(relatedAccount.Id);
            if(ownerId != null && String.isNotBlank(ownerId)){
                objAccount.OwnerId = ownerId;
            }
        }else{
            ownerId = relatedAccount.OwnerId;
        }
        if(!objOpportunity.owner_Auto_Assign__c && AccountAssignmentHelper.isApiUser('UserId', UserInfo.getUserId())){
            ownerId = NULL;
        }
        Debug.log('roeAssignmentForEnterpriseAndMidMarket==>'+ownerId);
        return ownerId;
    }
    
    /************************************************************************************************************************************
    Author 				: 	Pragalbha Mahajan
    Description 		: 	This method is used for owner assignment of MLB flow opportunity.
    Issue No.			:	ST-3391
	Created Date		:	29 Jan 2019
    **************************************************************************************************************************************/
    public static Id roeAssignmentForMLB(Account relatedAccount, Opportunity objOpportunity, String existingRecordTypeName){
        Id ownerId;
        Boolean isRecordTypeChange = false;
        String recordTypeId = AccountAssignmentHelper.getRecordTypeIdFromCompanySize(relatedAccount);
        debug.log('recordTypeId: '+recordTypeId);
        String recordTypeNameAfterUpgrade;
        if(String.isNotBlank(recordTypeId)){
            recordTypeNameAfterUpgrade = AccountAssignmentHelper.getRecordTypeNameById('Account', recordTypeId);
        }
        Debug.log('roeAssignmentForMLB recordTypeNameAfterUpgrade==>'+recordTypeNameAfterUpgrade);
        Debug.log('existingRecordTypeName==>'+existingRecordTypeName);
        if(String.isNotBlank(recordTypeNameAfterUpgrade) && recordTypeNameAfterUpgrade.equalsIgnoreCase('Enterprise Solutions')){
            ownerId = roeAssignmentForEnterpriseAndMidMarket(relatedAccount, objOpportunity, 'Enterprise Solutions');
            isRecordTypeChange = true;
        }else if((String.isNotBlank(recordTypeNameAfterUpgrade) && recordTypeNameAfterUpgrade.equalsIgnoreCase('Mid Market')) || existingRecordTypeName.equalsIgnoreCase('Mid Market')){
            ownerId = roeAssignmentForEnterpriseAndMidMarket(relatedAccount, objOpportunity, 'Mid Market');
            if(!existingRecordTypeName.equalsIgnoreCase('Mid Market')){
                isRecordTypeChange = true;
            }
        }else{
            ownerId = roeAssignmentForEnterpriseAndMidMarket(relatedAccount, objOpportunity, 'Consumer');
        }
        debug.log('isRecordTypeChange: '+isRecordTypeChange);
        if(isRecordTypeChange && String.isNotBlank(recordTypeNameAfterUpgrade)){
            Account objAccount = AccountAssignmentHelper.getAccountFromMap(relatedAccount.Id);
            objAccount.RecordTypeId = recordTypeId;
        }
        return OwnerId;
    }
    
    /************************************************************************************************************************************
    Author 				: 	Pragalbha Mahajan
    Description 		: 	This method is used to get owner by desk interested.
    Issue No.			:	ST-3391
	Created Date		:	29 Jan 2019
    **************************************************************************************************************************************/
    public static Id getOwnerByDesksInterested(Account objAccount, Opportunity objOpportunity, String FTEType){
        Integer desksInterested = (objOpportunity.Interested_in_Number_of_Desks__c != null && objOpportunity.Interested_in_Number_of_Desks__c > 0) ? Integer.valueOf(objOpportunity.Interested_in_Number_of_Desks__c) : (FTEType.equals('EnterpriseFTE') && objOpportunity.Requirement_Quantity__c != null && objOpportunity.Type__c != null && objOpportunity.Type__c.equals('WeWork')) ? Integer.valueOf(objOpportunity.Requirement_Quantity__c) : 1;
        List<String> lstRecordTypesToSearchInQueue = getRecordTypesByDesksInterested(desksInterested, FTEType);
        return getAccountOwnerIdFromBuildingId(objOpportunity, lstRecordTypesToSearchInQueue);
    }
    
    /************************************************************************************************************************************
    Author 				: 	Pragalbha Mahajan
    Description 		: 	This method is used to get owner by account manager priority.
    Issue No.			:	ST-3391
	Created Date		:	29 Jan 2019
    **************************************************************************************************************************************/
    public static Id getOwnerWithAccountManagerPriority(Account objAccount, Opportunity objOpportunity, String recordTypeName){
        Id ownerId;
        Id marketId;
        Set<String> setHqMarketStatus = AccountAssignmentHelper.getAllowedRecordTypes('restricthqstatus');
        List<String> lstRecordTypes = new List<String>{recordTypeName};
        if(String.isNotBlank(objOpportunity.Building__c)){
            Building__c objBuilding = settings.getBuildingById(objOpportunity.Building__c);
            marketId = String.isNotBlank(objBuilding.Market__c) ? objBuilding.Market__c : NULL ;
        }
        if(String.isNotBlank(objAccount.Account_Market__c) && String.isNotBlank(marketId) && objAccount.Account_Market__c == marketId){
            ownerId = AccountQueueServices.getQueueOwnerByMarketTerritoryOrRegion(new List<String>{recordTypeName}, objAccount.Account_Market__c, recordTypeName);
        }else if(!(System.isBatch() || System.isFuture()) && String.isBlank(objAccount.Account_Market__c) && !setHqMarketStatus.contains(objAccount.Update_HQ_Market_Status__c) && AccountAssignmentHelper.isValidProfileAndUserForAssignment(objOpportunity.OwnerId)){
            Account objAcc = AccountAssignmentHelper.getAccountFromMap(objAccount.Id);
            objAcc.Processing_Stage__c = 'On Hold';
            objOpportunity.Assignment_Status__c = 'On Hold';
        }else if(String.isNotBlank(objAccount.Account_Market__c) && String.isNotBlank(marketId) && objAccount.Account_Market__c != marketId){
            ownerId = getOwnerByDesksInterested(objAccount, objOpportunity, 'MidMarketFTE');
        }else{
            ownerId = getAccountOwnerIdFromBuildingId(objOpportunity, new List<String>{recordTypeName});
        }
        return ownerId;
    }
    
    /************************************************************************************************************************************
    Author 				: 	Pragalbha Mahajan
    Description 		: 	This method is used to get record types by desk interested.
    Issue No.			:	ST-3391
    Created Date		:	29 Jan 2019
    **************************************************************************************************************************************/
    public static List<String> getRecordTypesByDesksInterested(Integer numberOfDesks, String FTEType){
        Debug.log('FTEType==>'+FTEType);
        Setting__c accountAssignmentByDesksSetting = Settings.get('AccountAssignmentByDesks');
        Map<String, List<Map<String, String>>> mapAccountAssignmentByDesksSetting = (Map<String, List<Map<String, String>>>) JSON.deserialize(accountAssignmentByDesksSetting.Data__c, Map<String, List<Map<String, String>>>.class);
        List<Map<String, String>> lstDesksRange = mapAccountAssignmentByDesksSetting.get(FTEType);
        List<String> lstRecordTypesForAssignments = new List<String>();
        Debug.log('numberOfDesks==>'+numberOfDesks);
        Integer lowerDesksRangeNumber;
        for(Map<String,String> desksRange : lstDesksRange){
            lowerDesksRangeNumber = AccountAssignmentHelper.getLowerSize(desksRange.get('Size'));
            if(numberOfDesks >= lowerDesksRangeNumber){
               lstRecordTypesForAssignments = desksRange.get('RecordType').split('\\,');
            }
        }
        Debug.log('getRecordTypesByDesksInterested lstRecordTypesForAssignments==>'+lstRecordTypesForAssignments);
        return lstRecordTypesForAssignments;
    }
    
    /************************************************************************************************************************************
    Author 				: 	Pragalbha Mahajan
    Description 		: 	This method is used to get account owner from building Id.
    Issue No.			:	ST-3391
	Created Date		:	23 Jan 2019
    **************************************************************************************************************************************/
    public static Id getAccountOwnerIdFromBuildingId(Opportunity objOpportunity, List<String> lstRecordTypesOrFields){
        Id ownerId; 
        debug.log('getAccountOwnerIdFromBuildingId lstRecordTypesOrFields==>'+lstRecordTypesOrFields);
        if(String.isNotBlank(objOpportunity.Building__c) && lstRecordTypesOrFields.size() > 0){
            Building__c objBuilding = settings.getBuildingById(objOpportunity.Building__c);
            debug.log('objBuilding: '+objBuilding);
            
            Set<String> setRecordTypesForAssignment = AccountAssignmentHelper.getAllowedRecordTypes('AllowRecordTypes');
            if(setRecordTypesForAssignment.contains(lstRecordTypesOrFields[0].toLowerCase())){
                Id buildingId = String.isNotBlank((String)objBuilding.get('Market__c')) ? Id.valueOf((String)objBuilding.get('Market__c')) : NULL;
                ownerId = AccountQueueServices.getQueueOwnerByMarketTerritoryOrRegion(lstRecordTypesOrFields, buildingId, String.valueOf(lstRecordTypesOrFields).toLowerCase().contains('enterprise solutions') ? 'Enterprise Solutions' : 'Mid Market');
            }else{
                Id fieldValue = (String)getRelationShipValue(lstRecordTypesOrFields[0], objBuilding);
                Debug.log('getAccountOwnerIdFromBuildingId=='+fieldValue);
                ownerId = (fieldValue != null && settings.getUserActive(fieldValue)) ? fieldValue : AccountAssignmentHelper.getApiUserId('UserId');
            }
        }
        return ownerId;
    }
    
    /************************************************************************************************************************************
    Author 				: 	Pragalbha Mahajan
    Description 		: 	This method is used to get relationship value.
    Issue No.			:	ST-3391
	Created Date		:	29 Jan 2019
    **************************************************************************************************************************************/
    public static Object getRelationShipValue(String fieldApiName, sObject objSobject){
        debug.log('objSobject: '+objSobject);
        if(objSobject != null){
            List<String> objRelList = fieldApiName.split('\\.');
            if(objRelList.size() > 0){
                for(Integer index = 0; index < (objRelList.size() - 1); index++ ) {
                    objSobject = objSobject.getSObject(objRelList[index]);  
                }
                fieldApiName = objRelList[objRelList.size() - 1];
            }
            if(objSobject != null){
                return objSobject.get(fieldApiName);  
            }
        }
        return null;       
    }
}