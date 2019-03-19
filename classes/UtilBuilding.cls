/**
* @author Gad Sharon    
* @date 01/10/18
* @description Util class for the Building__c object.
*/

public class UtilBuilding {

	Private Static Map<String, Object> stMapFields = new Map<String, Object>();

	public static List <Building__c> createBuildings (Integer numberOfRecords, Boolean doInsert)
	{
        List<Map<String,Object>> ListOfMapFields = new List<Map<String,Object>>();

        for (Integer i = 0; i < numberOfRecords; i++)
        {
            Map <String, Object> mapBuildingFields = new Map <String, Object>(StMapFields);
            mapBuildingFields.put('CurrencyIsoCode', 'USD');
            ListOfMapFields.add(mapBuildingFields);
        }

        return UtilGeneral.createTestRecords(Building__c.sObjectType, ListOfMapFields, doInsert); 
    }

	public static Building__c createBuilding (string name, string city, string country, string state, string timeZone, Id responsibleCM, boolean doInsert)
	{
		stMapFields.put('Name', name);
        stMapFields.put('City__c', city);
        stMapFields.put('Country__c', country);
        stMapFields.put('State__c', state);
        stMapFields.put('Time_Zone__c', timeZone);
        stMapFields.put('Responsible_CM__c', responsibleCM);
        
        return createBuildings(1, doInsert)[0];
		
	}

}