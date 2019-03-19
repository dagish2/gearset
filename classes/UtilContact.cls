/*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Name:            UtilContact.cls
Description:    Contact Object Utility for testing and general functions .        
Date            Author          Summary of Changes 
7-OCT-2018     Rashad Saeed  Initial Implementation 
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest()
public class UtilContact {
    Private Static Map <String,Id>ActiveRecordTypes = UtilRecordType.GetSobjectActiveRecordTypes('Contact');    
    Private Static Map<String,Object> StMapFields = new Map<String,Object> ();
    
    public static List<Contact>GetNewContacts(Integer NumberOfRecords,Account Acc,Boolean DoInsert){
        List<Map<String,Object>> ListOfMapFields = new List<Map<String,Object>>();
        for (Integer i = 1, j = NumberOfRecords; i <= j; i++){
            Map<String,Object> ConFieldsMap = new Map<String,Object>(StMapFields);
            ConFieldsMap.put ('AccountId',Acc.id);
            ConFieldsMap.put ('FirstName',Acc.Name);
            ConFieldsMap.put ('LastName','Test_'+i);
            ConFieldsMap.put ('Email','wework@SF.SF'+i);
            ConFieldsMap.put ('Status__c','active');
            ListOfMapFields.add(ConFieldsMap);
        }
        return UtilGeneral.createTestRecords(Contact.sObjectType, ListOfMapFields, DoInsert); 
    }  
    
    public Static List <Contact> GetContactByRecordType (Integer NumberOfRecords,String RecordTypeName,Account Acc,Boolean DoInsert){
        RecordTypeName = RecordTypeName.toLowerCase();
        if (ActiveRecordTypes.containsKey(RecordTypeName))
            StMapFields.put('RecordTypeId',ActiveRecordTypes.get(RecordTypeName));
        else
            return null;
        return GetNewContacts(NumberOfRecords,Acc,DoInsert);
    }
}