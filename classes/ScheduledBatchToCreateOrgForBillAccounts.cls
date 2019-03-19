public class ScheduledBatchToCreateOrgForBillAccounts implements Database.Batchable<sObject>{    
/************************************************************************************************************************************
    Author 		: 	Krishana Tupe
    Issue NO	: 	ST-1907
    Description : 	Scheduled batch to assign org account for bill Account.

    History:
----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE				AUTHOR					DETAIL
    1.0			18 Jan 2018			Krishana Tupe			Initial Developement.
	2.0			16 Apr 2018			Krishana Tupe			Added field mapping Bill to create new org Account
**************************************************************************************************************************************/
   
    Settings.FieldMappings mapBillAccountToOrgAccount = new Settings.FieldMappings();
    Set<String> setAccountFields = new Set<String>();  
   /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is used initialize the settings required for maintain chaining in account hierarchy batches.
      	Created Date  		:   12 April 2018
        Last Modified By    :   Krishana Tupe
    **************************************************************************************************************************************/
    public ScheduledBatchToCreateOrgForBillAccounts(){
        mapBillAccountToOrgAccount = Settings.getFieldMappings('BillAccountToOrgAccount');
        if( mapBillAccountToOrgAccount == null){
            mapBillAccountToOrgAccount = Settings.BillAccountToOrgAccountMapping();   
        }         
        for(Settings.MappedField field : mapBillAccountToOrgAccount.mappings.values()){
            if(field.fieldname != null){
                setAccountFields.add(field.fieldname);   
            }            
        }   
        debug.Log('setAccountFields==> '+setAccountFields); 
    }
    /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is used to gets the bill account which meets query criteria.
      	Created Date  		:   12 April 2018
        Last Modified By    :   Ajaysinh Chauhan
    **************************************************************************************************************************************/
    public Database.QueryLocator start(Database.BatchableContext bc) {
        Setting__c objAccountHierarchyOrgAssignBatchTime = Settings.get('AccountHierarchy:OrgAssignBatchTime');
        Map<String, Object> mapInterval = (Map<String, Object>)JSON.deserializeUntyped(objAccountHierarchyOrgAssignBatchTime.Data__c);
        DateTime interval = System.now().addMinutes(-Integer.valueOf(mapInterval.get('account')));
        Date afterCreatedDate = Date.valueOf(String.valueOf(mapInterval.get('createdDate')));
        setAccountFields.add('Org_Identification_Status__c');
        setAccountFields.add('Name');
        setAccountFields.add('Account_Type__c');
        setAccountFields.add('Cleansed_Unomy_Company_Name__c');
        setAccountFields.add('Unomy_Company_ID__c');
        setAccountFields.add('Unomy_Company_Name__c');
        setAccountFields.add('Cleansed_Account_Name__c'); 
        setAccountFields.add('ParentId');
        setAccountFields.remove(null);
        Debug.log('setAccountFields==>'+setAccountFields); 
        List<String> lstFields = new List<String>(setAccountFields);        
        String query = 'SELECT Id , '+String.join(lstFields, ',' );
        query += ' FROM Account WHERE (CreatedDate > :afterCreatedDate) AND (Org_Identification_Status__c=\'Pending\' AND Account_Type__c = \'Bill\')';
        query += ' AND (CreatedDate < :interval OR Unomy_Updated_DateTime__c <> null)' ;
        Debug.log('Query==>'+query);
        return Database.getQueryLocator(query); 
    }
    /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is used to find org for bill account and if org found then it will update on it else it will create new org for that bill account.
      	Created Date  		:   12 April 2018
        Last Modified By    :   Krishana Tupe
    **************************************************************************************************************************************/
    public void execute(Database.BatchableContext bc, List<sobject> lstRecords){
        try{
            List<sObject> lstRecordsToUpdate;
            for (Account objAccount : (List<Account>)lstRecords) {
                if(lstRecordsToUpdate==null){
                    lstRecordsToUpdate = new List<sObject>(); 
                }
                // if we are unable to find org then also we will mark that account as Processed for minimizing batch data.
                if(objAccount.ParentId==null){
                    objAccount.ParentId = AccountHierarchyHelper.findOrCreateRelatedOrg(objAccount,mapBillAccountToOrgAccount);
                    objAccount.Org_Identification_Status__c = 'Processed';
                }else if(objAccount.Org_Identification_Status__c != 'Processed'){
                    objAccount.Org_Identification_Status__c = 'Processed'; 
                }                
                lstRecordsToUpdate.add(objAccount);
            }
            if (lstRecordsToUpdate != null && lstRecordsToUpdate.size() > 0){
                Database.update(lstRecordsToUpdate,false);
            }
        }catch(Exception pEx) {           
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('ScheduledBatchToAssignOrgAccounts','ScheduledBatchToAssignOrgAccounts',null,pEx)
            );
        }
    }  
   /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is used to reschedule the batch and maintain chaining between batches.
      	Created Date  		:   12 April 2018
        Last Modified By    :   Ajaysinh Chauhan
    **************************************************************************************************************************************/
    public void finish(Database.BatchableContext bc){
        Set<String> setBatches;
        Setting__c settingData = Settings.get('OrgBatchesChainigSetting');   
        if(settingData != null && settingData.Data__c!=null){
            setBatches = (Set<String>)JSON.deserialize(settingData.data__c.toLowerCase(), Set<String>.class);
        }
        if(setBatches!=null){
            if(setBatches.contains('scheduledbatchtoassignorgaccounts')){
                Database.executeBatch(new ScheduledBatchToAssignOrgAccounts(), 1);
            }else if(setBatches.contains('scheduledbatchtoassignaccountonlead')){
                Database.executeBatch(new ScheduledBatchToAssignAccountOnLead(), 1);
            }else if(setBatches.contains('scheduledbatchtocreateorgforbillaccounts')){
                Database.executeBatch(new ScheduledBatchToCreateOrgForBillAccounts(), 1);
            }
        }        
    } 
}