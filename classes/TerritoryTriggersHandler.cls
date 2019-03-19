/************************************************************************************************************************************
	Author		 	:	Ajaysinh Chauhan
	Description 	:	This class contains business logic for TerritoryTrigger

	History			:
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION	  	DATE	          			AUTHOR                      	DETAIL
	1	     	04 December 2017			Ajaysinh Chauhan            	Initial Developement
**************************************************************************************************************************************/
public class TerritoryTriggersHandler extends ITriggerHandler{
    public TerritoryTriggersHandler(){
        super('Territory__c');
    }
    /************************************************************************************************************************************
        Author				:	Ajaysinh Chauhan
        Description 		:	This method overrides after update method from ITriggerHander which will control the execution flow.
        Last Modified Date	:	04 December 2017
        Last Modified By	:	Ajaysinh Chauhan
    **************************************************************************************************************************************/    
    public override void AfterUpdate(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems){
		updateTerritoryInfoOnBuilding(listNewItems,mapNewItems,listOldItems,mapOldItems);
    }
    
   /************************************************************************************************************************************
        Author				:	Ajaysinh Chauhan
        Description 		:	This method contains logic for updating TerritoryInfo On Building
        Last Modified Date	:	04 December 2017
        Last Modified By	:	Ajaysinh Chauhan
   **************************************************************************************************************************************/    
   public static void updateTerritoryInfoOnBuilding(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems){
       if(TriggerSettings.mappedField.Territory_UpdateTerritoryInfoOnBuilding){ 
           try{
               Set<Id> setTerritoryIds = new Set<Id>();   
               for(Territory__c trtry:(List<Territory__c>)listNewItems){
                   if((trtry.Territory__c==null || !trtry.Territory__c.equalsIgnoreCase(String.valueOf(mapOldItems.get(trtry.Id).get('Territory__c')))) || trtry.Territory_Sales_Manager__c!=mapOldItems.get(trtry.Id).get('Territory_Sales_Manager__c') || trtry.RegionID__c !=mapOldItems.get(trtry.Id).get('RegionID__c')){
                       setTerritoryIds.add(trtry.Id);
                   }
               }
               Debug.log('setTerritoryIds-----'+setTerritoryIds);
               if(setTerritoryIds.size()>0){
                   List<Building__c> lstBuildings = [Select Id,Market__r.TerritoryId__r.Territory__c,Market__r.TerritoryId__r.Territory_Sales_Manager__r.Name,Market__r.TerritoryId__r.Territory_Sales_Manager__r.Email,Market__r.TerritoryId__r.RegionId__r.Region__c,Market__r.TerritoryId__r.RegionId__r.Regional_Sales_Manager__r.Name, Market__r.TerritoryId__r.RegionId__r.Regional_Sales_Manager__r.Email From Building__c Where Market__r.TerritoryId__c IN:setTerritoryIds];
                   List<Building__c> lstBuildingsToUpdate = new List<Building__c>();
                   for(Building__c bldng:lstBuildings){
                       Building__c b = new Building__c(Id=bldng.Id);
                       b.Territory_Name__c = bldng.Market__r.TerritoryId__r.Territory__c;
                       b.Territory_Sales_Manager_Name__c = bldng.Market__r.TerritoryId__r.Territory_Sales_Manager__r!=null?bldng.Market__r.TerritoryId__r.Territory_Sales_Manager__r.Name:'';
                       b.Region_Name__c = bldng.Market__r.TerritoryId__r.RegionId__r.Region__c;
                       b.Regional_Sales_Manager_Name__c = bldng.Market__r.TerritoryId__r.RegionId__r.Regional_Sales_Manager__r!=null?bldng.Market__r.TerritoryId__r.RegionId__r.Regional_Sales_Manager__r.Name:'';
                       b.Territory_Sales_Manager_Email__c = bldng.Market__r.TerritoryId__r.Territory_Sales_Manager__r!=null?bldng.Market__r.TerritoryId__r.Territory_Sales_Manager__r.Email:'';
                       b.Regional_Sales_Manager_Email__c = bldng.Market__r.TerritoryId__r.RegionId__r.Regional_Sales_Manager__r!=null?bldng.Market__r.TerritoryId__r.RegionId__r.Regional_Sales_Manager__r.Email:'';
                       lstBuildingsToUpdate.add(b);
                   }
                   Debug.log('lstBuildingsToUpdate-----'+lstBuildingsToUpdate);
                   update lstBuildingsToUpdate;
               } 
           }catch(Exception pEx) { 
               List<Id> ids = New List<Id>();
               if(mapOldItems!=null)
                   ids.addAll(mapOldItems.keyset());
               new ApexDebugLog().createLog( 
                   new ApexDebugLog.Error('TerritoryTriggersHandler','updateTerritoryInfoOnBuilding',String.join(ids,','),pEx)
               );
               throw new TerritoryTriggersHandlerException(pEx.getMessage());
           }    
       }
    }
    
   /************************************************************************************************************************************
        Author				:	Ajaysinh Chauhan
        Description 		:	This is custom exception handling class used for exception handling
        Last Modified Date	:	04 December 2017
        Last Modified By	:	Ajaysinh Chauhan
   **************************************************************************************************************************************/
    public class TerritoryTriggersHandlerException extends Exception{}
}