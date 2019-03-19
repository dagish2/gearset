@isTest
public class TestingUtility {
    
    public static List<String> monthsList = new List<String>{'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'};
    public static final String CURRENT_YEAR = String.valueOf( Date.today().year() );
    public static Boolean isAccounstInserted = false;
    public static Boolean isBillingAccountInserted = false;
    public static Boolean isContactsInserted = false;
    public static Boolean isOpportunityInserted = false;
    public static Boolean isTaskInserted = false;
    public static Boolean isMarketInserted = false;
    public static Boolean isBuildingInserted = false;
    public static Boolean isJourneyInserted = false;
    public static Boolean isLeadInserted = false;
    public static Boolean isCampaignInserted = false;
    public static Boolean isTourScheduleInserted = false;
    public static Boolean isTourOpenHours = false;
    public static Boolean isCasesInserted = false;
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
    
    public static List<sObject> createTestRecords(Integer intRecordCount,Schema.sObjectType sObjectTypeRequested, List<Map<String,Object>> recordValuesList,Boolean DoInsert){
        List<sObject> sObjectList = new List<sObject>();
        Map<String,Schema.DescribeFieldResult> requiredFieldsMap = getNullabelRequiredFields(sObjectTypeRequested);
        sObject record = null;
        for(integer index = 0; index < intRecordCount; index++){            
            record = sObjectTypeRequested.newSobject();
            Map<String, Object> recordValuesMap;
            if(recordValuesList != null && intRecordCount <= recordValuesList.size()){
                recordValuesMap = recordValuesList[index];
            }
            else if(recordValuesList != null && recordValuesList.size() > 0){
                recordValuesMap = recordValuesList[0];
            }
            if(recordValuesMap != null && !recordValuesMap.isEmpty()){
                for(String strUserField : recordValuesMap.keySet()){                    
                    record.put(strUserField.trim(),recordValuesMap.get(strUserField));
                }   
            }            
            for(String strField : requiredFieldsMap.keySet()){
                if(recordValuesMap == null || recordValuesMap.isEmpty() || !recordValuesMap.containsKey(strField)) {
                    record.put(strField,getTestValue(requiredFieldsMap.get(strField)));    
                }
            }          
            sObjectList.add(record);
        }
        if(DoInsert){
            InsertListWithAssert(sObjectList); 
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
    public static sObject createTestRecords(Schema.sObjectType sObjectTypeRequested, Map<String,Object> recordValuesMap,Boolean DoInsert){
        List<Map<String,Object>> newListOfMap = new List<Map<String,Object>>(); 
        newListOfMap.add(recordValuesMap);
        return createTestRecords(1, sObjectTypeRequested, newListOfMap, DoInsert)[0];
    }
    
    //Return Type: Mulitple sObject type record
    public static List<sObject> createTestRecords(Schema.sObjectType sObjectTypeRequested, List<Map<String,Object>> recordValuesList,Boolean DoInsert){
        return createTestRecords(recordValuesList.size(), sObjectTypeRequested, recordValuesList, DoInsert);
    }
    
    // <summary>
    // Created By: Anant Kumar
    // Created On: 23-02-2016.
    // Purpose: To Get the Required Fields from sObject.
    // Parameters:
    // 1. sObjectTypeRequested: sObject Type to get Required Fields.    
    // Return type: List Field Describe Object of required Fields.
    static Map<String,Schema.DescribeFieldResult> getNullabelRequiredFields(Schema.sObjectType sObjectTypeRequested){
        Map<String,Schema.DescribeFieldResult> describeFieldMap = new Map<String,Schema.DescribeFieldResult>();
        Schema.DescribeSObjectResult dResult = sObjectTypeRequested.getDescribe();
        Map<String,Schema.SObjectField> fieldsMap = dResult.fields.getMap();
        for(Schema.SObjectField field : fieldsMap.values()){
            Schema.DescribeFieldResult fieldMetadata = field.getDescribe();
            if(fieldMetadata.IsCreateable() && !fieldMetadata.IsNillable() && !fieldMetadata.IsDefaultedOnCreate() ){
                describeFieldMap.put(fieldMetadata.getName(),fieldMetadata);
            }
        }
        return describeFieldMap;
    }    
    
    // <summary>
    // Created By: Anant Kumar.
    // Created On: 23-02-2016.
    // Purpose: To Get the Test Values for sObject's Required Fields.
    // Parameters:
    // 1. fieldDescribe: Result of Field Describe.    
    // Return type: Object of Test Value.
    static Object getTestValue(Schema.DescribeFieldResult fieldDescribe){
        Object TestValue = null;
        if(fieldDescribe != null){
            Schema.DisplayType displayType = fieldDescribe.getType();
            if(displayType.equals(Schema.DisplayType.Email)){ 
                TestValue = createStringValue() +'@Email.com';
            } else if(displayType.equals(Schema.DisplayType.DATETIME)){
                TestValue = DateTime.now();
            }else if(displayType.equals(Schema.DisplayType.STRING) || displayType.equals(Schema.DisplayType.TEXTAREA)){
                TestValue = createRandomString();
            }else if(displayType.equals(Schema.DisplayType.URL)){
                TestValue = 'https://'+ createStringValue() +'.com';
            }else if(displayType.equals(Schema.DisplayType.TIME)){
                TestValue = Time.newInstance(12, 00, 00, 00);
            }else if(displayType.equals(Schema.DisplayType.BASE64)){
                TestValue = Blob.valueOf(createStringValue());
            }else if(displayType.equals(Schema.DisplayType.Currency)){
                TestValue = math.rint( math.random() * 100000 );
            }else if(displayType.equals(Schema.DisplayType.Date)){
                TestValue = Date.today();
            }else if(displayType.equals(Schema.DisplayType.Double)){
                TestValue = math.rint( math.random() * 100000 );
            }else if(displayType.equals(Schema.DisplayType.Percent)){
                TestValue = math.rint( math.random() * 100000 );
            }else if(displayType.equals(Schema.DisplayType.Phone)){
                TestValue = 987654321;
            }else if(displayType.equals(Schema.DisplayType.Reference)){
                List<sObject> sObjectList = createTestRecords(1,fieldDescribe.getReferenceTo()[0], null,true);
                TestValue = sObjectList[0].Id;
            }
        }        
        return TestValue;
    }
    
    //Method to get the record type of sObjects By Name.
    public static Map<String,Id> getRecordTypeMapByName ( Schema.SObjectType sObjectType){
        Map<String,Id> recordTypeByNameMap = new Map<String,Id>();
        for( RecordType recordType :  [SELECT Id, Name FROM RecordType WHERE sObjectType =: String.valueOf(sObjectType)])
            recordTypeByNameMap.put( recordType.Name, recordType.Id);            
        return recordTypeByNameMap;
    }
    
    //Method to get the Admin User
    public static User getAdminUser(){
        return [SELECT Id, Name, Email FROM User WHERE Profile.Name ='System Administrator' AND IsActive = true LIMIT 1]; 
    }
    
    //Method to get the guest User
    public static User getGuestUser(){
        User guestUser = [SELECT Id, alias, Email, LastName, ProfileId, UserName, CommunitynickName FROM User WHERE userType='Guest'  LIMIT 1];
        system.assert(guestUser != null,'No Guest User Found');
        return guestUser;
    }
    
    //Method to get the current User
    public static User getCurrentUser(){
        User currentUser = [SELECT Id, Alias, Email, Lastname, FirstName,Profileid, UserName, CommunitynickName,CompanyName FROM user WHERE Id = :UserInfo.getUserId()]; 
        return currentUser;
    }
    
    //Method to get the admin profile id
    public static Id getAdminProfileId(){
        Id profileId = [SELECT Id FROM Profile WHERE Name =:'System Administrator' LIMIT 1].Id;
        return profileId;
    }
    //Purpose: To get the Random Name for Test Record.
    public static String createStringValue(){
        return'TestValue' + math.rint( math.random() * 100000 );
    }
    
    //Purpose: To get the Random Name for Test Record.
    public static String createRandomString(){
        return'Te' + math.rint( (math.random() * 1000));
    }
    
    // <summary>
    // Created By: Anant Kumar.
    // Created On: 23-02-2016.
    // Purpose: To Get the Test Values for sObject's Required Fields.
    // Parameters:
    // 1. objName: API Name of object.  
    // 2. fieldsToCheck : Fields name to be check for Access.  
    // 3. crudType: crudType i.e Delete, Update, Insert
    // Return type: Is Fields has specified Access.
    public Boolean checkObjectCrud( Schema.SObjectType objectType, Set<String> fieldsToCheck, String crudType ){  
        // Get the global describe
        Schema.DescribeSObjectResult objectResult = objectType.getDescribe();
        Map<String,Schema.SObjectField> fieldsMap = objectResult.fields.getMap();
        if(fieldsToCheck != null && !fieldsToCheck.isEmpty()){
            for(String field : fieldsToCheck){
                if(fieldsMap.containsKey(field)){
                    Schema.DescribeFieldResult fieldDescribe = fieldsMap.get( field ).getDescribe();
                    if('create'.equalsIgnoreCase( crudType ) && !fieldDescribe.isCreateable()){
                        return false;
                    }else if( 'update'.equalsIgnoreCase( crudType ) && !fieldDescribe.isUpdateable()){
                        return false;
                    }else if( 'delete'.equalsIgnoreCase( crudType ) && !fieldDescribe.isRestrictedDelete()){
                        return false;
                    }
                }else{
                    return false;
                }
            }
        }
        return true;
    }
    
    
    /* Database Operations */
    // Insert Single Record and Assert.
    public static Database.SaveResult insertWithAssert( sObject dataObject){
        Database.SaveResult saveResult = Database.insert( dataObject);
        System.assert(saveResult.isSuccess());
        return saveResult;
    }
    
    public static Database.SaveResult insertWithAssert( sObject dataObject,string msg){
        Database.SaveResult saveResult = Database.insert( dataObject);
        System.assert(saveResult.isSuccess(), msg);
        return saveResult;
    }
    
    // Update Single Record and Assert.
    public static Database.SaveResult updateWithAssert( sObject dataObject){
        Database.SaveResult saveResult = Database.update( dataObject);
        System.assert( saveResult.isSuccess());
        return saveResult;
    }
    
    public static Database.SaveResult updateWithAssert( sObject dataObject,string msg){
        Database.SaveResult saveResult = Database.update( dataObject);
        System.assert(saveResult.isSuccess(), msg);
        return saveResult;
    }
    
    // Upsert Single Record and Assert.
    public static Database.Upsertresult upsertWithAssert( sObject dataObject){
        Database.Upsertresult upsertResult = Database.upsert( dataObject);
        System.assert( upsertResult.isSuccess());
        return upsertResult;
    }
    
    // Delete single Record and Assert.
    public static Database.DeleteResult deleteWithAssert( sObject dataObject){
        Database.DeleteResult deleteResult = Database.delete( dataObject);
        System.assert( deleteResult.isSuccess());
        return deleteResult;
    }
    
    // Insert List of records and Assert.
    public static Database.SaveResult[] insertListWithAssert( List<sObject> sObjectsList){
        Database.SaveResult[] arrSaveResult = Database.insert( sObjectsList);
        for(Database.SaveResult saveResult : arrSaveResult){
            System.assert( saveResult.isSuccess());
        }        
        return arrSaveResult;
    }
    
    // Update List of Records with Assert.
    public static Database.SaveResult[] updateListWithAssert( List<sObject> sObjectsList){
        Database.SaveResult[] arrUpdateResult = Database.update( sObjectsList);
        for(Database.SaveResult saveResult : arrUpdateResult){
            System.assert( saveResult.isSuccess());  
        }           
        return arrUpdateResult;
    }
    
    // Upsert List of records with Assert.
    public static Database.Upsertresult[] upsertListWithAssert( List<sObject> sObjectsList){
        Database.Upsertresult[] arrSaveResult = Database.upsert( sObjectsList);
        for(Database.Upsertresult saveResult : arrSaveResult){
            System.assert( saveResult.isSuccess());   
        }        
        return arrSaveResult;
    }
    
    //Delete List of records with Assert.
    public static Database.DeleteResult[] deleteListWithAssert( List<sObject> sObjectsList){
        Database.DeleteResult[] arrDeleteResult = Database.delete( sObjectsList);
        for(Database.DeleteResult deleteResult : arrDeleteResult){
            System.assert( deleteResult.isSuccess());
        }        
        return arrDeleteResult;
    }
    
    //Current Pagereference
    public static pagereference currentPageReference( String pageName, Map<String,String> queryStringMap){        
        PageReference pageRef =  new ApexPages.PageReference(pageName);
        for(String key : queryStringMap.keySet()){
            pageRef.getParameters().put(key,queryStringMap.get(key));
        }
        Test.setCurrentPageReference(pageRef);
        system.assert(pageRef != null);
        return pageRef;
    }
  
    // <summary>
    // Created By: Anant Kumar.
    // Created On: 23/02/2016.
    // Purpose: User create/insert method.
    // Parameters:
    // 1. Id: profileId.  
    // 2. Map Of User Fields 
    // 3. crudType: crudType i.e Insert
    // Return type: Single User.
    public static User insertUserWithAssert(Id profileId,Map<String,Object> recordValuesMap){
        return insertUserWithAssert(profileId, recordValuesMap, true);
    }
    
    public static User insertUserWithAssert(Id profileId, Map<String,Object> recordValuesMap, Boolean b_doInsert){
        Map<String,Object> userRecordMap = new Map<String,Object>();
        userRecordMap.put('alias','te');
        userRecordMap.put('Username',createStringValue()+'standarduser@test.com');
        userRecordMap.put('ProfileId',profileId);
        userRecordMap.put('EmailEncodingKey','ISO-8859-1');
        userRecordMap.put('LanguageLocaleKey','en_US');
        userRecordMap.put('LocaleSidKey','en_US');
        userRecordMap.put('TimeZoneSidKey','America/Los_Angeles');
        //Added by Milanjeet Singh to overcome from duplicate Community nickname
        userRecordMap.put('CommunityNickname', createStringValue()+DateTime.now().getTime());
        if(recordValuesMap != null){
            for(String key : recordValuesMap.keySet()){
                userRecordMap.put(key,recordValuesMap.get(key));
            }
        } 
        User objUser = new User();
        objUser = (User)TestingUtility.createTestRecords(User.SObjectType, userRecordMap, b_doInsert);
        return objUser;
    }
    
    public static List<User> insertUserWithAssert(Id profileId, List<Map<String,Object>> lstRecordValuesMap, Boolean b_doInsert){
        List<Map<String,Object>> lstUserRecordValuesMap = new List<Map<String,Object>>();
        for(Map<String,Object> recordValuesMap : lstRecordValuesMap){
            Map<String,Object> userRecordMap = new Map<String,Object>();
            userRecordMap.put('alias','te');
            userRecordMap.put('Username',createStringValue()+'standarduser@test.com');
            userRecordMap.put('ProfileId',profileId);
            userRecordMap.put('EmailEncodingKey','ISO-8859-1');
            userRecordMap.put('LanguageLocaleKey','en_US');
            userRecordMap.put('LocaleSidKey','en_US');
            userRecordMap.put('TimeZoneSidKey','America/Los_Angeles');
            //Added by Milanjeet Singh to overcome from duplicate Community nickname
            userRecordMap.put('CommunityNickname', createStringValue()+DateTime.now().getTime());
            if(recordValuesMap != null){
                for(String key : recordValuesMap.keySet()){
                    userRecordMap.put(key,recordValuesMap.get(key));
                }
            }
            lstUserRecordValuesMap.add(userRecordMap);
        }
        return (List<User>)createTestRecords(lstUserRecordValuesMap.size(), User.SObjectType, lstUserRecordValuesMap, b_doInsert);
    }
    
    // Purpose: get sObject Picklist Values.
    // Parameters:
    // 1. String ObjectApiName: object Name.  
    // 2. String strFieldName: picklist field api name 
    // 3. crudType: crudType i.e Insert
    // Return type: List Of Picklist Values
    public static List<String> getPicklistValues(String strObjectApiName,String strFieldName){
        List<String> pickValsList=new List<String>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(strObjectApiName);
        Sobject sObjName = targetType.newSObject();
        Schema.sObjectType sObjType = sObjName.getSObjectType();
        Schema.DescribeSObjectResult sObjDescribe = sObjType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = sObjDescribe.fields.getMap();
        List<Schema.PicklistEntry> picklistEntryList = fieldMap.get(strFieldName).getDescribe().getPickListValues();
        for (Schema.PicklistEntry pcEntry : picklistEntryList) { 
            pickValsList.add(pcEntry.getValue());
        }
        return pickValsList;
    }
    
    //create single account record with assertion
    public static Account createAccount(String strAccountName, Boolean b_doInsert ){
        Map<String,Object> recordValuesMap = new Map<String,Object>();
        List<Map<String,Object>> newListOfMap = new List<Map<String,Object>>(); 
        recordValuesMap.put('Name',strAccountName);
        newListOfMap.add(recordValuesMap);
        return (Account)createTestRecords(1, Account.sObjectType, newListOfMap, b_doInsert)[0];
        
    }
    
    //create account records with assertion
    public static List<Account> createAccounts( Integer i_AccCount, String strName, Boolean b_doInsert ){
        //create different account records with assertion
        List<Map<String,Object>> accountRecordListOfMap = new List<Map<String,Object>>();
        for( Integer i = 0; i < i_AccCount; i++ ){
            Map<String,Object> accountRecordMap = new Map<String,Object>();
            accountRecordMap.put('Name',strName+i);
            accountRecordListOfMap.add(accountRecordMap);
        }
        return createTestRecords(Account.sObjectType, accountRecordListOfMap, b_doInsert);
    }
    
    //create single contact records with assertion
    public static Contact createContact( Id acctId, String strLastName, Boolean b_doInsert ){
        //Create Contact Data
        Map<String,Object> recordValuesMap = new Map<String,Object>();
        List<Map<String,Object>> newListOfMap = new List<Map<String,Object>>(); 
        recordValuesMap.put('LastName',strLastName);
        recordValuesMap.put('AccountId',acctId);
        recordValuesMap.put('Email','Test@Example.com');
        newListOfMap.add(recordValuesMap);
        return (Contact)createTestRecords(1, Contact.sObjectType, newListOfMap, b_doInsert)[0];
    }
    
    //create single contact records with assertion
    public static Contact createContact(Map<String,Object> recordValuesMap, Boolean doInsert ){
        //Create Contact Data
        if(recordValuesMap.get('LastName') == null){
            recordValuesMap.put('LastName','Last Name 1'); 
        } 
        if(recordValuesMap.get('Email') == null){
            recordValuesMap.put('Email','Test'+createUserCommunityName()+'@Example.com');
        }
        return (Contact)createTestRecords(Contact.sObjectType, recordValuesMap, doInsert);
    }
    
    //create single Opportunity records with assertion
    public static Opportunity createOpportunity(Id accountId, Boolean b_doInsert){
        List<String> stageValsList = TestingUtility.getPicklistValues('Opportunity','StageName');    
        Map<String,Object> recordValuesMap = new Map<String,Object>();
        recordValuesMap.put('StageName',stageValsList[0]);
        recordValuesMap.put('Name','Test Opportunity');
        recordValuesMap.put('CloseDate',System.today().addDays(30));
        recordValuesMap.put('AccountId',accountId);
        return (Opportunity)createTestRecords(Opportunity.sObjectType, recordValuesMap, b_doInsert);        
    }

    public static Opportunity createOpportunity(Map<String,Object> recordValuesMap, Boolean doInsert){    
        if(String.isBlank((String)recordValuesMap.get('StageName'))){
            List<String> stageValsList = TestingUtility.getPicklistValues('Opportunity','StageName');
            recordValuesMap.put('StageName',stageValsList[0]);
        }
        if(recordValuesMap.get('CloseDate')==null){
            recordValuesMap.put('CloseDate',System.today().addDays(30));
        }
        recordValuesMap.put('Name','Test Opportunity');
        return (Opportunity)createTestRecords(Opportunity.sObjectType, recordValuesMap, doInsert);        
    }

    public static Account createAccount(Map<String,Object> recordValuesMap, Boolean doInsert){  
        if(String.isBlank((String)recordValuesMap.get('Name'))){
            recordValuesMap.put('Name','Test Opportunity');
        }
        return (Account)createTestRecords(Account.sObjectType, recordValuesMap, doInsert);        
    }
    
    //Create single opportunity with Billing Account
    public static Opportunity createOpportunityWithBillingAcc(Id billingAccId, Boolean b_doInsert){
        List<String> stageValsList = TestingUtility.getPicklistValues('Opportunity','StageName');    
        Map<String,Object> recordValuesMap = new Map<String,Object>();
        recordValuesMap.put('StageName',stageValsList[0]);
        recordValuesMap.put('Name','Test Opportunity');
        recordValuesMap.put('CloseDate',System.today().addDays(30));
        recordValuesMap.put('Billing_Account__c',billingAccId);
        return (Opportunity)createTestRecords(Opportunity.sObjectType, recordValuesMap, b_doInsert);        
    }
     

    public static User getPortalUser(Id portalProfileId, String portalType, User userWithRole, Boolean b_doInsert) {
        Id portalProfId;
        Account accObj;
        Contact conObj;
        //Make sure the running user has a role otherwise an exception will be thrown. 
        if(userWithRole == null) {
            if(UserInfo.getUserRoleId() == null) {
                UserRole userRoleObj = new UserRole(name = 'TEST ROLE');
                Database.insert(userRoleObj);
                Map<String,Object> userRecordMap = new Map<String,Object>();
                userRecordMap.put('UserRoleId',userRoleObj.id);
                userWithRole = TestingUtility.insertUserWithAssert(UserInfo.getProfileId(),userRecordMap);               
            }else {
                userWithRole = new User(Id = UserInfo.getUserId(), UserRoleId = UserInfo.getUserRoleId());
            }
        }        
        System.runAs(userWithRole) {
            accObj = TestingUtility.createAccount('Test Account', true);
            conObj = TestingUtility.createContact(accObj.Id,'Test Contact',true);
        }
        // Get any profile Id for the given type.
        if(portalProfileId != null){
            portalProfId = portalProfileId;
        }else{
            portalProfId = [SELECT Id FROM Profile WHERE Usertype = :portalType LIMIT 1].Id;
        }       
        Map<String,Object> userRecordMap = new Map<String,Object>();
        userRecordMap.put('ContactId',conObj.Id);
        userRecordMap.put('Email','asuniqueasme@sunGard.com');        
        User portalUser = TestingUtility.insertUserWithAssert(portalProfId,userRecordMap,b_doInsert);
        return portalUser;
    }
    
    //Added by    @ Milanjeet Singh 
    //Date        @ 19/June/2017
    //Purpose     @ To rsolve duplicate Community Nickname for User
    //Description @ It returns randon string with current timeStamp as user Community Nickname
    public static string createUserCommunityName(){
        string nickName = (createRandomString()+Datetime.now().getTime()+userInfo.getOrganizationId()) + '' +math.random();
        return nickName.right(30);
    }
    
    Public static Building__c createBuilding(Map<String,Object> recordValuesMap, Boolean doInsert){
        if(String.isBlank((String)recordValuesMap.get('Name'))){
            recordValuesMap.put('Name','Test Building');
        }
        return (Building__c)createTestRecords(Building__c.sObjectType, recordValuesMap, doInsert);
    }
    
    /*This method can be used to create bulk building records*/
    Public static List<Building__c> createBuildings(Map<String,Object> recordValuesMap,Integer count){
        List<Building__c> lstBuilding= new List<Building__c>();
        for(Integer index = 1 ; index <= count ;index ++){
            if(String.isBlank((String)recordValuesMap.get('Name'))){
                recordValuesMap.put('Name','Test Building '+index);
            }
            lstBuilding.add((Building__c)createTestRecords(Building__c.sObjectType, recordValuesMap,false));
        }
        return lstBuilding;
    }
    
    public static Billing_Account__c createBillingAccount(Map<String,Object> recordValuesMap, Boolean doInsert){
        if(recordValuesMap.get('Name') == null){
            recordValuesMap.put('Name', 'Test Bill Account');
        }
        return (Billing_Account__c)createTestRecords(Billing_Account__c.sObjectType, recordValuesMap, doInsert);
    }
    
    public static Reservable__c createReservable(Map<String,Object> recordValuesMap, Boolean doInsert){        
        return (Reservable__c)createTestRecords(Reservable__c.sObjectType, recordValuesMap, doInsert);
    }
    
    public static OpportunityLineItem createOpportunityLineItem(Map<String,Object> recordValuesMap, Boolean doInsert){        
        return (OpportunityLineItem)createTestRecords(OpportunityLineItem.sObjectType, recordValuesMap, doInsert);
    }
    
    public static Product2 createProduct2(Map<String,Object> recordValuesMap, Boolean doInsert){        
        return (Product2)createTestRecords(Product2.sObjectType, recordValuesMap, doInsert);
    }
    
    public static List<Account> getSalesAccountsWithHierarchy(Integer numberOfOrgAccounts,Boolean createHierarchy){
        List<Account> lstAcc = new List<Account>();
        for(integer index = 0; index <= numberOfOrgAccounts; index++){
            lstAcc.add( new Account(Name='test Sales'+index,Nickname__c = 'Sales'+index+TestingUtility.createUserCommunityName()));    
        }
        insert lstAcc;
        if(createHierarchy){
            lstAcc = createHierarchy(numberOfOrgAccounts, lstAcc);
        }
        return lstAcc;
    }
    
    public static Id orgAccountIdOnInsert;
    public static List<Account> createHierarchy(Integer numberOfOrgAccounts, List<Account> lstSalesAccounts){
        for(Integer index = 0; index < lstSalesAccounts.size(); index++){
            if(index != 0){
                lstSalesAccounts[index].parentId = lstSalesAccounts[index-1].Id;
                lstSalesAccounts[index].Account_Type__c = 'Sales'; 
            }else{
                lstSalesAccounts[index].Account_Type__c = 'Org';
                orgAccountIdOnInsert = lstSalesAccounts[0].Id;
            }            
        }       
        update lstSalesAccounts;
        return lstSalesAccounts;
    }
    
    public static set<String> getEditableFields(Set<String> setFields , String sObjectName){
        Set<String> setFieldstoReturn = new Set<String>();
        Schema.DescribeSObjectResult sObjResult = Schema.getGlobalDescribe().get(sObjectName).getDescribe();
        for(String fieldName:sObjResult.fields.getMap().keyset()){
            Schema.DescribeFieldResult fieldResult = sObjResult.fields.getMap().get(fieldName).getDescribe();
            if(fieldResult.isCreateable() && !fieldResult.isAutoNumber() && !fieldResult.isCalculated()){
                if(setFields!= null && setFields.contains(fieldName.toLowerCase())){
                    setFieldstoReturn.add(fieldResult.getName());
                }else if(setFields == null){
                    setFieldstoReturn.add(fieldResult.getName());
                }
            }
        }
        return setFieldstoReturn;
    }
    
    public static Map<String, Object> getUserMapValues(string nameDifferentiator){
        Map<String, Object> mapUserValues = new Map<String, Object>();
        mapUserValues.put('Alias', String.valueOf(createRandomString()).substring(0,5));
        mapUserValues.put('Email', 'testUser_' + nameDifferentiator + '@example.com');
        mapUserValues.put('LastName', 'User' + nameDifferentiator);
        mapUserValues.put('UserName', 'testUser_' + nameDifferentiator + '@example.com');
        mapUserValues.put('CommunityNickName', 'Test'  + nameDifferentiator + system.now());
        return mapUserValues;
    }
    
    public static List<Account> getAccountsByType(Map<String,Object> recordValuesMap, String accountType, Integer count){
        List<Account> lstAccount= new List<Account>();
        if(recordValuesMap !=null && !recordValuesMap.isEmpty()){
            for(Integer index = 1 ; index <= count; index ++){
                if(String.isBlank((String)recordValuesMap.get('Name'))){
                    recordValuesMap.put('Name','Test Account' + index);
                }else{
                    recordValuesMap.put('Name',String.valueOf(recordValuesMap.get('Name')) + index);
                }
                if(String.isBlank((String)recordValuesMap.get('Account_Type__c')) && accountType != null){
                    recordValuesMap.put('Account_Type__c', accountType);
                }
                lstAccount.add((Account)createTestRecords(Account.sObjectType, recordValuesMap, false));
            }
        }
        return lstAccount;
    }
    
    public static set<Id> insertRecordsWithAssert(sObject[] recordsToInsert, Boolean allOrNone){
        set<Id> recordIds = new set<Id>();
        for(Database.SaveResult result : Database.insert( recordsToInsert,allOrNone)){
            if(result.isSuccess()){
                recordIds.add(result.getId());   
            }
        }
        return recordIds;
    }
    
   /************************************************************************************************************************************
        Author              :   Sunil Bhosale
        Description         :   
        Created By          :   19 Oct 2018
    **************************************************************************************************************************************/
    private static List<Account> getAccounts(Integer numberOfAccount){
        List<Account>  lstAccount = new List<Account>();
        for(Integer count=1 ;count <= numberOfAccount ; count++){
            lstAccount.add(new Account(Name = 'john'+count, Unomy_Company_ID__c = 11111+count, Lead_Source__c = 'Wework.com'));    
        }
        insertRecordsWithAssert(lstAccount, false);
        if(lstAccount.size() > 0 && lstAccount[0].Id != null){
            isAccounstInserted = true;
            return  lstAccount;
        }
        return null; 
    }
    
    private static List<Contact> getContacts(Integer numberOfContacts, List<String> lstEmails){
        if(!isAccounstInserted){
            getAccounts(numberOfContacts);
        }        
        List<Contact> lstContacts = new List<Contact>();
        if(lstEmails!= null && lstEmails.size() > 0){
            Integer count = 0;
            for(Account account : [SELECT Id, Name FROM Account LIMIT : numberOfContacts]){
                lstContacts.add(new Contact(FirstName=account.Name,LastName='Smith',Email=lstEmails[count],AccountId=account.Id));
                count++;
            }           
        }else{
            for(Account account : [SELECT Id, Name FROM Account LIMIT : numberOfContacts]){
                lstContacts.add(new Contact(FirstName=account.Name,LastName='Smith',Email=account.Name+'.Contact@example.com',AccountId=account.Id));
            }
        }
        insertRecordsWithAssert(lstContacts, false);
        if(lstContacts.size() > 0 && lstContacts[0].Id != null){
            isContactsInserted = true;
            return lstContacts;
        }else{
            return null;  
        }    
    }
    
    private static List<Opportunity> getOpportunities(Integer numberOfOpportunities){
        Map<String, Id> oppRecordType = TestingUtility.getRecordTypeMapByName(Opportunity.sObjectType);
        List<Opportunity> lstOpportunities = new List<Opportunity>();
        if(!isContactsInserted){
            getContacts(numberOfOpportunities,null);  
        }        
        Integer count = 1;
        for(Contact contact : [SELECT Id, Name, AccountId, Account_Name__c FROM Contact LIMIT : numberOfOpportunities]){
            lstOpportunities.add(new Opportunity(
                Name ='Opp-'+contact.Name+contact.Account_Name__c,
                CloseDate = System.today().addDays(30),
                AccountId =  contact.AccountId,
                Primary_Member__c = contact.Id,   
                contract_UUId__c = 'test121'+count,
                StageName = 'Selling',
                RecordTypeId = oppRecordType.get('Consumer')
            ));   
            count++;
        }
        insertRecordsWithAssert(lstOpportunities, false);
        if(lstOpportunities.size() > 0 && lstOpportunities[0].Id != null){
            isOpportunityInserted = true;
            return lstOpportunities;
        }
        return null;   
    }
    
    private static List<Opportunity> getOpportunities(Map<String, List<Object>> mapFieldValues, Integer numberOfOpportunities, Boolean doInsert){
        Map<String, Id> oppRecordType = TestingUtility.getRecordTypeMapByName(Opportunity.sObjectType);
        List<Opportunity> lstOpportunities = new List<Opportunity>();
        Map<String, Object> mapOpportunityDefaults = new Map<String, Object>{'StageName'=>'Selling', 'CloseDate'=>System.today().addDays(30)};
            if(!isContactsInserted && mapFieldValues != null){
                getContacts(numberOfOpportunities,null); 
            }
        Map<String,Schema.DescribeFieldResult> requiredFieldsMap = getNullabelRequiredFields(Opportunity.sObjectType);
        if(mapFieldValues != null && mapFieldValues.Size() > 0){
            lstOpportunities.addAll((List<Opportunity>)createRecordsWithFields(Opportunity.sObjectType, mapFieldValues, mapOpportunityDefaults, numberOfOpportunities, null)); 
        }else{
            for(Contact contact : [SELECT Id, Name, AccountId, Account_Name__c FROM Contact LIMIT : numberOfOpportunities]){
                Opportunity objOpp = new Opportunity();
                for(String fieldApiName : mapOpportunityDefaults.keyset()){
                    objOpp.put(fieldApiName, mapOpportunityDefaults.get(fieldApiName));
                }
                objOpp.Name = 'Opp-'+contact.Name+contact.Account_Name__c;
                objOpp.AccountId =  contact.AccountId;
                objOpp.Primary_Member__c = contact.Id;
            } 
        }
        if(doInsert){
            insertRecordsWithAssert(lstOpportunities, false);
            isOpportunityInserted = true;
        }
        return lstOpportunities;
    }
    
    public static List<Billing_Account__c> getBillingAccount(Map<String, List<Object>> mapFieldValues, Integer numberOfBillingAccounts, Boolean doInsert, Map<String, Object> mapData){
        List<Billing_Account__c> lstBillingAccount = new List<Billing_Account__c>();
        if(mapData != null && mapData.get('method') != null){
            if(!isAccounstInserted)
                getAccounts(numberOfBillingAccounts);
            List<Account> lstAccounts = [SELECT Id FROM Account LIMIT : numberOfBillingAccounts];
            for(Integer count = 0 ;count < numberOfBillingAccounts ; count++){
                lstBillingAccount.add(new Billing_Account__c(Name = 'TestBillAcc'+count, UUID__c = 'billUUID'+count, Parent_Account__c = lstAccounts[count].Id));
            }
            if(doInsert){
                insertRecordsWithAssert(lstBillingAccount, false);
            }
            if(lstBillingAccount.size() > 0 && lstBillingAccount[0].Id != null){
                isBillingAccountInserted = true;
                Debug.log('lstBillingAccount:'+lstBillingAccount);
                return lstBillingAccount;
            }else
                return null;  
        }else{
            Map<String,Schema.DescribeFieldResult> requiredFieldsMap = getNullabelRequiredFields(Billing_Account__c.sObjectType);
            if(mapFieldValues != null && mapFieldValues.Size() > 0){
                lstBillingAccount.addAll((List<Billing_Account__c>)createRecordsWithFields(Billing_Account__c.sObjectType, mapFieldValues, null, numberOfBillingAccounts, null)); 
            }
            if(doInsert){
                insertRecordsWithAssert(lstBillingAccount, false);
            }   
            Debug.log('lstBillingAccount:'+lstBillingAccount);
            return lstBillingAccount;
        }
        
    }
    
    public static List<sObject> createRecordsWithFields(Schema.sObjectType sObjectTypeRequested, Map<String, List<Object>> mapFieldValues, Map<String, Object> mapDefaults, Integer totalRecords, List<Map<String, Object>> lstCustomMap){
        Map<String,Schema.DescribeFieldResult> requiredFieldsMap;
        if(sObjectTypeRequested != null){
            requiredFieldsMap = getNullabelRequiredFields(sObjectTypeRequested);
        }
        Boolean createMap = (mapDefaults != null && mapDefaults.get('createMap') != null) ? Boolean.valueOf(mapDefaults.get('createMap')) : false;
        List<sObject> lstRecords = new List<sObject>();
        sObject obj;
        Map<String, Object> mapCustomFieldAndValues;
        if(mapFieldValues != null && mapFieldValues.Size() > 0){
            for(Integer index = 0; index < totalRecords; index++){
                if(createMap){
                    mapCustomFieldAndValues = new Map<String, Object>();  
                }else{
                    obj =  getDefultValuesInSobject(sObjectTypeRequested, requiredFieldsMap, mapDefaults); 
                }
                for(String fieldApiName : mapFieldValues.Keyset()){
                    if(mapCustomFieldAndValues != null){
                        mapCustomFieldAndValues.put(fieldApiName, mapFieldValues.get(fieldApiName)[index]);                  
                    }else if(obj != null ){
                        obj.put(fieldApiName, mapFieldValues.get(fieldApiName)[index]); 
                    }
                }
                if(lstCustomMap != null){
                    lstCustomMap.add(mapCustomFieldAndValues);
                }
                lstRecords.add(obj);
            }
        }
        return lstRecords;
    }
    
    private static sObject getDefultValuesInSobject(Schema.sObjectType sObjectTypeRequested, Map<String,Schema.DescribeFieldResult> requiredFieldsMap, Map<String, Object> defaults){
        debug.log('defaults: '+defaults);
        sObject record = sObjectTypeRequested.newSobject();
        if(defaults != null){
            for(String strField : requiredFieldsMap.keySet()){
                if( !defaults.KeySet().contains(strField)){
                    record.put(strField,getTestValue(requiredFieldsMap.get(strField)));
                }
            } 
            for(String fieldApiName : defaults.keySet()){
                record.put(fieldApiName,defaults.get(fieldApiName));
            }
        }
        return record;
    }
    
    private static List<Tour_Outcome__c> getTours(Integer numberOfTours){
        List<Tour_Outcome__c> lstTours = new List<Tour_Outcome__c>();
        Integer Count = 0;
        if(!isOpportunityInserted){
            getOpportunities(numberOfTours); 
        }
        if(!isJourneyInserted){
            getJourneys(numberOfTours); 
        }
        if(!isBuildingInserted){
           getBuildings(numberOfTours); 
        }
        List<Journey__c> lstJourney= [select id from Journey__c LIMIT : numberOfTours];       
        List<Building__C> lstBuilding = [select id from Building__C where Name LIKE 'testBuilding%'];
        for(Opportunity opportunity : [SELECT Id, Name, RecordTypeId, Primary_Member__c, Journey__c, AccountId FROM Opportunity]){
            lstTours.add(new Tour_Outcome__c(
                Scheduled_By__c = opportunity.Primary_Member__c,
                booked_by_contact_id__c = opportunity.Primary_Member__c, 
                Opportunity__c = opportunity.Id,
                Status__c = 'Scheduled',
                Location__c = lstBuilding[0].Id,
                Primary_Member__c =  opportunity.Primary_Member__c,   
                Start_Time__c = '8:00pm',
                End_Time__c = '8:30pm',
                Tour_Confirmation_Email_Sent__c = true,
                Tour_Date__c = system.today().addDays(3), 
                Journey__c = lstJourney[Count].Id
            ));            
            Count++;
        }
        insertRecordsWithAssert(lstTours, false);
        if(lstTours.size() > 0 && lstTours[0].Id != null){
            return lstTours; 
        }else{
            return null;
        }
    }
    
    private static List<Task> getTasks(Integer  numberOfTask){
        List<Task> lstTask = new List<Task>();
        if(!isContactsInserted)
            getContacts(numberOfTask,null);
        for(Contact contact : [SELECT Id, Name, AccountId, Account_Name__c FROM Contact LIMIT : numberOfTask]){
            lstTask.add(new Task(
                WhoId = contact.Id,
                Subject = 'Follow up',
                Status = 'In Progress'
            )); 
        }
        insertRecordsWithAssert(lstTask, false);
        if(lstTask.size() > 0 && lstTask[0].Id != null){
            return lstTask; 
        }
        return null;        
    }
    
    private static List<Journey__c> getJourneys(Integer  numberOfJourneys){
        List<Journey__c> lstJourney= new List<Journey__c>();
        if(!isContactsInserted){
            getContacts(numberOfJourneys, null); 
        }        
        for(Contact contact : [SELECT Id, Name FROM Contact LIMIT : numberOfJourneys]){
            lstJourney.add(new Journey__c(
                Name = 'testJourney'+contact.Name,
                Primary_Contact__c = contact.Id,
                NMD_Next_Contact_Date__c = System.today()
            )); 
        }
        insertRecordsWithAssert(lstJourney, false);
        if(lstJourney.size() > 0 && lstJourney[0].Id != null){          
            return lstJourney; 
        }else{
            return null; 
        }
    }
    
    private static List<Market__c> getMarkets(Integer numberOfMarkets){
        List<Market__c>  lstMarkets = new List<Market__c>();
        for(Integer count=1; count <= numberOfMarkets; count++){
            lstMarkets.add(new Market__c(Name = 'testMarket'+count, CurrencyIsoCode = 'USD', UUID__c = 'MarketUUID'+count));    
        }
        insertRecordsWithAssert(lstMarkets, false);
        if(lstMarkets.size() > 0 && lstMarkets[0].Id != null){
            isMarketInserted= true;
            return lstMarkets;
        }else{
            return null; 
        }
    }
    
    private static List<Building__c> getBuildings(Integer numberOfBuildings){
        List<Building__c>  lstBuildings = new List<Building__c>();
        List<Market__c>  lstMarkets;
        if(!isMarketInserted){
            lstMarkets = getMarkets(numberOfBuildings);  
        }
        for(Integer count=1; count <= numberOfBuildings; count++){
            lstBuildings.add(new Building__c(Name = 'testBuilding'+count, Market__c = lstMarkets[count-1].Id, CurrencyIsoCode = 'USD', UUID__c = 'buildingUUID'+count, City__c = 'test'));    
        }
        insertRecordsWithAssert(lstBuildings, false);
        if(lstBuildings.size() >0 && lstBuildings[0].Id != null){
            isBuildingInserted= true;
            return  lstBuildings;
        }else{
            return null; 
        }
    }
    
    private static List<Reservable__c> getReservables(Integer numberOfReservables){
        List<Building__c> lstBuildings;
        if(!isBuildingInserted){
            lstBuildings = getBuildings(numberOfReservables);  
        }        
        List<Reservable__c> lstReservables = new List<Reservable__c>();
        for(Building__c building : lstBuildings){
            lstReservables.add(new Reservable__c(Name = 'testReservableof'+building.Name, Building__c = building.Id, CurrencyIsoCode = 'USD', UUID__c = 'ReservableUUIDOf'+building.UUID__c));
        }
        insertRecordsWithAssert(lstReservables, false);
        return lstReservables;
    }
    
    private static List<Referral__c> getReferrals(Integer numberOfReferrals){
        List<Referral__c> lstReferrals = new List<Referral__c>();
        if(!isContactsInserted){
            getContacts(numberOfReferrals,null);
        }        
        List <String> lstEmails = new List<String>();
        for(Integer index = 1 ;index <= numberOfReferrals; index++ ){
            lstEmails.add('zilla@comcast.net'+index);
        }        
        List<Contact> lstReferrer = getContacts(numberOfReferrals, lstEmails);
        Integer count = 0;
        for(Contact contact : [SELECT Id, Name, Email FROM Contact LIMIT : numberOfReferrals]){
            lstReferrals.add(new Referral__c(
                Name = 'testReferralOf'+contact.Name, 
                IsActive__c = true,
                Referral_Email__c = contact.Email, 
                Referrer__c = lstReferrer[count].Id
            )); 
            count++;
        }
        insertRecordsWithAssert(lstReferrals, false);        
        if(lstReferrals.size() > 0 && lstReferrals[0].Id != null){
            return lstReferrals; 
        }
        return null;        
    }
    
    public static List<Product2> createAllWeWorkProducts(Boolean doInsert){
        String JSONForAllWeWorkProducts = '{"Name":["Dedicated Desk","Deal","Dedicated Desk","Enterprise Solutions Desk","Hot Desk","WeMembership","Shared Office Desk","Global Access Membership","Desk","Not Considered"],"ProductCode":["PRDE-000200","PRDL-000001","PRES-000300","PRHD-000400","PRWM-000500","PRSO-000700","PRGA-000800","PROF-000900","Not Considered"],"Default_Product_Category__c":["Standard Office","Standard Office","Custom Office","Hot Desk","WeMembership","Standard Office","Global Access","Standard Office","Standard Office"],"Family":["WeWork","WeWork","Enterprise Solutions","WeWork","WeWork","WeWork","Global Access","WeWork","WeWork"]}';
        Map<String, List<String>> mapFieldValues = (Map<String, List<String>>) JSON.deserialize(JSONForAllWeWorkProducts, Map<String, List<String>>.class); 
        List<Product2> lstProductItems = createProducts(mapFieldValues, doInsert);
        if(doInsert){
            List<Product2> lstProducts = new List<Product2>();
            for(Product2 objProduct: lstProductItems){                
                objProduct.IsActive = true;
                lstProducts.add(objProduct);
            } 
            if(lstProducts.size() > 0){
                update lstProducts;
            }
        }
        return lstProductItems;
    }
    
    private static List<Product2> createProducts(Map<String, List<Object>> mapFieldValues, Boolean doInsert){
        List<Product2> lstProduct2 = (List<Product2>)createRecordsWithFields(Product2.sobjectType, mapFieldValues, null, 9, null);
        if(doInsert){
            insertListWithAssert(lstProduct2);
            createPriceBookEntriesForProduct(lstProduct2);
        }
        return lstProduct2;
    }
    
    private static void createPriceBookEntriesForProduct(List<Product2> lstProduct2){
        Id pricebookId = Test.getStandardPricebookId();
        List<PricebookEntry> lstPricebookEntry = new List<PricebookEntry>();
        for(CurrencyType objCurrencyType : [SELECT ISOCode, ConversionRate FROM CurrencyType WHERE IsActive = TRUE]){            
            for(Product2 objProduct2 : lstProduct2){
                PricebookEntry priceBook = new PricebookEntry();
                priceBook.Pricebook2Id = pricebookId;
                priceBook.Product2Id  = objProduct2.Id;
                priceBook.CurrencyIsoCode = objCurrencyType.ISOCode;
                priceBook.UnitPrice = 9999;
                priceBook.IsActive = true;
                lstPricebookEntry.add(priceBook);
            }
        }
        insertListWithAssert(lstPricebookEntry);
    }
    
    public static List<OpportunityLineItem> getOpportunityLineItem(Map<String, Map<String, List<Object>>> mapFieldValuesForOppId, Map<String, Integer> mapNumberOfLineItemsWithOppId, Set<String> setProductCode, Boolean doInsert){
        Map<String, Opportunity> mapOpportunityWithId = new Map<String, Opportunity>([SELECT Id, CurrencyISOCode FROM Opportunity WHERE Id In: mapFieldValuesForOppId.keyset()]);
        Map<String, PricebookEntry> mapPBEWithProductCodeAndCurrencyIso = new Map<String, PricebookEntry>();
        Set<String> setOppCurrencies = new Set<String>();
        List<sobject> lstLineItems = new List<sobject>();
        for(opportunity opp : mapOpportunityWithId.values()){
            setOppCurrencies.add(opp.CurrencyISOCode);
        }       
        for(PricebookEntry objPBE : [Select Id, ProductCode, CurrencyIsoCode From PricebookEntry Where ProductCode IN: setProductCode AND CurrencyIsoCode In: setOppCurrencies]){
            mapPBEWithProductCodeAndCurrencyIso.put(objPBE.CurrencyIsoCode.toLowerCase() + ';' + objPBE.ProductCode.toLowerCase(), objPBE);
        }       
        Map<String, List<Object>> mapFieldOfLineItems;
        String oppCurrency;
        for(String opportunityId : mapFieldValuesForOppId.keyset()){
            mapFieldOfLineItems = mapFieldValuesForOppId.get(opportunityId);
            oppCurrency = mapOpportunityWithId.get(opportunityId).CurrencyISOCode.toLowerCase();
            List<Object> lstPriceBookEntries = new List<Object>();
            List<Object> lstOpportunityId = new List<Object>();
            for(String productCode :  setProductCode){
                if(mapPBEWithProductCodeAndCurrencyIso.get(oppCurrency + ';' + productCode.toLowercase()) != null){
                    lstPriceBookEntries.add(mapPBEWithProductCodeAndCurrencyIso.get(oppCurrency + ';' + productCode.toLowercase()).Id);
                    lstOpportunityId.add(opportunityId); 
                }
            }
            mapFieldOfLineItems.put('OpportunityId',lstOpportunityId);
            mapFieldOfLineItems.put('PricebookEntryId',lstPriceBookEntries);           
            lstLineItems.addall(createRecordsWithFields(OpportunityLineItem.sObjectType, mapFieldValuesForOppId.get(opportunityId), null, mapNumberOfLineItemsWithOppId.get(opportunityId), null));
        }
        if(doInsert){
            insertListWithAssert(lstLineItems);
        }
        return lstLineItems;
    }
    
    private static List<Lead> getLeads(Integer numberOfLead, Map<String, Object> mapData){
        List<Lead>  lstLead = new List<Lead>();
        for(Integer count=1; count <= numberOfLead; count++){
            Lead objLead = new Lead(FirstName = 'FirstName' + count, LastName = 'LastName' + count, Company = 'Company');
            objLead.Email = mapData.containsKey('Email') ? String.valueOf(mapData.get('Email')) : 'john.smith' + count + '@example.com';
            objLead.LeadSource = mapData.containsKey('LeadSource') ? String.valueOf(mapData.get('LeadSource')) : 'WeWork.com';
            objLead.Lead_Source_Detail__c = mapData.containsKey('Lead_Source_Detail__c') ? String.valueOf(mapData.get('Lead_Source_Detail__c')) : 'Book a Tour Form';
            objLead.Generate_Journey__c = mapData.containsKey('Generate_Journey__c') ? Boolean.valueOf(mapData.get('Generate_Journey__c')) : true;
            lstLead.add(objLead);    
        }
        insertRecordsWithAssert(lstLead, false);
        Debug.log('lstLead in getLeads:'+lstLead);
        if(lstLead.size() > 0 && lstLead[0].Id != null){
            isLeadInserted = true; 
            return  lstLead;
        }else
            return null; 
    }
    //User insertion
    private static List<User> getUsers(Integer numberOfUsers,Map<String,Object> mapData){        
        List<User> lstUsers = new List<User>();
        Map<string , Object> mapofUsers = new Map <String, object>();
        List<Profile> lstProfiles = new List<Profile>();
        Profile objProfile;
        if(mapData.containsKey('userProfiles') && mapData.get('userProfiles') != null){
            List<String> lstProfileNames = (List<String>)mapData.get('userProfiles');
            lstProfiles = [SELECT Id FROM Profile WHERE Name IN: lstProfileNames];
        }   
        else{
            objProfile = [SELECT Id FROM Profile WHERE Name = 'Wework System Administrator'];
        }
        String emailDomain = mapData.containsKey('emailDomain') ? String.valueOf(mapData.get('emailDomain')) : 'test.com';
        for(Integer count = 1; count <= numberOfUsers; count++){
            mapofUsers.put('LastName', 'testUser ' + count + '@' + emailDomain);
            mapofUsers.put('Email', 'testUserEmail' + count + '@' + emailDomain);
            User objUser;
            if(mapData.containsKey('userProfiles') && mapData.get('userProfiles') != null && lstProfiles.size() > 0){
                for(Integer index = 0; index < lstProfiles.size();index++){
                    objUser = insertUserWithAssert(lstProfiles[index].Id,mapofUsers,true);
                }
            }else{
                objuser = insertUserWithAssert(objProfile.Id,mapofUsers,true);
            }
            
            lstUsers.add(objuser);
        }
        return lstUsers;
    }
    //This method will insert number Of Campaigns provided as a parameter "numberOfCampaign" and first of them is Parent Campaign 
    private static List<Campaign> getCampaigns(Integer numberOfCampaign){
        List<Campaign> lstCampaigns = new List<Campaign>();
        Campaign objCampaign = new Campaign(Name = 'Parent Campaign', Region__c = 'India;Mumbai', Program__c = 'Test Program');
        insertWithAssert(objCampaign);        
        for(Integer count = 1; count < numberOfCampaign; count++){
            lstCampaigns.add(new Campaign(Name = 'Test Campaign '+count, Program__c = 'Test Campaign'+count, Region__c = 'Maharashtra', Type = 'Telemarketing', ParentId = objCampaign.Id, Name__c = 'Test Campaign Name '+count));  
        }
        insertRecordsWithAssert(lstCampaigns, false);
        if(lstCampaigns.size() > 0 && lstCampaigns[0].Id != null){
            isCampaignInserted = true;
            return lstCampaigns;
        }else
            return null;
    }
    
    private static List<CampaignMember> getCampaignMembers(Integer numberOfCampaignMember){
        Integer count = 0;
        List<CampaignMember> lstCampaignMember = new List<CampaignMember>();
        if(!isContactsInserted)
            getContacts(numberOfCampaignMember, null);
        if(!isCampaignInserted)
            getCampaigns(numberOfCampaignMember);
        List<Campaign> lstCamapaign = [SELECT Id FROM Campaign];
        for(Contact objContact : [SELECT Id, Name FROM Contact LIMIT : numberOfCampaignMember]){
            lstCampaignMember.add(new CampaignMember(
                CampaignId = lstCamapaign[count].Id,
                ContactId = objContact.Id
            ));
            count++;
        }
        insertRecordsWithAssert(lstCampaignMember, false);
        if(lstCampaignMember.size() > 0 && lstCampaignMember[0].Id != null){
           return lstCampaignMember; 
        }else{
            return null;
        }
    }
    
    private static List<Tour_Schedule__c> getTourSchedule(Integer numberTourSchedule){
        List<Tour_Schedule__c> lstTourSchedule = new List<Tour_Schedule__c>();
        if(!isBuildingInserted){
            getBuildings(numberTourSchedule);  
        }
        for(Building__c objBuilding : [SELECT Id FROM Building__c LIMIT : numberTourSchedule]){
            lstTourSchedule.add(new Tour_Schedule__c(Building__c = objBuilding.Id, Simultaneous_Tours__c = '2', Tour_Spacing__c = 'Hour', Maximum_Tour_Days__c = 1));   
        }
        insertRecordsWithAssert(lstTourSchedule, false);
        if(lstTourSchedule.size() > 0 && lstTourSchedule[0].Id != null){
            isTourScheduleInserted = true;
            return lstTourSchedule;
        }else
            return null;
    }
    
    /************************************************************************************************************************************
    Author 				: Rupesh Patil
    Description 		: This method is used to get Case records.
    Created Date		: 28 Nov 2018 
   **************************************************************************************************************************************/ 
    private static List<Case> getCases(Integer numberOfCases){
        List<Case> lstCases = new List<Case>();
        if(!isOpportunityInserted)
            getOpportunities(numberOfCases);
        for(Opportunity objOpp : [SELECT Id, Name, Primary_Member__c, AccountId FROM Opportunity LIMIT : numberOfCases]){
            lstCases.add(new Case(AccountId = objOpp.AccountId, Opportunity__c = objOpp.Id, Status = 'New', Requested_Type__c = 'Proposal'));
        }
        insertRecordsWithAssert(lstCases, false);
        Debug.log('lstCases:'+ lstCases);
        if(lstCases.size() > 0 && lstCases[0].Id != null){
            isCasesInserted = true;
            return  lstCases;
        }else
            return null;   
    }
    
    private static List<Tour_Open_Hour__c> getTourOpenHours(Integer numberTourOpenHours){
        List<Tour_Open_Hour__c> lstTourOpenHour = new List<Tour_Open_Hour__c>();
        Integer countRecords = 0;
        if(!isBuildingInserted){
            getBuildings(numberTourOpenHours);
        }
        if(!isTourScheduleInserted){
            getTourSchedule(numberTourOpenHours);
        }
        List<Building__c> lstBuilding = [SELECT Id FROM Building__c WHERE Name LIKE 'testBuilding%'];
        List<Tour_Schedule__c> lstSchedule = [SELECT Id FROM Tour_Schedule__c LIMIT : numberTourOpenHours];       
        for(Integer count = 1; count <= numberTourOpenHours; count++){
            lstTourOpenHour.add(new Tour_Open_Hour__c(weekday__c = 'Monday', start_time__c = '8:00AM', end_time__c = '8:30PM', Tour_Schedule__c = lstSchedule[countRecords].Id,Building__c = lstBuilding[countRecords].Id, CurrencyIsoCode = 'USD'));
        }
        insertRecordsWithAssert(lstTourOpenHour, false);
        if(lstTourOpenHour.size() > 0 && lstTourOpenHour[0].Id != null){
            isTourOpenHours = true;
            return lstTourOpenHour;
        }else{
            return null;   
        }
    }
    
    /************************************************************************************************************************************
    Author 				: Rupesh Patil
    Description 		: This method is used to get  records.
    Created Date		: 28 Nov 2018 
   **************************************************************************************************************************************/ 
    private static List<OpportunityTeamMember> getOpportunityTeamMembers(Integer numberOfTeamMembers){
        List<OpportunityTeamMember> lstOppTeamMems = new List<OpportunityTeamMember>();
        List<User> lstUsers = [SELECT Id FROM User LIMIT : numberOfTeamMembers];
        if(!isOpportunityInserted){
            getOpportunities(numberOfTeamMembers);
        }
        for(Opportunity objOpp : [SELECT Id FROM Opportunity LIMIT : numberOfTeamMembers]){
            for(Integer count=0 ;count < numberOfTeamMembers; count++){
                lstOppTeamMems.add(new OpportunityTeamMember(OpportunityId = objOpp.Id, UserId = lstUsers[count].Id));
            }
        }
        insertRecordsWithAssert(lstOppTeamMems, false);
        Debug.log('lstOppTeamMems:'+lstOppTeamMems);
        if(lstOppTeamMems.size() > 0 && lstOppTeamMems[0].Id != null){
            return lstOppTeamMems;
        }else
            return null;
    }
    
    public static List<sObject> getRecords(Map<String,Object> mapData){
        String objName = String.valueOf(mapData.get('objName')).toLowerCase();
        Integer numberOfRecords = Integer.valueOf(mapData.get('numberOfRecords'));
        List<String> lstEmails = (List<String>)(mapData.get('lstEmails'));
        Boolean doInsert;
        if(mapData.get('doInsert') != null){
            doInsert = Boolean.valueOf(mapData.get('doInsert'));
        }        
        Map<String,  List<Object>> mapFieldValues;
        if(mapData.get('mapFieldValues') != null){
            mapFieldValues = (Map<String,  List<Object>>) mapData.get('mapFieldValues'); 
        }       
        switch on objName { 
            when 'lead' {
                return getLeads(numberOfRecords, mapData);
            }
            when 'user'  {
                return getUsers(numberOfRecords, mapData);
            }
            when 'account' {    
                return getAccounts(numberOfRecords);
            }   
            when 'contact' {
                return getContacts(numberOfRecords,lstEmails);
            }
            when 'opportunity' {    
                return getOpportunities(mapFieldValues, numberOfRecords, doInsert);  
            }
            when 'tour' {   
                return  getTours(numberOfRecords);  
            }
            when 'task' {
                return  getTasks(numberOfRecords);
            }
            when 'reservable'{
                return getReservables(numberOfRecords);
            }
            when 'referral'{
                return getReferrals(numberOfRecords);
            }
            when 'billing_account__c'{
                return getBillingAccount(mapFieldValues, numberOfRecords, doInsert, mapData);
            }
            when 'product2'{
                return createAllWeWorkProducts(doInsert);
            }
            when 'journey'{
                return getJourneys(numberOfRecords);
            }
            when 'campaignmember'{
                return getCampaignMembers(numberOfRecords);
            }
            when 'campaign'{
                return getCampaigns(numberOfRecords);
            }
            when 'touropenhour'{
                return getTourOpenHours(numberOfRecords);
            }
            when 'building__c' {	
                return getBuildings(numberOfRecords);
            }
            when 'case' {
                return getCases(numberOfRecords);
            }
            when 'oppoteam' {
                return getOpportunityTeamMembers(numberOfRecords);
            }
        }
        return null;  
    }    
}