public class UtilGeneral
{
    private static Map<string, Map<String, Schema.DescribeFieldResult>> describeFieldPerObjectMap = new Map<string, Map<String, Schema.DescribeFieldResult>>();
    
    // <summary>
    // Created By: Anant Kumar.
    // Created On: 23-02-2016.
    // Purpose: To Create multiple Test Records for Test methods.
    // Parameters:
    // 1. intRecordCount: Number of Records to be Created.
    // 2. sObjectTypeRequested: sObject Type for which record to be Created.
    // 3. recordValuesMap: If record has specific value for Fields.
    // 4. DoInsert: Perform insert or return Only records.
    // Return type: List of Requested sObject Type Records.
    
    public static List<sObject> createTestRecords(Integer intRecordCount, Schema.sObjectType sObjectTypeRequested, List<Map<String, Object>> recordValuesList, Boolean DoInsert)
    {
        List<sObject> sObjectList = new List<sObject>();
        sObject record;
                
        Map<String, Schema.DescribeFieldResult> requiredFieldsMap = getNullabelRequiredFields(sObjectTypeRequested);
        
        for(integer index = 0; index < intRecordCount; index++)
        {    
            record = sObjectTypeRequested.newSobject();
            Map<String, Object> recordValuesMap;
            
            if(recordValuesList != null && intRecordCount <= recordValuesList.size())
            {
                recordValuesMap = recordValuesList[index];
            }
            else if(recordValuesList != null && recordValuesList.size() > 0)
            {
                recordValuesMap = recordValuesList[0];
            }
            
            if(recordValuesMap != null && !recordValuesMap.isEmpty())
            {
                for(String strUserField : recordValuesMap.keySet())
                {                    
                    record.put(strUserField.trim(), recordValuesMap.get(strUserField));
                }   
            }
            
            for(String strField : requiredFieldsMap.keySet())
            {
                if(recordValuesMap == null || recordValuesMap.isEmpty() || !recordValuesMap.containsKey(strField))
                {
                    record.put(strField, getTestValue(requiredFieldsMap.get(strField)));    
                }
            }
            
            sObjectList.add(record);
        }
        
        if(DoInsert)
        {
            insert sObjectList;
        }
        
        return sObjectList;
    }

    // Created By: Anant Kumar
    // Created On: 23-02-2016
    // Purpose: To Create a Test Records for Test methods.
    // Parameters:
    // 1. sObjectTypeRequested: sObject Type for which record to be Created.
    // 2. recordValuesMap: If record has specific value for Fields.
    // 3. DoInsert: Perform insert or return Only records.
    // Return type: single sObject type record.
    public static sObject createTestRecords(Schema.sObjectType sObjectTypeRequested, Map<String,Object> recordValuesMap, Boolean DoInsert)
    {
        List<Map<String,Object>> newListOfMap = new List<Map<String,Object>>(); 
        newListOfMap.add(recordValuesMap);
        return createTestRecords(1, sObjectTypeRequested, newListOfMap, DoInsert)[0];
    }

    //Return Type: Mulitple sObject type record
    public static List<sObject> createTestRecords(Schema.sObjectType sObjectTypeRequested, List<Map<String,Object>> recordValuesList,Boolean DoInsert)
    {
        return createTestRecords(recordValuesList.size(), sObjectTypeRequested, recordValuesList, DoInsert);
    }
    
    // <summary>
    // Created By: Anant Kumar
    // Created On: 23-02-2016.
    // Purpose: To Get the Required Fields from sObject.
    // Parameters:
    // 1. sObjectTypeRequested: sObject Type to get Required Fields.    
    // Return type: List Field Describe Object of required Fields.
    
    static Map<String, Schema.DescribeFieldResult> getNullabelRequiredFields(Schema.sObjectType sObjectTypeRequested)
    {
        Map<String, Schema.DescribeFieldResult> describeFieldMap = new Map<String, Schema.DescribeFieldResult>();
        Schema.DescribeSObjectResult dResult = sObjectTypeRequested.getDescribe();
        
        //If we already got the fields for this object.
        if(describeFieldPerObjectMap.containsKey(dResult.getName()))
        {
            return describeFieldPerObjectMap.get(dResult.getName());
        }

        Map<String, Schema.SObjectField> fieldsMap = dResult.fields.getMap();
        for(Schema.SObjectField field : fieldsMap.values())
        {
            Schema.DescribeFieldResult fieldMetadata = field.getDescribe();
            if(fieldMetadata.IsCreateable() && !fieldMetadata.IsNillable() && !fieldMetadata.IsDefaultedOnCreate())
            {
                describeFieldMap.put(fieldMetadata.getName(), fieldMetadata);
            }
        }

        describeFieldPerObjectMap.put(dResult.getName(), describeFieldMap);

        return describeFieldPerObjectMap.get(dResult.getName());
    }
    
    // <summary>
    // Created By: Anant Kumar.
    // Created On: 23-02-2016.
    // Purpose: To Get the Test Values for sObject's Required Fields.
    // Parameters:
    // 1. fieldDescribe: Result of Field Describe.    
    // Return type: Object of Test Value.
    static Object getTestValue(Schema.DescribeFieldResult fieldDescribe)
    {
        Object TestValue = null;
        if(fieldDescribe != null)
        {
            Schema.DisplayType displayType = fieldDescribe.getType();

            if(displayType.equals(Schema.DisplayType.Email))
            { 
                TestValue = createStringValue() +'@Email.com';
            }
            else if(displayType.equals(Schema.DisplayType.DATETIME))
            {
                TestValue = DateTime.now();
            }
            else if(displayType.equals(Schema.DisplayType.STRING) || displayType.equals(Schema.DisplayType.TEXTAREA))
            {
                TestValue = createStringValue();
            }
            else if(displayType.equals(Schema.DisplayType.URL))
            {
                TestValue = 'https://'+ createStringValue() +'.com';
            }
            else if(displayType.equals(Schema.DisplayType.TIME))
            {
                TestValue = Time.newInstance(12, 00, 00, 00);
            }
            else if(displayType.equals(Schema.DisplayType.BASE64))
            {
                TestValue = Blob.valueOf(createStringValue());
            }
            else if(displayType.equals(Schema.DisplayType.Currency))
            {
                TestValue = math.rint( math.random() * 100000 );
            }
            else if(displayType.equals(Schema.DisplayType.Date))
            {
                TestValue = Date.today();
            }
            else if(displayType.equals(Schema.DisplayType.Double))
            {
                TestValue = math.rint( math.random() * 100000 );
            }
            else if(displayType.equals(Schema.DisplayType.Percent))
            {
                TestValue = math.rint( math.random() * 100000 );
            }
            else if(displayType.equals(Schema.DisplayType.Phone))
            {
                TestValue = 987654321;
            }
            else if(displayType.equals(Schema.DisplayType.Reference) && 
                    fieldDescribe.getReferenceTo()[0] != BusinessHours.sObjectType)
            {
                List<sObject> sObjectList = createTestRecords(1,fieldDescribe.getReferenceTo()[0], null,true);
                TestValue = sObjectList[0].Id;
            }
        }        
        return TestValue;
    }
    
    //Purpose: To get the Random Name for Test Record.
    public static String createStringValue()
    {
        return 'Te' + math.rint((math.random() * 1000));
    }
}