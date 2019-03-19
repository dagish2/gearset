@isTest
public class UpdateJourneyOnCampaignMemberBatchTest {
/*    @testSetup static void setup() {
        SalesConsoleSettings.createSettings(); 
        List<Campaign>lstCampaign =new List<Campaign>();           
        for(Integer index=1;index<7;index++) {
            lstCampaign.add(new Campaign(Name = 'TestCamp'+index, Type='Event', Status='Active', Event_Email_Opt_Out__c=true, StartDate=Date.today()));
        }
        insert lstCampaign;
        
        List<Lead>lstLead =new List<Lead>();           
        for(Integer index=1;index<11;index++) {
            if(index<=5){
                lstLead.add(new Lead(FirstName='Test',LastName = 'Lead'+index,LeadSource='Event',Lead_Source_Detail__c='Book A Tour Availability',Phone='8888888888',Email='testlead'+index+'@example.com',Company='TestAccount'));
            }else{
                lstLead.add(new Lead(FirstName='Test',LastName = 'Lead'+index,Phone='1234567890',LeadSource='Event',Lead_Source_Detail__c='Book A Tour Form',Email='testlead'+index+'@example.com',Company = 'TestAccount')); 
            }           
        }
        insert lstLead;
        
        Account objAccount = new Account(Name = 'Test Account001');
        insert objAccount; 
        
        List<Contact>lstContact =new List<Contact>(); 
        for(Integer index=1;index<11;index++) {          
            lstContact.add(new Contact(AccountId=objAccount.Id,FirstName='Test',LastName = 'Contact_'+index,Email='testcontact_'+index+'_c@example.com', LeadSource ='Event'));           
        }
        insert lstContact; 
        
        List<Journey__c>lstJorneys =new List<Journey__c>();
        for(Integer index=0;index<5;index++) {          
            lstJorneys.add(new Journey__c(Name = lstLead.get(index).LastName, Status__c = 'Started', Lead_Source__c='Event', Primary_Lead__c=lstLead.get(index).Id, NMD_Next_Contact_Date__c = Date.today()));
        }
        
        for(Integer index=0;index<5;index++) {          
            lstJorneys.add(new Journey__c(Name = lstContact.get(index).LastName,Status__c = 'Started', Lead_Source__c='Event' ,Primary_Contact__c=lstContact.get(index).Id, NMD_Next_Contact_Date__c = Date.today()));
        }
        insert lstJorneys;
        
        List<CampaignMember> lstCM = new List<CampaignMember>();
        for(Integer index=0; index<5; index++) {          
            lstCM.add(new CampaignMember(CampaignId = lstCampaign.get(index).Id, LeadId = lstLead.get(index).Id ));
        }
        for(Integer index=0; index<5; index++) {  
            lstCM.add(new CampaignMember(CampaignId = lstCampaign.get(index).Id, ContactId = lstContact.get(index).Id ));
        }
        insert lstCM;
    }
    
    static testmethod void testUpdateJourneyBasedCM() {
        List<Campaign>lstCamp = [SELECT Id,Name,StartDate FROM Campaign];
        System.assertEquals(lstCamp.size(), 6);
        List<CampaignMember> lstCM = [SELECT Id,Contact.Name,Lead.Name,CreatedDate FROM CampaignMember];
        System.assertEquals(lstCM.size(), 10);
        List<Lead>lstleads=[SELECT Id,Name,LeadSource,Company,Phone,Email FROM Lead];
        System.assertEquals(lstleads.size(), 10);
        List<Account>lstAccounts=[SELECT Id,Name FROM Account];
        System.assertEquals(lstAccounts.size(), 2, 'It creates two accounts first is Org and second is under that org');
        List<Contact>lstContacts=[SELECT Id,Name,Email,Account.Name FROM Contact];
        System.assertEquals(lstContacts.size(), 10);
        List<Journey__c>lstJourneys=[SELECT Id,Name,Email__c,Status__c,CreatedDate FROM Journey__c];
        System.assertEquals(10, lstJourneys.size());
        Test.startTest();
        Id batchId = Database.executeBatch(new UpdateJourneyOnCampaignMemberBatch(),100);
        System.assertNotEquals(batchId, null);
        Test.stopTest();
        List<Journey__c>lstResultJourneys = [SELECT Id,Name,Email__c,Status__c,Primary_Contact__c,Primary_Lead__c,CreatedDate FROM Journey__c WHERE Status__c='Completed'];
        System.debug('lstResultJourneys==>'+lstResultJourneys.size());
        System.assertEquals(10,lstResultJourneys.size());
        
    }
*/    
    
}