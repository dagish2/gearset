/**
 * Used to test AccountPrimaryMember & OpportunityPrimaryMember triggers
 * 
 * @author	itadic@ramseysolutions.com
 * @since	04/03/2014
 */
@isTest
private class TestPrimaryMember {
	/*
    static testMethod void testPrimaryMembers() {
        Setting__c testSettings = new Setting__c();
       	testSettings.Name = 'OpportunityFromLatestOpportunity';
       	testSettings.Data__c = '{"LeadSource":{"name":"LeadSource","overwrite":false},"Lead_Source_Detail__c":{"name":"Lead_Source_Detail__c","overwrite":true},"utm_campaign__c":{"name":"utm_campaign__c","overwrite":true},"utm_campaign_id__c":{"name":"utm_campaign_id__c","overwrite":false},"utm_content__c":{"name":"utm_content__c","overwrite":false},"utm_medium__c":{"name":"utm_medium__c","overwrite":true},"utm_source__c":{"name":"utm_source__c","overwrite":false},"utm_term__c":{"name":"utm_term__c","overwrite":false},"createDuration":{"upto":"1 Months"}}';
       	TestingUtility.insertWithAssert(testSettings);
       	
        //Triggers__c triggers = new Triggers__c(Name= 'Triggers');
		//triggers.Update_Opportunity_Primary_Member__c= true;
		//insert triggers;
		 
        //Insert Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        //Insert two contacts
        Contact c1 = new Contact(FirstName = 'Test',
        						 LastName = 'Contact1',
                                 Email = 'testEmail1@example.com',
        						 AccountId = acc.Id);
        insert c1;
        Contact c2 = new Contact(FirstName = 'Test',
        						 LastName = 'Contact2',
                                 Email = 'testEmail2@example.com',
        						 AccountId = acc.Id);
        insert c2;
        
        //Update Account
        acc.Name = 'Test Account Updated';
        update acc;
        
        //Check if Primary Member is set to c1
        acc = [SELECT Id, Name, Primary_Member__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(acc.Primary_Member__c, c1.Id);
        
        //Insert Opportunity
        Opportunity opp = new Opportunity(Name = 'Test Opp',
        								  AccountId = acc.Id,
        								  StageName = 'Qualifying',
        								  CloseDate = Date.today(),
        								  number_of_desks_2016__c = '1');
        insert opp;
        
        //Check if Primary Member is set to c1
        opp = [SELECT Id, Primary_Member__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(opp.Primary_Member__c, c1.Id);
        
        //Update Opp Primary Member to c2
        opp.Primary_Member__c = c2.Id;
        update opp;
        
        //Check if Account Primary Member is set to c2
        acc = [SELECT Id, Name, Primary_Member__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(acc.Primary_Member__c, c2.Id);
        
    }
    */
}