/************************************************************************************************************************************
    Author      :   Rohit Nimase
    Description :   This class contain all test methods related to SOSLSearchController class.
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE           Issue No.    AUTHOR                DETAIL
    1           7 Feb 2019     STL-127    Rohit Nimase           Initial Developement
**************************************************************************************************************************************/
@isTest
public class SOSLSearchControllerTest {
    /************************************************************************************************************************************
        Author 			: Rohit Nimase
        Description 	: This method has setup data for all test methods 
        Created Date	: 7 Feb 2019 
		Issue No.		: STL-127
    **************************************************************************************************************************************/
    @TestSetup
    static void initData(){          
        SalesConsoleSettings.createSettings();
        List<Contact> lstContacts = (List<Contact>)TestingUtility.getRecords(new Map<String, Object>{'objName' => 'Contact', 'numberOfRecords' => 4});
        List<Account> lstAccounts = (List<Account>)TestingUtility.getRecords(new Map<String, Object>{'objName' => 'Account', 'numberOfRecords' => 4});
        List<Lead> lstLeads = (List<Lead>)TestingUtility.getRecords(new Map<String, Object>{'objName' => 'Lead', 'numberOfRecords' => 3, 'doInsert' => true});
    }
  
    /************************************************************************************************************************************
       	Author 			: Rohit Nimase
        Description 	: This method is used to test getRecordsWithSOSLSearch method.
        Created Date	: 7 Feb 2019 
		Issue No.		: STL-127
  **************************************************************************************************************************************/
    public static testMethod void verifyGetRecordsWithSOSLSearch(){
        string keywordToSearch1 = 'john';
        string keywordToSearch2 = 'Test';
        string objWithFields = '{"contact":["Id", "Name", "Email", "Account.Id", "Account.Name", "Account.UUID__c", "Interested_in_Number_of_Desks__c", "Phone", "Number_of_Full_Time_Employees__c"], "lead":["Id", "Name", "Email", "Phone", "Company", "Number_of_Full_Time_Employees__c", "Interested_in_Number_of_Desks__c", "Account__c"]}'; 
        String strLimit = '3'; 
        string whereClause = '{"lead":"WHERE isConverted=false"}';
       
        List<Id> lstLeadContactIds = new List<Id>();
        for(Lead objLead : [SELECT Id, Name, Email FROM Lead LIMIT 3]){
            lstLeadContactIds.add(objLead.Id);
        }
        List<Id> lstContactIds = new List<Id>();
        for(Contact objContact : [SELECT Id, Name, Email FROM Contact LIMIT 3]){
            lstLeadContactIds.add(objContact.Id);
        }
        System.assertEquals(6, lstLeadContactIds.size());        
        Test.setFixedSearchResults(lstLeadContactIds);        
      	
        DatabaseResult result = SOSLSearchController.getRecordsWithSOSLSearch(keywordToSearch1, objWithFields, strLimit, whereClause);
        System.assertNotEquals(null, result.data);
        List<List<sObject>> lstObjects = (List<List<sObject>>) result.data;
        System.assertEquals(3, lstObjects[0].size());
        System.assertEquals(3, lstObjects[1].size());
	 }
}