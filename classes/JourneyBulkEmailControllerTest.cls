@isTest
private class JourneyBulkEmailControllerTest {
	/*static testMethod void TestJourneyDetailsController() {
		JourneyBulkEmailController testObject = new JourneyBulkEmailController();
        //Test Account created for testContact.
        Account testAccount = new Account();
        	testAccount.Name = 'Test Account';
		insert testAccount;
		//Test Contact created for testJourney.
        Contact testContact = new Contact();
    	 	testContact.AccountId = testAccount.Id;
    	 	testContact.firstname = 'TestFirstName';
    	 	testContact.lastname = 'TestLastName';
         	testContact.Email = 'Test111@example.com';
         	testContact.Status__c = 'active';
        insert testContact;
	    System.assertNotEquals(testContact.Id, null);
		     
	    Journey__c testJourney = new Journey__c();
            testJourney.Name = 'testJourneyName';
            testJourney.CurrencyIsoCode = 'USD';
            testJourney.Primary_Contact__c = testContact.Id;
            testJourney.NMD_Next_Contact_Date__c = Date.today();
	    TestingUtility.insertWithAssert(testJourney);
        
        EmailTemplate objEmailTemplate = new EmailTemplate();
        EmailTemplate objEmailTemplateFetch = new EmailTemplate();
        //objEmailTemplate = [select Id, HtmlValue, Body, Subject,TemplateType From EmailTemplate Limit 1];
        objEmailTemplate = [select Id, HtmlValue, Body, Subject,TemplateType From EmailTemplate where TemplateType ='visualforce' AND isActive = true Limit 1];
        
        objEmailTemplateFetch = JourneyBulkEmailController.fetchEmailTemplate(objEmailTemplate.Id);
        String resultContactEmail = JourneyBulkEmailController.sendEmail(objEmailTemplate.Id,testJourney.Id);
        debug.Log('resultContactEmail>>' + resultContactEmail);
        system.assertEquals('Email Send Successfully.',resultContactEmail);
        
        EmailTemplate objEmailTemplate2 = new EmailTemplate(); 
            
        objEmailTemplate2 = [select Id, HtmlValue, Body, Subject,TemplateType From EmailTemplate where TemplateType !='visualforce' AND isActive = true Limit 1];
        List<Lead> listLeads = new List<Lead>();
        Lead leadNew = new Lead();
            leadNew.LastName = 'lastName';
            leadNew.Company = 'company';
            leadNew.Email = 'email@example.com';
            leadNew.Phone = '9874563210';
        insert leadNew;
        
        testJourney.Primary_Contact__c = null;
        testJourney.Primary_Lead__c = leadNew.Id;
        update testJourney;
        String resultLeadEmail = JourneyBulkEmailController.sendEmail(objEmailTemplate2.Id,testJourney.Id);
        system.assertEquals('Email Send Successfully.',resultLeadEmail); 
        debug.Log('resultLeadEmail>>' + resultLeadEmail);
    }*/
}