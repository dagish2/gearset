/************************************************************************************************************************************
    Author 		: Ajaysinh Chauhan
    Description : Test class for Batch to find duplicate accounts that has no opportunities, accounts and child accounts and created after 9th Mar 2018 by Susie Romero.

    History:
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE				AUTHOR					DETAIL
    1			27 Mar 2018			Ajaysinh Chauhan    	Initial Developement.
**************************************************************************************************************************************/
@isTest
public class BatchToFindDuplicateAccountsTests {
    @TestSetup
    public static void setup(){
        SalesConsoleSettings.createSettings();
    }
	@isTest
    public static void verifyDuplicateAccountsBatch(){
   		User u = [Select Id From User Where Name='Susie Romero'];
        List<Account> lstAccounts = new List<Account>{new Account(Name='testName1',Account_Type__c='Org'),new Account(Name='testName2',Account_Type__c='Org')};
        System.runAs(u){
			TestingUtility.insertListWithAssert(lstAccounts);
        }
        Database.executeBatch(new BatchToFindDuplicateAccounts());
    }
}