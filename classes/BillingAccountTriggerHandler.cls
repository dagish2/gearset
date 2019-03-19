/************************************************************************************************************************************
    Author      :   Prashant Mane
    Description :   This class contains business logic for BillingAccountTriggers

    History :
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                     DETAIL
    1           06 June 2018        Prashant Mane              Initial Developement
**************************************************************************************************************************************/
public with sharing class BillingAccountTriggerHandler extends ITriggerHandler{
    
    public BillingAccountTriggerHandler(){
        super('Billing_Account__c');    }
    
    /************************************************************************************************************************************
        Author              :   Prashant Mane
        Description         :   This method overrides before insert method from ITriggerHander which will control the execution flow.
        Last Modified Date  :   06 June 2018
        Last Modified By    :   Prashant Mane
	**************************************************************************************************************************************/
    public override void BeforeInsert(List<SObject> listNewItems){
        if(TriggerSettings.mappedField.Billing_Account_SetDefaultAccountOwner){
            setdefaultAccountOwner(listNewItems,null);
        }
        if(TriggerSettings.mappedField.Billing_Account_SetAccountPrimaryMember){
            setAccountPrimaryMember(listNewItems,null);
        }
        if(TriggerSettings.mappedField.Billing_Account_GenerateUUID){
            generateUUID(listNewItems);
        }
        if(TriggerSettings.mappedField.Billing_Account_mapParentAccount){
            mapParentAccount(listNewItems,null,null);
        }
        if(Triggersettings.mappedField.Billing_Account_SetUltimateParent){
            setUltimateParentToAccount(listNewItems,null);
        }
        if(Triggersettings.mappedField.Billing_Account_UpdateBillingAccountName){
            updateBillingAccountName(listNewItems,null);
        }
        if(Triggersettings.mappedField.Billing_Account_UpdateCleansedAccNameAndUnomyName){
            UpdateCleansedAccNameAndUnomyName(listNewItems,null,null,null);
        }
    }
   /************************************************************************************************************************************
        Author              :   Prashant Mane
        Description         :   This method overrides before update method from ITriggerHander which will control the execution flow.
        Last Modified Date  :   06 June 2018
        Last Modified By    :   Prashant Mane
	**************************************************************************************************************************************/
    public override void BeforeUpdate(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems){
       
        if(TriggerSettings.mappedField.Billing_Account_SetAccountPrimaryMember){
            setAccountPrimaryMember(listNewItems, mapNewItems);
        }
        if(TriggerSettings.mappedField.Billing_Account_mapParentAccount){
            mapParentAccount(listNewItems,(Map<Id, Billing_Account__c>)mapNewItems,(Map<Id, Billing_Account__c>)mapOldItems);
        }
        if(Triggersettings.mappedField.Billing_Account_SetUltimateParent){
            setUltimateParentToAccount(listNewItems,mapOldItems);
        }
        if(Triggersettings.mappedField.Billing_Account_UpdateBillingAccountName){
            updateBillingAccountName(listNewItems,mapOldItems);
        }
        if(Triggersettings.mappedField.Billing_Account_UpdateCleansedAccNameAndUnomyName){
            UpdateCleansedAccNameAndUnomyName(listNewItems,null,null,mapOldItems); 
        }
    }
   /************************************************************************************************************************************
        Author              :   Prashant Mane
        Description         :   This method overrides after insert method from ITriggerHander which will control the execution flow.
        Last Modified Date  :   06 June 2018
        Last Modified By    :   Prashant Mane
	**************************************************************************************************************************************/
    public override void AfterInsert(List<SObject> listNewItems, Map<Id, SObject> mapNewItems){
        if(Triggersettings.mappedField.Billing_Account_UpdateContactsWithoutAccountId){
            UpdateContactsWithoutAccountId(listNewItems,mapNewItems,null,null); 
        }
        
        lstContactToUpdateAccount.clear();
        mapPrimaryIdWithOrg.clear();
    }
    
   /************************************************************************************************************************************
        Author              :   Prashant Mane
        Description         :   This method overrides after update method from ITriggerHander which will control the execution flow.
        Last Modified Date  :   06 June 2018
        Last Modified By    :   Prashant Mane
	**************************************************************************************************************************************/
    public override void AfterUpdate(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems){
        if(Triggersettings.mappedField.Billing_Account_changeChildRecordsParent){
            changeChildRecordsParent((List<Billing_Account__c>)listNewItems,mapNewItems,mapOldItems);  
        }
		if(Triggersettings.mappedField.Billing_Account_UpdateContactsWithoutAccountId){
            UpdateContactsWithoutAccountId(listNewItems,mapNewItems,listOldItems,mapOldItems); 
        }
        lstContactToUpdateAccount.clear();
        mapPrimaryIdWithOrg.clear();
    }
    
    /*****************************************************************************************************************************************
        Author              :   Prashant Mane
        Description         :   This method is used to set default Owner to susie
        Last Modified Date  :   06 June 2018    
        Last Modified By    :   Prashant Mane
    *****************************************************************************************************************************************/
     public static void setdefaultAccountOwner(List<SObject> listNewItems, Map<Id, SObject> mapNewItems) {
        Set<Id> accsToProcessIds;
         Setting__c APIUserContactInfo = new Setting__c();
         APIUserContactInfo = Settings.get('APIUserContactInfo'); 
         BillingAccountTriggerHandler.APIUserSetting settingData = new BillingAccountTriggerHandler.APIUserSetting();
         if(APIUserContactInfo != null){
             settingData = (APIUserSetting)JSON.deserialize(APIUserContactInfo.Data__c, APIUserSetting.class);
         }
        for(Billing_Account__c billAcc : (List<Billing_Account__c>)listNewItems){
            if(!string.isBlank(billAcc.OwnerId) && String.valueOf(billAcc.OwnerId) != settingData.UserId){
                billAcc.OwnerId = settingData.UserId;
            }
        }
    }
    /************************************************************************************************************************************************************
        Author              :   Prashant Mane
        Description         :   This method is used to set primary member of Account
        Last Modified Date  :   06 June 2018    
        Last Modified By    :   Prashant Mane
    *************************************************************************************************************************************************************/
    public static void setAccountPrimaryMember(List<SObject> listNewItems, Map<Id, SObject> mapNewItems) {
        Set<Id> accsToProcessIds;
        for(Billing_Account__c billAcc : (List<Billing_Account__c>)listNewItems){
            if(string.isBlank(billAcc.Primary_Member__c)){
                if(accsToProcessIds==null){
                   accsToProcessIds = new Set<Id>() ;
                }
                accsToProcessIds.add(billAcc.Id);
            }
        }
        Debug.Log('accsToProcessIds==>'+accsToProcessIds);
        //Get Bill Accounts and first contacts
        if(accsToProcessIds != null && !accsToProcessIds.isEmpty()){
            List<Billing_Account__c> billAccsToUpdate = [SELECT Id,(SELECT Id FROM Contacts__r ORDER BY CreatedDate LIMIT 1) 
                                                         FROM Billing_Account__c WHERE Id IN :accsToProcessIds];               
            for(Billing_Account__c billAcc : billAccsToUpdate){
                if(billAcc.Contacts__r.size() > 0){
                    Billing_Account__c triggerAcc = (Billing_Account__c)mapNewItems.get(billAcc.Id);
                    triggerAcc.Primary_Member__c = billAcc.Contacts__r[0].Id;
                }       
            }
        }
    }
    
    /************************************************************************************************************************************************************
        Author              :   Prashant Mane
        Description         :   This method is used to update cleansed account name annd Cleansed Unomy Company Name
        Last Modified Date  :   06 June 2018    
        Last Modified By    :   Prashant Mane
    *************************************************************************************************************************************************************/
    public static void UpdateCleansedAccNameAndUnomyName(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems){
        String accName,unomyName;
        for(Billing_Account__c billAcc:(List<Billing_Account__c>) listNewItems){
            if(billAcc.Name!=null){
                accName = billAcc.Name;
                String cleansedAccName  = OrganizationHelper.getCleansedName(accName);
                billAcc.Cleansed_Account_Name__c = cleansedAccName;
            }                               
        }
        if(Trigger.IsUpdate){           
            for(Billing_Account__c billAcc:(List<Billing_Account__c>)listNewItems){
                Billing_Account__c oldAccount = (Billing_Account__c)mapOldItems.get(billAcc.Id);
                if(billAcc.Unomy_Company_Name__c != oldAccount.Unomy_Company_Name__c){
                    if(billAcc.Unomy_Company_Name__c!=null){
                        unomyName = billAcc.Unomy_Company_Name__c;
                        String cleansedUnomyAccName  = OrganizationHelper.getCleansedName(unomyName);
                        billAcc.Cleansed_Unomy_Company_Name__c = cleansedUnomyAccName;
                    }
                }               
            }   
        } 
    } 
    
    /************************************************************************************************************************************************************
        Author              :   Prashant Mane
        Description         :   This method is used to generate uuid fir bill type of account.
        Last Modified Date  :   06 June 2018    
        Last Modified By    :   Prashant Mane
    *************************************************************************************************************************************************************/
    public static void generateUUID(List<sObject> listNewItems) {
        for (Billing_Account__c billAcc : (List<Billing_Account__c>)listNewItems) {                
            if ((String.isBlank(billAcc.UUID__c) && (billAcc.Lead_Source__c == null || !billAcc.Lead_Source__c.equalsIgnoreCase('Id')))){
                billAcc.UUID__c = UUIDHandler.generateVersion4();                       
            }                    
        }                 
    }
    
    /************************************************************************************************************************************************************
        Author              :   Shobhit Gahlot
        Description         :   This method is used to map the parent account Id by finding org.
        Last Modified Date  :   17 August 2018    
        Issue No			:	ST-2706
    *************************************************************************************************************************************************************/
    public static void mapParentAccount(List<Billing_Account__c> listNewItems,Map<Id, Billing_Account__c> mapNewItems, Map<Id, Billing_Account__c> mapOldItems){
        findBillAccountsAndContactsToUpdate(listNewItems, mapOldItems);
        if(mapPrimaryIdWithOrg.size() > 0){
            for(Billing_Account__c billAccountRecord : listNewItems){
                if(String.isNotBlank(billAccountRecord.Primary_Member__c) && String.isBlank(billAccountRecord.Parent_Account__c) && mapPrimaryIdWithOrg.get(billAccountRecord.Primary_Member__c) != null){
                    billAccountRecord.Parent_Account__c = mapPrimaryIdWithOrg.get(billAccountRecord.Primary_Member__c);
                }
            }
        }
    }
    
    static List<Contact> lstContactToUpdateAccount = new List<Contact>();
    static Map<Id,Id> mapPrimaryIdWithOrg = new Map<Id,Id>();
    public static void findBillAccountsAndContactsToUpdate(List<Billing_Account__c> listNewItems, Map<Id, Billing_Account__c> mapOldItems){
        Map<Id,Billing_Account__c> mapContactWithBillingAccounts = new Map<Id,Billing_Account__c>();
        for(Billing_Account__c billAccountRecord : listNewItems){
            if(String.isNotBlank(billAccountRecord.Primary_Member__c) && String.isBlank(billAccountRecord.Parent_Account__c)){
                mapContactWithBillingAccounts.put(billAccountRecord.Primary_Member__c,billAccountRecord);
            }
        }
        
        List<Contact> lstContactToFingOrg = new List<Contact>();
        if(mapContactWithBillingAccounts.size() > 0){
            for(Contact contactRec : [SELECT Id,Email,Email_Domain__c,UUID__c,Account_Name__c,AccountId,FirstName,LastName,Name,Account.Parent_Org_Id__c,Account.ParentId,Company__c,Unomy_Company_ID__c,Unomy_Company_Name__c,Cleansed_Unomy_Company_Name__c,Account.Account_Type__c,Cleansed_Company_Name__c,Billing_Account__c,Billing_Account_Name__c FROM Contact WHERE Id IN : mapContactWithBillingAccounts.keyset()]){
                if(String.isBlank(contactRec.AccountId)){
                    lstContactToUpdateAccount.add(contactRec);
                }
                lstContactToFingOrg.add(contactRec);
            }
        }
        debug.log('mapContactWithBillingAccounts: '+mapContactWithBillingAccounts);
        debug.log('lstContactToFingOrg: '+lstContactToFingOrg);
        if(lstContactToFingOrg.size() > 0){
            for(Contact contactRec :lstContactToFingOrg){
                String cleansedBillAccName;
                if(String.isNotBlank(contactRec.Billing_Account_Name__c)){
                    cleansedBillAccName = OrganizationHelper.getCleansedName(contactRec.Billing_Account_Name__c);
                }
                if(String.isBlank(contactRec.Company__c) && String.isBlank(contactRec.AccountId) && cleansedBillAccName != contactRec.Cleansed_Company_Name__c){
                    contactRec.put('Cleansed_Company_Name__c',(String.isNotBlank(cleansedBillAccName)) ? cleansedBillAccName : null);
                }
                if(String.isBlank(contactRec.Company__c)){
                    contactRec.put('Company__c',(String.isNotBlank(contactRec.Billing_Account_Name__c)) ? contactRec.Billing_Account_Name__c:mapContactWithBillingAccounts.get(contactRec.Id).Name);
                }
            }
            Debug.log('lstContactToFingOrg ::'+lstContactToFingOrg);
            mapPrimaryIdWithOrg = OrganizationHelper.findOrCreateRelatedOrg(lstContactToFingOrg);
        }
    }
    /************************************************************************************************************************************************************
        Author              :   Prashant Mane
        Description         :   This method is used to generate Ultimate Parent Account for a billing Account.
        Last Modified Date  :   19 June 2018    
        Last Modified By    :   Prashant Mane
    *************************************************************************************************************************************************************/
    public static void setUltimateParentToAccount(List<SObject> listNewItems,Map<Id, SObject> mapOldItems) {
        Debug.log('setUltimateParentToAccount listNewItems==>'+listNewItems);
        Debug.log('setUltimateParentToAccount mapOldItems==>'+mapOldItems);
        Set<Id> accsToProcessIds = new Set<Id>();
        for(Billing_Account__c billAcc : (List<Billing_Account__c>)listNewItems){            
            if(String.isNotBlank(billAcc.Parent_Account__c) && (mapOldItems==null || (mapOldItems!=null && billAcc.Parent_Account__c != mapOldItems.get(billAcc.Id).get('Parent_Account__c'))) ){
                accsToProcessIds.add(billAcc.Parent_Account__c);
            }
        }
        if(accsToProcessIds !=null  && accsToProcessIds.size()>0){
            List<Billing_Account__c> lstBillingAccount = new List<Billing_Account__c>();
            Map<Id,Account> mapUltimateParentIds = OrganizationHelper.getUltimateParents(accsToProcessIds,new List<String>{'Name'});  
            Debug.log('mapUltimateParentIds===>'+mapUltimateParentIds);
            if(mapUltimateParentIds !=null && mapUltimateParentIds.size()>0){
                for(Billing_Account__c billAcc : (List<Billing_Account__c>)listNewItems){
                    if(mapUltimateParentIds.get(billAcc.Parent_Account__c) != null){
                        billAcc.Ultimate_Parent_Org__c = mapUltimateParentIds.get(billAcc.Parent_Account__c).Id;
                        Debug.Log('billAccbillAcc'+billAcc); 
                    }
                }
            }
        }
    }
    /************************************************************************************************************************************************************
        Author              :   Prashant Mane
        Description         :   This method is used to generate Ultimate Parent Account for a billing Account.
        Last Modified Date  :   19 June 2018    
        Last Modified By    :   Prashant Mane
    *************************************************************************************************************************************************************/ 
    public static void updateBillingAccountName(List<SObject> listNewItems,Map<Id, SObject> mapOldItems) {
        Debug.Log('updateBillingAccountName listNewItems===>'+listNewItems);      
        Debug.Log('updateBillingAccountName mapOldItems===>'+mapOldItems);
        Integer count = 1;
        Set<Id> setParentIds = new Set<Id>();
        for(Billing_Account__c billAcc : (List<Billing_Account__c>) listNewItems){
            if((String.isNotBlank(billAcc.Parent_Account__c) && mapOldItems==null) || (String.isNotBlank(billAcc.Parent_Account__c) && mapOldItems !=null /*&& mapOldItems.get(billAcc.Id).get('Region_Name__c') == null*/ && billAcc.Region_Name__c != null)){
                Debug.Log('billAcc.Ultimate_Parent_Org__c====>'+billAcc.Ultimate_Parent_Org__c);
                if(String.isNotBlank(billAcc.Ultimate_Parent_Org__c)){
                    setParentIds.add(billAcc.Ultimate_Parent_Org__c);
                }              
            }
        }
        Debug.Log('setParentIds===>'+setParentIds);
        if(setParentIds != null && setParentIds.size()>0){  
            List<Billing_Account__c> lstBillAcc=[Select Id, Name,Parent_Account__r.Parent_Org_Name__c,Conventional_Name__c,Region_Name__c,Ultimate_Parent_Org__c From Billing_Account__c where Ultimate_Parent_Org__c IN:setParentIds];
            Map<Id,Map<String,String>> mapAccountData = new Map<Id,Map<String,String>>();
            if(lstBillAcc!=null && lstBillAcc.size()>0){
                for(Billing_Account__c billAcc:lstBillAcc){
                    Map<String,String> temp = new Map<String,String>();
                    if(mapAccountData.get(billAcc.Ultimate_Parent_Org__c)!=null){
                        temp = mapAccountData.get(billAcc.Ultimate_Parent_Org__c);
                        temp.put('Count',String.ValueOf(Integer.valueOf(temp.get('Count'))+1));
                    }else{
                        temp.put('OrgName',billAcc.Parent_Account__r.Parent_Org_Name__c);
                        temp.put('Count','0'); 
                    }
                    mapAccountData.put(billAcc.Ultimate_Parent_Org__c,temp);  
                }
            }
            Debug.log('mapAccountData'+mapAccountData);
            List<Billing_Account__c> lstBilltoUpdate = new List<Billing_Account__c>();
            for(Billing_Account__c billAccount : (List<Billing_Account__c>) listNewItems){
                if(mapAccountData !=null && !mapAccountData.isEmpty() && mapAccountData.containsKey(billAccount.Ultimate_Parent_Org__c)){                                        
                    String dummyName = String.isNotBlank(billAccount.Region_Name__c) ? billAccount.Region_Name__c : '';
                    Debug.Log('dummyName'+dummyName);
                    Debug.Log('mapAccountData.get(billAccount.Ultimate_Parent_Org__c)'+mapAccountData.get(billAccount.Ultimate_Parent_Org__c));
                    Debug.Log('123'+mapAccountData.get(billAccount.Ultimate_Parent_Org__c).get('OrgName'));
                    billAccount.Conventional_Name__c = (mapAccountData.get(billAccount.Ultimate_Parent_Org__c).get('OrgName')!=null ? mapAccountData.get(billAccount.Ultimate_Parent_Org__c).get('OrgName') : '') +' '+ dummyName +' ' + String.valueOf(Integer.valueOf(mapAccountData.get(billAccount.Ultimate_Parent_Org__c).get('Count'))+1);
                    Debug.Log('billAccount.Conventional_Name__c===>'+billAccount.Conventional_Name__c);
                    Map<String,String> temp = mapAccountData.get(billAccount.Ultimate_Parent_Org__c);
                    temp.put('Count',String.valueOf(Integer.valueOf(temp.get('Count'))+1));
                }else {
                    //String dummyName = String.isNotBlank(billAccount.Region_Name__c) ? billAccount.Region_Name__c : '';
                    //billAccount.Conventional_Name__c =  dummyName +' ' + String.valueOf(Integer.valueOf(mapAccountData.get(billAccount.Ultimate_Parent_Org__c).get('Count'))+1);
                    Debug.log('billAccount else ::'+billAccount);
                    Map<String,String> temp = new Map<String,String>();
                    temp.put('Count','1');
                    mapAccountData.put(billAccount.Ultimate_Parent_Org__c,temp);  
                } 
            }
        }
    }
    
    /************************************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is used update Billing Account child records Opportunities and Contacts parent Account Lookup.
        Created Date  		:   29 June 201
    *************************************************************************************************************************************************************/
    Static Map<Id,Set<Id>> mapContactsWithBillAccounts;                
    public static void changeChildRecordsParent(List<Billing_Account__c> listNewItems,Map<Id, SObject> mapNewItems,Map<Id, SObject> mapOldItems){
        List<sobject> lstRecordsToUpadate;       
        Set<Id> setBillAccountIds = new Set<Id>();
        Set<Id> setPrimaryMemberIds = new Set<Id>();
        Debug.log('listNewItems changeChildRecordsParent=>'+listNewItems);
        for(Billing_Account__c billAcc : listNewItems){           
            if(mapOldItems.get(billAcc.Id).get('Parent_Account__c') != null && billAcc.Parent_Account__c != mapOldItems.get(billAcc.Id).get('Parent_Account__c')){
                setBillAccountIds.add(billAcc.Id);  
                if(String.isNotBlank(billAcc.Primary_Member__c)){
                    setPrimaryMemberIds.add(billAcc.Primary_Member__c);
                }
            }
        }
        Debug.log('setBillAccountIds==>'+setBillAccountIds);
        Debug.log('setPrimaryMemberIds==>'+setPrimaryMemberIds);
        Debug.log('mapOldItems==>'+mapOldItems);
        if(setBillAccountIds != null && setBillAccountIds.size() > 0){
            User loggedInUser = Settings.getUserById(UserInfo.getUserId());
            Setting__c reparentingBypassProfilesSetting = Settings.get('ReparentingBypassProfilesSettings'); 
            Map<String,Map<String,Set<String>>> mapExcludedProfiles;
            if(reparentingBypassProfilesSetting != null){
                mapExcludedProfiles = (Map<String,Map<String,Set<String>>>)JSON.deserialize(reparentingBypassProfilesSetting.Data__c.toLowerCase(),Map<String,Map<String,Set<String>>>.class);   
            }       
            Debug.log('mapExcludedProfiles==>'+mapExcludedProfiles);
            if(mapExcludedProfiles != null && mapExcludedProfiles.get('billingaccountreparenting').get('excludedprofiles') !=null && !mapExcludedProfiles.get('billingaccountreparenting').get('excludedprofiles').contains(String.valueOf(loggedInUser.Profile.Name).toLowerCase())){
                List<Billing_Account__c> lstBillingAccounts = [Select Id,Name,Parent_Account__c,Primary_Member__c,Primary_Member__r.Name,Ultimate_Parent_Org__c,(Select Id,Name,AccountId From Contacts__r),(Select Id,Name,AccountId From Opportunities__r LIMIT 2) FROM Billing_Account__c WHERE Id IN : setBillAccountIds];                
                for(Billing_Account__c billAcc : lstBillingAccounts){
                    if(billAcc.getSobjects('Contacts__r') != null && billAcc.getSobjects('Contacts__r').size()>0){
                        Map<Id,Contact> mapContacts = new Map<Id,Contact>((List<Contact>)billAcc.getSobjects('Contacts__r'));                        
                        setPrimaryMemberIds.addAll(mapContacts.keySet());
                    }
                }
                Debug.log('setPrimaryMemberIds==>'+setPrimaryMemberIds);
                if(!setPrimaryMemberIds.isEmpty() && setPrimaryMemberIds.size()>0){
                    mapContactsWithBillAccounts = new Map<Id,Set<Id>>();
                    if(lstContactToUpdateAccount.Size() == 0){
                        lstContactToUpdateAccount = [Select Id,Name,Billing_Account__c From Contact Where Id In :setPrimaryMemberIds AND Billing_Account__c != null];
                    }
                    for(Contact con : lstContactToUpdateAccount){
                        if(con.Billing_Account__c != null){
                            if(mapContactsWithBillAccounts.containsKey(con.Id)){
                                Set<Id> setTempBillAccounts = mapContactsWithBillAccounts.get(con.Id);                            
                                setTempBillAccounts.add(con.Billing_Account__c);
                                mapContactsWithBillAccounts.put(con.Id,setTempBillAccounts);                                                     
                            }else{
                                mapContactsWithBillAccounts.put(con.Id,new Set<Id>{con.Billing_Account__c});
                            }   
                        }
                    }                                         
                    for(Billing_Account__c billAcc : [Select Id,Name,Parent_Account__c,Primary_Member__c,Primary_Member__r.Name,Ultimate_Parent_Org__c FROM Billing_Account__c WHERE Primary_Member__c IN : setPrimaryMemberIds]){
                        if(mapContactsWithBillAccounts.containsKey(billAcc.Primary_Member__c)){
                            Set<Id> setTempBillAccounts = mapContactsWithBillAccounts.get(billAcc.Primary_Member__c);                            
                            setTempBillAccounts.add(billAcc.Id);
                            mapContactsWithBillAccounts.put(billAcc.Primary_Member__c,setTempBillAccounts);                                                     
                        }else{
                            mapContactsWithBillAccounts.put(billAcc.Primary_Member__c,new Set<Id>{billAcc.Id});
                        }  
                    }  
                }
                Debug.log('mapContactsWithBillAccounts==>'+mapContactsWithBillAccounts);                
                for(Billing_Account__c billAcc : lstBillingAccounts){
                    Boolean isReparentRecords = false;
                    if(billAcc.getsObjects('Opportunities__r') == null){                        
                        if(billAcc.Ultimate_Parent_Org__c == mapOldItems.get(billAcc.Id).get('Ultimate_Parent_Org__c')){                            
                            isReparentRecords = true;
                        }else if(billAcc.Ultimate_Parent_Org__c != mapOldItems.get(billAcc.Id).get('Ultimate_Parent_Org__c')){
                            if(mapContactsWithBillAccounts != null && mapContactsWithBillAccounts.containsKey(billAcc.Primary_Member__c) && mapContactsWithBillAccounts.get(billAcc.Primary_Member__c).size()>1){                                
                                mapNewItems.get(billAcc.Id).addError('You cannot reparent the billing account outside of Org hierarchy as '+billAcc.Primary_Member__r.Name+'  is a Primary member or Member of another Billing Account :'+mapContactsWithBillAccounts.get(billAcc.Primary_Member__c));  
                            }else{
                                isReparentRecords = true; 
                            }
                        }                        
                    }else if(billAcc.getsObjects('Opportunities__r') != null){
                        if(billAcc.Ultimate_Parent_Org__c == mapOldItems.get(billAcc.Id).get('Ultimate_Parent_Org__c')){                            
                            isReparentRecords = true;
                        }else if(billAcc.Ultimate_Parent_Org__c != mapOldItems.get(billAcc.Id).get('Ultimate_Parent_Org__c')){
                            mapNewItems.get(billAcc.Id).addError('You cannot reparent the billing account outside the Org if Opportunity is present on it.');                             
                        }
                    }                
                    if(isReparentRecords){                      
                        if(billAcc.getsObjects('Contacts__r') != null && billAcc.getsObjects('Contacts__r').size()>0){
                            validateMemberRecords(billAcc,billAcc.getsObjects('Contacts__r'),mapNewItems,mapOldItems); 
                        }  
                    }
                }                
                Debug.log('lstRecordsToUpadate ==>'+lstRecordsToUpadate);                
            } 
        }
    }
    
   /************************************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is used update Billing Account child records Opportunities and Contacts parent Account Lookup.
        Created Date  		:   29 June 2018
    *************************************************************************************************************************************************************/
    public static void validateMemberRecords(Billing_Account__c billAcc , List<sObject> lstChildRecords,Map<Id,sObject> mapNewItems,Map<Id,sObject> mapOldItems){
        List<sobject> lstRecordsToUpdate = new List<sObject>(); 
        Debug.log('mapContactsWithBillAccounts==>'+mapContactsWithBillAccounts);
        for(sObject objChildRecord : lstChildRecords){ 
            if(objChildRecord.getSObjectType().getDescribe().getName().equalsIgnoreCase('Contact')){
                if(billAcc.Ultimate_Parent_Org__c != mapOldItems.get(billAcc.Id).get('Ultimate_Parent_Org__c') && mapContactsWithBillAccounts != null && mapContactsWithBillAccounts.containsKey(String.valueOf(objChildRecord.get('Id'))) && mapContactsWithBillAccounts.get(String.valueOf(objChildRecord.get('Id'))).size()>1){                                
                    mapNewItems.get(billAcc.Id).addError('You cannot reparent the billing account outside of Org hierarchy as '+objChildRecord.get('Name')+'  is a Primary member or Member of another Billing Account :'+mapContactsWithBillAccounts.get(String.valueOf(objChildRecord.get('Id'))));  
                }              
            }
        }
    }
    
    /************************************************************************************************************************************************************
        Author              :   Shobhit Gahlot
        Description         :   This method is used to map the parent account Id by finding org.
        Last Modified Date  :   17 August 2018    
        Issue No			:	ST-2706
    *************************************************************************************************************************************************************/
    public static void UpdateContactsWithoutAccountId(List<Billing_Account__c> listNewItems,Map<Id, SObject> mapNewItems, List<Billing_Account__c> listOldItems,Map<Id, SObject> mapOldItems){
        List<Contact> lstContacts = new List<Contact>();
        if(lstContactToUpdateAccount.Size() == 0){
            findBillAccountsAndContactsToUpdate(listNewItems, (Map<Id, Billing_Account__c>)mapOldItems);
        }
        
        for(contact contactRecord : lstContactToUpdateAccount){
            lstContacts.add(new Contact(Id=contactRecord.Id, AccountId = mapPrimaryIdWithOrg.get(contactRecord.Id)));
        }
        Debug.log('lstContacts==>'+lstContacts);
        if(lstContactToUpdateAccount.size() > 0){
            update lstContacts;
        }
    }
    
  /************************************************************************************************************************************
    Author      :   Prashant Mane
    Description :   This is a wrapper class to store api user data.
 
    History :
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                     DETAIL
    1           06 June 2018        Prashant Mane              Initial Developement
**************************************************************************************************************************************/
  public class APIUserSetting {
        public String  UserId{get;set;}
        public String Email{get;set;}
        public String Name{get;set;}
        public String ContactId{get;set;}
        public String ContactUUID{get;set;}
    }    
    public class BillingAccountTriggerHandlerException extends Exception {}
}