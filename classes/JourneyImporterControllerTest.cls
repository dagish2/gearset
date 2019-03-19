@isTest
public class JourneyImporterControllerTest {
    
    @TestSetup
    static void initData(){
        SalesConsoleSettings.createSettings();
        Test.startTest();
        List<Lead> lstLeads = (List<Lead>)TestingUtility.getRecords(new Map<String, Object>{'objName' => 'Lead', 'numberOfRecords' => 2});
        List<Contact> lstContacts = (List<Contact>)TestingUtility.getRecords(new Map<String, Object>{'objName' => 'Contact', 'numberOfRecords' => 4});
        List<Campaign> lstCampaigns = (List<Campaign>)TestingUtility.getRecords(new Map<String, Object>{'objName' => 'Campaign', 'numberOfRecords' => 1});       
        Test.stopTest();
    } 
    
	/************************************************************************************************************************************
		Author 				: Ashish Mishra
		Description 		: This method verifies the insertJourneysForKickbox() function.
		Created Date		: 19 June 2018 
		Last Modified By	: Rupesh Patil
		Last Modified Date  : 28 Nov 2018
   **************************************************************************************************************************************/
    public static testMethod void verifyinsertJourneysForKickbox(){
        List<Lead> lstLeads = [SELECT Id, Name, Email, OwnerId, LeadSource, Company FROM Lead Limit 2];
        List<Campaign> lstCampaigns = [SELECT Id FROM Campaign LIMIT 2];
        List<Contact> lstContacts = [SELECT Id, Name, Email, OwnerId, LeadSource, Status__c FROM Contact Limit 2];
        lstContacts[0].Status__c = 'active';
        lstLeads[1].Email = lstContacts[0].Email;
        List<sObject> lstObjects = new List<sObject>{lstContacts[0], lstLeads[1]};
        TestingUtility.updateListWithAssert(lstObjects);
        
        List<String> lstFailColumns = new List<string>{'Email, FirstName, Company','Status'};
        List<String> successColumns = new List<String>{'Email','FirstName','Company','Status'};
                
        //CSV String is Created
        String strCSV = '"First Name", "Last Name", "EMAIL", "Company", "Locations Interested", "Lead Source", "Lead Source Detail", "Generate Journey", "Status", "Phone"\n'+'"Wework", "Kickbox1", "Test3107_1@enzigma.com", "", "LA-Gas Tower", "wework.com", "Book A Tour Form",'+
                '"true", "Open","1234567890"\n'+'"Wework", "Kickbox1", "test79985464@example.com", "", "LA-Gas Tower", "wework.com", "Book A Tour Form", "true", "Open", "1234567890"\n'+'"Wework", "Kickbox1", "testexistinglead@example.com","","LA-Gas Tower","wework.com","Book A Tour Form","true","Open","1234567890"\n'+'"Wework","Kickbox1","Test3107_2@enzigma.com","Enzigma","LA-Gas Tower","","Book A Tour Form","true","Open","1234567891"\n'+'"Wework","Kickbox1","Test3107_3@enzigma.com","Enzigma","LA-Gas Tower","wework.com","Book A Tour Form","true","Open","1234567891"\n'+'"Wework","Kickbox1","Test3107_4@enzigma.com","Enzigma","LA-Gas Tower","wework.com","Book A Tour Form","true","Open","1234567891"\n';
        List<string> apinames = new List<string>{'Id', 'Email', 'LeadSource', 'OwnerId', 'Company'};
            
        //With Campaign
        DatabaseResult result = JourneyImporterController.insertJourneysForKickBoxImporter(lstLeads, strCSV, True, lstCampaigns[0].Id, apinames, lstFailColumns, successColumns);
        System.assertEquals(true, result.success, 'result message is incorrect Parameter pass');
        
        //Without Campaign
        result = JourneyImporterController.insertJourneysForKickBoxImporter(lstLeads, strCSV, True, Null, apinames, lstFailColumns, successColumns);
        System.assertEquals(true, result.success, 'result message is incorrect Parameter pass');
        
        try{
            result = JourneyImporterController.insertJourneysForKickBoxImporter(null, strCSV, True, Null, apinames, lstFailColumns, successColumns);
        }catch(Exception exc){
            System.assertNotEquals(null, exc);
        }
    }
}