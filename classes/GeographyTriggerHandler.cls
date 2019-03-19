/************************************************************************************************************************************
    Author 		: Priyanka Ambre
    Description : This class contains business logic for GeographyTriggerHandler.
    History		:
----------------------------------------------------------------------------------------------------------------------------------
	VERSION	  	DATE	        	AUTHOR           		DETAIL
	1	     	07, Mar 2017		Priyanka Ambre      	Initial Developement
**************************************************************************************************************************************/
public class GeographyTriggerHandler extends ITriggerHandler{
    public GeographyTriggerHandler(){
        super('Geography__c');
    }
    
    /************************************************************************************************************************************
    Author 				: 	Priyanka Ambre
    Description 		: 	This method overrides before insert method from ITriggerHander which will control the execution flow.
    Created Date		:	07, Mar 2017	 
    **************************************************************************************************************************************/
     public override void BeforeInsert(List<SObject> listNewItems){ 
         Debug.log('In updateNearestBuilding BeforeInsert Limits.getQueries() before calling  :: ' + Limits.getQueries()); 
         GeographyTriggerHandler.updateNearestBuilding((List<Geography__c>) listNewItems, null, null, null);
         Debug.log('In updateNearestBuilding BeforeInsert Limits.getQueries() after calling  :: ' + Limits.getQueries()); 
    }
    
    /************************************************************************************************************************************
    Author 				: 	Priyanka Ambre
    Description 		: 	This method overrides before update method from ITriggerHander which will control the execution flow.
    Created Date		:	07, Mar 2017	
    **************************************************************************************************************************************/
    public override void BeforeUpdate(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems){
        Debug.log('In updateNearestBuilding BeforeUpdate Limits.getQueries() before calling  :: '+Limits.getQueries()); 
        GeographyTriggerHandler.updateNearestBuilding((List<Geography__c>) listNewItems, (Map<Id, Geography__c>) mapNewItems, (List<Geography__c>) listOldItems, (Map<Id, Geography__c>) mapOldItems);
        Debug.log('In updateNearestBuilding BeforeUpdate Limits.getQueries() after calling  :: '+Limits.getQueries()); 
    }    
    
    /************************************************************************************************************************************
    Author 				: 	Priyanka Ambre
    Description 		: 	This method manage nearest building on geography .
    Created Date		:	07, Mar 2017	
	Modify By           :   Nikhil Mehta
    Modification        :   At the time of insertion if the nearest building is present we have to neglect that building
                        :   and update nearest building from remaining buildings.
	Last Modified By    :   Nikhil Mehta
	Last Modified Date  :   4 December 2018
	issue No			: 	ST-3200
    **************************************************************************************************************************************/
    public static void updateNearestBuilding(List<Geography__c> listNewItems, Map<Id, Geography__c> mapNewItems, List<Geography__c> listOldItems, Map<Id, Geography__c> mapOldItems){
        if (TriggerSettings.mappedField.Geography_UpdateNearestBuilding){
            Set<String> setCities = new Set<String>();
            Set<String> setStates = new Set<String>();
            Set<String> setCountries = new Set<String>();
            List<Geography__c> lstGeographies = new List<Geography__c>();
            for(Geography__c objLocation : listNewItems){
                if((listOldItems == null) || (listOldItems != null && (objLocation.Nearest_Building__c == null || (mapOldItems.get(objLocation.Id).Geocode__Latitude__s != (mapNewItems.get(objLocation.Id).Geocode__Latitude__s)) || (mapOldItems.get(objLocation.Id).Geocode__Longitude__s != (mapNewItems.get(objLocation.Id).Geocode__Longitude__s))))){ 
                    lstGeographies.add(objLocation);
                    setCities.add(objLocation.City__c);
                    setStates.add(objLocation.State__c);
                    setCountries.add(objLocation.Country__c);
                }
            }            
            if(!lstGeographies.isEmpty()){
                List<Building__c> lstBuildings = new List<Building__c>([SELECT Id, Name, City__c, State__c, Country__c, Geography__r.Geocode__c, Geography__r.City__c, Geography__r.State__c, Geography__r.Country__c FROM Building__c WHERE City__c IN : setCities OR State__c IN : setStates OR Country__c IN : setCountries OR Geography__r.City__c IN : setCities OR Geography__r.State__c IN : setStates OR Geography__r.Country__c IN : setCountries ORDER BY Geography__c ASC NULLS Last]);
                Map<String, List<Building__c>> mapBuildingByGeographyCity = new Map<String, List<Building__c>>();
                Map<String, List<Building__c>> mapBuildingByGeographyState = new Map<String, List<Building__c>>();
                Map<String, List<Building__c>> mapBuildingByGeographyCountry = new Map<String, List<Building__c>>();
                Map<String, List<Building__c>> mapBuildingByCity = new Map<String, List<Building__c>>();
                Map<String, List<Building__c>> mapBuildingByState = new Map<String, List<Building__c>>();
                Map<String, List<Building__c>> mapBuildingByCountry = new Map<String, List<Building__c>>();
                for(Building__c buildingRec : lstBuildings){
                    addLocationInMap('City__c', buildingRec, mapBuildingByCity, mapBuildingByGeographyCity);
                    addLocationInMap('State__c', buildingRec, mapBuildingByState, mapBuildingByGeographyState);
                    addLocationInMap('Country__c', buildingRec, mapBuildingByCountry, mapBuildingByGeographyCountry);
                }
                
                for(Geography__c geographyRec : lstGeographies){
                    Id buildingRecId; 
                    if(String.isBlank(buildingRecId)){
                        buildingRecId = getNearestBuilding('City__c', geographyRec, mapBuildingByGeographyCity, (listOldItems == null));
                    }
                    if(String.isBlank(buildingRecId)){
                        buildingRecId = getNearestBuilding('State__c', geographyRec, mapBuildingByGeographyState, (listOldItems == null));
                    }
                    if(String.isBlank(buildingRecId)){
                        buildingRecId = getNearestBuilding('Country__c', geographyRec, mapBuildingByGeographyCountry, (listOldItems == null));
                    }
                    if(String.isBlank(buildingRecId)){
                        buildingRecId = getNearestBuilding('City__c', geographyRec, mapBuildingByCity, (listOldItems == null));
                    }
                    if(String.isBlank(buildingRecId)){
                        buildingRecId = getNearestBuilding('State__c', geographyRec, mapBuildingByState, (listOldItems == null));
                    }
                    if(String.isBlank(buildingRecId)){
                        buildingRecId = getNearestBuilding('Country__c', geographyRec, mapBuildingByCountry, (listOldItems == null));
                    }
                    if(String.isBlank(buildingRecId)){
                        buildingRecId = getNearestBuilding(geographyRec, Settings.getAllBuildings(), (listOldItems == null), false);                        
                    }
                    if(String.isNotBlank(buildingRecId)){    
                        geographyRec.Nearest_Building__c = buildingRecId;
                    }                    
                }
            }
        }
    }
    /************************************************************************************************************************************
        Author              :   Nikhil Mehta
        Description         :   This method check geography present or not and add to related map.
        Created Date  		:   04 December 2018
		Issue No.			:	ST-3200
    **************************************************************************************************************************************/    
   public static void addLocationInMap(String fieldName, Building__c buildingRec, Map<String, List<Building__c>> mapBuildings, Map<String, List<Building__c>> mapBuildingsWithGeography){
        if(String.isNotBlank(buildingRec.Geography__c) && buildingRec.Geography__r.get(fieldName) != NULL && String.isNotBlank((String)buildingRec.Geography__r.get(fieldName))){
            addBuildingInMap(String.valueOf(buildingRec.Geography__r.get(fieldName)), buildingRec, mapBuildingsWithGeography);
        }else if(String.isNotBlank((String)buildingRec.get(fieldName))){
            addBuildingInMap((String)buildingRec.get(fieldName), buildingRec, mapBuildings);
        }
    }
    /************************************************************************************************************************************
        Author              :   Nikhil Mehta
        Description         :   This method add builing to related city, state, countries map.
        Created Date  		:   04 December 2018
		Issue No.			:	ST-3200
    **************************************************************************************************************************************/    
    public static void addBuildingInMap(String strLocation, Building__c buildingRec, Map<String, List<Building__c>> mapBuildings){
        if(!mapBuildings.containsKey(strLocation)){
            mapBuildings.put(strLocation, new List<Building__c>());
        }
        List<Building__c> lstBuildings = mapBuildings.get(strLocation);
        lstBuildings.add(buildingRec);
        mapBuildings.put(strLocation, mapBuildings.get(strLocation));
    }
    /************************************************************************************************************************************
        Author              :   Nikhil Mehta
        Description         :   This method check where location is present in map if it present return nearest building Id.
        Created Date  		:   04 December 2018
		Issue No.			:	ST-3200
    **************************************************************************************************************************************/    
    public static Id getNearestBuilding(String fieldName, Geography__c geographyRec, Map<String, List<Building__c>> mapBuildings, Boolean isInsert){
        if(String.isNotBlank((String)geographyRec.get(fieldName)) && !mapBuildings.isEmpty() && mapBuildings.containsKey((String)geographyRec.get(fieldName)) && !mapBuildings.get((String)geographyRec.get(fieldName)).isEmpty()){
            return getNearestBuilding(geographyRec, mapBuildings.get((String)geographyRec.get(fieldName)), isInsert, true);
        }
        return NULL;
    }
    /************************************************************************************************************************************
        Author              :   Nikhil Mehta
        Description         :   This method calculate distance and returns nearest building Id.
        Created Date  		:   04 December 2018
		Issue No.			:	ST-3200
    **************************************************************************************************************************************/    
    public static Id getNearestBuilding(Geography__c geographyRec, List<Building__c> lstBuildings, Boolean isInsert, Boolean checkGeographyBlank){
        Building__c objNearestBuilding;
        Double distance;
        for(Building__c buildingRec : lstBuildings){
            if(!isInsert || (isInsert && (String.isBlank(geographyRec.Nearest_Building__c) || (String.isNotBlank(geographyRec.Nearest_Building__c) && !geographyRec.Nearest_Building__c.equals(buildingRec.Id))))){
                Double newDistance;
                if(String.isNotBlank(buildingRec.Geography__c)){
                    newDistance = getDistance(geographyRec, buildingRec);
                    if(newDistance != NULL && (distance == NULL || newDistance < distance)){
                        distance = newDistance;
                        objNearestBuilding = buildingRec;
                    }
                }
                if(String.isBlank(buildingRec.Geography__c) && checkGeographyBlank){
                    return buildingRec.Id;
                }
            }
        }
        return objNearestBuilding != NULL ? objNearestBuilding.Id : NULL;
    }
    
    /************************************************************************************************************************************
        Author              :   Nikhil Mehta
        Description         :   This method return double it calculate distance between two point.
        Created Date  		:   04 December 2018
		Issue No.			:	ST-3200
    **************************************************************************************************************************************/    
    public static Double getDistance(Geography__c geographyRec, Building__c buildingRec){
        if(geographyRec.Geocode__Latitude__s != NULL && geographyRec.Geocode__Longitude__s != NULL){
            return Location.getDistance(Location.newInstance(geographyRec.Geocode__Latitude__s, geographyRec.Geocode__Longitude__s), buildingRec.Geography__r.Geocode__c, 'mi');
        }
        return NULL;
    }
}