/************************************************************************************************************************************
    Author 		: Shobhit Gahlot
    Description : This will contain all triggers on SuggestedDiscounts Object test
    
    History		:
----------------------------------------------------------------------------------------------------------------------------------
    VERSION	 DATE	        AUTHOR          DETAIL
    1	     05, Oct 2017   Shobhit Gahlot  Initial Developement
**************************************************************************************************************************************/
public with sharing class SuggestedDiscountsTriggerHandler extends ITriggerHandler{
   
	public SuggestedDiscountsTriggerHandler(){
        super('Suggested_Discounts__c');
    }
    
        /************************************************************************************************************************************
    Author :
    Issue No :
    Description : 
    Created Date :
    Last Modified Date	: 2 Feb, 2018
    Last Modified By	: Shivprasad Patil
**************************************************************************************************************************************/

    public override void BeforeInsert(List<SObject> listNewItems){
    	if(TriggerSettings.mappedField.SuggestedDiscounts_SetBuildingLocation){
    		setBuildingLocation(listNewItems,null,null,null);
    	}
    }
    
/************************************************************************************************************************************
Author :
Issue No :
Description : 
Created Date :
Last Modified Date	: 2 Feb, 2018
Last Modified By	: Shivprasad Patil
**************************************************************************************************************************************/
    
     public override void BeforeUpdate(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems){
		if(TriggerSettings.mappedField.SuggestedDiscounts_SetBuildingLocation){
    		setBuildingLocation(listNewItems,null,null,null);
    	}
    }
    
    
/************************************************************************************************************************************
Author :
Issue No :
Description : 
Created Date :
Last Modified Date	: 2 Feb, 2018
Last Modified By	: Shivprasad Patil
**************************************************************************************************************************************/
    
    public static void setBuildingLocation(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems){
        debug.log('inside setBuildingLocation::');
        Set<String> setBuildingUUIDs = new Set<String>();
        Map<String,String> mapLocationUUId = new Map<String,String>();
        boolean flag = true;
        for(Suggested_Discounts__c objSuggesstedDiscount : (List<suggested_Discounts__c>)listNewItems){
            if(objSuggesstedDiscount.Location_UUID__c != null)
              setBuildingUUIDs.add(objSuggesstedDiscount.Location_UUID__c);
            else{
                objSuggesstedDiscount.addError('Location UUID is compulsory field');
                flag = false;
            }             
        }
        debug.log('setBuildingUUIDs :: '+setBuildingUUIDs);
        if(setBuildingUUIDs.size() > 0 && setBuildingUUIDs != null){
            for(Building__c objBuilding : [SELECT Id, UUID__c FROM Building__c WHERE UUId__c  IN : setBuildingUUIDs])
                mapLocationUUId.put(objBuilding.UUID__c, objBuilding.Id);           
        }
         debug.log('mapLocationUUId :: '+mapLocationUUId);
        if(!mapLocationUUId.isEmpty()){
        	for(Suggested_Discounts__c objSuggesstedDiscount : (List<suggested_Discounts__c>)listNewItems){
                if(objSuggesstedDiscount.Location_UUID__c != null){
                    if(mapLocationUUId.containsKey(objSuggesstedDiscount.Location_UUID__c))
                    	objSuggesstedDiscount.Location__c = mapLocationUUId.get(objSuggesstedDiscount.Location_UUID__c);
                    else
                        objSuggesstedDiscount.addError('Location UUID Not Found');
                }
            }
        }else if(flag){
            Trigger.new[0].addError('Location UUID Not Found');
        }      
    }
}