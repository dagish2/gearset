/************************************************************************************************************************************
	Author 		:  Amol Darekar
	Description : This class contains methods get called from DealTrigger 

History:
----------------------------------------------------------------------------------------------------------------------------------
	VERSION			DATE				AUTHOR					DETAIL							ISSUE
	1				13 May 2016			Amol Darekar			Initial Developement			-
**************************************************************************************************************************************/

public class DealsTriggerHandler extends ITriggerHandler{
    /************************************************************************************************************************************
      Author 			: Krishana Tupe
      Description 		: This is ITriggerHandler constructor which will be used in future.
      Created Date		: 01 February 2018          
    **************************************************************************************************************************************/   
	 public DealsTriggerHandler(){ 
        super('Deal__c');      
    }
    
   	/************************************************************************************************************************************
      Author 				: Krishana Tupe
      Description 			: This method overrides before update method from ITriggerHander which will control the execution flow.
      Last Modified Date	: 01 February 2018
      Last Modified By		: Krishana Tupe (added Comment)
	**************************************************************************************************************************************/
     public override void BeforeUpdate(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems){		
        updateClosedDealStatusToBlank(listNewItems, mapNewItems, listOldItems, mapOldItems);
    }
	       
    /************************************************************************************************************************************
        Author 				: Amol Darekar  
        Description 		: This method used for Set Deal Gate(Phase__c) value to Blank when Deal Status is Closed.
        Last Modified Date	: 13 May 2016
        Last Modified By	: Sunil Bhosale
        Issue No. 			: ST-325
    **************************************************************************************************************************************/ 
    public static void updateClosedDealStatusToBlank(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems){ 
        if(TriggerSettings.mappedField.Deal_SetClosedDealStatusToBlank){
            List<Deal__c> lstDeals = listNewItems;            
            for(Deal__c currentDeal : lstDeals){
                if(currentDeal.Status__c == 'Closed'){
                    currentDeal.Phase__c ='';
                }
            }	
        }
    }
}