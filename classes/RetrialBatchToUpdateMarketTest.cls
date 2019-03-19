/************************************************************************************************************************************
	Author		: 	Krishana Tupe
	Description	: 	This batch class handle Geography insertion using google api account update related market on Account record.
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE	        		AUTHOR                     	DETAIL
	1	    	28 January 2018			Krishana Tupe           	Initial Developement	
**************************************************************************************************************************************/
@isTest
public class RetrialBatchToUpdateMarketTest {
    
 /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is used to crete the Test data for this Test class
        Created Date  		:   23 January 2019	
		Issue No.			:	ST-3343
  **************************************************************************************************************************************/    
    @TestSetup
    public static void initData(){
        SalesConsoleSettings.createSettings();
    }
    
    
    /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method returns the Accounts
        Created Date  		:   23 January 2019	
		Issue No.			:	ST-3343
  **************************************************************************************************************************************/    
    public static List<Account> getAccounts(List<Account> lstAccounts, Integer size){
        for(Integer iIndex = 0; iIndex < size; iIndex++){
            lstAccounts.add(new Account(Name='Master Account'+iIndex, Update_HQ_Market_Status__c ='Retry Round 1', Unomy_Company_ID__c = 123456+iIndex, Unomy_Updated_DateTime__c = Date.today(), Lead_Source__c = 'Test'+iIndex, Account_Type__c = 'Org', Unomy_Location_Address__c = 'USA', Unomy_Location_City__c = 'Seattle', Unomy_Location_State__c = 'Washington', Unomy_Location_Country__c = 'USA', BillingStreet = 'Washington', BillingCity = 'Seattle', BillingState = 'Washington', BillingCountry = 'USA')); 
        }
        return lstAccounts;
    }    
     
  /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method returns the Leads
        Created Date  		:   23 January 2019	
		Issue No.			:	ST-3343
  **************************************************************************************************************************************/    
    public static List<Lead> getLeads(List<Lead> lstLeads, Integer size){
        for(Integer iIndex = 0; iIndex < size; iIndex++){
            lstLeads.add(new Lead(LeadSource='WeWork.com', Lead_Source_Detail__c='TEST LEAD SOURCE '+iIndex, LastName = 'Doe '+iIndex, 
                                  FirstName = 'John', Email = 'johndoe1582018_1'+iIndex+'@example.com', Office_Type__c = 'Daily Desk', 
                                  Status = 'Open', Locations_Interested__c = 'Test Building Tour', Company = 'Enzigma ltd', 
                                  Generate_Journey__c = true, Number_of_Full_Time_Employees__c = 15, Update_HQ_Market_Status__c ='Retry Round 1',
                                  Unomy_Location_Address__c = 'USA', Unomy_Location_City__c = 'Seattle', Unomy_Location_State__c = 'Greenland', Unomy_Location_Country__c = 'USA',
                                  Unomy_Updated_DateTime__c = System.today()));    
        }
        return lstLeads;
    }    
    
  /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method verifies the Lead records on which we need to find and update market (Retrial Batch).
        Created Date  		:   23 January 2019	
		Issue No.			:	ST-3343
  **************************************************************************************************************************************/  
   @isTest
    public static void verifyUpdateMarketOnLeadSuccess(){   
        Test.setMock(HttpCalloutMock.class, new QueueInsertGeoForBuildingMockRes());
        Id marketId = BatchToUpdateMarketTest.createMarketData();
        RESTInboundLeadAPIHelper.isLeadFromWeb  = true;
        List<Lead> lstLeads = new List<Lead>();
        RetrialBatchToUpdateMarketTest.getLeads(lstLeads,5);       
        Database.insert(lstLeads, false);
        List<Lead> lstLeadsResult = [SELECT Id, Name, Email, Update_HQ_Market_Status__c, Lead_Demographic_Score_Re_calculate__c, Lead_Demographic_Score__c, Lead_Processing_Stage__c, Processing_Stage__c, Lead_Market__c FROM Lead WHERE Id IN : lstLeads AND isConverted = FALSE];
        BatchToUpdateMarketTest.verifyAssertions(lstLeadsResult, 'Pending', 'Created', '5');       
        for(Lead objLead : lstLeadsResult){
            objLead.Update_HQ_Market_Status__c ='Retry Round 1';           
        }
        Database.update(lstLeadsResult, false);
        Test.startTest();
        System.schedule('Update Market on Lead batch', '0 0 0 3 9 ? 2022', new ScheduleBatchToUpdateMarketOnLead());
        Database.executeBatch(new RetrialBatchToUpdateMarket('Lead'));
        Test.stopTest();
        lstLeadsResult = [SELECT Id, Name, Email, Update_HQ_Market_Status__c, Lead_Demographic_Score_Re_calculate__c, Lead_Demographic_Score__c, Lead_Processing_Stage__c, Processing_Stage__c, Lead_Market__c FROM Lead WHERE Id IN : lstLeads AND isConverted = FALSE];
        BatchToUpdateMarketTest.verifyAssertions(lstLeadsResult, 'Completed', 'Market Identified', '5');
        for(Lead objLead : lstLeadsResult){
            System.assertEquals(marketId, objLead.Lead_Market__c);
        }        
    }
    
   /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method verifies the Account records on which we need to find and update market (Retrial Batch).
        Created Date  		:   23 January 2019	
		Issue No.			:	ST-3343
  **************************************************************************************************************************************/  
   @isTest
    public static void verifyUpdateMarketOnAccountSuccess(){   
        Test.setMock(HttpCalloutMock.class, new QueueInsertGeoForBuildingMockRes());
        Id marketId = BatchToUpdateMarketTest.createMarketData();      
        List<Account> lstAccounts = new List<Account>();
        getAccounts(lstAccounts,5);       
        Database.insert(lstAccounts, true);
        List<Account> lstAccountInserted = [SELECT Id, Processing_Stage__c, Account_Market__c, Unomy_Company_ID__c, Geography__c, Market_Identified_On__c, Update_HQ_Market_Status__c FROM Account WHERE Id IN : lstAccounts];
        for(Account objAccount : lstAccountInserted){
            objAccount.Update_HQ_Market_Status__c = 'Retry Round 1';   
        }
        update lstAccountInserted;
        Test.startTest();       
        System.schedule('Update Market on Account batch', '0 0 0 3 9 ? 2022', new ScheduleBatchToUpdateMarketOnAccount());
        Database.executeBatch(new RetrialBatchToUpdateMarket('Account'));
        Test.stopTest();
        lstAccountInserted = [SELECT Id, Processing_Stage__c, Account_Market__c, Unomy_Company_ID__c, Geography__c, Market_Identified_On__c, Update_HQ_Market_Status__c FROM Account WHERE Id IN : lstAccountInserted];
        for(Account objAccount : lstAccountInserted){
            System.assertEquals(marketId, objAccount.Account_Market__c);
            System.assertNotEquals(NULL, objAccount.Geography__c);
            System.assertEquals('Completed', objAccount.Update_HQ_Market_Status__c);
        }        
    }
}