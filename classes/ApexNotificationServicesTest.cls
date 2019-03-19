@isTest
private class ApexNotificationServicesTest {
	
	private class TestException extends Exception{}

	@isTest static void test_1() {
		//pre-context
			TestException t = new TestException('This is a test exception');

		//test
		Test.startTest();
			//Integer before = Limits.getEmailInvocations();
			
			ApexNotificationServices.notify(t, 'summary here');
			
			ApexNotificationServices.generic_notify('john@doe.com', 'subject', 'summary here');
			
			ApexNotificationServices.notify(t);

			//Integer after = Limits.getEmailInvocations();
			
			/* Commented by Mayuresh Ghodke on 25 June 2016
			* system.assertNotEquals(); In Comment :: We can not send Emails from Sandbox.
			*/ 
			
			/*
			system.assertNotEquals(
				before, 
				after,
				'An email should be sent with a notification!'
			);
			*/
		Test.stopTest();
	}

}