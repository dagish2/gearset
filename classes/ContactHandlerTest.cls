/**
*Modified By: Dipak Pawar
*Modified Date: 14 July 2016
*/
@isTest
private class ContactHandlerTest {
    static {
       /* List<Setting__c> lstSettings = new List<Setting__c>();
        lstSettings.add(new Setting__c(Name = 'AccountCleansingSetting',Data__c = '{"starts_with":["The","An","A"],"ends_with":["pvt","ltd"],"specialCharacters":"@#^&*!():?/><"}'));
        Insert lstSettings;*/
        SalesConsoleSettings.createSettings();
    }
  /*static void initFieldMappings() {
      
        Setting__c testSettings = new Setting__c();
        testSettings.Name = 'Lead:Lead and Lead Source Details';
        testSettings.Data__c = '{"LeadSource":[{"name":"Broker","OverrideLeadSoruce":true}], "LeadSourceDetails":["Broker1","Broker2" ]}]';
        TestingUtility.insertWithAssert(testSettings);
        
        Profile weworkSystemAdmin = [SELECT Id FROM Profile WHERE Name='WeWork Standard User'];
        Map<String,Object> userRecordMap = new Map<String,Object>();
        userRecordMap.put('LastName','Last Name 1');
        userRecordMap.put('Username','testweworkuser1@example.com');
        userRecordMap.put('Email','testweworkuser1@example.com');
        User user1 = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, userRecordMap, true); 
        
        testSettings = new Setting__c();
        testSettings.Name = 'User/Queue Journey Creation';
        testSettings.Data__c = '{"allowedUsers":[{"userName":"'+ user1.Username +'","Id":"'+user1.Id +'"}],"allowedQueues":[]}';
        TestingUtility.insertWithAssert(testSettings);
    }*/
    
/*    static testMethod void testPersonEndpoint_1() {
        // TO DO: implement unit test
        //pre-context
    	initFieldMappings();
    		//Insert Account
		        
		Account acc = new Account(Name = 'Test Company');
		insert acc;
        
		//Insert two contacts
		Contact c1 = new Contact(FirstName = 'Test',
								LastName = 'Contact1',
								AccountId = acc.Id,
								Email = 'testEmail_1@example.com',
								Phone = '3256987425');
		insert c1;
	    
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
        RESTContact.Response response;
        //Check if contact exist and lead not exist
        WWTypes.Person typeMember = new WWTypes.Person();
        typeMember = new WWTypes.Person();
        typeMember.contact_sfid = c1.Id;
        typeMember.company_name = 'Test Company';
        typeMember.last_name = 'Kumar';
        typeMember.first_name = 'Anant';
        typeMember.email = 'testEmail_1@example.com';
        typeMember.type = 'broker';
        //submit post
        
        response = RESTContact.doPost(typeMember);
        Test.stopTest();
        System.assertEquals(true,response.success);
        System.assertEquals(c1.Id, response.contact_sfid);
            
    }
*/
    
/*   static testMethod void testPersonEndpoint_2() {
        // TO DO: implement unit test
        //pre-context
    	initFieldMappings();
    		//Insert Account
		        
		Account acc = new Account(Name = 'Test Company');
		insert acc;
        
		//Insert two contacts
		Contact c1 = new Contact(FirstName = 'Test',
								LastName = 'Contact1',
								AccountId = acc.Id,
								Email = 'testEmail_1@example.com',
								Phone = '3256987425');
		insert c1;
		
		Contact contact = [select Id, Email, UUID__c from Contact where email=:c1.Email];
		
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
            RESTContact.Response response;
            //Check if contact exist and lead not exist
            WWTypes.Person typeMember = new WWTypes.Person();
	    	typeMember = new WWTypes.Person();
            typeMember.company_name = 'Test Company';
            typeMember.contact_uuid = contact.UUID__c;
            typeMember.last_name = 'Kumar';
            typeMember.first_name = 'Anant';
            typeMember.email = 'testEmail_1@example.com';
            typeMember.type = 'broker';
            //submit post
            
            response = RESTContact.doPost(typeMember);
            System.assertEquals(true,response.success);
        	System.assertEquals(c1.Id, response.contact_sfid);
            
    }*/
    
/*    static testMethod void testPersonEndpoint_3() {
        // TO DO: implement unit test
        //pre-context
    	initFieldMappings();
    		//Insert Account
		Account acc = new Account(Name = 'Test Company');
		insert acc;
        
		//Insert two contacts
		Contact c1 = new Contact(FirstName = 'Test',
								LastName = 'Contact1',
								AccountId = acc.Id,
								Email = 'testEmail_1@example.com',
								Phone = '3256987425');
		insert c1;
    	
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
            RESTContact.Response response;
            //Check if contact exist and lead not exist
            WWTypes.Person typeMember = new WWTypes.Person();
	    	typeMember = new WWTypes.Person();
            typeMember.company_name = 'Test Company';
            typeMember.last_name = 'Kumar';
            typeMember.first_name = 'Anant';
            typeMember.email = 'testEmail_1@example.com';
            typeMember.type = 'broker';
            //submit post
            
            response = RESTContact.doPost(typeMember);
            System.assertEquals(true,response.success);
            System.assertEquals(c1.Id, response.contact_sfid);
    }
    
    static testMethod void testPersonEndpoint_4() {
        // TO DO: implement unit test
        //pre-context
    	initFieldMappings();
    		//Insert Account
		Account acc = new Account(Name = 'Test Company');
		insert acc;
        
		//Insert two contacts
		Contact c1 = new Contact(FirstName = 'Test',
								LastName = 'Contact1',
								AccountId = acc.Id,
								Email = 'testEmail_1@example.com',
								Phone = '3256987425',
								UUID__c = '31343639-3032-4373-b035-323436333134');								
		insert c1;
    	
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
            RESTContact.Response response;
            //Check if contact exist and lead not exist
            WWTypes.Person typeMember = new WWTypes.Person();
	    	typeMember = new WWTypes.Person();
            typeMember.company_name = 'Test Company';
            typeMember.last_name = 'Kumar';
            typeMember.first_name = 'Anant';
            typeMember.email = 'testEmail_1@example.com';
            typeMember.contact_uuid = '31343639-3032-4373-b035-323436333134';
            typeMember.type = 'broker';
            //submit post
            
            response = RESTContact.doPost(typeMember);
            System.assertEquals(true,response.success);
            System.assertEquals(c1.Id, response.contact_sfid);
            System.assertEquals(c1.UUID__c, response.contact_uuid);
    }
    
    static testMethod void testPersonEndpoint_5() {
        // TO DO: implement unit test
        //pre-context
    	initFieldMappings();
    		//Insert Account
		Account acc = new Account(Name = 'Test Company');
		insert acc;
        
		//Insert two contacts
		Contact c1 = new Contact(FirstName = 'Test',
								LastName = 'Contact1',
								AccountId = acc.Id,
								Email = 'testEmail_1@example.com',
								Phone = '3256987425',
								UUID__c = '31343639-3032-4373-b035-323436333134');								
		insert c1;
    	
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
            RESTContact.Response response;
            //Check if contact exist and lead not exist
            WWTypes.Person typeMember = new WWTypes.Person();
	    	typeMember = new WWTypes.Person();
            typeMember.company_name = 'Test Company';
            typeMember.last_name = 'Kumar';
            typeMember.first_name = 'Anant';
            typeMember.email = 'testEmail_2@example.com';
            typeMember.contact_uuid = '31343639-3032-4373-b035-323436333134';
            typeMember.type = 'broker';
            //submit post
            
            response = RESTContact.doPost(typeMember);
            System.assertEquals(false,response.success);
            System.assertNotEquals(c1.Id, response.contact_sfid);
            System.assertNotEquals(c1.UUID__c, response.contact_uuid);
    }
*/ 
/*    static testMethod void testPersonEndpoint_6() {
        // TO DO: implement unit test
        //pre-context
    	initFieldMappings();
    		//Insert Account
		Account acc = new Account(Name = 'Test Company');
		insert acc;
        
        //If lead exist with matching contact and remove primary_lead__c and assigne priamry_contact__c for journey present for lead
        Lead lead = prepareLead('Smith', 'WeWork Test Company', 'testEmail_13420@example.com', null);
        Lead leadOriginal = lead;
        lead.Company = 'Test Company';
        lead.Generate_Journey__c = false;
        insert lead;
        System.assert(lead.Id != null);
        debug.log('Lead: '+lead);
        Journey__c testJourney = new Journey__c();
        testJourney.Name = 'testJourneyName';
        testJourney.CurrencyIsoCode = 'USD';
        testJourney.Primary_Lead__c = lead.Id;
        testJourney.NMD_Next_Contact_Date__c = Date.today();
        insert testJourney;
        System.assert(testJourney.Id != null);
        
        Contact c1 = new Contact(FirstName = 'Test',
                                 LastName = 'Contact1',
                                 AccountId = acc.Id,
                                 Email = 'testEmail_13420@example.com',
                                 Phone = '3256987425');
        insert c1;
        Debug.log('lead ::'+lead);
        Test.startTest();
        RestRequest req 	= new RestRequest(); 
    	RestResponse res 	= new RestResponse();
	 
        req.requestURI = System.URL.getSalesforceBaseURL().toExternalForm() + '/services/apexrest/Person';   
        req.httpMethod = 'POST';
          
        //assign rest context
        RestContext.request 	= req;
        RestContext.response 	= res;
          
        WWTypes.Person typeMember = new WWTypes.Person();
        typeMember = new WWTypes.Person();
        typeMember.last_name = 'Kumar';
        typeMember.first_name = 'Anant';
        typeMember.company_name = 'Microsoft';
        typeMember.phone = '9146185355';
        typeMember.lead_source = 'Facebook';
        typeMember.lead_source_detail = 'Facebook Details';
        typeMember.utm_campaign_id = '701230000009Gd5';
        typeMember.utm_campaign = 'San Francisco - Modifier';
        typeMember.utm_content = 'utm contents';
        typeMember.utm_medium = 'cpc';
        typeMember.utm_source = 'ads-google';
        typeMember.utm_term = 'virtual +office +san +francisco';
        typeMember.locale = 'US';
        typeMember.country_code = 'US';
        typeMember.email = 'testEmail_13420@example.com';
        typeMember.type = 'Employee';
	        
        list<Journey__c> lstJourney = new list<Journey__c>();
        lstJourney = [select Id,Name,Primary_Lead__c from Journey__c where Primary_Lead__c =: lead.Id];
        System.assertEquals(1, lstJourney.size());
        
        RESTContact.Response response = RESTContact.doPost(typeMember);
        debug.log('response: '+response);
        Test.stopTest();
        System.assertEquals(true, response.success);
        list<Contact> lstContact = new list<Contact>();	  
        lstContact = [select Id, Name from Contact where Id =: response.contact_sfid];
        System.assertEquals(1,lstContact.size());
    }
    
	static testMethod void testPersonEndpoint_7() {
        // TO DO: implement unit test
        //pre-context
    	initFieldMappings();
    	
    	Account acc = new Account(Name = 'Test Company', UUID__c = '31343639-3032-4373-b035-323436333134');
		insert acc;
    		
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
	        
	        //Check if contact not exist with given account uuid or company name and account exist
	        WWTypes.Person typeMember = new WWTypes.Person();
	        typeMember = new WWTypes.Person();
            typeMember.company_name = 'Test Company';
            typeMember.last_name = 'Kumar';
            typeMember.first_name = 'Anant';
        	typeMember.email = 'testEmail@example.com';
            typeMember.account_uuid = '31343639-3032-4373-b035-323436333134';
            typeMember.type = 'broker';
            
            RESTContact.Response response;
            //submit post
            response = RESTContact.doPost(typeMember);
            System.assertEquals(true, response.success); 
            list<Account> lstAccount = [Select Id, Name  from Account where UUID__c =: acc.UUID__c];
            System.assertEquals(1,lstAccount.size());
        	list<Contact> lstContact = [Select Id, Email  from Contact where Email =: typeMember.email];
        	System.assertEquals(1,lstCOntact.size());
        Test.stopTest();
	}
*/
/*	static testMethod void testPersonEndpoint_8() {
        // TO DO: implement unit test
        //pre-context
    	initFieldMappings();
    	
    	Account acc = new Account(Name = 'Test Company', UUID__c = '31343639-3032-4373-b035-323436333134');
		insert acc;
    		
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
	        
	        //Check if contact not exist with given account uuid or company name and account exist
	        WWTypes.Person typeMember = new WWTypes.Person();
	        typeMember = new WWTypes.Person();
            typeMember.company_name = 'Test Company 2';
            typeMember.last_name = 'Kumar';
            typeMember.first_name = 'Anant';
            typeMember.account_uuid = '31343639-3032-4373-b035-323436333134';
            typeMember.type = 'broker';
            
            RESTContact.Response response;
            //submit post
            response = RESTContact.doPost(typeMember);
            Debug.Log('acc.UUID__c::'+acc.UUID__c);
            list<Account> lstAccount = [Select Id,Name from Account where UUID__c =: acc.UUID__c];
           
            System.assertEquals(1,lstAccount.size());
            System.assertEquals(false, response.success);
            System.assertEquals(acc.Name, lstAccount[0].Name);                        
            
        Test.stopTest();
	}
	
	static testMethod void testPersonEndpoint_9() {
        // TO DO: implement unit test
        //pre-context
    	initFieldMappings();
    	
    	Account acc = new Account(Name = 'Test Company', UUID__c = '31343639-3032-4373-b035-323436333134');
		insert acc;
    		
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
	        
	        //Check if contact not exist with given account uuid or company name and account exist
	        WWTypes.Person typeMember = new WWTypes.Person();
	        typeMember.company_name = 'Test Company';
            typeMember.last_name = 'Kumar';
            typeMember.first_name = 'Anant';
            typeMember.email = 'testEmail@example.com';
            typeMember.account_uuid = '31343639-3032-4373-b035-323436333134';
            typeMember.type = 'broker';
            
            RESTContact.Response response;
            //submit post
            response = RESTContact.doPost(typeMember);
            
            list<Account> lstAccount = [Select Id, Name, UUID__c  from Account where UUID__c =: acc.UUID__c];
            System.assertEquals(1,lstAccount.size());
            
            list<Contact> lstContact = [Select Id, Name, AccountId  from Contact where Id =: response.contact_sfid];
            System.assertEquals(1,lstContact.size());
            
            System.assertEquals(true, response.success);
            System.assertEquals(lstContact[0].AccountId, lstAccount[0].Id);                        
            
        Test.stopTest();
	}
	
	static testMethod void testPersonEndpoint_10() {
        // TO DO: implement unit test
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
	        
	        //Check if contact not exist with given account uuid or company name and account exist
	        WWTypes.Person typeMember = new WWTypes.Person();
	        typeMember = new WWTypes.Person();
            typeMember.last_name = 'Kumar';
            typeMember.first_name = 'Anant';
            typeMember.email = 'testEmail_1@example.com';
            typeMember.type = 'broker';
            
            RESTContact.Response response;
            //submit post
            response = RESTContact.doPost(typeMember);
            string comapny_name = typeMember.first_name+' '+typeMember.last_name;
            
            list<Account> lstAccount = [Select Id, Name  from Account where Name =: comapny_name];
            System.assertEquals(1,lstAccount.size());
            
            list<Contact> lstContact = [Select Id, Name, AccountId  from Contact where Email =: typeMember.email];
        	System.assertEquals(1,lstContact.size());
        	
        	System.assertEquals(true, response.success);
        	System.assertEquals(lstContact[0].Id, response.contact_sfid);
        Test.stopTest();
	}
	
    static testMethod void testPersonEndpoint_12() {
        // TO DO: implement unit test
        //pre-context
    	initFieldMappings();
    		
        //test
        Test.startTest();
			RestRequest req     = new RestRequest(); 
        	RestResponse res    = new RestResponse();
      
        	// pass the req and resp objects to the method         
            req.requestURI = System.URL.getSalesforceBaseURL().toExternalForm() + '/services/apexrest/Person';   
            req.httpMethod = 'POST';
			
			Account acc = new Account(Name = 'Test Company');
			insert acc;
			
            //assign rest context
            RestContext.request     = req;
            RestContext.response    = res; 
              	//Check if account not exist
            WWTypes.Person typeMember = new WWTypes.Person();
        	typeMember = new WWTypes.Person();
            typeMember.company_name = 'Test Company';
            typeMember.last_name = 'Kumar';
            typeMember.first_name = 'Anant';
            typeMember.email = 'john.smith@test.wework.com';
            typeMember.contact_uuid =  UUIDHandler.generateVersion4();
            typeMember.account_uuid =  UUIDHandler.generateVersion4();
            typeMember.type = 'broker';
            
            //submit post
            RESTContact.Response response;
            response = RESTContact.doPost(typeMember);
            System.assertEquals(response.success,true);
        	
        	list<Account> lstAccounts = [select Id,Name from Account where Name =: typeMember.company_name];
        	System.assertEquals(2,lstAccounts.size());
        	
        	list<Contact> lstContact = [select Id,Name,AccountId from Contact where Email =: typeMember.email];
        	System.assertEquals(1,lstContact.size());
        Test.stopTest();
        	
    } 	
    static testMethod void testPersonEndpoint_13() {
        
        Account acc = new Account(Name = 'Test Company');
		insert acc;
        
		//Insert two contacts
		Contact c1 = new Contact(FirstName = 'Test',
								LastName = 'Contact1',
								AccountId = acc.Id,
								Email = 'john.smith@test.wework.com',
								Phone = '3256987425');
		insert c1;
    	Test.startTest();
			ContactHandler.checkContact(c1.Email);
        	
        	Lead testLead = new Lead();
        	testLead.LastName = 'Pawar';
        	testLead.Company = 'A company';
        	testLead.Status = 'Open';
        	testLead.LeadSource = 'wework.com';
        	testLead.Email = 'dipak@example.com';
        	TestingUtility.insertWithAssert(testLead);
        
        	ContactHandler.checkContact(testLead.Email);
       	Test.stopTest();
    }
    
    static testMethod void testPersonEndpoint_14() {
        // TO DO: implement unit test
        //pre-context
    	initFieldMappings();
    		
        //test
        Test.startTest();
			RestRequest req     = new RestRequest(); 
        	RestResponse res    = new RestResponse();
      
        	// pass the req and resp objects to the method         
            req.requestURI = System.URL.getSalesforceBaseURL().toExternalForm() + '/services/apexrest/Person';   
            req.httpMethod = 'POST';
			
			Account acc = new Account(Name = 'Test Company');
			insert acc;
			
            //assign rest context
            RestContext.request     = req;
            RestContext.response    = res; 
              	//Check if account not exist
            WWTypes.Person typeMember = new WWTypes.Person();
        	typeMember = new WWTypes.Person();
            typeMember.company_name = 'Test Company';
            typeMember.last_name = 'Kumar';
            typeMember.first_name = 'Anant';
            typeMember.email = '';
            typeMember.type = 'broker';
            
            //submit post
            RESTContact.Response response;
            response = RESTContact.doPost(typeMember);
            System.assertEquals(response.success,false);
        	
        Test.stopTest();
        	
    } 
    
    static testMethod void testPersonEndpoint_15() {
        // TO DO: implement unit test
        //pre-context
    	initFieldMappings();
    		
        //test
        Test.startTest();
			RestRequest req     = new RestRequest(); 
        	RestResponse res    = new RestResponse();
      
        	// pass the req and resp objects to the method         
            req.requestURI = System.URL.getSalesforceBaseURL().toExternalForm() + '/services/apexrest/Person';   
            req.httpMethod = 'POST';
			
			Account acc = new Account(Name = 'Test Company', UUID__c = '31343639-3032-4373-b035-323436333134');
			insert acc;
			
            //assign rest context
            RestContext.request     = req;
            RestContext.response    = res; 
              	//Check if account not exist
            WWTypes.Person typeMember = new WWTypes.Person();
        	typeMember = new WWTypes.Person();
            typeMember.company_name = '';
            typeMember.last_name = 'Kumar';
            typeMember.first_name = 'Anant';
            typeMember.email = 'testEmail@example.com';
        	typeMember.account_uuid = '31343639-3032-4373-b035-323436333134';
            typeMember.type = 'broker';
            
            //submit post
            RESTContact.Response response;
            response = RESTContact.doPost(typeMember);
            System.assertEquals(false,response.success);
        	
        Test.stopTest();
        	
    } 
    
    static testMethod void testPersonEndpoint_16() {
        // TO DO: implement unit test
        //pre-context
    	initFieldMappings();
    		
        //test
        Test.startTest();
			RestRequest req     = new RestRequest(); 
        	RestResponse res    = new RestResponse();
      
        	// pass the req and resp objects to the method         
            req.requestURI = System.URL.getSalesforceBaseURL().toExternalForm() + '/services/apexrest/Person';   
            req.httpMethod = 'POST';
			
			Account acc = new Account(Name = 'Test Company', UUID__c = '31343639-3032-4373-b035-123456123456');
			insert acc;
        
        	Contact c1 = new Contact(FirstName = 'Test',
								LastName = 'Contact1',
								AccountId = acc.Id,
								Email = 'testEmail_13420@example.com',
								Phone = '3256987425',
                                UUID__c = '31343639-3032-4373-b035-323436333134');
			insert c1;
			
            //assign rest context
            RestContext.request     = req;
            RestContext.response    = res; 
              	//Check if account not exist
            WWTypes.Person typeMember = new WWTypes.Person();
        	typeMember = new WWTypes.Person();
            typeMember.company_name = 'Test Company';
            typeMember.last_name = 'Kumar';
            typeMember.first_name = 'Anant';
            typeMember.email = 'testEmail_13420@example.com';
        	typeMember.account_uuid = '31343639-3032-4373-b035-323436333134';
            typeMember.type = 'broker';
            
            //submit post
            RESTContact.Response response;
            response = RESTContact.doPost(typeMember);
            System.assertEquals(response.success,false);
        	
        Test.stopTest();
        	
    }     
*/
}