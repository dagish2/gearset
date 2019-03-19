public with sharing class BuildingHandler {
	//	Returns the Building UUID from the associated won Opportunity of the given account ID
    public static String getBuildingUUIDByAccount(Id pAccountID) {
        String result;
        Set<String> stagesToSync = new Set<String>{'Closed Won','Closing'};
            try{
                Opportunity o = [ SELECT Building__r.UUID__c FROM Opportunity WHERE AccountID =: pAccountID AND stageName IN :stagesToSync LIMIT 1 ];
                result = o.Building__r.UUID__c;
                return result;
            } catch(Exception pEx) {
                result = null; //default value
                return result;
                /*new ApexDebugLog().createLog( 
                    new ApexDebugLog.Error('BuildingHandler','getBuildingUUIDByAccount', pAccountID, pEx)
                );
                throw new BuildingHandlerException(pEx.getMessage());*/
            }
    }

    public static String getMultipicklistValuesFromUUID(String[] pUUIDs){
        String result;
        String[] values = new String[]{};
            Map<String, String> uuid_to_name = new Map<String, String>();
        try {
            for(Building__c b : getAllBuildings().values()) {
                uuid_to_name.put(b.uuid__c, b.name);
            }
            //select values
            for(String u : pUUIDs) {
                String v = uuid_to_name.get(u);
                if (v != null) values.add(v);
            }
            //separate values with semi-colon
            result = String.join(values, ';');
            //check if no matches
            if (values.size() == 0) result = null;
            
        } catch(Exception pEx) {
            result = null; //default value
            /*new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('BuildingHandler','getMultipicklistValuesFromUUID',(pUUIDs != null) ? String.join(pUUIDs, ',') : null, pEx)
            );*/
        }
        return result;
    }

    public static String[] getUUIDsFromMultipicklistValues(String pMultipicklistField) {
        String[] result = new String[]{};
            try {
                String[] Vs = Common.splitStringToList(pMultipicklistField, ';');
                for (Building__c b : [	SELECT uuid__c FROM Building__c WHERE name IN :Vs]) {
                    result.add(b.uuid__c);
                }
            } catch(Exception pEx) {
                result = new String[]{}; //default value
                /*new ApexDebugLog().createLog( 
                    new ApexDebugLog.Error('BuildingHandler','getUUIDsFromMultipicklistValues', pMultipicklistField, pEx)
                );*/
            }
        return result;
    }

	public static Id getBuildingIdByUUID(String pUUID) {
		Id result;
		try {
			result =  Settings.getBuildingByUUID(pUUID).Id;//[SELECT id FROM Building__c WHERE uuid__c = :pUUID LIMIT 1].id;
		}
		catch(Exception pEx) {
			result = null; //default value
            /*new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('BuildingHandler','getBuildingIdByUUID', pUUID, pEx)
            );*/
		}
		return result;
	}
	public static Map<Id, Building__c> allBuildings;
	public static Map<Id, Building__c> getAllBuildings(){
		if(allBuildings == null)
			allBuildings = new Map<Id, Building__c>(Settings.getAllBuildings());//[SELECT Id, Name FROM Building__c]
		return allBuildings;
	}
	public static List<Building__c> getSpecificBuildings(Set<String> buildingNames){
		List<Building__c> buildings = new List<Building__c>();
		for(Building__c building : BuildingHandler.getAllBuildings().values())
			if(buildingNames.contains(building.Name))
				buildings.add(building);
		return buildings;
	}
    public class BuildingHandlerException extends Exception{}
}