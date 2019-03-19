/*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Name:            UtilAccount.cls

Description:    Account Object Utility for testing and general functions .        
Date            Author          Summary of Changes 
25-SEP-2018     Rashad Saeed  Initial Implementation 
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest()
public Class UtilAccount {
    // this method return Accounts with for all active recordtypes with auto fields mapping 'for Required  fields only '.
    Private Static String MethodNameRunning ='';
    Private Static Map <String,Id>ActiveRecordTypes = UtilRecordType.GetSobjectActiveRecordTypes('Account');
    Private Static List <Id> RecordTypeIds = ActiveRecordTypes.Values();
    Private Static Map<String,Object> StMapFields = new Map<String,Object> ();
    
    public static List<Account>GetNewAccounts(Integer NumberOfRecords,Boolean DoInsert)
    {
        Boolean SetSize = (MethodNameRunning=='GetAccountsWithAllRecordTypes') ? True : False;
        if (NumberOfRecords<RecordTypeIds.size()&&SetSize)
            NumberOfRecords=RecordTypeIds.size(); 
        List<Map<String,Object>> ListOfMapFields = new List<Map<String,Object>>();
        for (Integer i = 1, j = NumberOfRecords; i <= j; i++){
            Map<String,Object> AccountFieldsMap = new Map<String,Object>(StMapFields);
            If (MethodNameRunning=='GetAccountsWithAllRecordTypes')
                AccountFieldsMap.put('RecordTypeId',RecordTypeIds[math.mod(i,RecordTypeIds.size())]);
            AccountFieldsMap.put ('Name','Test-'+i);
            ListOfMapFields.add(AccountFieldsMap);
        }
        return UtilGeneral.createTestRecords(Account.sObjectType, ListOfMapFields, DoInsert);
    }

    public static List <Account> GetAccountsWithAllRecordTypes (Boolean DoInsert)
    {
        MethodNameRunning ='GetAccountsWithAllRecordTypes';   
        return GetNewAccounts(1,false);
    }

    // this method return Accounts for all active recordtypes with field mapping if there is Required fields missing this method will fill it automatically .
    Public Static List <Account>GetNewAccountsWithFieldMapping (Integer NumberOfRecords,Map<String,Object> MapFields,Boolean DoInsert){
        StMapFields = MapFields.clone();
        MethodNameRunning ='GetNewAccountsWithFieldMapping';
        return GetNewAccounts(NumberOfRecords,false);
    }
    
    // this method will return accounts with specific record type ex .  GetNewAccountsByRecordType (10,'Consumer',Map<String,Object>,false)
    Public static list <Account> GetNewAccountsByRecordType (Integer NumberOfRecords,String RecordTypeName,Map<String,Object> MapFields,Boolean DoInsert)
    {
        StMapFields = MapFields.clone();
        RecordTypeName = RecordTypeName.toLowerCase();
        MethodNameRunning ='GetNewAccountsByRecordType';
        if (ActiveRecordTypes.containsKey(RecordTypeName))
            StMapFields.put('RecordTypeId',ActiveRecordTypes.get(RecordTypeName));
        else
            return null;
        return GetNewAccounts(NumberOfRecords,DoInsert);
    } 
    
    // TO DO 
    // Create new method that create accounts with related contacts . 
    // Create new method that create accounts with related Opportunities . 
}