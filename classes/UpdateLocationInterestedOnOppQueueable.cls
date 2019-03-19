public class UpdateLocationInterestedOnOppQueueable implements Queueable {
    public Opportunity objOpporturnity;
    public Id pAccountId;
    public Id pContactId;
    public String buildingName;
    public Id buildingId;
    public WWTypes.InboundLead pInboundLead;
    public UpdateLocationInterestedOnOppQueueable(Id AccountId, Id ContactId, WWTypes.InboundLead objInboundLead){
        this.pInboundLead = objInboundLead;
        this.pAccountId = AccountId;
        this.pContactId = ContactId;
    }
	public void execute(QueueableContext context) {
		sleep(8000);
        if(pInboundLead.tour_building_uuid != null || String.isNotBlank(pInboundLead.tour_building_uuid))
        	buildingName = BuildingHandler.getMultipicklistValuesFromUUID( new String[] { pInboundLead.tour_building_uuid });
        if(pInboundLead.opportunity_id != null || String.isNotBlank(pInboundLead.opportunity_id)){
        	this.objOpporturnity = OpportunityServices.getOpportunitybySFId(pInboundLead.opportunity_id);
            Debug.log('getOpportunitybySFId ==>> '+ this.objOpporturnity);
        } else {
			this.objOpporturnity = OpportunityServices.get_latest_open_opportunity_by_primary_member(pAccountId, pContactId, buildingName);
			Debug.log('get_latest_open_opportunity_by_primary_member ==>> '+ this.objOpporturnity);
		}
        
        if(pInboundLead.tour_building_uuid != null || String.isNotBlank(pInboundLead.tour_building_uuid))
			buildingId = BuildingHandler.getBuildingIdByUUID(pInboundLead.tour_building_uuid);
		
        if(this.objOpporturnity.locations_interested__c != null){ 
            debug.log('locations_interested__c of Opportunity != null ::'+ this.objOpporturnity.locations_interested__c);
            Set<String> location_Interested = new Set<String>(this.objOpporturnity.locations_interested__c.split(';'));
            location_Interested.add(buildingName);
            this.objOpporturnity.locations_interested__c = String.join(new List<String>(location_Interested),';');
            debug.log('updated locations_interested__c of Opportunity ::'+ this.objOpporturnity.locations_interested__c);
        } else {
            debug.log('locations_interested__c of Opportunity == null ::'+ buildingName);
            if(this.objOpporturnity != null)
            	this.objOpporturnity.locations_interested__c = buildingName;
        }		
        /*if(buildingId != null){
            //this.objOpporturnity.Building__c = buildingId;
        }*/
        if(this.objOpporturnity != null)
        	update this.objOpporturnity;
    }
	private static void sleep(Long milliSeconds){
		Long timeDiff = 0;
		DateTime firstTime = System.now();
		do
		{
			timeDiff = System.now().getTime() - firstTime.getTime();
		}
		while(timeDiff <= milliSeconds);
	}
}