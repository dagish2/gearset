/************************************************************************************************************************************
    Author      :   Prashant Mane
    Description :   This class contain all test methods related to ManageToursController class.
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1           10 Jan 2019         Prashant Mane           Initial Developement
**************************************************************************************************************************************/
@isTest
private class ManageToursControllerTests {  
    @TestSetup 
    static void testDataSetup(){
        SalesConsoleSettings.createSettings();
        List<Opportunity> lstOpportunities = new List<Opportunity>();
        Map<String,Object> mapOpportunityRecord = new Map<String,Object>();
        Map<String,Object> mapRecordValues = new Map<String,Object>();
        List<User> lstUsers = (List<User>)TestingUtility.getRecords(new Map<String, Object>{'objName' => 'User', 'numberOfRecords' => 2});
        List<Building__c> lstBuildings = (List<Building__c>)TestingUtility.getRecords(new Map<String, Object>{'objName' => 'Building__c', 'numberOfRecords' => 1});
        Account testAccount = TestingUtility.createAccount(new Map<String,Object>{'Name'=>'Test Account1','UUID__c'=>'0000-0001'}, false);
        TestingUtility.insertWithAssert(testAccount);

        Account testAccount1 = TestingUtility.createAccount(new Map<String,Object>{'Name'=>'Test Account2','UUID__c'=>'0000-0002'}, false);
        TestingUtility.insertWithAssert(testAccount1);
        
        mapRecordValues.clear();
        mapRecordValues.put('LastName','Primary Contact');
        mapRecordValues.put('Email','TestContact@example.com');
        mapRecordValues.put('AccountId',testAccount.Id);
        TestingUtility.createContact(mapRecordValues, true); 
        
        //Opportunity 1 for selling stage
        mapOpportunityRecord.put('StageName', 'Selling');
        mapOpportunityRecord.put('CloseDate', system.today().addDays(5));
        mapOpportunityRecord.put('AccountId', testAccount.Id);
        mapOpportunityRecord.put('Contract_UUID__c', 'Opp-0001');
        lstOpportunities.add(TestingUtility.createOpportunity(mapOpportunityRecord, false));
        
        //Opportunity 2 for Closed Won stage
        mapOpportunityRecord.put('StageName', 'Closed Won');
        mapOpportunityRecord.put('CloseDate', system.today().addDays(10));
        mapOpportunityRecord.put('AccountId', testAccount.Id);
        mapOpportunityRecord.put('Contract_UUID__c', 'Opp-0002');
        lstOpportunities.add(TestingUtility.createOpportunity(mapOpportunityRecord, false));
        
        //Opportunity 3 for Closing stage and contract stage is Contract Sent
        mapOpportunityRecord.put('StageName', 'Closing');
        mapOpportunityRecord.put('Contract_Stage__c', 'Contract Sent');
        mapOpportunityRecord.put('CloseDate', system.today().addDays(15));
        mapOpportunityRecord.put('AccountId', testAccount.Id);
        mapOpportunityRecord.put('Contract_UUID__c', 'Opp-0003');
        lstOpportunities.add(TestingUtility.createOpportunity(mapOpportunityRecord, false));
        
        //Inserting Opportunities
        TestingUtility.insertListWithAssert(lstOpportunities);
    }
    
	/************************************************************************************************************************************
    	Author 				:	Samadhan Kadam
    	Description 		: 	This method tests verifyIsValidOppForManageTour.
    	Created Date		: 	18 July 2018 
    **************************************************************************************************************************************/
    static testMethod void verifyIsValidOppForManageTour(){
        
        Set<String> setContractUUIDs = new Set<String>{'Opp-0001','Opp-0002','Opp-0003'};
        List<Opportunity> lstOpportunities = [SELECT Id FROM Opportunity WHERE Contract_UUID__c In: setContractUUIDs];
        
        Test.startTest();
        String resultForSellingOpp = ManageToursController.isValidOpportunityForManageTour(lstOpportunities[0].id);
        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(resultForSellingOpp);
        System.assertEquals(true, response.get('isValid'));
        
        String resultForClosedOpp = ManageToursController.isValidOpportunityForManageTour(lstOpportunities[1].id);
        response = (Map<String, Object>)JSON.deserializeUntyped(resultForClosedOpp);   
        System.assertEquals(false, response.get('isValid'));
        System.assertEquals(response.get('errorMsg'), 'Cannot Book Tours for Opportunity with stage Closed Won, Closed Lost or Merged');        
        
        String resultForClosingopp = ManageToursController.isValidOpportunityForManageTour(lstOpportunities[2].id);
        response = (Map<String, Object>)JSON.deserializeUntyped(resultForClosingopp);
        System.assertEquals(false, response.get('isValid'));
        System.assertEquals(response.get('errorMsg'), 'Cannot Book Tours on Closing Opportunity with Contract Stage as Sent or Signed');  
        ManageToursController.isValidOpportunityForManageTourLightning(lstOpportunities[1].id);
        Test.stopTest();
    }  
    
	/************************************************************************************************************************************
		Author 				:	Samadhan Kadam
		Description 		: 	This method tests verify IsValidAccountForManageTour.
		Created Date		: 	18 July 2018 
	**************************************************************************************************************************************/
    static testMethod void verifyIsValidAccountForManageTour(){
        Set<String> setAccounUUIDs = new Set<String>{'0000-0001','0000-0002'};
        List<Account> lstAccounts = [SELECT Id,Name FROM Account WHERE UUID__c In: setAccounUUIDs];
        
        Test.startTest();
        string resultForAccountWithCon = ManageToursController.isValidAccountForManageTour(lstAccounts[0].id);
        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(resultForAccountWithCon);
        System.assertEquals(true, response.get('isValid'));
        
        string resultForAccountWithoutCon = ManageToursController.isValidAccountForManageTour(lstAccounts[1].id);
        response = (Map<String, Object>)JSON.deserializeUntyped(resultForAccountWithoutCon);
        System.assertEquals(false, response.get('isValid'));
        System.assertEquals(response.get('errorMsg'), 'You cannot book a tour due to Contact not found under '+lstAccounts[1].Name+'');          
        Test.stopTest();
        ManageToursController.isValidAccountForManageTourLightning(lstAccounts[0].id);
    }
    
   /************************************************************************************************************************************
		Author 				:	Samadhan Kadam
		Description 		: 	This method tests verify IsValidAccountForManageTour.
		Created Date		: 	18 July 2018 
	**************************************************************************************************************************************/
    public static testMethod void verifyCreateOpportunityForManageTours() {
        Object numberOfDesk = 10;
        List<Contact> lstcontacts = [SELECT Id FROM Contact LIMIT 1];
        DatabaseResult result = ManageToursController.createOpportunityForManageTours(lstcontacts[0].Id, numberOfDesk);
        System.assertEquals(true,result.success);
        List<Opportunity> lstOpportunity = (List<Opportunity>)JSON.deserialize(String.valueOf(result.data), List<Opportunity>.class);
        System.assertEquals(1, lstOpportunity.size());
        try{
            result  = ManageToursController.createOpportunityForManageTours(null, null);//to verify with null data
        } catch(Exception exc){
            System.assertNotEquals(null, exc);
        }
    }
    
    /************************************************************************************************************************************
		Author 				:	Samadhan Kadam
		Description 		: 	This method tests verify IsValidAccountForManageTour.
		Created Date		: 	18 July 2018 
	**************************************************************************************************************************************/
    public static testMethod void verifyGetDataForManageTours(){
        List<Account> lstAccounts = [SELECT Id FROM Account LIMIT 1];
        List<Contact> lstContacts = [SELECT Id, Name, Email, AccountId FROM Contact LIMIT 1];
        List<Opportunity> lstOpportunities = [SELECT Id FROM Opportunity LIMIT 1];
        List<User> lstUsers = [SELECT Id, FirstName, LastName, Email FROM User LIMIT 1];
        
        Test.startTest();
        DatabaseResult accdata = ManageToursController.getDataForManageTours('account', lstAccounts[0].Id);
        System.assert(accdata.success);
        DatabaseResult condata = ManageToursController.getDataForManageTours('contact', lstContacts[0].Id);
        System.assert(condata.success);
        DatabaseResult oppodata = ManageToursController.getDataForManageTours('opportunity', lstOpportunities[0].Id);
        System.assert(oppodata.success);
        Test.stopTest();
    }
    
    /************************************************************************************************************************************
		Author 				:	Samadhan Kadam
		Description 		: 	This method tests verify IsValidAccountForManageTour.
		Created Date		: 	18 July 2018 
	**************************************************************************************************************************************/
    public static testMethod void verifyGetUserAndBuildingForManageTours(){
        List<Contact> lstContacts = [SELECT Id, Name, AccountId FROM Contact LIMIT 1];
        Debug.Log('lstContacts------>'+lstContacts);
        List<Building__c> lstBuildings = [SELECT Id, UUID__c, Community_Manager__c FROM Building__c LIMIT 1];
        lstBuildings[0].Community_Manager__c = lstContacts[0].Id;
        lstBuildings[0].UUID__c = 'c56c2645-1327-4035-b252-c1dc5f4c10ba7899845fgf';
        TestingUtility.updateWithAssert(lstBuildings[0]);
        
        DatabaseResult result = ManageToursController.getUserAndBuildingForManageTours((String)lstBuildings[0].Id);
        System.assertEquals(result.success, true);
        DatabaseResult result1 = ManageToursController.getUserAndBuildingForManageTours((String)lstBuildings[0].UUID__c);
        System.assertEquals(result1.success, true);
    }
}