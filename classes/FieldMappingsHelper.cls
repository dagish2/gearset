/************************************************************************************************************************************
    Author 		: 	Ajaysinh Chauhan	
    Description : 	This class contain all Mapping methods that are used for field mapping.
    
    History		:
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION		DATE				AUTHOR					DETAIL
    1			-					Ajaysinh Chauhan		Initial Developement(6,June 2018)
**************************************************************************************************************************************/
public class FieldMappingsHelper{
    
   /****************************************************************************************************************************
        Author 				: Ajaysinh Chauhan
        Description  		: This method used to create dynamic mapping when we pass sourceId, destinationId and FieldMapping name.  
        Created Date		: 6,June 2018
        Last Modified By 	: Ashish Mishra
        Last Modified Date  : 8,June 2018
   *****************************************************************************************************************************/
    public static sObject getMappings(Id sourceId,Id destinationId,String strFieldMapping){
        Map<Id,sObject> mapFieldMappings = getMappings(new Map<Id,Id>{sourceId=>destinationId},strFieldMapping);
        return mapFieldMappings.get(sourceId);
    }
    
   /****************************************************************************************************************************
        Author 				: Ajaysinh Chauhan
        Description  		: This method used to create dynamic mapping between objects when we pass sourceId and FieldMapping name.  
        Created Date		: 6,June 2018
        Last Modified By 	: Ashish Mishra
        Last Modified Date  : 8,June 2018
   *****************************************************************************************************************************/
    public static sObject getMappings(Id sourceId,String strFieldMapping){
        Map<Id,sObject> mapFieldMappings = getMappings(new Map<Id,Id>{sourceId=>null},strFieldMapping);
        return mapFieldMappings.get(sourceId);
    }
    
   /****************************************************************************************************************************************
        Author 				: Ajaysinh Chauhan
        Description  		: This method used to create dynamic mapping between objects when we pass list of sourceId and FieldMapping name.  
        Created Date		: 6,June 2018
        Last Modified By 	: Ashish Mishra
        Last Modified Date  : 8,June 2018
   ******************************************************************************************************************************************/
    public static Map<Id,sObject> getMappings(List<Id> setSourceIds,String strFieldMapping){
        return getMappings(new Set<Id>(setSourceIds),strFieldMapping);
    }
    
   /****************************************************************************************************************************
        Author 				: Ajaysinh Chauhan
        Description  		: This method used to create dynamic mapping between objects when we pass Set of sourceId and FieldMapping name.  
        Created Date		: 6,June 2018
        Last Modified By 	: Ashish Mishra
        Last Modified Date  : 8,June 2018
   *****************************************************************************************************************************/
    public static Map<Id,sObject> getMappings(Set<Id> setSourceIds,String strFieldMapping){
        Map<Id,Id> mapSourceDestination = new Map<Id,Id>();
        for(Id sourceId:setSourceIds){
            mapSourceDestination.put(sourceId,null);
        }
        return getMappings(mapSourceDestination,strFieldMapping);
    }
    
    /****************************************************************************************************************************
        Author 				: Ajaysinh Chauhan
        Description  		: This method used to create dynamic mapping when we pass sourceId and FieldMapping name.  
        Created Date		: 6,June 2018
        Last Modified By 	: Ashish Mishra
        Last Modified Date  : 8,June 2018
   *****************************************************************************************************************************/
    public static sObject getMappings(Id sourceId, sObject objDestination,String strFieldMapping){
        Debug.Log('sourceId---'+sourceId);
        Debug.Log('objDestination---'+objDestination);
        Debug.Log('map---'+(new Map<Id,sObject>{sourceId=>objDestination}));
        Map<Id,sObject> mapFieldMappings = getMappings(new Map<Id,sObject>{sourceId=>objDestination},strFieldMapping);
        return mapFieldMappings.get(sourceId);
    }
    
    /***********************************************************************************************************************************************
        Author 				: Ajaysinh Chauhan
        Description  		: This method used to create dynamic mapping when we pass Map of <sourceId and Destination object> and FieldMapping name.  
        Created Date		: 6,June 2018
        Last Modified By 	: Ashish Mishra
        Last Modified Date  : 8,June 2018
   *************************************************************************************************************************************************/
    public static Map<Id, sObject> getMappings(Map<Id, sObject> mapSourceDestination, String strFieldMapping){
        Map<Id,Id> mapFieldMappings = new Map<Id,Id>();
        sObject objFirstObject; 
        for(Id sourceId : mapSourceDestination.keySet()){
            Map<String,Object> mapDestination = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(mapSourceDestination.get(sourceId)));
            if(mapDestination.get('Id')!=null){
                mapFieldMappings.put(sourceId, String.valueOf(mapDestination.get('Id')));
            }else{
                mapFieldMappings.put(sourceId,null);
            }
            if(objFirstObject == null){
                objFirstObject = mapSourceDestination.get(sourceId);
            }
        }       
        Schema.DescribeSObjectResult sObjResult = objFirstObject.getSObjectType().getDescribe();
        Set<String> setFields = new Set<String>();
        for(String fieldName:sObjResult.fields.getMap().keyset()){
            Schema.DescribeFieldResult fieldResult = sObjResult.fields.getMap().get(fieldName).getDescribe();
            if(fieldResult.isCreateable() && !fieldResult.isAutoNumber() && !fieldResult.isCalculated()){
                setFields.add(fieldResult.getName());
            }
        }
        Map<Id,sObject> mapObjectMappings = getMappings(mapFieldMappings,strFieldMapping);
        for(Id sourceId:mapSourceDestination.keySet()){
            Map<String,Object> mapDestination = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(mapSourceDestination.get(sourceId)));
            sObject objDestination = mapObjectMappings.get(sourceId);
            if(objDestination != null){
                for(String strField:mapDestination.keySet()){                 
                    if(setFields.contains(strField) && mapDestination.get(strField)!=null){
                        Schema.DescribeFieldResult fieldResult = sObjResult.fields.getMap().get(strField).getDescribe();
                        if(String.valueOf(fieldResult.getType()).toLowerCase()=='date'){
                            objDestination.put(strField,Date.valueOf(String.valueOf(mapDestination.get(strField))));
                        }else if(String.valueOf(fieldResult.getType()).toLowerCase()=='datetime'){
                            DateTime dt = (DateTime)JSON.deserialize(String.valueOf(mapDestination.get(strField)), DateTime.class);
                            objDestination.put(strField,dt);
                        }else if(String.valueOf(fieldResult.getType()).toLowerCase()=='decimal'){
                            objDestination.put(strField,Decimal.valueOf(String.valueOf(mapDestination.get(strField))));
                        }else if(String.valueOf(fieldResult.getType()).toLowerCase()=='integer'){
                            objDestination.put(strField,Integer.valueOf(String.valueOf(mapDestination.get(strField))));
                        }else if(String.valueOf(fieldResult.getType()).toLowerCase()=='double'){
                            objDestination.put(strField,Double.valueOf(String.valueOf(mapDestination.get(strField))));
                        }else if(String.valueOf(fieldResult.getType()).toLowerCase()=='boolean'){
                            objDestination.put(strField,Boolean.valueOf(String.valueOf(mapDestination.get(strField))));
                        }else{
                            objDestination.put(strField,mapDestination.get(strField));
                        }
                    }
                }
                mapObjectMappings.put(sourceId,objDestination); 
            }else{                
                return mapObjectMappings;
            }            
        }
        return mapObjectMappings;
    }
    
    /***********************************************************************************************************************************************
        Author 				: Ajaysinh Chauhan
        Description  		: This method used to create dynamic mapping when we pass Map of <sourceId and Destination object> and FieldMapping name.  
        Created Date		: 6,June 2018
        Last Modified By 	: Ashish Mishra
        Last Modified Date  : 8,June 2018
   *************************************************************************************************************************************************/
    public static Map<Id,sObject> getMappings(Map<Id,Id> mapSourceDestination,String strFieldMapping){        
        Debug.log('strFieldMapping==>'+strFieldMapping);
        Setting__c objMapping = Settings.get(strFieldMapping);
        FieldMapping mapping = (FieldMapping)JSON.deserialize(objMapping.Data__c, FieldMapping.class);
        Set<String> setSourceFields = new Set<String>{'Id'};
            Set<String> setDestinationFields = new Set<String>{'Id'};
                //Do Changes In Key Set Contact field is Present 
                for(String Destination:mapping.mappings.keySet()){
                    if(!String.isBlank(Destination)){
                        setDestinationFields.add(Destination);
                    }
                    if(!String.isBlank(mapping.mappings.get(Destination).fieldname)){
                        setSourceFields.add(mapping.mappings.get(Destination).fieldname);
                    }
                }
        Set<Id> setSourceIds = mapSourceDestination.keySet();        
        setSourceIds.remove(null); 
        Set<Id> setDestinationIds = new Set<Id>(mapSourceDestination.values());        
        setDestinationIds.remove(null);        
        String sourceQuery = 'Select '+String.join(new List<String>(setSourceFields), ',')+' From '+objMapping.Source_Object__c+' Where Id IN:setSourceIds';
        String destinationQuery = 'Select '+String.join(new List<String>(setDestinationFields), ',')+' From '+objMapping.Destination_Object__c+' Where Id IN:setDestinationIds';
        Map<Id,sObject> mapSource = new Map<Id,sObject>(Database.query(sourceQuery));
        Map<Id,sObject> mapDestination = new Map<Id,sObject>(Database.query(destinationQuery));
        Map<Id,sObject> mapSourceDestinationMappings = new Map<Id,sObject>();
        for(sObject source: mapSource.values()){
            sObject destination;
            if(String.isNotBlank(mapSourceDestination.get(String.valueOf(source.get('Id'))))){
                destination = mapDestination.get(mapSourceDestination.get(String.valueOf(source.get('Id'))));
            }else{
                destination = Schema.getGlobalDescribe().get(objMapping.Destination_Object__c).newSObject();
            }
            
            for(String destinationField : mapping.mappings.keySet()){     
                if(mapping.mappings.get(destinationField).isvalue == true){
                    destination.put(destinationField,mapping.mappings.get(destinationField).value); 
                }else if(mapping.mappings.get(destinationField).overwrite == true || destination.get(destinationField)==null ) {
                    if(source.get(mapping.mappings.get(destinationField).fieldname)!=null){
                        destination.put(destinationField,source.get(mapping.mappings.get(destinationField).fieldname));   
                    }
                }                
            }
            mapSourceDestinationMappings.put(String.valueOf(source.get('Id')),destination);
        }       
        return mapSourceDestinationMappings;
    }
    
    public class FieldMapping{
        String version{get;set;}
        Map<String,Mapping> mappings{get;set;}
    }
    
    public class Mapping{
        String value{get;set;}
        Boolean overwrite{get;set;}
        Boolean isvalue{get;set;}
        String fieldname{get;set;}
    }
    
}