/************************************************************************************************************************************
    Author 		: 	RamseySolutions	
    Description : 	This class contain buisness logic for DocusignStatus trigger.

    History		:
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE				AUTHOR					DETAIL
	1			07 July 2016		Aanat Kumar			Initial Developement
**************************************************************************************************************************************/
public with sharing class DocuSignStatusTriggerHandler extends ITriggerHandler {
	
	public DocuSignStatusTriggerHandler(){
        super('dsfs__DocuSign_Status__c');
    }
    /************************************************************************************************************************************
        Author 				: 	Aanat Kumar
        Description 		: 	This method overrides after insert method from ITriggerHander which will control the execution flow.
        Created Date		:	07 July 2016
	**************************************************************************************************************************************/
    public override void AfterInsert(List<SObject> listNewItems, Map<Id, SObject> mapNewItems)
    {
		closeOpportunities(listNewItems, mapNewItems,null,null);	
	}
	/************************************************************************************************************************************
        Author 				: 	Aanat Kumar
        Description 		: 	This method overrides after update method from ITriggerHander which will control the execution flow.
        Created Date		:	07 July 2016
	**************************************************************************************************************************************/
    public override void AfterUpdate(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems)
    {
		closeOpportunities(listNewItems, mapNewItems, listOldItems, mapOldItems);		
	}
	/************************************************************************************************************************************
        Author 				: 	Aanat Kumar
        Description 		: 	This method will close opportunities.
        Created Date		:	07 July 2016
	**************************************************************************************************************************************/
    public static void closeOpportunities(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems)
 	{
        if(TriggerSettings.mappedField.DocuSign_CloseOpportunity)
        {
            Set<Id> opportunityIds = new Set<Id>();
            Map<Id, dsfs__DocuSign_Status__c> oldDocuSignMap = (Map<Id, dsfs__DocuSign_Status__c>)mapOldItems;
            for (dsfs__DocuSign_Status__c docuSignStatus:(List<dsfs__DocuSign_Status__c>) listNewItems) {
                
                if (docuSignStatus.dsfs__Opportunity__c != null &&
                    docuSignStatus.dsfs__Envelope_Status__c == 'Completed' &&
                    (Trigger.isInsert || oldDocuSignMap.get(docuSignStatus.Id).dsfs__Envelope_Status__c != 'Completed')) {
                    //(Trigger.isInsert || oldDocuSignMap.get(docuSignStatus.Id).dsfs__Envelope_Status__c != 'Completed')) {
        
                    opportunityIds.add(docuSignStatus.dsfs__Opportunity__c);
                }
            }
            
            if (!opportunityIds.isEmpty()) {
                OpportunityServices.closeOpportunities(opportunityIds);
            }
        }
 	}
	
}