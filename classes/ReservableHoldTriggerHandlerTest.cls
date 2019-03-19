/************************************************************************************************************************************
Author          :   Shobhit Gahlot
Description     :   This class contains test methods for ReserVableHoldTrigger

History:
----------------------------------------------------------------------------------------------------------------------------------
VERSION     DATE                AUTHOR                          DETAIL
1           07 December 2017    Shobhit Gahlot                  Initial Developement
2           28 June 2018        Rupesh Patil                    Modifications
**************************************************************************************************************************************/
@isTest
public class ReservableHoldTriggerHandlerTest {
    
    @TestSetup 
    static void testDataSetup() {
        SalesConsoleSettings.createSettings();
        
        Map<String,Object> mapContactFieldValues = new Map<String,Object>();
        List<Contact> lstContacts = new List<Contact>();
        mapContactFieldValues.put('firstname','John');
        mapContactFieldValues.put('lastname','Rambo');
        mapContactFieldValues.put('email','test@example.com');
        mapContactFieldValues.put('Status__c','active');
        mapContactFieldValues.put('UUID__c','UUID1');
        lstContacts.add((Contact)TestingUtility.createTestRecords(Contact.sObjectType,mapContactFieldValues,false));
        
        mapContactFieldValues.put('firstname','John1');
        mapContactFieldValues.put('lastname','Rambo1');
        mapContactFieldValues.put('email','test1@example.com');
        mapContactFieldValues.put('Status__c','active');
        mapContactFieldValues.put('UUID__c','UUID2');
        lstContacts.add((Contact)TestingUtility.createTestRecords(Contact.sObjectType,mapContactFieldValues,false));
        
        mapContactFieldValues.put('firstname','John2');
        mapContactFieldValues.put('lastname','Rambo2');
        mapContactFieldValues.put('email','test2@example.com');
        mapContactFieldValues.put('Status__c','active');
        mapContactFieldValues.put('UUID__c','UUID3');
        lstContacts.add((Contact)TestingUtility.createTestRecords(Contact.sObjectType,mapContactFieldValues,false));        
        
        TestingUtility.insertListWithAssert(lstContacts); 
        System.debug('lstContacts==>'+lstContacts);
        
        Map<String,Object> mapAccountFieldValues = new Map<String,Object>();
        List<Account> lstAccounts = new List<Account>();
        mapAccountFieldValues.put('Name','Test Account') ; 
        mapAccountFieldValues.put('UUID__c','Test_Account_UUID') ;  
        lstAccounts.add((Account)TestingUtility.createTestRecords(Account.sObjectType,mapAccountFieldValues,false));
        
        mapAccountFieldValues.put('Name','Test Account1') ; 
        mapAccountFieldValues.put('UUID__c','Test_Account_UUID1') ;  
        lstAccounts.add((Account)TestingUtility.createTestRecords(Account.sObjectType,mapAccountFieldValues,false));
        
        mapAccountFieldValues.put('Name','Test Account2') ; 
        mapAccountFieldValues.put('UUID__c','Test_Account_UUID2') ;  
        lstAccounts.add((Account)TestingUtility.createTestRecords(Account.sObjectType,mapAccountFieldValues,false));

        TestingUtility.insertListWithAssert(lstAccounts); 
        Debug.log('lstAccounts==>'+lstAccounts);
        
        Map<String,Object> mapBillingAccountFieldValues = new Map<String,Object>();
        List<Billing_Account__c> lstBillAcc = new List<Billing_Account__c>();
        mapBillingAccountFieldValues.put('Name','TestBillingAccount');
        mapBillingAccountFieldValues.put('UUID__c','1234567');    
        mapBillingAccountFieldValues.put('Primary_Member__c',lstContacts[0].Id);
        mapBillingAccountFieldValues.put('Parent_Account__c',lstAccounts[0].Id);
        lstBillAcc.add((Billing_Account__c)TestingUtility.createTestRecords(Billing_Account__c.sObjectType,mapBillingAccountFieldValues,false));
       
        mapBillingAccountFieldValues.put('Name','TestBillingAccount2');
        mapBillingAccountFieldValues.put('UUID__c','2345678');    
        mapBillingAccountFieldValues.put('Primary_Member__c',lstContacts[1].Id);
        lstBillAcc.add((Billing_Account__c)TestingUtility.createTestRecords(Billing_Account__c.sObjectType,mapBillingAccountFieldValues,false));
        
        mapBillingAccountFieldValues.put('Name','TestBillingAccount3');
        mapBillingAccountFieldValues.put('UUID__c','3456789');    
        mapBillingAccountFieldValues.put('Primary_Member__c',lstContacts[2].Id);
        lstBillAcc.add((Billing_Account__c)TestingUtility.createTestRecords(Billing_Account__c.sObjectType,mapBillingAccountFieldValues,false));

        TestingUtility.insertListWithAssert(lstBillAcc);
        
        mapContactFieldValues.put('firstname','John3');
        mapContactFieldValues.put('lastname','Rambo3');
        mapContactFieldValues.put('email','test3@example.com');
        mapContactFieldValues.put('Status__c','active');
        mapContactFieldValues.put('UUID__c','UUID4');
        mapContactFieldValues.put('AccountId',lstAccounts[0].Id);
        mapContactFieldValues.put('Billing_Account__c',lstBillAcc[0].Id);
        Contact conRec3=(Contact)TestingUtility.createTestRecords(Contact.sObjectType,mapContactFieldValues,false);
        TestingUtility.insertWithAssert(conRec3);
        
        lstContacts[1].AccountId = lstAccounts[1].Id;
        lstContacts[2].AccountId = lstAccounts[2].Id;
        update lstContacts;
        
        Map<String,Object> mapBuilidingFieldValues = new Map<String,Object>();
        List<Building__c> lstBuilding = new List<Building__c>();
        mapBuilidingFieldValues.put('Name','Test Square');
        mapBuilidingFieldValues.put('City__c','DC-ChinaTown');
        mapBuilidingFieldValues.put('UUID__c','ec4b0820-59e4-0131-b9d5-3a00bb45c91f');
        lstBuilding.add((Building__c)TestingUtility.createTestRecords(Building__c.sObjectType,mapBuilidingFieldValues,false));
        
        mapBuilidingFieldValues.put('Name','Test1');
        mapBuilidingFieldValues.put('UUID__c','abc123');
        lstBuilding.add((Building__c)TestingUtility.createTestRecords(Building__c.sObjectType,mapBuilidingFieldValues,false));
       
        mapBuilidingFieldValues.put('Name','Test2');
        mapBuilidingFieldValues.put('UUID__c','abc1234');
        lstBuilding.add((Building__c)TestingUtility.createTestRecords(Building__c.sObjectType,mapBuilidingFieldValues,false));
        
        TestingUtility.insertListWithAssert(lstBuilding);
        
        List<Opportunity> lstOpportunities = new  List<Opportunity>();
        Opportunity oppRecForConsumer = TestingUtility.createOpportunityWithBillingAcc(lstBillAcc[1].Id, false);
        oppRecForConsumer.Primary_Member__c = lstContacts[1].Id;
        oppRecForConsumer.Building__c =  lstBuilding[0].Id;
        oppRecForConsumer.StageName = 'Selling';
        oppRecForConsumer.CloseDate = system.today().addDays(5);
        oppRecForConsumer.Membership_Agreement_Notes__c = 'Opprtunity 1 Membership_Agreement_Notes__c';
        oppRecForConsumer.Tour_Notes__c = 'Opprtunity 1 Tour_Notes__c';        
        oppRecForConsumer.Tour_Outcome_Notes__c = 'Opprtunity 1 Tour_Notes__c';
        oppRecForConsumer.Description = 'Opprtunity 1 Tour_Notes__c';
        oppRecForConsumer.Locations_Interested__c = lstBuilding[1].Name+';'+lstBuilding[2].Name;
        oppRecForConsumer.Owner_Auto_Assign__c = true;
        lstOpportunities.add(oppRecForConsumer);
        
        Opportunity oppRecForConsumer2 = TestingUtility.createOpportunityWithBillingAcc(lstBillAcc[2].Id, false);
        oppRecForConsumer2.Primary_Member__c = conRec3.Id;
        oppRecForConsumer2.StageName = 'Selling';
        oppRecForConsumer2.CloseDate = system.today().addDays(5);
        oppRecForConsumer2.Membership_Agreement_Notes__c = 'Opprtunity 1 Membership_Agreement_Notes__c';
        oppRecForConsumer2.Tour_Notes__c = 'Opprtunity 1 Tour_Notes__c';        
        oppRecForConsumer2.Tour_Outcome_Notes__c = 'Opprtunity 1 Tour_Notes__c';
        oppRecForConsumer2.Description = 'Opprtunity 1 Tour_Notes__c';
        oppRecForConsumer2.Locations_Interested__c = lstBuilding[1].Name+';'+lstBuilding[2].Name;
        oppRecForConsumer2.Owner_Auto_Assign__c = true;
        lstOpportunities.add(oppRecForConsumer2);
        debug.Log('Before insert oppRecForConsumer' + oppRecForConsumer);
        TestingUtility.insertListWithAssert(lstOpportunities);
        
        Map<String,Object> mapReservableFieldValues = new Map<String,Object>();
        mapReservableFieldValues.put('Building__c',lstBuilding[0].Id);
        mapReservableFieldValues.put('Name','Residential Unit-101');
        mapReservableFieldValues.put('Monthly_Price__c',50);
        mapReservableFieldValues.put('UUID__c','4f65bbe3-3997-4f9b-b3b6-54535f8247d6');
        Reservable__c residentialUnit1 = (Reservable__c)TestingUtility.createTestRecords(Reservable__c.sObjectType,mapReservableFieldValues,false);
       
        TestingUtility.insertWithAssert(residentialUnit1);
        
        Test.startTest();
        List<Reservable_Hold__c> lstHoldReservables = new List<Reservable_Hold__c>();
        Map<String,Object> mapReservableHoldFieldValues = new Map<String,Object>();
        mapReservableHoldFieldValues.put('Company_UUID__c',lstBillAcc[0].UUID__c);
        mapReservableHoldFieldValues.put('Reservable_UUID__c',residentialUnit1.UUID__c);
        mapReservableHoldFieldValues.put('starts_at__c',Date.today());
        mapReservableHoldFieldValues.put('expires_at__c',system.today().addDays(5));
        mapReservableHoldFieldValues.put('CurrencyIsoCode','USD');
        mapReservableHoldFieldValues.put('UUID__c','test');
        mapReservableHoldFieldValues.put('Contact_UUID__c',lstContacts[1].UUID__c);
        lstHoldReservables.add((Reservable_Hold__c)TestingUtility.createTestRecords(Reservable_Hold__c.sObjectType,mapReservableHoldFieldValues,false));

        mapReservableHoldFieldValues.put('Company_UUID__c',null);
        mapReservableHoldFieldValues.put('Reservable_UUID__c',residentialUnit1.UUID__c);
        mapReservableHoldFieldValues.put('expires_at__c',system.today().addDays(5));
        mapReservableHoldFieldValues.put('CurrencyIsoCode','USD');
        mapReservableHoldFieldValues.put('UUID__c','test2');
        mapReservableHoldFieldValues.put('Contact_UUID__c',conRec3.UUID__c);
        lstHoldReservables.add((Reservable_Hold__c)TestingUtility.createTestRecords(Reservable_Hold__c.sObjectType,mapReservableHoldFieldValues,false));

        mapReservableHoldFieldValues.put('Company_UUID__c',lstBillAcc[1].UUID__c);
        mapReservableHoldFieldValues.put('Reservable_UUID__c',residentialUnit1.UUID__c);
        mapReservableHoldFieldValues.put('expires_at__c',system.today().addDays(5));
        mapReservableHoldFieldValues.put('CurrencyIsoCode','USD');
        mapReservableHoldFieldValues.put('UUID__c','test3');
        mapReservableHoldFieldValues.put('Contact_UUID__c',lstContacts[2].UUID__c);
        lstHoldReservables.add((Reservable_Hold__c)TestingUtility.createTestRecords(Reservable_Hold__c.sObjectType,mapReservableHoldFieldValues,false));
       
        TestingUtility.insertListWithAssert(lstHoldReservables);
        Test.stopTest();
    }
    
    /************************************************************************************************************************************
        Author              :   Shobhit Gahlot
        Description         :   This test method used to validate SetAccConResOppForHold method of ReservableHoldTrigger
        Last Modified Date  :   30 June 2018
        Last Modified By    :   Rupesh Patil
    **************************************************************************************************************************************/        
    public static testMethod void verifySetAccConResOppForHold(){
        Test.startTest();
        List<Contact> lstContacts = [SELECT Id,LastName,UUID__c from Contact];
        List<Billing_Account__c> lstBillAcc = [SELECT Id,Name,UUID__c,Primary_Member__c,Parent_Account__c FROM Billing_Account__c];
        List<Reservable_Hold__c> lstHoldReservables = [SELECT Id,name,Account__c,Opportunity__c,Opportunity__r.AccountID,Opportunity__r.Billing_Account__c,created_by_id__c,Billing_Account__c,Opportunity_For_Related_List__c,Contact__c,Approval_Status__c,Company_UUID__c,Reservable_UUID__c,expires_at__c,CurrencyIsoCode,UUID__c,Contact_UUID__c FROM Reservable_Hold__c ];
        List<Opportunity> lstOpportunities = [SELECT Id,Primary_Member__c,Building__c,StageName,CloseDate FROM Opportunity];
        Test.stopTest();
        System.assertEquals(lstOpportunities[0].Id,lstHoldReservables[2].Opportunity__c);
        System.assertEquals(lstOpportunities[0].Id, lstHoldReservables[2].Opportunity_For_Related_List__c);
        System.assertEquals(lstBillAcc[0].Id, lstHoldReservables[0].Billing_Account__c);
        System.assertEquals(lstBillAcc[0].Parent_Account__c,lstHoldReservables[0].Opportunity__r.AccountID);
        System.assertEquals('Hold',lstHoldReservables[0].Approval_Status__c);
        System.assertEquals(lstContacts[1].Id,lstHoldReservables[0].Contact__c);
        System.assertEquals(lstContacts[3].Id,lstHoldReservables[1].Contact__c);
        System.assertEquals(lstOpportunities[1].Id,lstHoldReservables[1].Opportunity__c);
        System.assertEquals(lstBillAcc[1].Id,lstHoldReservables[2].Billing_Account__c);
        System.assertEquals(lstContacts[2].Id, lstHoldReservables[2].Contact__c);
    }   
    
    /************************************************************************************************************************************
        Author              :   Samadhan Kadam
        Description         :   This test method used to validate sendHoldEmailAlerts method of ReservableHoldTrigger
        Last Modified Date  :   30 June 2018
        Last Modified By    :   Ashish Mishra
    **************************************************************************************************************************************/        
    public static testMethod void testSendHoldEmailAlerts(){
        
        List<Contact> lstContacts = new List<Contact>();
        Contact conRec = new Contact(firstname = 'John',lastname = 'Rambo',email = 'tests@example.com', Status__c = 'active', UUID__c='contact1uuid');
        lstContacts.add(conRec);
        insert lstContacts;
        
        List<Account> lstAccounts = new List<Account>();
        Account accRec = TestingUtility.createAccount('strAccountName', false);
        accRec.UUID__c = '123456789';
        accRec.Primary_Member__c=conRec.Id;
        accRec.RecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Mid Market').getRecordTypeId();
        insert accRec;  
        
        lstContacts[0].AccountId = accRec.Id;
        update lstContacts[0];
        
        List<Billing_Account__c> lstBillAcc = [SELECT Id,Name,UUID__c,Primary_Member__c,Parent_Account__c FROM Billing_Account__c];
        
        Profile weworkSystemAdmin = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        Map<String,Object> mapRegionSalesManager = new Map<String,Object>();
        mapRegionSalesManager.put('LastName','TestRegionSalesManager');
        mapRegionSalesManager.put('Username','TestRegionSalesManager@weworkexample.com');
        mapRegionSalesManager.put('Email','testregionsalesmanager@weworkexample.com');
        User RegionSalesManager = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, mapRegionSalesManager, true);
        
        Map<String,Object> mapTerritorySalesManager = new Map<String,Object>();
        mapTerritorySalesManager.put('LastName','TestTerritorySalesManager');
        mapTerritorySalesManager.put('Username','TestTerritorySalesManager@weworkexample.com');
        mapTerritorySalesManager.put('Email','testterritorysalesmanager@weworkexample.com');
        User TerritorySalesManager = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, mapTerritorySalesManager, true);
        
        Map<String,Object> mapPortfolioSalesManager = new Map<String,Object>();
        mapPortfolioSalesManager.put('LastName','TestPortfolioSalesManager');
        mapPortfolioSalesManager.put('Username','TestPortfolioSalesManager@weworkexample.com');
        mapPortfolioSalesManager.put('Email','testportfoliosalesmanager@weworkexample.com');
        User PortfolioSalesManager = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, mapPortfolioSalesManager, true);
        
        Map<String,Object> mapClusterSalesManager = new Map<String,Object>();
        mapClusterSalesManager.put('LastName','TestClusterSalesManager');
        mapClusterSalesManager.put('Username','TestClusterSalesManager@weworkexample.com');
        mapClusterSalesManager.put('Email','testclustersalesmanager@weworkexample.com');
        User ClusterSalesManager = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, mapClusterSalesManager, true);
        
        Map<String,Object> mapClusterSalesLead = new Map<String,Object>();
        mapClusterSalesLead.put('LastName','TestClusterSalesLead');
        mapClusterSalesLead.put('Username','TestClusterSalesLead@weworkexample.com');
        mapClusterSalesLead.put('Email','testclustersaleslead@weworkexample.com');
        User ClusterSalesLead = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, mapClusterSalesLead, true);
        
        Region__c regn = new Region__c(Name='Test Region',Region__c='Test Region',Regional_Sales_Manager__c=RegionSalesManager.Id);
        insert regn;
        System.assert(regn.Id!=null, 'Region not inserted');
        
        Territory__c tertry = new Territory__c(Name='Test Territory',Territory__c='Test Territory',RegionID__c=regn.Id,Territory_Sales_Manager__c=TerritorySalesManager.Id);
        insert tertry;
        System.assert(tertry.Id!=null, 'Territory not inserted');
        
        Market__c mrkt = new Market__c(Name='Test Portfolio',Portfolio__c='Test Portfolio',TerritoryId__c=tertry.Id,Portfolio_Sales_Manager__c=PortfolioSalesManager.Id);
        insert mrkt;
        System.assert(mrkt.Id!=null, 'Portfolio not inserted');
        
        Cluster__c clstr = new Cluster__c(Name='Test Cluster',Cluster_Sales_Manager__c=ClusterSalesManager.Id,Sales_Lead__c=ClusterSalesLead.Id);
        insert clstr;
        System.assert(clstr.Id!=null, 'Cluster not inserted');
        
        Building__c bldng = new Building__c(Name='Test Building',Cluster__c=clstr.Id,Market__c=mrkt.Id);
        insert bldng;
        Integer beforeInvocations = Limits.getEmailInvocations();
        system.assertEquals(0, beforeInvocations);
        debug.Log('beforeInvocations'+beforeInvocations);
        
        Reservable__c residentialUnit1 = new Reservable__c();
        residentialUnit1.Building__c = bldng.Id;
        residentialUnit1.Name = 'Residential Unit-102';
        residentialUnit1.Monthly_Price__c = 50;
        residentialUnit1.UUID__c = '4f65bbe3-3997-4f9b-b3b6-54535f8247d8';
        TestingUtility.insertWithAssert(residentialUnit1);
        
        List<Opportunity> lstOpportunities = new  List<Opportunity>();
        Opportunity oppRecForConsumer = TestingUtility.createOpportunity(accRec.Id, false);      
        oppRecForConsumer.StageName = 'Selling';
        oppRecForConsumer.CloseDate = system.today().addDays(5);
        oppRecForConsumer.Membership_Agreement_Notes__c = 'Opprtunity 1 Membership_Agreement_Notes__c';
        oppRecForConsumer.Tour_Notes__c = 'Opprtunity 1 Tour_Notes__c';        
        oppRecForConsumer.Tour_Outcome_Notes__c = 'Opprtunity 1 Tour_Notes__c';
        oppRecForConsumer.Description = 'Opprtunity 1 Tour_Notes__c';
        oppRecForConsumer.Building__c = bldng.Id;
        lstOpportunities.add(oppRecForConsumer);
        
        Opportunity oppRecForConsumer1 = TestingUtility.createOpportunity(accRec.Id, false);
        //oppRecForConsumer.Primary_Member__c = conRec1.Id;
        oppRecForConsumer1.StageName = 'Selling';
        oppRecForConsumer1.CloseDate = system.today().addDays(5);
        oppRecForConsumer1.Membership_Agreement_Notes__c = 'Opprtunity 1 Membership_Agreement_Notes__c';
        oppRecForConsumer1.Tour_Notes__c = 'Opprtunity 1 Tour_Notes__c';        
        oppRecForConsumer1.Tour_Outcome_Notes__c = 'Opprtunity 1 Tour_Notes__c';
        oppRecForConsumer1.Description = 'Opprtunity 1 Tour_Notes__c';
        oppRecForConsumer1.Locations_Interested__c = bldng.Id;
        oppRecForConsumer1.Owner_Auto_Assign__c = true;
        lstOpportunities.add(oppRecForConsumer1);
        
        insert lstOpportunities;

        Test.startTest();
        
        Reservable_Hold__c newHold3 = new Reservable_Hold__c();
        newHold3.Company_UUID__c = lstBillAcc[0].UUID__c;
        newHold3.Reservable_UUID__c =  residentialUnit1.UUID__c;
        newHold3.starts_at__c = system.today().addDays(2);
        newHold3.expires_at__c = system.today().addDays(5);
        newHold3.CurrencyIsoCode = 'USD';
        newHold3.UUID__c = 'testhold';
        newHold3.Contact_UUID__c = lstContacts[0].UUID__c;
        insert newHold3;
        Integer afetrInvocation3 = Limits.getEmailInvocations();
        system.assertEquals(0, afetrInvocation3);
        
        Reservable_Hold__c newHold = new Reservable_Hold__c();
        newHold.Company_UUID__c = accRec.UUID__c;
        newHold.Reservable_UUID__c =  residentialUnit1.UUID__c;
        newHold.expires_at__c = system.today().addDays(5);
        newHold.CurrencyIsoCode = 'USD';
        newHold.UUID__c = 'test';
        newHold.Approval_Status__c = 'Hold';
        newHold.Opportunity__c = lstOpportunities[0].Id;
        newHold.Contact_UUID__c = lstContacts[0].UUID__c;
        insert newHold;
        
        List<Reservable_Hold__c> resHold = [Select Id,Name from Reservable_Hold__c where Id=:newHold.Id];
        debug.Log('resHold Id'+resHold[0].Id);
        Integer afetrInvocation = Limits.getEmailInvocations();
        system.assertEquals(1, afetrInvocation);
        debug.log('afetrInvocation-->'+afetrInvocation);
        Opportunity opp = [SELECT ID,Name,Regional_Sales_Manager_Email__c,Territory_Sales_Manager_Email__c,Portfolio_Sales_Manager_Email__c FROM Opportunity WhERE ID=: lstOpportunities[0].Id];
        system.assertEquals('testregionsalesmanager@weworkexample.com', opp.Regional_Sales_Manager_Email__c);

        Reservable_Hold__c newHold1 = new Reservable_Hold__c();
        newHold1.Company_UUID__c = accRec.UUID__c;
        newHold1.Reservable_UUID__c =  residentialUnit1.UUID__c;
        newHold1.expires_at__c = system.today().addDays(5);
        newHold1.CurrencyIsoCode = 'USD';
        newHold1.UUID__c = 'test123';
        newHold1.Send_Reminder_Alert__c = false;
        newHold1.Reminder_After_21_Days__c = false;
        newHold1.Opportunity__c = lstOpportunities[1].Id;
        newHold1.Contact_UUID__c = lstContacts[0].UUID__c;
        insert newHold1;
        Integer afetrInvocation1 = Limits.getEmailInvocations();       
       
        system.assertEquals(1, afetrInvocation1);
        Debug.log('afetrInvocation1==>'+afetrInvocation1);
        
        newHold1.Approval_Status__c = 'Hold';
        update newHold1;
        Integer afetrInvocation2 = Limits.getEmailInvocations();
       
        system.assertEquals(2, afetrInvocation2);
        Debug.log('afetrInvocation1==>'+afetrInvocation2);
        
        newHold1.Send_Reminder_Alert__c = true;     
        newHold1.Reminder_After_21_Days__c = true;
        newHold1.Approval_Status__c = 'Released';
        update newHold1;
        system.assertEquals(false,String.isBlank(newHold1.Opportunity__c));
        
        Reservable_Hold__c newHold2 = new Reservable_Hold__c();
        newHold2.Company_UUID__c = accRec.UUID__c;
        newHold2.Reservable_UUID__c =  residentialUnit1.UUID__c;
        newHold2.expires_at__c = system.today().addDays(5);
        newHold2.CurrencyIsoCode = 'USD';
        newHold2.UUID__c = 'test123';
        newHold2.Send_Reminder_Alert__c = false;
        newHold2.Reminder_After_21_Days__c = false;
        newHold2.Opportunity__c = lstOpportunities[1].Id;
        newHold2.Contact_UUID__c = lstContacts[0].UUID__c;
        insert newHold2;
        
        newHold2.Approval_Status__c = 'Expired';
        newHold2.Send_Reminder_Alert__c = true;
        update newHold2;
        
        
        Test.stopTest();
    }
    
}