/*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Name:            UtilRecordType.cls

Description:    RecordType Utility for testing and general functions .        
Date            Author          Summary of Changes 
18-sep-2018     Rashad Saeed  Initial Implementation 
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
public class UtilRecordType {
    
    Private static map <string, Map<String,Id>> mapObjectToRecrdTypes = new map <string, Map<String,Id>>();
    Private static map <string, Map<Id,string>> mapObjectToRecrdTypesById = new map <string, Map<Id,string>>();
    
    Public Static Map<String,Id> GetSobjectActiveRecordTypes (String ObjName)
    {
        if(!mapObjectToRecrdTypes.containsKey(ObjName.toLowerCase()))
        {
            addToMaps(ObjName);
        }
        
        return mapObjectToRecrdTypes.get(ObjName.toLowerCase()); 
    }

    Public Static Map<Id,string> GetSobjectActiveRecordTypesById (String ObjName)
    {
        if(!mapObjectToRecrdTypes.containsKey(ObjName.toLowerCase()))
        {
            addToMaps(ObjName);
        }

        return mapObjectToRecrdTypesById.get(ObjName.toLowerCase());
    }

    Private static void addToMaps(String ObjName)
    {
        Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get(ObjName).getDescribe();
        List<Schema.RecordTypeInfo> recordTypeInfo = sobjectResult.getRecordTypeInfos();
        Map<String,Id> mapRecordTypeNameId = new Map<String,Id>();
        Map<Id,string> mapRecordTypeIdName = new Map<Id,string>();
        for(Schema.RecordTypeInfo info : recordTypeInfo){
            if (info.isActive())
                mapRecordTypeNameId.put(info.getDeveloperName().toLowerCase(),info.getRecordTypeId());
                mapRecordTypeIdName.put(info.getRecordTypeId(), info.getDeveloperName().toLowerCase());
        }
        
        mapObjectToRecrdTypes.put(ObjName.toLowerCase(), mapRecordTypeNameId);
        mapObjectToRecrdTypesById.put(ObjName.toLowerCase(), mapRecordTypeIdName);

    }
}