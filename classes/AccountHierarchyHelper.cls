/************************************************************************************************************************************
    Author 		: 	Ajaysinh Chauhan
    Description : 	Generic class to identify or create org for Account and Leads.

    History:
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE				AUTHOR					DETAIL											Issue No.
    1			15 Jan 2018			Ajaysinh Chauhan		Initial Developement.							ST-1947
	2			22 Jan 2018			Ajaysinh Chauhan		Changes for identifying org for Leads.
**************************************************************************************************************************************/

public without sharing class AccountHierarchyHelper {   
    /************************************************************************************************************************************
        Author 		: 	Ajaysinh Chauhan
        Description : 	This method identifies the Organization for the given Lead or Account, this is not bulkified to keep the code 
                        simple for faster development.
    
        History:
        ----------------------------------------------------------------------------------------------------------------------------------
        VERSION		DATE				AUTHOR					DETAIL
        1			15 Jan 2018			Ajaysinh Chauhan		Initial Developement.
        2			22 Jan 2018			Ajaysinh Chauhan		Changes for identifying org for Leads.
    **************************************************************************************************************************************/
    public static Id findRelatedOrg(sObject record){
        List<String> lstCriterias = new List<String>();
        Decimal companyId = (Decimal)record.get('Unomy_Company_ID__c');
        if(record != null ){
            String strRecordObjectName = record.getSObjectType().getDescribe().getName().toLowerCase();
            if(record.get('Unomy_Company_ID__c') != null){
                lstCriterias.add('Unomy_Company_Id__c=:companyId');
            }
            if(strRecordObjectName == 'account' && String.isNotBlank(String.valueOf(record.get('Cleansed_Unomy_Company_Name__c')))){
                lstCriterias.add('Cleansed_Unomy_Company_Name__c=\'' + LightningComponentController.escapeSpecialChars(String.valueOf(record.get('Cleansed_Unomy_Company_Name__c')))+'\'');
            	lstCriterias.add('Cleansed_Account_Name__c=\'' + LightningComponentController.escapeSpecialChars(String.valueOf(record.get('Cleansed_Unomy_Company_Name__c')))+'\'');
            }else if(String.isNotBlank(String.valueOf(record.get('Unomy_Company_Name__c')))){
                lstCriterias.add('Unomy_Company_Name__c=\'' + LightningComponentController.escapeSpecialChars(String.valueOf(record.get('Unomy_Company_Name__c')))+'\'');
            	lstCriterias.add('Name=\'' + LightningComponentController.escapeSpecialChars(String.valueOf(record.get('Unomy_Company_Name__c')))+'\'');
            }
            if(strRecordObjectName == 'account'){
                if(String.isNotBlank(String.valueOf(record.get('Cleansed_Account_Name__c')))){
                    lstCriterias.add('Cleansed_Account_Name__c=\'' + LightningComponentController.escapeSpecialChars(String.valueOf(record.get('Cleansed_Account_Name__c')))+'\'');
                }else if(String.isNotBlank(String.valueOf(record.get('Name')))){
                    lstCriterias.add('Name=\'' + LightningComponentController.escapeSpecialChars(String.valueOf(record.get('Name')))+'\'');
                }
            }
            else if(strRecordObjectName == 'lead'){
                if(String.isNotBlank(String.valueOf(record.get('Cleansed_Company_Name__c')))){
                    lstCriterias.add('Cleansed_Account_Name__c=\'' + LightningComponentController.escapeSpecialChars(String.valueOf(record.get('Cleansed_Company_Name__c')))+'\'');
                }else if(String.isNotBlank(String.valueOf(record.get('Name')))){
                    lstCriterias.add('Name=\'' + LightningComponentController.escapeSpecialChars(String.valueOf(record.get('Name')))+'\'');
                }
            }
            if(!lstCriterias.isEmpty()){
                String strQuery = 'Select Id From Account Where Account_Type__c=\'Org\' AND ('+ String.join(lstCriterias, ' OR ') +')';
                Debug.Log('strQuery==>'+strQuery);
                List<Account> lstAccounts = Database.query(strQuery);
                if(!lstAccounts.isEmpty()){
                    Debug.Log('strQuery  Result==>'+lstAccounts[0].Id);
                    return lstAccounts[0].Id;
                }
            }
        }
        return null;
    }

    /************************************************************************************************************************************
        Author 		: 	Ajaysinh Chauhan
        Description : 	This method identifies the Organization for the given Lead or Account, this is not bulkified to keep the code simple
        for faster development.
        
        History:
        ----------------------------------------------------------------------------------------------------------------------------------
        VERSION		DATE				AUTHOR					DETAIL
        1			31 Jan 2018			Ajaysinh Chauhan		Created new method to find or create Organization
    **************************************************************************************************************************************/
    public static Id findOrCreateRelatedOrg(sObject record,Settings.FieldMappings mapBillAccountToOrgAccount){
        Debug.log('record==>'+record);
        Id idOrg = findRelatedOrg(record);       
        String strRecordObjectName = record.getSObjectType().getDescribe().getName().toLowerCase();
        Debug.log('strRecordObjectName==>'+strRecordObjectName);
        if(idOrg == null && strRecordObjectName == 'account' && record.get('Account_Type__c') == 'Bill'){
            String strOrgName;            
            Account account = (Account)record;
            Debug.log('Account to Create==>'+account);
            // If unomy does not updates the data then we will use billing account name as org name.
            if(account.Unomy_Company_Name__c!=null){
                strOrgName = account.Unomy_Company_Name__c;
            }else{
                strOrgName = account.Name;
            }
            Account objOrg = new Account();
            objOrg = AccountHierarchyHelper.getOrgAccount(account,mapBillAccountToOrgAccount);
            debug.log('Final objOrg==>'+objOrg);
            objOrg.Name = strOrgName;
            objOrg.Org_Identification_Status__c = 'Processed';
            objOrg.Account_Type__c = 'Org';
            objOrg.Lead_Source__c = 'Batch';
            //objOrg.Org_Name__c = strOrgName;
            Database.SaveResult result = Database.insert(objOrg,false); 
            idOrg = result.getId();
        }
        Debug.log('Returned Org==>'+idOrg);
        return idOrg;
    }
    public static Account getOrgAccount(Account accRecord,Settings.FieldMappings mapBillAccountToOrgAccount){       
        if(accRecord != null && mapBillAccountToOrgAccount != null){ 
            Account orgAccount = new Account();
            for(String field : mapBillAccountToOrgAccount.mappings.keySet()){
                Settings.MappedField mappedField = mapBillAccountToOrgAccount.mappings.get(field);
                if(mappedField.isvalue == true){
                    orgAccount.put(field, mappedField.value); 
                }else{
                    orgAccount.put(field, accRecord.get(mappedField.fieldname));   
                }  
            } 
            debug.log('orgAccount==>'+orgAccount);
            return orgAccount;  
        }else{
            return null; 
        }        
    }
    /************************************************************************************************************************************
        Author 		: 	Ajaysinh Chauhan
        Description : 	This exception class is used for throwing exceptin for current class.
    
        History:
        ----------------------------------------------------------------------------------------------------------------------------------
        VERSION		DATE				AUTHOR					DETAIL
        3			31 Jan 2018			Ajaysinh Chauhan		Created new class for throwing specific exception of AccountHirarchyHelper
    **************************************************************************************************************************************/
    public class AccountHirarchyHelperException extends Exception {}
}