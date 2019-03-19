public with sharing class CustomSettingsServices {
	public static void loadDefaultTestValues() {
		//get object
		WWSync_Setup__c setup = CustomSettingsServices.default();
	}

	public static WWSync_Setup__c default() {
		//get object
		WWSync_Setup__c setup = WWSync_Setup__c.getOrgDefaults();
		
		if (Test.isRunningTest()) {
			//load defaults
			setup.token__c 		= 'abc123456';
			setup.endpoint__c = 'wework.testapi.com/app/test';
			setup.payment_endpoint__c = 'payments.wework.com/api/';
			setup.email_catcher_contact_id__c = null;
			setup.apex_notification_email__c = 'cmhelp@wework.com';

			//dml
			upsert setup;	
		}

		return setup;	
	}
}