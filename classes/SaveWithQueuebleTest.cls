/************************************************************************************************************************************
   	Author 		: Ajaysinh Chauhan
   	Description : This class Contains Unit Tests of Save With Queueble

   	History		:
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE				AUTHOR				DETAIL
	1			13 June 2017		Ajaysinh Chauhan	Initial Developement
**************************************************************************************************************************************/
@isTest
public class SaveWithQueuebleTest {
    /************************************************************************************************************************************
        Author 				: Ajaysinh Chauhan
        Description 		: Test method for verifying non queable save
        Last Modified Date	: 13 June 2017
        Last Modified By	: Ajaysinh Chauhan
	**************************************************************************************************************************************/
    static testmethod void verifyNonQueableSave(){
        SalesConsoleSettings.createSettings();
        
        Account objAccount_1 = TestingUtility.createAccount('Test Account 5', false);
        SaveWithQueueble.save(objAccount_1);
        
        //for record having Id, Updating the name and passed for save
        Account objAccount_2 = TestingUtility.createAccount('Test Account', true);
        objAccount_2.Name = 'Test Account Record';
        
        SaveWithQueueble.save(objAccount_2);
        
        //creating list of new records to verify insertion of list of records
        Account objAccount1 = TestingUtility.createAccount('Test Account 11', false);
        Account objAccount2 = TestingUtility.createAccount('Test Account 22', false);
        Account objAccount3 = TestingUtility.createAccount('Test Account 33', false);
        Account objAccount4 = TestingUtility.createAccount('Test Account 44', false);
        List<Account> lstAccountIds = new List<Account>();
        
        List<Account> lstAccount = new List<Account>();
        lstAccount.add(objAccount1);
        lstAccount.add(objAccount2);
        lstAccount.add(objAccount3);
        lstAccount.add(objAccount4);

        SaveWithQueueble.save(lstAccount);
        
        //creating record list
        Account objAccount5 = TestingUtility.createAccount('Test Account 66', true);
        Account objAccount6 = TestingUtility.createAccount('Test Account 77', true);
        Account objAccount7 = TestingUtility.createAccount('Test Account 88', true);
        Account objAccount8 = TestingUtility.createAccount('Test Account 99', true);
        
        lstAccountIds.add(objAccount5);
        lstAccountIds.add(objAccount6);
        lstAccountIds.add(objAccount7);
        lstAccountIds.add(objAccount8);
        List<Account> lstTempAccount = new List<Account>();
        Integer i=1;
        //Updating inserted records, changing the name and add to temp list for save, Its for old records having Id 
        for (Account account : lstAccountIds){
            account.Name = 'Test'+i;
            lstTempAccount.add(account);
            i++;
        }
        debug.Log('Ids -- :' + lstAccountIds );
        SaveWithQueueble.save(lstTempAccount);       
    }
}