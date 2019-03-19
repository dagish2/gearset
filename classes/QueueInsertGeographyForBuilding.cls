/************************************************************************************************************************************
	Author		: 	Nikhil Mehta
	Description	: 	This Queueable class insert Geography to related to Building.
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE	        	AUTHOR                     DETAIL
	1	    	4 December 2018		Nikhil Mehta            Initial Developement
**************************************************************************************************************************************/
public class QueueInsertGeographyForBuilding implements Queueable, Database.AllowsCallouts{
    public List<Building__c> lstNewBuildings;
    public Integer maxCallouts;
    private Integer counter = 0;
    public GeographyHandler.GoogleGeolocationAPI googleGeolocationAPISetting;
    
    public QueueInsertGeographyForBuilding(List<Building__c> lstNewBuildings,GeographyHandler.GoogleGeolocationAPI googleGeolocationAPISetting){
        this.lstNewBuildings = lstNewBuildings;
        this.maxCallouts = lstNewBuildings.size();
        this.googleGeolocationAPISetting = googleGeolocationAPISetting;
    }
    /************************************************************************************************************************************
        Author              :   Nikhil Mehta
        Description         :   This method insert geography record for Building.
		Last Modified By	:	Nikhil Mehta
        Last Modified Date  :   04 December 2018
    **************************************************************************************************************************************/    
    public void execute(QueueableContext context) {
        try{
            if(googleGeolocationAPISetting != null && lstNewBuildings != null && lstNewBuildings.size()>0){
                Building__c building = lstNewBuildings[counter];
                Map<String, String> mapAddress = new Map<String, String>();
                mapAddress.put('address', building.Address__c);
                mapAddress.put('city', building.City__c);
                mapAddress.put('state', building.State__c);
                mapAddress.put('country', building.Country__c);
                Geography__c geographyRec = GeographyHandler.getGeography(mapAddress);
                if(String.isEmpty(geographyRec.Id)){
                    geographyRec.Nearest_Building__c = building.Id;
                    Database.insert(geographyRec, false);
                }
                if(geographyRec.Id != null){
                    Building__c newBuilding = new Building__c(Id = building.Id, Geography__c = geographyRec.Id);
                    update newBuilding;
                    List<Geography__c> lstGeographies = new List<Geography__c>([SELECT Id, Name, Geocode__Latitude__s, Geocode__Longitude__s, Nearest_Building__r.Name, Nearest_Building__r.Geography__c, Nearest_Building__r.Geography__r.Name, Nearest_Building__r.Geography__r.Geocode__Latitude__s, Nearest_Building__r.Geography__r.Geocode__Longitude__s, Nearest_Building__r.Geography__r.Nearest_Building__c FROM Geography__c WHERE Id =: geographyRec.Id]);
                    if(lstGeographies.size() > 0){
                        Geography__c newGeographyRec = lstGeographies[0];
                        Geography__c nearestGeographyRec = newGeographyRec.Nearest_Building__r.Geography__r;
                        if(building != null && nearestGeographyRec != null){
                            List<Geography__c> lstNearestBuildingGeographies = [SELECT Id, Name, Geocode__Latitude__s, Geocode__Longitude__s FROM Geography__c WHERE Nearest_Building__c =: nearestGeographyRec.Nearest_Building__c];
                            if(lstNearestBuildingGeographies.size() > 0){
                                List<Geography__c> lstGeographysToUpdate = new List<Geography__c>();
                                System.Location newGeographyRecLocation = System.Location.newInstance(newGeographyRec.Geocode__Latitude__s, newGeographyRec.Geocode__Longitude__s);
                                System.Location nearestGeographyRecLocation = System.Location.newInstance(nearestGeographyRec.Geocode__Latitude__s, nearestGeographyRec.Geocode__Longitude__s);
                                System.Location geographyLocation;
                                for(Geography__c nearestBuildingGeographyRec : lstNearestBuildingGeographies){
                                    geographyLocation = System.Location.newInstance(nearestBuildingGeographyRec.Geocode__Latitude__s, nearestBuildingGeographyRec.Geocode__Longitude__s);
                                    if(System.Location.getDistance(geographyLocation, newGeographyRecLocation, 'mi') < System.Location.getDistance(geographyLocation, nearestGeographyRecLocation, 'mi')){
                                        nearestBuildingGeographyRec.Building_Updated_Date__c = System.now();
                                        nearestBuildingGeographyRec.Previous_Building__c = nearestGeographyRec.Nearest_Building__c;
                                        nearestBuildingGeographyRec.Nearest_Building__c = building.Id;
                                        lstGeographysToUpdate.add(nearestBuildingGeographyRec);
                                    }
                                }
                                if(lstGeographysToUpdate.size() > 0){
                                    Database.update(lstGeographysToUpdate, false);
                                }
                            }
                        }
                    }
                }
                counter += 1;
                if(maxCallouts > counter){
                    QueueInsertGeographyForBuilding jobQueueInsertGeographyForBuilding = new QueueInsertGeographyForBuilding(lstNewBuildings, googleGeolocationAPISetting);
                    jobQueueInsertGeographyForBuilding.counter = counter;
                    System.enqueueJob(jobQueueInsertGeographyForBuilding);
                }
            }
        } catch(Exception pEx) { 
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('QueueInsertGeographyForBuilding','execute',null,pEx)
            );
            throw new QueueInsertGeographyForBuildingException(pEx.getMessage());
        }
    }
    
    public class QueueInsertGeographyForBuildingException extends Exception{}
}