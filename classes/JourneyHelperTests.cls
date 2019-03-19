/*****************************************************************************************************************************
  Yet to do
  1. Modularize the code into multiple method calls.
  2. Put comments for each method call to establish references.
  3. Get it reviewed from the peer team.
******************************************************************************************************************************
    Author      :  Krishana Tupe  
    Description :  This class contains the test methods of JourneyHelper class.

    History     :  --
    
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION                 DATE            ISSUE       AUTHOR                          DETAIL
    1                       30 Nov 2018      -     		Krishana Tupe                   Initial Developement    
******************************************************************************************************************************/
@isTest
public class JourneyHelperTests {
    
   /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This setup method is used to create test data for JourneyHelperTests class								
      	Created Date  		:   27 Nov 2018        
 *************************************************************************************************************************************/
    @TestSetup
    public static void testSetup(){
        SalesConsoleSettings.createSettings(); 
        List<User> lstUser = new List<User>();
        Profile weworkSysAdmin = [SELECT Id FROM Profile WHERE Name='WeWork System Administrator'];        
        lstUser.add(LeadRoutingHelperTest.getUser('testinguser1@example.com', 'testinguser1@example.com', weworkSysAdmin.Id));
        lstUser.add(LeadRoutingHelperTest.getUser('testinguser2@example.com', 'testinguser2@example.com', weworkSysAdmin.Id));
        Database.insert(lstUser);
        
        List<Campaign> lstCampaigns = new List<Campaign>();
        lstCampaigns.add(new Campaign(Name = 'Test Campaign 1', City__c = 'Chicago', State__c = 'IL', Email_Address__c = 'Building1@example.com', Type = 'Splash Event'));
        lstCampaigns.add(new Campaign(Name = 'Test Campaign 2', State__c = 'DC', City__c = 'Washington DC', Type = 'Splash Event', Email_Address__c='abc3@example.com', Lead_Owner__c =lstUser[0].Id));
        Database.insert(lstCampaigns);
    }
    
 /************************************************************************************************************************************
    Author             :   	Krishana Tupe
    Description        :   	This method is used to verify restrict duplicate journey creation,
							when duplicate lead submission with same set of information.
    Created Date       :   	26 Nov 2018   
 *************************************************************************************************************************************/ 
    @isTest
    public static void verifyRestrictDuplicateJourneyCreation(){
        LeadRoutingHelperTest.verifyDuplicateLeadInsertionWithoutCampaign();
    }
   
 /************************************************************************************************************************************
    Author            :   Krishana Tupe
    Description       :   This method is used to verify insert lead and Journey for Hold back flow(manually)
    Created Date      :   26 Nov 2018   
 *************************************************************************************************************************************/
    @isTest
    public static void verifyManualLeadInsertion(){
        LeadRoutingHelperTest.verifyManualLeadInsertion();
    }
    
 /************************************************************************************************************************************
        Author            :   Krishana Tupe
        Description       :   This method verifies bypass Lead insertion hold back logic                 
        Created Date      :   27 Nov 2018        
 *************************************************************************************************************************************/
    @isTest
    public static void verifyBypassHoldBackLeadInsertion(){
        LeadRoutingHelperTest.verifyBypassHoldBackLeadInsertion();
    }
   
 /************************************************************************************************************************************
        Author            :   Krishana Tupe
        Description       :   This method verifies Lead/journey hold back logic when lead comes from Website                 
        Created Date      :   27 Nov 2018        
 *************************************************************************************************************************************/ 
    @isTest
    public static void verifyLeadInsertionHoldBack(){
        LeadRoutingHelperTest.verifyLeadInsertionHoldBack();
    }

 /************************************************************************************************************************************
        Author            :   Krishana Tupe
        Description       :   This method verifies Lead/journey hold back logic when lead comes from Website  with campaign                
        Created Date      :   27 Nov 2018        
 *************************************************************************************************************************************/
    @isTest
    public static void verifyLeadInsertionWithCampaign(){
        LeadRoutingHelperTest.verifyLeadInsertionWithCampaign();
    }
    
 /************************************************************************************************************************************
        Author            :   Krishana Tupe
        Description       :   This method verifies Lead/journey hold back logic when lead comes from Website and contact exist                
        Created Date      :   27 Nov 2018        
 *************************************************************************************************************************************/ 
    @isTest
    public static void verifyHoldBackForExistingContact(){
        LeadRoutingHelperTest.verifyHoldBackForExistingContact();
    }
    
 /************************************************************************************************************************************
        Author            :   Krishana Tupe
        Description       :   This method verifies by pass Lead/journey hold back logic when lead created manually and contact exist                
        Created Date      :   27 Nov 2018        
 *************************************************************************************************************************************/ 
    @isTest
    public static void verifyBypassHoldBackForExistingContact(){
        LeadRoutingHelperTest.verifyBypassHoldBackForExistingContact();
    }
  
 /************************************************************************************************************************************
        Author            :   Krishana Tupe
        Description       :   This method verifies Lead/journey hold back logic when lead comes from Website with campaign and contact exist                
        Created Date      :   27 Nov 2018        
 *************************************************************************************************************************************/
    @isTest
    public static void verifyLeadExistingContactWithCampaign(){
        LeadRoutingHelperTest.verifyLeadExistingContactWithCampaign();
    }
    
}