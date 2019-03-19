/************************************************************************************************************************************
    Author 		: Ajaysinh Chauhan
    Description : Test class for Helper for BatchToFindDuplicateAccounts for generting csv and sending email.

    History:
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE				AUTHOR					DETAIL
    1			27 Mar 2018			Ajaysinh Chauhan    	Initial Developement.
**************************************************************************************************************************************/
@isTest
public class CSVGeneratorTests {
    /************************************************************************************************************************************
        Author 		: Ajaysinh Chauhan
        Description : Test method for BatchToFindDuplicateAccounts for generting csv.
    
        History:
        ----------------------------------------------------------------------------------------------------------------------------------
        VERSION		DATE				AUTHOR					DETAIL
        1			27 Mar 2018			Ajaysinh Chauhan    	Initial Developement.
	**************************************************************************************************************************************/
    @isTest
    public static void verifyGenerateCSV(){
        List<Account> lstAccounts = new List<Account>{new Account(Name='testName1',Website='testWebsite1'),new Account(Name='testName2',Website='testWebsite2')};
        List<String> lstHeaders = new List<String>{'Name','Website'};
        String strCSV = CSVGenerator.generateCSV(lstHeaders,lstAccounts);
        System.assertEquals('testName1,testWebsite1 \ntestName2,testWebsite2 \n', strCSV);
    }
    /************************************************************************************************************************************
        Author 		: Ajaysinh Chauhan
        Description : Test method for BatchToFindDuplicateAccounts for sending email.
    
        History:
        ----------------------------------------------------------------------------------------------------------------------------------
        VERSION		DATE				AUTHOR					DETAIL
        1			27 Mar 2018			Ajaysinh Chauhan    	Initial Developement.
	**************************************************************************************************************************************/
    @isTest
    public static void verifySendEmail(){
        Integer beforeInvocations = Limits.getEmailInvocations();
        CSVGenerator.sendEmail('testName1,testWebsite1\ntestName2,testWebsite2',new List<String>{'girish.bhandari@enzigma.in'},'DuplicateAccount.csv','Duplicate Accounts','Please find the attachment for generated duplicate accounts csv.');
    	System.assertEquals(1,Limits.getEmailInvocations());
    }
}