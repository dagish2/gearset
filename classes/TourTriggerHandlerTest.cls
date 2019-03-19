/************************************************************************************************************************************
Author 		: Anant Kumar
Description : This class Contains Unit Test of TourTriggerHandler

History		:
----------------------------------------------------------------------------------------------------------------------------------
VERSION		DATE				AUTHOR				DETAIL
1			23 Feb 2016			Anant Kumar 		Initial Developement
**************************************************************************************************************************************/

@isTest
public class TourTriggerHandlerTest {  
    @TestSetup
    static void initData(){
        SalesConsoleSettings.createSettings();
        WeWorkValidatorHelper.createTerritoryStructure();
        test.startTest();
        TestingUtility.getRecords(new Map<String, Object>{'objName'=>'Referral', 'numberOfRecords'=>5});
        TestingUtility.getRecords(new Map<String, Object>{'objName'=>'Reservable', 'numberOfRecords'=>5});
        TestingUtility.getRecords(new Map<String, Object>{'objName'=>'Task', 'numberOfRecords'=>5});
        TestingUtility.getRecords(new Map<String, Object>{'objName'=>'Tour', 'numberOfRecords'=>5});
        List<Contact> lstContacts = [SELECT Id, Name, Email FROM Contact];
        List<Profile> lstProfiles = [SELECT Id FROM Profile WHERE Name In ('WeWork System Administrator' , 'WeWork NMD User')];       
        Map<String, Object> userRecordMap = new Map<String, Object>();
        userRecordMap.put('LastName','testweworkuser1');
        userRecordMap.put('Username','testweworkuser1878@example.com');
        userRecordMap.put('Email','testweworkuser1@example.com');
        User testUser = TestingUtility.insertUserWithAssert(lstProfiles[0].Id, userRecordMap, true);
        Map<String, Object> userRecordMap1 = new Map<String, Object>();
        userRecordMap1.put('LastName','testweworkuser1');
        userRecordMap1.put('Username','testweworkuser1879@example.com');
        userRecordMap1.put('Email', lstContacts[0].Email);
        userRecordMap1.put('IsActive', true);
        User testUser1 = TestingUtility.insertUserWithAssert(lstProfiles[1].Id, userRecordMap1, true);
        test.stopTest();
    }
    
    static testMethod void verifyCloseAllOpenInboundLead(){
        set<String> setContactIds = new set<String>();
        for(Tour_Outcome__c tour : [SELECT Id, Primary_Member__c FROM Tour_Outcome__c ]){
            setContactIds.add(tour.Primary_Member__c);
        }
        for(Task task : [select Id,Status from Task where WhoId IN : setContactIds]){
            System.assertEquals('Completed', task.Status);
        } 
    }
    
    static testMethod void verifyUpdateJourneyStage(){
        set<String> setJourneyIds = new set<String>();
         Debug.log('tour.Journey__c '+ [SELECT Id, Journey__c FROM Tour_Outcome__c ]);
        for(Tour_Outcome__c tour : [SELECT Id, Journey__c FROM Tour_Outcome__c ]){
            if(tour.Journey__c != null)
                setJourneyIds.add(tour.Journey__c);
        }
        Debug.log('tour.Journey__c '+ [SELECT Id, Journey__c FROM Tour_Outcome__c ]);
        for(Journey__c journey :[SELECT Id,Status__c,(Select Id,Name,Status__c From Tours__r) Status__c FROM Journey__c WHERE ID IN : setJourneyIds]){
            if(journey.Tours__r.size() > 0)
                System.assertEquals('Completed', journey.Status__c);
        }
    }
    static testMethod void verifyExtendValidityOfReference(){
        set<String> setprimaryMemberEmail = new set<String>();
        for(Tour_Outcome__c tour : [SELECT Id,Primary_Member__r.Email FROM Tour_Outcome__c ]){
            if(tour.Primary_Member__c != null)
                setprimaryMemberEmail.add(tour.Primary_Member__r.Email);
        }
        for(Referral__c referral: [SELECT Id,Expires_On__c FROM Referral__c WHERE Referral_Email__c in:setprimaryMemberEmail AND IsActive__c=true] ){
            System.assertEquals(System.today().addDays(60), referral.Expires_On__c);
        }
    }
    
    static testMethod void verifyUpdateTourOwnerForAssignedHost(){
        test.startTest();
        List<Contact> lstContact = [SELECT Id, Name, Email FROM Contact];
        List<Tour_Outcome__c> lstToursToUpdate  = new List<Tour_Outcome__c>();
        List<Tour_Outcome__c> lstTours  = [SELECT Id, Assigned_Host__c, OwnerId FROM Tour_Outcome__c];
        for(Tour_Outcome__c tour : lstTours){
            tour.Assigned_Host__c = lstContact[0].Id;
            lstToursToUpdate.add(tour);
        }
        UPDATE lstToursToUpdate;
        test.stopTest();
        List<User> lstUser = [select id from User WHERE Email in ('testweworkuser1@example.com','john1.contact@example.com')];
        Debug.Log('lstUserlstUserlstUser'+lstUser);
        for(Tour_Outcome__c tour :lstTours){
            System.assertEquals(tour.OwnerId, userInfo.getUserId());
        }  
    }
    static testMethod void verifyCleanTourOutcomeData(){
        test.startTest();
        List<Building__c> lstBuildings = [SELECT Id, Name, UUID__c FROM Building__c];
        List<Reservable__c> lstReservables = [SELECT Id, Name, UUID__c  FROM Reservable__c];
        List<Tour_Outcome__c> lstTours = [SELECT Id, Name, Interested_Buildings__c, Outcome_Reservables__c, Name_of_Decision_Maker__c FROM Tour_Outcome__c];
        List<Contact> lstContacts = [SELECT Id, Name, UUID__c, Email  FROM Contact];
        lstTours[0].Interested_Buildings__c = lstBuildings[0].UUID__c+';'+lstBuildings[1].UUID__c+';'+lstBuildings[2].UUID__c;
        lstTours[1].Outcome_Reservables__c = lstReservables[2].UUID__c+';'+lstReservables[3].UUID__c+';'+lstReservables[4].UUID__c;
        lstTours[2].Name_of_Decision_Maker__c = lstContacts[0].Email;
        UPDATE lstTours;
        test.stopTest();
        List<Tour_Outcome__c> lstToursAfterUpdate = [SELECT Id, Name, Interested_Buildings__c, Outcome_Reservables__c, Name_of_Decision_Maker__c FROM Tour_Outcome__c WHERE Id In :lstTours];
        System.assertEquals(lstToursAfterUpdate[0].Interested_Buildings__c, lstBuildings[0].Name+';'+lstBuildings[1].Name+';'+lstBuildings[2].Name);
        System.assertEquals(lstToursAfterUpdate[1].Outcome_Reservables__c, lstReservables[2].Name+';'+lstReservables[3].Name+';'+lstReservables[4].Name);
        System.assertEquals(lstToursAfterUpdate[2].Name_of_Decision_Maker__c, lstContacts[0].Email);
    }
    static testMethod void verifyTourCreateTaskForEmailReminderSentForHour(){
        test.startTest();
        List<Tour_Outcome__c> lstToursToUpdate = new List<Tour_Outcome__c>();
        List<Tour_Outcome__c> lstTours = [SELECT Id, X24_Hours_email_reminder_sent__c, X1_Hour_reminder_email_sent__c,  Location__c, Primary_Member__c, Status__c FROM Tour_Outcome__c ];
        for(Tour_Outcome__c tour : lstTours){
            tour.X1_Hour_reminder_email_sent__c = true;
            lstToursToUpdate.add(tour);
        }
        UPDATE lstToursToUpdate;
        test.stopTest();
        List<Task> lstNewInsertedTask = [SELECT Id, Subject, Status, WhatId, WhoId, Priority FROM Task WHERE Subject = '1 Hour reminder email sent'];
        for(Task task : lstNewInsertedTask){
            System.assertEquals('1 Hour reminder email sent', task.Subject);
            System.assertEquals('Normal', task.Priority);
            System.assertEquals('Completed', task.Status);    
        }
    }
    static testMethod void verifyTourCreateTaskForEmailReminderSentForDay(){
        List<Tour_Outcome__c> lstToursToUpdate = new List<Tour_Outcome__c>();
        test.startTest();
        List<Tour_Outcome__c> lstTours = [SELECT Id, X24_Hours_email_reminder_sent__c, X1_Hour_reminder_email_sent__c,  Location__c, Primary_Member__c, Status__c FROM Tour_Outcome__c ];
        for(Tour_Outcome__c tour : lstTours){
            tour.X24_Hours_email_reminder_sent__c = true;
            lstToursToUpdate.add(tour);
        }
        UPDATE lstToursToUpdate;
        test.stopTest();
        List<Task> lstNewInsertedTask = [SELECT Id, Subject, Status, WhatId, WhoId, Priority FROM Task WHERE Subject = '24 Hours email reminder sent'];
        for(Task task : lstNewInsertedTask){
            System.assertEquals('24 Hours email reminder sent', task.Subject);
            System.assertEquals('Normal', task.Priority);
            System.assertEquals('Completed', task.Status);    
        }
    }
    static testMethod void verifyUpdateTourEndTime(){
        test.startTest();
        List<Tour_Outcome__c> lstTours = [SELECT Id, Name, Start_Time__c, Tour_Date__c FROM Tour_Outcome__c];
        lstTours[0].Start_Time__c = '11:00PM';
        lstTours[0].End_Time__c = null;
        UPDATE lstTours;
        test.stopTest();
        List<Tour_Outcome__c> lstToursAfterUpdate = [SELECT Id, Name, End_Time__c FROM Tour_Outcome__c WHERE Id In :lstTours];
        System.assertEquals('11:30PM', lstToursAfterUpdate[0].End_Time__c);
    }
    static testMethod void verifycreateORUpdateTourOutcome(){
        test.startTest();
        List<Tour_Outcome__c> lstTours = [SELECT Id, Name, Interested_Buildings__c, Outcome_Reservables__c, Name_of_Decision_Maker__c, Referrer__c, Primary_Member__c, Unit_Type__c, Office_Capacity__c, Opportunity__c, Opportunity__r.StageName, (SELECT Id, Name FROM Tour_Summaries__r) FROM Tour_Outcome__c];
        List<Reservable__c> lstReservables = [SELECT Id, Name, UUID__c  FROM Reservable__c];
        List<Opportunity> lstOpportunities = [SELECT Id, Name, StageName FROM Opportunity];
        List<Contact> lstContacts = [SELECT Id, Email FROM Contact];
        System.assertEquals(0, lstTours[0].Tour_Summaries__r.size());
        lstTours[0].Unit_Type__c = 'Office';
        lstTours[0].Office_Capacity__c = '20';
        lstTours[0].Outcome_Reservables__c = lstReservables[0].Name;
        lstOpportunities[0].StageName  = 'closed won';
        
        lstTours[1].Unit_Type__c = 'Hot Desk;Dedicated Desk';
        lstTours[1].Name_of_Decision_Maker__c = lstContacts[1].Email;
        lstTours[1].Is_Decision_Maker__c = true;
        UPDATE lstTours;
        test.stopTest();
        List<Tour_Outcome__c> lstUpdatedTours = [SELECT Id, Name, Interested_Buildings__c, Outcome_Reservables__c, Name_of_Decision_Maker__c, Referrer__c, Primary_Member__c, Unit_Type__c, Office_Capacity__c, Opportunity__c, (SELECT Id, Name FROM Tour_Summaries__r) FROM Tour_Outcome__c where Id in :lstTours];
        System.assertEquals(2, lstUpdatedTours[0].Tour_Summaries__r.size());
    }
    static testMethod void verifyUpdateActiveReferrerOnTour(){
        test.startTest();
        List<Tour_Outcome__c> lstTours = [SELECT Id, Name, Interested_Buildings__c, Outcome_Reservables__c, Name_of_Decision_Maker__c, Referrer__c, Primary_Member__c FROM Tour_Outcome__c];
        List<Contact> lstContacts = [SELECT Id, Name, UUID__c, Email  FROM Contact]; 
        List<Referral__c> lstReferrals = [SELECT Id, Name, Referral_Email__c, IsActive__c, Referrer__c FROM Referral__c];
        lstTours[0].Primary_Member__c = lstContacts[1].Id;
        UPDATE lstTours;
        List<Tour_Outcome__c> lstToursUpdated = [SELECT Id, Name, Interested_Buildings__c, Outcome_Reservables__c, Name_of_Decision_Maker__c, Referrer__c, Primary_Member__c FROM Tour_Outcome__c where Id In : lstTours];
        test.stopTest();
        Debug.log('lstTourslstTourslstTours'+lstToursUpdated);
        System.assertEquals(lstToursUpdated[0].referrer__c, lstContacts[6].Id);
    }
    
    static testMethod void verifyCallCountTour(){
        List<Tour_Outcome__c> lstTours = [SELECT Id, Name, Interested_Buildings__c, Outcome_Reservables__c, Name_of_Decision_Maker__c, Primary_Member__c FROM Tour_Outcome__c];
        set<String> setContactEmails = new set<String>();
        setContactEmails.add('test.Contact1@example.com');
        setContactEmails.add('test.Contact2@example.com');
        test.startTest();
        TourTriggerHandler.callCountTour(JSON.serialize(lstTours));
        test.stopTest();
        for(Contact contact:[SELECT id, Total_Scheduled_Tours__c, Total_Completed_Tours__c, Other_Tours_Count__c FROM Contact WHERE Email IN :  setContactEmails]){
            System.assertEquals(1, contact.Total_Scheduled_Tours__c);
        }
    }
    
    static testMethod void verifyUpdateOpportunityStage(){
        test.startTest();
        List<Tour_Outcome__c> lstTours = [SELECT Id, Name, Primary_Member__c, Status__c, Opportunity__c, Opportunity__r.StageName FROM Tour_Outcome__c];
        lstTours[0].Status__c = 'Completed';
        UPDATE lstTours;
        test.stopTest();
        List<Tour_Outcome__c> lstToursAfterUpdate = [SELECT Id, Name, Primary_Member__c, Status__c, Opportunity__c, Opportunity__r.StageName FROM Tour_Outcome__c WHERE Id In :lstTours];
        Debug.log('lstToursAfterUpdate'+ lstToursAfterUpdate);
    }
    
    public static testMethod void verifySetLocationEmail(){
        List<Tour_Outcome__c> lstUpdatedTors = [SELECT Id, Location__c, Building_No_City__c, Location_Email__c, Location__r.Email__c, Primary_Member__c, Status__c FROM Tour_Outcome__c WHERE Location__c!=null];
        TestingUtility.updateWithAssert(new Building__c(Id = lstUpdatedTors[0].Location__c, Location_No_City__c = 'test', Email__c='test6565@test.com'));
        TestingUtility.updateWithAssert(new Tour_Outcome__c(Id=lstUpdatedTors[0].Id, account_uuid__c='5571'));
        Tour_Outcome__c objTour = [SELECT Id, Location_Email__c FROM Tour_Outcome__c WHERE Id = :lstUpdatedTors[0].Id];
        System.assertEquals('test6565@test.com', objTour.Location_Email__c);
    }
    
    public static testMethod void verifyTourCanceledDate(){
        List<Tour_Outcome__c> lstTours = [SELECT Id, Status__c FROM Tour_Outcome__c WHERE Status__c!='Cancelled' LIMIT 1];
        System.assertNotEquals(0, lstTours.size());
        TestingUtility.updateWithAssert(new Tour_Outcome__c(Id=lstTours[0].Id, Status__c='Cancelled'));
        Tour_Outcome__c objTour = [SELECT Id, Tour_Canceled_Date__c, Status__c FROM Tour_Outcome__c WHERE Id=:lstTours[0].Id];
        System.assertEquals(System.today(), objTour.Tour_Canceled_Date__c);
    }
    
    public static testMethod void verifyTourCompletedDate(){
        List<Tour_Outcome__c> lstTours = [SELECT Id, Status__c FROM Tour_Outcome__c WHERE Status__c!='Completed' LIMIT 1];
        System.assertNotEquals(0, lstTours.size());
        sObject objToursObject = new Tour_Outcome__c(Id=lstTours[0].Id, Status__c='Completed');
        TestingUtility.updateWithAssert(objToursObject);
        Tour_Outcome__c objTour = [SELECT Id, Tour_Completed__c, Status__c FROM Tour_Outcome__c WHERE Id=:lstTours[0].Id];
        System.assertEquals(System.today(), objTour.Tour_Completed__c); 
    }
    
    public static testMethod void verifySetTourScheduledWithEmail(){
        Lead objLead = new Lead(LastName = 'Doe', FirstName = 'John', Email = 'johnDoe6618_1@example.com' ,Office_Type__c = 'Daily Desk',Status = 'Open', Company = 'Enzigma ltd',Generate_Journey__c = true,Number_of_Full_Time_Employees__c = 15);
        TestingUtility.insertWithAssert(objLead);
        List<Tour_Outcome__c> lstTours = [SELECT Id, Status__c FROM Tour_Outcome__c WHERE Status__c!='Completed' LIMIT 1];
        System.assert(lstTours.size()>0);
        TestingUtility.updateWithAssert(new Tour_Outcome__c(Id=lstTours[0].Id, Lead__c = objLead.Id));
        Tour_Outcome__c objTour = [SELECT Id, Tour_Scheduled_With_Email__c FROM Tour_Outcome__c WHERE Id= :lstTours[0].Id];
        System.assertNotEquals(null,  objTour.Tour_Scheduled_With_Email__c);
        System.assertEquals('johndoe6618_1@example.com', objTour.Tour_Scheduled_With_Email__c.toLowerCase());
        
        List<Opportunity> lstOpportunities = [SELECT Id, Primary_Member__c FROM Opportunity WHERE Primary_Member__c!=null LIMIT 1];
        System.assertEquals(1, lstOpportunities.size());
        
        TestingUtility.updateWithAssert(new Contact(Id=lstOpportunities[0].Primary_Member__c, Email = 'testJohn11@example.com'));
        
        TestingUtility.updateWithAssert(new Tour_Outcome__c(Id=lstTours[0].Id, Lead__c = null, Opportunity__c=lstOpportunities[0].Id));
        
        objTour = [SELECT Id, Tour_Scheduled_With_Email__c FROM Tour_Outcome__c WHERE Id= :lstTours[0].Id];
        System.assertNotEquals(null,  objTour.Tour_Scheduled_With_Email__c);
        System.assertEquals('testjohn11@example.com', objTour.Tour_Scheduled_With_Email__c.toLowerCase());
    }
    
    public static testMethod void verifySetTourDate(){
        List<Tour_Outcome__c> lstTours = [SELECT Id, Tour_Date__c, Status__c FROM Tour_Outcome__c WHERE Status__c ='Scheduled' LIMIT 1];
        System.assert(lstTours.size() > 0);
        Tour_Outcome__c objTour = lstTours[0];
        System.assertNotEquals(null, objTour);
        System.assertNotEquals(null, objTour.Tour_Date__c);        
        Date tourDate = objTour.Tour_Date__c;
        
        TestingUtility.updateWithAssert(new Tour_Outcome__c(Id = lstTours[0].Id, Status__c = 'Completed'));
        
        lstTours = [SELECT Id, Tour_Date__c FROM Tour_Outcome__c WHERE Id= :lstTours[0].Id];
        System.assert(lstTours.size() > 0);
        objTour = lstTours[0];
        System.assertNotEquals(null, objTour);
        System.assertNotEquals(null, objTour.Tour_Date__c);        
        System.assertEquals(tourDate, objTour.Tour_Date__c);
    }
}