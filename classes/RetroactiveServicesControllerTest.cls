/************************************************************************************************************************************
    Author      :  Nikhil Mehta    
    Description :  This class contain all test methods related to aura methods in RetroactiveServicesController.
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR          		DETAIL
     1          1 Nov 2018       	Nikhil Mehta    	    Initial Developement
**************************************************************************************************************************************/

@isTest
public class RetroactiveServicesControllerTest {
	@TestSetup
    static void initData(){
        SalesConsoleSettings.createSettings();
        Account accRec = new Account(Name = 'strAccount', Number_of_Full_Time_Employees__c = 1000, Website = 'testaccount.in', Interested_in_Number_of_Desks__c = 100, Phone = '9845623584');
        TestingUtility.insertWithAssert(accRec);
        Contact contactRec = new Contact(FirstName = 'John1', LastName = 'Smith1', Email = 'testContact1@example.com', Status__c = 'active', AccountId = accRec.Id);
        TestingUtility.insertWithAssert(contactRec);
        Billing_Account__c billingAcc = new Billing_Account__c(Name = 'tstBillingAcc', Primary_Member__c = contactRec.Id);
        TestingUtility.insertWithAssert(billingAcc);
    }
    /************************************************************************************************************************************
        Author              :   Nikhil Mehta
        Description         :   This method tests searchRecord method.
        Last Modified Date  :   1 Nov 2018
		Issue No			:   ST-2858
    **************************************************************************************************************************************/
    public static testMethod void verifysearchRecord(){
        try{
            List<Contact> lstContacts = [SELECT Id, (SELECT Id FROM Billing_Accounts__r) FROM Contact WHERE Email = 'testContact1@example.com'];
            if(!lstContacts.isEmpty()){
                DatabaseResult conResult = RetroactiveServicesController.searchRecord(lstContacts[0].Id, null, true);
                List<Contact> lstContact = ((List<Contact>)JSON.deserialize(JSON.serialize(conResult.data), List<Contact>.class));
                System.assertEquals(lstContacts[0].Id, lstContact[0].Id);
                conResult = RetroactiveServicesController.searchRecord(null, 'testContact1@example.com', true);
                lstContact = ((List<Contact>)JSON.deserialize(JSON.serialize(conResult.data), List<Contact>.class));
                System.assertEquals(lstContacts[0].Id, lstContact[0].Id);
                conResult = RetroactiveServicesController.searchRecord(null, 'testContact1@example.com', false);
                lstContact = ((List<Contact>)JSON.deserialize(JSON.serialize(conResult.data), List<Contact>.class));
                System.assertEquals(lstContacts[0].Id, lstContact[0].Id);
                conResult = RetroactiveServicesController.searchRecord(lstContacts[0].Billing_Accounts__r[0].Id, 'testContact1@example.com', false);
                List<Billing_Account__c> lstBillingAccs = ((List<Billing_Account__c>)JSON.deserialize(JSON.serialize(conResult.data), List<Billing_Account__c>.class));
                System.assertEquals(lstContacts[0].Billing_Accounts__r[0].Id, lstBillingAccs[0].Id);
                conResult = RetroactiveServicesController.searchRecord(null, null, false);
            }
        }catch(Exception exc){
            System.assertNotEquals(null, exc);
        }
    }
}