/************************************************************************************************************************************
	Author 		: Anant Kumar	
	Description : This class will contain the business logic of DiscountTriggers.

History:
----------------------------------------------------------------------------------------------------------------------------------
	VERSION			DATE				AUTHOR					DETAIL												ISSUE
	1				07 July 2016		Anant Kumar				Code moved from DiscountStartDate trigger.			-
	2				13 January 2018		Kishor Shinde			added new trigger structure							-
**************************************************************************************************************************************/

public with sharing class DiscountTriggerHandler extends ITriggerHandler{
 	/************************************************************************************************************************************
      Author 			: Krishana Tupe
      Description 		: This is ITriggerHandler constructor which will be used in future.
      Created Date		: 01 February 2018          
    **************************************************************************************************************************************/   
    public DiscountTriggerHandler(){
        super('Discount__c');
    }   
   	/************************************************************************************************************************************
      Author 				: Krishana Tupe
      Description 			: This method overrides before insert method from ITriggerHander which will control the execution flow.
      Last Modified Date	: 01 February 2018
      Last Modified By		: Krishana Tupe (added Comment)
	**************************************************************************************************************************************/
    public override void BeforeInsert(List<SObject> listNewItems){
    	if(TriggerSettings.mappedField.Discount_VerifyStartDate){
    		verifyStartDate(listNewItems,null,null,null);
    	}		
    }
    /************************************************************************************************************************************
       Author 			: -
       Description 		: verifyStartDate.
       Created Date		:	-
       Modified Date 	: 01 February 2018
       Last Modified By	: Krishana Tupe	  
    **************************************************************************************************************************************/ 
    public static void verifyStartDate(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems) {
        Set<Id> oppIdSet = new Set<Id>();
        for (Discount__c discount : (List<Discount__c>)listNewItems) {
            if(String.isBlank(discount.Discount_Type__c)){
                oppIdSet.add(discount.Opportunity__c);
            } else if(discount.Discount_Type__c.toLowerCase() != 'commitment term')//ST-2202 ByPassing the validation when discount type is commitment term for contract event
            	oppIdSet.add(discount.Opportunity__c);
        }
        Debug.log('listNewItems ::'+listNewItems);
        Debug.log('oppIdSet ::'+oppIdSet);
        if(oppIdSet.size() > 0){
            Map<Id, Opportunity> allDiscountOnOpportunity = (new Map<Id, Opportunity>([SELECT Id, (SELECT start_date__c FROM Discounts__r) FROM Opportunity WHERE Id in:oppIdSet]));
            Debug.log('test ::'+allDiscountOnOpportunity);
            for(Discount__c target : (List<Discount__c>)listNewItems) {        
                if(allDiscountOnOpportunity.get(target.Opportunity__c) != null && allDiscountOnOpportunity.get(target.Opportunity__c).Discounts__r != null){
                    for(Discount__c oldDiscount: allDiscountOnOpportunity.get(target.Opportunity__c).Discounts__r){
                        if (oldDiscount.start_date__c == target.start_date__c) 
                            target.addError(
                                new GenericExceptions.DiscountStartDateException(
                                    'There is an existing discount for the given start date'
                                ),	false 			
                            );
                    }
                }
            } 
        }
    }   
}