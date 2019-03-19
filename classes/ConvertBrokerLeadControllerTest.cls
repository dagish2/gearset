/************************************************************************************************************************************
   	Author 		: Ashish Mishra
   	Description : This class Contains Unit Test Methods of ConvertBrokerLeadController

   	History		:
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE				AUTHOR				DETAIL
	1			22 Aug 2018			Ashish Kumar 		Initial Developement
**************************************************************************************************************************************/
@isTest
public class ConvertBrokerLeadControllerTest {
    @TestSetup
    static void initData(){
        SalesConsoleSettings.createSettings();
        
        Lead objLead = new Lead();        
        objLead.LastName = 'lastName';       
        objLead.Email = 'lastName@enazigma.com'; 
        objLead.Phone = '1234567891';
        objLead.Company = 'Test Company';
        objLead.Locations_Interested__c='Test Building Tour';
        objLead.LeadSource= 'Broker';
        objLead.Lead_Source_Detail__c = 'Broker1';        
        insert objLead;
        
        Map<String, Object> mapFieldsForAccount = new Map<String, Object>();
        mapFieldsForAccount.put('Name', 'TestAccount');
        mapFieldsForAccount.put('Lighthouse_Account__c', true);
        Account testAccount = TestingUtility.createAccount(mapFieldsForAccount, true);
        TestingUtility.getRecords(new Map<string, object>{'objName'=>'Journey', 'numberOfRecords'=>1, 'doInsert'=> true});
    }    
    
   /************************************************************************************************************************************
        Author 				: Ashish Mishra
        Description 		: When Lead Source and Lead Source Details are not Match with given criteria and give a error msg (from SaleConcoleSetting-RestrictOpportunityCreation)
        Last Created By		: 22 Aug 2018
        Last Modified By	: -
	**************************************************************************************************************************************/
    public static testMethod void verifyBrokerLeadtestscenario1() {
        //When Lead Source and Lead Source Details are not Match with given criteria (from SaleConcoleSetting)
        Lead objLead = [SELECT Id,Email FROM Lead WHERE Email = 'lastName@enazigma.com'];
        System.debug('objLead==>'+objLead);
        System.assert(objLead.id!= null);
        
        DatabaseResult result = ConvertBrokerLeadController.verifyBrokerLead(objLead.id, false, objlead, '', false);
        System.assertEquals(false,result.success);
        System.assertNotEquals(result.message,null);        
    }
    /************************************************************************************************************************************
        Author 				: Ashish Mishra
        Description 		: When Lead Source and Lead Source Details are Match with given criteria then it should be successfully validated.
								(from SaleConcoleSetting-RestrictOpportunityCreation)
        Last Created By		: 22 Aug 2018
        Last Modified By	: -
	**************************************************************************************************************************************/
    public static testMethod void verifyBrokerLeadtestscenario2() {
        //When Lead Source and Lead Source Details are Match with given criteria (from SaleConsoleSetting)
        Account objAccount = new Account(Name='Example', Unomy_Company_ID__c = 11111, Lead_Source__c='LeadSource1',Account_Type__c='Org');
        insert objAccount;
        Contact objContact = new Contact(FirstName='John',LastName='Smith',Email='john.smith@example.com',AccountId=objAccount.Id);
        insert objContact;
        Lead objLead = [SELECT Id,Email FROM Lead WHERE Email = 'lastName@enazigma.com'];        
        objLead.LeadSource = 'Partner Referral';
        objLead.Lead_Source_Detail__c = 'Community Registration';  
        objLead.Referrer__c = objContact.Id;
        update objLead;
        
        System.debug('objLead verifyBrokerLeadtestscenario2==>'+objLead);
        System.assert(objLead.id!= null);
        
        DatabaseResult result = ConvertBrokerLeadController.verifyBrokerLead(objLead.id, false, objlead, '', false);
        System.assertEquals(true,result.success);
    }
    
    /************************************************************************************************************************************
        Author 				: Ashish Mishra
        Description 		: When Lead Source and Lead Source Details are Match with given criteria and opportunity should not be created.
								(from SaleConcoleSetting-RestrictOpportunityCreation)
        Last Created By		: 22 Aug 2018
        Last Modified By	: - 
	**************************************************************************************************************************************/
    public static testMethod void verifyBrokerLeadtestscenario3() {
        //When Lead Source and Lead Source Details are not Match with given criteria (from SaleConcoleSetting)
        Account objAccount = new Account(Name='Example', Unomy_Company_ID__c = 11111, Lead_Source__c='LeadSource1',Account_Type__c='Org');
        insert objAccount;
        Contact objContact = new Contact(FirstName='John',LastName='Smith',Email='john.smith@example.com',AccountId=objAccount.Id);
        insert objContact;
        Lead objLead = [SELECT Id,Email FROM Lead WHERE Email = 'lastName@enazigma.com'];         
        objLead.LeadSource= 'Partner Referral';
        objLead.Lead_Source_Detail__c = 'Community Registration';        
        objLead.Referrer__c=objContact.Id;
        update objLead;
        List<Journey__c> lstJourney = [SELECT Id FROM Journey__c WHERE Primary_Lead__c = :objLead.Id LIMIT 1];
        String journeyId;
        if(lstJourney.size() > 0)
            journeyId = lstJourney[0].Id;
        System.debug('objLead==>'+objLead);
        System.assert(objLead.id!= null);
        
        DatabaseResult result = ConvertBrokerLeadController.verifyBrokerLead(null,true,null,'',false);
        System.assertEquals(false,result.success);
        
        result = ConvertBrokerLeadController.verifyBrokerLead(objLead.id,true,objlead,journeyId,false);
        System.assertEquals(true,result.success);
    }
     
    public static testMethod void testGetJourneyToUpdate() {
        List<Lead> lstLead = [SELECT Id,Email FROM Lead WHERE Email = 'lastName@enazigma.com'];  
        System.assertNotEquals(0, lstLead.size());
        DatabaseResult result = ConvertBrokerLeadController.getJourneyToUpdate(lstLead[0].Id);
        System.assertEquals(true,result.success);
        List<Journey__c> lstJourney = (List<Journey__c>)result.Data;
        System.assertNotEquals(0, lstJourney.size());
    }
    /************************************************************************************************************************************
        Author          : Chandra Teja
        Description     : This Method is used to test save journey method which will decide whether to send email to account owner or not after clicking journey handoff button 
        Created Date    : 1 February 2019
        Issue No        : ST-3285
    **************************************************************************************************************************************/
    @isTest
    public static void testSaveJourney(){
        List<Account> lstAccounts = [SELECT Id, Name, Lighthouse_Account__c  FROM Account WHERE Lighthouse_Account__c = true];
        List<Journey__c> lstJourneys = [SELECT Id, Primary_Contact__c, Primary_Contact__r.Id FROM Journey__c WHERE Primary_Contact__c != null];
        UPDATE new Contact(Id = lstJourneys[0].Primary_Contact__c, AccountId= lstAccounts[0].Id);
        Test.startTest();
        DatabaseResult saveJourneyresult = ConvertBrokerLeadController.saveJourney(lstJourneys[0]);
        System.assertEquals(1, Limits.getEmailInvocations());
        Test.stopTest();
        DatabaseResult saveJourneyresult1 = ConvertBrokerLeadController.saveJourney(null); 
    }
    /************************************************************************************************************************************
        Author          : Chandra Teja
        Description     : This Method is used to test query results according to labels
        Created Date    : 1 February 2019
        Issue No        : ST-3285
    **************************************************************************************************************************************/
    @isTest
    public static void testGetQueryResultForLabel(){
        DatabaseResult GetQueryResultForLabel = ConvertBrokerLeadController.getQueryResultForLabel('journeyDetails', new Map<String, Object>{'journeyId'=>null});
        system.assertNotEquals(null, GetQueryResultForLabel);
    }
}