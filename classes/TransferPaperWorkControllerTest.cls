/************************************************************************************************************************************
    Author      :   Prashant Mane
    Description :   This class contain all test methods related to TransferPaperwork class.
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1           10 Jan 2019         Prashant Mane           Initial Developement
**************************************************************************************************************************************/
@isTest
public class TransferPaperWorkControllerTest {
    @TestSetup
    /************************************************************************************************************************************
   	    Author 				: Rohit Nimase
   	    Description 		: This method is used to create test Data.
   	    Created Date		: 21 Jan 2019 
	**************************************************************************************************************************************/
    static void initData(){
        SalesConsoleSettings.createSettings();
        Test.startTest();
        List<Account> lstAccount = (List<Account>)TestingUtility.getRecords(new Map<String, Object>{'objName' => 'Account', 'numberOfRecords' => 5, 'doInsert' => true});
        List<Contact> lstContact = (List<Contact>)TestingUtility.getRecords(new Map<String, Object>{'objName' => 'Contact', 'numberOfRecords' => 2, 'doInsert' => true});
        List<Billing_Account__c> lstBillingAccounts = (List<Billing_Account__c>)TestingUtility.getRecords(new Map<String, Object>{'objName' => 'Billing_Account__c', 'numberOfRecords' => 5, 'doInsert' => true, 'method' => 'simpleBillingAccount'});        
        List<Opportunity> lstOpportunities = new List<Opportunity>();
        for( Integer Index = 0 ; Index < lstBillingAccounts.size(); Index++ ){
            lstOpportunities.Add(((List<Opportunity>)TestingUtility.getRecords(new Map<String, Object>{'objName' => 'Opportunity', 'numberOfRecords' => 1, 'doInsert' => true, 'mapFieldValues' => new Map<String, List<Object>>{'Contract_Stage__c' => new List<Object>{'Contract Sent'}, 'Billing_Account__c' => new List<Object>{lstBillingAccounts[Index].Id}}}))[0]);
        }
       Test.stopTest();
    }
    
   /************************************************************************************************************************************
   	    Author 				: Jitesh Adwani
   	    Description 		: This method tests isValidOppforTransferPaperwork.
   	    Created Date		: 07 June 2018 
	-------------------------------------------------------------------------------------------------------------------------------------
		Last Modified By	: Milanjeet Singh
		Description`		: Test scenarios according to TransferPaperworkComntroller
		Issue No.			: ST-2547

		Last Modified By	: Rohit Nimase
        Last Modified Date	: 21 Jan 2019
		Issue No.			: CSI-1571
    **************************************************************************************************************************************/
    static testMethod void verifyIsValidOppforTransferPaperwork(){
        List<Account> lstAccount = [SELECT Id, Name, Account_Type__c, RecordTypeId FROM Account LIMIT 5];
        List<Contact> lstContact = [SELECT Id, accountID, Name FROM Contact LIMIT 2];
        List<Billing_Account__c> lstBillingAccount = [SELECT Id, Parent_Account__c, Name FROM Billing_Account__c LIMIT 5];
        List<Opportunity> lstOpportunity = [SELECT Id, Name FROM Opportunity LIMIT 5];
        
        lstAccount[0].RecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Mid Market').getRecordTypeId();
        lstAccount[1].RecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Mid Market').getRecordTypeId();
        TestingUtility.updateListWithAssert(lstAccount);
        
        //Updating billing account uuid as blank for uuid error on Transfer PW
        lstBillingAccount[0].Parent_Account__c = lstAccount[0].Id;
        lstBillingAccount[0].UUID__c = '';
        lstBillingAccount[1].Parent_Account__c = lstAccount[1].Id;
        TestingUtility.updateListWithAssert(lstBillingAccount);
        
        //Updating Opportunity with Stage other than TransferPaperwork Setting
        lstOpportunity[0].AccountId = lstAccount[0].Id;
        lstOpportunity[0].Primary_Member__c = lstContact[0].Id;
        lstOpportunity[0].StageName = 'Close Lost';
        lstOpportunity[0].Lost_Reason__c = 'Not Interested';
        lstOpportunity[0].CloseDate = system.today().addDays(5);
        lstOpportunity[0].Membership_Agreement_Notes__c = 'Opprtunity 1 Membership_Agreement_Notes__c';
        lstOpportunity[0].Tour_Notes__c = 'Opprtunity 1 Tour_Notes__c';
        lstOpportunity[0].Tour_Outcome_Notes__c = 'Opprtunity 1 Tour_Notes__c';
        lstOpportunity[0].Description = 'Opprtunity 1 Tour_Notes__c'; 
        lstOpportunity[0].Contract_Stage__c = 'Contract Sent';
        lstOpportunity[0].Owner_Auto_Assign__c = true; 
        
        //Updating Opportunity with Stage from TransferPaperwork and Contract Stage is not from Setting
        lstOpportunity[1].AccountId = lstAccount[0].Id;
        lstOpportunity[1].Primary_Member__c = lstContact[0].Id;
        lstOpportunity[1].StageName = 'Selling';
        lstOpportunity[1].CloseDate = system.today().addDays(5);
        lstOpportunity[1].Membership_Agreement_Notes__c = 'Opprtunity 2 Membership_Agreement_Notes__c';
        lstOpportunity[1].Tour_Notes__c = 'Opprtunity 2 Tour_Notes__c';
        lstOpportunity[1].Tour_Outcome_Notes__c = 'Opprtunity 2 Tour_Notes__c';
        lstOpportunity[1].Description = 'Opprtunity 2 Tour_Notes__c'; 
        lstOpportunity[1].Owner_Auto_Assign__c = true; 
        lstOpportunity[1].Contract_Stage__c = 'Contract Signed';
        
        Account accRec4 = new Account();
        accRec4.Name = 'StrAccountName';
        accRec4.Account_Type__c = 'Bill';
        insert accRec4;
        
        //Updating Opportunity Stage and Contract Stage from Setting having billing account with No UUID
        lstOpportunity[2].AccountId = lstAccount[0].Id;
        lstOpportunity[2].Primary_Member__c = lstContact[0].Id;
        lstOpportunity[2].StageName = 'Selling';
        lstOpportunity[2].CloseDate = system.today().addDays(5);
        lstOpportunity[2].Membership_Agreement_Notes__c = 'Opprtunity 3 Membership_Agreement_Notes__c';
        lstOpportunity[2].Tour_Notes__c = 'Opprtunity 3 Tour_Notes__c';
        lstOpportunity[2].Tour_Outcome_Notes__c = 'Opprtunity 3 Tour_Notes__c';
        lstOpportunity[2].Description = 'Opprtunity 3 Tour_Notes__c'; 
        lstOpportunity[2].Owner_Auto_Assign__c = true; 
        lstOpportunity[2].Contract_Stage__c = 'Contract Sent';
        lstOpportunity[2].Billing_Account__c = lstBillingAccount[0].Id;
        
        //Updating Opportunity Stage and Contract Stage from Setting having billing account having UUID
        lstOpportunity[3].AccountId = lstAccount[1].Id;
        lstOpportunity[3].Primary_Member__c = lstContact[0].Id;
        lstOpportunity[3].StageName = 'Selling';
        lstOpportunity[3].CloseDate = system.today().addDays(5);
        lstOpportunity[3].Membership_Agreement_Notes__c = 'Opprtunity 4 Membership_Agreement_Notes__c';
        lstOpportunity[3].Tour_Notes__c = 'Opprtunity 4 Tour_Notes__c';
        lstOpportunity[3].Tour_Outcome_Notes__c = 'Opprtunity 4 Tour_Notes__c';
        lstOpportunity[3].Description = 'Opprtunity 4 Tour_Notes__c'; 
        lstOpportunity[3].Owner_Auto_Assign__c = true; 
        lstOpportunity[3].Billing_Account__c = lstBillingAccount[1].Id;
        lstOpportunity[3].Contract_Stage__c = 'Contract Sent';
        
        //Updating Opportunity Stage and Contract Stage from Setting having no billing account
        lstOpportunity[4].AccountId = lstAccount[1].Id;
        lstOpportunity[4].Primary_Member__c = lstContact[0].Id;
        lstOpportunity[4].StageName = 'Selling';
        lstOpportunity[4].CloseDate = system.today().addDays(5);
        lstOpportunity[4].Membership_Agreement_Notes__c = 'Opprtunity 4 Membership_Agreement_Notes__c';
        lstOpportunity[4].Tour_Notes__c = 'Opprtunity 4 Tour_Notes__c';
        lstOpportunity[4].Tour_Outcome_Notes__c = 'Opprtunity 4 Tour_Notes__c';
        lstOpportunity[4].Description = 'Opprtunity 4 Tour_Notes__c'; 
        lstOpportunity[4].Owner_Auto_Assign__c = true; 
        lstOpportunity[4].Billing_Account__c = lstBillingAccount[1].Id;
        lstOpportunity[4].Contract_Stage__c = 'Contract Sent';
        TestingUtility.updateListWithAssert(lstOpportunity);
        
        //Defining the error for asserts
        String oppStageError = 'You are not allowed to transfer this paperwork. Please check the Opportunity Stage.';
        String oppContractStageError = 'You are not allowed to transfer this paperwork. Please check the Contract Stage.';
        String oppBillingAccountUUIDError = 'You are not allowed to transfer this paperwork as uuid is not present on Opportunity\'s Billing Account.';
        TransferPaperWorkController.ValidResultWithOpp result;
        String strResult;
        
        //Assertions for Opportunity whose Stage is not from the Setting
        strResult = TransferPaperWorkController.isValidOppforTransferPaperwork(lstOpportunity[0].Id);
        result = (TransferPaperWorkController.ValidResultWithOpp)JSON.deserialize(strResult,TransferPaperWorkController.ValidResultWithOpp.class);
        System.assertEquals(result.isValid, false, 'Opportunity should not be valid');
        System.assertEquals(result.errorMsg ,oppStageError ,'errorMsg for Opportunity Stage is not matched');
        
        //Assertions for Opportunity whose Contact Stage is not from the Setting
        strResult = TransferPaperWorkController.isValidOppforTransferPaperwork(lstOpportunity[1].Id);
        result = (TransferPaperWorkController.ValidResultWithOpp)JSON.deserialize(strResult,TransferPaperWorkController.ValidResultWithOpp.class);
        System.assertEquals(result.isValid, false, 'Opportunity should not be valid');
        System.assertEquals(result.errorMsg ,oppContractStageError ,'errorMsg for Contract Stage is not matched');
        
        DatabaseResult strResult1 = TransferPaperWorkController.isValidOpportunityforTransferPaperwork(lstOpportunity[1].Id);
        String strResult2 = String.valueOf(strResult1.Data);
        result = (TransferPaperWorkController.ValidResultWithOpp)JSON.deserialize(strResult2,TransferPaperWorkController.ValidResultWithOpp.class);
        System.assertEquals(result.isValid, false, 'Opportunity should not be valid');
        System.assertEquals(result.errorMsg ,oppContractStageError ,'errorMsg for Contract Stage is not matched');
        
        DatabaseResult nullResult = TransferPaperWorkController.isValidOpportunityforTransferPaperwork(null);
        System.assertEquals(null, nullResult.data);
        
        //Assertions for Opportunity having billing account with no uuid
        strResult = TransferPaperWorkController.isValidOppforTransferPaperwork(lstOpportunity[2].Id);
        result = (TransferPaperWorkController.ValidResultWithOpp)JSON.deserialize(strResult,TransferPaperWorkController.ValidResultWithOpp.class);
        System.assertEquals(result.isValid, false, 'Opportunity should not be valid');
        System.assertEquals(result.errorMsg ,oppBillingAccountUUIDError ,'errorMsg for UUID Stage is not matched');
        
        //Assertions for Opportunity having billing account with uuid
        strResult = TransferPaperWorkController.isValidOppforTransferPaperwork(lstOpportunity[3].Id);
        result = (TransferPaperWorkController.ValidResultWithOpp)JSON.deserialize(strResult,TransferPaperWorkController.ValidResultWithOpp.class);
        System.assertEquals(result.isValid, true, 'Opportunity should valid');
        
        //Assertions for Opportunity not having billing account
        strResult = TransferPaperWorkController.isValidOppforTransferPaperwork(lstOpportunity[4].Id);
        result = (TransferPaperWorkController.ValidResultWithOpp)JSON.deserialize(strResult,TransferPaperWorkController.ValidResultWithOpp.class);
        System.assertEquals(result.isValid, true, 'Opportunity should be valid');
    }
}