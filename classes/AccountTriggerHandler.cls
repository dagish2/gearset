/************************************************************************************************************************************
    Author      :   Mayuresh Ghodke
    Description :   This class contains business logic for AccountTriggers

    History :
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                     DETAIL
    1           05 July 2016        Mayuresh Ghodke            Initial Developement
    2           06 June 2018        Prashant Mane              changes according to Account Hirarchy 2
**************************************************************************************************************************************/
public with sharing class AccountTriggerHandler extends ITriggerHandler{  
    public AccountTriggerHandler(){
        super('Account');
    }
    
    /************************************************************************************************************************************
        Author              :   Mayuresh Ghodke
        Description         :   This method overrides before insert method from ITriggerHander which will control the execution flow.
        Last Modified Date  :   05 July 2016
        Last Modified By    :   Mayuresh Ghodke
    -------------------------------------------------------------------------------------------------------------------------------
        Last Modified By    :   Prashant Mane
        Last Modified Date  :   06 June 2018
    **************************************************************************************************************************************/
    public override void BeforeInsert(List<SObject> listNewItems){
        if(TriggerSettings.mappedField.Account_SetAccountPrimaryMember){
            setAccountPrimaryMember(listNewItems,null);
        }
        if(TriggerSettings.mappedField.Account_retrictDuplicateOrgName){
            retrictDuplicateOrgName(listNewItems, null,null,null);
        }
        WithoutSharingUtilityController.updateRecordType(listNewItems, null,null,null);
        if(TriggerSettings.mappedField.Account_updateAccountName){
            updateAccountName(listNewItems,null,null,null);
        }
        if(TriggerSettings.mappedField.Account_UpdateCleansedAccNameAndUnomyName){
            updateCleansedName((List<Account>)listNewItems);
        }            
        if(TriggerSettings.mappedField.Account_checkDuplicateNicknameInOrg){
            checkDuplicateNicknameInOrg(listNewItems,null,null,null);
        }
    }
    
    /************************************************************************************************************************************
        Author              :   Mayuresh Ghodke
        Description         :   This method overrides after insert method from ITriggerHander which will control the execution flow.
        Last Modified Date  :   05 July 2016
        Last Modified By    :   Mayuresh Ghodke
    -------------------------------------------------------------------------------------------------------------------------------
        Last Modified By    :   Prashant Mane
        Last Modified Date  :   06 June 2018
    **************************************************************************************************************************************/ 
    public override void AfterInsert(List<SObject> listNewItems, Map<Id, SObject> mapNewItems){
        if(Triggersettings.mappedField.Account_CreateMergedAccounts){
            createMergedAccounts(listNewItems,mapNewItems);
        }
    }
    /************************************************************************************************************************************
        Author              :   Mayuresh Ghodke
        Description         :   This method overrides before update method from ITriggerHander which will control the execution flow.
        Last Modified Date  :   05 July 2016    
        Last Modified By    :   Mayuresh Ghodke
    -------------------------------------------------------------------------------------------------------------------------------
        Last Modified By    :   Prashant Mane
        Last Modified Date  :   06 June 2018
    **************************************************************************************************************************************/
    public override void BeforeUpdate(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems){
        Debug.Log('listNewItems---'+Trigger.new);
        Debug.Log('listOldItems---'+Trigger.old);
        if(TriggerSettings.mappedField.Account_SetAccountPrimaryMember){
            setAccountPrimaryMember(listNewItems, mapNewItems);
        }
        if(TriggerSettings.mappedField.Opportunity_SendEmailOnOwnerChange){
            storeAccOpportunitiesForEmailAlert((List<Account>)listNewItems, (Map<Id, Account>) mapNewItems, (List<Account>) listOldItems, (Map<Id, Account>) mapOldItems);
        }
        if(TriggerSettings.mappedField.Account_retrictDuplicateOrgName){
            retrictDuplicateOrgName(listNewItems, mapNewItems, listOldItems, mapOldItems);
        }
        WithoutSharingUtilityController.updateRecordType(listNewItems, mapNewItems, listOldItems, mapOldItems);
        if(TriggerSettings.mappedField.Account_updateAccountName){
            updateAccountName(listNewItems,null,null,null);
        }
        if(TriggerSettings.mappedField.Account_UpdateCleansedAccNameAndUnomyName){
            updateCleansedName((List<Account>)listNewItems);
        }            
        if(TriggerSettings.mappedField.Account_checkDuplicateNicknameInOrg){
            checkDuplicateNicknameInOrg(listNewItems,null,null,mapOldItems);
        }      
    }
    
    /************************************************************************************************************************************
        Author              :   Mayuresh Ghodke
        Description         :   This method overrides after update method from ITriggerHander which will control the execution flow.
        Last Modified Date  :   05 July 2016    
        Last Modified By    :   Mayuresh Ghodke
    -------------------------------------------------------------------------------------------------------------------------------
        Last Modified By    :   Prashant Mane
        Last Modified Date  :   06 June 2018
    **************************************************************************************************************************************/    
    public override void AfterUpdate(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems){
        WithoutSharingUtilityController.updateChildRecords();
        if(TriggerSettings.mappedField.Account_UnomyMergeAccounts){
            unomyMergeAccounts(listNewItems, mapNewItems,listOldItems,mapOldItems);
        }
        if(TriggerSettings.mappedField.Account_updateOnReparent){
            updateOnReparent((List<Account>)listNewItems,null,null,(Map<Id,Account>)mapOldItems);
        }
        
        if(TriggerSettings.mappedField.Account_SendEmailOnOwnerChange){
            sendEmailOnOwnerChange((List<Account>)listNewItems, (Map<Id, Account>) mapNewItems, (List<Account>) listOldItems, (Map<Id, Account>) mapOldItems);
        }
        
        //as we are not generating uuid for account object so no need of this trigger
        /*if(TriggerSettings.mappedField.Account_UpdateMergedAccountUUID){
            updateMergedAccountUUID(listNewItems, mapNewItems,listOldItems,mapOldItems);
        }*/
        
        //handle through formula field
        //setUltimateParentToAccount(listNewItems,null,null,null);
    }
    
    /************************************************************************************************************************************
        Author              :   Mayuresh Ghodke
        Description         :   This method overrides before delete method from ITriggerHander which will control the execution flow.
        Last Modified Date  :   05 July 2016    
        Last Modified By    :   Mayuresh Ghodke
    -------------------------------------------------------------------------------------------------------------------------------
        Last Modified By    :   Prashant Mane
        Last Modified Date  :   06 June 2018
    **************************************************************************************************************************************/    
    public override void BeforeDelete(List<SObject> listOldItems, Map<Id, SObject> mapOldItems){
        /*deleteAccounts(listOldItems,mapOldItems);*/
        if(TriggerSettings.mappedField.Account_deleteAccountValidations){
            deleteAccountValidations(listOldItems,mapOldItems);
        }
        if(TriggerSettings.mappedField.Account_reparentChildAccounts){
            reparentChildAccounts(listOldItems,mapOldItems);
        }
    }
    
    /************************************************************************************************************************************
        Author              :   Mayuresh Ghodke
        Description         :   This method overrides after delete method from ITriggerHander which will control the execution flow.
        Last Modified Date  :   05 July 2016    
        Last Modified By    :   Mayuresh Ghodke
    --------------------------------------------------------------------------------------------------------------------------------------
        Last Modified By    :   Milanjeet singh
        Last Modified Date  :   16 June 2018
        Issue No.           :   ST-2173
    -------------------------------------------------------------------------------------------------------------------------------
        Last Modified By    :   Prashant Mane
        Last Modified Date  :   06 June 2018
    **************************************************************************************************************************************/
    public override void AfterDelete(List<SObject> listOldItems, Map<Id, SObject> mapOldItems){
        /*deleteAccounts(listOldItems, mapOldItems);*/
        
        /*discussed with parag we dont need to generate push topics after org merge.
        if(TriggerSettings.mappedField.Account_NotifyPushTopicsForMerge){
            notifyPushTopicsForMerge(listOldItems, mapOldItems);
        }*/
        if(TriggerSettings.mappedField.Account_deleteAccountValidations){
            deleteAccountValidations(listOldItems,mapOldItems);
        }
        if(TriggerSettings.mappedField.Account_reparentChildAccounts){
            reparentChildAccounts(listOldItems,mapOldItems);
        }
        if(TriggerSettings.mappedField.Account_HierarchyAccountAndOpportunityNameOnMerge){
             updateHierarchyAccountAndOpportunityNameOnMerge(listOldItems,mapOldItems);
        }
    }
    
    /************************************************************************************************************************************
        Author              :   Mayuresh Ghodke
        Description         :   This method is used to set primary member of Account
        Last Modified Date  :   05 July 2016    
        Last Modified By    :   Mayuresh Ghodke
    -------------------------------------------------------------------------------------------------------------------------------
        Last Modified By    :   Prashant Mane
        Discription         :   Code-Optimisation
        Last Modified Date  :   06 June 2018
    **************************************************************************************************************************************/
    public static void setAccountPrimaryMember(List<Account> listNewItems, Map<Id, SObject> mapNewItems) {
        Set<Id> accsToProcessIds;
        for(Account acc : listNewItems){
            if(string.isBlank(acc.Primary_Member__c)){
                if(accsToProcessIds==null){
                    accsToProcessIds = new Set<Id>();
                }
                accsToProcessIds.add(acc.Id);
            }
        }
        //Get Accounts and first contacts
        if(accsToProcessIds != null && !accsToProcessIds.isEmpty()){
            List<Account> accsToUpdate = [SELECT Id,(SELECT Id FROM Contacts ORDER BY CreatedDate LIMIT 1) 
                                          FROM Account WHERE Id IN :accsToProcessIds];               
            Debug.log('accsToUpdate :: '+accsToUpdate);                
            for(Account acc : accsToUpdate){
                if(acc.Contacts.size() > 0){
                    Account triggerAcc = (Account)mapNewItems.get(acc.Id);
                    triggerAcc.Primary_Member__c = acc.Contacts[0].Id;
                }       
            }
        }
    }
    
    /************************************************************************************************************************************
        Author              :   Ajaysinh Chauhan
        Description         :   Merges two accounts when Unomy enriches the data
        CreatedDate         :   18 April 2017
        Last Modified Date  :   2 February 2018
        Last Modified By    :   Ajaysinh Chauhan
    -------------------------------------------------------------------------------------------------------------------------------
        Last Modified By    :   Prashant Mane
        Discription         :   Chnages in Soql to only allow merging of Org ype of accounts.
        Last Modified Date  :   06 June 2018
    **************************************************************************************************************************************/
    public static void unomyMergeAccounts(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems){
        if(Settings.get('AccountMergeSettings')!= null){
            Map<String,Set<String>> setting = (Map<String,Set<String>>)JSON.deserialize(Settings.get('AccountMergeSettings').Data__c.toLowerCase(),Map<String,Set<String>>.class); 
            Set<String> setOwners = setting.get('owner');
            Set<String> setProfiles = setting.get('profiles');
            Set<Decimal> setUnomyCompanyIds;
            Set<Id> setAccountIds;
            for(Account acc:(List<Account>)listNewItems){
                if(acc.Unomy_Company_ID__c!=null && acc.Unomy_Updated_DateTime__c!=null && (acc.Unomy_Company_ID__c!=mapOldItems.get(acc.Id).get('Unomy_Company_ID__c') || acc.Unomy_Updated_DateTime__c!=mapOldItems.get(acc.Id).get('Unomy_Updated_DateTime__c'))){
                    if(setAccountIds == null && setUnomyCompanyIds == null){
                        setAccountIds = new Set<Id>();
                        setUnomyCompanyIds = new Set<Decimal>();
                    }
                    setUnomyCompanyIds.add(acc.Unomy_Company_ID__c);
                    setAccountIds.add(acc.Id);
                }
            }
            if(setAccountIds !=null && setAccountIds.size()>0){
                Map<Id,Id> mapMergeData = new Map<Id,Id>();
                List<Account> lstAccounts = [Select Id,Name,CreatedDate,OwnerId,Owner.Profile.Name,CreatedById,CreatedBy.Profile.Name,Allow_Merge__c,Is_Merged__c,Account_Type__c,Unomy_Company_Id__c,Unomy_Updated_DateTime__c,(Select Id,Total_Reservables_Selected__c From Opportunities) From Account Where Id IN:setAccountIds OR Unomy_Company_Id__c IN:setUnomyCompanyIds];
                Debug.log('lstAccounts---'+lstAccounts);
                for(Account acc : lstAccounts){
                    if(setOwners.contains(String.valueOf(acc.OwnerId).substring(0,15).toLowerCase()) || setOwners.contains(String.valueOf(acc.CreatedById).substring(0,15).toLowerCase()) || setProfiles.contains(acc.Owner.Profile.Name.toLowerCase()) || setProfiles.contains(acc.CreatedBy.Profile.Name.toLowerCase())){
                        if(mapNewItems.containsKey(acc.Id) && acc.Allow_Merge__c && !acc.Is_Merged__c && acc.Account_Type__c=='Org'){
                            Boolean allowMerge = true;
                            for(Opportunity opp : acc.Opportunities){
                                if(opp.Total_Reservables_Selected__c>0){
                                    allowMerge = false;
                                }
                            }
                            if(allowMerge){
                                Account masterAccount = getMasterAccount(acc,lstAccounts);
                                if(masterAccount!=null){
                                    mapMergeData.put(acc.Id,masterAccount.Id);
                                }
                            }
                        }
                    }
                }
                Debug.log('mapMergeData---'+mapMergeData);
                Map<String,Object> mapFields = truncateReadOnlyFields(listNewItems[0].getPopulatedFieldsAsMap());
                List<String> lstFieldsToQuery = new List<String>();
                lstFieldsToQuery.addAll(mapFields.keySet());
                List<Id> lstMasterIds = mapMergeData.values();
                List<Account> lstMasterAccounts = Database.query('Select Id,'+String.join(lstFieldsToQuery, ',')+' From Account Where Id IN:lstMasterIds');
                Debug.log('lstMasterAccounts---'+lstMasterAccounts);
                Map<Id,Account> mapMasterAccount = new Map<Id,Account>((List<Account>)lstMasterAccounts);
                Set<Id> setMasterAccountIDs = new Set<Id>();
                for(Account acc : (List<Account>)listNewItems){
                    if(mapMergeData.containsKey(acc.Id)){
                        Account masterAccount = mapMasterAccount.get(mapMergeData.get(acc.Id));
                        for(String strField : lstFieldsToQuery){
                            if(masterAccount.get(strField)==null && acc.get(strField)!=null){
                                masterAccount.put(strField,acc.get(strField));
                            }
                        }
                        setMasterAccountIDs.add(masterAccount.Id);
                        Database.merge(masterAccount,acc.Id);             
                    }
                }
                if(setMasterAccountIDs.size()>0){
                    assignmentOnPostUnomyMerge(setMasterAccountIDs, setting);
                }
            }
        }
    }
    /************************************************************************************************************************************
        Author              :   Ajaysinh Chauahn
        Description         :   This is a helper method to get the related master record for accounts.
        Created Date        :   10 Feb 2018
    -------------------------------------------------------------------------------------------------------------------------------
        Last Modified By    :   Prashant Mane
        Last Modified Date  :   06 June 2018
    **************************************************************************************************************************************/
    public static Account getMasterAccount(Account objAccount,List<Account> lstAccounts){
        Account masterAccount;
        for(Account acc : lstAccounts){
            if(acc.Id!=objAccount.Id && acc.Unomy_Company_ID__c==objAccount.Unomy_Company_ID__c){
                if((objAccount.Account_Type__c=='Org' && acc.Account_Type__c=='Org')){
                    if(masterAccount==null || masterAccount.CreatedDate<acc.CreatedDate){
                        masterAccount = acc;
                    }
                }
            }
        }
        return masterAccount;
    }
    
    /************************************************************************************************************************************
        Author              :   Ajaysinh Chauahn
        Description         :   This method is used to truncate read only fields
        Last Modified Date  :   05 July 2016
        Last Modified By    :   Ajaysinh Chauahn
    **************************************************************************************************************************************/    
    public static Map<String,Object> truncateReadOnlyFields(Map<String,Object> mapFields){
        Map<String,Schema.SObjectField> mfields = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap();
        Map<String,Object> mapNewFields = new Map<String,Object>();
        for(String field:mapFields.keyset()){
            if(mfields.get(field).getDescribe().isUpdateable()){
                mapNewFields.put(field,mapFields.get(field));
            }
        }
        return mapNewFields;
    }
    
    /************************************************************************************************************************************
        Author              :   Dipak Pawar
        Description         :   Create an "Merged Account" record under the Accounts UUID object when after Account insert.
        Issue No.           :   ST-1150
        Last Modified Date  :   23 June 2017
        Last Modified By    :   Dipak Pawar
    -------------------------------------------------------------------------------------------------------------------------------
        Last Modified By    :   Prashant Mane
        Discription         :   As Org account is not generating UUIDs while creating merge account removed mapping uuid field
        Last Modified Date  :   06 June 2018
    **************************************************************************************************************************************/
    public static void createMergedAccounts(List<SObject> listNewItems, Map<Id, SObject> mapNewItems){ 
        List<Merged_Account__c> lstMergedAccounts = new List<Merged_Account__c>();
        if(listNewItems != null){
            for(Account accRec : (List<Account>)listNewItems){
                Debug.log('accRec => '+accRec);
                Merged_Account__c mergedAccountRec = new Merged_Account__c(
                    Account__c = accRec.Id,
                    CurrencyIsoCode = 'USD'
                );
                lstMergedAccounts.add(mergedAccountRec);
            } 
        }
        Debug.log('lstMergedAccounts => '+lstMergedAccounts);
        if(lstMergedAccounts.size() > 0){               
            insert lstMergedAccounts;
        }
    }

    /************************************************************************************************************************************
        Author              :   Dipak Pawar
        Description         :   When accounts UUID gets updated need to update related Merged Account's Merged_Account_UUID__c.
        Issue No.           :   ST-1152
        Last Modified Date  :   23 June 2017
        Last Modified By    :   Dipak Pawar
    -------------------------------------------------------------------------------------------------------------------------------
        Last Modified By    :   Prashant Mane
        Last Modified Date  :   06 June 2018
        Discription         :   no use of this trigger as org account is not generating UUIDs
    **************************************************************************************************************************************/
    /*public static void updateMergedAccountUUID(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems){
        Set<String> setAccountUUIDs = new Set<String>();
        Map<Id, Account> accountOldMap;
        if(mapOldItems != null)
            accountOldMap = (Map<Id, Account>)mapOldItems;
        Debug.log('updateMergedAccountUUID accountOldMap =>'+accountOldMap);
        Map<String, Merged_Account__c> mapRelatedMergedAccounts = new Map<String, Merged_Account__c>();
        Map<Id, Merged_Account__c> mapRelatedMergedAccountsToUpdate = new Map<Id, Merged_Account__c>();
        if(listNewItems != null){
            for(Account newAccRec : (List<Account>)listNewItems){
                Account oldAccRec = (Account)accountOldMap.get(newAccRec.Id);
                if(newAccRec.UUID__c != null && oldAccRec.UUID__c != newAccRec.UUID__c){
                    setAccountUUIDs.add(oldAccRec.UUID__c);
                }
            }
        }
        setAccountUUIDs.remove(null);
        Debug.log('setAccountUUIDs =>'+setAccountUUIDs);            
        if(!setAccountUUIDs.isEmpty()){
            Debug.log('Test =>'+setAccountUUIDs);    
            List<Merged_Account__c> lstMergedAcc = [SELECT Id, Account__c, Merged_Account_UUID__c FROM Merged_Account__c WHERE Merged_Account_UUID__c IN :setAccountUUIDs]; 
            Debug.Log('lstMergedAcc =>'+lstMergedAcc);
            if(lstMergedAcc != null){
                for(Merged_Account__c relatedMergedAccount : lstMergedAcc){
                    mapRelatedMergedAccounts.put(relatedMergedAccount.Merged_Account_UUID__c, relatedMergedAccount);
                }  
            }
            
            Debug.Log('mapRelatedMergedAccounts =>'+mapRelatedMergedAccounts);
            if(!mapRelatedMergedAccounts.isEmpty()){
                if(listNewItems != null){
                    for(Account newAccRec : (List<Account>)listNewItems){
                        Account oldAccRec = (Account)accountOldMap.get(newAccRec.Id);
                        if(newAccRec.UUID__c != null && oldAccRec.UUID__c != newAccRec.UUID__c && mapRelatedMergedAccounts.get(oldAccRec.UUID__c) != null){
                            Merged_Account__c mergedAccount = mapRelatedMergedAccounts.get(oldAccRec.UUID__c);
                            mergedAccount.Merged_Account_UUID__c = newAccRec.UUID__c;
                            mapRelatedMergedAccountsToUpdate.put(mergedAccount.Id, mergedAccount);
                        }
                    }
                }
                Debug.log('mapRelatedMergedAccountsToUpdate =>'+mapRelatedMergedAccountsToUpdate);
                if(!mapRelatedMergedAccountsToUpdate.isEmpty()){                       
                    update mapRelatedMergedAccountsToUpdate.values();
                }
            }
        }
    }
    */
    
    /************************************************************************************************************************************
        Author              :   Mayuresh Ghodke
        Description         :   This method is used to delete an account
        Issue No.           :   ST-1162,ST-1163
        Last Modified Date  :   18 April 2017
        Last Modified By    :   Mayuresh Ghodke
    **************************************************************************************************************************************/
   /* public static void deleteAccounts(List<SObject> listOldItems, Map<Id, SObject> mapOldItems){  
        try{
            if(TriggerSettings.mappedField.Account_DeleteAccounts){
                System.debug('1.Number of Queries used in this apex code so far in unomy merge: ' + Limits.getQueries());
                List<String> lstRestrictAccountDeletion;
                List<Profile> lstProfileIds;
                Set<Id> setRestrictAccountDeletion = new Set<Id>();
                Set<Id> setAccountWithOpp = new Set<Id>();
                //Check current Accounts having Opportunity with Opportunity Reservables
                List<Opportunity> lstOpportunities = [Select Id, AccountId, Total_Reservables_Selected__c From Opportunity Where AccountId IN: listOldItems];
                if(lstOpportunities.size()>0){
                    for(Opportunity opp : lstOpportunities)
                        if(opp.Total_Reservables_Selected__c > 0)
                        setAccountWithOpp.add(opp.AccountId);
                }
                //Fetch RestrictAccountDeletion which having name of profiles those dont have permission to delete the active accounts.
                if(Settings.get('RestrictAccountDeletion') != null)
                    lstRestrictAccountDeletion = (List<String>)JSON.deserialize(Settings.get('RestrictAccountDeletion').Data__c,List<String>.class);
                else
                    lstRestrictAccountDeletion = new List<String>();
                if(lstRestrictAccountDeletion.size()>0){
                    lstProfileIds = [Select Id From Profile Where Name IN : lstRestrictAccountDeletion];
                    Debug.log('lstProfileIds --> '+lstProfileIds);
                    if(lstProfileIds.size()>0)
                        for(Profile objProfile : lstProfileIds)
                        setRestrictAccountDeletion.add(objProfile.Id);
                }            
                for(Account objAcc : (List<Account>)listOldItems){
                    if(Trigger.isBefore){
                        //Check Current account is Active 
                        if(objAcc.ID_Status2__c == 'active'){
                            System.debug('2.Number of Queries used in this apex code so far in unomy merge: ' + Limits.getQueries());
                            mapOldItems.get(objAcc.Id).addError('Active Accounts cannot be deleted or merged.');
                        }
                        //Check current Accounts which having Opportunity with Opportunity Reservables.                   
                        if(setAccountWithOpp.contains(objAcc.Id)){
                            debug.log('Delete Opp Related --> '+objAcc);
                            mapOldItems.get(objAcc.Id).addError('You cannot delete or merge an Account that has an Opportunity with Opportunity Reservables.');
                        }
                        //Check current Account not mearge with other account and Logged in user's profile dont have permission to delete Account give error.
                        debug.log('MasterRecordId --> '+objAcc.MasterRecordId);
                        debug.log('setRestrictAccountDeletion.contains(UserInfo.getProfileId()) --> '+setRestrictAccountDeletion.contains(UserInfo.getProfileId()));
                    }
                    if(Trigger.isAfter)
                        if(objAcc.MasterRecordId == null && setRestrictAccountDeletion.contains(UserInfo.getProfileId())){
                            debug.log('MasterRecordId --> '+objAcc.MasterRecordId);
                            mapOldItems.get(objAcc.Id).addError('You do not have permission to delete the account.');
                        }
                }
            }
        } catch(Exception pEx) {
            List<Id> ids = New List<Id>();
            if(mapOldItems!=null)
                ids.addAll(mapOldItems.keyset());
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('AccountTriggerHandler','deleteAccounts',String.join(ids,','),pEx)
            );
            throw new AccountTriggerHandlerException(pEx.getMessage());
        } 
        
    }
    */
    /************************************************************************************************************************************
        Author              :   Ajaysinh Chauhan
        Description         :   When account merge takes place we fire force update to merged account for notify push topic
        Last Modified Date  :   30 June 2017
        Last Modified By    :   Ajaysinh Chauhan
        -------------------------------------------------------------------------------------------------------------------------------
        Last Modified By    :   Prashant Mane
        Discription         :   No need to notify push topic for an org type of accounts
        Last Modified Date  :   06 June 2018
    **************************************************************************************************************************************/
    /*public static void notifyPushTopicsForMerge(List<SObject> listOldItems, Map<Id, SObject> mapOldItems){     
        Debug.log('in notifyPushTopicsForMerge');
        Set<Id> setMasterIds = new Set<Id>();
        for(Account acc : (List<Account>)listOldItems){
            if(acc.MasterRecordId!=null){
                setMasterIds.add(acc.MasterRecordId);
            }
        }
        Map<String,Merged_Account__c> mapMergedAccount = new Map<String,Merged_Account__c>();
        for(Merged_Account__c macc : [Select Id,Name,Account__c,Master_UUID__c,Merged_Account_UUID__c,Is_Deleted__c,Force_Update__c From Merged_Account__c Where Account__c IN:setMasterIds]){
            mapMergedAccount.put(macc.Merged_Account_UUID__c,macc);
        }
        Debug.log('mapMergedAccount : '+mapMergedAccount);
        List<Merged_Account__c> lstMergedAccounts = new List<Merged_Account__c>();
        for(Account acc : (List<Account>)listOldItems){
            if(acc.MasterRecordId!=null && mapMergedAccount.containsKey(acc.UUID__c)){
                lstMergedAccounts.add(new Merged_Account__c(Id=mapMergedAccount.get(acc.UUID__c).Id,Account__c=acc.MasterRecordId,Merged_Account_UUID__c=acc.UUID__c,Force_Update__c=(!mapMergedAccount.get(acc.UUID__c).Force_Update__c)));
            }
        }        
        update lstMergedAccounts; 
    } 
    */
    
    /************************************************************************************************************************************
        Author              :   Samadhan kadam
        Description         :   This method is used to update Cleansed Company Name and Cleansed Unomy Company Name 
        Issue No.           :   ST-1246
        Last Modified Date  :   27 June 2018
        Last Modified By    :   Pragalbha Mahajan 
    **************************************************************************************************************************************/
    public static void updateCleansedName(List<Account> listNewItems){
        for(Account account:listNewItems){
            if(String.isNotBlank(account.Name) ) 
                account.Cleansed_Account_Name__c = OrganizationHelper.getCleansedName(account.Name);
            if(String.isNotBlank(account.Unomy_Company_Name__c) )
                account.Cleansed_Unomy_Company_Name__c = OrganizationHelper.getCleansedName(account.Unomy_Company_Name__c);
            if(String.isBlank( account.BillingStreet) && String.isNotBlank(account.Unomy_Location_Address__c))
                //account.BillingStreet = account.Unomy_Location_Address__c;
            if(String.isBlank(account.BillingCity) && String.isNotBlank(account.Unomy_Location_City__c))
                //account.BillingCity = account.Unomy_Location_City__c;
            if(String.isBlank(account.BillingState) && String.isNotBlank(account.Unomy_Location_State__c))
                //account.BillingState = account.Unomy_Location_State__c;
            if(String.isBlank( account.BillingCountry ) && String.isNotBlank(account.Unomy_Location_Country__c))
                //account.BillingCountry = account.Unomy_Location_Country__c;
            if(account.Number_of_Full_Time_Employees__c == null && account.Unomy_Company_Size_Min__c!=null)
                account.Number_of_Full_Time_Employees__c = account.Unomy_Company_Size_Min__c;
            if(account.AnnualRevenue == null && account.Unomy_Estimated_Revenue_Min__c!=null)
                account.AnnualRevenue = account.Unomy_Estimated_Revenue_Min__c;
            if(String.isBlank(account.Website) && String.isNotBlank(account.Unomy_Company_Website__c))
                account.Website = account.Unomy_Company_Website__c;
        }
    } 
    /************************************************************************************************************************************
        Author              :   Dipak Pawar
        Description         :   Contact and Opportunity Assignment post Account Merge.
        Issue No.           :   ST-1421
        Last Modified Date  :   29 September 2017
        Last Modified By    :   Dipak Pawar
    **************************************************************************************************************************************/
    public static void assignmentOnPostUnomyMerge(Set<Id> setMasterAccounts, Map<String,Set<String>> accountAssignmentSetting){
        Debug.log('assignmentOnPostUnomyMerge setMasterAccounts : '+setMasterAccounts);
        Debug.log('assignmentOnPostUnomyMerge accountAssignmentSetting : '+accountAssignmentSetting);        
        Map<String, RecordTypeInfo> mapAccountRecordTypesByName = Schema.SObjectType.Account.getRecordTypeInfosByName();
        Map<String, RecordTypeInfo> mapOpportunityRecordTypesByName = Schema.SObjectType.Opportunity.getRecordTypeInfosByName();
        Map<String, RecordTypeInfo> mapContactRecordTypesByName = Schema.SObjectType.Contact.getRecordTypeInfosByName();
        Set<String> setExcludedOpportunityStages = new Set<String>();        
        Set<String> setOwnerIds = new Set<String>();
        Set<String> setProfiles = new Set<String>();
        for(String ownerId : accountAssignmentSetting.get('owner')){
            setOwnerIds.add(String.valueOf(ownerId).trim().substring(0,15));
        }        
        for(String profileName : accountAssignmentSetting.get('profiles')){
            setProfiles.add(String.valueOf(profileName).trim().toLowerCase());
        }             
        if(Settings.get('ManageToursOpportunityStages')!= null){
            List<String> excludedOpportunityStagesSettings = (List<String>)JSON.deserialize(Settings.get('ManageToursOpportunityStages').Data__c,List<String>.class);
            for(String oppStage : excludedOpportunityStagesSettings){
                setExcludedOpportunityStages.add(oppStage.trim().toLowerCase());
            }
        }
        Map<Id,Account> mapMasterAccounts = new Map<Id,Account>([Select Id,RecordTypeId,RecordType.Name,OwnerId,Owner.Profile.Name,CreatedById,CreatedBy.Profile.Name,(Select Id,RecordTypeId,RecordType.Name,OwnerId From Contacts),(Select Id,StageName,RecordTypeId,RecordType.Name,OwnerId,Owner.Profile.Name,CreatedById,CreatedBy.Profile.Name,Total_Reservables_Selected__c From Opportunities Where StageName NOT IN :setExcludedOpportunityStages) FROM Account WHERE Id IN:setMasterAccounts]);
        Map<Id, SObject> mapRecordsToUpdate = new Map<Id, SObject>();
        for(Id accId : mapMasterAccounts.keySet()){
            //To change the Contact owner and record type.
            if(mapMasterAccounts.get(accId).Contacts != null && mapMasterAccounts.get(accId).Contacts.size()>0){
                for(Contact conRec : mapMasterAccounts.get(accId).Contacts){
                    if(mapMasterAccounts.get(accId).OwnerId!=conRec.OwnerId || mapAccountRecordTypesByName.get(mapMasterAccounts.get(accId).RecordType.Name)!= mapContactRecordTypesByName.get(conRec.RecordType.Name)){
                        conRec.OwnerId = (mapMasterAccounts.get(accId).OwnerId!=conRec.OwnerId) ? mapMasterAccounts.get(accId).OwnerId : conRec.OwnerId;
                        conRec.RecordTypeId = (mapAccountRecordTypesByName.get(mapMasterAccounts.get(accId).RecordType.Name)!= mapContactRecordTypesByName.get(conRec.RecordType.Name)) ? mapContactRecordTypesByName.get(mapMasterAccounts.get(accId).RecordType.Name).getRecordTypeId() : conRec.RecordTypeId;                    
                        mapRecordsToUpdate.put(conRec.Id, conRec);
                    }
                }               
            }
            //To change the Opportunity owner and record type.
            if(mapMasterAccounts.get(accId).Opportunities != null && mapMasterAccounts.get(accId).Opportunities.size()>0){
                for(Opportunity oppRec : mapMasterAccounts.get(accId).Opportunities){
                    Boolean flag = false;
                    if(mapAccountRecordTypesByName.get(mapMasterAccounts.get(accId).RecordType.Name)!= mapOpportunityRecordTypesByName.get(oppRec.RecordType.Name)){
                        if(mapOpportunityRecordTypesByName.containsKey(mapMasterAccounts.get(accId).RecordType.Name)){
                            oppRec.RecordTypeId = (mapAccountRecordTypesByName.get(mapMasterAccounts.get(accId).RecordType.Name)!= mapOpportunityRecordTypesByName.get(oppRec.RecordType.Name)) ? mapOpportunityRecordTypesByName.get(mapMasterAccounts.get(accId).RecordType.Name).getRecordTypeId() : oppRec.RecordTypeId;                        
                            flag = true;
                        }
                    }
                    if(mapMasterAccounts.get(accId).OwnerId!=oppRec.OwnerId && (setOwnerIds.contains(String.valueOf(oppRec.OwnerId).substring(0,15)) || setOwnerIds.contains(String.valueOf(oppRec.CreatedById).substring(0,15)) || setProfiles.contains(String.valueOf(oppRec.Owner.Profile.Name).toLowerCase()) || setProfiles.contains(String.valueOf(oppRec.CreatedBy.Profile.Name).toLowerCase()))){
                        oppRec.OwnerId = mapMasterAccounts.get(accId).OwnerId;                      
                        flag = true;
                    }
                    if(flag){
                        mapRecordsToUpdate.put(oppRec.Id, oppRec);
                    }
                }
            }
        }
        Debug.log('mapRecordsToUpdate : '+mapRecordsToUpdate);
        if(!mapRecordsToUpdate.isEmpty()){
            update mapRecordsToUpdate.values();
        }
    }
    
    /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   Naming Convention for Account Records.
                                For Sales Account==> Org Account Name:suffix:Current Account Nickname.
                                For org Account==>  Org Account Name:suffix.    
        Issue No.           :   ST-1773  
        Last Modified Date  :   17 January 2017
        Last Modified By    :   Krishana Tupe
    **************************************************************************************************************************************  
        Issue No.           :   ST-2079
        Last Modified By    :   Milanjeet Singh
        Last Modified Date  :   8 March 2018
    **************************************************************************************************************************************/
    public static List<Account> updateAccountName(List<SObject> lstNewItems, Map<Id, SObject> mapNewItems, List<SObject> lstOldItems, Map<Id, SObject> mapOldItems){
        Map<String, String> mapAccountNameSuffixSetting;  
        Setting__c objAccountHierarchySuffixSetting = Settings.get('Account Hierarchy : Naming Convention');
        if(objAccountHierarchySuffixSetting != null){
            mapAccountNameSuffixSetting= (Map<String, String>)JSON.deserialize(objAccountHierarchySuffixSetting.Data__c, Map<String, String>.class);
        }
        for(Account objAccount : (List<Account>)lstNewItems){  
            if(objAccount.Account_Type__c != null && objAccount.Account_Type__c.equalsIgnoreCase('sales')){
                String strNamingConvention = mapAccountNameSuffixSetting.get(objAccount.Account_Type__c);
                List<String> lstExpressions = getExpressions(strNamingConvention);                
                for(String strExpression : lstExpressions){
                    strNamingConvention = strNamingConvention.replace('{{' + strExpression + '}}', objAccount.get(strExpression) != null ? String.valueOf(objAccount.get(strExpression)) : '');
                }
                objAccount.Name = strNamingConvention;
            } 
        }
        return lstNewItems;
    }
    
    /************************************************************************************************************************************
        Author              :   Ajaysinh Chauhan
        Description         :   This method is used to get the expression for generate naming convension for account hierarchy.
        Last Modified Date  :   05 July 2016
        Last Modified By    :   Ajaysinh Chauhan
    **************************************************************************************************************************************/   
   
    public static List<String> getExpressions(String strExpression){
        List<String> lstExpressions = new List<String>();
        while(strExpression.substringBetween('{{', '}}')!=null){
            String exp = strExpression.substringBetween('{{', '}}');
            lstExpressions.add(exp);
            strExpression = strExpression.replace('{{'+exp+'}}','');
        }
        return lstExpressions;
    }
       /************************************************************************************************************************************
        Author              :   Milanjeet Singh
        Issue               :   ST-2080
        Description         :   This method is used to avoid Duplicate nickname under perticular org.
        Last Modified Date  :   07 March 2018    
        Last Modified By    :   Milanjeet Singh 
    **************************************************************************************************************************************/
    public static void checkDuplicateNicknameInOrg(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems){
        Debug.Log('<====listNewItems===>'+listNewItems);
        Set<String> setNickNames= new Set<String>();
        Map<String,List<String>> mapExistingOrgNicknames = new Map<String,List<String>>();
        Set<String> setOrgId = new Set<String>();
        for(Account acc : (List<Account>)listNewItems) {
            if(acc.Account_Type__c !=null && acc.Account_Type__c.equalsIgnoreCase('sales')){
                if(Trigger.isInsert || (Trigger.IsUpdate && mapOldItems.get(acc.Id) != null && ((Account)mapOldItems.get(acc.Id)).Nickname__c != null && !((Account)mapOldItems.get(acc.Id)).Nickname__c.equalsIgnoreCase(acc.Nickname__c))){
                    setNickNames.add(acc.Nickname__c);
                    if(acc.Parent_Org_Id__c!=null){
                        setOrgId.add(acc.Parent_Org_Id__c);    
                    }
                }
            }   
        }
        if(setNickNames.contains('null'))
            setNickNames.remove('null');
        if(setOrgId.contains('null'))
            setOrgId.remove('null');
        if(setNickNames.size()>0 && setOrgId.size()>0){
            for(Account account : [Select Id,Nickname__c,Parent_Org_Id__c from Account where (Parent_Org_Id__c IN:setOrgId AND Account_Type__c ='Sales') AND Nickname__c IN:setNickNames]){
                if(!mapExistingOrgNicknames.isEmpty() && mapExistingOrgNicknames.containsKey(account.Parent_Org_Id__c)){
                    mapExistingOrgNicknames.get(account.Parent_Org_Id__c).add(account.Nickname__c);
                }else{
                    mapExistingOrgNicknames.put(account.Parent_Org_Id__c,new List<String>{account.Nickname__c});
                }
            }
            debug.Log('mapExistingOrgNicknames :: '+mapExistingOrgNicknames);
            for(Account account : (List<Account>) listNewItems){
                if(account.Account_Type__c!=null && account.Account_Type__c.equalsIgnoreCase('sales')){
                    if(mapExistingOrgNicknames.containsKey(account.Parent_Org_Id__c)){
                        account.Nickname__c.addError('Sales Account with same Nickname "'+account.Nickname__c+'" already exists under the organization. Please choose another nickname.');
                    }
                }
            }
        }
    }
    
    /************************************************************************************************************************************
        Author              :   Ajaysinh Chauhan
        Issue               :   -
        Description         :   This method will restrict the deletion of accounts having child accounts,contacts or opportunities except merging takes place.
        Last Modified Date  :   27 March 2018    
        Last Modified By    :   Ajaysinh Chauhan
    --------------------------------------------------------------------------------------------------------------------------------------
        Last Modified By    :   Milanjeet singh
        Last Modified Date  :   16 June 2018
        Issue No.           :   ST-2173 (Changed Name of the method from restrictAccountDeletionWithRelatedRecords TO deleteAccountValidations)
    **************************************************************************************************************************************/
    public static Map<Id,Account> mapGlobalAccounts;
    public static void deleteAccountValidations(List<SObject> listOldItems, Map<Id, SObject> mapOldItems){
        debug.Log('mapOldItems==>'+mapOldItems);
        List<Account> lstToReparentAccounts = new List<Account>();
        if(Trigger.isBefore){
            mapGlobalAccounts = new Map<Id,Account>([Select Id,Name,(Select Id From ChildAccounts limit 199),(Select Id From Contacts limit 1),(Select Id From Opportunities limit 1) From Account Where Id IN:mapOldItems.keySet()]);
            for(Account objAcc : (List<Account>)listOldItems){
                if(objAcc.ID_Status2__c == 'active'){
                    mapOldItems.get(objAcc.Id).addError('Active Accounts cannot be deleted or merged.');
                }
            } 
        }else if(Trigger.isAfter){
            Set<Id> setProfileIdsRestrictAccountDel;
            if(Settings.get('RestrictAccountDeletion') != null){
                setProfileIdsRestrictAccountDel = (Set<Id>)JSON.deserialize(Settings.get('RestrictAccountDeletion').Data__c,Set<Id>.class);
            }   
            for(Account objAccount:(List<Account>)listOldItems){
                if(objAccount.MasterRecordId == null){
                    if(setProfileIdsRestrictAccountDel != null && setProfileIdsRestrictAccountDel.size() > 0 && setProfileIdsRestrictAccountDel.contains(UserInfo.getProfileId())){
                        objAccount.addError('You do not have permission to delete the account');
                    }else if(mapGlobalAccounts!=null && mapGlobalAccounts.containsKey(objAccount.Id)){
                        if(!((mapGlobalAccounts.get(objAccount.Id).ChildAccounts==null || mapGlobalAccounts.get(objAccount.Id).ChildAccounts.size()==0) && (mapGlobalAccounts.get(objAccount.Id).Contacts==null || mapGlobalAccounts.get(objAccount.Id).Contacts.size()==0) && (mapGlobalAccounts.get(objAccount.Id).Opportunities==null || mapGlobalAccounts.get(objAccount.Id).Opportunities.size()==0))){
                            objAccount.addError('You can not delete Accounts having child Accounts, Contacts or Opportunities except while merging.');
                        }
                    }
                }           
            }
        }
    }
    /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Issue               :   ST-2182
        Description         :   This method will reparent child accounts when merging takes place.
        Last Modified Date  :   16 April 2018    
        Last Modified By    :   Krishana Tupe
    **************************************************************************************************************************************/
    public static void reparentChildAccounts(List<SObject> listOldItems, Map<Id, SObject> mapOldItems){
        List<Account> lstToReparentAccounts;
        if(Trigger.isBefore){
            if(mapGlobalAccounts==null){
                mapGlobalAccounts = new Map<Id,Account>([Select Id,Name,(Select Id From ChildAccounts limit 199),(Select Id From Contacts limit 1),(Select Id From Opportunities limit 1) From Account Where Id IN:mapOldItems.keySet()]);
            }               
        }else if(Trigger.isAfter){
            for(Account objAccount:(List<Account>)listOldItems){
                if(objAccount.MasterRecordId !=null && mapGlobalAccounts !=null && mapGlobalAccounts.get(objAccount.Id).ChildAccounts != null){
                    for(Account acc : mapGlobalAccounts.get(objAccount.Id).ChildAccounts){
                        if(lstToReparentAccounts == null){
                            lstToReparentAccounts  = new List<Account>();
                        }
                        acc.parentId = objAccount.MasterRecordId; 
                        lstToReparentAccounts.add(acc);
                    } 
                }
            }
            if(lstToReparentAccounts != null && lstToReparentAccounts.size()>0){
                Database.update(lstToReparentAccounts,false);
            }
        }
    }
    /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is used to prevent duplicate org creation and duplicate org Name updation
        Created Date        :   12 April 2018
        Last Modified By    :   Krishana Tupe
        Modified by         :   Dipak Pawar on 23 April 2018 for ST-2266
    **************************************************************************************************************************************/     
    public static void retrictDuplicateOrgName(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems){
        Map<String,Account> mapAccountsByName = new Map<String,Account> ();
        List<Account> lstExistingAccounts = new List<Account>();
        Map<string,Account> mapExistingAccountsByName = new Map<string,Account>();
        
        for(Account objAccount :(List<Account>)listNewItems ){
            if((Trigger.isInsert && String.isNotBlank(objAccount.Name) && objAccount.Account_Type__c=='Org')|| (Trigger.isUpdate && String.isNotBlank(objAccount.Name) && objAccount.Account_Type__c=='Org' && mapOldItems.containsKey(objAccount.Id) && (objAccount.Name != mapOldItems.get(objAccount.Id).get('Name') || mapOldItems.get(objAccount.Id).get('Account_Type__c') != 'Org'))){
                if(mapAccountsByName.containsKey(objAccount.Name.toLowerCase())){
                    objAccount.Name.addError(objAccount.Name +' Organization already exists with the same name');
                }else{
                    mapAccountsByName.put(objAccount.Name.toLowerCase(), objAccount);   
                }  
            }
        }
        if(mapAccountsByName != null && mapAccountsByName.values().size() > 0){
            lstExistingAccounts = [Select Id,Name From Account Where Name IN : mapAccountsByName.keySet() AND Account_Type__c='Org']; 
            if(lstExistingAccounts != null){
                for(Account objAccount : lstExistingAccounts){
                    mapExistingAccountsByName.put(objAccount.Name.toLowerCase(),objAccount);  
                } 
            }
        }
        if(mapExistingAccountsByName != null){
            for(Account objAccount : (List<Account>)listNewItems ){
                if((Trigger.isInsert && objAccount.Account_Type__c == 'Org' && String.isNotBlank(objAccount.Name))|| (Trigger.isUpdate && objAccount.Account_Type__c == 'Org' && String.isNotBlank(objAccount.Name) && mapOldItems.containsKey(objAccount.Id) && (objAccount.Name != mapOldItems.get(objAccount.Id).get('Name') || mapOldItems.get(objAccount.Id).get('Account_Type__c') != 'Org'))){
                    if(mapExistingAccountsByName.containsKey(objAccount.Name.toLowerCase()) && objAccount.Account_Type__c != null && String.valueOf(objAccount.Account_Type__c).equalsIgnoreCase('org')){                    
                        objAccount.Name.addError(objAccount.Name+' Organization already exists with the same name');
                    }  
                }
            }
        }
    }
    /************************************************************************************************************************************
        Author              :   Shobhit Gahlot
        Description         :   This method is use to update the the child records which have same parent_org_id
        Created Date        :   06 July 2018
        Issue No            :   ST-2609
    **************************************************************************************************************************************/  
    public static void updateHierarchyAccountAndOpportunityNameOnMerge(List<sObject> listOldItems, Map<Id, sObject> mapOldItems){
        List<Account> lstAccounts = new List<Account>();
        for(Account objAccount : (List<Account>)listOldItems){
            if(objAccount.MasterRecordId != null && objAccount.Account_Type__c != null){
                lstAccounts.add(objAccount);
            }
        }  
        if(lstAccounts.size() > 0){
            updateAccountAndOpportunityNameInFutureForMerge(JSON.serialize(lstAccounts));
        }
    }
    @future
    public static void updateAccountAndOpportunityNameInFutureForMerge(String stringMasterAccounts){
        List<Account> lstAccounts = (List<Account>)JSON.deserialize(stringMasterAccounts,List<Account>.class);
        Set<Id> setAccountIds = new Set<Id>();
        Set<String> setOrgAccountIds = new Set<String>();
        for(Account accRec : lstAccounts){
            if(accRec.MasterRecordId != null){
                if(accRec.Account_Type__c.toLowerCase() == 'org'){
                    setOrgAccountIds.add(string.valueOf(accRec.MasterRecordId).subString(0,15));
                    setAccountIds.add(accRec.MasterRecordId);
                }else if(accRec.Account_Type__c.toLowerCase() == 'sales'){
                    setAccountIds.add(accRec.MasterRecordId);
                }
            }else{
                if(accRec.Account_Type__c.toLowerCase() == 'org'){
                    setOrgAccountIds.add(string.valueOf(accRec.Id).subString(0,15));
                    setAccountIds.add(accRec.Id);
                }else if(accRec.Account_Type__c.toLowerCase() == 'sales'){
                    setAccountIds.add(accRec.Id);
                }
            }
            
        }
        Debug.log('setOrgAccountIds ::'+setOrgAccountIds);
        Debug.log('setAccountIds ::'+setAccountIds);
        List<Account> lstAccountsToUpdate = new List<Account>([SELECT Id, Name, Parent_Org_Id__c, Account_Type__c, Parent_Org_Name__c, Nickname__c,(SELECT Id, AccountId, Opportunity_Account_Name__c, CloseDate, No_of_Desks_unweighted__c, Name, RecordTypeId, Building__c, Building__r.Name, Geography__c, Geography__r.Name, Geography__r.City__c, Geography__r.State__c, Geography__r.Country__c, Type__c, Requirement_Quantity__c FROM Opportunities), (SELECT Id, Ultimate_Parent_Org__c, Parent_Account__c, Region_Name__c FROM Billing_Accounts__r) FROM Account WHERE Parent_Org_Id__c IN : setOrgAccountIds OR Parent_Org__c IN : setOrgAccountIds OR Id IN : setAccountIds]);
        List<Opportunity> lstOpportunitiesToUpdate = new List<Opportunity>();
        List<Billing_Account__c> lstBillingAccountsToUpdate = new List<Billing_Account__c>();
        for(Account objAccount : lstAccountsToUpdate){
            if(objAccount.Opportunities != null && objAccount.Opportunities.size() > 0){
                lstOpportunitiesToUpdate.addAll(objAccount.Opportunities);
            }
            if(objAccount.Billing_Accounts__r != null && objAccount.Billing_Accounts__r.size() > 0){
                lstBillingAccountsToUpdate.addAll(objAccount.Billing_Accounts__r);
            }
        }
        lstAccountsToUpdate = updateAccountName(lstAccountsToUpdate, null, null, null);
        update lstAccountsToUpdate;
        if(lstOpportunitiesToUpdate.size() > 0){
            opportunityTriggerHandler.updateOppName(lstOpportunitiesToUpdate,null,null,null);
            update lstOpportunitiesToUpdate;
        }
        if(lstBillingAccountsToUpdate.size() > 0){
            BillingAccountTriggerHandler.setUltimateParentToAccount(lstBillingAccountsToUpdate, null);
            Debug.Log('lstBillingAccountsToUpdate---'+lstBillingAccountsToUpdate);
            update lstBillingAccountsToUpdate;
        }
    }
    /************************************************************************************************************************************
        Author              :   Nikhil Mehta
        Description         :   This method restrict sales account to other org and update child records
        Created Date        :   12 July 2018
        Issue No            :   ST-2624,ST-2625
    **************************************************************************************************************************************/  
    public static void updateOnReparent(List<Account> lstNewAccounts,Map<Id,Account> mapNewAccounts,List<Account> lstOldAccounts,Map<Id,Account> mapOldAccounts){
        List<Account> lstAccountToUpdate = new List<Account>();
        User loggedInUser = Settings.getUserById(UserInfo.getUserId());        
        Setting__c reparentingBypassProfilesSetting = Settings.get('ReparentingBypassProfilesSettings'); 
        Map<String,Map<String,Set<String>>> mapExcludedProfiles;
        if(reparentingBypassProfilesSetting != null){
            mapExcludedProfiles = (Map<String,Map<String,Set<String>>>)JSON.deserialize(reparentingBypassProfilesSetting.Data__c.toLowerCase(),Map<String,Map<String,Set<String>>>.class);   
        } 
        if(mapExcludedProfiles != null && mapExcludedProfiles.get('salesaccountreparenting') != null && mapExcludedProfiles.get('salesaccountreparenting').get('excludedprofiles') != null && loggedInUser != null && String.isNotBlank(loggedInUser.ProfileId) && String.isNotBlank(loggedInUser.Profile.Name) && !mapExcludedProfiles.get('salesaccountreparenting').get('excludedprofiles').contains(String.valueOf(loggedInUser.Profile.Name).toLowerCase())){
            for(Account accRec : lstNewAccounts){               
                if(accRec.Account_Type__c != null && accRec.Account_Type__c.toLowerCase() =='sales' && mapOldAccounts.get(accRec.Id).ParentId != null && mapOldAccounts.get(accRec.Id).ParentId != accRec.ParentId && (mapOldAccounts.get(accRec.Id).Parent_Org_Id__c != accRec.Parent_Org_Id__c || mapOldAccounts.get(accRec.Id).Parent_Org__c != accRec.Parent_Org__c)){
                    accRec.ParentId.addError('Reparenting of Sales Account is not allowed outside the Organization.');
                }else if(accRec.Account_Type__c != null && accRec.Account_Type__c.toLowerCase() =='org' && mapOldAccounts.get(accRec.Id).ParentId != accRec.ParentId){
                    lstAccountToUpdate.add(accRec);
                }
            }   
        }else{
            for(Account accRec : lstNewAccounts){
                if(accRec.Account_Type__c != null  && mapOldAccounts.get(accRec.Id).ParentId != accRec.ParentId){
                    if(accRec.Parent_Org__c != null){
                        lstAccountToUpdate.add(new Account(Id=accRec.Parent_Org__c, Account_Type__c='Org'));
                    }
                    if(accRec.Parent_Org_Id__c != null){
                        lstAccountToUpdate.add(new Account(Id=accRec.Parent_Org_Id__c, Account_Type__c='Org'));
                    }
                    lstAccountToUpdate.add(accRec);
                }
            }
        }
        if(lstAccountToUpdate != null && lstAccountToUpdate.size()>0){
            updateAccountAndOpportunityNameInFutureForMerge(JSON.serialize(lstAccountToUpdate));
        }
    }
    
    /************************************************************************************************************************************
        Author              :   Pragalbha Mahajan
        Description         :   This method sends email to current and previous owners of account when account owner will be changed.
        Created Date        :   30 August 2018
        Issue No            :   ST-2696
    **************************************************************************************************************************************/
    public static void sendEmailOnOwnerChange(List<Account> listNewItems, Map<Id, Account> mapNewItems, List<Account> listOldItems, Map<Id, Account> mapOldItems){
        Set<Id> setAccountIds = new Set<Id>(); 
        for(Account objAccount: listNewItems){
            if(objAccount.OwnerId != mapOldItems.get(objAccount.Id).OwnerId){
                setAccountIds.add(objAccount.Id);
            }
        }
        if(setAccountIds.size() > 0){
            handleSendEmailOnOwnershipChange(setAccountIds, 'Email_on_Account_Owner_Change', mapNewItems, mapOldItems);	
        }
    }
    public static Map<Id, Opportunity> mapOpportunityWithOwner = new Map<Id, Opportunity>();
    /************************************************************************************************************************************
        Author              :   Pragalbha Mahajan
        Description         :   This method is used to store opportunity related to the account.
        Created Date        :   06 Oct 2018
        Issue No            :   ST-2696
    **************************************************************************************************************************************/
    public static void storeAccOpportunitiesForEmailAlert(List<Account> listNewItems, Map<Id, Account> mapNewItems, List<Account> listOldItems, Map<Id, Account> mapOldItems){
        Set<Id> setAccountIds = new Set<Id>();
        for(Account objAccount: (List<Account>)listNewItems){
            if(objAccount.OwnerId != mapOldItems.get(objAccount.Id).get('OwnerId')){  
                setAccountIds.add(objAccount.Id);
            }
        }
        if(setAccountIds.size()>0){
            if(mapOpportunityWithOwner == null){
                mapOpportunityWithOwner = new Map<Id, Opportunity>();
            }
            if(TriggerSettings.mappedField.Opportunity_SendEmailOnOwnerChange){
                for(Account accRec : [SELECT id,Name,OwnerId,(SELECT Id,Name,OwnerId FROM Opportunities) FROM Account WHERE Id IN: setAccountIds]){
                    for(Opportunity oppRec : accRec.Opportunities){
                        mapOpportunityWithOwner.put(oppRec.Id, oppRec);
                    }
                }
            }
        }
    }
    
    /************************************************************************************************************************************
        Author              :   Pragalbha Mahajan
        Description         :   This method sends email to current and previous owners of record when ownership will be changed.
        Created Date        :   09 Oct 2018
        Issue No            :   ST-2795
    **************************************************************************************************************************************/
    public static void handleSendEmailOnOwnershipChange(Set<Id> setIdsToSendNotification,String templateName, Map<Id, sObject> mapNewItems, Map<Id, sObject> mapOldItems){
        Settings.fetchAllUsers();
        Map<Id,User> mapUserById =  Settings.mapAllUsersById;
        Setting__c setting = Settings.get('APIUserContactInfo');
        Map<String, Object> apiUsermapData;
        if(setting != null){
            apiUsermapData = (Map<String,Object>)JSON.deserializeUntyped(setting.Data__c);
        }
        String apiUserEmail = String.valueOf(apiUsermapData.get('Email'));
        EmailTemplate emailTemplateOnOwnerChange = Settings.getEmailTemplateByDeveloperName(templateName);
        List<Messaging.SingleEmailMessage> allEmailToSend = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage objSingleMail;
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        List<Id> lstId = new List<Id>(setIdsToSendNotification);
        String objectType = String.valueOf(lstId[0].getSobjectType());
        for(Id recId : setIdsToSendNotification){ 
            sObject record = mapNewItems.get(recId);
            User oldUser, newUser;
            if(objectType.toLowerCase() == 'account'){
                oldUser = mapUserById.get(((Account)mapOldItems.get(record.Id)).OwnerId);
                newUser = mapUserById.get(((Account)record).OwnerId);
            }else if(objectType.toLowerCase() == 'opportunity'){
                if(AccountTriggerHandler.mapOpportunityWithOwner.size() > 0 && AccountTriggerHandler.mapOpportunityWithOwner.containsKey(recId)){
                    oldUser = mapUserById.get(AccountTriggerHandler.mapOpportunityWithOwner.get(recId).OwnerId);
                    mapOpportunityWithOwner.remove(recId);
                }else{
                    oldUser = mapUserById.get(((Opportunity)mapOldItems.get(recId)).OwnerId);
                }
                newUser = mapUserById.get(((Opportunity)mapNewItems.get(recId)).OwnerId);
            }
            if(oldUser != null && newUser != null){
                objSingleMail = new Messaging.SingleEmailMessage();
                if(newUser.Email == apiUserEmail && oldUser.IsActive){
                    objSingleMail.toAddresses = new List<String>(new Set<String>{oldUser.Email});
                }
                else if(oldUser.Email == apiUserEmail){
                    objSingleMail.toAddresses = new List<String>(new Set<String>{newUser.Email});
                }
                else if(newUser.Email != apiUserEmail && oldUser.Email != apiUserEmail){
                    objSingleMail.toAddresses = (oldUser.IsActive ? new List<String>(new Set<String>{newUser.Email, oldUser.Email}) : new List<String>(new Set<String>{newUser.Email}));
                }
                if(objSingleMail.toAddresses != null){
                    objSingleMail.setSubject(objectType+' Owner has been Changed');
                    String htmlBody = emailTemplateOnOwnerChange.Markup;
                    htmlBody = htmlBody.replace('{loggedUser}', mapUserById.get(UserInfo.getUserId()).Name);
                    if(record.Id!=null && objectType.toLowerCase()=='account'){
                        htmlBody = htmlBody.replace('{Account.Name}','<a href="' + baseUrl + '/'+record.Id+'">' + ((Account)record).Name + '</a>');
                    }else if(record.Id!=null && objectType.toLowerCase()=='opportunity'){
                        htmlBody = htmlBody.replace('{Opportunity.Name}','<a href="' + baseUrl + '/'+record.Id+'">' + ((Opportunity)record).Name + '</a>');
                    }
                    htmlBody = htmlBody.replace('{old'+objectType+'Owner}', oldUser.Name); 
                    htmlBody = htmlBody.replace('{new'+objectType+'Owner}', newUser.Name);
                    objSingleMail.htmlbody = htmlBody;
                    objSingleMail.setSaveAsActivity(false);
                }
            }
            if(objSingleMail.toAddresses != null){
                allEmailToSend.add(objSingleMail);
            }
        }
        if(allEmailToSend.size() > 0){  
            Messaging.SendEmailResult[] emailResults = Messaging.sendEmail(allEmailToSend);
        }  
    }
}