@isTest
public class SFMCRepliesControllerTest {
	static {
        SalesConsoleSettings.createSettings();
		Profile testProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User testUser = new User(Alias = 'testU', Email='testUser_1@example.com', 
            EmailEncodingKey='UTF-8', LastName='User', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = testProfile.Id, IsActive = true,
            TimeZoneSidKey='America/Los_Angeles', UserName='testUserName_1@example.com',
            CommunityNickname = TestingUtility.createUserCommunityName());
        insert testUser;
    }
    
    @isTest
    static void testGetSettingsData(){
        SFMCRepliesController.SFMCRepliesSetting setting = SFMCRepliesController.getSettingsData();
        Debug.log('setting : '+setting);
        
    }
    
    @isTest
    static void testReadCSV(){
        Account accRec = new Account(Name='Test Account');
      	insert accRec;
        Debug.log('accRec : '+accRec);
        
      	Contact conRec = new Contact(
      	AccountId =  accRec.Id,  
        firstname = 'TestFirstName',
        lastname = 'TestLastName',
        email = 'testEmail@example.com',
        Status__c = 'active'                       
        );
        insert conRec;
        Debug.log('conRec : '+conRec);
        
        
        Map<String, Id> oppRecordType = TestingUtility.getRecordTypeMapByName(Opportunity.sObjectType);
        Debug.log('oppRecordType : '+oppRecordType);
        
        Opportunity oppRec = TestingUtility.createOpportunity(accRec.Id, false);
        oppRec.Primary_Member__c = conRec.Id;
        oppRec.StageName = 'Qualifying';
        oppRec.CloseDate = system.today().addDays(5);
        oppRec.RecordTypeId = oppRecordType.get('Consumer');
        TestingUtility.insertWithAssert(oppRec);
        Debug.log('oppRec : '+oppRec);
        
        Tour_Outcome__c tourRec = new Tour_Outcome__c();
        tourRec.Primary_Member__c = conRec.Id;
        tourRec.Status__c = 'Inquiry';
        tourRec.Tour_Date__c = system.today().addDays(4);
        tourRec.Opportunity__c = oppRec.Id;
        TestingUtility.insertWithAssert(tourRec);
        Debug.log('tourRec : '+tourRec);
        
        Datetime tourDate = Datetime.now().addDays(-10);
		Test.setCreatedDate(tourRec.Id, tourDate);
        
        Tour_Outcome__c tourRec1 = new Tour_Outcome__c();
        tourRec1.Primary_Member__c = conRec.Id;
        tourRec1.Status__c = 'Inquiry';
        tourRec1.Tour_Date__c = system.today().addDays(4);
        tourRec1.Opportunity__c = oppRec.Id;
        TestingUtility.insertWithAssert(tourRec1);
        Debug.log('tourRec1 : '+tourRec1);
        
        List<String> lstEmails = new List<String>();
        lstEmails.add(conRec.Email);
        
        
        List<SFMCRepliesController.Request> lstRequests = new List<SFMCRepliesController.Request>();
        Datetime dt = Datetime.now().addDays(-5);
    	SFMCRepliesController.Request req = new SFMCRepliesController.Request();        
        req.emailId = conRec.Email;
        req.emailCount = 1;
        req.dateSent = dt.format('MM/dd/yyyy hh:mm a');        
        Debug.log('req : '+req);
        lstRequests.add(req);
        SFMCRepliesController.Request req2 = new SFMCRepliesController.Request();        
        req2.emailId = conRec.Email;
        req2.emailCount = 1;
        req2.dateSent = null;        
        Debug.log('req2 : '+req2);
        lstRequests.add(req2);
        Debug.log('lstRequests : '+lstRequests);
        
        try{
            List<String> csvResult = SFMCRepliesController.readCSV(lstRequests);
        	Debug.log('csvResult : '+csvResult);
        }catch(Exception exc){
            
        }
    }
    
    @isTest
    static void testSendAttachment(){
        Account accRec = new Account(Name='Test Account');
      	insert accRec;
        Debug.log('accRec : '+accRec);
        
      	Contact conRec = new Contact(
      	AccountId =  accRec.Id,  
        firstname = 'TestFirstName',
        lastname = 'TestLastName',
        email = 'testAtt@example.com',
        Status__c = 'active'                       
        );
        insert conRec;
        
        Attachment attach=new Attachment();   	
    	attach.Name='Unit Test Attachment';
    	Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
    	attach.body=bodyBlob;
        attach.parentId=conRec.id;
        insert attach;
        Debug.log('attach : '+attach);
        Boolean result;
        try {            
            result = SFMCRepliesController.sendAttachment(attach.Id, false);
            Debug.log('result : '+result);
        } catch(Exception exc){
            
        }       
        Debug.log('result : '+result);
    }
}