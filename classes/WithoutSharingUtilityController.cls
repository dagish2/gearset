/************************************************************************************************************************************
    Author      :   --- 
    Description :   This class contain methods to run buisness logic in system mode.

    History:
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1           22 January 2016     ---                     Initial Developement
**************************************************************************************************************************************/
public without sharing class WithoutSharingUtilityController {
    /************************************************************************************************************************************
        Author              :   ---
        Description         :   This wrapper class is used to set id and userName.
        Created Date        :   11 June 2017
    **************************************************************************************************************************************/
    public class AssignUserToInactiveContacts{
        public String Id {get; set;}    
        public String userName {get; set;}
    }
    static Setting__c assignUserToInactiveContactsObject = Settings.get('Assign Contacts to Active User');
    static Setting__c referralSourcesSetting = Settings.get('ReferralsourcesSettings');
    static Setting__c apiUserContactInfo = Settings.get('APIUserContactInfo');
    Static Set<String> setReferralSources = new Set<String>();
    public static AssignUserToInactiveContacts apiUser;
    /************************************************************************************************************************************
    Author 				: 	Pragalbha Mahajan
    Description 		: 	This static method is used get various settings and deserialize it in map.
    Issue No.			:	ST-3293
	Created Date		:	23 Jan 2019
    **************************************************************************************************************************************/ 
    static{
        if(assignUserToInactiveContactsObject != null) {    
            apiUser = (AssignUserToInactiveContacts)JSON.deserialize(assignUserToInactiveContactsObject.Data__c, AssignUserToInactiveContacts.class);
        }        
        if(referralSourcesSetting != null){
            setReferralSources = (Set<String>)(JSON.deserialize(referralSourcesSetting.Data__c.toLowerCase(), Set<String>.class));
        }
    }
    
     /************************************************************************************************************************************
        Author              :   ---
        Description         :   This Method is called by Batch when user gets deactivated.
                                so all accounts whose owner is deactivated user will be changes as per account assignment.
        Created Date        :   11 June 2017
    **************************************************************************************************************************************/
    public static List<Account> setAccountOwnerByDealType(Set<Id> setAccountIds){  
        List<Account> accountsToUpdate = new List<Account>();
        if(setAccountIds != null && setAccountIds.size() > 0){
            Id OwnerId;
            Map<String, List<String>> mapAllFieldsForAssignment = AccountAssignmentHelper.getAllFieldsForAssignment();
            List<String> lstAccountFields = mapAllFieldsForAssignment.get('Account');
            List<String> lstOpportunityFields = mapAllFieldsForAssignment.get('Opportunity');
            for(Account objAccount : (List<Account>) Database.query('SELECT '+ String.join(lstAccountFields, ',')+', (SELECT '+String.join(lstOpportunityFields, ',')+' FROM Opportunities WHERE StageName != \'Closed Lost\' Order BY LastModifiedDate DESC) FROM Account WHERE Id IN: setAccountIds')){
                for(Opportunity objOpportunity : objAccount.Opportunities){
                    OwnerId = AccountAssignmentController.roeAccountRecordTypeForNewOpportunity(objAccount, objOpportunity);
                    if(String.isNotBlank(ownerId) && Settings.getUserActive(ownerId)){ 
                        accountsToUpdate.add(new Account(Id = objAccount.Id, OwnerId = ownerId, User_Deactivation_Updated_On__c = Date.today(), Reassignment_On_User_Deactivation__c = true));                   
                    }else{
                        accountsToUpdate.add(new Account(Id=objAccount.Id, OwnerId = apiUser.Id));     
                    }
                    break;
                }
            }
        }
        AccountQueueServices.updateAccountQueues();
        if(accountsToUpdate.size() > 0){
            return accountsToUpdate; 
        }
        return null;
    }
    
    /************************************************************************************************************************************
        Author              :   ---
        Description         :   This method is used to update record type of account based on company size.
        Created Date        :   11 June 2017
    **************************************************************************************************************************************/
    public static void updateRecordType(List<sObject> lstNewItems, Map<Id,sObject> mapNewItems, List<sObject> lstOldItems, Map<Id,sObject> mapOldItems){
        List<Billing_Account__c> updateBillAccount;
        List<Id> lstAcccId;
        Boolean allowFire = false; 
        if(Trigger.isUpdate){
            for(Account acc : (List<Account>)lstNewItems){
                if(acc.Number_of_Full_Time_Employees__c != mapOldItems.get(acc.Id).get('Number_of_Full_Time_Employees__c') || acc.Company_Size__c != mapOldItems.get(acc.Id).get('Company_Size__c') || acc.Unomy_Company_Size__c != mapOldItems.get(acc.Id).get('Unomy_Company_Size__c')){
                    allowFire = true;
                }
            }
        }else{
            allowFire = true;
        }
        if(allowFire){
            Map<Id,Account> mapAccounts;
            if(Trigger.isUpdate){
                mapAccounts = new Map<Id,Account>([SELECT Id, (SELECT Id FROM Contacts WHERE RecordTypeId =: Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Referral').getRecordTypeId()) FROM Account WHERE Id IN : mapNewItems.keyset()]);
            }
            for(Account acc : (List<Account>)lstNewItems){
                if(acc.RecordTypeId == null || (acc.RecordTypeId != null && Schema.SObjectType.Account.getRecordTypeInfosById().get(String.valueOf(acc.RecordTypeId)).getName() == 'Consumer')){                    
                    if(Trigger.isUpdate && mapAccounts.get(acc.Id).Contacts != null && mapAccounts.get(acc.Id).Contacts.size() > 0){
                        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Referral').getRecordTypeId();
                    }else if(acc.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get('Consumer').getRecordTypeId()){
                        Integer companySize = getCompanySizeFromAccount(acc);
                        String recordTypeId = getRecordTypeOfAccountUsingCompanySize(companySize);
                        if(recordTypeId != null){
                            acc.RecordTypeId = recordTypeId;
                        }
                    }
                }
            }
        }
    }
    
    public static Integer getCompanySizeFromAccount(Account objAccount){
        return AccountAssignmentHelper.getCompanySizeFromAccount(objAccount);
    }
    
    public static Id getRecordTypeOfAccountUsingCompanySize(Integer CompanySize){
        return AccountAssignmentHelper.getRecordTypeOfAccountUsingCompanySize(CompanySize);
    }
        
    /************************************************************************************************************************************
        Author 				: 	AjaySinh Chauhan
        Description 		: 	This method is used to change record type and owner of account,contact and opportunity childs of account.
		Created Date		:	11 June 2017
	**************************************************************************************************************************************/
    public static Map<Id, Map<String, List<sObject>>> changeChildsRecordTypeAndOwner(List<sObject> lstNewItems, Map<Id,sObject> mapOldItems){
        Map<Id, Map<String, List<sObject>>> mapAccountWithRecordToUpdate = new Map<Id, Map<string, List<sObject>>>();
        Map<Id, sObject> mapNewAccounts = new Map<Id, sObject>(); 
        mapNewAccounts.putAll(lstNewItems);
        if(Settings.get('AccountMergeSettings') != null && Settings.get('ManageToursOpportunityStages') != null){
            Set<Id> setAccountsWithRecordTypeOrOwnerChange = new Set<Id>();
            for(Account acc:(List<Account>)lstNewItems){
                if((String.isNotBlank(acc.RecordTypeId) && acc.RecordTypeId != mapOldItems.get(acc.Id).get('RecordTypeId')) || (String.isNotBlank(acc.OwnerId) && acc.OwnerId != mapOldItems.get(acc.Id).get('OwnerId'))){
                    setAccountsWithRecordTypeOrOwnerChange.add(acc.Id);
                }
            }
            if(setAccountsWithRecordTypeOrOwnerChange.size() > 0){
                Map<String,String> mapOrgAccount = new Map<String,String>();
                List<String> lstChilds = new List<String>{'Contacts','Opportunities','childAccounts'};
                List<Account> lstAccounts = [SELECT Id, Name, RecordTypeId,RecordType.Name, OwnerId, Account_Type__c, ParentId, (SELECT Id, Name, RecordTypeId, OwnerId FROM Contacts),(SELECT Id, Name, RecordTypeId, OwnerId FROM childAccounts),(SELECT Id, RecordTypeId, OwnerId, Owner.Profile.Name, StageName FROM Opportunities WHERE StageName ='Qualifying' OR StageName ='Selling' OR StageName ='Negotiating') FROM Account WHERE Id IN : setAccountsWithRecordTypeOrOwnerChange AND (Account_Type__c='' OR Account_Type__c='Org' OR Account_Type__c='Sales')];
                List<sObject> lstRecordsToUpadate;
                Map<String,List<sObject>> maprecordsToUpdate;
                for(Account objAccount : lstAccounts){
                    List<String> lstFieldsToUpdate;
                    if(mapNewAccounts.get(objAccount.Id).get('RecordTypeId') != NULL && mapNewAccounts.get(objAccount.Id).get('RecordTypeId') != mapOldItems.get(objAccount.Id).get('RecordTypeId')){
                        if(lstFieldsToUpdate==null){
                            lstFieldsToUpdate = new List<String>();
                        }
                        lstFieldsToUpdate.add('RecordTypeId');
                    }
                    if(mapNewAccounts.get(objAccount.Id).get('OwnerId') != NULL && mapNewAccounts.get(objAccount.Id).get('OwnerId') != mapOldItems.get(objAccount.Id).get('OwnerId')){
                        if(lstFieldsToUpdate==null){
                            lstFieldsToUpdate = new List<String>();
                        }
                        lstFieldsToUpdate.add('OwnerId');
                    } 
                    if(lstFieldsToUpdate != null && lstFieldsToUpdate.size() > 0){
                        for(String strChild : lstChilds){
                            if(objAccount.getsObjects(strChild) != null && objAccount.getsObjects(strChild).size() > 0){
                                List<sObject> lstTempRecordsToUpdate = generateRecordsToUpdate(mapNewAccounts.get(objAccount.Id), objAccount.getsObjects(strChild), lstFieldsToUpdate, mapOldItems);
                                if(lstTempRecordsToUpdate != null && lstTempRecordsToUpdate.size() > 0){
                                    if(mapAccountWithRecordToUpdate == NULL){
                                        mapAccountWithRecordToUpdate = new Map<Id, Map<string, List<sObject>>>();
                                    }
                                    if(!mapAccountWithRecordToUpdate.containsKey(objAccount.Id)){
                                        mapAccountWithRecordToUpdate.put(objAccount.Id, new Map<String, List<sObject>>());
                                    }
                                    if(!mapAccountWithRecordToUpdate.get(objAccount.Id).containsKey(strChild)){
                                        mapAccountWithRecordToUpdate.get(objAccount.Id).put(strChild, new List<sObject>());
                                    }
                                    mapAccountWithRecordToUpdate.get(objAccount.Id).get(strChild).addAll(lstTempRecordsToUpdate);
                                }
                            }
                        }
                    }
                    lstFieldsToUpdate = NULL;
                }
            }
        }
        return mapAccountWithRecordToUpdate;
    }    
   
    public static void updateChildRecords(){
        if(TrAccountByPassChildUpdate.lstchildObjectsToUpdate != null && TrAccountByPassChildUpdate.lstchildObjectsToUpdate.size() > 0){
            update TrAccountByPassChildUpdate.lstchildObjectsToUpdate;
        }
        TrAccountByPassChildUpdate.lstchildObjectsToUpdate = null;
    }

    /************************************************************************************************************************************
        Author              :   ---
        Description         :   This method is used to generate records(account,contact and opportunity) to update.
        Created Date        :   11 June 2017
    **************************************************************************************************************************************/
    static Set<String> setRestrictedStage;
    static Set<String> setAllowedRecordTypeForContact;
    public static List<sObject> generateRecordsToUpdate(sObject objMasterRecord, List<sObject> lstChildRecords,List<String> lstFields, Map<Id,sObject> mapOldItems){
        if(setRestrictedStage == NULL){
            Setting__c opportunityStageSetting = Settings.get('ManageToursOpportunityStages');
            if(opportunityStageSetting != NULL && String.isNotBlank(opportunityStageSetting.Data__c)){
                setRestrictedStage = (Set<String>)JSON.deserialize(opportunityStageSetting.Data__c.toLowerCase(), Set<String>.class);
            }
        }
        if(setAllowedRecordTypeForContact == NULL && lstChildRecords != null && lstChildRecords.size() > 0 && String.valueOf(lstChildRecords[0].get('Id')).startsWith('003')){
            Setting__c contactOwnerSetting = Settings.get('ContactOwnerShipSetting');
			setAllowedRecordTypeForContact = ((Map<String, Set<String>>)JSON.deserialize(contactOwnerSetting.Data__c.toLowerCase(), Map<String, Set<String>>.class)).get('allowedrecordtypes');
        }
        List<sObject> lstRecordsToUpdate;
        Map<String, Schema.SObjectType> mapGlobalDescribe = AccountAssignmentHelper.getGlobalDescribe();
        Map<Id, RecordTypeInfo> mapAccountRecordTypes = mapGlobalDescribe.get('Account').getDescribe().getRecordTypeInfosById();
        Map<String, RecordTypeInfo> mapContactRecordTypes = mapGlobalDescribe.get('Contact').getDescribe().getRecordTypeInfosByName();
        Map<String, RecordTypeInfo> mapOpportunityRecordTypes = mapGlobalDescribe.get('Opportunity').getDescribe().getRecordTypeInfosByName();
        Map<String, RecordTypeInfo> mapSalesAcocuntRecordTypes = mapGlobalDescribe.get('Account').getDescribe().getRecordTypeInfosByName();
        Boolean isValid;
        String objApiName;
        sObject objRecordToUpdate;
        Map<String, Object> mapFieldNameWithValue;
        for(sObject objChildRecord : lstChildRecords){
            objApiName = objChildRecord.getSObjectType().getDescribe().getName();
            mapFieldNameWithValue = new Map<String, Object>();
            for(String strField : lstFields){
                if(objMasterRecord.get(strField) != objChildRecord.get(strField) && strField == 'RecordTypeId'){
                    if(objApiName == 'Contact' && mapContactRecordTypes.containsKey(mapAccountRecordTypes.get((Id)objMasterRecord.get(strField)).getName())){
                        mapFieldNameWithValue.put(strField, mapContactRecordTypes.get(mapAccountRecordTypes.get((Id)objMasterRecord.get(strField)).getName()).getRecordTypeId());
                    }else if(objApiName == 'Opportunity' && mapOpportunityRecordTypes.containsKey(mapAccountRecordTypes.get((Id)objMasterRecord.get(strField)).getName())){
                        mapFieldNameWithValue.put(strField, mapOpportunityRecordTypes.get(mapAccountRecordTypes.get((Id)objMasterRecord.get(strField)).getName()).getRecordTypeId());
                    }else if(objApiName == 'Account' && mapSalesAcocuntRecordTypes.containsKey(mapAccountRecordTypes.get((Id)objMasterRecord.get(strField)).getName())){
                        mapFieldNameWithValue.put(strField, mapSalesAcocuntRecordTypes.get(mapAccountRecordTypes.get((Id)objMasterRecord.get(strField)).getName()).getRecordTypeId());
                    }
                }else if(objMasterRecord.get(strField) != objChildRecord.get(strField) && objApiName == 'Contact'){
                    isValid = false;
                    if(setAllowedRecordTypeForContact == NULL){
                        isValid = true;
                    }else if(objMasterRecord.get('RecordTypeId') != NULL && setAllowedRecordTypeForContact != NULL){
                        if(!setAllowedRecordTypeForContact.contains(mapAccountRecordTypes.get((Id)objMasterRecord.get('RecordTypeId')).getName().toLowerCase())){
                            isValid = true;
                        }else if(!Settings.getUserActive((String)objChildRecord.get('OwnerId')) || (mapOldItems != null && mapOldItems.get(objMasterRecord.Id) != null && mapOldItems.get(objMasterRecord.Id).get(strField) == objChildRecord.get('OwnerId'))){
                            isValid = true;
                        }
                    }
                    if(isValid){
                        mapFieldNameWithValue.put(strField, objMasterRecord.get(strField));
                    }       
                }else if(objApiName == 'Opportunity' && (objChildRecord.get('OwnerId') == null || AccountAssignmentHelper.isValidProfileAndUserForAssignment(String.valueOf(objChildRecord.get('OwnerId')))) &&
                         !setRestrictedStage.contains(String.valueOf(objChildRecord.get('StageName')).toLowerCase()) && mapOldItems != null && mapOldItems.get(objMasterRecord.Id) != null &&  
                         mapOldItems.get(objMasterRecord.Id).get(strField) == objChildRecord.get('OwnerId')){
                             mapFieldNameWithValue.put(strField, objMasterRecord.get(strField));
                }
            }
            if(!mapFieldNameWithValue.isEmpty()){
                objRecordToUpdate = mapGlobalDescribe.get(objApiName).newSObject();
                for(String fieldApiName: mapFieldNameWithValue.keySet()){
                    if(!fieldApiName.equalsIgnoreCase('OwnerId') || (fieldApiName.equalsIgnoreCase('OwnerId') && !BatchToUpdateMarketHelper.mapOpportunitiesToUpdateViaAssignment.containsKey((Id)objRecordToUpdate.get('Id')))){
                        objRecordToUpdate.put(fieldApiName, mapFieldNameWithValue.get(fieldApiName));
                    }
                }
                objRecordToUpdate.put('Id', objChildRecord.get('Id'));    
                if(lstRecordsToUpdate == null){
                    lstRecordsToUpdate = new List<sObject>();
                }
                lstRecordsToUpdate.add(objRecordToUpdate);
            }
        }
        return lstRecordsToUpdate;
    }
    
  /************************************************************************************************************************************
        Author              :   ---
        Description         :   This method is invoked from updateRecordType to get lower size from company size range.
        Created Date        :   11 June 2017
  **************************************************************************************************************************************/
    public static Integer getLowerSize(String size){
        return AccountAssignmentHelper.getLowerSize(size);
    }
    
    public static OpportunityTeamMember helperCreateOpportunityTeamMember(User userDetails, Opportunity objOpportunity, String teamMemberRole){
        OpportunityTeamMember objOpportunityTeamMember = new OpportunityTeamMember();
        objOpportunityTeamMember.UserId = userDetails.Id;
        objOpportunityTeamMember.TeamMemberRole = teamMemberRole;
        objOpportunityTeamMember.OpportunityId = objOpportunity.Id;
        objOpportunityTeamMember.TeamMemberCreationSource__c = 'TourOutcomeForm';
        return objOpportunityTeamMember;
    }
    public static OpportunityTeamMember helperCreateORUpdateOpportunityTeamMember(User objUser, Opportunity objOpportunity, String teamMemberRole){
        set<Id> setOpportunityTeamMemberIds = new set<Id>();
        for(OpportunityTeamMember objOpportunityTeamMember : objOpportunity.OpportunityTeamMembers ){
            if(objOpportunityTeamMember.UserId != null)
                setOpportunityTeamMemberIds.add(objOpportunityTeamMember.UserId);
        }
        if(setOpportunityTeamMemberIds.size() >0 && setOpportunityTeamMemberIds.contains(objUser.Id)){//If User is allready present as member then update its Role as Assist
            for(OpportunityTeamMember objOpportunityTeamMember : objOpportunity.OpportunityTeamMembers ){
                if(objOpportunityTeamMember.UserId == objUser.Id){
                    objOpportunityTeamMember.TeamMemberRole = 'Assist';
                    objOpportunityTeamMember.TeamMemberCreationSource__c = 'TourOutcomeForm';
                    return objOpportunityTeamMember;
                }
            }
        }else{//If user is not a member then add user as Team member 
            return helperCreateOpportunityTeamMember(objUser, objOpportunity, teamMemberRole);
        }
        return null;
    } 
   /************************************************************************************************************************************
        Author              :   ---
        Description         :   This method is used to update tour completed by field on tour.
        Created Date        :   11 June 2017
		LastModified By 	: 	Sunil Bhosale
		LastModified Date	: 	6 Dec 2018 
		Issue No			:	ST-3197
    **************************************************************************************************************************************/
    
    public static void updateTourCompletedBy(List<Tour_Outcome__c> lstNewTours, Map<Id, Tour_Outcome__c> mapOldTours){        
        set<String> setTourCompletedByUUIDs = new set<String>();
        set<String> setOpportunityIds = new set<String>();
        Map<String, Set<string>> mapExcludedProfiles = new Map<String, Set<string>>();
        MetadataSetting__mdt objMeataData = Settings.getMetadataSetting('RestrictTeamMemberProfiles');
        if(objMeataData != NULL && String.isNotBlank(objMeataData.Data__c)){
            mapExcludedProfiles = (Map<String,Set<String>>)JSON.deserialize(objMeataData.Data__c, Map<String,Set<String>>.class);   
        }
        for(Tour_Outcome__c objTour :  lstNewTours){
            if(String.isNotBlank(objTour.Tour_Completed_By_Contact_UUID__c) && mapOldTours.get(objTour.Id).Tour_Completed_By_Contact_UUID__c != objTour.Tour_Completed_By_Contact_UUID__c){
                setTourCompletedByUUIDs.add(objTour.Tour_Completed_By_Contact_UUID__c);
            }
            if(String.isNotBlank(objTour.Opportunity__c)){
                setOpportunityIds.add(objTour.Opportunity__c);
            }
        }
        Map<String, Contact> mapContacts = new Map<String, Contact>();
        Map<Id, Opportunity> mapRealetedOpp = new Map<Id, Opportunity>();
        if(!setTourCompletedByUUIDs.isEmpty()){
            for(Contact contact: [SELECT id, Email, UUID__c FROM Contact WHERE UUID__c In : setTourCompletedByUUIDs]){
                mapContacts.put(contact.UUID__c, contact);
            }
        }
        if(!setOpportunityIds.isEmpty()){
            mapRealetedOpp = new Map<Id, Opportunity>([SELECT Id, StageName, RecordType.Name, Owner.UserRole.Name, (SELECT Id,TeamMemberRole,OpportunityId,UserId FROM OpportunityTeamMembers ) FROM Opportunity WHERE Id IN :setOpportunityIds]);
        }
        List<OpportunityTeamMember> lstOppTeamMember = new List<OpportunityTeamMember>();
        List<Opportunity> lstOpportunityToUpdate = new List<Opportunity>();
        Set<String> setRoles = new Set<String>();
        Set<String> setOpportunityStages = new Set<String>{'closed won', 'closed lost'};
        Setting__c OpportunityOwnershipSetting = Settings.get('OpportunityOwnershipTourOutcomeSetting');
        if(OpportunityOwnershipSetting != NULL && String.isNotBlank(OpportunityOwnershipSetting.Data__c)){
            setRoles = (Set<String>)(JSON.deserialize(OpportunityOwnershipSetting.Data__c.toLowerCase(), Set<String>.class));
        } 
        for(Tour_Outcome__c objTour :  lstNewTours){
            if(String.isNotBlank(objTour.Tour_Completed_By_Contact_UUID__c) && mapContacts.get(objTour.Tour_Completed_By_Contact_UUID__c) != null){
                Contact objContact = mapContacts.get(objTour.Tour_Completed_By_Contact_UUID__c);
                objTour.Tour_Completed_By__c = objContact.Id;
            }
            User objUser = getValideUserForOpportunityTeamMember(objTour.Tour_Completed_By_SFID__c, mapExcludedProfiles);
            if(objUser != null && String.isNotBlank(objTour.Opportunity__c) && mapRealetedOpp.get(objTour.Opportunity__c) != null){
                lstOppTeamMember.add(helperCreateORUpdateOpportunityTeamMember(objUser, mapRealetedOpp.get(objTour.Opportunity__c), 'Assist'));
            }
            if(String.isNotBlank(objTour.Tour_Completed_By_SFID__c) && mapOldTours.get(objTour.Id).Tour_Completed_By_SFID__c != objTour.Tour_Completed_By_SFID__c){
                objTour.OwnerId = (Id)objTour.Tour_Completed_By_SFID__c;
                if(String.isNotBlank(objTour.Opportunity__c) && mapRealetedOpp.get(objTour.Opportunity__c) != null){
                    Opportunity objOpportunity = mapRealetedOpp.get(objTour.Opportunity__c);
                    if(objOpportunity != null && String.isNotBlank(objOpportunity.StageName) && !setOpportunityStages.contains(objOpportunity.StageName.toLowerCase()) && objOpportunity.Owner.UserRoleId !=null && !setRoles.contains(objOpportunity.Owner.UserRole.Name.toLowerCase()) && !AccountAssignmentHelper.getRecordTypeNameById('Opportunity', objOpportunity.RecordTypeId).equalsIgnoreCase('Mid Market') && !AccountAssignmentHelper.getRecordTypeNameById('Opportunity', objOpportunity.RecordTypeId).equalsIgnoreCase('Enterprise Solutions')){
                        objOpportunity.OwnerId = (Id)objTour.Tour_Completed_By_SFID__c; 
                        lstOpportunityToUpdate.add(objOpportunity);
                    }
                }
            }
        }
        if(!lstOpportunityToUpdate.isEmpty()){
            if(!lstOppTeamMember.isEmpty()){
                if(OpportunityHelper.lstOpportunityTeamMembers == NULL){
                    OpportunityHelper.lstOpportunityTeamMembers = new List<OpportunityTeamMember>();
                }
                OpportunityHelper.lstOpportunityTeamMembers.addAll(lstOppTeamMember);
            }
           update lstOpportunityToUpdate;
        }else if(!lstOppTeamMember.isEmpty()){
           upsert lstOppTeamMember;
        }
    }
    
    /****************************************************************************************************************************
        Author              : Nikhil Mehta
        Description         : This method returns valid user if the user is valid for the team member creation.
        Created Date        : 05 July 2016
    *****************************************************************************************************************************/
    public static User getValideUserForOpportunityTeamMember(Id userId, Map<String, Set<String>> mapExcludedProfiles){
        if(String.isNotBlank(userId) && Settings.getUserActive(userId)){
            User objUser = Settings.getUserById(userId);
            if(mapExcludedProfiles != NULL && !mapExcludedProfiles.isEmpty() &&
               mapExcludedProfiles.get('RestrictProfilesForRoleAssist') != NULL &&
               !mapExcludedProfiles.get('RestrictProfilesForRoleAssist').contains(String.valueOf(objUser.ProfileId)) && 
               !mapExcludedProfiles.get('RestrictProfilesForRoleAssist').contains(String.valueOf(objUser.ProfileId).substring(0, 15)) &&
               !AccountAssignmentHelper.isApiUser('UserId', objUser.Id)){
                   return objUser;
               }
        }
        return NULL;
    }
    
    /****************************************************************************************************************************
        Author              : Amol Darekar
        Description         : This method is invoked from OpportunityTeamMember on before insert and before Update.
        Summary             : This Method is used to Update the Split percentage according to sales console setting creiterias on OpportunityTeam Member records.
        Created Date        : 05 July 2016
        Last Modified By    : Krishana Tupe
        Last Modified Date  : 05 February 2018
    *****************************************************************************************************************************/
    public static void updateSplitPercentage(List<OpportunityTeamMember> listNewItems,Map<Id, OpportunityTeamMember> mapNewItems) {
        Set<Id> setOpportunityIds = new Set<Id>();
        Set<Id> setUserIds = new Set<Id>();
        for(OpportunityTeamMember objOpportunityTeam :  listNewItems){
            setOpportunityIds.add(objOpportunityTeam.OpportunityId);
            setUserIds.add(objOpportunityTeam.UserId);
        }
        Map<Id,Opportunity> mapOpportunity = new Map<Id,Opportunity>([Select Id,Owner.UserRole.Name,LeadSource From Opportunity Where Id IN:setOpportunityIds]);
        
        Settings.fetchUsers();
        Map<Id,User> mapUserSfdcRole = Settings.mapUserById;
        //Map<Id,User> mapUserSfdcRole = new Map<Id,User>([Select Id,UserRole.Name from User Where Id IN:setUserIds]);
        
        for(OpportunityTeamMember objOpportunityTeam :  listNewItems){
            if(!(WeworkEngine.hasSObjectField('Split_Rep_Percentage__c',objOpportunityTeam)) && objOpportunityTeam.Split_Rep_Percentage__c==null){
                Opportunity objOpportunity = mapOpportunity.get(objOpportunityTeam.OpportunityId);
                if(objOpportunity.Owner.UserRole !=null&&(objOpportunity.Owner.UserRole.Name.toLowerCase().contains('key sales') || objOpportunity.Owner.UserRole.Name.toLowerCase().contains('lead -')) && objOpportunityTeam.TeamMemberRole.toLowerCase()==('split rep')){                        
                    if(mapUserSfdcRole.get(objOpportunityTeam.UserId) != null){
                        if((mapUserSfdcRole.get(objOpportunityTeam.UserId).UserRole.Name.toLowerCase().contains('key sales')|| mapUserSfdcRole.get(objOpportunityTeam.UserId).UserRole.Name.toLowerCase().contains('lead -')) && (objOpportunity.LeadSource != null && objOpportunity.LeadSource.toLowerCase()=='outbound email/cold call')){                          
                            objOpportunityTeam.Split_Rep_Percentage__c = 100.00;
                        }
                        else if((mapUserSfdcRole.get(objOpportunityTeam.UserId).UserRole.Name.toLowerCase().contains('enterprise solutions') || mapUserSfdcRole.get(objOpportunityTeam.UserId).UserRole.Name.toLowerCase().contains('key sales') || mapUserSfdcRole.get(objOpportunityTeam.UserId).UserRole.Name.toLowerCase().contains('lead -')) && (objOpportunity.LeadSource != null && objOpportunity.LeadSource.toLowerCase()=='outbound email/cold call')){                           
                            objOpportunityTeam.Split_Rep_Percentage__c = 50.00;
                        }
                        else{                             
                            objOpportunityTeam.Split_Rep_Percentage__c = 0;
                        }  
                    }                        
                }
                else if(objOpportunity.Owner.UserRole !=null && objOpportunity.Owner.UserRole.Name.toLowerCase().contains('enterprise solutions')){
                    if(mapUserSfdcRole.get(objOpportunityTeam.UserId) != null){
                        if(mapUserSfdcRole.get(objOpportunityTeam.UserId).UserRole.Name.toLowerCase().contains('enterprise solutions')){
                            objOpportunityTeam.Split_Rep_Percentage__c = 100.00;
                        }
                        else if(mapUserSfdcRole.get(objOpportunityTeam.UserId).UserRole.Name.toLowerCase().contains('key sales') || mapUserSfdcRole.get(objOpportunityTeam.UserId).UserRole.Name.toLowerCase().contains('lead -')){
                            objOpportunityTeam.Split_Rep_Percentage__c = 50.00;
                        }
                        else{
                            objOpportunityTeam.Split_Rep_Percentage__c = 0;
                        }   
                    }                        
                }
                else{
                    objOpportunityTeam.Split_Rep_Percentage__c = 0;
                }
            }
        }  
    }
    
}