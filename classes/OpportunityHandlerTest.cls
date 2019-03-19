/************************************************************************************************************************************
    Author      :   Amol Darekar
    Description :   This class will test the business logic of Opportunity Merge functionality.

    History:
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  ISSUE			DETAIL 
    1           06 April 2017       Amol Darekar            ST-987			Initial Developement
    2           13 June 2016        Amol Darekar            -				Made changes for related object move
	3			-					Milanjeet Singh 		ST-1628			Made required changes for opportunity merge functionality
	4			18 July 2018 		Krishana Tupe 			-				Code optimization and changes in opportunity merge functionality.
**************************************************************************************************************************************/
@isTest
private class OpportunityHandlerTest {
    public static string primaryOppId {get;set;}
    public static string OppId1 {get;set;}
    public static string OppId2 {get;set;}    
    
    static{        
        SalesConsoleSettings.createSettings();
        Setting__c OpportunityTeamMemberCreationSetting = Settings.get('OpportunityTeamMemberCreationSetting');
        debug.log('OpportunityTeamMemberCreationSetting ::'+OpportunityTeamMemberCreationSetting);
        Set<String> setRoles=new Set<String>();
        if(OpportunityTeamMemberCreationSetting != null){
            setRoles = (Set<String>)(JSON.deserialize(OpportunityTeamMemberCreationSetting.Data__c.toLowerCase(), Set<String>.class));
            debug.log('setRoles ::'+setRoles);
        }
        List<User> userDetails =[SELECT Id, UserRole.Name FROM User where UserRole.Name  NOT IN : setRoles AND ISActive=True LIMIT 5];
        debug.log('userDetails==='+userDetails);
        if(userDetails!=null){
            System.runAs(userDetails[1]) {         
                Account accRec = TestingUtility.createAccount('strAccountName', true);
               
                list<Contact> lstContactTest = new list<Contact>();
                Contact conRec = new Contact(
                    firstname  = 'John',
                    lastname   = 'Rambo',
                    email     = 'test0.contact0@example.com',
                    accountID  = accRec.Id,
                    Status__c  = 'active'
                );
                lstContactTest.add(conRec);
                
                conRec = new Contact(
                    firstname  = 'John',
                    lastname   = 'Rambo_1',
                    email     = 'test1.contact1@example.com',
                    accountID  = accRec.Id,
                    Status__c  = 'active'
                );
                lstContactTest.add(conRec);
                
                conRec = new Contact(
                    firstname  = 'John',
                    lastname   = 'Rambo_2',
                    email     = 'test2.contact2@example.com',
                    accountID  = accRec.Id,
                    Status__c  = 'active'
                );
                
                lstContactTest.add(conRec);
                insert lstContactTest;
                
                Building__c b = new Building__c(
                    Name='Test1',
                    uuid__c = 'abc123'
                );
                insert b;
                
                b = new Building__c(
                    Name='Test2',
                    uuid__c = 'abc1234'
                );
                insert b;
                List<Opportunity> lstopp = new List<Opportunity>();
                Map<String, Id> oppRecordType = TestingUtility.getRecordTypeMapByName(Opportunity.sObjectType);
                //set<Id> setTestOppIds = new set<Id>();
                
                Opportunity oppRec = TestingUtility.createOpportunity(accRec.Id, false);
                oppRec.Primary_Member__c = conRec.Id;
                oppRec.StageName = 'Selling';
                oppRec.CloseDate = system.today().addDays(5);
                oppRec.RecordTypeId = oppRecordType.get('Consumer');
                oppRec.Membership_Agreement_Notes__c = 'Opprtunity 1 Membership_Agreement_Notes__c';
                oppRec.Tour_Notes__c = 'Opprtunity 1 Tour_Notes__c';
                oppRec.Tour_Outcome_Notes__c = 'Opprtunity 1 Tour_Notes__c';
                oppRec.Description = 'Opprtunity 1 Tour_Notes__c';
                oppRec.Locations_Interested__c = 'Test2;';
                oppRec.CurrencyIsoCode='USD';           
                lstopp.add(oppRec);
                
                Opportunity oppRec1 = TestingUtility.createOpportunity(accRec.Id, false);
                oppRec1.Primary_Member__c = conRec.Id;
                oppRec1.StageName = 'Selling';
                oppRec1.CloseDate = system.today().addDays(5);
                oppRec1.RecordTypeId = oppRecordType.get('Enterprise Solutions');
                oppRec1.Membership_Agreement_Notes__c = 'Opprtunity 2 Membership_Agreement_Notes__c';
                oppRec1.Tour_Notes__c = 'Opprtunity 2 Tour_Notes__c';
                oppRec1.Tour_Outcome_Notes__c = 'Opprtunity 2 Tour_Notes__c';
                oppRec1.Description = 'Opprtunity 2 Tour_Notes__c';
                oppRec1.Locations_Interested__c = 'Test1;Test2;';
                oppRec1.Amount = 10;
                oppRec1.CurrencyIsoCode='USD';           
                lstopp.add(oppRec1); 
                
                Opportunity oppRec2 = TestingUtility.createOpportunity(accRec.Id, false);
                oppRec2.Primary_Member__c = conRec.Id;
                oppRec2.StageName = 'Selling';
                oppRec2.CloseDate = system.today().addDays(5);
                oppRec2.RecordTypeId = oppRecordType.get('Enterprise Solutions');
                oppRec2.Membership_Agreement_Notes__c = 'Opprtunity 3 Membership_Agreement_Notes__c';
                oppRec2.Tour_Notes__c = 'Opprtunity 3 Tour_Notes__c';
                oppRec2.Tour_Outcome_Notes__c = 'Opprtunity 3 Tour_Notes__c';
                oppRec2.Description = 'Opprtunity 3 Tour_Notes__c';
                oppRec2.Amount = 10;
                oppRec2.CurrencyIsoCode='USD';            
                lstopp.add(oppRec2); 
                TestingUtility.insertListWithAssert(lstopp);
                
                primaryOppId = lstopp[0].Id;
                OppId1=lstopp[1].Id;
                OppId2 = lstopp[2].Id;
                debug.log('Static block End==>');
                
            }   
        }
          
    }
      /*****************************************************************************************************************************************
        Author              :   Amol Darekar
        Description         :   This method is used to test mergeOpprtunitiesNotes function.
        Created Date        :   06 April 2017
		Issue 				: 	ST-987,ST-1027  
  ****************************************************************************************************************************************
		Modified By      	:   Krishana Tupe 
 		Last Modified Date  :   18 July 2018 		
  *******************************************************************************************************************************************/
    static testMethod void mergeOpprtunitiesNotesTest() {       
        map<Id,Opportunity> mapOpprtunity = new map<Id,Opportunity>([SELECT Id,Merged_Opprtunity__c from Opportunity]);
        list<string> lstTestOpportunities = new list<string>();        
        OpportunityHandler.getUserId();
        
        Test.startTest();
        OpportunityHandler.mergeOpprtunities(JSON.serialize(mapOpprtunity.keySet()),primaryOppId);
        list<Opportunity> lstOpprtunity = [SELECT Id,Merged_Opprtunity__c from Opportunity where Id !=: primaryOppId];
        mapOpprtunity = new map<Id,Opportunity>([SELECT Id,Merged_Opprtunity__c from Opportunity where Id !=: primaryOppId]);
        for(Opportunity currentOpp :mapOpprtunity.values()){
            debug.log('Current Opp:'+currentOpp);
            system.assertEquals(currentOpp.Merged_Opprtunity__c, primaryOppId);
        }
        Test.stopTest();
    }   
    
    static testMethod void insertPriseBookForOpportunityTest() {
        //thePricebookEntry.CurrencyIsoCode = this.theOpportunity.CurrencyIsoCode;
        Id pricebookId = Test.getStandardPricebookId();
        map<Id,Opportunity> mapOpprtunity = new map<Id,Opportunity>([SELECT Id,Merged_Opprtunity__c from Opportunity]);
        Test.startTest();
        
        //Create your product
        Product2 prod = new Product2(
            Name = 'Product X',
            ProductCode = 'Pro-X',
            isActive = true,
            Default_Product_Category__c='Custom Office'
        );
        insert prod;
        
        //Create your pricebook entry
        Opportunity opptest = [Select Id,CurrencyIsoCode from Opportunity Where Id=:OppId2];
        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            UnitPrice = 100.00,
            IsActive = true,
            CurrencyIsoCode = opptest.CurrencyIsoCode
        );
        insert pbEntry;
        //create your opportunity line item.  This assumes you already have an opportunity created, called opp
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = OppId2,
            Quantity = 5,
            PricebookEntryId = pbEntry.Id,
            TotalPrice = 5 * pbEntry.UnitPrice
        );
        insert oli;
        
        list<Opportunity> lstTestOpportunty = [SELECT Pricebook2Id FROM Opportunity WHERE Id =: OppId2];
        system.assertEquals(lstTestOpportunty[0].Pricebook2Id,pricebookId);
        
        // Insert a test product.
        prod = new Product2(
            Name = 'Laptop X200', 
            Family = 'Hardware',
            isActive = true,
            Default_Product_Category__c='Custom Office');
        insert prod;
        
        // Create a custom price book
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
        // 2. Insert a price book entry with a custom price.
        PricebookEntry pbEntry2 = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            UnitPrice = 100,
            IsActive = true,
            CurrencyIsoCode='USD'
        );
        insert pbEntry2;
        
        //create your opportunity line item.  This assumes you already have an opportunity created, called opp        
        OpportunityLineItem oli2 = new OpportunityLineItem(
            OpportunityId = OppId1,
            Quantity = 5,
            PricebookEntryId = pbEntry2.Id,
            TotalPrice = 100
        );
        insert oli2;
        Test.stopTest();
        list<OpportunityLineItem> lstTestOpportunityLineItem = [SELECT Id from OpportunityLineItem WHERE OpportunityId =:primaryOppId];
        system.assertEquals(0,lstTestOpportunityLineItem.size());
        
        OpportunityHandler.mergeOpprtunities(JSON.serialize(mapOpprtunity.keySet()),primaryOppId);
        lstTestOpportunityLineItem = [SELECT Id from OpportunityLineItem WHERE OpportunityId =:primaryOppId];
        system.assertEquals(2,lstTestOpportunityLineItem.size());
        
    }
    
    static testMethod void insertOppContactRoleTest() {        
        List<contact>lstContacTest = [SELECT Id,email FROM contact];
        map<String,Id> mapTestContactMap = new map<String,Id>();
        
        for(contact  currentTestConact: lstContacTest){
            mapTestContactMap.put(currentTestConact.email,currentTestConact.Id);
        }
        
        map<Id,Opportunity> mapOpprtunity = new map<Id,Opportunity>([SELECT Id,Merged_Opprtunity__c from Opportunity]);        
        system.assertEquals(3,mapOpprtunity.size());
        
        list<OpportunityContactRole> lstTestOppContactRoles = new list<OpportunityContactRole>();
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = mapTestContactMap.get('test0.contact0@example.com');
        ocr.OpportunityId = primaryOppId;
        ocr.IsPrimary = TRUE;
        ocr.Role = 'Decision Maker';
        lstTestOppContactRoles.add(ocr);
        
        ocr = new OpportunityContactRole();	
        ocr.ContactId = mapTestContactMap.get('test1.contact1@example.com');
        ocr.OpportunityId = OppId1;
        ocr.IsPrimary = FALSE;
        ocr.Role = 'Economic Decision Maker';
        lstTestOppContactRoles.add(ocr);
        
        
        ocr = new OpportunityContactRole();	
        ocr.ContactId = mapTestContactMap.get('test1.contact1@example.com');
        ocr.OpportunityId = OppId1;
        ocr.IsPrimary = FALSE;
        ocr.Role = 'Economic Decision Maker';
        lstTestOppContactRoles.add(ocr);
        Test.startTest();
        insert lstTestOppContactRoles;
        
        lstTestOppContactRoles = [SELECT Id,Contact.Email from OpportunityContactRole];
        debug.Log('lstTestOppContactRoles------'+lstTestOppContactRoles);
        system.assertEquals(6,lstTestOppContactRoles.size());        
        lstTestOppContactRoles = [SELECT Id from OpportunityContactRole WHERE opportunityId =:primaryOppId];
        system.assertEquals(2,lstTestOppContactRoles.size());
        OpportunityHandler.mergeOpprtunities(JSON.serialize(mapOpprtunity.keySet()),primaryOppId);
        lstTestOppContactRoles = [SELECT Id from OpportunityContactRole WHERE opportunityId =:primaryOppId];
        system.assertEquals(4,lstTestOppContactRoles.size());
        Test.stopTest();
    }
    
    static testMethod void insertOppTeamTest() {        
        map<Id,Opportunity> mapOpprtunity = new map<Id,Opportunity>([SELECT Id,Merged_Opprtunity__c from Opportunity]);
        Profile weworkSystemAdmin = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        Map<String,Object> userRecordMap = new Map<String,Object>();
        userRecordMap.put('LastName','Last Name 1');
        userRecordMap.put('Username','testweworkuser1@example.com');
        userRecordMap.put('Email','testweworkuser1@example.com');
        User testUser = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, userRecordMap, true);
    }
    
    static testMethod void insertDocusignStatusTest() {
        map<Id,Opportunity> mapOpprtunity = new map<Id,Opportunity>([SELECT Id,Merged_Opprtunity__c from Opportunity]);       
        list<dsfs__DocuSign_Status__c> lstTestDocusignInsert = new list<dsfs__DocuSign_Status__c>();
        dsfs__DocuSign_Status__c objTestDocusign = new dsfs__DocuSign_Status__c();
        objTestDocusign.dsfs__Opportunity__c = OppId1;
        objTestDocusign.dsfs__Sender_Email__c = 'test@example.com';
        objTestDocusign.dsfs__Subject__c = 'This is test subject';
        lstTestDocusignInsert.add(objTestDocusign);
        insert lstTestDocusignInsert;
        
        //Before function call there should be no docusign status record on Primary Opportunity
        lstTestDocusignInsert = [SELECT Id FROM dsfs__DocuSign_Status__c WHERE dsfs__Opportunity__c =:primaryOppId]; 
        system.assertEquals(0,lstTestDocusignInsert.size());
        
        /*Insert oppTeams Records*/
        
        Profile weworkSystemAdmin = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        Map<String,Object> userRecordMap = new Map<String,Object>();
        userRecordMap.put('LastName','Last Name 1');
        userRecordMap.put('Username','testweworkuser1@example.com');
        userRecordMap.put('Email','testweworkuser1@example.com');
        User testUser = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, userRecordMap, true);
        
        list<OpportunityTeamMember> NewTestOppteam = new list<OpportunityTeamMember>();
        OpportunityTeamMember opt = new OpportunityTeamMember();
        opt.Opportunityid = OppId1;
        opt.UserId = UserInfo.getUserId();
        opt.TeamMemberRole = 'Account Manager';
        NewTestOppteam.add(opt);
        
        opt = new OpportunityTeamMember();
        opt.Opportunityid = OppId2;
        opt.UserId = testUser.Id;
        opt.TeamMemberRole = 'Lead Qualifire';
        NewTestOppteam.add(opt);
        
        insert NewTestOppteam;
        
        /*Insert Opportunity Contact Roles*/
        
        list<contact>lstContacTest = [SELECT Id,email FROM contact];
        map<String,Id> mapTestContactMap = new map<String,Id>();
        
        for(contact  currentTestConact: lstContacTest){
            mapTestContactMap.put(currentTestConact.email,currentTestConact.Id);
        }
        
        list<OpportunityContactRole> lstTestOppContactRoles = new list<OpportunityContactRole>();
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = mapTestContactMap.get('test0.contact0@example.com');
        ocr.OpportunityId = primaryOppId;
        ocr.IsPrimary = TRUE;
        ocr.Role = 'Decision Maker';
        lstTestOppContactRoles.add(ocr);
        
        //Now update the OCR for the non-primary contact
        ocr = new OpportunityContactRole();	
        ocr.ContactId = mapTestContactMap.get('test1.contact1@example.com');
        ocr.OpportunityId = OppId1;
        ocr.IsPrimary = FALSE;
        ocr.Role = 'Economic Decision Maker';
        lstTestOppContactRoles.add(ocr);
        test.startTest();
        //Now update the OCR for the non-primary contact
        ocr = new OpportunityContactRole();	
        ocr.ContactId = mapTestContactMap.get('test1.contact1@example.com');
        ocr.OpportunityId = OppId1;
        ocr.IsPrimary = FALSE;
        ocr.Role = 'Economic Decision Maker';
        lstTestOppContactRoles.add(ocr);
        insert lstTestOppContactRoles;
        
        lstTestOppContactRoles = [SELECT Id from OpportunityContactRole];
        system.assertEquals(6,lstTestOppContactRoles.size());
        
        lstTestOppContactRoles = [SELECT Id from OpportunityContactRole WHERE opportunityId =:primaryOppId];
        system.assertEquals(2,lstTestOppContactRoles.size());
        
        NewTestOppteam = [SELECT Id FROM OpportunityTeamMember WHERE Opportunityid =:primaryOppId];
        Debug.log('NewTestOppteam==>'+NewTestOppteam);
        system.assertEquals(1,NewTestOppteam.size());
        
        /* Call to merge opportunity function */
        OpportunityHandler.mergeOpprtunities(JSON.serialize(mapOpprtunity.keySet()),primaryOppId);
        
        //Afer function call there should be 2 opportunity team member ib primary opportunity
        NewTestOppteam = [SELECT Id,User.Name,User.Email FROM OpportunityTeamMember WHERE Opportunityid =:primaryOppId];        
       // system.assertEquals(2,NewTestOppteam.size());
        
        //OpportunityHandler.mergeOpprtunities(JSON.serialize(mapOpprtunity.keySet()),primaryOppId);
        
        //After function call there should be one docusign record on primary opportunity
        lstTestDocusignInsert = [SELECT Id FROM dsfs__DocuSign_Status__c WHERE dsfs__Opportunity__c =:primaryOppId]; 
        system.assertEquals(1,lstTestDocusignInsert.size());
        
        //After funtion call there should be 3 contact roles on primary opportunity.
        lstTestOppContactRoles = [SELECT Id from OpportunityContactRole WHERE opportunityId =:primaryOppId];
        system.assertEquals(4,lstTestOppContactRoles.size());
        test.stopTest();
    }
    
    static testMethod void addAttachmentToParent() {
        map<Id,Opportunity> mapOpprtunity = new map<Id,Opportunity>([SELECT Id,Merged_Opprtunity__c from Opportunity]);        
        ContentVersion cv = new ContentVersion(); 
        cv.Origin = 'H';
        cv.PathOnClient='myFile.txt';
        cv.Title ='myFile'; 
        cv.VersionData = Blob.valueOf('I am a file posting to Chatter');
        insert cv;
        
        FeedItem contentFI = new FeedItem();
        contentFI.Type = 'ContentPost';
        contentFI.ParentId = oppId1; // Opportunity
        contentFI.RelatedRecordId = cv.id;
        contentFI.title = 'Content Post';
        contentFI.Body = 'Body of content post';
        insert contentFI;
        
        list<ContentDocument> lstContentDocumentTest = [SELECT Id FROM ContentDocument];
        system.assertEquals(1,lstContentDocumentTest.size());
        
        list<ContentDocumentLink> lstDocLink = [SELECT linkedentityid,contentdocumentid,sharetype,visibility FROM ContentDocumentLink WHERE LinkedEntityId =: oppId1];
        system.assertEquals(1,lstDocLink.size());
        
        lstDocLink = [SELECT linkedentityid,contentdocumentid,sharetype,visibility FROM ContentDocumentLink WHERE LinkedEntityId =: primaryOppId];
        system.assertEquals(0,lstDocLink.size());
        Test.startTest();
        OpportunityHandler.mergeOpprtunities(JSON.serialize(mapOpprtunity.keySet()),primaryOppId);
        
        lstDocLink = [SELECT linkedentityid,contentdocumentid,sharetype,visibility FROM ContentDocumentLink WHERE LinkedEntityId =: primaryOppId];
        system.assertEquals(1,lstDocLink.size());
        Test.stopTest();
        
    }
    
    public static testMethod void checkOpportunityRoleValidation(){       
        Account accRec1 = TestingUtility.createAccount('strAccountName1', true);
               
        Test.startTest();
        map<Id,Opportunity> mapOpprtunity = new map<Id,Opportunity>([SELECT Id,Merged_Opprtunity__c from Opportunity]);
        Contact conRec1 = new Contact(
            firstname  = 'John',
            lastname   = 'Rambo',
            email     = 'testc1@example.com',
            accountID  = accRec1.Id,
            Status__c  = 'active'
        );
        insert conRec1;
        
        Contact conRec2 = new Contact(
            firstname  = 'John',
            lastname   = 'Rambo',
            email     = 'testc2@example.com',
            accountID  = accRec1.Id,
            Status__c  = 'active'
        );
        
        insert conRec2;
        
        Map<String, Id> oppRecordType = TestingUtility.getRecordTypeMapByName(Opportunity.sObjectType);        
        
        Opportunity oppRec = TestingUtility.createOpportunity(accRec1.Id, false);
        oppRec.Primary_Member__c = conRec1.Id;
        oppRec.StageName = 'Selling';
        oppRec.CloseDate = system.today().addDays(5);
        oppRec.RecordTypeId = oppRecordType.get('Consumer');
        oppRec.Membership_Agreement_Notes__c = 'Opprtunity 1 Membership_Agreement_Notes__c';
        oppRec.Tour_Notes__c = 'Opprtunity 1 Tour_Notes__c';
        oppRec.Tour_Outcome_Notes__c = 'Opprtunity 1 Tour_Notes__c';
        oppRec.Description = 'Opprtunity 1 Tour_Notes__c';
        oppRec.Locations_Interested__c = 'Test2;';
        oppRec.Amount = 10;
        TestingUtility.insertWithAssert(oppRec);
        
        Opportunity oppRec1 = TestingUtility.createOpportunity(accRec1.Id, false);
        oppRec1.Primary_Member__c = conRec2.Id;
        oppRec1.StageName = 'Selling';
        oppRec1.CloseDate = system.today().addDays(5);
        oppRec1.RecordTypeId = oppRecordType.get('Enterprise Solutions');
        oppRec1.Membership_Agreement_Notes__c = 'Opprtunity 2 Membership_Agreement_Notes__c';
        oppRec1.Tour_Notes__c = 'Opprtunity 2 Tour_Notes__c';
        oppRec1.Tour_Outcome_Notes__c = 'Opprtunity 2 Tour_Notes__c';
        oppRec1.Description = 'Opprtunity 2 Tour_Notes__c';
        oppRec1.Locations_Interested__c = 'Test1;Test2;';
        oppRec1.Amount = 10;
        TestingUtility.insertWithAssert(oppRec1);
        set<Id> setOppIds = new set<Id>();
        setOppIds.add(oppRec.Id);
        setOppIds.add(oppRec1.Id);
        
        //One opportunity role record gets created after inserting the new opportunity using trigger and 2 records are manually inserted. 
        List<Opportunity_Role__c> lstTestOppRoles = [SELECT Id,Contact__c,Opportunity__c FROM Opportunity_Role__c WHERE Opportunity__c IN : setOppIds];
        debug.log('lstTestOppRoles ::'+lstTestOppRoles);
        //Here 3 Opportunity roles gets created because we assign contact as primary member of opportunity which is not primary member of account
        //So we have process builder name 'Opportunity fields mapping' which update opportunity primary member field  to accounts primary member
        //Here opportunity primary member get changed so 2 opportunity roles get created first on create and second on update from trigger.
        system.assertEquals(2,lstTestOppRoles.size());
        
        OpportunityHandler.mergeOpprtunities(JSON.serialize(setOppIds),oppRec1.Id);
        
        lstTestOppRoles = [SELECT Id,Contact__c,Opportunity__c FROM Opportunity_Role__c WHERE Opportunity__c =: oppRec1.Id];
        system.assertEquals(2,lstTestOppRoles.size());
        Test.stopTest();
    }
    
    public static testMethod void moveBuildingInterestForNMDUser(){
        Profile weworkSystemNMDUser = [SELECT Id FROM Profile WHERE Name='WeWork NMD User'];
        Map<String,Object> userRecordMap = new Map<String,Object>();
        userRecordMap.put('LastName','Last Name 1');
        userRecordMap.put('Username','testweworkuserNMD1@example.com');
        userRecordMap.put('Email','testweworkuserNMD1@example.com');
        User testUser1 = TestingUtility.insertUserWithAssert(weworkSystemNMDUser.Id, userRecordMap, true);
        map<Id,Opportunity> mapOpprtunity = new map<Id,Opportunity>([SELECT Id,Merged_Opprtunity__c from Opportunity]);
        Debug.Log('mapOpprtunity==>'+mapOpprtunity); 
        
        list<Building_Interest__c> lstTestBuildingInt= [SELECT Id,Opportunity__c FROM Building_Interest__c WHERE Opportunity__c =: primaryOppId];
        Test.startTest();
        debug.log('lstTestBuildingInt: '+lstTestBuildingInt);
        system.assertEquals(1, lstTestBuildingInt.size());
        
        /* Call to merge opportunity function */
        debug.log('mapOpprtunity.keySet: '+mapOpprtunity.keySet());
        debug.log('primaryOppId: '+primaryOppId);
        OpportunityHandler.mergeOpprtunities(JSON.serialize(mapOpprtunity.keySet()),primaryOppId);        
        
        list<Building_Interest__c> lstAllBuildingInterestAfterMerge = [SELECT Id,Name,Opportunity__c FROM Building_Interest__c];
        debug.log('lstAllBuildingInterestAfterMerge: '+lstAllBuildingInterestAfterMerge);
        
        lstTestBuildingInt = [SELECT Id,Opportunity__c FROM Building_Interest__c WHERE Opportunity__c =: primaryOppId];
        Debug.Log('lstTestBuildingInt==>'+lstTestBuildingInt);
        system.assertEquals(2, lstTestBuildingInt.size());
        Test.stopTest();
    }
    
    public static void improveCodeCoverageTest(){
        OpportunityHandler.getOpportunityStagesForMerge();
        List<Opportunity> lstOpportunity = [Select Id,Name,RecordTypeId From Opportunity LIMIT 1];
        List<String> lstFields = new List<String>{'Name','RecordTypeId'};
            String result =  OpportunityHandler.getDuplicateCriteria(lstOpportunity[0],lstFields);
        system.assert(result != null);
    }
}