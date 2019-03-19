/************************************************************************************************************************************
    Author 		: Ajaysinh Chauhan
    Description : Batch to find duplicate accounts that has no opportunities, accounts and child accounts and created after 9th Mar 2018 by Susie Romero.

    History:
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE				AUTHOR					DETAIL
    1			27 Mar 2018			Ajaysinh Chauhan    	Initial Developement.
**************************************************************************************************************************************/
global class BatchToFindDuplicateAccounts implements Database.Batchable<sObject>,Database.Stateful {
    global String strCSV;
    global BatchToFindDuplicateAccounts(){
        strCSV = '';
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('Select Id,Name,(Select Id From ChildAccounts limit 1),(Select Id From Contacts limit 1),(Select Id From Opportunities limit 1) From Account Where CreatedDate >= 2018-03-09T00:00:00Z AND CreatedBy.UserName=\'joinus@wework.com\' AND Account_Type__c=\'Org\''); 
    }
    global void execute(Database.BatchableContext bc, List<Account> listRecords){
        List<Account> lstDuplicateAccounts = new List<Account>();
        for(Account objAccount:listRecords){
            if((objAccount.ChildAccounts==null || objAccount.ChildAccounts.size()==0) && (objAccount.Contacts==null || objAccount.Contacts.size()==0) && (objAccount.Opportunities==null || objAccount.Opportunities.size()==0)){
                lstDuplicateAccounts.add(objAccount);
            }
        }
        strCSV += CSVGenerator.generateCSV(new List<String>{'Id','Name'},lstDuplicateAccounts);
    } 
    global void finish(Database.BatchableContext bc) {
        List<String> lstHeaders = new List<String>{'Id','Name'};
        String strHeader = String.join(lstHeaders,',');
        strHeader += '\n';
        strCSV = strHeader+''+strCSV;
        CSVGenerator.sendEmail(strCSV,new List<String>{'wework@enzigma.com'},'DuplicateAccount.csv','Duplicate Accounts','Please find the attachment for generated duplicate accounts csv.');
    }
}