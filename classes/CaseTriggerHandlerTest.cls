/************************************************************************************************************************************
    Author      :   Dipak Pawar
    Description :   This class should contain all test methods related to CaseTriggerHandler class.
    History		:
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1           23-Nov-2017         Dipak Pawar             Initial Development
    
    Code Reviewed By    :   Dipak Pawar
    Code Review Comments:   Reviewed the new trigger structure, comments. ST-2022.
    Code Review Date    :   07-Feb-2018
**************************************************************************************************************************************/
 
@isTest
public class CaseTriggerHandlerTest {
    static List<Account> lstAccountsToInsert = new List<Account>();
    static List<Contact> lstContacts = new List<Contact>();
    static List<Building__c> lstBuildings = new List<Building__c>();
    public static List<Opportunity> lstOpportunities = new List<Opportunity>();
    public static List<User> lstUserInserted = new List<User>();
    static List<Case_Template__c> lstCaseTemplates = new List<Case_Template__c>();
    public static List<Case_Template__c> lstCaseTemplatesInserted = new List<Case_Template__c>();
    static List<Case> lstCases = new List<Case>();
    
    @TestSetup
    static void initData(){
        SalesConsoleSettings.createSettings(); 
        
        Profile testProfile1 = [SELECT Id FROM Profile WHERE Name='WeWork System Administrator']; 
        List<User> lstUsers = new List<User>();
        User user1 = new User(Alias = 'standt', Email = 'standarduser1@example.com',
                              EmailEncodingKey = 'UTF-8', LastName='Testing1', 
                              LanguageLocaleKey = 'en_US',
                              LocaleSidKey='en_US', 
                              ProfileId = testProfile1.Id,
                              TimeZoneSidKey='America/Los_Angeles', UserName='standarduser1@example.com',CommunityNickname='Test1'+System.now());
        lstUsers.add(user1); 
        User user2 = new User(Alias = 'standt2', Email = 'standarduser2@example.com',
                              EmailEncodingKey = 'UTF-8', LastName='Testing2', 
                              LanguageLocaleKey = 'en_US',
                              LocaleSidKey='en_US', 
                              ProfileId = testProfile1.Id,
                              TimeZoneSidKey='America/Los_Angeles', UserName='standarduser2@example.com',CommunityNickname='Test2'+System.now());
        lstUsers.add(user2);
        insert lstUsers; 
        for(User userObj : lstUsers){
            System.assertNotEquals(null, userObj.Id); 
        }
        
        Account accRec = new Account(Name = 'strAccountName1', Account_Type__c = 'Org', Number_of_Full_Time_Employees__c = 1000, RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Enterprise Solutions').getRecordTypeId());
        lstAccountsToInsert.add(accRec);
        
        Account acc = new Account(name = 'Test Account',UUID__c = 'testAccountUUID1',Account_Type__c = 'Org');
        lstAccountsToInsert.add(acc);
        TestingUtility.insertListWithAssert(lstAccountsToInsert);
        
        Contact contactRec = new Contact(FirstName = 'John', LastName = 'Smith', Email = 'testContact1@example.com', AccountID = accRec.Id, Status__c = 'active');
        lstContacts.add(contactRec);
        TestingUtility.insertListWithAssert(lstContacts);
        
        Building__c objBuilding = new Building__c(City__c = 'Test',Name = 'NYC-Penn Station',Community_Manager__c = contactRec.Id,uuid__c = 'abc123');
        lstBuildings.add(objBuilding);
        Building__c objBuilding1 = new Building__c(City__c = 'Test',Name = 'NYC-Penn Station 34',Community_Manager__c = contactRec.Id,uuid__c = 'abc123AB');
        lstBuildings.add(objBuilding1); 
        TestingUtility.insertListWithAssert(lstBuildings) ;
        
        Opportunity opp = new Opportunity(Name = 'Test Opportunity1',AccountId = accRec.Id,StageName = 'Selling',CloseDate = Date.Today(),Primary_Member__c = contactRec.Id,Primary_Member_Email__c = contactRec.Email,Building__c = objBuilding.Id);
        lstOpportunities.add(opp);
        Opportunity opp1 = new Opportunity(Name = 'Test Opportunity2',AccountId = accRec.Id,CloseDate = Date.Today(),StageName = 'Selling',Primary_Member_Email__c = lstContacts[0].Email,Building__c = objBuilding.Id);
        lstOpportunities.add(opp1); 
        TestingUtility.insertListWithAssert(lstOpportunities); 
        
        Case_Template__c caseTemplate1 = new Case_Template__c(
            Name = 'Proposal',
            Default_Owner__c = 'Queue:SalesAnalystQueue', 
            Record_Type_Name__c = 'Enterprise Finance & Strategy',
            Opportunity_Stages__c = 'Selling;Negotiating;Closing',
            Triggering_Object__c = 'Opportunity'
        );   
        lstCaseTemplates.add(caseTemplate1); 
        Case_Template__c caseTemplate2 = new Case_Template__c(
            Name = 'Proposal & Pricing',
            Default_Owner__c = 'Queue:SalesAnalystQueue', 
            Record_Type_Name__c = 'Enterprise Finance & Strategy',           
            Opportunity_Stages__c = 'Any',
            Triggering_Object__c = 'Account'
        );
        lstCaseTemplates.add(caseTemplate2);  
        
        Case_Template__c caseTemplate3 = new Case_Template__c(
            Name = 'Membership Agreement: Contract Review',
            Default_Owner__c = 'Queue:testGroup', 
            Record_Type_Name__c = 'Enterprise Finance & Strategy',
            Opportunity_Stages__c = 'Selling;Negotiating;Closing',
            Owner_Role__c = 'Legal Counsel',
            Triggering_Object__c = 'Opportunity'
        );  
        lstCaseTemplates.add(caseTemplate3);
        
        Case_Template__c caseTemplate4 = new Case_Template__c(
            Name = 'Proposal',
            Default_Owner__c = 'Sales Analyst Queue', 
            Record_Type_Name__c = 'Enterprise Finance & Strategy', 
            Opportunity_Stages__c = 'Selling;Negotiating;Closing',
            Owner_Role__c ='Sales Analyst',
            Triggering_Object__c = 'Account'
        );  
        lstCaseTemplates.add(caseTemplate4); 
        
        Case_Template__c caseTemplate5 = new Case_Template__c(
            Name = 'Pricing',
            Default_Owner__c = 'Sales Analyst Queue', 
            Record_Type_Name__c = 'Enterprise Finance & Strategy', 
            Opportunity_Stages__c = 'Selling;Negotiating;Closing',
            Owner_Role__c ='Sales Analyst',
            Triggering_Object__c = 'Opportunity'
        );  
        lstCaseTemplates.add(caseTemplate5);
        
        Case_Template__c caseTemplate6 = new Case_Template__c(
            Name = 'Proposal',
            Default_Owner__c = 'User:standarduser2@example.com', 
            Record_Type_Name__c = 'Enterprise Finance & Strategy', 
            Opportunity_Stages__c = 'Selling;Negotiating;Closing',
            Owner_Role__c ='RoleDemo',
            Triggering_Object__c = 'Opportunity'
        );  
        lstCaseTemplates.add(caseTemplate6);
        
        Case_Template__c caseTemplate7 = new Case_Template__c(
            Name = 'Search Spaces',
            Owner_Role__c = 'Sales Analyst',
            Record_Type_Name__c = 'Enterprise Finance & Strategy',
            Triggering_Object__c = 'Account',
            Opportunity_Stages__c = 'Any' 
        );   
        lstCaseTemplates.add(caseTemplate7); 
        
        Case_Template__c caseTemplate8 = new Case_Template__c(
            Name = 'Design Layout',
            Owner_Role__c = 'Product Design Manager',
            Record_Type_Name__c = 'Enterprise Finance & Strategy',
            Triggering_Object__c = 'Opportunity' ,
            Opportunity_Stages__c = 'Any' 
        ); 
        lstCaseTemplates.add(caseTemplate8);
        
        Case_Template__c caseTemplate9 = new Case_Template__c(
            Name = 'Sign NDA',
            Due_In_Days__c = 20,            
            Triggering_Object__c = 'Account'
        );
        lstCaseTemplates.add(caseTemplate9);
        
        Case_Template__c caseTemplate10 = new Case_Template__c(
            Name = 'Search Spaces Using Salesforce',
            Due_In_Days__c = 1,            
            Triggering_Object__c = 'Opportunity'
        );
        lstCaseTemplates.add(caseTemplate10);
        TestingUtility.insertListWithAssert(lstCaseTemplates);
        
        Case caseRec1 = new Case(
            Opportunity__c=lstOpportunities[0].Id,
            Status = 'New',
            Requested_Type__c = lstCaseTemplates[0].Name,
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(lstCaseTemplates[0].Record_Type_Name__c).getRecordTypeId(),
            Case_Template_Name__c=lstCaseTemplates[0].Name
        );
        lstCases.add(caseRec1);  
        Case caseRec2 = new Case(
            AccountId = lstAccountsToInsert[1].Id,
            Status = 'New',
            Requested_Type__c = lstCaseTemplates[1].Name,
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(lstCaseTemplates[1].Record_Type_Name__c).getRecordTypeId(),
            Case_Template_Name__c=lstCaseTemplates[1].Name
        );
        lstCases.add(caseRec2); 
        TestingUtility.insertListWithAssert(lstCases);
    }
    
    /************************************************************************************************************************************
        Author              :   Nikhil Mehta
        Description         :   Test method for caseOwnerAssignment.
        Issue No.           :   ST-1535
        Last Modified By    :   Pragalbha Mahajan on 22 Aug 2018 for ST-2713
        Code Reviewed By    :   Dipak Pawar
        Code Review Comments:   Reviewed the new trigger structure, comments. ST-2022.
        Code Review Date    :   07-Feb-2018
    **************************************************************************************************************************************/  
    @isTest 
    public static void caseOwnerAssignmentTest(){
        Test.startTest(); 
        lstUserInserted = [SELECT Id,Username,LastName,Email,ProfileId,EmailEncodingKey FROM User WHERE Email =:'standarduser1@example.com' OR Email =:'standarduser2@example.com'];
        List<Case_Template__c> lstCaseTemplates = [SELECT Id,Name,Record_Type_Name__c FROM Case_Template__c];
        List<Account> lstAccountsInserted = [SELECT Id,Name FROM Account];
        Group testGroup = new Group(Name='testGroup', type='Queue');
        insert testGroup;
        System.assertNotEquals(null, testGroup.Id); 
        
        System.runAs(new User(Id = UserInfo.getUserId())){
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SobjectType = 'Case');
            insert testQueue;
            System.assertNotEquals(null, testQueue.Id); 
            GroupMember member = new GroupMember();
            member.UserOrGroupId = lstUserInserted[0].Id;
            member.GroupId = testGroup.Id;  
            insert member;
            System.assertNotEquals(null, member.Id); 
        } 
        
        Opportunity oppRec1 = TestingUtility.createOpportunity(lstAccountsInserted[0].Id, false);
        oppRec1.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise Solutions').getRecordTypeId();
        oppRec1.StageName = 'Selling';
        insert oppRec1;
        System.assertNotEquals(null, oppRec1.Id);
        System.assertEquals(oppRec1.RecordTypeId, Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise Solutions').getRecordTypeId());
        
        List<OpportunityTeamMember> lstOppTeams = new List<OpportunityTeamMember>();
        OpportunityTeamMember objOppTeam1 = new OpportunityTeamMember(
            OpportunityId   = oppRec1.Id,
            TeamMemberRole = 'Legal Counsel',
            UserId = lstUserInserted[0].Id
        );
        lstOppTeams.add(objOppTeam1);
        insert lstOppTeams;
        System.assertNotEquals(null,lstOppTeams[0].Id);
        
        AccountTeamMember objAccTeam1 = new AccountTeamMember(
            AccountId   = lstAccountsInserted[0].Id,
            TeamMemberRole = 'Sales Analyst',
            UserId = lstUserInserted[1].Id
        );
        insert objAccTeam1;
        System.assertNotEquals(null,objAccTeam1.Id);
        
        List<Case> lstCase = new List<Case>();
        Case caseRec1 = new Case(
            Opportunity__c = oppRec1.Id,
            Status = 'New', 
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(lstCaseTemplates[2].Record_Type_Name__c).getRecordTypeId(),
            Case_Template_Name__c = lstCaseTemplates[2].Name,
            Case_Template__c = lstCaseTemplates[2].Id,
            Requested_Type__c = lstCaseTemplates[2].Name
        );
        lstCase.add(caseRec1);
        Case caseRec2 = new Case(
            AccountId = lstAccountsInserted[0].Id,
            Status = 'New', 
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(lstCaseTemplates[3].Record_Type_Name__c).getRecordTypeId(),
            Case_Template_Name__c = lstCaseTemplates[3].Name,
            Case_Template__c = lstCaseTemplates[3].Id,
            Requested_Type__c = lstCaseTemplates[3].Name
        );
        lstCase.add(caseRec2);
        Case caseRec3 = new Case(
            Opportunity__c = oppRec1.Id, 
            Status = 'New', 
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(lstCaseTemplates[4].Record_Type_Name__c).getRecordTypeId(),
            Case_Template_Name__c = lstCaseTemplates[4].Name,
            Case_Template__c = lstCaseTemplates[4].Id,
            Requested_Type__c = lstCaseTemplates[4].Name
        );
        lstCase.add(caseRec3);
        Case caseRec4 = new Case(
            Opportunity__c = oppRec1.Id, 
            Status = 'New', 
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(lstCaseTemplates[5].Record_Type_Name__c).getRecordTypeId(),
            Case_Template_Name__c = lstCaseTemplates[5].Name,
            Case_Template__c = lstCaseTemplates[5].Id,
            Requested_Type__c = lstCaseTemplates[5].Name
        );
        lstCase.add(caseRec4);
        insert(lstCase); 
        List<Case> lstCaseAfterInsert = [SELECT Id, OwnerId FROM Case];
        for(Case objCase : lstCaseAfterInsert){
            System.assertNotEquals(null, objCase.Id);
        }
        for(Case objCase : lstCaseAfterInsert){
            if(caseRec1.Id == objCase.Id){
                System.assertEquals(lstUserInserted[0].Id, objCase.OwnerId);
            }else if(caseRec2.Id == objCase.Id){
                System.assertEquals(lstUserInserted[1].Id, objCase.OwnerId);
            }else if(caseRec3.Id == objCase.Id){
                Debug.log('USER1--'+lstUserInserted[1].Id);
                System.assertEquals(lstUserInserted[1].Id, objCase.OwnerId);
            }else if(caseRec4.Id == objCase.Id){
                Debug.log('user2--'+lstUserInserted[1].Id);
                Debug.log('OwnerId--'+objCase.OwnerId);
                System.assertEquals(lstUserInserted[1].Id, objCase.OwnerId);
            }
        }
        Test.stopTest();
    }
    
    /************************************************************************************************************************************
        Author              :   Priyanka Ambre
        Description         :   This method is used to test validateUserToCloseCases when logged in user is of 'WeWork System Administrator' profile.
        Issue No.           :   ST-2000
        Last Modified By    :   Pragalbha Mahajan on 22 Aug 2018 for ST-2713
        Code Reviewed By    :   Dipak Pawar
        Code Review Comments:   Reviewed the new trigger structure, comments. ST-2022.
        Code Review Date    :   07-Feb-2018
    **************************************************************************************************************************************/  
    public static testMethod void validateUserToCloseCasesTest1(){
        Test.startTest();        
        lstUserInserted = [SELECT Id,Username,LastName,Email,ProfileId,EmailEncodingKey FROM User WHERE Email =:'standarduser1@example.com' OR Email =:'standarduser2@example.com'];     
        List<Case_Template__c> lstCaseTemplates = [SELECT Id,Name,Record_Type_Name__c FROM Case_Template__c];
        List<Account> lstAccountsInserted = [SELECT Id,Name FROM Account];
        
        Opportunity oppRec = TestingUtility.createOpportunity(lstAccountsInserted[0].Id, false);
        oppRec.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise Solutions').getRecordTypeId();
        insert oppRec;
        System.assertNotEquals(null,oppRec.Id);
        System.assertEquals(oppRec.RecordTypeId, Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise Solutions').getRecordTypeId());
        
        Map<String, Schema.RecordTypeInfo> mapCaseRtNameToInfo = Schema.SObjectType.Case.getRecordTypeInfosByName();
        List<Case> lstCase = new List<Case>();
        Case caseRec = UtilCase.createCaseReadyToBeClosed(lstAccountsInserted[0].Id, oppRec.Id, null, null,
            												mapCaseRtNameToInfo.get(lstCaseTemplates[6].Record_Type_Name__c).getRecordTypeId(), lstCaseTemplates[6].Name, lstCaseTemplates[6].Name, false);
        lstCase.add(caseRec);
        Case caseRec1 = UtilCase.createCaseReadyToBeClosed(lstAccountsInserted[0].Id, null, null, null,
            												mapCaseRtNameToInfo.get(lstCaseTemplates[7].Record_Type_Name__c).getRecordTypeId(), lstCaseTemplates[7].Name, lstCaseTemplates[7].Name, false);
        lstCase.add(caseRec1);      
        insert(lstCase);
        for(Case objCase : lstCase){
            System.assertNotEquals(null, objCase.Id);
        }  
        lstCase[0].Status = 'Closed';
        lstCase[1].Status = 'Closed'; 
        System.runAs(lstUserInserted[0]) { 
            try { 
                Database.update(lstCase, false);
            } catch(Exception exc) {
                System.assertNotEquals(null, exc);
                Boolean expectedExceptionThrown =  exc.getMessage().contains('Case Cannot be closed') ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
            }finally{
                lstCase = [Select Id, Status From Case Where Id IN:new List<Id>{lstCase[0].Id, lstCase[1].Id}];
                System.assertEquals('New', lstCase[0].Status); 
                System.assertEquals('New', lstCase[1].Status); 
            } 
        }
        Test.stopTest();
    }
    
    /************************************************************************************************************************************
        Author              :   Priyanka Ambre
        Description         :   This method is used to test validateUserToCloseCases when logged in user is of 'WeWork Product Design Manager' profile.
        Issue No.           :   ST-2000
        Last Modified By    :   Pragalbha Mahajan on 22 Aug 2018 for ST-2713
        Code Reviewed By    :   Dipak Pawar
        Code Review Comments:   Reviewed the new trigger structure, comments. ST-2022.
        Code Review Date    :   07-Feb-2018
    **************************************************************************************************************************************/  
    public static testMethod void validateUserToCloseCasesTest2(){
        Test.startTest();
        lstUserInserted = [SELECT Id,Username,LastName,Email,ProfileId,EmailEncodingKey FROM User WHERE Email =:'standarduser1@example.com' OR Email =:'standarduser2@example.com'];
        List<Case_Template__c> lstCaseTemplates = [SELECT Id,Name,Record_Type_Name__c FROM Case_Template__c];
        List<Account> lstAccountsInserted = [SELECT Id,Name FROM Account];
        Group testGroup = new Group(Name='testGroup', type='Queue');
        insert testGroup;
        System.runAs(new User(Id = UserInfo.getUserId())){
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SobjectType = 'Case');
            insert testQueue;
            GroupMember member = new GroupMember();
            member.UserOrGroupId = lstUserInserted[0].Id;
            member.GroupId = testGroup.Id;  
            insert member;
        } 
        
        Opportunity oppRec = TestingUtility.createOpportunity(lstAccountsInserted[0].Id, false);
        oppRec.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise Solutions').getRecordTypeId();
        oppRec.StageName = 'Selling';
        insert oppRec;
        System.assertNotEquals(null, oppRec.Id);
        System.assertEquals(oppRec.RecordTypeId, Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise Solutions').getRecordTypeId());
        
        Map<String, Schema.RecordTypeInfo> mapCaseRtNameToInfo = Schema.SObjectType.Case.getRecordTypeInfosByName(); 
        List<Case> lstCase = new List<Case>();
        Case caseRec1 = UtilCase.createCaseReadyToBeClosed(lstAccountsInserted[0].Id, oppRec.Id, lstUserInserted[0].Id, lstCaseTemplates[6].Id, 
                                                           mapCaseRtNameToInfo.get(lstCaseTemplates[6].Record_Type_Name__c).getRecordTypeId(), lstCaseTemplates[6].Name, lstCaseTemplates[6].Name, false);
        lstCase.add(caseRec1);
        Case caseRec2 = UtilCase.createCaseReadyToBeClosed (lstAccountsInserted[0].Id, null, testGroup.Id, lstCaseTemplates[7].Id, 
                                                            mapCaseRtNameToInfo.get(lstCaseTemplates[7].Record_Type_Name__c).getRecordTypeId(), lstCaseTemplates[7].Name, lstCaseTemplates[7].Name, false);
        lstCase.add(caseRec2); 
        System.runAs(lstUserInserted[0]){
            insert(lstCase);
        }
        
        for(Case objCase : lstCase){
            System.assertNotEquals(null, objCase.Id);
        }
        lstCase[0].Status = 'Closed';
        lstCase[1].Status = 'Closed';  
        try { 
            System.runAs(lstUserInserted[1]) {
                Database.update(lstCase, false);
            }
        } catch(Exception exc) {
            System.assertNotEquals(null, exc);
            Boolean expectedExceptionThrown = exc.getMessage().contains('Case Cannot be closed') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } finally {
            lstCase = [Select Id, Status, OwnerId From Case];
            for(Case caseRec : lstCase){
                if(caseRec.Id == caseRec2.Id){
                    System.assertEquals('New', caseRec.Status); 
                } else if(caseRec.Id == caseRec1.Id){
                    System.assertEquals('New', caseRec.Status); 
                    System.assertEquals(lstUserInserted[0].Id, caseRec.OwnerId);
                }
            }                
        }
        Test.stopTest();
    }
    
    /************************************************************************************************************************************
        Author              :   Dipak Pawar
        Description         :   Test method for autoDocumentGenerator function. 
        Issue No.           :   ST-2001
        Last Modified By    :   Pragalbha Mahajan on 22 Aug 2018 for ST-2713
        Code Reviewed By    :   Dipak Pawar
        Code Review Comments:   Reviewed the new trigger structure, comments. ST-2022.
        Code Review Date    :   07-Feb-2018
    **************************************************************************************************************************************/  
    public static testmethod void autoDocumentGeneratorTest(){
        Test.startTest();
        List<Case_Template__c> listCaseTemplates = new List<Case_Template__c>();
        List<Document_Template__c> listDocumentTemplates = new List<Document_Template__c>();
        List<Case_Template__c> lstCaseTemplates = [SELECT Id,Name,Record_Type_Name__c FROM Case_Template__c];
        List<Account> lstAccountsInserted = [SELECT Id,Name FROM Account];
        List<Contact> lstContactsInserted = [SELECT Id,Name FROM Contact];
        Document_Template__c objDocumentTemplate1 = new Document_Template__c(
            Name = 'Sign NDA', 
            Case_Template__c = lstCaseTemplates[8].Id,
            Document_Name__c = 'Sign NDA', 
            Document_Type__c = 'Versioned',            
            Object__c = 'Account'
        );
        listDocumentTemplates.add(objDocumentTemplate1);
        
        Document_Template__c objDocumentTemplate2 = new Document_Template__c(
            Name = 'Proposal', 
            Case_Template__c = lstCaseTemplates[9].Id,
            Document_Name__c = 'Proposal', 
            Document_Type__c = 'Versioned',            
            Object__c = 'Opportunity'
        );
        listDocumentTemplates.add(objDocumentTemplate2); 
        insert listDocumentTemplates;
        for(Document_Template__c docTemplate : listDocumentTemplates){
            System.assertNotEquals(null, docTemplate.Id);
        }
        
        Building__c buildingRec1 = new Building__c(Name = 'TestbuildingRec1',Real_Estate_Deal_Gate__c='B');
        Building__c buildingRec2 = new Building__c(Name = 'TestbuildingRec2',Real_Estate_Deal_Gate__c='A');
        List<Building__c> lstBuilding = new  List<Building__c>();
        lstBuilding.add(buildingRec1);
        lstBuilding.add(buildingRec2);
        insert lstBuilding;
        
        for(Building__c building : lstBuilding){
            System.assertNotEquals(null, building.Id);
        } 
        
        Opportunity oppRec = TestingUtility.createOpportunity(lstAccountsInserted[0].Id, false);
        oppRec.Primary_Member__c = lstContactsInserted[0].Id;
        oppRec.StageName = 'Qualifying';
        oppRec.CurrencyIsoCode = 'USD'; 
        oppRec.CloseDate = system.today().addDays(5);  
        oppRec.Building__c = lstBuilding[0].Id;
        insert oppRec;
        System.assertNotEquals(null, oppRec.Id); 
        
        List<Case> listCasesToInsert = new List<Case>();
        Case caseRec1 = new Case(
            Subject = 'Test Case Subject',
            Status = 'Open',
            Case_Template__c = lstCaseTemplates[9].Id,
            AccountId = lstAccountsInserted[0].Id,
            Requested_Type__c = lstCaseTemplates[9].Name
        );
        listCasesToInsert.add(caseRec1); 
        insert listCasesToInsert;
        for(Case caseRec : listCasesToInsert){
            System.assertNotEquals(null, caseRec.Id);
        } 
        
        listCasesToInsert = new List<Case>();
        Case caseRec4 = new Case(
            Subject = 'Test Case Subject',
            Status = 'New Submission',
            Case_Template__c = lstCaseTemplates[8].Id,
            AccountId = lstAccountsInserted[0].Id,
            Requested_Type__c = lstCaseTemplates[8].Name
        );
        listCasesToInsert.add(caseRec4); 
        insert listCasesToInsert;
        for(Case caseRec : listCasesToInsert){
            System.assertNotEquals(null, caseRec.Id);
        }
        
        List<Document__c> listDocuments = new List<Document__c>([SELECT Id, Name, Document_Template__c, Account__c, Opportunity__c FROM Document__c]);
        System.assertNotEquals(null, listDocuments);
        System.assertEquals(2, listDocuments.size());
        
        for(Document__c doc : listDocuments){
            if(doc.Account__c != null){
                System.assertEquals(lstAccountsInserted[0].Id, doc.Account__c);
            }
            if(doc.Opportunity__c != null){
                System.assertEquals(oppRec.Id, doc.Opportunity__c);
            } 
        }
        Test.stopTest();
    }
    
    /************************************************************************************************************************************
        Author              :   Priyanka Ambre
        Description         :   This method is used to test restrictCaseCreationBasedOnOppStages. 
        Issue No.           :   ST-2005
        Last Modified By    :   Pragalbha Mahajan on 22 Aug 2018 for ST-2713
        Code Reviewed By    :   Dipak Pawar
        Code Review Comments:   Reviewed the new trigger structure, comments. ST-2022.
        Code Review Date    :   07-Feb-2018
    **************************************************************************************************************************************/  
    public static testmethod void restrictCaseCreationBasedOnOppStagesTest(){  
        Test.startTest();
        Set<Id> setOppIds = new Set<Id>();
        List<Case_Template__c> lstCaseTemplates = [SELECT Id,Name,Record_Type_Name__c FROM Case_Template__c];
        List<Account> lstAccountsInserted = [SELECT Id,Name FROM Account];
        List<Opportunity> lstOppToInsert = new List<Opportunity>();
        Opportunity oppRec1 = TestingUtility.createOpportunity(lstAccountsInserted[0].Id, false);
        oppRec1.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise Solutions').getRecordTypeId();
        oppRec1.StageName = 'Selling';
        lstOppToInsert.add(oppRec1);
        
        Opportunity oppRec2 = TestingUtility.createOpportunity(lstAccountsInserted[0].Id, false);
        oppRec2.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise Solutions').getRecordTypeId();
        oppRec2.StageName = 'Qualifying';
        lstOppToInsert.add(oppRec2);
        insert lstOppToInsert;
        for(Opportunity opp : lstOppToInsert){
            System.assertNotEquals(null, opp.Id); 
            setOppIds.add(opp.Id);
        }
        List<Case> lstCase = new List<Case>();
        Case caseRec1 = new Case(
            AccountId = lstAccountsInserted[0].Id,
            Opportunity__c = oppRec1.Id,
            Status = 'New',
            Requested_Type__c = lstCaseTemplates[2].Name
        );
        lstCase.add(caseRec1);  //Should be inserted
        Case caseRec2 = new Case(
            AccountId = lstAccountsInserted[0].Id, 
            Opportunity__c = oppRec2.Id,
            Status = 'New',
            Requested_Type__c = lstCaseTemplates[3].Name
        );
        lstCase.add(caseRec2);  //Should not be inserted
        Case caseRec3 = new Case(
            AccountId = lstAccountsInserted[0].Id,
            Opportunity__c = oppRec2.Id,
            Status = 'New',
            Requested_Type__c = lstCaseTemplates[4].Name
        );
        lstCase.add(caseRec3);  //Should be inserted 
        
        try { 
            Database.insert(lstCase, false); 
            System.assertEquals(null, caseRec2.Id);
        } catch(Exception exc) {
            System.assertNotEquals(null, exc); 
        } finally {
            for(Case caseRec : [SELECT Requested_Type__c, AccountId, Opportunity__c, RecordTypeId, Status, Record_Type_Name__c FROM Case WHERE (Opportunity__c IN:setOppIds)]){
                if(caseRec.Id == caseRec1.Id){
                    System.assertNotEquals(null, caseRec.Id);
                } else if(caseRec.Id == caseRec2.Id){
                    System.assertEquals(null, caseRec.Id); 
                } else if(caseRec.Id == caseRec3.Id){
                    System.assertNotEquals(null, caseRec.Id);
                }  
            } 
        } 
        Test.stopTest();
    }
    
    /************************************************************************************************************************************
        Author              :   Priyanka Ambre
        Description         :   This method is used to test updateCaseSubject. 
        Issue No.           :   ST-2009        
        Last Modified By    :   Pragalbha Mahajan on 22 Aug 2018 for ST-2713
    **************************************************************************************************************************************/   
    public static testmethod void updateCaseSubjectTest(){
        Test.startTest();
        List<Case_Template__c> lstCaseTemplates = [SELECT Id,Name,Record_Type_Name__c FROM Case_Template__c];
        List<Account> lstAccountsInserted = [SELECT Id,Name FROM Account];
        
        Building__c buildingRec1 = new Building__c(Name = 'TestbuildingRec1',Real_Estate_Deal_Gate__c='B');
        insert buildingRec1;
        System.assertNotEquals(null, buildingRec1.Id);
        
        Opportunity oppRec1 = TestingUtility.createOpportunity(lstAccountsInserted[0].Id, false);
        oppRec1.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise Solutions').getRecordTypeId();
        oppRec1.StageName = 'Selling';
        insert oppRec1;
        System.assertNotEquals(null,oppRec1.Id);
        System.assertEquals(oppRec1.RecordTypeId, Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise Solutions').getRecordTypeId());
        
        List<Case> lstCase = new List<Case>();
        Case caseRec1 = new Case(
            AccountId=lstAccountsInserted[0].Id,
            Status = 'New',
            Requested_Type__c = lstCaseTemplates[0].Name,
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(lstCaseTemplates[0].Record_Type_Name__c).getRecordTypeId(),Case_Template_Name__c=lstCaseTemplates[4].Name);
        lstCase.add(caseRec1);  
        Case caseRec2 = new Case(
            Opportunity__c = oppRec1.Id,
            Status = 'New',
            Requested_Type__c = lstCaseTemplates[4].Name,
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(lstCaseTemplates[4].Record_Type_Name__c).getRecordTypeId());
        lstCase.add(caseRec2);
        Case caseRec4 = new Case(
            Subject= 'Test Subject', 
            Status = 'New',
            Requested_Type__c = lstCaseTemplates[0].Name,
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(lstCaseTemplates[0].Record_Type_Name__c).getRecordTypeId());
        lstCase.add(caseRec4); 
        try { 
            Database.insert(lstCase,false);
            List<Id> lstCaseId = new List<Id>();
            for(Case caseRec: lstCase){
                System.assertNotEquals(null, caseRec.Id);  
            } 
            lstCase = [SELECT Id, Subject FROM Case WHERE Id IN:lstCaseId];
            for(Case caseRec : lstCase){
                if(caseRec.Id == caseRec1.Id){
                    System.assertNotEquals(null, caseRec.Id);
                    System.assertEquals(lstAccountsInserted[0].Name+'-'+lstCaseTemplates[0].Record_Type_Name__c+'-'+lstCaseTemplates[4].Name, caseRec.Subject);
                    System.assertEquals(lstCaseTemplates[0].Id, caseRec.Case_Template__c);
                    System.assertEquals(lstAccountsInserted[0].Id, caseRec.AccountId);
                    System.assertEquals(lstCaseTemplates[0].Triggering_Object__c,caseRec.Case_Template__r.Triggering_Object__c);
                } else if(caseRec.Id == caseRec2.Id){
                    System.assertEquals(null, caseRec.Id); 
                    System.assertEquals(lstAccountsInserted[0].Name+'-'+lstCaseTemplates[4].Record_Type_Name__c+'-'+lstCaseTemplates[4].Name, caseRec.Subject);
                    System.assertEquals(lstCaseTemplates[4].Id, caseRec.Case_Template__c);
                    System.assertEquals(oppRec1.Id, caseRec.Opportunity__c);
                    System.assertEquals(lstAccountsInserted[0].Id, caseRec.AccountId); 
                    System.assertEquals(lstCaseTemplates[4].Triggering_Object__c,caseRec.Case_Template__r.Triggering_Object__c);
                }  else if(caseRec.Id == caseRec4.Id){
                    System.assertEquals(null, caseRec.Id); 
                    System.assertEquals('Test Subject', caseRec.Subject);
                    System.assertEquals(null, caseRec.Case_Template__c); 
                    System.assertEquals(null, caseRec.Opportunity__c);
                    System.assertEquals(null, caseRec.AccountId);  
                } 
            }  
        } catch(Exception exc) {
            System.assertNotEquals(null, exc);
        }
        Test.stopTest();
    } 
    
    /************************************************************************************************************************************
    Author 				: 	Priyanka Ambre
    Description 		: 	This method is used to test restrictDuplicateCaseCreation. 
    Last Modified By	: 	Pragalbha Mahajan for ST-2713
    **************************************************************************************************************************************/  
    public static testmethod void restrictDuplicateCaseCreation(){
        Test.startTest();
        Set<Id> setAccountIds = new Set<Id>();
        Set<Id> setOppIds = new Set<Id>(); 
        List<Case> lstCasesToInsert = new List<Case>();
        List<Opportunity> lstOpportunities = [SELECT Id,Name FROM Opportunity];
        List<Account> lstAccountsToInsert = [SELECT Id,Name FROM Account];
        List<Case_Template__c> lstCaseTemplates = [SELECT Id,Name,Record_Type_Name__c FROM Case_Template__c];
        Case caseRec11= new Case(
            Opportunity__c=lstOpportunities[0].Id,
            Status = 'New',
            Requested_Type__c = lstCaseTemplates[0].Name,
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(lstCaseTemplates[0].Record_Type_Name__c).getRecordTypeId(),Case_Template_Name__c=lstCaseTemplates[0].Name);
        lstCasesToInsert.add(caseRec11);  //should not be inserted 
        setOppIds.add(lstOpportunities[0].Id);
        Case caseRec12= new Case(
            Opportunity__c=lstOpportunities[1].Id,
            Status = 'New',
            Requested_Type__c = lstCaseTemplates[0].Name,
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(lstCaseTemplates[0].Record_Type_Name__c).getRecordTypeId(),Case_Template_Name__c=lstCaseTemplates[0].Name);
        lstCasesToInsert.add(caseRec12);//should be inserted 
        Case caseRec13= new Case(
            Opportunity__c=lstOpportunities[1].Id,
            Status = 'New',
            Requested_Type__c = lstCaseTemplates[0].Name,
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(lstCaseTemplates[0].Record_Type_Name__c).getRecordTypeId(),Case_Template_Name__c=lstCaseTemplates[0].Name);
        lstCasesToInsert.add(caseRec13);//should not be inserted 
        Case caseRec15= new Case(
            AccountId=lstAccountsToInsert[0].Id,
            Status = 'New',
            Requested_Type__c = lstCaseTemplates[1].Name,
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(lstCaseTemplates[1].Record_Type_Name__c).getRecordTypeId(),Case_Template_Name__c=lstCaseTemplates[0].Name);
        lstCasesToInsert.add(caseRec15);//should be inserted 
        Case caseRec16= new Case(
            AccountId=lstAccountsToInsert[0].Id,
            Status = 'New',
            Requested_Type__c = lstCaseTemplates[1].Name,
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(lstCaseTemplates[1].Record_Type_Name__c).getRecordTypeId(),Case_Template_Name__c=lstCaseTemplates[1].Name);
        lstCasesToInsert.add(caseRec16);//should not be inserted 
        Case caseRec14 = new Case(
            AccountId = lstAccountsToInsert[1].Id,
            Status = 'New',
            Requested_Type__c = lstCaseTemplates[1].Name,
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(lstCaseTemplates[1].Record_Type_Name__c).getRecordTypeId(),Case_Template_Name__c=lstCaseTemplates[1].Name);
        Database.insert(lstCasesToInsert, false);
        System.assertEquals(null, caseRec11.Id);
        System.assertNotEquals(null, caseRec12.Id); 
        System.assertEquals(null, caseRec13.Id); 
        System.assertNotEquals(null, caseRec15.Id);
        System.assertEquals(null, caseRec16.Id);
        List<Case> lstCasesAfterInsert = [SELECT Requested_Type__c, AccountId, Opportunity__c, RecordTypeId, Status, Record_Type_Name__c FROM Case WHERE (Opportunity__c IN:setOppIds OR AccountId IN:setAccountIds)];
        try {
            insert caseRec14;
            System.assertEquals(null, caseRec14.Id);
            System.assert(false, 'exception expected for Case ' + caseRec14);
        } catch (Exception e) {
            System.assert(e.getMessage().contains('Duplicate case can not be created'), 'message=' + e.getMessage());
        }
        for(Case caseRec : lstCasesAfterInsert){
            if(caseRec.Id == caseRec12.Id){
                System.assertEquals(caseRec12.Requested_Type__c, caseRec.Requested_Type__c);
                System.assertEquals(caseRec12.AccountId, caseRec.AccountId);
                System.assertEquals(caseRec12.Case_Template__c, caseRec.Case_Template__c );
            } 
        }
        Test.stopTest();
    }
}