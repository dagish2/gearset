@isTest
private class Email2LeadTest {
    static LeadConvertor.JourneySettings settingJourney;
    @TestSetup
    static void initData(){
        SalesConsoleSettings.createSettings();
        delete [SELECT Id FROM Setting__c WHERE Name IN ('Lead:Lead and Lead Source Details','User/Queue Journey Creation')];
        Setting__c testSettings = new Setting__c();
        testSettings.Name = 'Lead:Lead and Lead Source Details';
        testSettings.Data__c = '{"LeadSource":[{"name":"Inbound Email","OverrideLeadSoruce":false},{"name":"Test Broker","OverrideLeadSoruce":true}], "LeadSourceDetails":["Broker1","Broker2", "joinus@wework.com" ]}';
        TestingUtility.insertWithAssert(testSettings);
        
        Profile weworkSystemAdmin = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        Map<String,Object> userRecordMap = new Map<String,Object>();
        userRecordMap.put('LastName','Last Name 1');
        userRecordMap.put('Username','testweworkuser1@example.com');
        userRecordMap.put('Email','testweworkuser1@example.com');
        User testUser = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, userRecordMap, true); 
        
        userRecordMap = new Map<String,Object>();
        userRecordMap.put('LastName','Last Name 2');
        userRecordMap.put('Username','testweworkuser2@example.com');
        userRecordMap.put('Email','testweworkuser2@example.com');
        User testUser1 = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, userRecordMap, true); 
        
        //Create a queue
        List<Group> lstTestGroup = new List<Group>();
        Group testGroup = new Group ();
        testGroup.Name = 'Test Lead Queue';
        testGroup.Type = 'Queue';
        lstTestGroup.add(testGroup);
        
        testGroup = new Group ();
        testGroup.Name = 'Test Lead Queue1';
        testGroup.Type = 'Queue';
        lstTestGroup.add(testGroup);
        
        insert lstTestGroup;
        
        System.runAs(new User(Id=UserInfo.getUserId())){
            List<QueueSObject> lstQueueSobject = new  List<QueueSObject>(); 
            QueueSObject testQueue = new QueueSObject();
            testQueue.QueueId = lstTestGroup[0].Id;
            testQueue.SObjectType = 'Lead';
            lstQueueSobject.add(testQueue);
            
            testQueue = new QueueSObject();
            testQueue.QueueId = lstTestGroup[0].Id;
            testQueue.SObjectType = 'Journey__c';
            lstQueueSobject.add(testQueue);
            
            testQueue = new QueueSObject();
            testQueue.QueueId = lstTestGroup[1].Id;
            testQueue.SObjectType = 'Lead';
            lstQueueSobject.add(testQueue);
            
            testQueue = new QueueSObject();
            testQueue.QueueId = lstTestGroup[1].Id;
            testQueue.SObjectType = 'Journey__c';
            lstQueueSobject.add(testQueue);
            
            insert lstQueueSobject;
            
            List<GroupMember> lstGroupMember = new List<GroupMember>();
            GroupMember member = new GroupMember();
            member.UserOrGroupId = testUser.Id;
            member.GroupId = lstTestGroup[0].Id; 
            lstGroupMember.add(member);
            
            member = new GroupMember();
            member.UserOrGroupId = UserInfo.getUserId();
            member.GroupId = lstTestGroup[0].Id; 
            lstGroupMember.add(member);
            
            insert lstGroupMember;
        }
        testSettings = new Setting__c();
        testSettings.Name = 'User/Queue Journey Creation';
        testSettings.Data__c = '{"allowedUsers":[{"userName":"'+ testUser.Username +'","Id":"'+testUser.Id +'"},{"userName":"'+ testUser1.Username +'","Id":"'+testUser1.Id +'"}],"allowedQueues":[{"Id":"'+ lstTestGroup[0].Id +'","queueName":"'+ lstTestGroup[0].Name +'"}]}';
        TestingUtility.insertWithAssert(testSettings);
    }
    public Messaging.InboundEmail getInboundEmail(String strFromAddress,String[] strToAddresses,String[] strCcAddresses){
        Messaging.InboundEmail inboundEmail = new Messaging.InboundEmail(); 
        inboundEmail.subject       		 = 'Looking for a space';
        inboundEmail.fromname      		 = 'John Baba';
        inboundEmail.plainTextBody 		 = 'hii there!';
        inboundEmail.htmlBody      		 = inboundEmail.plainTextBody;
        inboundEmail.fromAddress   		 = strFromAddress;
        inboundEmail.toAddresses   		 = strToAddresses;
        if(strCcAddresses!=null)
            inboundEmail.ccAddresses = strCcAddresses;
        return inboundEmail;
    }
    @isTest 
    static void insertingNewLeadsUsingEmailTest(){
        User objAdminUser = [Select Id from user where username =:'testweworkuser1@example.com']; 
        system.assertNotEquals(objAdminUser,null);
        
        system.runAs(objAdminUser){
            insert new List<Lead>{new Lead(firstname = 'Troy',lastname = 'McClure',email='testUniqueEmail@gmail.com',company='Springfield Inc',Generate_Journey__c = false)};
                System.assertEquals(1,([SELECT Id FROM Lead]).size());
            Test.startTest();
            Messaging.InboundEmail inboundEmail = new Email2LeadTest().getInboundEmail('john@doe.com',new String[]{'testservice@salesforce.com'}, new String[]{'testcc1@example.com'});
            
            Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
            binaryAttachment.body            = blob.valueOf('Test binaryAttachment text');
            binaryAttachment.fileName        = 'textfileone.txt';
            binaryAttachment.mimeTypeSubType = 'text/plain';
            
            inboundEmail.binaryAttachments   = new Messaging.inboundEmail.BinaryAttachment[] { binaryAttachment };
                
                Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
            attachmenttext.body              = 'Test attachment text';
            attachmenttext.fileName          = 'textfilet.txt';
            attachmenttext.mimeTypeSubType   = 'text/plain';
            inboundEmail.textAttachments     =  new Messaging.inboundEmail.TextAttachment[] { attachmenttext };
                
                Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
            envelope.toAddress       = 'testservice@salesforce.com';
            envelope.fromAddress     = 'john@doe.com';
            
            EMail2Lead emailProcess = new EMail2Lead();
            emailProcess.handleInboundEmail(inboundEmail, envelope);
            Test.stopTest();
            List<Lead> lstOfLeads = [SELECT Id,Name,Email FROM Lead];
            Debug.log('lstOfLeads=='+lstOfLeads);
            System.assertEquals(3, lstOfLeads.size());
            
            List<Journey__c> lstOfJourneys = [SELECT Id,Primary_Lead__r.Name,Primary_Lead__r.Email FROM Journey__c];
            Debug.log('lstOfJourneys=='+lstOfJourneys);
            System.assertEquals(0, lstOfJourneys.size());
            
            /*List<Task> lstOfTask = [SELECT Id,type FROM Task];
            Debug.log('lstOfTasks=='+lstOfTask);
            System.assertEquals(3, lstOfTask.size());
            Set<String> setOfTask = new Set<String>();
            for(Task itrTask : lstOfTask){
                setOfTask.add(itrTask.type);
            }
            System.assertEquals(2, setOfTask.size());
            System.assert(setOfTask.contains('Email'));*/
        }
    }
    
    @isTest
    static void testForExistingEmailLead(){
        insert new List<Lead>{new Lead(firstname = 'Troy',lastname = 'McClure',email='testservice@salesforce.com',company='Springfield Inc',Generate_Journey__c = false)};
            System.assertEquals(1,([SELECT Id FROM Lead]).size());
        Test.startTest();
        Messaging.InboundEmail inboundEmail = new Email2LeadTest().getInboundEmail('john@doe.com',new String[]{'testservice@salesforce.com'}, null);
        
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        envelope.toAddress       = 'testservice@salesforce.com';
        envelope.fromAddress     = 'john@doe.com';
        EMail2Lead emailProcess = new EMail2Lead();
        emailProcess.handleInboundEmail(inboundEmail, envelope);
        Test.stopTest();
        
        List<Lead> lstLead = [SELECT Id FROM Lead WHERE Email = 'testservice@salesforce.com'];
        System.assertEquals(2, lstLead.size());
        
        /*List<task> lstTask = [SELECT Id,Type FROM Task WHERE WHOID = : lstLead[0].Id Order By CreatedDate];
        System.assertEquals(2, lstTask.size());
        Debug.Log('lstTask=='+lstTask);
        Set<String> setOfTask = new Set<String>();
        for(Task itrTask : lstTask){
            setOfTask.add(itrTask.type);
        }
        System.assertEquals(2, setOfTask.size());
        System.assert(setOfTask.contains('Email'));*/
    }
    
    @isTest
    static void testForExistingEmailLeadWithoutJourney(){
        insert new List<Lead>{new Lead(firstname = 'Troy',lastname = 'McClure',email='testservice@salesforce.com',company='Springfield Inc')};
            System.assertEquals(1,([SELECT Id FROM Lead]).size());
        Test.startTest();
        Messaging.InboundEmail inboundEmail = new Email2LeadTest().getInboundEmail('john@doe.com',new String[]{'testservice@salesforce.com'}, null);
        
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        envelope.toAddress       = 'testservice@salesforce.com';
        envelope.fromAddress     = 'john@doe.com';
        EMail2Lead emailProcess = new EMail2Lead();
        emailProcess.handleInboundEmail(inboundEmail, envelope);
        Test.stopTest();
        
        List<Lead> lstLead = [SELECT Id FROM Lead WHERE Email = 'testservice@salesforce.com'];
        System.assertEquals(2, lstLead.size());
        
        /*List<task> lstTask = [SELECT Id,type FROM Task WHERE WHOID = : lstLead[0].Id];
        System.assertEquals(2, lstTask.size());
        Debug.Log('lstTask=='+lstTask);
        Set<String> setOfTask = new Set<String>();
        for(Task itrTask : lstTask){
            setOfTask.add(itrTask.type);
        }
        System.assertEquals(2, setOfTask.size());
        System.assert(setOfTask.contains('Email'));*/
    }
    
    @isTest
    static void testForExistingConvertedLead(){
        List<Lead> lstLeads =  new List<Lead>{new Lead(firstname = 'Troy',lastname = 'McClure',email='testservice@salesforce.com',company='Springfield Inc',Generate_Journey__c = false)};
            insert lstLeads;    
        System.assertEquals(1,([SELECT Id FROM Lead]).size());
        
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(lstLeads[0].id);
        
        LeadStatus convertStatus = [ SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1 ];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        
        Messaging.InboundEmail inboundEmail = new Email2LeadTest().getInboundEmail('john@doe.com',new String[]{'testservice@salesforce.com'}, null);
        
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        envelope.toAddress       = 'testservice@salesforce.com';
        envelope.fromAddress     = 'john@doe.com';
        
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('Test attachment text');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        inboundEmail.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
            
            Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
        attachmenttext.body = 'Test attachment text';
        attachmenttext.fileName = 'textfilet.txt';
        attachmenttext.mimeTypeSubType = 'text/plain';
        inboundEmail.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext };
            
            Test.startTest();
        EMail2Lead emailProcess = new EMail2Lead();
        emailProcess.handleInboundEmail(inboundEmail, envelope);
        Test.stopTest();
        
        Lead[] arrLead = [SELECT id, isConverted, convertedContactId, convertedContact.ownerId FROM Lead WHERE id = :lstLeads[0].id];
        
        system.assertEquals(1, arrLead.size(),'A new lead should not exist after processing a new email');
        system.assert(arrLead[0].isConverted);
        system.assertNotEquals(null,arrLead[0].convertedContactId,'The last lead sould be converted into a contact');
        
        /*Task[] arrTasks = [SELECT id, subject, type, ownerId  FROM Task WHERE WhoId = :arrLead[0].convertedContactId ORDER BY createddate ]; 
        System.assertEquals(arrLead[0].convertedContact.ownerId,arrTasks[0].ownerId,'Task should be assigned to Lead/Contact owner');*/
        
    }
    
    @isTest
    static void testForExistingContact(){
        User adminUser = [Select Id from user where username =:'testweworkuser1@example.com']; 
        system.assertNotEquals(null, adminUser);
        
        System.runAs(adminUser){
            Account objAccount = new Account(name = 'Test Account');
            insert objAccount;
            
            Contact objContact = new Contact(firstname = 'Peter',lastname = 'Parker',email = 'testservice@salesforce.com',AccountId = objAccount.id);
            insert objContact;
            
            Opportunity objOpportunity = TestingUtility.createOpportunity(objAccount.Id,false);
            objOpportunity.StageName='Selling';
            objOpportunity.Interested_in_Number_of_Desks__c = 5;
            objOpportunity.Owner_Auto_Assign__c=true;
            insert objOpportunity;
            
            objContact = [SELECT id, ownerId, firstname, lastname, email FROM Contact WHERE id = :objContact.id LIMIT 1];
            System.assertNotEquals(null,objContact.Id);
            
            Messaging.InboundEmail inboundEmail = new Email2LeadTest().getInboundEmail('john@doe.com',new String[]{'testservice@salesforce.com'}, null);
            
            Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
            envelope.toAddress       = 'testservice@salesforce.com';
            envelope.fromAddress     = 'john@doe.com';
            
            Test.startTest();
            EMail2Lead emailProcess = new EMail2Lead();
            emailProcess.handleInboundEmail(inboundEmail, envelope);
            Test.stopTest();
            
            /*Task[] arrTask = [ SELECT id, subject, type, ownerId  FROM Task  WHERE WhoId = :objContact.id ];
            Debug.log('arrTask=='+arrTask);
            System.assertEquals( 1, arrTask.size(),'A new Task Email should be created and associated to the contact');
            System.assertEquals('Email',arrTask[0].type,'A new Email should be created and associated to the Lead\'s converted Contact');
            System.assertEquals(objContact.OwnerId,arrTask[0].OwnerId,'Task should be assigned to Contact owner');
            System.assertEquals(0, [SELECT Id FROM Journey__c].size());*/
        }
    }
}