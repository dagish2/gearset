/************************************************************************************************************************************
   	Author 		: Milanjeet
   	Description : This class contains Logic of PortfolioTrigger

   	History		:
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE			AUTHOR				DETAIL
	1			9 Nov 2017		Milanjeet 			Initial Developement
**************************************************************************************************************************************/

public class PortfolioTriggersHandler extends ITriggerHandler {
    public PortfolioTriggersHandler(){
        super('Market__c');
    }
    
    /************************************************************************************************************************************
         Author 			: Pragalbha Mahajan
         Description 		: This method overrides after update method from ITriggerHander which will control the execution flow.
         Last Modified Date	: 02 February 2018
         Last Modified By	: Pragalbha Mahajan (added Comment)
	**************************************************************************************************************************************/
    public override void AfterUpdate(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems){
        updatePortfolioInfoOnBuilding(listNewItems, mapNewItems, listOldItems, mapOldItems);
    }

    /************************************************************************************************************************************
        Author 				: Milanjeet
        Description 		: This method is used to update portfolio info on Building
        Last Modified Date	: 10-Nov-2017
        Last Modified By	: Milanjeet
        Issue No 			: ST-1652
	**************************************************************************************************************************************/
    public static void updatePortfolioInfoOnBuilding(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems){     
        if(TriggerSettings.mappedField.Portfolio_UpdatePortfolioInfoOnBuilding){
            Set<Id> setPortfolioIds = new Set<Id>();   
            try{
                for(Market__c mrkt:(List<Market__c>)listNewItems){
                    if((mrkt.Portfolio__c==null || !mrkt.Portfolio__c.equalsIgnoreCase(String.valueOf(mapOldItems.get(mrkt.Id).get('Portfolio__c')))) || mrkt.Portfolio_Sales_Manager__c!=mapOldItems.get(mrkt.Id).get('Portfolio_Sales_Manager__c') || mrkt.TerritoryID__c !=mapOldItems.get(mrkt.Id).get('TerritoryID__c') || mrkt.Name !=mapOldItems.get(mrkt.Id).get('Name')){
                        setPortfolioIds.add(mrkt.Id);
                    }
                }
                if(setPortfolioIds.size()>0){
                    List<Building__c> lstBuildings = [Select Id,Market__r.Name,Market__r.Portfolio__c,Market__r.Portfolio_Sales_Manager__r.Name,Market__r.Portfolio_Sales_Manager__r.Email,Market__r.TerritoryId__r.Territory__c,Market__r.TerritoryId__r.Territory_Sales_Manager__r.Name,Market__r.TerritoryId__r.Territory_Sales_Manager__r.Email,Market__r.TerritoryId__r.RegionId__r.Region__c,Market__r.TerritoryId__r.RegionId__r.Regional_Sales_Manager__r.Name,Market__r.TerritoryId__r.RegionId__r.Regional_Sales_Manager__r.Email From Building__c Where Market__c IN:setPortfolioIds];
                    List<Building__c> lstBuildingsToUpdate = new List<Building__c>();
                    for(Building__c bldng:lstBuildings){
                        Building__c b = new Building__c(Id=bldng.Id);
                        b.Portfolio_Name__c = bldng.Market__r.Portfolio__c;
                        b.Portfolio_Standard_Name__c = bldng.Market__r.Name;
                        b.Portfolio_Sales_Manager_Name__c = bldng.Market__r.Portfolio_Sales_Manager__r!=null?bldng.Market__r.Portfolio_Sales_Manager__r.Name:'';
                        b.Territory_Name__c = bldng.Market__r.TerritoryId__r.Territory__c;
                        b.Territory_Sales_Manager_Name__c = bldng.Market__r.TerritoryId__r.Territory_Sales_Manager__r!=null?bldng.Market__r.TerritoryId__r.Territory_Sales_Manager__r.Name:'';
                        b.Region_Name__c = bldng.Market__r.TerritoryId__r.RegionId__r.Region__c;
                        b.Regional_Sales_Manager_Name__c = bldng.Market__r.TerritoryId__r.RegionId__r.Regional_Sales_Manager__r!=null?bldng.Market__r.TerritoryId__r.RegionId__r.Regional_Sales_Manager__r.Name:'';
                        
                        b.Portfolio_Sales_Manager_Email__c = bldng.Market__r.Portfolio_Sales_Manager__r!=null?bldng.Market__r.Portfolio_Sales_Manager__r.Email:'';
                        b.Territory_Sales_Manager_Email__c = bldng.Market__r.TerritoryId__r.Territory_Sales_Manager__r!=null?bldng.Market__r.TerritoryId__r.Territory_Sales_Manager__r.Email:'';
                        b.Regional_Sales_Manager_Email__c = bldng.Market__r.TerritoryId__r.RegionId__r.Regional_Sales_Manager__r!=null?bldng.Market__r.TerritoryId__r.RegionId__r.Regional_Sales_Manager__r.Email:'';
                        lstBuildingsToUpdate.add(b);
                    }
                    update lstBuildingsToUpdate;
                }  
            }catch(Exception pEx) { 
                List<Id> ids = New List<Id>();
                if(mapOldItems.keyset()!=null)
                    ids.addAll(mapOldItems.keyset());
                new ApexDebugLog().createLog( 
                    new ApexDebugLog.Error('PortfolioTriggersHandler','updatePortfolioInfoOnBuilding',String.join(ids,','),pEx)
                );
                throw new PortfolioTriggersHandlerException(pEx.getMessage());
            }    
            
        }
    }
    
    /************************************************************************************************************************************
        Author 				: Milanjeet
        Description 		: This is custom exception used for Portfolio Triggers Handler
        Last Modified Date	: 9 Nov 2017
        Last Modified By	: Milanjeet
	**************************************************************************************************************************************/
    public class PortfolioTriggersHandlerException extends Exception{}
}