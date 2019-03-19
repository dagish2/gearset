/************************************************************************************************************************************
    Author 		: Prashant Mane
    Description : Batch To Populate Account On Lead Based On Sepecific Creteria , If Not found then Dosen't Create New Organization

    History:
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE				AUTHOR					DETAIL
    1			23 Jan 2018			Prashant Mane			Initial Developement.
**************************************************************************************************************************************/

public class ScheduledBatchToAssignAccountOnLead implements Database.Batchable<sObject>{ 
/************************************************************************************************************************************
    Author 		: 	Prashant Mane
    Description : 	This method queries all such Leads whose Org Identification is Pending and Unomy data is populated or  Unomy has 
					failed to populate the record even after prescribed time of 3 minutes. Unomy has guaranteed to populate the data 
					within 3 minutes of creation of Lead, but giving buffer we are processing record only after 10 minutes(configurable) 
					assuming Unomy has failed populating data, if Unomy data is missing

    History:
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE				AUTHOR					DETAIL
    1			23 Jan 2018			Prashant Mane			Initial Developement.
**************************************************************************************************************************************/
    public Database.QueryLocator start(Database.BatchableContext bc) {
        Setting__c objAccountHierarchyOrgAssignBatchTime = Settings.get('AccountHierarchy:OrgAssignBatchTime');
        Map<String, Object> mapInterval = (Map<String, Object>)JSON.deserializeUntyped(objAccountHierarchyOrgAssignBatchTime.Data__c);
        
        //If Unomy data is not populated even after 10 minutes(configurable) of creation of Lead, we should assume Unomy has failed and
        //process such records. Hence calculating datetime of created before 10 minutes(configurable)
        DateTime dtCreatedBefore = System.now().addMinutes(-Integer.valueOf(mapInterval.get('lead')));
        Date afterCreatedDate = date.valueOf(String.valueOf(mapInterval.get('createdDate')));
        return Database.getQueryLocator('SELECT Id,Name,Account__c,Unomy_Company_ID__c,Unomy_Company_Name__c,Cleansed_Company_Name__c, Org_Identification_Status__c  '+
                                        ' FROM Lead WHERE isConverted=false AND (CreatedDate > :afterCreatedDate) AND (Org_Identification_Status__c = \'Pending\') AND ('+
                                        ' CreatedDate < :dtCreatedBefore OR Unomy_Updated_DateTime__c <> null)'); 
    }

/************************************************************************************************************************************
    Author 		: 	Prashant Mane
    Description : 	This method processes one record of the lead at a time. It tries to find existing Oganizatoin for the Lead and if
					found assign that to the Lead. If there is already an Organization assigned to Lead it will not be overwritten.

    History:
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE				AUTHOR					DETAIL
    1			23 Jan 2018			Prashant Mane			Initial Developement.
**************************************************************************************************************************************/
    public void execute(Database.BatchableContext bc, List<sObject> listRecords){
        Debug.log('listRecords Processed in batch==>'+listRecords);     
        Lead lead = ((List<Lead>)listRecords)[0];
        Lead leadToUpdate = new Lead(Id = lead.Id);
        if(lead.Account__c == null) {  
            //Only if related org is found we should update the Lead with the Org found
            leadToUpdate.Account__c = AccountHierarchyHelper.findRelatedOrg(lead);
            leadToUpdate.Org_Identification_Status__c = 'Processed';
        }else if(lead.Org_Identification_Status__c != 'Processed'){
            leadToUpdate.Org_Identification_Status__c = 'Processed'; 
        }               
        Database.update(leadToUpdate,false);
    }  
   /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is used to reschedule the batch or maintain chaining between batches.
      	Created Date  		:   12 April 2018
        Last Modified By    :   Krishana Tupe
    **************************************************************************************************************************************/
    public void finish(Database.BatchableContext bc){
        Set<String> setBatches;
        Setting__c settingData = Settings.get('OrgBatchesChainigSetting');   
        if(settingData != null && settingData.Data__c!=null){
            setBatches = (Set<String>)JSON.deserialize(settingData.data__c.toLowerCase(), Set<String>.class);
        }
        if(setBatches!=null){
            if(setBatches.contains('scheduledbatchtocreateorgforbillaccounts')){
                Database.executeBatch(new ScheduledBatchToCreateOrgForBillAccounts(), 1);
            }else if(setBatches.contains('scheduledbatchtoassignorgaccounts')){
                Database.executeBatch(new ScheduledBatchToAssignOrgAccounts(), 1);
            }else if(setBatches.contains('scheduledbatchtoassignaccountonlead')){
                Database.executeBatch(new ScheduledBatchToAssignAccountOnLead(), 1);
            }
        }
    }
}