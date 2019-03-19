/*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Name:            Opportunity.cls
Description:    Opportunity Object Utility for testing and general functions .        
Date            Author          Summary of Changes 
7-OCT-2018     Rashad Saeed  Initial Implementation 
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
public class UtilOpportunity {
    
    Private Static Map <String,Id>ActiveRecordTypes = UtilRecordType.GetSobjectActiveRecordTypes('Opportunity');    
    Private Static Map<String,Object> StMapFields = new Map<String,Object> ();
   
    public static List<Opportunity>GetNewOpportunity(Integer NumberOfRecords,Account Acc,Boolean DoInsert){
        List<Map<String,Object>> ListOfMapFields = new List<Map<String,Object>>();
        for (Integer i = 1, j = NumberOfRecords; i <= j; i++){
            Map<String,Object> OppFieldsMap = new Map<String,Object>(StMapFields);
            OppFieldsMap.put ('AccountId',Acc.id);
            OppFieldsMap.put ('StageName','New');
            String OppName = Acc.Name+'_'+i;
            OppFieldsMap.Put ('Name',OppName);
            OppFieldsMap.Put ('CloseDate',System.today().addDays(5));
            OppFieldsMap.Put ('LeadSource','WeWork.com');
            ListOfMapFields.add(OppFieldsMap);
        }
        return UtilGeneral.createTestRecords(Opportunity.sObjectType, ListOfMapFields, DoInsert); 
    }  
    
    public Static List <Opportunity> GetOppByRecordType (Integer NumberOfRecords,String RecordTypeName,Account Acc,Boolean DoInsert){
        RecordTypeName = RecordTypeName.toLowerCase();
        if (ActiveRecordTypes.containsKey(RecordTypeName))
            StMapFields.put('RecordTypeId',ActiveRecordTypes.get(RecordTypeName));
        else
            return null;
        return GetNewOpportunity (NumberOfRecords,Acc,DoInsert);
    }

    public static Opportunity createOppWithGeoAndContact(integer NumberOfRecords, Account acc, Id contactId, Id geo, boolean doInsert)
    {
    	StMapFields.put('Primary_Member__c',contactId);
    	StMapFields.put('Geography__c',geo);

    	return GetNewOpportunity (NumberOfRecords, Acc, DoInsert)[0];
    }
}