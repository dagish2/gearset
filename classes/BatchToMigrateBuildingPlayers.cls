global class BatchToMigrateBuildingPlayers implements Database.Batchable<SObject>,Database.stateful {
    /*
* @ Descrption : Data Maigration for populate building players Names and Email.
* @ Created By : Krishana Tupe
* @ Modified By : Krishana Tupe
* @ Created Date : 06 Jan 2018
* @ Issue : For ST-1855
*/
    global List<String> lstEmailAddresses = new List<String>();
    global String query = 'SELECT Market__r.TerritoryID__r.RegionID__r.Region__c,Market__r.TerritoryID__r.RegionID__r.Regional_Sales_Manager__r.name,'+
        'Market__r.TerritoryID__r.RegionID__r.Regional_Sales_Manager__r.email,Market__r.TerritoryID__r.name,Market__r.TerritoryID__r.Territory_Sales_Manager__r.name,'+
        'Market__r.TerritoryID__r.Territory_Sales_Manager__r.email,Market__r.name,Market__r.Portfolio_Sales_Manager__r.name,Market__r.Portfolio_Sales_Manager__r.email,'+
        'Cluster__r.name,Cluster__r.Cluster_Sales_Manager__r.name,Cluster__r.Cluster_Sales_Manager__r.email,'+
        'Cluster__r.Sales_Lead__r.name,Cluster__r.Sales_Lead__r.email FROM Building__c';	
    
    global Database.QueryLocator start( Database.BatchableContext bc ) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> records){
        try{
            for(Building__c building: (List<Building__c> ) records) { 
                building.Region_Name__c = building.Market__r.TerritoryID__r.RegionID__r.Region__c;
                building.Regional_Sales_Manager_Name__c = building.Market__r.TerritoryID__r.RegionID__r.Regional_Sales_Manager__r.name;
                building.Regional_Sales_Manager_Email__c = building.Market__r.TerritoryID__r.RegionID__r.Regional_Sales_Manager__r.email;	
                
                building.Territory_Name__c = building.Market__r.TerritoryID__r.name;
                building.Territory_Sales_Manager_Name__c = 	building.Market__r.TerritoryID__r.Territory_Sales_Manager__r.name;
                building.Territory_Sales_Manager_Email__c = building.Market__r.TerritoryID__r.Territory_Sales_Manager__r.email;
                
                building.Portfolio_Name__c = building.Market__r.name;
                building.Portfolio_Sales_Manager_Name__c = building.Market__r.Portfolio_Sales_Manager__r.name; 
                building.Portfolio_Sales_Manager_Email__c = building.Market__r.Portfolio_Sales_Manager__r.email; 	
                
                building.Cluster_Name__c = building.Cluster__r.name;
                building.Cluster_Sales_Manager_Name__c = building.Cluster__r.Cluster_Sales_Manager__r.name;  	
                building.Cluster_Sales_Manager_Email__c = building.Cluster__r.Cluster_Sales_Manager__r.email;  	 
                
                building.Cluster_Sales_Lead_Name__c = building.Cluster__r.Sales_Lead__r.name;
                building.Cluster_Sales_Lead_Email__c = building.Cluster__r.Sales_Lead__r.email;
            }
        }
        catch(Exception pEx) {          
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('BatchToMigrateBuildingPlayers','Batch Apex','Referal Sources',pEx)
            );
        }
        Database.update(records);
    }    
    
    global void finish(Database.BatchableContext context) {
        lstEmailAddresses.add('devdatta.bauskar@enzigma.com');
        lstEmailAddresses.add('krishna.tupe@enzigma.com');
        lstEmailAddresses.add('ajaysinh.chauhan@enzigma.in');
        lstEmailAddresses.add('girish.bhandari@enzigma.in');
        if(lstEmailAddresses.size()>0){
            AsyncApexJob a = [SELECT Id, Status,ExtendedStatus,NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:context.getJobId()];
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses =lstEmailAddresses;
            mail.setToAddresses(toAddresses);
            mail.setSubject('BatchToMigrateBuildingPlayers Batch Status :: ' + a.Status);+
                mail.setPlainTextBody('Records Processed ' + a.TotalJobItems +   ' With '+ a.NumberOfErrors + ' Failures.');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });   
        }        
    }
}