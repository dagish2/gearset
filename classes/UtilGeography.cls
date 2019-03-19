/**
* @author Gad Sharon    
* @date 01/10/18
* @description Util class for the Geography__c object.
*/

public class UtilGeography {

    Private Static Map<String, Object> stMapFields = new Map<String, Object>();

    public static List <Geography__c> createGeography (Integer numberOfRecords, Boolean doInsert)
    {
        List<Map<String,Object>> ListOfMapFields = new List<Map<String,Object>>();

        for (Integer i = 0; i < numberOfRecords; i++)
        {
            Map <String, Object> mapGeoFields = new Map <String, Object>(stMapFields);
            mapGeoFields.put('Location_Type__c', 'APPROXIMATE');
            mapGeoFields.put('CurrencyIsoCode', 'USD');
            ListOfMapFields.add(mapGeoFields);
        }

        return UtilGeneral.createTestRecords(Geography__c.sObjectType, ListOfMapFields, doInsert); 
    }

    public static Geography__c createGeography(string name, string city, string country, string district, string state, string address, string json, string placeId, Id nearestBuilding, Object latitude, Object longitude, boolean doInsert)
    {
        stMapFields.put('Name', name);
        stMapFields.put('City__c', city);
        stMapFields.put('Country__c', country);
        stMapFields.put('District__c', district);
        stMapFields.put('State__c', state);
        stMapFields.put('Formatted_Address__c', address);
        stMapFields.put('JSON__c', json);
        stMapFields.put('Place_ID__c', placeId);
        stMapFields.put('Nearest_Building__c', nearestBuilding);
        stMapFields.put('Geocode__Latitude__s', latitude);
        stMapFields.put('Geocode__Longitude__s', longitude);
     	
        return createGeography(1, doInsert)[0];
    }

}