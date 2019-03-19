/************************************************************************************************************************************
   	Author 		: Sunil Bhosale
   	Description : This class contains Logic of RegionTriggersHandler

   	History		:
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE					AUTHOR				DETAIL
	1			10 November 2017		Sunil Bhosale 		Initial Developement
**************************************************************************************************************************************/

public class RegionTriggersHandler extends ITriggerHandler{

	public RegionTriggersHandler(){
		super('Region__c');
	}
    
    /************************************************************************************************************************************
         Author 			: Pragalbha Mahajan
         Description 		: This method overrides after update method from ITriggerHander which will control the execution flow.
         Last Modified Date	: 02 February 2018
         Last Modified By	: Pragalbha Mahajan (added Comment)
	**************************************************************************************************************************************/
	public override void AfterUpdate(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems){
		UpdateRegionInfoOnBuilding(listNewItems , mapOldItems);
	}
    
    /************************************************************************************************************************************
        Author 				: Sunil Bhosale
        Description 		: This method is used to Update Region Info On Building
        Last Modified Date	: 10 November 17
        Last Modified By	: Sunil Bhosale
        Issue No 			: ST-1650
	**************************************************************************************************************************************/
    public static void UpdateRegionInfoOnBuilding(List<SObject> listNewItems, Map<Id, SObject> mapOldItems){
        if(TriggerSettings.mappedField.Region_UpdateRegionInfoOnBuilding){
            Set<Id> setRegionIds = new Set<Id>();   
            try{
                for(Region__c region:(List<Region__c>)listNewItems){
                    if((region.Region__c==null || !region.Region__c.equalsIgnoreCase(String.valueOf(mapOldItems.get(region.Id).get('Region__c')))) || region.Regional_Sales_Manager__c!=mapOldItems.get(region.Id).get('Regional_Sales_Manager__c')){
                        setRegionIds.add(region.Id);
                    }
                }
                if(setRegionIds.size()>0){
                    List<Building__c> lstBuildings = [Select Id,Market__r.TerritoryId__r.RegionId__r.Region__c,Market__r.TerritoryId__r.RegionId__r.Regional_Sales_Manager__r.Name,Market__r.TerritoryId__r.RegionId__r.Regional_Sales_Manager__r.Email From Building__c Where Market__r.TerritoryId__r.RegionId__c IN:setRegionIds];
                    List<Building__c> lstBuildingsToUpdate = new List<Building__c>();
                    for(Building__c bldng:lstBuildings){
                        Building__c b = new Building__c(Id=bldng.Id);
                        b.Region_Name__c = bldng.Market__r.TerritoryId__r.RegionId__r.Region__c;
                        b.Regional_Sales_Manager_Name__c = bldng.Market__r.TerritoryId__r.RegionId__r.Regional_Sales_Manager__r!=null?bldng.Market__r.TerritoryId__r.RegionId__r.Regional_Sales_Manager__r.Name:'';
                        b.Regional_Sales_Manager_Email__c = bldng.Market__r.TerritoryId__r.RegionId__r.Regional_Sales_Manager__r!=null?bldng.Market__r.TerritoryId__r.RegionId__r.Regional_Sales_Manager__r.Email:'';
                        lstBuildingsToUpdate.add(b);
                    }
                    update lstBuildingsToUpdate;
                }    
            }catch(Exception pEx) { 
                List<Id> ids = New List<Id>();
                if(mapOldItems!=null)
                    ids.addAll(mapOldItems.keyset());
                new ApexDebugLog().createLog( 
                    new ApexDebugLog.Error('RegionTriggersHandler','UpdateRegionInfoOnBuilding',String.join(ids,','),pEx)
                );
                throw new RegionTriggersHandlerException(pEx.getMessage());
            }      
        }
    }
    
    /************************************************************************************************************************************
        Author 				: Sunil Bhosale
        Description 		: This is custom exception used for Portfolio Triggers Handler
        Created Date		: 10 November 2017
	**************************************************************************************************************************************/
    public class RegionTriggersHandlerException extends Exception{}
}