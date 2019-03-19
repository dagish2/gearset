/************************************************************************************************************************************
	Author		: 	Nikhil Mehta
	Description	:   This class used to test BatchToUpdateSobjects.
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE	        		AUTHOR                     	DETAIL
	1	    	22 February 2019		Nikhil Mehta             	Initial Developement
**************************************************************************************************************************************/
@isTest
public class BatchToUpdateOrInsertSObjectsTest {
    @TestSetup
    public static void initData(){
        SalesConsoleSettings.createSettings();
    }
    
    @isTest
    public static void verifyBatchToUpdateSOBjects(){
        List<Account> lstAccounts = new List<Account>();
        Integer iIndex;
        for(iIndex = 0; iIndex < 5; iIndex++){
            lstAccounts.add(new Account(Name='Master Account'+iIndex, Unomy_Company_ID__c = 123456+iIndex, Unomy_Updated_DateTime__c = Date.today(), Lead_Source__c = 'Test'+iIndex, Account_Type__c = 'Org', Unomy_Location_Address__c = 'USA', Unomy_Location_City__c = 'Seattle', Unomy_Location_State__c = 'Washington', Unomy_Location_Country__c = 'USA', BillingStreet = 'Washington', BillingCity = 'Seattle', BillingState = 'Washington', BillingCountry = 'USA')); 
        }
        Database.insert(lstAccounts, false);
        iIndex = 0;
        for(Account objAccount : lstAccounts){
            objAccount.Name = 'Account'+iIndex;
            iIndex++;
        }
        Test.startTest();
        Database.executeBatch(new BatchToUpdateOrInsertSObjects(lstAccounts));
        Test.stopTest();
        iIndex = 0;
        for(Account objAccount : [SELECT Id, Name FROM Account WHERE Id IN :lstAccounts]){
            System.assertEquals('Account'+iIndex, objAccount.Name);
            iIndex++;
        }
    }
}