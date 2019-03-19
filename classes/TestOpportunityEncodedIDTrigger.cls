@isTest
private class TestOpportunityEncodedIDTrigger {
	//We should delete this test class as we already deleted OpportunityStageToTour trigger.
	//Test code moved to OpportunityTriggerHandlerTest class.
	//Commmented By : Anant Kumar
	//Date : 23/June/2016
	/*
	@isTest static void test_x() {
		//pre-context
			Setting__c testSettings = new Setting__c();
	       	testSettings.Name = 'OpportunityFromLatestOpportunity';
	       	testSettings.Data__c = '{"LeadSource":{"name":"LeadSource","overwrite":false},"Lead_Source_Detail__c":{"name":"Lead_Source_Detail__c","overwrite":true},"utm_campaign__c":{"name":"utm_campaign__c","overwrite":true},"utm_campaign_id__c":{"name":"utm_campaign_id__c","overwrite":false},"utm_content__c":{"name":"utm_content__c","overwrite":false},"utm_medium__c":{"name":"utm_medium__c","overwrite":true},"utm_source__c":{"name":"utm_source__c","overwrite":false},"utm_term__c":{"name":"utm_term__c","overwrite":false}}';
	       	TestingUtility.insertWithAssert(testSettings);
       		
       		Triggers__c triggers = new Triggers__c(Name= 'Triggers');
         	triggers.Opportunity_Upate_Encoded_ID__c= true;
       		TestingUtility.insertWithAssert(triggers);
       		
			Building__c b = new Building__c(
				Name='b1',
				uuid__c = 'abc123'
			);
			insert b;

			Opportunity o = new Opportunity(				
				CloseDate 	= system.today(),
				StageName 	= 'Qualifying',
				Name 				= 'test Opoortunity',
				Building__c	= b.Id
			);
			insert o;		//test

		Test.startTest();
			o = [SELECT Encoded_Id__c FROM Opportunity WHERE id = :o.Id LIMIT 1];
			system.assertEquals(
				EncodingHandler.encode(o.Id),
				o.Encoded_Id__c,
				'The Opportunity was not correctly encoded.'
			);
			
		Test.stopTest();
	}
	*/
}