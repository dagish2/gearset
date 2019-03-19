@isTest
public class CreateOpportunityControllerTests {
    
    public static List<Lead> lstLeads = new List<Lead>();
    public static List<Account> lstAccounts = new List<Account>(); 
    public static List<Contact> lstContacts = new List<Contact>(); 
    public static List<Building__c> lstBuildings = new List<Building__c>();
    public static List<User> lstUser = new List<User>();
    public static List<Journey__c> lstJourneys = new List<Journey__c>();
    public static Account orgAccRec;
    
    @TestSetup
    static void initData(){
        SalesConsoleSettings.createSettings();
     
        Account orgAccRec;
        Profile objProfile1 = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        Profile objProfile2 = [SELECT Id FROM Profile WHERE Name = 'WeWork System Administrator'];
        User objUser1 = new User(Alias = 'testU', Email = 'testUserName1@example.com', 
                                 EmailEncodingKey = 'UTF-8', LastName = 'User', LanguageLocaleKey = 'en_US', 
                                 LocaleSidKey = 'en_US', ProfileId = objProfile1.Id, IsActive = true,
                                 TimeZoneSidKey = 'America/Los_Angeles', UserName = 'testUserName1@example.com',CommunityNickname = TestingUtility.createUserCommunityName());
        lstUser.add(objUser1);
        
        User objUser2 = new User(Alias = 'testU1',Email = 'testUser1LeadOwner@example.com', 
                                 EmailEncodingKey = 'UTF-8', LastName = 'User', LanguageLocaleKey = 'en_US', 
                                 LocaleSidKey = 'en_US', ProfileId = objProfile2.Id, IsActive = true,
                                 TimeZoneSidKey = 'America/Los_Angeles', UserName = 'testUser1LeadOwner@example.com',CommunityNickname = TestingUtility.createUserCommunityName());
        lstUser.add(objUser2); 
        TestingUtility.insertListWithAssert(lstUser); 
        
        //Groups
        List<Group>  lstGroup = new List<Group>();
        Group testGroup = new Group(Name = 'New_Org_Request_Recipient_Queue', type = 'Queue');
        lstGroup.add(testGroup);
        TestingUtility.insertListWithAssert(lstGroup);
        System.runAs(new User(Id = UserInfo.getUserId())){
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SobjectType = 'Case');
            insert testQueue;
            GroupMember member = new GroupMember();
            member.UserOrGroupId = lstUser[1].Id;
            member.GroupId = testGroup.Id;  
            insert member;
            
        } 
        //Buildings 
        lstBuildings.add(new Building__c(Name = 'Building1', UUID__c = '15318_1', Email__c = 'Building1@example.com')); 
        TestingUtility.insertListWithAssert(lstBuildings);
        
        //OrgAccount
        orgAccRec = new Account(Name = 'orgAccRec',Number_of_Full_Time_Employees__c = 1000, Account_Type__c = 'Org', Unomy_Company_Name__c = 'orgAcc1');
        lstAccounts.add(orgAccRec);
       
        Account orgAccRec2 = new Account(Name = 'orgAccRec2',Number_of_Full_Time_Employees__c = 1000, Account_Type__c = 'Org', Unomy_Company_Name__c = 'orgAcc2');
        lstAccounts.add(orgAccRec2);
        
        Account objBill1 = new Account(Name = 'strAccountName1', Number_of_Full_Time_Employees__c=1000, Account_Type__c = 'Org', Unomy_Company_Name__c = 'strAccount1');
        lstAccounts.add(objBill1);
        
        Account objBill2 = new Account(Name = 'strAccountName2', Number_of_Full_Time_Employees__c = 1000, Account_Type__c = 'Org', Unomy_Company_Name__c = 'strAccount2');
        lstAccounts.add(objBill2);
        
        TestingUtility.insertListWithAssert(lstAccounts);
        lstAccounts.clear();
        
        //SalesAccounts
        Account objAcc1 = new Account(Name = 'strAccountName1',Nickname__c = 'strAcc',Account_Type__c = 'Sales',ParentId = orgAccRec.Id, UUID__c = 'ABC123-62481');
        lstAccounts.add(objAcc1); 
       
        Account objAcc2 = new Account(Name = 'strAccountName2',Nickname__c = 'strAcc2',Account_Type__c = 'Sales', UUID__c = 'ABC123-62483', ParentId = orgAccRec2.Id);
        lstAccounts.add(objAcc2);
        
        TestingUtility.insertListWithAssert(lstAccounts);
     
        //Insert Test Leads 
        Lead leadRec1 = new Lead(LastName = 'Doe', FirstName = 'John', 
                                 Email = 'john.smith1@example.com',
                                 Company = 'WeWork Inc',
                                 Locations_Interested__c = lstBuildings[0].Name,
                                 Generate_Journey__c = true,
                                 Account__c = orgAccRec.Id);  
        lstLeads.add(leadRec1); 
        
        Lead leadRec2 = new Lead(LastName = 'Doe', FirstName = 'John', 
                                Email = 'john.smith2@example.com',
                                Company = 'WeWork Inc',
                                Locations_Interested__c = lstBuildings[0].Name,
                                Generate_Journey__c = true);  
        
        lstLeads.add(leadRec2);
        
        Lead leadRec3 = new Lead(LastName = 'Doe', FirstName = 'John', 
                                 Email = 'john.smith3@example.com',
                                 Company = 'WeWork Inc',
                                 Locations_Interested__c = lstBuildings[0].Name,
                                 Generate_Journey__c = true,
                                 Account__c = objAcc1.Id);  
        lstLeads.add(leadRec3); 
        
        TestingUtility.insertListWithAssert(lstLeads); 
        
        Contact objOrgcon = new Contact(firstname = 'John',lastname = 'Rambo',email = 'john.con1@example.com', AccountId = orgAccRec.Id, Status__c = 'active');
        lstContacts.add(objOrgcon);
        Contact objSalesCon = new Contact(firstname = 'John',lastname = 'Rambo',email = 'john.con2@example.com', AccountId = objAcc1.Id, Status__c = 'active');
        lstContacts.add(objSalesCon);
        Contact objBillCon = new Contact(firstname = 'John',lastname = 'Rambo',email = 'john.con3@example.com',  AccountId= objBill1.Id, Status__c = 'active');
        lstContacts.add(objBillCon);
        Contact objCon = new Contact(firstname = 'John',lastname = 'Rambo',email = 'john.con4@example.com', Status__c = 'active');
        lstContacts.add(objCon);
        Contact objSalesCon1 = new Contact(firstname = 'John',lastname = 'Rambo',email = 'john.con5@example.com', AccountId = objAcc2.Id, Status__c = 'active');
        lstContacts.add(objSalesCon1);
        Contact objBillCon1 = new Contact(firstname = 'John',lastname = 'Rambo',email = 'john.con6@example.com', AccountId= objBill2.Id, Status__c = 'active');
        lstContacts.add(objBillCon1);
        TestingUtility.insertListWithAssert(lstContacts); 
        
        Journey__c objOrgJourney = new Journey__c();
        objOrgJourney.Name = objOrgcon.LastName;
        objOrgJourney.Primary_Contact__c = objOrgcon.Id;
        objOrgJourney.Status__c = 'Started';
        objOrgJourney.Primary_Email__c = objOrgcon.Email;
        objOrgJourney.NMD_Next_Contact_Date__c = Date.today();
        lstJourneys.add(objOrgJourney); 
        
        Journey__c objSalesJourney = new Journey__c();
        objSalesJourney.Name = objSalesCon.LastName;
        objSalesJourney.Primary_Contact__c = objSalesCon.Id;
        objSalesJourney.Status__c = 'Started';
        objSalesJourney.Primary_Email__c = objSalesCon.Email;
        objSalesJourney.NMD_Next_Contact_Date__c = Date.today();
        lstJourneys.add(objSalesJourney); 
        
        Journey__c objBillJourney = new Journey__c();
        objBillJourney.Name = objBillCon.LastName;
        objBillJourney.Primary_Contact__c = objBillCon.Id;
        objBillJourney.Status__c = 'Started';
        objBillJourney.Primary_Email__c = objBillCon.Email;
        objBillJourney.NMD_Next_Contact_Date__c = Date.today();
        lstJourneys.add(objBillJourney); 
        
        Journey__c objOrgJourneyLead = new Journey__c();
        objOrgJourneyLead.Name = leadRec1.LastName;
        objOrgJourneyLead.Primary_Lead__c = leadRec1.Id;
        objOrgJourneyLead.Status__c = 'Started';
        objOrgJourneyLead.Primary_Email__c = leadRec1.Email;
        objOrgJourneyLead.NMD_Next_Contact_Date__c = Date.today();
        lstJourneys.add(objOrgJourneyLead);
        
        Journey__c objOrgJourneyLead1 = new Journey__c();
        objOrgJourneyLead1.Name = leadRec2.LastName;
        objOrgJourneyLead1.Primary_Lead__c = leadRec2.Id;
        objOrgJourneyLead1.Status__c = 'Started';
        objOrgJourneyLead1.Primary_Email__c = leadRec2.Email;
        objOrgJourneyLead1.NMD_Next_Contact_Date__c = Date.today();
        lstJourneys.add(objOrgJourneyLead1);
        
        Journey__c objOrgJourneyLead2 = new Journey__c();
        objOrgJourneyLead2.Name = leadRec3.LastName;
        objOrgJourneyLead2.Primary_Lead__c = leadRec3.Id;
        objOrgJourneyLead2.Status__c = 'Started';
        objOrgJourneyLead2.Primary_Email__c = leadRec3.Email;
        objOrgJourneyLead2.NMD_Next_Contact_Date__c = Date.today();
        lstJourneys.add(objOrgJourneyLead2);
        
        Journey__c objConJourney = new Journey__c();
        objConJourney.Name = objCon.LastName;
        objConJourney.Primary_Contact__c = objCon.Id;
        objConJourney.Status__c = 'Started';
        objConJourney.Primary_Email__c = objCon.Email;
        objConJourney.NMD_Next_Contact_Date__c = Date.today();
        lstJourneys.add(objConJourney); 
        TestingUtility.insertListWithAssert(lstJourneys);  
    }
    
/************************************************************************************************************************************
Author 			: Dipak Pawar
Description 	: This method tests the getRelatedRecordDetails() function.
Created Date	: 23 June 2018 
**************************************************************************************************************************************/
    public static testMethod void getRelatedRecordDetails(){ 
        Account orgAcc,orgAcc1, salesAcc, billAcc, salesAcc1, billAcc1;
        
        for(Account objAcc : [SELECT Id, Name, UUID__c, Unomy_Company_Name__c, Account_Type__c, ParentId, Parent_Org_Id__c FROM Account ]){
            if(objAcc.Account_Type__c == 'Org'){
                if(objAcc.Unomy_Company_Name__c == 'orgAcc1'){
                    orgAcc = objAcc;
                } else if(objAcc.Unomy_Company_Name__c == 'orgAcc2'){
                    orgAcc1 = objAcc;
                }else if(objAcc.Unomy_Company_Name__c == 'strAccount1'){
                    billAcc = objAcc;
                }else if(objAcc.Unomy_Company_Name__c == 'strAccount2'){
                    billAcc1 = objAcc;
                } 
            }else if(objAcc.Account_Type__c == 'Sales' && objAcc.UUID__c == 'ABC123-62481'){
                salesAcc = objAcc;
            }else if(objAcc.Account_Type__c == 'Sales' && objAcc.UUID__c == 'ABC123-62483'){
                salesAcc1 = objAcc;
            }
        }
        
        Test.startTest();
        CreateOpportunityController.RelatedRecordDetail record = (CreateOpportunityController.RelatedRecordDetail)JSON.deserialize(String.valueOf(CreateOpportunityController.getCreateOpportunityData(orgAcc.Id).data), CreateOpportunityController.RelatedRecordDetail.class);
        System.assertEquals(orgAcc.Id, record.ultimateParentAccountRecord.Id);
        
        record = (CreateOpportunityController.RelatedRecordDetail)JSON.deserialize(String.valueOf(CreateOpportunityController.getCreateOpportunityData(salesAcc.Id).data), CreateOpportunityController.RelatedRecordDetail.class);
        System.assertEquals(orgAcc.Id, record.ultimateParentAccountRecord.Id);
        
        record = (CreateOpportunityController.RelatedRecordDetail)JSON.deserialize(String.valueOf(CreateOpportunityController.getCreateOpportunityData(billAcc.Id).data), CreateOpportunityController.RelatedRecordDetail.class);
        System.assertEquals(billAcc.Id, record.ultimateParentAccountRecord.Id);
        
        record = (CreateOpportunityController.RelatedRecordDetail)JSON.deserialize(String.valueOf(CreateOpportunityController.getCreateOpportunityData(billAcc1.Id).data), CreateOpportunityController.RelatedRecordDetail.class);
        System.assertEquals(billAcc1.Id, record.ultimateParentAccountRecord.Id);
        
        
        Contact objOrgCon, objSalesCon, objBillCon, objConNoAcc, objSalesCon1, objBillCon1;
        
        for(contact objCon :[SELECT LastName, FirstName, UUID__c, Account_Name__c, Unomy_Company_Name__c, AccountId, Email FROM Contact]){
            if(objCon.Email == 'john.con1@example.com'){
                objOrgCon = objCon;
            }else if(objCon.Email == 'john.con2@example.com'){
                objSalesCon = objCon;
            }else if(objCon.Email == 'john.con3@example.com'){
                objBillCon = objCon;
            }else if(objCon.Email == 'john.con4@example.com'){
                objConNoAcc = objCon;
            }else if(objCon.Email == 'john.con5@example.com'){
                objSalesCon1 = objCon;
            }else if(objCon.Email == 'john.con6@example.com'){
                objBillCon1 = objCon;
            }
        }
        
        record = (CreateOpportunityController.RelatedRecordDetail)JSON.deserialize(String.valueOf(CreateOpportunityController.getCreateOpportunityData(objOrgCon.Id).data), CreateOpportunityController.RelatedRecordDetail.class);
        System.assertEquals(orgAcc.Id, record.ultimateParentAccountRecord.Id);
        
        record = (CreateOpportunityController.RelatedRecordDetail)JSON.deserialize(String.valueOf(CreateOpportunityController.getCreateOpportunityData(objSalesCon.Id).data), CreateOpportunityController.RelatedRecordDetail.class);
        System.assertEquals(orgAcc.Id, record.ultimateParentAccountRecord.Id);
        
        record = (CreateOpportunityController.RelatedRecordDetail)JSON.deserialize(String.valueOf(CreateOpportunityController.getCreateOpportunityData(objBillCon.Id).data), CreateOpportunityController.RelatedRecordDetail.class);
        System.assertEquals(billAcc.Id, record.ultimateParentAccountRecord.Id);
        
        if(objConNoAcc != null){
            record = (CreateOpportunityController.RelatedRecordDetail)JSON.deserialize(String.valueOf(CreateOpportunityController.getCreateOpportunityData(objConNoAcc.Id).data), CreateOpportunityController.RelatedRecordDetail.class);  
        }       
        
        record = (CreateOpportunityController.RelatedRecordDetail)JSON.deserialize(String.valueOf(CreateOpportunityController.getCreateOpportunityData(objBillCon1.Id).data), CreateOpportunityController.RelatedRecordDetail.class);
        System.assertEquals(billAcc1.Id, record.ultimateParentAccountRecord.Id);
        
        Lead objOrgLead, objOrgLead1, objOrgLead2;
        
        for(Lead objLead :[SELECT LastName, FirstName, Email, Company, Unomy_Company_Name__c, LeadSource, Lead_Source_Detail__c, Account__c FROM Lead]){
            if(objLead.Email == 'john.smith1@example.com'){
                objOrgLead=objLead;
            }else if(objLead.Email == 'john.smith2@example.com'){
                objOrgLead1=objLead;
            } else if(objLead.Email == 'john.smith3@example.com'){
                objOrgLead2=objLead;
            }  
        }
        
        record = (CreateOpportunityController.RelatedRecordDetail)JSON.deserialize(String.valueOf(CreateOpportunityController.getCreateOpportunityData(objOrgLead.Id).data), CreateOpportunityController.RelatedRecordDetail.class);
        System.assertEquals(orgAcc.Id, record.ultimateParentAccountRecord.Id);
        
        record = (CreateOpportunityController.RelatedRecordDetail)JSON.deserialize(String.valueOf(CreateOpportunityController.getCreateOpportunityData(objOrgLead1.Id).data), CreateOpportunityController.RelatedRecordDetail.class);
        System.assertNotEquals(null, record.ultimateParentAccountRecord.Id);
        
        record = (CreateOpportunityController.RelatedRecordDetail)JSON.deserialize(String.valueOf(CreateOpportunityController.getCreateOpportunityData(objOrgLead2.Id).data), CreateOpportunityController.RelatedRecordDetail.class);
        System.assertEquals(orgAcc.Id, record.ultimateParentAccountRecord.Id);
        
        Journey__c objOrgJourney, objSalesJourney, objBillJourney, objOrgJourneyLead, objOrgJourneyLead1, objOrgJourneyLead2, objConJourney;
        for(Journey__c objJourney : [SELECT  Name, Primary_Contact__c , Status__c, Primary_Email__c, Primary_Lead__c, Unomy_Company_Name__c FROM Journey__c]){
            if(objJourney.Primary_Lead__c == null){
                if(objJourney.Primary_Email__c == 'john.con1@example.com'){
                    objOrgJourney = objJourney;
                }else if(objJourney.Primary_Email__c == 'john.con2@example.com'){
                    objSalesJourney = objJourney;
                }else if(objJourney.Primary_Email__c == 'john.con3@example.com'){
                    objBillJourney = objJourney;
                }else if(objJourney.Primary_Email__c == 'john.con4@example.com'){
                    objConJourney = objJourney;
                }
            } else {
                if(objJourney.Primary_Email__c == 'john.smith1@example.com'){
                    objOrgJourneyLead = objJourney;
                }else if(objJourney.Primary_Email__c == 'john.smith2@example.com'){
                    objOrgJourneyLead1 = objJourney;
                }else if(objJourney.Primary_Email__c == 'john.smith3@example.com'){
                    objOrgJourneyLead2 = objJourney;
                } 
            } 
        }
        
        record = (CreateOpportunityController.RelatedRecordDetail)JSON.deserialize(String.valueOf(CreateOpportunityController.getCreateOpportunityData(objOrgJourney.Id).data), CreateOpportunityController.RelatedRecordDetail.class);
        System.assertEquals(orgAcc.Id, record.ultimateParentAccountRecord.Id);
        
        record = (CreateOpportunityController.RelatedRecordDetail)JSON.deserialize(String.valueOf(CreateOpportunityController.getCreateOpportunityData(objSalesJourney.Id).data), CreateOpportunityController.RelatedRecordDetail.class);
        System.assertEquals(orgAcc.Id, record.ultimateParentAccountRecord.Id);
        
        record = (CreateOpportunityController.RelatedRecordDetail)JSON.deserialize(String.valueOf(CreateOpportunityController.getCreateOpportunityData(objBillJourney.Id).data), CreateOpportunityController.RelatedRecordDetail.class);
        System.assertEquals(billAcc.Id, record.ultimateParentAccountRecord.Id);
        
        record = (CreateOpportunityController.RelatedRecordDetail)JSON.deserialize(String.valueOf(CreateOpportunityController.getCreateOpportunityData(objOrgJourneyLead.Id).data), CreateOpportunityController.RelatedRecordDetail.class);
        System.assertEquals(orgAcc.Id, record.ultimateParentAccountRecord.Id);
        Test.stopTest(); 
        
        record = (CreateOpportunityController.RelatedRecordDetail)JSON.deserialize(String.valueOf(CreateOpportunityController.getCreateOpportunityData(objConJourney.Id).data), CreateOpportunityController.RelatedRecordDetail.class);
        System.assertNotEquals(null, record.ultimateParentAccountRecord.Id);
        
        record = (CreateOpportunityController.RelatedRecordDetail)JSON.deserialize(String.valueOf(CreateOpportunityController.getCreateOpportunityData(objOrgJourneyLead2.Id).data), CreateOpportunityController.RelatedRecordDetail.class);
        System.assertEquals(orgAcc.Id, record.ultimateParentAccountRecord.Id);
        
        record = (CreateOpportunityController.RelatedRecordDetail)JSON.deserialize(String.valueOf(CreateOpportunityController.getCreateOpportunityData(objOrgJourneyLead1.Id).data), CreateOpportunityController.RelatedRecordDetail.class);
        System.assertNotEquals(null, record.ultimateParentAccountRecord.Id);
    }
    
    /************************************************************************************************************************************
    Author 			: Dipak Pawar
    Description 	: This method tests the convertEnterpriseLead() function.
    Created Date	: 23 June 2018 
    **************************************************************************************************************************************/
    public static testMethod void verifyconvertEnterpriseLeadTest(){   
        User sysUser;
        User weUser;
        for(User objUser : [SELECT Id, IsActive, Email  FROM User]){
            if(objUser.Email == 'testUserName1@example.com'){
                sysUser=objUser;
            } else if(objUser.Email == 'testUser1LeadOwner@example.com'){
                weUser = objUser;
            }
        }
        Lead objOrgLead1, objOrgLead2, objOrgLead3;
        
        for(Lead objLead :[SELECT LastName, FirstName, Email, Company, LeadSource, Lead_Source_Detail__c, Account__c FROM Lead ]){
            if(objLead.Email == 'john.smith1@example.com'){
                objOrgLead1=objLead;
            }else if(objLead.Email == 'john.smith2@example.com'){
                objOrgLead2=objLead;
            }else if(objLead.Email == 'john.smith3@example.com'){
                objOrgLead3=objLead;
            }
        } 
        objOrgLead1.OwnerId = sysUser.Id;
        
        Account orgAcc, orgAcc1;
        for(Account objAcc : [SELECT Id, Name, UUID__c, Account_Type__c, ParentId, Unomy_Company_Name__c, Parent_Org_Id__c FROM Account ]){
            if(objAcc.Account_Type__c == 'Org'){
                if(objAcc.Unomy_Company_Name__c == 'orgAcc1'){
                    orgAcc = objAcc;
                } else if(objAcc.Unomy_Company_Name__c == 'orgAcc2'){
                    orgAcc1 = objAcc;
                }
            }
        }    
        
        Test.startTest();
        Map<String, Object> mapEntity = new Map<String,Object>(); 
        Contact objSalesCon = [SELECT LastName, FirstName, UUID__c, AccountId, Email, (SELECT Id, Name FROM Journeys__r) FROM Contact WHERE Email = 'john.con4@example.com' LIMIT 1];
        mapEntity.put('leadId', objOrgLead1.Id); 
        mapEntity.put('orgAccountId', objOrgLead1.Account__c);
        mapEntity.put('Email', objOrgLead1.Email);
        
        System.runAs(weUser){
            sysUser.IsActive = false;
            update sysUser; 
        }
        
        DatabaseResult result = CreateOpportunityController.convertEnterpriseLead(mapEntity);
        
        Map<String, Id> mapResult = (Map<String, Id>) JSON.deserialize(String.valueOf(result.data), Map<String, Id>.class);
        System.assertEquals(true, mapResult.containsKey('contactId'));
        System.assertNotEquals(null, mapResult.get('contactId'));
        System.assertNotEquals(null, mapResult.get('accountId'));
        System.assertEquals(objOrgLead1.Account__c, mapResult.get('accountId'));  
        
        mapEntity.put('leadId', objOrgLead2.Id); 
        mapEntity.put('orgAccountId', orgAcc.Id);
        mapEntity.put('Email', objSalesCon.Email);
        DatabaseResult resultObj = CreateOpportunityController.convertEnterpriseLead(mapEntity);
        Test.stopTest();
    }    
    
    /************************************************************************************************************************************
    Author              :   Priyanka Ambre
    Description         :   This test method is used to verify CreateOpportunity() when we pass Opportunity Record to the Method . 
    Created Date  		:   23 July 2018  
    Issue No			:	ST-2486
    ***************************************************************************************************************************************/
    static testMethod void verifyCreateEnterpriseOpportunity(){
        List<Building__c> lstBuildings = [SELECT Id, Name FROM Building__c];
        Contact objOrgCon = [SELECT LastName, FirstName, UUID__c, AccountId, Email, (SELECT Id, Name FROM Journeys__r) FROM Contact WHERE Email = 'john.con1@example.com' LIMIT 1];
        
        Opportunity objOppRec = new Opportunity(
            Do_Not_Create_Opportunity_Role__c = true,
            AccountId = objOrgCon.AccountId,
            LeadSource = 'WeWork.com',
            Owner_Auto_Assign__c = true,
            StageName = 'Qualifying',
            Decision_Maker__c = null,   
            Primary_Member__c = objOrgCon.Id,
            Interested_in_Number_of_Desks__c = 0,
            Building__c = lstBuildings[0].Id,
            CloseDate = system.today().addDays(5),
            Journey__c = objOrgCon.Journeys__r[0].Id
        );  
        Test.startTest();
        DatabaseResult result = CreateOpportunityController.createEnterpriseOpportunity(objOppRec);
        Opportunity objOppResponse =  (Opportunity)result.data;
        System.assertNotEquals(null, objOppResponse.Id);
        System.assertEquals(lstBuildings[0].Id, objOppResponse.Building__c);
        Test.stopTest();
    } 
}