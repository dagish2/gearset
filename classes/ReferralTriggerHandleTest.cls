/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
/************************************************************************************************************************************
	Author 		: -
	Description : This class contains unit test cases for ReferralTriggerHandler.
 	
History:
----------------------------------------------------------------------------------------------------------------------------------
VERSION			DATE				AUTHOR					DETAIL							ISSUE
1				-			-								Initial Developement			-
2				01 February 2018	Krishana Tupe			Added new trigger structure.	-			
**************************************************************************************************************************************/
@isTest
private class ReferralTriggerHandleTest {
    
 /************************************************************************************************************************************
	Author 				: Krishana Tupe
	Description 		: This static block used to get all salesconsole settings for this class.
	Last Modified Date	: 01 February 2018
	Last Modified By	: Krishana Tupe
**************************************************************************************************************************************/
    static{
        SalesConsoleSettings.createSettings();       
    }
    
 /************************************************************************************************************************************
	Author 				: Krishana Tupe
	Description 		: This test method is used to verify PreventDuplicateActiveReference.
	Last Modified Date	: 01 February 2018
	Last Modified By	: Krishana Tupe (Comment added)
**************************************************************************************************************************************/   
   static testMethod void PreventDuplicateActiveReference() {
        Account accRec = TestingUtility.createAccount('strAccountName', true);
        Contact referrer1 = new Contact();
        referrer1.LastName = 'referrer1';
        referrer1.Email = 'referrer1@example.com';
        TestingUtility.insertWithAssert(referrer1);
        
        Contact referrer2 = new Contact();
        referrer2.LastName = 'referrer1';
        referrer2.Email = 'referrer2@example.com';
        TestingUtility.insertWithAssert(referrer2);
        
        Referral__c reference1 = new Referral__c();
        reference1.Referral_Email__c= 'referenced1@example.com';
        reference1.IsActive__c = true;
        reference1.Referrer__c = referrer1.Id;
        reference1.Expires_On__c = Date.today().addDays(60);
        TestingUtility.insertWithAssert(reference1);
       
       try{ 
        reference1 = new Referral__c();
        reference1.Referral_Email__c= 'referenced123@example.com';
        reference1.IsActive__c = true;
        reference1.Referrer__c = referrer1.Id;
        reference1.Expires_On__c = Date.today().addDays(60);
        TestingUtility.insertWithAssert(reference1);
       }
       catch(Exception ex){
       	 Debug.log('Exception::'+ex);
       }
    }
}