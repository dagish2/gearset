/************************************************************************************************************************************
    Author 		: 	Sunil Bhosale	
    Description : 	This class contains  test methods for CampaignServices class.
    Date 		:	10 April 2018
	Comment		:	Code is commeneted as this class is depricated
	Code commented by : Sunil b.		
    **************************************************************************************************************************************/
@isTest	
public class CampaignServicesTest {
   /* static{
        SalesConsoleSettings.createSettings();
        List<User> lstUser = new List<User>();
        Profile p1 = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u1 = new User(Alias = 'testU', Email='testUserName1@example.com', 
                           EmailEncodingKey='UTF-8', LastName='User', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p1.Id, IsActive = true,
                           TimeZoneSidKey='America/Los_Angeles', UserName='testUserName1@example.com',CommunityNickname = TestingUtility.createUserCommunityName());
        lstUser.add(u1);
        
        TestingUtility.insertListWithAssert(lstUser);
        List<Building__c> lstBuildings = new List<Building__c>();
        Building__c Building1 = new Building__C();
        Building1.Name =  'Building15318_1';
        Building1.UUID__c = '15318_1';
        Building1.Email__c = 'Building1@example.com'; 
        lstBuildings.add(Building1);
        TestingUtility.insertListWithAssert(lstBuildings); 
        SalesConsoleSettings.createSplashEventJourney();
    }
    public static testMethod void verifyinsertCampaignMember() {
   
        List<Campaign> lstCampaign = new List<Campaign>(); 
        List<Lead> lstLead = new List<Lead>();  
        Campaign campaign1 = new Campaign(Name = 'Test Campaign1', StartDate = Date.today(), Type = '', Email_Address__c = 'Building1@example.com');
        lstCampaign.add(campaign1);
        insert lstCampaign;
        System.assertNotEquals(null, lstCampaign[0].Id, 'campaign not inserted');
        Lead lead1 = new Lead(FirstName = 'John', LastName = 'Smith', Company = 'Test Company', Email='testLead1@example.com' ,phone = '9168200192');
        lstLead.add(lead1);
        insert lstLead;
        System.assertNotEquals(null, lstLead[0].Id, 'lead not inserted');
        CampaignMember campaignMember1 = new CampaignMember();
        campaignMember1.LeadId = Lead1.Id;
        campaignMember1.CampaignId = campaign1.Id;
        insert campaignMember1;
        System.assertNotEquals(null, campaignMember1.Id, 'campaign member not inserted');
        Debug.log('campaign1---'+campaign1);
        Debug.log('lead1.Email---'+lead1.Email);
        RESTInboundLeadAPI.Response leadResponse = CampaignServicesTest.insertLeadInCampaign(campaign1,lead1.Email);
        List<campaignMember> lstcampaignMember = new List<campaignMember>();
        lstcampaignMember = [select id,Email from CampaignMember where campaignId = : campaign1.Id];
        System.assertEquals(1, lstcampaignMember.size());        
    }
    
    public static RESTInboundLeadAPI.Response insertLeadInCampaign(campaign campaign1,String leadEmail){
        Map<String,Object> mapData = new Map<String,Object>();
        mapData.put('first_name','John');
        mapData.put('last_name','Smith');
        mapData.put('email',leadEmail);
        mapData.put('phone','9168200192');
        mapData.put('company_name','Test Company');
        mapData.put('company_size','5-10 desks');
        mapData.put('lead_source','WeWork.com');
        mapData.put('lead_source_detail','Book a Tour Form');
        mapData.put('campaign_sfid',(campaign1.Id != null?string.valueOf(campaign1.Id):''));
        RESTInboundLeadAPI.Response leadResponse = WeWorkValidatorHelper.insertInboundLead(mapData);        
        return leadResponse;
       // WeWorkValidatorAssertions.verifyLeadCreation(mapData);
      //if(leadResponse != null){
         //   System.assertEquals(true,leadResponse.success,'Failed to create inbound lead, Error: '+leadResponse.message);
       // }
    }*/
}