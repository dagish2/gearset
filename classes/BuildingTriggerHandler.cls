/*******************************************************************************************************************************
    Author 		: Ajaysinh Chauhan
    Description : ---
    History		: --

----------------------------------------------------------------------------------------------------------------------------------
    VERSION					DATE					AUTHOR							DETAIL
    1						--		                Ajaysinh Chauhan	            Initial Developement
********************************************************************************************************************************/
public class BuildingTriggerHandler extends ITriggerHandler {
    public BuildingTriggerHandler(){
        super('Building__c');
    } 
    public static Map<Id, Cluster__c> mapClusters;
    public static Map<Id, Market__c> mapPortfolios;
    public static Map<Id, Building__c> mapBuildings;
    
/*******************************************************************************************************************************
    Author 				: Ajaysinh Chauhan
    Description 		: This method overrides before insert method from ITriggerHander which will control the execution flow.
    Created Date		:	--
    Last Modified Date	: 02 Feb, 2018
    Last Modified By	: Prashant Mane
********************************************************************************************************************************/
    public override void BeforeInsert(List<SObject> listNewItems){        
        if(TriggerSettings.mappedField.Building_SetTerritoryStructure)
            setTerritoryStructure((List<Building__c>)listNewItems, null, null, null);
    }
    
/******************************************************************************************************************************
    Author              : Nikhil Mehta
    Description         : This method overrides after Insert method from ITriggerHander which will control the execution flow.
    Created Date        : 16 May, 2018
*******************************************************************************************************************************/
    public override void AfterInsert(List<SObject> listNewItems, Map<Id, SObject> mapNewItems){
        if(TriggerSettings.mappedField.Building_ManageBuildingRelatedGeographies){
            manageBuildingRelatedGeographies((List<Building__c>)listNewItems,(Map<Id,Building__c>)mapNewItems);
        }
    }
    
/*******************************************************************************************************************************
    Author 				: Ajaysinh Chauhan
    Description 		: This method overrides before update method from ITriggerHander which will control the execution flow.
    Created Date		:	--
    Last Modified Date	: 02 Feb, 2018
    Last Modified By	: Prashant Mane
********************************************************************************************************************************/   
    public override void BeforeUpdate(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems){
        if(TriggerSettings.mappedField.Building_SetTerritoryStructure)
            setTerritoryStructure((List<Building__c>) listNewItems, (Map<Id, Building__c>) mapNewItems, (List<Building__c>) listOldItems, (Map<Id, Building__c>) mapOldItems);
    }
    
/*******************************************************************************************************************************
    Author 				: Ajaysinh Chauhan
    Description 		: Method used to get Building Structures.
    Created Date		:	--
    Last Modified Date	: 02 Feb, 2018
    Last Modified By	: Prashant Mane
********************************************************************************************************************************/
    public static void getBuildingStructure(){
        mapClusters = new Map<Id, Cluster__c>([SELECT Id, Name, Cluster_Sales_Manager__r.Full_Name__c, Cluster_Sales_Manager__r.Email, Sales_Lead__r.Full_Name__c, Sales_Lead__r.Email FROM Cluster__c]);
        mapPortfolios = new Map<Id, Market__c>([SELECT Id, Name, Portfolio_Sales_Manager__r.Full_Name__c, Portfolio_Sales_Manager__r.Email, TerritoryID__r.Territory__c, TerritoryID__r.Territory_Sales_Manager__r.Full_Name__c, TerritoryID__r.Territory_Sales_Manager__r.Email, TerritoryID__r.RegionID__r.Region__c, TerritoryID__r.RegionID__r.Regional_Sales_Manager__r.Full_Name__c, TerritoryID__r.RegionID__r.Regional_Sales_Manager__r.Email FROM Market__c]); 
        mapBuildings = new Map<Id, Building__c>([SELECT Id, Name, Community_Lead__c, Community_Lead__r.Name, Responsible_CM__c, Responsible_CM__r.Name FROM Building__c]); 
    }
    
/*******************************************************************************************************************************
    Author 				: Ajaysinh Chauhan
    Description 	    : Method Used To Set Territory Structure in Both Before inserion And Before Updation of Building Record.
    Created Date		: --
    Last Modified Date	: 02 Feb, 2018
    Last Modified By	: Prashant Mane
********************************************************************************************************************************/
    public static void setTerritoryStructure(List<Building__c> listNewItems, Map<Id, Building__c> mapNewItems, List<Building__c> listOldItems, Map<Id, Building__c> mapOldItems){ 
        if(mapClusters == null || mapPortfolios == null ){
            BuildingTriggerHandler.getBuildingStructure();
        }
        for(Building__c objBuilding : listNewItems){
            if(objBuilding.Market__c != null){
                if(mapPortfolios != null && mapPortfolios.containsKey(objBuilding.Market__c) && (Trigger.isInsert || objBuilding.Market__c != mapOldItems.get(objBuilding.Id).get('Market__c'))){
                    objBuilding.Portfolio_Name__c = mapPortfolios.get(objBuilding.Market__c).Name;
                    objBuilding.Territory_Name__c = mapPortfolios.get(objBuilding.Market__c).TerritoryID__r.Territory__c;
                    objBuilding.Region_Name__c = mapPortfolios.get(objBuilding.Market__c).TerritoryID__r.RegionID__r.Region__c;
                    objBuilding.Portfolio_Sales_Manager_Name__c =  mapPortfolios.get(objBuilding.Market__c).Portfolio_Sales_Manager__r.Full_Name__c;
                    objBuilding.Territory_Sales_Manager_Name__c =  mapPortfolios.get(objBuilding.Market__c).TerritoryID__r.Territory_Sales_Manager__r.Full_Name__c;
                    objBuilding.Regional_Sales_Manager_Name__c =  mapPortfolios.get(objBuilding.Market__c).TerritoryID__r.RegionID__r.Regional_Sales_Manager__r.Full_Name__c;
                    objBuilding.Portfolio_Sales_Manager_Email__c = mapPortfolios.get(objBuilding.Market__c).Portfolio_Sales_Manager__r.Email;
                    objBuilding.Territory_Sales_Manager_Email__c = mapPortfolios.get(objBuilding.Market__c).TerritoryID__r.Territory_Sales_Manager__r.Email;
                    objBuilding.Regional_Sales_Manager_Email__c = mapPortfolios.get(objBuilding.Market__c).TerritoryID__r.RegionID__r.Regional_Sales_Manager__r.Email;
                }    
            } else {
                objBuilding.Portfolio_Name__c = null;
                objBuilding.Territory_Name__c = null;
                objBuilding.Region_Name__c = null; 
                objBuilding.Portfolio_Sales_Manager_Name__c = null;
                objBuilding.Territory_Sales_Manager_Name__c = null;
                objBuilding.Regional_Sales_Manager_Name__c = null;
                objBuilding.Portfolio_Sales_Manager_Email__c = null;
                objBuilding.Territory_Sales_Manager_Email__c = null;
                objBuilding.Regional_Sales_Manager_Email__c = null;
            }
            
            if(objBuilding.Cluster__c != null){
                if(mapClusters != null && mapClusters.containsKey(objBuilding.Cluster__c) && (Trigger.isInsert || objBuilding.Cluster__c != mapOldItems.get(objBuilding.Id).get('Cluster__c'))){
                    objBuilding.Cluster_Name__c = mapClusters.get(objBuilding.Cluster__c).Name;
                    objBuilding.Cluster_Sales_Manager_Name__c = mapClusters.get(objBuilding.Cluster__c).Cluster_Sales_Manager__r.Full_Name__c;
                    objBuilding.Cluster_Sales_Lead_Name__c = mapClusters.get(objBuilding.Cluster__c).Sales_Lead__r.Full_Name__c;
                    objBuilding.Cluster_Sales_Manager_Email__c = mapClusters.get(objBuilding.Cluster__c).Cluster_Sales_Manager__r.Email;
                    objBuilding.Cluster_Sales_Lead_Email__c = mapClusters.get(objBuilding.Cluster__c).Sales_Lead__r.Email;
                }                   
            }else{
                objBuilding.Cluster_Sales_Manager_Name__c = null;
                objBuilding.Cluster_Sales_Lead_Name__c = null;
                objBuilding.Cluster_Sales_Manager_Email__c = null;
                objBuilding.Cluster_Sales_Lead_Email__c = null;
            }  
            
            if( objBuilding.Community_Lead__c != null && mapBuildings != null && mapBuildings.get(objBuilding.Id) != null ){   
                
                objBuilding.Community_Lead_Name__c = mapBuildings.get(objBuilding.Id).Community_Lead__r.Name;
                objBuilding.Community_Manager_Name__c = mapBuildings.get(objBuilding.Id).Responsible_CM__r.Name;
            } else{
                objBuilding.Community_Lead_Name__c = null;
                objBuilding.Community_Manager_Name__c = null;
            } 
            
        }
    }
    
/*************************************************************************************************
    Author              : Nikhil Mehta
    Description         : This method is used to map new or existing geography on building
    Created Date        : 14 May, 2018
    Issue No			: ST-2267
****************************************************************************************************/
    public static void manageBuildingRelatedGeographies(List<Building__c> lstNewBuildings, Map<Id, Building__c> mapNewBuildings){
        Setting__c googleGeolocationAPISetting = Settings.get('Google Geolocation API');
        if(googleGeolocationAPISetting != null){
            String googleGeolocationAPISettingData = googleGeolocationAPISetting.Data__c.replace('accept-encoding','acceptEncoding');
            GeographyHandler.GoogleGeolocationAPI googleGeolocationAPIRec = (GeographyHandler.GoogleGeolocationAPI)System.JSON.deserialize(googleGeolocationAPISettingData, GeographyHandler.GoogleGeolocationAPI.class);
            if(!Test.isRunningTest()){
                QueueInsertGeographyForBuilding jobQueueInsertGeographyForBuilding = new QueueInsertGeographyForBuilding(lstNewBuildings,googleGeolocationAPIRec);
                ID jobID = System.enqueueJob(jobQueueInsertGeographyForBuilding);
            }
        }
    }
}