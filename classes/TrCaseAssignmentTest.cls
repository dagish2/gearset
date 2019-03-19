/************************************************************************************************************************************
    Author 		: 	Rupesh Patil
    Description : 	This class will contain the test methods of TrCaseAssignment
    History:
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE				AUTHOR					DETAIL
	1			4 March 2019		Rupesh Patil 		    Initial Development	 
**************************************************************************************************************************************/
@isTest
public class TrCaseAssignmentTest {
	 @TestSetup
    static void initData(){
        SalesConsoleSettings.createSettings();
        Test.startTest();
        List<User> lstUsers = (List<User>)TestingUtility.getRecords(new Map<String, Object>{'objName' => 'User', 'numberOfRecords' => 2});
        List<Case> lstCases = (List<Case>)TestingUtility.getRecords(new Map<String, Object>{'objName' => 'Case', 'numberOfRecords' => 1});
        Test.stopTest();
    }
    /************************************************************************************************************************************
        Created By		: Rupesh Patil
        Created Date	: 22 Feb 2019 
		Description     : This method verifies CaseAssignment from TrCaseAssignment()
    **************************************************************************************************************************************/    
    public static testMethod void verifyCaseAssignmentBeforeUpdate(){
        List<Case> lstCases = [SELECT Id, OwnerId, RecordTypeId, REA_Region__c FROM Case LIMIT 1];
        List<User> lstUsers = [SELECT Id, Profile.Name FROM User Where ProfileId = '00eF0000000aice' and IsActive = true LIMIT 1];
        System.assert(lstCases.size() > 0);
        System.assert(lstUsers.size() > 0);       
       	lstCases[0].REA_Region__c = 'APAC';
        lstCases[0].OwnerId = lstUsers[0].Id;
        lstCases[0].RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('REA').getRecordTypeId();
        System.runAs(lstUsers[0]){
            Test.startTest();
            TestingUtility.updateListWithAssert(lstCases);
            Test.stopTest();
        }
        List<Case> lstNewCases = [SELECT Id, OwnerId, RecordTypeId, REA_Region__c FROM Case LIMIT 1];
        System.assertEquals(lstNewCases[0].REA_Region__c , 'APAC');
        System.assertEquals(lstNewCases[0].RecordTypeId, lstCases[0].RecordTypeId);
    }
    
    public static testMethod void verifyCaseAssignmentAfterInsert(){
        List<User> lstUsers = [SELECT Id, Profile.Name FROM User Where ProfileId = '00eF0000000aice' and IsActive = true LIMIT 1];
        List<Case> lstCases = new List<Case>();
		Case objCase = new Case(RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('REA').getRecordTypeId(), REA_Region__c = 'LatAm', Subject = 'Test Assignment', OwnerId = lstUsers[0].Id);
        lstCases.add(objCase);
        System.runAs(lstUsers[0]){
            Test.startTest();
            TestingUtility.insertListWithAssert(lstCases);
            Test.stopTest();
        }
        List<Case> lstNewCases = [SELECT Id, OwnerId, RecordTypeId, REA_Region__c FROM Case Where Subject = 'Test Assignment'];        
        System.assertEquals(lstNewCases[0].REA_Region__c , 'LatAm');
        System.assertEquals(lstNewCases[0].RecordTypeId, lstCases[0].RecordTypeId);     
    }
}