/************************************************************************************************************************************
   	Author 		: Ajaysinh Chauhan
   	Description : This class Contains Unit Tests methods of LightningComponentController
   	History		:
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE				AUTHOR				DETAIL
	1			-            		Ajaysinh Chauhan    Initial Developement
	2           28 November 2018    Rupesh Patil        Optimized and Changed to increase code coverage
**************************************************************************************************************************************/
@isTest
public class LightningComponentControllerTests {
    /************************************************************************************************************************************
        Author 			: Rupesh Patil
        Description 	: This method has setup data for all test methods 
        Created Date	: 28 Nov 2018 
    **************************************************************************************************************************************/
    @TestSetup
    static void initData(){
        SalesConsoleSettings.createSettings();
        Test.startTest();
        List<User> lstUsers = (List<User>)TestingUtility.getRecords(new Map<String, Object>{'objName' => 'User', 'numberOfRecords' => 2});
       	List<Lead> lstLeads = (List<Lead>)TestingUtility.getRecords(new Map<String, Object>{'objName' => 'Lead', 'numberOfRecords' => 2});
        List<Contact> lstContacts = (List<Contact>)TestingUtility.getRecords(new Map<String, Object>{'objName' => 'Contact', 'numberOfRecords' => 4});
        List<Account> lstAccounts = (List<Account>)TestingUtility.getRecords(new Map<String, Object>{'objName' => 'Account', 'numberOfRecords' => 6});
        List<Building__c> lstBuildings = (List<Building__c>)TestingUtility.getRecords(new Map<String, Object>{'objName' => 'Building__c', 'numberOfRecords' => 1});
        List<Tour_Outcome__c> lstTours = (List<Tour_Outcome__c>)TestingUtility.getRecords(new Map<String, Object>{'objName' => 'Tour', 'numberOfRecords' => 4});
       	List<Geography__c> lstGeographies = (List<Geography__c>)TestingUtility.getRecords(new Map<String, Object>{'objName' => 'Geography__c', 'numberOfRecords' => 2});
        List<Billing_Account__c> lstBillingAccounts = (List<Billing_Account__c>)TestingUtility.getRecords(new Map<String, Object>{'objName' => 'Billing_Account__c', 'numberOfRecords' => 1, 'doInsert' => true, 'method' => 'simpleBillingAccount'});        
        List<Opportunity> lstOpportunities = (List<Opportunity>)TestingUtility.getRecords(new Map<String, Object>{'objName' => 'Opportunity', 'numberOfRecords' => 1, 'doInsert' => true, 'mapFieldValues' => new Map<String, List<Object>>{'Contract_Stage__c' => new List<Object>{'Contract Sent'}, 'Billing_Account__c' => new List<Object>{lstBillingAccounts[0].Id}}});
        List<Campaign> lstCampaigns = (List<Campaign>)TestingUtility.getRecords(new Map<String, Object>{'objName' => 'Campaign', 'numberOfRecords' => 1});       
        Test.stopTest();
    }    
    
	 /************************************************************************************************************************************
        Modified By		: Rupesh Patil
        Modified Date	: 28 Nov 2018 
		Description     : This method verifies getQueryData()
    **************************************************************************************************************************************/    
    public static testMethod void verifyGetQueryData() {
        List<Contact> lstContacts = (List<Contact>)LightningComponentController.getQueryData('Select Id from Contact').data;
        System.assert(lstContacts.size() != 0);
        lstContacts = (List<Contact>)LightningComponentController.getQueryData('SELECT').data;//To verify whether the unexpected token exception caught by the method or not if incomplete or wrong query is passed   
        System.assert(lstContacts == null);
        lstContacts = (List<Contact>)LightningComponentController.getQueryData(null).data;//To verify whether the null pointer exception caught by the method or not if null is passed   
        System.assert(lstContacts == null);
    }
    
     /************************************************************************************************************************************
        Modified By		: Rupesh Patil
        Modified Date	: 28 Nov 2018 
		Description     : This method verifies getListQueryData()
    **************************************************************************************************************************************/    
    public static testMethod void verifyGetListQueryData() {
        List<String> lstQueries = new List<String>{'Select Id from Contact', 'Select Id from Account'};
        List<List<sObject>> lstContacts = (List<List<sObject>>)LightningComponentController.getListQueryData(lstQueries).data;
        System.assert(lstContacts[0].size() != 0 && lstContacts[1].size() != 0);
        DatabaseResult result = LightningComponentController.getListQueryData(new List<String>{' '});//To verify whether the null pointer exception caught by the method or not if null is passed  
        System.assertEquals(false, result.success);
        System.assertNotEquals(result.message, null);
    }
    
     /************************************************************************************************************************************
        Modified By		: Rupesh Patil
        Modified Date	: 28 Nov 2018 
		Description     : This method verifies saveRecord()
    **************************************************************************************************************************************/    
    public static testMethod void verifySaveRecord() {
        Contact objContact = new Contact( firstname = 'John',  lastname = 'Rambo', email = 'john@example.com'); 
        List<Contact> lstContacts = [SELECT Id, Name, Email FROM Contact];       
        Database.SaveResult response = (Database.SaveResult)JSON.deserializeStrict((String)LightningComponentController.saveRecord(objContact).data,Database.SaveResult.class);
        System.assert(response.success);
        DatabaseResult result = LightningComponentController.saveRecord(null);//To verify whether the null pointer exception caught by the method or not if null is passed  
        System.assertEquals(false, result.success);
        System.assertNotEquals(result.message, null);
        Database.SaveResult responseOfSavedContact = (Database.SaveResult)JSON.deserializeStrict((String)LightningComponentController.saveRecord(lstContacts[0]).data,Database.SaveResult.class);
        System.assert(responseOfSavedContact.success);
    }
    
     /************************************************************************************************************************************
        Modified By		: Rupesh Patil
        Modified Date	: 28 Nov 2018 
		Description     : This method verifies saveRecords()
    **************************************************************************************************************************************/    
    public static testMethod void verifySaveRecords() {
        Contact objContact = new Contact( firstname = 'John',lastname = 'Rambo',email = 'john@example.com' );
        List<Account> lstAccounts = [SELECT Id, Name FROM Account LIMIT 1];
        lstAccounts[0].Name = 'UpdatedAcccount';
        List<sObject> lstRecords = new List<sObject>();
        Map<String,List<Database.SaveResult>> response = (Map<String, List<Database.SaveResult>>)JSON.deserializeStrict((String)LightningComponentController.saveRecords(new List<sObject>{objContact, lstAccounts[0]}).data,Map<String, List<Database.SaveResult>>.class);
        for(Database.SaveResult sr:response.get('insertedRecords')){
            System.assert(sr.success);
        }
        for(Database.SaveResult sr:response.get('updatedRecords')){
            System.assert(sr.success);
        }
        DatabaseResult result = LightningComponentController.saveRecords(null);//To verify whether the null pointer exception caught by the method or not if wrong data is passed   
        System.assertEquals(false, result.success);
        System.assertNotEquals(result.message, null);
    }
    
    /************************************************************************************************************************************
        Modified By		: Rupesh Patil
        Modified Date	: 28 Nov 2018 
		Description     : This method verifies deleteRecord()
    **************************************************************************************************************************************/    
    public static testMethod void verifyDeleteRecord() {
        List<Contact> lstContacts = [SELECT Id, Name, Email FROM Contact WHERE Email = 'john1.Contact@example.com']; 
        List<Journey__c> lstJourneys = [SELECT Id FROM Journey__c WHERE Primary_Contact__r.Email = 'john1.Contact@example.com'];
        List<Opportunity> lstOpportunities = [SELECT Id FROM Opportunity WHERE Primary_Member__r.Email = 'john1.Contact@example.com'];
        DatabaseResult resOppo = LightningComponentController.deleteRecord(lstOpportunities[0].Id);
        System.assert(resOppo.success);
        DatabaseResult resJourney = LightningComponentController.deleteRecord(lstJourneys[0].Id);
        System.assert(resJourney.success);
        DatabaseResult resContact = LightningComponentController.deleteRecord(lstContacts[0].Id);       
        System.assert(resContact.success);
        DatabaseResult result = LightningComponentController.deleteRecord('Exception'); //To verify whether the invalid Id exception caught by the method or not if wrong data is passed  
        System.assertEquals(false, result.success);
        System.assertNotEquals(null,result.message);
    }
    
     /************************************************************************************************************************************
        Modified By		: Rupesh Patil
        Modified Date	: 28 Nov 2018 
		Description     : This method verifies deleteRecords()
    **************************************************************************************************************************************/    
    public static testMethod void verifyDeleteRecords() {
        List<Contact> lstContacts = [SELECT Id, Name, Email, AccountId FROM Contact WHERE Email = 'john1.Contact@example.com'];        
        List<Journey__c> lstJourneys = [SELECT Id FROM Journey__c WHERE Primary_Contact__r.Email = 'john1.Contact@example.com'];
        List<Opportunity> lstOpportunities = [SELECT Id FROM Opportunity WHERE Primary_Member__r.Email = 'john1.Contact@example.com'];
        List<String> recordsToDelete = new List<String>{lstJourneys[0].Id, lstOpportunities[0].Id, lstContacts[0].AccountId, lstContacts[0].Id};      
        DatabaseResult response = LightningComponentController.deleteRecords(recordsToDelete);
        String validationMessage='You can not delete Accounts having child Accounts, Contacts or Opportunities except while merging.';
        System.assertEquals(validationMessage.toLowerCase(), response.message.split('FIELD_CUSTOM_VALIDATION_EXCEPTION,')[1].split(':')[0].trim().toLowerCase(), 'Account is deleted having related contacts ');
        DatabaseResult result = LightningComponentController.deleteRecords(null);//To verify whether the null pointer exception caught by the method or not if wrong data is passed
        System.assertEquals(false, result.success);
    }
    
     /************************************************************************************************************************************
        Modified By		: Rupesh Patil
        Modified Date	: 28 Nov 2018 
		Description     : This method verifies getFieldsMetadata()
    **************************************************************************************************************************************/    
    public static testMethod void verifyGetFieldsMetadata() {
        List<String> lstFields = new List<String>{'Name', 'Email'};
        String metadata = (String)LightningComponentController.getFieldsMetadata('Contact', lstFields).data;
        System.assertNotEquals(null, metadata);
        DatabaseResult result = LightningComponentController.getFieldsMetadata('Exception', new List<String>{'exception'}); //To verify whether the null pointer exception caught by this method or not if wrong data is passed
        System.assertEquals(false, result.success);
        System.assertNotEquals(null, result.message);
    }
    
    /************************************************************************************************************************************
        Modified By		: Rupesh Patil
        Modified Date	: 28 Nov 2018 
		Description     : This method verifies getFieldMetadata()
    **************************************************************************************************************************************/    
    public static testMethod void verifyGetFieldMetadata() {
        String metadata = (String)LightningComponentController.getFieldMetadata('Contact', 'Name').data;
        System.assertNotEquals(null, metadata);
        DatabaseResult result = LightningComponentController.getFieldMetadata('Contact', 'Exception');//To verify whether the null pointer exception caught by this method or not if wrong data is passed
        System.assertEquals(false, result.success);
        System.assertNotEquals(null, result.message);
    }
    
     /************************************************************************************************************************************
        Modified By		: Rupesh Patil
        Modified Date	: 28 Nov 2018 
		Description     : This method verifies getAllFields()
    **************************************************************************************************************************************/    
    public static testMethod void verifyGetAllFields() {
        String allfields = (String)LightningComponentController.getAllFields('Contact').data;
       	System.assertNotEquals(null, allfields);
        DatabaseResult result = LightningComponentController.getAllFields('Exception');//To verify whether the null pointer exception caught by this method or not if wrong data is passed
        System.assertEquals(false, result.success);
        System.assertNotEquals(null, result.message);
    }
    
    /************************************************************************************************************************************
        Modified By		: Rupesh Patil
        Modified Date	: 28 Nov 2018 
		Description     : This method verifies getTableData()
    **************************************************************************************************************************************/    
    public static testMethod void verifyGetTableData() {
        Map<string,Object> tabledata = (Map<string,Object>)LightningComponentController.getTableData('Select Id, Name from Contact').data;
        DatabaseResult result = LightningComponentController.getTableData(' ');//To verify whether the null pointer exception caught by this method or not if null data is passed
        System.assertEquals(false, result.success);
        System.assertNotEquals(null, result.message);
    }
    
    /************************************************************************************************************************************
        Modified By		: Rupesh Patil
        Modified Date	: 28 Nov 2018 
		Description     : This method verifies getLayout()
    **************************************************************************************************************************************/    
    public static testMethod void verifyGetLayout() {
        List<Account> lstAccounts = [SELECT Id, Name, RecordTypeId, RecordType.Name FROM Account LIMIT 1];
        List<Building__c> lstBuildings = [SELECT Id, Name FROM Building__c LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorForLightning());
        Object obj = LightningComponentController.getLayout(lstAccounts[0].Id);
        DatabaseResult wrongResult =  LightningComponentController.getLayout(lstBuildings[0].Id);
        Test.stopTest();
        String objResponse = JSON.serialize(obj);
        System.assertNotEquals(null, objResponse);
        System.assert(wrongResult.success);
        DatabaseResult nullResult =  LightningComponentController.getLayout(null);//To verify whether the null pointer exception caught by this method or not if null data is passed
      	System.assert(!nullResult.success);
    }   
    
     /************************************************************************************************************************************
        Modified By		: Rupesh Patil
        Modified Date	: 28 Nov 2018 
		Description     : This method verifies getLayoutWithMapping()
    **************************************************************************************************************************************/    
    public static testMethod void verifyGetLayoutWithMapping(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorForLightning());
        DatabaseResult objAccount = LightningComponentController.getLayoutWithMapping('Account');
        DatabaseResult objSetting = LightningComponentController.getLayoutWithMapping('Setting__c'); 
        System.assert(objAccount.success);
        System.assert(objSetting.success);
        Test.stopTest();  
    } 
    
     /************************************************************************************************************************************
        Modified By		: Rupesh Patil
        Modified Date	: 28 Nov 2018 
		Description     : This method verifies describeById()
    **************************************************************************************************************************************/    
    public static testMethod void verifyDescribeById(){
        List<Account> lstAccountIds = [SELECT Id FROM Account LIMIT 2];
        DatabaseResult result = LightningComponentController.describeById(new List<Id>{lstAccountIds[0].Id, lstAccountIds[1].Id});
        System.assert(result.success);
        DatabaseResult wrongResult = LightningComponentController.describeById(new List<Id>{'906F0000000DDd6IAG'});
        System.assertEquals(false, wrongResult.success);
        System.assertNotEquals(null, wrongResult.message);
        try{
          DatabaseResult nullResult = LightningComponentController.describeById(null);//To verify whether the null pointer exception caught by this method or not if wrong data is passed
        } catch(Exception exc){
            System.assertNotEquals(null, exc);
        }
    } 
    
    /************************************************************************************************************************************
        Modified By		: Rupesh Patil
        Modified Date	: 28 Nov 2018 
		Description     : This method verifies getSobjectNameById()
    **************************************************************************************************************************************/    
    public static testMethod void verifyGetSobjectNameById(){
        List<Account> lstAccount = [SELECT Id, Name FROM Account LIMIT 1];
        String objName = (String)LightningComponentController.getSobjectNameById(lstAccount[0].Id).data;
        system.assertEquals('Account', objName);
        DatabaseResult result = LightningComponentController.getSobjectNameById('906F0000000DDd6IAG');
        System.assertEquals(false, result.success);
        System.assertNotEquals(result.message, null);
        try{
            result = LightningComponentController.getSobjectNameById(null);//To verify whether the null pointer exception caught by this method or not if wrong data is passed
        } catch(Exception exc){
            System.assertNotEquals(null, exc);
        }
    }
    
     /************************************************************************************************************************************
        Modified By		: Rupesh Patil
        Modified Date	: 28 Nov 2018 
		Description     : This method verifies getAllRecordTypesById()
    **************************************************************************************************************************************/    
    public static testMethod void verifyGetAllRecordTypesById(){  
        List<RecordType> lstRecordType = (List<RecordType>)LightningComponentController.getAllRecordTypesById([SELECT Id FROM Account LIMIT 1].Id).data;
        List<RecordType> lstRecordType1 = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Account'];
        boolean isEquals = lstRecordType.equals(lstRecordType1);       
        System.assertEquals(true, isEquals);
        DatabaseResult result = LightningComponentController.getAllRecordTypesById('906F0000000DDd6IAG');//To verify whether the invalid id exception caught by this method or not if wrong id is passed
        System.assertEquals(false, result.success);
        System.assertNotEquals(result.message, null);
    }
    
    /************************************************************************************************************************************
        Modified By		: Rupesh Patil
        Modified Date	: 28 Nov 2018 
		Description     : This method verifies getUserInfo()
    **************************************************************************************************************************************/    
    public static testMethod void verifyGetUserInfo(){
        User objUser = [SELECT Id, Name FROM User WHERE Id=:UserInfo.getUserId()];
        DatabaseResult result = LightningComponentController.getUserInfo();
        System.assert(result.success);
    }
    
     /************************************************************************************************************************************
        Modified By		: Rupesh Patil
        Modified Date	: 28 Nov 2018 
		Description     : This method verifies describeTable()
    **************************************************************************************************************************************/    
    public static testMethod void verifyDescribeTable(){
        DatabaseResult result = LightningComponentController.describeTable('Contact',new List<String>{'Name','Account.Name'});
        System.assert(result.success);
        DatabaseResult nullResult = LightningComponentController.describeTable(null,new List<String>{''});//To verify whether the null pointer exception caught by this method or not if wrong data is passed
        System.assert(!nullResult.success);
    }
    
     /************************************************************************************************************************************
        Modified By		: Rupesh Patil
        Modified Date	: 28 Nov 2018 
		Description     : This method verifies getRelationFieldsMetadata()
    **************************************************************************************************************************************/    
    public static testMethod void verifGetRelationFieldsMetadata (){
        List<String> lstAccounts = new  List<String>{'Name:Account.Name','AccountNumber:Account.AccountNumber'};
        LightningComponentController.getRelationFieldsMetadata(lstAccounts);
        DatabaseResult result = LightningComponentController.getRelationFieldsMetadata(new List<String>{'Exception'});//To verify with wrong data
        System.assertEquals(false,result.success);
        System.assertNotEquals(result.message,null);
    } 
    
     /************************************************************************************************************************************
        Modified By		: Rupesh Patil
        Modified Date	: 28 Nov 2018 
		Description     : This method verifies isValidForTourOutcome()
    **************************************************************************************************************************************/    
    public static testMethod void verifyisValidForTourOutcome(){
        List<Tour_Outcome__c> listTourOutcome = [SELECT Id, Name FROM Tour_Outcome__c LIMIT 4];
        listTourOutcome[0].Uuid__c = '12rer-45545-dssd745';
        listTourOutcome[1].Tour_Date__c = System.today() + 1;
        listTourOutcome[1].Start_Time__c = '18:30PM';
        listTourOutcome[1].End_Time__c = '7:30PM';
        listTourOutcome[2].Tour_Date__c = System.today()-1;
        listTourOutcome[2].uuid__c = '123er-45545-dssdgsd';
        listTourOutcome[2].Start_Time__c = '18:30PM';
        listTourOutcome[2].End_Time__c = '7:30PM';
        listTourOutcome[3].Tour_Date__c = System.today()-15;
        listTourOutcome[3].uuid__c = null;
        TestingUtility.updateListWithAssert(listTourOutcome);
      
        LightningComponentController.TourOutcomeResult objTourOutcomeResult = (LightningComponentController.TourOutcomeResult)LightningComponentController.isValidForTourOutcome(listTourOutcome[0].id).data;
        String result = JSON.serialize(objTourOutcomeResult);
        Map<String, Object> obj = (Map<String, Object>)JSON.deserializeUntyped(result);
        System.assertEquals(true, obj.get('isValid'));
        
        objTourOutcomeResult = (LightningComponentController.TourOutcomeResult)LightningComponentController.isValidForTourOutcome(listTourOutcome[2].id).data;
        result = JSON.serialize(objTourOutcomeResult);
        obj = (Map<String, Object>)JSON.deserializeUntyped(result);
        System.assertEquals(true, obj.get('isValid'));
        
        objTourOutcomeResult = (LightningComponentController.TourOutcomeResult)LightningComponentController.isValidForTourOutcome(listTourOutcome[1].id).data;
        result = JSON.serialize(objTourOutcomeResult);
        obj = (Map<String, Object>)JSON.deserializeUntyped(result);
        System.assertEquals(false, obj.get('isValid'));
        
        objTourOutcomeResult = (LightningComponentController.TourOutcomeResult)LightningComponentController.isValidForTourOutcome(listTourOutcome[3].id).data;
        result = JSON.serialize(objTourOutcomeResult);
        obj = (Map<String, Object>)JSON.deserializeUntyped(result);
        System.assertEquals(false, obj.get('isValid'));
        
        String tempId = 'a0R0S000000qZU3UAM';
        LightningComponentController.TourOutcomeResult objTourOutcomeResult1 = (LightningComponentController.TourOutcomeResult)LightningComponentController.isValidForTourOutcome(tempId).data;//to throw exception with wrong id and catch invalid id exception
 		System.assert(objTourOutcomeResult1 == null);
       
    }
    
     /************************************************************************************************************************************
        Modified By		: Rupesh Patil
        Modified Date	: 28 Nov 2018 
		Description     : This method verifies getTodaysDate()
    **************************************************************************************************************************************/    
    public static testMethod void verifygetTodaysDate(){
        Date objDate = (Date)LightningComponentController.getTodaysDate().data;
        System.assertEquals(System.today(), objDate);
    }
    
    /************************************************************************************************************************************
        Modified By		: Rupesh Patil
        Modified Date	: 28 Nov 2018 
		Description     : This method verifies callSaveRecords()
    **************************************************************************************************************************************/    
    public static testMethod void verifyCallSaveRecords(){
        List<Journey__c> lstofJourneys = [SELECT Id, Name, CurrencyIsoCode, Primary_Contact__c, NMD_Next_Contact_Date__c FROM Journey__c WHERE Primary_Contact__r.Email = 'john1.Contact@example.com' OR Primary_Contact__r.Email = 'john2.Contact@example.com'];
        List<object> resultofJourney = (List<object>)LightningComponentController.callSaveRecords(lstofJourneys).data;
       	System.assert(resultofJourney != null);
    }
    
    /************************************************************************************************************************************
        Modified By		: Rupesh Patil
        Modified Date	: 28 Nov 2018 
		Description     : This method verifies getUserProfileInfo()
    **************************************************************************************************************************************/
  	public static testMethod void verifyGetUserProfileInfo(){
        String UserInfo = (String)LightningComponentController.getUserProfileInfo().data; 
        System.assert(UserInfo != null);
    }
    
    /************************************************************************************************************************************
        Modified By		: Rupesh Patil
        Modified Date	: 28 Nov 2018 
		Description     : This method verifies addBusinessDays()
    **************************************************************************************************************************************/    
    public static testMethod void verifyAddBusinessDays(){
        Date businessDate = (Date)LightningComponentController.addBusinessDays(2017, 09, 15, 2).data; 
        Date myDate = Date.newInstance(2017, 09, 19);       
        System.assertEquals(myDate,businessDate);
        try{
            businessDate = (Date)LightningComponentController.addBusinessDays(null, null, null, null).data; 
        } catch(Exception exc){
            System.assertNotEquals(null, exc);
        } 
    }
    
    /************************************************************************************************************************************
        Modified By		: Rupesh Patil
        Modified Date	: 28 Nov 2018 
		Description     : This method verifies getMyDomain()
    **************************************************************************************************************************************/    
    public static testMethod void verifygGetMyDomain(){
        String MyDomain = (String)LightningComponentController.getMyDomain().data; 
        System.assert(MyDomain != null);
    }
   
   /************************************************************************************************************************************
        Modified By		: Rupesh Patil
        Modified Date	: 28 Nov 2018 
		Description     : This method verifies getAllObjects()
    **************************************************************************************************************************************/    
    public static testMethod void verifygetAllObjects() {
        String test = (String)LightningComponentController.getAllObjects().data;
       	System.assert(test != null);
    }
   
    /************************************************************************************************************************************
   		 Author 		: Rupesh Patil
   		 Description 	: This method verifies the getUltimateParentAccount() and getParentAccount()
    	 Created Date	: 15 Nov 2018 
    **************************************************************************************************************************************/
        public testmethod static void verifygetParentAccount(){
            List<Account> lstAccounts = [SELECT Id, Name, Account_Type__c FROM Account LIMIT 3];
            lstAccounts[1].ParentId =  lstAccounts[0].Id;// lstAccounts[0] will be ultimate parent
            TestingUtility.updateWithAssert(lstAccounts[1]);
            
            lstAccounts[2].Account_Type__c = 'Sales';
            lstAccounts[2].Nickname__c = 'NickSales';
            lstAccounts[2].ParentId = lstAccounts[1].Id;
            TestingUtility.updateWithAssert(lstAccounts[2]);
            System.assertEquals(lstAccounts[0].Id, (Id)LightningComponentController.getUltimateParentAccount(lstAccounts[2].Id).data);
            System.assertEquals(lstAccounts[0].Id, (Id)LightningComponentController.getUltimateParentAccount(lstAccounts[1].Id).data);
        }  
        
  /************************************************************************************************************************************
        Author              : Priyanka Ambre
        Description         : This method  tests SaveGoogleLocations .
        Created Date        : 27 November 2017
        Issue No.           : ST-1640
    **************************************************************************************************************************************/
    public static testMethod void verifySaveGoogleLocations(){  
        List<Geography__c> lstGeography = new  List<Geography__c>(); 
        Geography__c objGeography1 = new Geography__c(
            Name='Baner1,Maharashtra',
            City__c='Pune',
            Country__c='Indi2politicala', District__c='Pune',
            Formatted_Address__c='Baner, Pune, Maharashtra, India', 
            Geocode__Latitude__s=18.5596581,
            Geocode__Longitude__s=73.7799374,
            JSON__c='{"address_components":[{"long_name":"Baner","short_name":"Baner","types":["","sublocality","sublocality_level_1"]},{"long_name":"Pune","short_name":"Pune","types":["locality","political"]},{"long_name":"Pune","short_name":"Pune","types":["administrative_area_level_2","political"]},{"long_name":"Maharashtra","short_name":"MH","types":["administrative_area_level_1","political"]},{"long_name":"India","short_name":"IN","types":["country","political"]}],"formatted_address":"Baner, Pune, Maharashtra, India","geometry":{"bounds":{"northeast":{"lat":18.5756111,"lng":73.8043045},"southwest":{"lat":18.544332,"lng":73.76332800000002}},"location":{"lat":18.5596581,"lng":73.7799374},"location_type":"APPROXIMATE","viewport":{"northeast":{"lat":18.5756111,"lng":73.8043045},"southwest":{"lat":18.544332,"lng":73.76332800000002}}},"place_id":"ChIJy9Nd8M--wjsRfat_-5cSkaE","types":["political","sublocality","sublocality_level_1"]}',
            Location_Type__c='APPROXIMATE', 
            Place_ID__c='ChIJy9Nd8M--wjsRfat_-5cSkaE', 
            State__c='Maharashtra' 
        ); 
        Id geoId = (Id)LightningComponentController.upsertGeolocation(objGeography1).data;
        System.assertNotEquals(null, geoId);
        
        Geography__c objGeography2 = new Geography__c(
            Name='Sangamner, Maharashtra', City__c='Sangamner',
            Country__c='Indi2politicala', District__c='Ahmednagar',
            Formatted_Address__c='Sangamner, Maharashtra 422605, India', 
            Geocode__Latitude__s=19.5771387 ,
            Geocode__Longitude__s=74.2079648,
            JSON__c='{"address_components":[{"long_name":"Sangamner","short_name":"Sangamner","types":["locality","political"]},{"long_name":"Ahmednagar","short_name":"Ahmednagar","types":["administrative_area_level_2","political"]},{"long_name":"Maharashtra","short_name":"MH","types":["administrative_area_level_1","political"]},{"long_name":"India","short_name":"IN","types":["country","political"]},{"long_name":"422605","short_name":"422605","types":["postal_code"]}],"formatted_address":"Sangamner, Maharashtra 422605, India","geometry":{"bounds":{"northeast":{"lat":19.5954532,"lng":74.2273235},"southwest":{"lat":19.5567976,"lng":74.1888714}},"location":{"lat":19.5771387,"lng":74.2079648},"location_type":"APPROXIMATE","viewport":{"northeast":{"lat":19.5954532,"lng":74.2273235},"southwest":{"lat":19.5567976,"lng":74.1888714}}},"partial_match":true,"place_id":"ChIJeavrqdAB3TsRiL6oagFS3UY","types":["locality","political"]}',
            Location_Type__c='APPROXIMATE', 
            Place_ID__c='ChIJy9Nd8M--wjsRfat_-5cSkaE', 
            State__c='Maharashtra',
            CurrencyIsoCode='USD'
        );
        Id newGeoId = (Id)LightningComponentController.upsertGeolocation(objGeography2).data;
        System.assertNotEquals(null, newGeoId); 
        System.assertEquals(geoId, newGeoId);
        try{
            newGeoId = (Id)LightningComponentController.upsertGeolocation(null).data;
        } catch(Exception exc){
            System.assertNotEquals(null, exc);
        }
    }
    
   /************************************************************************************************************************************
        Modified By		: Rupesh Patil
        Modified Date	: 28 Nov 2018 
		Description     : This method verifies getRecordTypeIds()
    **************************************************************************************************************************************/    
    public static testMethod void verifyGetRecordTypeIdsTest(){
        Map<String,Id> result = (Map<String,Id>)LightningComponentController.getRecordTypeIds('Enterprise Solutions').data;
        System.assertNotEquals(null, result);
        try{
            result = (Map<String,Id>)LightningComponentController.getRecordTypeIds(null).data;
        } catch(Exception exc){
            System.assertNotEquals(null, exc);
        }
    }
    
     /************************************************************************************************************************************
        Modified By		: Rupesh Patil
        Modified Date	: 28 Nov 2018 
		Description     : This method verifies getRecordTypeInfos()
    **************************************************************************************************************************************/    
    public static testMethod void verifyGetRecordTypeInfosTest(){
        List<String> lstObjectNames = new List<String>{'Account', 'Contact', 'Opportunity'};
        Map<String, Map<String, Id>> result = (Map<String, Map<String, Id>>)LightningComponentController.getRecordTypeInfos(lstObjectNames).data;
        System.assertNotEquals(null, result);
        Id consumerRecordTypeIdofAcc = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Consumer').getRecordTypeId();
       	System.assertEquals(consumerRecordTypeIdofAcc, result.get('Account').get('Consumer'));
        Id midMarketRecordTypeOfContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Mid Market').getRecordTypeId();
        System.assertEquals(midMarketRecordTypeOfContact, result.get('Contact').get('Mid Market'));
        Id enterpriseSolutionsRecordTypeOfOppo = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise Solutions').getRecordTypeId();
        System.assertEquals(enterpriseSolutionsRecordTypeOfOppo, result.get('Opportunity').get('Enterprise Solutions'));
        try{
            result = (Map<String, Map<String, Id>>)LightningComponentController.getRecordTypeInfos(null).data;//To verify null pointer exception
        } catch(Exception exc){
            System.assertNotEquals(null, exc);
        }
    }
    
     /************************************************************************************************************************************
        Modified By		: Rupesh Patil
        Modified Date	: 28 Nov 2018 
		Description     : This method verifies getSalesConsoleSetting()
    **************************************************************************************************************************************/    
    public static testMethod void verifyGetSalesConsoleSettingTest(){
        Setting__c setting = [SELECT Id, Name FROM Setting__c WHERE Name = 'FieldMappings:BillAccountToOrgAccount'];
        String result = (String)LightningComponentController.getSalesConsoleSetting(setting.Name).data;
        System.assertNotEquals(null, result);
        try{
            result = (String)LightningComponentController.getSalesConsoleSetting(null).data;//To verify with null data
        } catch(Exception exc){
            System.assertNotEquals(null, exc);
        }
    }
    
     /************************************************************************************************************************************
        Modified By		: Rupesh Patil
        Modified Date	: 28 Nov 2018 
		Description     : This method verifies getObjectFields()
    **************************************************************************************************************************************/    
    public static testMethod void verifyGetObjectFields(){
        DatabaseResult objFieldsForAccount =  LightningComponentController.getObjectFields('Account');
        System.assertNotEquals(null, objFieldsForAccount);
        DatabaseResult objFieldsForException =  LightningComponentController.getObjectFields('Accounts');
        System.assertNotEquals(null, objFieldsForException);
        try{
            objFieldsForException = LightningComponentController.getObjectFields(null);//To verify with null data
        } catch(Exception exc){
            System.assertNotEquals(null, exc);
        }
    }
    
    /************************************************************************************************************************************
        Modified By		: Rupesh Patil
        Modified Date	: 28 Nov 2018 
		Description     : This method verifies getsObjectPrefix()
    **************************************************************************************************************************************/    
    public static testMethod void verifyGetsObjectPrefix(){
        DatabaseResult sObjectPrefix =  LightningComponentController.getsObjectPrefix('Account');
        System.assertNotEquals(null, sObjectPrefix);
        System.assertEquals('001', (String)sObjectPrefix.data);
        sObjectPrefix =  LightningComponentController.getsObjectPrefix('exception');
        System.assertEquals(false, sObjectPrefix.success);
        System.assertNotEquals(null, sObjectPrefix.message);
        try{
            sObjectPrefix = LightningComponentController.getsObjectPrefix(null);//to verify the exception with null data
            System.assertEquals(false, sObjectPrefix.success);
        } catch(Exception exc){
            System.assertNotEquals(null, exc);
        }
    }
    
     /************************************************************************************************************************************
        Modified By		: Rupesh Patil
        Modified Date	: 28 Nov 2018 
		Description     : This method verifies getTimezoneOffset()
    **************************************************************************************************************************************/    
    public static testMethod void verifyTimezoneOffset(){
        DatabaseResult timeZoneOffset =  LightningComponentController.getTimezoneOffset();
        System.assertNotEquals(null, timeZoneOffset);
    }
   
     /************************************************************************************************************************************
        Modified By		: Rupesh Patil
        Modified Date	: 28 Nov 2018 
		Description     : This method verifies searchQueryData()
    **************************************************************************************************************************************/    
    public static testMethod void verifySearchQueryData(){
        String str ='FIND \'*Lead*\' IN Name FIELDS RETURNING Account( Id, Name )';
        String result =  (String)LightningComponentController.searchQueryData(str).data;
        try{
            result = (String)LightningComponentController.searchQueryData(null).data;//to verify the exception with null or wrong data
       		System.assertEquals(null, result);
        } catch(Exception exc){
            System.assertNotEquals(null, exc);
        }
    }
    
     /************************************************************************************************************************************
        Modified By		: Rupesh Patil
        Modified Date	: 28 Nov 2018 
		Description     : This method verifies getTimezoneOffset()
    **************************************************************************************************************************************/    
    public static testMethod void verifyGetTimezoneOffset() {
        TimeZone tz1 = UserInfo.getTimeZone();
        Integer offset = tz1.getOffset(DateTime.newInstance(2019,05,06));
        DatabaseResult result = LightningComponentController.getTimezoneOffset();
        System.assertEquals(offset, Integer.valueOf(result.data));
    }
    
     /************************************************************************************************************************************
        Modified By		: Rupesh Patil
        Modified Date	: 28 Nov 2018 
		Description     : This method verifies getSessionId()
    **************************************************************************************************************************************/    
    public static testMethod void verifyGetSessionId() {
        String sessionId = UserInfo.getSessionId();
        DatabaseResult result = LightningComponentController.getSessionId();       
        System.assert(result.success);
        System.assertEquals(sessionId, (String)result.data);
    }
    
     /************************************************************************************************************************************
        Modified By		: Rupesh Patil
        Modified Date	: 28 Nov 2018 
		Description     : This method verifies isValidOppforSendProposal()
    **************************************************************************************************************************************/    
    public static testMethod void verifyIsValidOppforSendProposal() {
        List<Opportunity> lstOpportunities = [SELECT Id FROM Opportunity LIMIT 1];
        DatabaseResult result = LightningComponentController.isValidOppforSendProposal(lstOpportunities[0].Id);
        LightningComponentController.ValidResultWithOpp validResult = new LightningComponentController.ValidResultWithOpp();
        validResult = (LightningComponentController.ValidResultWithOpp)result.data;
        System.assert(validResult.isValid==true);
        Opportunity objOpportunity = validResult.objOpportunity;
        System.assertNotEquals(objOpportunity.Proposal_Sent_On__c, null);
        Boolean isValidOwner = validResult.isValidOwner;
        String errorMsg = validResult.errorMsg;
        List<String> opportunityBuildings = validResult.opportunityBuildings;
        try{
            result = LightningComponentController.isValidOppforSendProposal(null);//to verify the exception with null or wrong data
        } catch(Exception exc){
            System.assertNotEquals(null, exc);
        }
    }
     
     /************************************************************************************************************************************
        Modified By		: Rupesh Patil
        Modified Date	: 28 Nov 2018 
		Description     : This method verifies getUITheme()
    **************************************************************************************************************************************/    
    public static testMethod void  verifyGetUITheme() {
        String uiTheme =  UserInfo.getUiTheme();
        DatabaseResult result = LightningComponentController.getUITheme();
        System.assertEquals(uiTheme, String.valueOf(result.data));
    }
    
     /************************************************************************************************************************************
        Modified By		: Rupesh Patil
        Modified Date	: 28 Nov 2018 
		Description     : This method verifies getRecordTypeInfo()
    **************************************************************************************************************************************/    
    public static testMethod void  verifygetRecordTypeInfo() {
        DatabaseResult result = LightningComponentController.getRecordTypeInfo('Account');
        Map<Id,String> mapOfRecordTypes = (Map<Id,String>)result.data;
        Integer size = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().values().size();
        System.assertEquals(size, mapOfRecordTypes.size());
        System.assertEquals('consumer',(mapOfRecordTypes.get('0120G000001USsT')).toLowerCase() );
        System.assertEquals('mid market',(mapOfRecordTypes.get('0120G000001USsU')).toLowerCase() );
        
        result = LightningComponentController.getRecordTypeInfo('exception');
        System.assertEquals(false,result.success);
        System.assertNotEquals(result.message,null);
        try{
            result  = LightningComponentController.getRecordTypeInfo(null);//to verify with null data
        } catch(Exception exc){
            System.assertNotEquals(null, exc);
        }
    }
  
     /************************************************************************************************************************************
        Modified By		: Rupesh Patil
        Modified Date	: 28 Nov 2018 
		Description     : This method verifies executeRestQuery()
    **************************************************************************************************************************************/    
    public static testMethod void  verifyExecuteRestQuery() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorForLightning());
        DatabaseResult result = LightningComponentController.executeRestQuery(false, 'GET','http://example.com/example/test', new Map<String,String>{'Authorization'=>'Standard'},'');
        DatabaseResult result1 = LightningComponentController.executeRestQuery(true, 'GET','http://example1.com/example/test', new Map<String,String>{'Authorization'=>'Standard'},'');
        DatabaseResult result2 = LightningComponentController.executeRestQuery(true, 'POST','http://example2.com/example/test', new Map<String,String>{'Authorization'=>'Standard','Content-type'=>'Data'},'');
        Test.stopTest(); 
        System.assertEquals(true, result.success);
        System.assertEquals(true, result1.success); 
        System.assertEquals(true, result2.success);
        System.assertEquals('{"foo":"bar"}', String.valueOf(result.data));
        try{
            result  = LightningComponentController.executeRestQuery(null, 'GET','http://example.com/example/test', new Map<String,String>{'Authorization'=>'Standard'},'');//to verify the exception generated with null and wrong data
        } catch(Exception exc){
            System.assertNotEquals(null, exc);
        }
    }
  
    /************************************************************************************************************************************
    Author         : Samadhan Kadam
    Description     : This method is used in apex log component to fetch debug logs.
    Created Date    : 05 May 2018 
    Modified By		: Rupesh Patil
    Modified Date	: 28 Nov 2018 
    **************************************************************************************************************************************/
    public static testMethod void verifyGetUserLogs() {
        List<string> lstUser1 = new List<string>{'005F0000003KmbwIAC',UserInfo.getUserId()};
        string startTime = '11:00';
        string startDate = '2017-05-21';
        string endTime = '11:00';
        string endDate = '2022-05-31';
        List<string> lstOperations = new List<string>();
        string size = '2'; 
        string searchTerm = 'foo'; 
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorForLightning());
        DatabaseResult result = LightningComponentController.getUserLogs(lstUser1,startDate,endDate,size,searchTerm,lstOperations,startTime,endTime);
        System.assert(result.success);
        Test.stopTest();
        DatabaseResult result1 = LightningComponentController.getUserLogs(null,startDate,endDate,size,'test exception',lstOperations,startTime,endTime);
        System.assertNotEquals(true, result1.success);
    }
    
    /************************************************************************************************************************************
    Author         : Samadhan Kadam
    Description     : This method is used in apex log component to delete debug logs.
    Created Date    : 05 May 2018 
    Modified By		: Rupesh Patil
    Modified Date	: 28 Nov 2018 
    **************************************************************************************************************************************/
    public static testMethod void  verifydeleteLogs() {
        List<String> lstApexLogId = new List<string>();
        List<ApexLog> lstApexLog = [Select Id from ApexLog limit 5];
        for(ApexLog objApexLog : lstApexLog ){
            lstApexLogId.add(objApexLog .Id);
        }
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorForLightning());
        DatabaseResult result = LightningComponentController.deleteLogs(lstApexLogId);
        System.assert(result.success);
        Test.stopTest();
    }
    
     /************************************************************************************************************************************
        Modified By		: Rupesh Patil
        Modified Date	: 28 Nov 2018 
		Description     : This method verifies getDateAccordingToLoginUserTimeZone()
    **************************************************************************************************************************************/    
    public static testmethod void verifygetAPISessionId(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorForLightning());
        Test.stopTest();
        DatabaseResult dbresult = LightningComponentController.getAPISessionId();
        System.assert(dbresult != null); 
    }
    
     /************************************************************************************************************************************
        Modified By		: Rupesh Patil
        Modified Date	: 28 Nov 2018 
		Description     : This method verifies getDateAccordingToLoginUserTimeZone()
    **************************************************************************************************************************************/    
    public static testmethod void verifygetRESTCalloutData(){
        DatabaseResult objdbresult = LightningComponentController.getRESTCalloutData();
        System.assert(objdbresult.success);
    }
   	
    /************************************************************************************************************************************
		Author : Ashish Mishra
		Description : This method cover the getTableBody() function.
		Created Date	: 19 June 2018 
	**************************************************************************************************************************************/
    public static testMethod void verifyGetTableBody(){
        Map<String, List<sObject>> mapSobjectRecords = new Map<string, List<sObject>>();
        Set<String> setTblFields = new Set<String>{'Name', 'Email'};
        List<lead> lstLeads = [SELECT Id, Name, Email FROM Lead Limit 1];
        mapSobjectRecords.put('Existing Leads', lstLeads);
        String body = LightningComponentController.getTableBody(setTblFields, mapSobjectRecords);
        System.assert(body != null);
    }
  
    /************************************************************************************************************************************
        Author 			: Jitesh Adwani
        Description 	: This method verifies the getListQueryDataBySOSL()
        Created Date	: 27 July 2018
		Last Modified By: Rupesh Patil
		Last Modified Date : 28 Nov 2018
  **************************************************************************************************************************************/
    public static testMethod void verifyGetListQueryDataBySOSL(){
        List<String> lstQuery = new List<String>();
        String query = 'FIND {A} IN Name FIELDS RETURNING Account(Name) LIMIT 1';
        lstQuery.add(query);
        DatabaseResult result = LightningComponentController.getListQueryDataBySOSL(lstQuery);
        System.assertEquals(true, result.success);
        DatabaseResult result1 = LightningComponentController.getListQueryDataBySOSL(null);
        System.assert(!result1.success);
    }
    
   /************************************************************************************************************************************
        Author 			: Jitesh Adwani
        Description 	: This method verifies the getRelatedRefernces()
        Created Date	: 27 July 2018 
		Last Modified By: Rupesh Patil
		Last Modified Date : 28 Nov 2018
  **************************************************************************************************************************************/
   public static testMethod void verifyGetRelatedRefernces(){
       String objName = 'Account';
       List<String> lstObjFields = new List<String>{'Name', 'Phone', 'Site'};
       DatabaseResult result = LightningComponentController.getRelatedRefernces(objName, lstObjFields);
       System.assertEquals(true, result.success);
       result = LightningComponentController.getRelatedRefernces(null, lstObjFields);
       System.assertEquals(false, result.success);
    }
    
   /************************************************************************************************************************************
        Author       : Jitesh Adwani
        Description   : This method covers the convertLeadsToExisting()
        Created Date  : 27 July 2018 
  **************************************************************************************************************************************/
    static testMethod void verifyConvertLeadsToExisting(){
        Lead objLead = new Lead();        
        objLead.LastName = 'lastName';       
        objLead.Email = 'email@enazigma.com'; 
        objLead.Phone = '1234567891';
        objLead.Company = 'Test Company';
        objLead.Locations_Interested__c='Test Building Tour';
        objLead.LeadSource= 'Broker';
        objLead.Lead_Source_Detail__c = 'Broker1';
        insert objLead;
        System.assert(objLead.id!= null);
        DatabaseResult result = LightningComponentController.convertLeadsToExisting(objLead);
        System.debug('result-->'+result);
        System.assertEquals(true, result.success);
    }    
    /************************************************************************************************************************************
        Author 			: Ashish Mishra
        Description 	: This method verifies the verifySendPaperworkOpportunity()
        Created Date	: 23 Oct 2018 
        Modified By		: Rupesh Patil
		Modified Date   : 29 Nov 2018
   **************************************************************************************************************************************/
    public static testMethod void verifyGetLayoutForNewRecord(){ 
        String sobjectName ='Account';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorForLightning());
        DatabaseResult layout = LightningComponentController.getLayoutForNewRecord(sobjectName);
        System.assert(layout.success);
        Test.stopTest();   
        layout = LightningComponentController.getLayoutForNewRecord(null);//To verify with null data
        System.assert(!layout.success);
    }
    
    /************************************************************************************************************************************
        Author 			: Rupesh Patil
        Description 	: This method verifies the validateLeadforWebService() and validateLead()
        Created Date	: 15 Nov 2018 
    **************************************************************************************************************************************/
    public static testMethod void verifyValidateLeadforWebService(){
        List<Lead> lstLeads = [SELECT Id FROM Lead LIMIT 1];
        List<Journey__c> lstJourneys = [SELECT Id FROM Journey__c LIMIT 1];
                                            
        Test.startTest();
        LightningComponentController.WebServiceWrapper objWrapper = LightningComponentController.validateLeadforWebService(lstLeads[0].Id);
        System.assert(objWrapper.success);
        objWrapper = LightningComponentController.validateLeadforWebService(lstJourneys[0].Id);
        System.assert(objWrapper.success);
        Test.stopTest();
        objWrapper = LightningComponentController.validateLeadforWebService(null);//To verify exception with null id
        System.assert(!objWrapper.success);
    }
    
/************************************************************************************************************************************
        Author 			: Rohit Nimase
        Description 	: This method has setup data for all test methods 
        Created Date	: 7 Feb 2019 
		Issue No.		: STL-127
**************************************************************************************************************************************/
    public static testMethod void verifyGetExternalSystemEndPoints(){
        Set<String> setTourEndpoint = new set<String>();
        for(Integration_Data__mdt tourEndpoint : [SELECT Label FROM Integration_Data__mdt]){
            setTourEndpoint.add(tourEndpoint.Label);
        }
        
        Map<String, Integration_Data__mdt> allTourAPIs = LightningComponentController.getExternalSystemEndPoints(setTourEndpoint);
        System.assertNotEquals(null, allTourAPIs.get('tourbuildingavailabilitiesapi'));
    }
    
     public testmethod static void verifyBulkJourneyUpdates(){
        List<Lead> lstLeadData = new List<Lead>();
        lstLeadData = [SELECT Id FROM Lead];
        Journey__c testJourney = new Journey__c();
        testJourney.Name = 'testJourney';
        testJourney.CurrencyIsoCode = 'USD';
        testJourney.Primary_Lead__c = lstLeadData[0].Id;
        testJourney.NMD_Next_Contact_Date__c = Date.today();
        testJourney.Lost_Reason__c = 'Not Interested';
        TestingUtility.insertWithAssert(testJourney);
        debug.Log('testJourney===>'+testJourney);
        Journey__c objJourney=[SELECT Id,Name From Journey__c Where Id=: testJourney.Id LIMIT 1];
        String str= (String)ManageToursController.getDataForManageTours('Lead', lstLeadData[0].Id).data;
        List<String>journeyIds=new List<String>();
        journeyIds.add(String.valueOf(testJourney.Id)); 
        boolean l = (Boolean)LightningComponentController.bulkJourneyUpdates(journeyIds, '2017-11-24', 'description').data;
        debug.log('l::'+l);
        string header = 'Id, Type__c ,Name,Data__c,Description__c\n';
        string finalstr = header ;
        string recordString = '12345678, String ,krishana,test data,None\n';
        finalstr = finalstr +recordString;   
        String result = (String)LightningComponentController.SendMail(finalstr).data;
        Debug.log('result::'+result);
        system.assertEquals('done', result);
        
        Settings.FieldMappings obj = (Settings.FieldMappings)LightningComponentController.Contact2Opportunity().data;
        try{
            result = (String)LightningComponentController.SendMail(null).data;
        } catch(Exception exc){
            System.assertNotEquals(null, exc);
        }      
    }
    
   /************************************************************************************************************************************
        Author        : Shivprasad Patil
        Description   : This method covers the GetDefaultPickListValue method in lightning component
        Created Date  : 9 Jan 2019
   **************************************************************************************************************************************/
    public static testMethod void verifyGetDefaultPickListValue(){ 
        DatabaseResult objResult = LightningComponentController.getDefaultPickListValue('Lead', 'LeadSource');
        System.assertEquals(false, objResult.success);
    }
}