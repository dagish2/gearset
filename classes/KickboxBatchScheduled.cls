/**
* @Created By   	: Mayuresh Ghodke
* @Created Date 	: 26-Dec-2016
* @Issue No.		: ST-684
* @Comment			: Class will run every night at 1AM. And call to CheckEmailQuality,
*					which will fetch YESTERDAY Leads or contact and send emails to Kickbox API to verify email Ids.
*/ 
global class KickboxBatchScheduled implements Schedulable {
	global void execute(SchedulableContext sc) {
        Debug.log('In KickboxBatchScheduled ::');
       	String LeadQuery = 'Select id,email from Lead Where CreatedDate = YESTERDAY AND  Email_Quality__c = null Limit 2';	
		String ContactQuery = 'Select id,email from Contact Where CreatedDate = YESTERDAY AND Email_Quality__c = null Limit 2';
        Boolean regularBatch = true;
      	CheckEmailQuality objCheckEmailQuality = new CheckEmailQuality(LeadQuery,ContactQuery,regularBatch); 
      	database.executebatch(objCheckEmailQuality);
   }
}