/************************************************************************************************************************************
    Author 		: 	Shivprasad Patil
    Issue NO	: 	ST-1907
    Description : 	Scheduled batch to assign org account for blank Account.

    History:
----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE				AUTHOR					DETAIL
    1.0			18 Jan 2018			Shivprasad Patil		Initial Developement.
**************************************************************************************************************************************/
public class ScheduledBatchToAssignOrgAccounts implements Database.Batchable<sObject>{
    
   /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is used to gets the blank account which meets query criteria.
      	Created Date  		:   12 April 2018
        Last Modified By    :   Krishana Tupe
    **************************************************************************************************************************************/
    public Database.QueryLocator start(Database.BatchableContext bc) {
        Setting__c objAccountHierarchyOrgAssignBatchTime = Settings.get('AccountHierarchy:OrgAssignBatchTime');
        Map<String, Object> mapInterval = (Map<String, Object>)JSON.deserializeUntyped(objAccountHierarchyOrgAssignBatchTime.Data__c);
        DateTime interval = System.now().addMinutes(-Integer.valueOf(mapInterval.get('account')));
        Date afterCreatedDate = Date.valueOf(String.valueOf(mapInterval.get('createdDate')));
        Set<String> setAccountFields = new Set<String>();
        setAccountFields.add('Org_Identification_Status__c');
         setAccountFields.add('Name');
        setAccountFields.add('Account_Type__c');
        setAccountFields.add('Cleansed_Unomy_Company_Name__c');
        setAccountFields.add('Unomy_Company_ID__c');
        setAccountFields.add('Unomy_Company_Name__c');
        setAccountFields.add('Cleansed_Account_Name__c'); 
        setAccountFields.add('ParentId');
        setAccountFields.remove(null);
        List<String> lstFields = new List<String>(setAccountFields);        
        String query = 'SELECT Id, '+String.join(lstFields, ',' );
        query += ' FROM Account WHERE (CreatedDate > :afterCreatedDate) AND (Org_Identification_Status__c = \'Pending\' AND Account_Type__c = \'\')';
        query += ' AND ( CreatedDate < :interval OR Unomy_Updated_DateTime__c <> null )' ;
        Debug.log('Query==>'+query);
        return Database.getQueryLocator(query); 
    }
   /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is used to find org for blank account and if found then it will update on it.
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
                    objAccount.ParentId = AccountHierarchyHelper.findRelatedOrg(objAccount);
                    objAccount.Org_Identification_Status__c = 'Processed';  
                }else if(objAccount.Org_Identification_Status__c != 'Processed'){
                    objAccount.Org_Identification_Status__c = 'Processed'; 
                }
                lstRecordsToUpdate.add(objAccount);
            }
            if (lstRecordsToUpdate != null && lstRecordsToUpdate.size()>0){
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
        Description         :   This method is used to reschedule the batch or maintain chaining between batches.
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
            if(setBatches.contains('scheduledbatchtoassignaccountonlead')){
                Database.executeBatch(new ScheduledBatchToAssignAccountOnLead(), 1);
            }else if(setBatches.contains('scheduledbatchtocreateorgforbillaccounts')){
                Database.executeBatch(new ScheduledBatchToCreateOrgForBillAccounts(), 1);
            }else if(setBatches.contains('scheduledbatchtoassignorgaccounts')){
                Database.executeBatch(new ScheduledBatchToAssignOrgAccounts(), 1);
            }
        }
    }
}