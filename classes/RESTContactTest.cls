@isTest
private class RESTContactTest {
    
    static void initFieldMappings() {
        SalesConsoleSettings.createSettings();
    }
    
    //contact_sfId == null With no existing contact/lead with given email.
    @isTest static void test_post_success_1() {
        //pre-context
    	initFieldMappings();
        //test
        Test.startTest();
			RestRequest req     = new RestRequest(); 
        	RestResponse res    = new RestResponse();
      
        	// pass the req and resp objects to the method         
            req.requestURI = System.URL.getSalesforceBaseURL().toExternalForm() + '/services/apexrest/Person';   
            req.httpMethod = 'POST';

            //assign rest context
            RestContext.request     = req;
            RestContext.response    = res;
            
            //define container and set request Company and Reservable UUIDs
            WWTypes.Person typeMember = new WWTypes.Person();
            typeMember.company_name = 'A company';
            typeMember.last_name = 'Kumar';
            typeMember.first_name = 'Anant';
            typeMember.email = 'anant@test.com';
            typeMember.type = 'broker';
            
            //submit post
            RESTContact.Response response = RESTContact.doPost(typeMember);
        	System.assertEquals(true, response.success);
        Test.stopTest();
    }
    
    //contact_sfId == null With no existing contact with given email.
	@isTest static void test_post_success_2() {
        //pre-context
    	initFieldMappings();
        //test
        Test.startTest();
			RestRequest req     = new RestRequest(); 
        	RestResponse res    = new RestResponse();
      
        	// pass the req and resp objects to the method         
            req.requestURI = System.URL.getSalesforceBaseURL().toExternalForm() + '/services/apexrest/Person';   
            req.httpMethod = 'POST';

            //assign rest context
            RestContext.request     = req;
            RestContext.response    = res;
            
        	Account company = TestingUtility.createAccount('strAccountName', false);
        	company.Type = 'Licensee';
        	TestingUtility.insertWithAssert(company);
        	Contact existingContact = TestingUtility.createContact(company.Id, 'strLastName', false);
        	existingContact.Email = 'anant@test.com';
        	TestingUtility.insertWithAssert(existingContact);
        
            //define container and set request Company and Reservable UUIDs
            WWTypes.Person typeMember       = new WWTypes.Person();
            typeMember.company_name                = 'A company';
            typeMember.last_name                   = 'Kumar';
            typeMember.first_name                  = 'Anant';
            typeMember.email                       = 'anant@test.com';
            typeMember.type                        = 'Employee';
            
            //submit post
            RESTContact.Response response = RESTContact.doPost(typeMember);
    		System.assertEquals(true, response.success);
            
        Test.stopTest();
    }
    
    //contact_sfId != null.
	@isTest static void test_post_success_3() {
        //pre-context
    	initFieldMappings();
        //test
        Test.startTest();
			RestRequest req     = new RestRequest(); 
        	RestResponse res    = new RestResponse();
      
        	// pass the req and resp objects to the method         
            req.requestURI = System.URL.getSalesforceBaseURL().toExternalForm() + '/services/apexrest/Person';   
            req.httpMethod = 'POST';

            //assign rest context
            RestContext.request     = req;
            RestContext.response    = res;
            
        	Account company = TestingUtility.createAccount('strAccountName', true);
        	Contact existingContact = TestingUtility.createContact(company.Id, 'strLastName', false);
        	existingContact.Email = 'anant@test.com';
        	TestingUtility.insertWithAssert(existingContact);
        
            //define container and set request Company and Reservable UUIDs
            WWTypes.Person typeMember       = new WWTypes.Person();
            typeMember.company_name                = 'A company';
            typeMember.last_name                   = 'Kumar';
            typeMember.first_name                  = 'Anant';
            typeMember.email                       = 'anant@test.com';
            typeMember.type                        = 'broker';
        	typeMember.contact_sfid                = existingContact.Id;
            
            //submit post
            RESTContact.Response response = RESTContact.doPost(typeMember);
    		System.assertEquals(true, response.success);
            
        Test.stopTest();
    }
    
    //contact_sfId == null but existing lead available with given Emailid.
	@isTest static void test_post_success_4() {
        //pre-context
    	initFieldMappings();
        //test
        Test.startTest();
			RestRequest req     = new RestRequest(); 
        	RestResponse res    = new RestResponse();
      
        	// pass the req and resp objects to the method         
            req.requestURI = System.URL.getSalesforceBaseURL().toExternalForm() + '/services/apexrest/Person';   
            req.httpMethod = 'POST';

            //assign rest context
            RestContext.request     = req;
            RestContext.response    = res;
        	
        	Account fakeAccount = TestingUtility.createAccount('Lead Conversion Account', true);
        
        	Lead existingLead = new Lead();
        	existingLead.LastName = 'Kumar';
        	existingLead.Company = 'A company';
        	existingLead.Status = 'Open';
        	existingLead.LeadSource = 'wework.com';
        	existingLead.Email = 'anant@test.com';
        	TestingUtility.insertWithAssert(existingLead);
        
            //define container and set request Company and Reservable UUIDs
            WWTypes.Person typeMember       = new WWTypes.Person();
            typeMember.company_name                = 'A company';
            typeMember.last_name                   = 'Kumar';
            typeMember.first_name                  = 'Anant';
            typeMember.email                       = 'anant@test.com';
            typeMember.type                        = 'broker';
            
            //submit post
            RESTContact.Response response = RESTContact.doPost(typeMember);
    		System.assertEquals(true, response.success);
            
        Test.stopTest();
    }
}