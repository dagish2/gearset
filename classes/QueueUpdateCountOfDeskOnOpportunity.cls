/**
 * Created By : Mayuresh Ghodke
 * Created Date : 3 June 2017
 * Comment : Queueable class for ST-910 functionality. Which will call from Tour Trigger.
 			Change normal method to Queueable method as after updating Opportunities Count_of_Desk__c there is no any other operation to work.
 */
public class QueueUpdateCountOfDeskOnOpportunity implements Queueable {
	List<Tour_Outcome__c> triggerNew = new List<Tour_Outcome__c>();
	
	public QueueUpdateCountOfDeskOnOpportunity(List<Tour_Outcome__c> triggerNew){
		//this.triggerNew = triggerNew;
	}
	
	public void execute(QueueableContext context) {
		/*set<Id> setPrimaryContact = new set<Id>(); //Contains Primary contact of Tour triggerNew
        set<Id> setLastModifiedJourney = new set<Id>(); //Contains Last Modified Journey
        Map<Id, Tour_Outcome__c> mapTourWithJourneyId = new Map<Id, Tour_Outcome__c>();
        Map<Id, Opportunity> mapOpportunityToUpdate = new Map<Id, Opportunity>();
        Map<Id,Journey__c> mapJourneyToUpdate = new Map<Id,Journey__c>();
        Set<Id> setOpportunityIds = new Set<Id>();
        for(Tour_Outcome__c tourRec : triggerNew){
            if(tourRec.Primary_Member__c != null)    
                setPrimaryContact.add(tourRec.Primary_Member__c);
        }
        
        //List of Journey order by LastModifiedDate desc
        List<Journey__c> lstJourney = new List<Journey__c>();
       
        if(setPrimaryContact.size() > 0)
        	lstJourney = new List<Journey__c>([Select Id, Name, LastModifiedDate, Status__c, Primary_Contact__c, Building_Interested_In__c, Count_of_Desk__c From Journey__C Where Primary_Contact__c IN : setPrimaryContact order by LastModifiedDate desc]); //AND LastModifiedDate > :Datetime.now().addMinutes(-15)
        Debug.log('lstJourney :: '+lstJourney);
        
        Map<Id, Journey__c> mapOfJourneys = new Map<Id, Journey__c>(lstJourney);
        
        for(Journey__c journeyRec : lstJourney){
            Debug.log('journeyRec :: '+journeyRec);
            if(!setLastModifiedJourney.contains(journeyRec.Primary_Contact__c)){
                setLastModifiedJourney.add(journeyRec.Primary_Contact__c);
                mapJourneyToUpdate.put(journeyRec.Primary_Contact__c,journeyRec);
            } 
        }
        Debug.log('Test : setLastModifiedJourney ::: ' + setLastModifiedJourney);
        Debug.log('Test : mapJourneyToUpdate ::: ' + mapJourneyToUpdate);
        for(Tour_Outcome__c tourRec : triggerNew){
            Debug.log('Test : tourRec ::: ' + tourRec);
            if(tourRec.Opportunity__c != null)
                setOpportunityIds.add(tourRec.Opportunity__c);
            if(tourRec.Journey__c == null)
            {
                Journey__c journeyRec = mapJourneyToUpdate.get(tourRec.Primary_Member__c);
                Debug.log('Test : journeyRec ::: ' + journeyRec);
                if(journeyRec != null){
                    if((journeyRec.Primary_Contact__c == tourRec.Primary_Member__c) && 
                       (journeyRec.Building_Interested_In__c == tourRec.Location__c) 
                      ){
                          tourRec.Journey__c = journeyRec.Id;
                          mapTourWithJourneyId.put(journeyRec.Id, tourRec);
                      }
                    if((journeyRec.Primary_Contact__c == tourRec.Primary_Member__c) && 
                       (journeyRec.Building_Interested_In__c == null)                   
                      ){
                          tourRec.Journey__c = journeyRec.Id;
                          mapTourWithJourneyId.put(journeyRec.Id, tourRec);
                    }
                }
            }
        }
       //Map<Id, Opportunity> mapOpportunities = new Map<Id, Opportunity>([SELECT Id, Count_of_Desk__c FROM Opportunity Where Id in : setOpportunityIds]);
       Map<Id, Opportunity> mapOpportunities = new Map<Id, Opportunity>();
       if(setOpportunityIds.size() > 0){
           for(Opportunity oppRec : [SELECT Id, Count_of_Desk__c FROM Opportunity Where Id in : setOpportunityIds]){
               mapOpportunities.put(oppRec.Id, oppRec);    
           }
       } 
       Debug.log('Test : mapTourWithJourneyId ::: ' + mapTourWithJourneyId);
        //Changes to populate Count_of_Desks on Tour's Opportunity
        for(Journey__c journey : mapOfJourneys.values()){
            if(mapTourWithJourneyId.get(journey.Id) != null){
                Id oppId = mapTourWithJourneyId.get(journey.Id).Opportunity__c;
                if(oppId != null){
	                Opportunity getOpp = mapOpportunities.get(oppId);
	                Debug.log('Test : getOpp ::: ' + getOpp);
	                if(getOpp.Count_of_Desk__c == null && mapTourWithJourneyId.get(journey.Id) != null){
	                    Opportunity opp = new Opportunity();
	                    opp.Id = oppId;
	                    opp.Count_of_Desk__c = journey.Count_of_Desk__c;
	                    mapOpportunityToUpdate.put(opp.Id, opp);
	                }
                }
            }
        }
        Debug.log('Test : mapOpportunityToUpdate ::: ' + mapOpportunityToUpdate);
        
        if(mapOpportunityToUpdate.size() > 0)
        	update mapOpportunityToUpdate.values();*/
	}
	
    
}