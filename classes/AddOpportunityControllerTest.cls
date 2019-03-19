/************************************************************************************************************************************
    Author      :   Priyanka Ambre
    Description :   This class contain all test methods related to AddOpportunityController class.
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1           30 Oct 2018         Priyanka Ambre          Initial Developement
	2           31 Oct 2018         Krishana Tupe         	Code Optimization
	3			10 Jan 2019			Prashant Mane			Added Test Mathods.
**************************************************************************************************************************************/
@isTest
public class AddOpportunityControllerTest {
    public static List<Lead> lstLeads = new List<Lead>(); 
    public static List<Account> lstAccounts = new List<Account>(); 
    public static List<Contact> lstContacts = new List<Contact>(); 
    public static List<Journey__c> lstJourneys = new List<Journey__c>();
    public static List<Building__c> lstBuildings = new List<Building__c>();
    public static List<Opportunity> lstOpportunities = new List<Opportunity>();
    
 /****************************************************************************************************************************
        Author              : Krishana Tupe
        Description         : This Test setup method used to create test data for this class.
        Created Date        : 31 Oct 2018
  *****************************************************************************************************************************/
    @TestSetup
    static void initData(){
        SalesConsoleSettings.createSettings();
        //Account
        Account objOrgAccRec1 = new Account(Name = 'orgAccRec', Number_of_Full_Time_Employees__c = 1000, Account_Type__c = 'Org', Unomy_Company_Name__c = 'orgAcc1');
        TestingUtility.insertWithAssert(objOrgAccRec1);    
        //Lead
        Lead objLead1 = new Lead(LastName = 'Doe', FirstName = 'John', Email = 'john.smith1@example.com', Company = 'WeWork Inc', Generate_Journey__c = true, Account__c = objOrgAccRec1.Id);  
        TestingUtility.insertWithAssert(objLead1); 
        //Contact
        Contact objContact1 = new Contact(firstname = 'John',lastname = 'Rambo',email = 'john.con1@example.com', AccountId = objOrgAccRec1.Id, Status__c = 'active');
        TestingUtility.insertWithAssert(objContact1); 
        //Journeys
        lstJourneys.add(new Journey__c(Name = objContact1.LastName, Primary_Contact__c = objContact1.Id, Status__c = 'Started', Primary_Email__c = objContact1.Email, NMD_Next_Contact_Date__c = Date.today()));        
        lstJourneys.add(new Journey__c(Name = objLead1.LastName, Primary_Lead__c = objLead1.Id, Status__c = 'Started', Primary_Email__c = objLead1.Email, NMD_Next_Contact_Date__c = Date.today()));        
        TestingUtility.insertListWithAssert(lstJourneys);
        //Building
        Building__c objBuilding1 = new Building__c(Name = 'Building1', UUID__c = '15318_1', Email__c = 'Building1@example.com'); 
        TestingUtility.insertWithAssert(objBuilding1);
        //Opportunity
        Opportunity objOpportunity = new Opportunity(Do_Not_Create_Opportunity_Role__c = true, AccountId = objContact1.AccountId, LeadSource = 'WeWork.com', Owner_Auto_Assign__c = true, 
                                                     StageName = 'Qualifying', Decision_Maker__c = null, Primary_Member__c = objContact1.Id, Interested_in_Number_of_Desks__c = 0,
                                                     Building__c = objBuilding1.Id, CloseDate = system.today().addDays(5),Journey__c = lstJourneys[0].Id);  
        TestingUtility.insertWithAssert(objOpportunity);		   
    }
    
 /****************************************************************************************************************************
        Author              : Priyanka Ambre
        Description         : This method tests the getAddOpportunityData() function.
        Created Date        : 31 Oct 2018
   *****************************************************************************************************************************/
    public static testmethod void verifyGetAddOpportunityData(){
        lstJourneys = [SELECT  Name, Primary_Contact__c , Status__c, Primary_Email__c, Primary_Lead__c, Unomy_Company_Name__c FROM Journey__c];
        Journey__c objLeadJourey = getRelatedJourney(lstJourneys, true); 
        String strJourneyData = (String)AddOpportunityController.getAddOpportunityData(objLeadJourey.Id).data;
        AddOpportunityController.AddOpportunityData  objAddOpportunityData = (AddOpportunityController.AddOpportunityData)JSON.deserialize(strJourneyData, AddOpportunityController.AddOpportunityData.class);        
        System.assertNotEquals(null, objAddOpportunityData.journeyRecord);
        System.assertEquals(objLeadJourey.Id, objAddOpportunityData.journeyRecord.Id);
        System.assertNotEquals(null, objAddOpportunityData.currentUserProfile);       
        DatabaseResult result = AddOpportunityController.getAddOpportunityData(null);
        System.assertEquals(null, result.data);
        System.assert(String.valueOf(result.message).contains('Please provide journey Id'));        
    } 
    
 /****************************************************************************************************************************
        Author              : Priyanka Ambre
        Description         : This method tests the getJourneyOpportunityData() function.
        Created Date        : 31 Oct 2018
   *****************************************************************************************************************************/
     public static testmethod void verifyGetJourneyOpportunityData(){
            lstAccounts = [SELECT Id, Name, UUID__c, Unomy_Company_Name__c, Account_Type__c, ParentId, Parent_Org_Id__c FROM Account];
            lstContacts = [SELECT LastName, FirstName, UUID__c, Account_Name__c, Unomy_Company_Name__c, AccountId, Email FROM Contact];
            lstLeads = [SELECT LastName, FirstName, Company, Generate_Journey__c, Account__c FROM Lead];
            lstJourneys = [SELECT  Name, Primary_Contact__c , Status__c, Primary_Email__c, Primary_Lead__c, Unomy_Company_Name__c FROM Journey__c];
            
            Journey__c objContactJourney = getRelatedJourney(lstJourneys, false);
            Map<String, String> mapOpportunityData = new Map<String, String>();
            mapOpportunityData.put('accountId', lstAccounts[0].Id);
            mapOpportunityData.put('contactId', lstContacts[0].Id);
            mapOpportunityData.put('leadId', lstLeads[0].Id);
            mapOpportunityData.put('journeyId', objContactJourney.Id);
            
            String strGetJourneyOpportunityDataResponse = (String)AddOpportunityController.getJourneyOpportunityData(mapOpportunityData).data; 
            Map<String, Object> mapResponse = (Map<String, Object>)JSON.deserializeUntyped(strGetJourneyOpportunityDataResponse);       
            validateAsserts(((Map<String, Object>)mapResponse.get('contact')), lstContacts[0].Id);
            validateAsserts(((Map<String, Object>)mapResponse.get('account')), lstAccounts[0].Id);
            validateAsserts(((Map<String, Object>)mapResponse.get('lead')), lstLeads[0].Id);
            validateAsserts(((Map<String, Object>)mapResponse.get('journey')), objContactJourney.Id);    
            validateAsserts(((Map<String, Object>)mapResponse.get('opportunityRecordTypes')), null);  
            validateAsserts(((Map<String, Object>)mapResponse.get('accountRecordTypes')), null); 
            validateAsserts(((Map<String, Object>)mapResponse.get('mapBuildings')), null); 
             
            DatabaseResult result = AddOpportunityController.getJourneyOpportunityData(null);
            System.assertEquals(null, result.data);
            System.assert(String.valueOf(result.message).contains('Parameter should not be blank')); 
        }
        
 /****************************************************************************************************************************
     Author              : Priyanka Ambre
     Description         : This method is used to verify getQueryData() method of AddOpportunityController class.
     Created Date        : 31 Oct 2018
   *****************************************************************************************************************************/   
    public static testmethod void verifyGetQueryData(){
        lstAccounts = [SELECT Id, Name, UUID__c, Unomy_Company_Name__c, Account_Type__c, ParentId, Parent_Org_Id__c FROM Account];
        lstOpportunities = [SELECT Id, Name, AccountId, Primary_Member__c, Building__c FROM Opportunity];
        lstContacts = [SELECT LastName, FirstName, UUID__c, Account_Name__c, Unomy_Company_Name__c, AccountId, Email FROM Contact];
        lstJourneys = [SELECT  Name, Primary_Contact__c , Status__c, Primary_Email__c, Primary_Lead__c, Unomy_Company_Name__c FROM Journey__c];       
        Journey__c objContactJourney = getRelatedJourney(lstJourneys, false);        
        List<Opportunity> lstJourneyRelatedOpportunities = (List<Opportunity>)AddOpportunityController.getQueryData('getJourneyRelatedOpportunities', objContactJourney.Id, lstContacts[0].Id, null).data;
        System.assertNotEquals(null, lstJourneyRelatedOpportunities);
        System.assertNotEquals(0, lstJourneyRelatedOpportunities.size());
        System.assertEquals(lstOpportunities[0].Id, lstJourneyRelatedOpportunities[0].Id);
        
        List<Account> lstAccountResponse = (List<Account>)AddOpportunityController.getQueryData('getAccountRecord', null, null, lstAccounts[0].Id).data;
        System.assertNotEquals(null, lstAccountResponse);
        System.assertNotEquals(0, lstAccountResponse.size());
        System.assertEquals(lstAccounts[0].Id, lstAccountResponse[0].Id);
        
        DatabaseResult result = AddOpportunityController.getQueryData('returnNull', null,  null, null);
        System.assertEquals(null, result);
        result = AddOpportunityController.getQueryData(null, null, null,null);
        System.assertEquals(null, result.data);
        System.assert(String.valueOf(result.message).contains('Please provide queryLable'));
    }
    
 /****************************************************************************************************************************
        Author              : Krishana Tupe
        Description         : This method is returns the related journey of Lead or Contact.
        Created Date        : 31 Oct 2018
   *****************************************************************************************************************************/   
  public static Journey__c getRelatedJourney(List<Journey__c> lstJourneys, Boolean isFromLead){         
        for(Journey__c objJourney : lstJourneys){
            if(objJourney.Primary_Lead__c != null && isFromLead){
                return objJourney;               
            }else if(!isFromLead){
                return objJourney;
            }
        }
        return null;
    }
    
 /****************************************************************************************************************************
        Author              : Krishana Tupe
        Description         : This method is used to validate the assertions of  verifyGetJourneyOpportunityData method functionality.
        Created Date        : 31 Oct 2018
 *****************************************************************************************************************************/
    public static void validateAsserts(Map<String, Object> mapResponse , Id recordId){ 
        if(String.isNotBlank(recordId)){           
            System.assertEquals(recordId, mapResponse.get('Id'));  
        }else{
            System.assert(mapResponse != null); 
        }       
    }
    
/****************************************************************************************************************************
        Author              : Krishana Tupe
        Description         : This method is used to verfiy the the addOpportunity functionality.
        Created Date        : 31 Oct 2018
 *****************************************************************************************************************************/  
    public static testMethod void verifyAddOpportunity(){
        lstContacts = [SELECT LastName, FirstName, UUID__c, Account_Name__c, Unomy_Company_Name__c, AccountId, Email FROM Contact];
        Opportunity objOpportunity = new Opportunity(AccountId = lstContacts[0].AccountId, LeadSource = 'WeWork.com', Owner_Auto_Assign__c = true, 
                                                     StageName = 'Tour Scheduled', Primary_Member__c = lstContacts[0].Id, Interested_in_Number_of_Desks__c = 0,
                                                     CloseDate = system.today().addDays(5));         
        Map<String,Object> mapAddOpportunityData = new Map<String,Object>();
        mapAddOpportunityData.put('Primary_Member__c',objOpportunity.Primary_Member__c); 
        String strResult = (String)AddOpportunityController.insertAddOpportunity(mapAddOpportunityData).data; 
        Map<String, Object> mapResponse = (Map<String, Object>)JSON.deserializeUntyped(strResult); 
        Debug.log('mapResponse==>'+mapResponse);
        Debug.log('mapResponse==>'+mapResponse.get('id'));
        System.assert(String.valueOf(mapResponse.get('id')).startsWith('006'));  
        System.assertEquals(true, mapResponse.get('success'));   
        
        DatabaseResult result = AddOpportunityController.insertAddOpportunity(null);
        System.assertEquals(null, result.data);
        System.assert(String.valueOf(result.message).contains('Parameter should not be blank'));
    }
    
}