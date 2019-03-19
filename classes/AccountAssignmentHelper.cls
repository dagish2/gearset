/************************************************************************************************************************************
Author 		: 	Pragalbha Mahajan
Description : 	This class is an helper class related to account assignment.
History		:
----------------------------------------------------------------------------------------------------------------------------------
VERSION		DATE				AUTHOR					DETAIL
1			30 Jan 2019	        Pragalbha Mahajan     	Initial Development	 
**************************************************************************************************************************************/

public class AccountAssignmentHelper {
    public class AccountAssignmentHelperException extends Exception{}
    
    public static Map<String, Schema.SObjectType> globalDescribe;
    public static Set<String> setReferralSources = new Set<String>();
    public static Map<String, Set<String>> mapAccountMergeSetting = new Map<String, Set<String>>();
    public static List<Map<String,String>> lstRecordTypeWithCompanySize = new List<Map<String,String>>();
    public static Map<String, String> mapAPIUserSetting = new Map<String, String>();
    
    /************************************************************************************************************************************
        Author 				: 	Pragalbha Mahajan
        Description 		: 	This method is used to get getGlobalDescribe.
        Issue No.			:	ST-3391
        Created Date		:	30 Jan 2019
    **************************************************************************************************************************************/
    public static Boolean checkReferralLeadSource(String leadSource){
        if(String.isBlank(leadSource)){
            return true;
        }
        if(setReferralSources.isEmpty()){
            Setting__c referralSourcesSetting = Settings.get('ReferralsourcesSettings');
            if(referralSourcesSetting != null && String.isNotBlank(referralSourcesSetting.Data__c)){
                setReferralSources = (Set<String>)(JSON.deserialize(referralSourcesSetting.Data__c.toLowerCase(), Set<String>.class));
            }
        }
        return !setReferralSources.contains(leadSource.toLowerCase());
    }
    
    /************************************************************************************************************************************
        Author 				: 	Pragalbha Mahajan
        Description 		: 	This method is used to get the account and opportunity fields used in assignment
        Issue No.			:	ST-3391
        Created Date		:	30 Jan 2019
    **************************************************************************************************************************************/
    public static Map<String, List<String>> getAllFieldsForAssignment(){
        Map<String, List<String>> mapFields = new Map<String, List<String>>();
        List<String> lstAccountFields = new List<String>();
        Set<String> setAccountFields = new Set<String>();
        setAccountFields.add('Id');
        setAccountFields.add('OwnerId');
        setAccountFields.add('Owner.Name');
        setAccountFields.add('Owner.Profile.Name');
        setAccountFields.add('RecordTypeId');
        setAccountFields.add('RecordType.Name');
        setAccountFields.add('Lead_Source__c');
        setAccountFields.add('Unomy_Company_Size__c');
        setAccountFields.add('Number_of_Full_Time_Employees__c');
        setAccountFields.add('Account_Market__c');
        setAccountFields.add('Account_Market__r.TerritoryID__c');
        setAccountFields.add('Account_Market__r.TerritoryID__r.RegionID__c');
        setAccountFields.add('Update_HQ_Market_Status__c');
        lstAccountFields.addAll(setAccountFields);
        mapFields.put('Account', lstAccountFields);
        
        List<String> lstOpportunityFields = new List<String>();
        Set<String> setOpportunityFields = new Set<String>();
        setOpportunityFields.add('Id');
        setOpportunityFields.add('OwnerId');
        setOpportunityFields.add('StageName');
        setOpportunityFields.add('Owner_Auto_Assign__c');
        setOpportunityFields.add('Building__c');
        setOpportunityFields.add('Quantity__c');
        setOpportunityFields.add('Interested_in_Number_of_Desks__c');
        setOpportunityFields.add('Requirement_Quantity__c');
        setOpportunityFields.add('Type__c');
        lstOpportunityFields.addAll(setOpportunityFields);
        mapFields.put('Opportunity', lstOpportunityFields);
        return mapFields;
    }
    
    
    /************************************************************************************************************************************
        Author 				: 	Pragalbha Mahajan
        Description 		: 	This method is used to get getGlobalDescribe.
        Issue No.			:	ST-3391
        Created Date		:	30 Jan 2019
    **************************************************************************************************************************************/
    public static Set<String> getAllowedRecordTypes(String metadataMemberKey){
        String metadataMember = metadataMemberKey.toLowerCase();
        Map<String, Set<String>> mapAccountSettingMetadata;
        MetadataSetting__mdt accountAssignmentSettingMetadata = Settings.getMetadataSettingByDevName('AccountAssignmentSetting');
        if(accountAssignmentSettingMetadata != NULL && String.isNotBlank(accountAssignmentSettingMetadata.Data__c)){
            mapAccountSettingMetadata = (Map<String, Set<String>>)JSON.deserialize(accountAssignmentSettingMetadata.Data__c.toLowerCase(), Map<String, Set<String>>.class);
        }
        debug.log('mapAccountSettingMetadata: '+mapAccountSettingMetadata);
        if(metadataMember.equalsIgnoreCase('allowrecordtypes') && (mapAccountSettingMetadata.get(metadataMember) == NULL || mapAccountSettingMetadata.get(metadataMember).isEmpty())){
            mapAccountSettingMetadata.put('allowrecordtypes', new Set<String>{'Enterprise Solutions', 'Mid Market', 'Consumer'});
        }else if(metadataMember.equalsIgnoreCase('restricthqstatus') && (mapAccountSettingMetadata.get(metadataMember) == NULL || mapAccountSettingMetadata.get(metadataMember).isEmpty())){
            mapAccountSettingMetadata.put('restricthqstatus', new Set<String>{'retry round 1','retry round 2'});
        }
        return mapAccountSettingMetadata.get(metadataMember.toLowerCase());
    }
    
    /************************************************************************************************************************************
        Author 				: 	Pragalbha Mahajan
        Description 		: 	This method is used to get getGlobalDescribe.
        Issue No.			:	ST-3391
        Created Date		:	30 Jan 2019
    **************************************************************************************************************************************/
    public static Map<String, Schema.SObjectType> getGlobalDescribe(){
        if(globalDescribe == null){
            globalDescribe = Schema.getGlobalDescribe();
        }
        return globalDescribe;
    }
    
    /************************************************************************************************************************************
        Author 				: 	Pragalbha Mahajan
        Description 		: 	This method is used to get account from map.
        Issue No.			:	ST-3391
        Created Date		:	30 Jan 2019
    **************************************************************************************************************************************/
    public static Account getAccountFromMap(Id AccountId){
        if(!AccountAssignmentController.mapAccountsToUpdate.containsKey(AccountId)){
            AccountAssignmentController.mapAccountsToUpdate.put(AccountId, new Account(Id = AccountId));
        }
        return AccountAssignmentController.mapAccountsToUpdate.get(AccountId);
    }
    
    /************************************************************************************************************************************
        Author 				: 	Pragalbha Mahajan
        Description 		: 	This method is used to get account from map.
        Issue No.			:	ST-3391
        Created Date		:	30 Jan 2019
    **************************************************************************************************************************************/
    public static Id getUpdatedAccountRecordTypeId(Account objAccount){ //to be removed
        Id recordTypeId = objAccount.RecordTypeId;
        if(AccountAssignmentController.mapAccountsToUpdate.containsKey(objAccount.Id) && String.isNotBlank(AccountAssignmentController.mapAccountsToUpdate.get(objAccount.Id).recordTypeId)){
            recordTypeId = AccountAssignmentController.mapAccountsToUpdate.get(objAccount.Id).recordTypeId;
        }
        return recordTypeId;
    }
    
    /************************************************************************************************************************************
        Author 				: 	Pragalbha Mahajan
        Description 		: 	This method is used to get record type name from record type Id.
        Issue No.			:	ST-3391
        Created Date		:	30 Jan 2019
    **************************************************************************************************************************************/
    public static String getRecordTypeNameById(String objectName, Id recordTypeId){
        getGlobalDescribe();
        if(String.isNotBlank(objectName) && String.isNotBlank(recordTypeId)){
           return globalDescribe.get(objectName).getDescribe().getRecordTypeInfosById().get(recordTypeId).getName(); 
        }
        return NULL;
    }
    
    /************************************************************************************************************************************
        Author 				: 	Pragalbha Mahajan
        Description 		: 	This method is used to check change account owner conditions.
        Issue No.			:	ST-3391
        Created Date		:	30 Jan 2019
    **************************************************************************************************************************************/
    public static boolean checkValidUserForAssignment(Id userId){
        if(String.isNotBlank(userId) && (!Settings.getUserActive(userId) || isApiUser('UserId', userId) || isValidProfileAndUserForAssignment(userId))){
            return true;
        }
        return false;
    }
    /************************************************************************************************************************************
        Author 				: 	Pragalbha Mahajan
        Description 		: 	This method is used to get check whether user is valid for assignment or not.
        Issue No.			:	ST-3391
        Created Date		:	30 Jan 2019
    **************************************************************************************************************************************/
    public static boolean isValidProfileAndUserForAssignment(String userId){
        if(String.isNotBlank(userId)){
            if(!Settings.getUserActive(userId)){
                return true;
            }
            if(mapAccountMergeSetting == NULL || mapAccountMergeSetting.isEmpty()){
                Setting__c accountMergeSetting = Settings.get('AccountMergeSettings');
                if(accountMergeSetting != NULL && String.isNotBlank(accountMergeSetting.Data__c)){
                    mapAccountMergeSetting = (Map<String,Set<String>>)JSON.deserialize(Settings.get('AccountMergeSettings').Data__c.toLowerCase(), Map<String,Set<String>>.class);
                }
            }
            User objUser = settings.getUserById(userId);
            if(mapAccountMergeSetting != NULL && ((mapAccountMergeSetting.get('owner') != NULL && (mapAccountMergeSetting.get('owner').contains(userId.toLowerCase()) || mapAccountMergeSetting.get('owner').contains(userId.toLowerCase().substring(0,15)))) || (mapAccountMergeSetting.get('profiles') != NULL && mapAccountMergeSetting.get('profiles').contains(objUser.Profile.Name.toLowerCase())))){
                return true;
            }
        }
        return false;
    }
    
    /************************************************************************************************************************************
        Author 				: 	Pragalbha Mahajan
        Description 		: 	This method is used to check user is API user or not..
        Issue No.			:	ST-3391
        Created Date		:	30 Jan 2019
    **************************************************************************************************************************************/
    public static boolean isApiUser(string dataType, Id userId){
        if(getApiUserId(dataType) == userId){
            return true;
        }
        return false;
    }
    
    /************************************************************************************************************************************
        Author 				: 	Pragalbha Mahajan
        Description 		: 	This method is used to check user is API user or not..
        Issue No.			:	ST-3391
        Created Date		:	30 Jan 2019
    **************************************************************************************************************************************/
    public static Id getApiUserId(string dataType){
        if(mapAPIUserSetting == NULL || mapAPIUserSetting.isEmpty()){
            Setting__c apiUserSetting = Settings.get('APIUserContactInfo');
            if(apiUserSetting != null && String.isNotBlank(apiUserSetting.Data__c)){
                mapAPIUserSetting = (Map<String, String>)JSON.deserialize(apiUserSetting.Data__c, Map<String, String>.class);
            }
        }        
        if(mapAPIUserSetting != null && mapAPIUserSetting.containsKey(dataType)){
            return mapAPIUserSetting.get(dataType);
        }
        return NULL;
    }
    /************************************************************************************************************************************
    Author 				: 	Pragalbha Mahajan
    Description 		: 	This method is used for record type change according to ROE assignment.
    Issue No.			:	ST-3391
	Created Date		:	29 Jan 2019
    **************************************************************************************************************************************/
    public static String getRecordTypeIdFromCompanySize(Account objAccount){
        Integer companySize = getCompanySizeFromAccount(objAccount);
        String recordTypeId = getRecordTypeOfAccountUsingCompanySize((companySize != null && companySize > 0) ? companySize : 1); 
        return recordTypeId;
    }
    
    
    /************************************************************************************************************************************
        Author 				: 	Pragalbha Mahajan
        Description 		: 	This method is used to get company size from account.
        Issue No.			:	ST-3391
        Created Date		:	30 Jan 2019
    **************************************************************************************************************************************/
    public static Integer getCompanySizeFromAccount(Account objAccount){
        Integer companySize;                        
        if(String.isNotBlank(objAccount.Unomy_Company_Size__c)){
            companySize = getLowerSize(String.valueOf(objAccount.Unomy_Company_Size__c));
        }else if(String.isNotBlank(String.valueOf(objAccount.Number_of_Full_Time_Employees__c))){
            companySize = Integer.valueOf(objAccount.Number_of_Full_Time_Employees__c);
        }
        return companySize;
    }
    
    /************************************************************************************************************************************
        Author 				: 	Pragalbha Mahajan
        Description 		: 	This method is used to get record type of account using company size.
        Issue No.			:	ST-3391
        Created Date		:	30 Jan 2019
    **************************************************************************************************************************************/
    public static Id getRecordTypeOfAccountUsingCompanySize(Integer CompanySize){
        if(lstRecordTypeWithCompanySize == NULL || lstRecordTypeWithCompanySize.isEmpty()){
            Setting__c accountRecordTypeSetting = Settings.get('AccountRecordTypeSettings');
            if(accountRecordTypeSetting != NUll && String.isNotBlank(accountRecordTypeSetting.Data__c)){
                lstRecordTypeWithCompanySize = (List<Map<String,String>>)JSON.deserialize(Settings.get('AccountRecordTypeSettings').Data__c, List<Map<String,String>>.class);
            }
        }
        String recordTypeId;
        if(lstRecordTypeWithCompanySize != NULL){
            for(Map<String,String> mapRecordType : lstRecordTypeWithCompanySize){
                if(companySize >= getLowerSize(mapRecordType.get('Size'))){
                    recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(mapRecordType.get('RecordType')).getRecordTypeId();
                }
            }
        }
        return String.isNotBlank(recordTypeId) ? recordTypeId : Schema.SObjectType.Account.getRecordTypeInfosByName().get('Consumer').getRecordTypeId();
    }
    
    /************************************************************************************************************************************
        Author 				: 	Pragalbha Mahajan
        Description 		: 	This method is used to get lower size from range.
        Issue No.			:	ST-3391
        Created Date		:	30 Jan 2019
    **************************************************************************************************************************************/
    public static Integer getLowerSize(String size){
        try{
            Integer lowerSize;
            size = size.replaceAll('(,|desks|desk|<)','');
            size = size.deleteWhitespace();
            size = size.split('(-|\\+)')[0];
            lowerSize = Integer.valueOf(size);
            return lowerSize;    
        }catch(Exception pEx){
            ApexDebugLog.logException(pEx,size, 'AccountAssignmentHelper', 'getLowerSize');
            return NULL;
        }
    }
}