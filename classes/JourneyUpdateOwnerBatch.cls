/*
 * Created By : Amol Darekar
 * Date : 20/Dec/2016
 */
global class JourneyUpdateOwnerBatch implements Database.Batchable<SObject>, Schedulable {
  
     global void execute(SchedulableContext SC) {
       JourneyUpdateOwnerBatch JourneyOwnerBatch = new JourneyUpdateOwnerBatch();
       ID batchprocessid = Database.executeBatch(JourneyOwnerBatch );
   }
    
    global Database.QueryLocator start(Database.BatchableContext context) {
        Datetime beforeOneHour = datetime.now().addHours(-1);
        return Database.getQueryLocator('SELECT Id, OwnerId,Primary_Lead__c FROM Journey__c WHERE CreatedDate >: beforeOneHour AND Lead_Source__c = \'Event\' AND Primary_Lead__c != null');
    }
    
	global void execute(Database.BatchableContext context, List<Journey__c> lstJourneysToUpdate) {
		
		Datetime beforeOneHour = datetime.now().addHours(-1);
		boolean journeyUpdateFlag = false;
		set<Id> setPrimaryLeadIds = new set<Id>();
        
        Debug.log('lstJourneysToUpdate::'+lstJourneysToUpdate);
		
		for(Journey__c currentJourney : lstJourneysToUpdate)
		{
			    setPrimaryLeadIds.add(currentJourney.Primary_Lead__c);
		}
		
		map<Id,Lead> mapJourneyPrimaryLead = new map<Id,Lead>([SELECT Id, Name, OwnerId FROM Lead WHERE Id IN:setPrimaryLeadIds AND CreatedDate >: beforeOneHour]);	
		
        Debug.log('mapJourneyPrimaryLead::'+mapJourneyPrimaryLead);
        
		for(Journey__c currentJourney : lstJourneysToUpdate)
		{
			if(mapJourneyPrimaryLead.containsKey(currentJourney.Primary_Lead__c) && mapJourneyPrimaryLead.get(currentJourney.Primary_Lead__c).ownerId != currentJourney.ownerId)
			{
				currentJourney.ownerId = mapJourneyPrimaryLead.get(currentJourney.Primary_Lead__c).ownerId;
			    journeyUpdateFlag = true;
			}
		}
		
		if(journeyUpdateFlag)
			update lstJourneysToUpdate;
	}
    
    global void finish(Database.BatchableContext context) {
        
    }

}