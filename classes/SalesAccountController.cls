/************************************************************************************************************************************
    Author      :   Prashant Mane
    Description :   This class contain all aura methods related to CreateNewSalesAccount Component.
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1           10 Jan 2019         Prashant Mane        	Initial Developement
**************************************************************************************************************************************/
global without sharing class SalesAccountController {
    public static Boolean isInvoker = false;
    public static Savepoint sp {get;set;}
    static {
        isInvoker = ApexDebugLog.registerRootInvoker(ApexDebugLog.InvokerType.AURA, 'SalesAccountController' + 'getsObjectPrefix', ApexDebugLog.InvokerType.AURA);        
    }
    @AuraEnabled
    public static DatabaseResult isValidForSalesAccount(String recordId){
        try{
            ValidForSalesAccountResult objValidForSalesAccountResult = new ValidForSalesAccountResult();
            objValidForSalesAccountResult.isValid = true;
            Account accRec = [SELECT Id, OwnerId , Account_Type__c FROM Account Where Id =:recordId];
            Debug.log('accRec---'+accRec);
            if(accRec.Account_Type__c != null && (accRec.Account_Type__c.toLowerCase() == 'org' || accRec.Account_Type__c.toLowerCase() == 'sales')){
                if(accRec.OwnerId == UserInfo.getUserId()){
                    objValidForSalesAccountResult.isValid = true;
                }else if(OrganizationHelper.getUltimateParents(new Set<Id>{accRec.Id},new List<String>{'OwnerId'}).get(accRec.Id).OwnerId == UserInfo.getUserId()){
                    objValidForSalesAccountResult.isValid = true;                    
                }else {
                    List<CustomPermission> lstCustomPermissions = [SELECT Id, DeveloperName, (SELECT Id, Parent.Name, Parent.Profile.Name FROM SetupEntityAccessItems WHERE Parent.Profile.Id =: UserInfo.getProfileId()) FROM CustomPermission WHERE DeveloperName = 'Can_Create_Sales_Account'];
                    if(lstCustomPermissions != null && lstCustomPermissions.size() > 0 && lstCustomPermissions[0].SetupEntityAccessItems != null && lstCustomPermissions[0].SetupEntityAccessItems.size()>0){
                        objValidForSalesAccountResult.isValid = true;
                    }else{
                        objValidForSalesAccountResult.isValid = false;
                        objValidForSalesAccountResult.errorMessage = 'You can not create Sales Account as you are not the owner of the Account.';
                    } 
                }
            }else{
                objValidForSalesAccountResult.isValid = false;
                objValidForSalesAccountResult.errorMessage = 'Sales account can only be created under Org or Sales accounts.';
            }
            return new DatabaseResult(JSON.serialize(objValidForSalesAccountResult));
        }catch(Exception pEx){
            ApexDebugLog.logException(pEx,'AccountId==> '+ recordId, 'SalesAccountController', 'isValidForSalesAccount');                      
            return new DatabaseResult(pEx);  
        } 
    }
    
 /****************************************************************************************************************************
    Author              :   Krishana Tupe
    Description         :   This method is used to find ultimate org for Lead record and returns its related sales account records                           
    Created Date        :   23 July 2018   
    Issue No.           :   ST-2669
 *********************************************************************************************************************************/  
    @AuraEnabled
    public static DatabaseResult getRelatedAccounts(String leadId,String parentId){
        try{
            String ultimateOrgId;
            if(String.isBlank(parentId)){
                Lead leadRecord = [Select Id,FirstName,Interested_in_Number_of_Desks_Min__c,Interested_in_Number_of_Desks__c,LastName,Name,Product_Line__c,OwnerId,Email_Domain__c,Company,Account__c,Account__r.Account_Type__c,Referrer__c,Cleansed_Unomy_Company_Name__c,Cleansed_Company_Name__c,Email,Unomy_Company_ID__c,Unomy_Company_Name__c,LeadSource,Lead_Source_Detail__c,Generate_Journey__c,By_Pass_Journey_Creation_Criteria__c,Building_Interested_In__c,Building_Interested_In__r.City__c,Locations_Interested__c,Number_of_Full_Time_Employees__c,Company_Size__c,Markets_Interested__c From  Lead Where Id=:leadId];
                ultimateOrgId =  OrganizationHelper.findRelatedOrg(leadRecord);
                Debug.log('ultimateOrgId ==>'+ultimateOrgId);
            }else{
                ultimateOrgId = parentId;   
            }
            Map<String,List<Account>> mapAccount = new Map<String,List<Account>>();
            if(String.isNotBlank(ultimateOrgId)){
                List<Account> lstAccounts = [Select Id,Name,Parent_Org_Id__c,Account_Type__c From Account Where Id=:ultimateOrgId];          
                if(lstAccounts != null && lstAccounts.size() >0){
                    mapAccount.put('OrgAccount',lstAccounts);
                    String query='';
                    if(String.isNotBlank(lstAccounts[0].Parent_Org_Id__c)){
                        query += 'Select Id,Name,Primary_Member__c,Primary_Member__r.Name,Primary_Member__r.Email,Parent_Org_Id__c,Parent_Org_Name__c,RecordType.Name,Account_Type__c,OwnerId,Owner.Name,ID_Status2__c,CreatedDate From Account Where (Parent_Org_Id__c=\''+String.valueOf(lstAccounts[0].Parent_Org_Id__c).substring(0,15)+'\' OR ParentId=\''+lstAccounts[0].Parent_Org_Id__c+'\' OR Id=\''+lstAccounts[0].Parent_Org_Id__c+'\') AND (Account_Type__c=\'Sales\' OR Account_Type__c=\'Org\')';
                    }else if(lstAccounts[0].Account_Type__c =='Org'){
                        query += 'Select Id,Name,Primary_Member__c,Primary_Member__r.Name,Primary_Member__r.Email,Parent_Org_Id__c,Parent_Org_Name__c,RecordType.Name,Account_Type__c,OwnerId,Owner.Name,ID_Status2__c,CreatedDate From Account Where (Parent_Org_Id__c=\''+String.valueOf(lstAccounts[0].Id).substring(0,15)+'\' OR ParentId=\''+lstAccounts[0].Id+'\') AND (Account_Type__c=\'Sales\' OR Account_Type__c=\'Org\')';   
                    }
                    Debug.log('query==>'+query);
                    List<Account> lstSalesAccounts = (List<Account>)Database.query(query);            
                    mapAccount.put('SalesAccounts',lstSalesAccounts);        
                    return new DatabaseResult(mapAccount);            
                }else{
                    return null;
                }  
            }
            return null;
        }catch(Exception pEx){
            ApexDebugLog.logException(pEx,'LeadId==>'+leadId+' AccountId==>'+parentId, 'SalesAccountController', 'getRelatedAccounts');                      
            return new DatabaseResult(pEx);   
        }
    }
    
    @AuraEnabled
    public static DatabaseResult isValisUserToShowAccountSelector(){
        try{
            Boolean showPage = false;
            User loggedInUser = Settings.getUserById(UserInfo.getUserId());
            Setting__c accountSelectorSettings = settings.get('AccountSelectorSettings');
            Map<String,set<String>> mapExcludedProfiles;
            if(accountSelectorSettings != null){
                mapExcludedProfiles  = (Map<String,set<String>>)JSON.deserialize(accountSelectorSettings.Data__c.toLowerCase(), Map<String,set<String>>.class);             
                Debug.log('mapExcludedProfiles==>'+mapExcludedProfiles);
                if(mapExcludedProfiles != null && !mapExcludedProfiles.get('profiles').contains(String.valueOf(loggedInUser.Profile.Name).toLowerCase())){
                    showPage = true;
                }
            }
            return new DatabaseResult(showPage);
        }catch(Exception pEx){
            ApexDebugLog.logException(pEx,'', 'SalesAccountController', 'isValisUserToShowAccountSelector');                      
            return new DatabaseResult(pEx);   
        }
    } 
    
    public class ValidForSalesAccountResult {
        public Boolean isValid {get;set;}
        public String errorMessage {get;set;}
    }
}