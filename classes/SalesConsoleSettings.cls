/************************************************************************************************************************************
    Author     :   Samadhan Kadam
    Description :   This class contain all thes sales console settings that are used for all test methods.

    History    :
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION    DATE        AUTHOR            DETAIL
    1      23 Aug 2017      Samadhan Kadam        Initial Developement
   2      01 Aug 2018      Krishana Tupe        Added Comment structure
**************************************************************************************************************************************/
public class SalesConsoleSettings {
    public static List<Setting__c> lstAllSettings;

   /************************************************************************************************************************************
        Author              :   Samadhan Kadam
        Description         :   This method is used to create/insert all sales console settings records.
        Created Date        :   23 Aug 2017
   **************************************************************************************************************************************/
    public static void createSettings(){
        if(lstAllSettings==null || lstAllSettings.size()==0){
            lstAllSettings = new List<Setting__c>();
            SalesConsoleSettings.createOpenOpportunityStages();
            SalesConsoleSettings.createAccountAssignmentSettings();
            SalesConsoleSettings.createAccountMergeSettings();
            SalesConsoleSettings.createAccountRecordTypeSettings();
            SalesConsoleSettings.createAccountTriggerFilterSettings();
            SalesConsoleSettings.createAllowedUsersForReferencePageSettings();
            SalesConsoleSettings.createAssignContactstoActiveUserSettings();
            SalesConsoleSettings.createCampaignSettings();
            SalesConsoleSettings.createCloseOpenActivitiesSettings();
            SalesConsoleSettings.createContactMemberTypePrioritySettings();
            SalesConsoleSettings.createContractEndpointOpportunityStagesSettings();
            SalesConsoleSettings.createCountriesSettings();
            SalesConsoleSettings.createEnterpriseSettings();
            SalesConsoleSettings.createExportReservablesSettings();
            SalesConsoleSettings.createFieldMappingsContactToActivity();
            SalesConsoleSettings.createFieldMappingContactToJourneySetting();
            SalesConsoleSettings.createFieldMappingsContactToOpportunitySetting();
            SalesConsoleSettings.createFieldMappingsContactToTourSetting();
            SalesConsoleSettings.createFieldMappingsJourneyToJourneySetting();
            SalesConsoleSettings.createFieldMappingsKickboxCSVToLeadSetting();
            SalesConsoleSettings.createFieldMappingsLeadToAccountSetting();
            SalesConsoleSettings.createFieldMappingsLeadToActivitySetting();
            SalesConsoleSettings.createFieldMappingsLeadToContactSetting();
            SalesConsoleSettings.createFieldMappingsAccountToBillingAccountSetting();
            SalesConsoleSettings.createFieldMappingsLeadToJourneySetting();
            SalesConsoleSettings.createFollowupOptionsSetting();
            SalesConsoleSettings.createIconSetting();
            SalesConsoleSettings.createJourneyCreationSetting();
            SalesConsoleSettings.createJourneyReport();
            SalesConsoleSettings.createJourneySetting();
            SalesConsoleSettings.createKickboxAPISetting();
            SalesConsoleSettings.createLeadJourneyTriggerSetting();
            SalesConsoleSettings.createManageToursOpportunityStagesSetting();
            SalesConsoleSettings.createNewTourButtonErrorMessageSetting();
            SalesConsoleSettings.createOpportunitySetting();
            SalesConsoleSettings.createOpportunityFromLatestOpportunitySetting();
            SalesConsoleSettings.createOpportunityProductsMappingSetting();
            SalesConsoleSettings.createOpportunityRelatedObjectSetting();
            SalesConsoleSettings.createReferenceSetting();
            SalesConsoleSettings.createRestrictAccountDeletionSetting();
            SalesConsoleSettings.createSendPaperWorkSetting();
            SalesConsoleSettings.createSFMCRepliesSetting();
            SalesConsoleSettings.createTasksUpdateToCompletedBatchSetting();
            SalesConsoleSettings.createTestSettiingForSkyviaSetting();
            SalesConsoleSettings.createTourContactEmailSetting();
            SalesConsoleSettings.createTourOpportunityStatusTriggerSetting();
            SalesConsoleSettings.createTourOutcomeFormSetting();
            SalesConsoleSettings.createTourReservableAPISetting();
            SalesConsoleSettings.createUserRoleUpdateSetting();
            SalesConsoleSettings.createTourAssignedHostSettings();
            SalesConsoleSettings.createSendPaperworkSettings();
            SalesConsoleSettings.createKickboxLeadImporterUtilitySettings();
            SalesConsoleSettings.createUpdateJourneyOnCampaignMemberBatch();
            SalesConsoleSettings.createRestrictUserRoleToChangeLeadSourceSettings();
            SalesConsoleSettings.createCreateOpportunityTeamMember();
            SalesConsoleSettings.createUpdateJourneysOwner();
            SalesConsoleSettings.createreferralQueueSetting();
            SalesConsoleSettings.createAPIUserContactInfoSetting();
            SalesConsoleSettings.JourneyForceFullyClose();
            SalesConsoleSettings.createQueueManagementSettings();
            SalesConsoleSettings.createRestrictBatchToChangeOwnerSettings();
            SalesConsoleSettings.createPublicDomainSettings();
            SalesConsoleSettings.createHoldReservableSettings();
            SalesConsoleSettings.createpurgeResolvedExceptionSettings();
            SalesConsoleSettings.createReferralsourcesSettings();
            SalesConsoleSettings.createNMDProfilesSetting();
            SalesConsoleSettings.createUnassignedNMDUSQueueSetting();
            SalesConsoleSettings.createRetroactiveReferralSettings();
            SalesConsoleSettings.UserQueueJourneyCreation();
            SalesConsoleSettings.AccountHierarchy_OrgAssignBatchTime();
            SalesConsoleSettings.Account_Hierarchy_Naming_Convention();
            SalesConsoleSettings.Lead_Org_Assign_Batch_Time();
            SalesConsoleSettings.Account_SalesAccountSetting();
            SalesConsoleSettings.createLeadSourceAndDetailsSetting();
            SalesConsoleSettings.createContractEventEndpointsSetting();
            SalesConsoleSettings.createResendPaperworkSetting();
            SalesConsoleSettings.createAllowedProfilesToManageCasesSettings();
            SalesConsoleSettings.createFieldMappings_Product2ToOpportunityLineItem();
            SalesConsoleSettings.createFieldMappingsBillAccountToOrgAccount();
            SalesConsoleSettings.createGoogleGeolocationAPI();
            SalesConsoleSettings.createSendDeactivateUserStatus();
            SalesConsoleSettings.createNewOrgCreationSetting();
            SalesConsoleSettings.createCampaignMemberStatusSetting();
            SalesConsoleSettings.createAccountCleansingSetting();
            SalesConsoleSettings.createFieldMappingContactToAccountSetting();
            SalesConsoleSettings.createTransferPaperworkSetting();
            SalesConsoleSettings.createReparentingBypassProfilesSettings();
            SalesConsoleSettings.createMergeOrganizationsSetting();
            SalesConsoleSettings.createAccountSelectorSettings();
            SalesConsoleSettings.createAccessTokenSettings();
            SalesConsoleSettings.createRollbarConfigSetting();
            SalesConsoleSettings.createRestrictOpportunityCreation();
            SalesConsoleSettings.createSandboxConfigurationSetting();
            SalesConsoleSettings.createCommunityViewApiSettings();
            SalesConsoleSettings.createLeadScoreMechansimSettings();
            SalesConsoleSettings.createNotifyTeamMemberProfiles();
            SalesConsoleSettings.createValidateReferralLead();
            SalesConsoleSettings.createNewOrganizationCreationRequestEmails();
            SalesConsoleSettings.createManageBillingAccountSettings();
            SalesConsoleSettings.createEnterpriseOppTeamMemberCreation();
            SalesConsoleSettings.createTourCloseHour();
            SalesConsoleSettings.createLeadScoreMechanismForLeadSourceDetail();
            SalesConsoleSettings.createContractUtilitySetting();
            SalesConsoleSettings.createUpdateJourneyOutreachStage();
            SalesConsoleSettings.createAccountAssignmentByDesks();
            SalesConsoleSettings.createJourneyCloseStages();
            SalesConsoleSettings.createContactOwnerShipSetting();
            SalesConsoleSettings.createRestartLocationSettings();
            List<Database.SaveResult> result =  Database.insert(lstAllSettings);
        }
    }

    public static void createNewOrgCreationSetting(){
        Setting__c setting = new setting__c();
        setting.Name = 'NewOrgCreationSetting';
        setting.Data__c = '{ "excludeProfiles": ["WeWork Enterprise Solutions"],"instructions": {"AccountInstructions": ["This is first Instruction for Create New Account."],"SearchOrganization": ["This is first Instruction to Search new organization."],"RequestNewOrganization": ["This is first Instruction to Request new Organization."],"CreateNewOrganization": ["This is first Instruction for Create New Organization."]}}';
        lstAllSettings.add(setting);
    }

     public static void createSendDeactivateUserStatus(){
        Setting__c setting = new setting__c();
        setting.Name = 'SendDeactivateUserStatus';
        setting.Data__c = '{"subject":"Deactivated user Summary &userId : &userName","searchInObjects":[{"Building__c":["Community_Sales_Lead__c","Name"]},{"Setting__c":["Data__c","Description__c"]},{"Cluster__c":["Cluster_Sales_Manager__c"]},{"Account_Queue__c":["Member__c"]},{"Campaign":["Lead_Owner__c"]}],"Emails":["shivprasad.patil@enzigma.com","girish.bhandari@enzigma.in"],"emailBody":""}';
        lstAllSettings.add(setting);
    }

    public static void createAccountAssignmentSettings(){
        Setting__c setting = new setting__c();
        setting.Name = 'AccountAssignmentSettings';
        setting.Data__c = '{"referralsources":["Broker"], "marketmapping":[ {"state":"Amsterdam","market":"Amsterdam"}, {"country":"Australia","market":"Austin"}, {"city":"New York","market":"Sydney"}]}';
        lstAllSettings.add(setting);
    }

    public static void createAccountCleansingSetting(){
        Setting__c testSettings = new Setting__c();
        testSettings.Name = 'AccountCleansingSetting';
        testSettings.Data__c = '{"starts_with":["The","A","An"],"ends_with":["llc","llp","inc","holdings","incorporated","collective","consulting","enterprises","group","industries","international","services","systems","unlimited","company","co","inc.","LTD","USA"],"specialCharacters":"."}';
        lstAllSettings.add(testSettings);
    }

    public static void createAccountMergeSettings(){
        Setting__c setting = new setting__c();
        Profile weworkSystemAdmin = [SELECT Id FROM Profile WHERE Name='WeWork System Administrator'];
        Profile weworkNMD = [SELECT Id FROM Profile WHERE Name='WeWork Standard User'];
        List<User> lstusers = new List<User>();
        User user1 = new User();
        user1.LastName = 'Test Name 1';
        user1.Username = 'testtaccountmerge1345345e5899@example.com';
        user1.Email = 'testaccountmerge183e5349@example.com';
        user1.ProfileId = weworkSystemAdmin.Id;
        user1.EmailEncodingKey = 'ISO-8859-1';
        user1.LanguageLocaleKey = 'en_US';
        user1.LocaleSidKey = 'en_US';
        user1.TimeZoneSidKey = 'America/Los_Angeles';
        user1.Alias = 'Name 1';
        lstusers.add(user1);

        User user2 = new User();
        user2.LastName = 'Test Name 2';
        user2.Username = 'testtaccountmerge1234543543519@example.com';
        user2.Email = 'testaccountmerge193243@example.com';
        user2.ProfileId = weworkNMD.Id;
        user2.EmailEncodingKey = 'ISO-8859-1';
        user2.LanguageLocaleKey = 'en_US';
        user2.LocaleSidKey = 'en_US';
        user2.TimeZoneSidKey = 'America/Los_Angeles';
        user2.Alias = 'Name 2';
        lstusers.add(user2);
        insert lstusers;

        setting.Name = 'AccountMergeSettings';
        Profile weworkSystemAdminNew = [SELECT Id FROM Profile WHERE Name='Wework System Administrator'];
        Map<String,Object> mapNewResCMUser = new Map<String,Object>();
        mapNewResCMUser.put('LastName','TestNewResCMSUser');
        mapNewResCMUser.put('Username','Testnewrescm_user@weworkexample.com');
        mapNewResCMUser.put('Email','Testnewrescm_user@weworkexample.com');
        User newBuidingResCMUser = TestingUtility.insertUserWithAssert(weworkSystemAdminNew.Id, mapNewResCMUser, true);

        Map<String,Object> userRecordMap3 = new Map<String,Object>();
        userRecordMap3.put('LastName','API User');
        userRecordMap3.put('Username','testapiuser568@example.com');
        userRecordMap3.put('Email','testapiuser@example.com');
        User apiUser = TestingUtility.insertUserWithAssert(weworkSystemAdminNew.Id, userRecordMap3, true);

        setting.Data__c = '{"owner":["005F0000003Kmbw","'+apiUser.Id+'","'+newBuidingResCMUser.Id+'","'+lstusers[0].Id+'","'+lstusers[1].Id+'"],"profiles":["WeWork System Administrator","WeWork NMD User"]}';
        lstAllSettings.add(setting);
    }

    public static void createAccountRecordTypeSettings(){
        Setting__c setting = new setting__c();
        setting.Name = 'AccountRecordTypeSettings';
        setting.Data__c = '[{"Size": "1-10","RecordType":"Consumer"},{"Size":"11-999","RecordType":"Mid Market"},{"Size":"1000+","RecordType":"Enterprise Solutions" }]';
        lstAllSettings.add(setting);
    }

    public static void createAccountTriggerFilterSettings(){
        Setting__c setting = new setting__c();
        setting.Name = 'AccountTriggerFilterSettings';
        setting.Data__c = '{"OpportunityStage":["Selling","Qualifying","Negotiating"],"TaskStatus":["Not Started","In Progress","Waiting on someone else"],"TourStatus":["Scheduled"]}';
        lstAllSettings.add(setting);
    }

    public static void createAllowedUsersForReferencePageSettings(){
        Setting__c setting = new setting__c();
        setting.Name = 'Allowed Users For Reference Page';
        setting.Data__c = '{"allowedUsers":[{"Id":"005F0000006rT9y","userName":"hemanshu.shah@wework.com"},{"Id":"005F0000006tF61","userName":"vidyadhar.mangrulkar@wework.com"},{"Id":"005F0000006rJPc","userName":"miteshkumar.shevale@wework.com"},{"Id":"005F0000006rzfS","userName":"parag.vyas@wework.com"}]}';
        lstAllSettings.add(setting);
    }

    public static void createAssignContactstoActiveUserSettings(){
        Setting__c setting = new setting__c();
        setting.Name = 'Assign Contacts to Active User';
        setting.Data__c = '{"Id":"005F0000003Kmbw","userName":"joinus@wework.com"}';
        lstAllSettings.add(setting);
    }

   public static void createCampaignSettings(){
        Setting__c setting = new setting__c();
        setting.Name = 'CampaignSettings';
        setting.Data__c = '{"SplashSettings":[{"splasheventtype":"Advertisement,Email,Splash Event,Event"}],"AddJourneysToCampaign":["Event","Splash Event","Inbound Lead Multi Touch"],"AuditCampaignDetails":{"OpportunityStages":["Closed Won"],"CampaignTypes":["Multitouch Outbound Campaign"]}}';
        lstAllSettings.add(setting);
    }

    public static void createCloseOpenActivitiesSettings(){
        Setting__c setting = new setting__c();
        setting.Name = 'CloseOpenActivities';
        setting.Data__c = '{"subject":"Inbound Lead Submission,New InboundLead,Follow-Up,Follow up,Follow up two,Final Final up"}';
        lstAllSettings.add(setting);
    }

    public static void createContactMemberTypePrioritySettings(){
        Setting__c setting = new setting__c();
        setting.Name = 'ContactMemberTypePriority';
        setting.Data__c = '{"Employee":"1", "Licensee":"2", "Broker":"3", "Affiliate":"4"}';
        lstAllSettings.add(setting);
    }

    public static void createContractEndpointOpportunityStagesSettings(){
        Setting__c setting = new setting__c();
        setting.Name = 'ContractEndpointOpportunityStages';
        setting.Data__c = '["Closed Won","Closed Lost","Merged"]';
        lstAllSettings.add(setting);
    }

    public static void createCountriesSettings(){
        Setting__c setting = new setting__c();
        setting.Name = 'Countries';
        setting.Data__c = '[{"name":"Afghanistan","code":"AF"},{"name":"Åland Islands","code":"AX"},{"name":"Albania","code":"AL"},{"name":"Algeria","code":"DZ"},{"name":"American Samoa","code":"AS"},{"name":"AndorrA","code":"AD"},{"name":"Angola","code":"AO"},{"name":"Anguilla","code":"AI"}]';
        lstAllSettings.add(setting);
    }

    public static void createEnterpriseSettings(){
        Setting__c setting = new setting__c();
        setting.Name = 'EnterpriseSettings' ;
        setting.Data__c = '{"EnterpriseLandingSettings":[{"LeadSource":"WeWork.com","LeadSourceDetail":"Enterprise Landing Page1"},{"LeadSource":"WeWork.com","LeadSourceDetail":"Enterprise Landing Page2"}],"EnterpriseLeadSettings":{ "ActivitySubject": "Owner and Record Type Change to Enterprise Solution Queue",  "CompanySize": 15 }}';
        lstAllSettings.add(setting);
    }

    public static void createExportReservablesSettings(){
        Setting__c setting = new setting__c();
        setting.Name = 'ExportReservablesSettings';
        setting.Data__c = '{"ExportReservable":{"emailTemplateName":"Export Reservables"}}';
        lstAllSettings.add(setting);
    }

    public static void createFieldMappingsContactToActivity(){
        Setting__c setting = new setting__c();
        setting.Source_Object__c = 'Contact';
        setting.Destination_Object__c = 'Task';
        setting.Name = 'FieldMappings:ContactToActivity';
        setting.Data__c = '{"version":"1","mappings":{"utm_campaign__c":{"fieldname":"utm_campaign__c","isvalue":false,"overwrite":false},"utm_campaign_id__c":{"fieldname":"utm_campaign_id__c","isvalue":false,"overwrite":false},"utm_content__c":{"fieldname":"utm_content__c","isvalue":false,"overwrite":false},"utm_medium__c":{"fieldname":"utm_medium__c","isvalue":false,"overwrite":false},"utm_source__c":{"fieldname":"utm_source__c","isvalue":false,"overwrite":false},"utm_term__c":{"fieldname":"utm_term__c","isvalue":false,"overwrite":false},"Quick_Quote_Location__c":{"fieldname":"Quick_Quote_Location__c","isvalue":false,"overwrite":false},"Lead_Source__c":{"fieldname":"LeadSource","isvalue":false,"overwrite":false},"Lead_Source_Detail__c":{"fieldname":"Lead_Source_Detail__c","isvalue":false,"overwrite":false},"Product_Interests__c":{"fieldname":"Product_Interests__c","isvalue":false,"overwrite":false},"Country_Code__c":{"fieldname":"Country_Code__c","isvalue":false,"overwrite":false},"Market__c":{"fieldname":"Market__c","isvalue":false,"overwrite":false},"Locale__c":{"fieldname":"Locale__c","isvalue":false,"overwrite":false},"Product_Line__c":{"fieldname":"Product_Line__c","isvalue":false,"overwrite":false},"Phone__c":{"fieldname":"Phone","isvalue":false,"overwrite":false},"WhoId":{"fieldname":"Id","isvalue":false,"overwrite":false},"Company__c":{"fieldname":"Company__c","isvalue":false,"overwrite":false},"Email__c":{"fieldname":"Email","isvalue":false,"overwrite":false},"First_Name__c":{"fieldname":"FirstName","isvalue":false,"overwrite":false},"Last_Name__c":{"fieldname":"LastName","isvalue":false,"overwrite":false},"Industry__c":{"fieldname":"Industry__c","isvalue":false,"overwrite":false},"Locations_Interested__c":{"fieldname":"Location_Interested__c","isvalue":false,"overwrite":false},"Referrer__c":{"fieldname":"Referrer__c","isvalue":false,"overwrite":false},"Markets_Interested__c":{"fieldname":"Markets_Interested__c","isvalue":false,"overwrite":false},"Company_Size__c":{"fieldname":"Company_Size__c","isvalue":false,"overwrite":false},"Interested_in_Number_of_Desks__c":{"fieldname":"Interested_in_Number_of_Desks__c","isvalue":false,"overwrite":false},"Number_of_Full_Time_Employees__c":{"fieldname":"Number_of_Full_Time_Employees__c","isvalue":false,"overwrite":false}}}' ;
        lstAllSettings.add(setting);
    }

    public static void createFieldMappingContactToJourneySetting(){
        Setting__c setting = new setting__c();
        setting.Source_Object__c = 'Contact';
        setting.Destination_Object__c = 'Journey__c';
        setting.Name = 'FieldMappings:ContactToJourney';
        setting.Data__c = '{"version":"1","mappings":{"utm_campaign__c":{"fieldname":"utm_campaign__c","isvalue":false,"overwrite":false},"utm_campaign_id__c":{"fieldname":"utm_campaign_id__c","isvalue":false,"overwrite":false},"utm_content__c":{"fieldname":"utm_content__c","isvalue":false,"overwrite":false},"utm_medium__c":{"fieldname":"utm_medium__c","isvalue":false,"overwrite":false},"utm_source__c":{"fieldname":"utm_source__c","isvalue":false,"overwrite":false},"utm_term__c":{"fieldname":"utm_term__c","isvalue":false,"overwrite":false},"Lead_Source_Detail__c":{"fieldname":"Lead_Source_Detail__c","isvalue":false,"overwrite":false},"Name":{"fieldname":"Name","isvalue":false,"overwrite":false},"Lead_Source__c":{"fieldname":"LeadSource","isvalue":false,"overwrite":false},"Country_Code__c":{"fieldname":"Country_Code__c","isvalue":false,"overwrite":false},"Locale__c":{"fieldname":"Locale__c","isvalue":false,"overwrite":false},"Quick_Quote_Location__c":{"fieldname":"Quick_Quote_Location__c","isvalue":false,"overwrite":false},"Markets_Interested__c":{"fieldname":"Markets_Interested__c","isvalue":false,"overwrite":false},"Number_of_Desks_2016__c":{"fieldname":"Number_of_Desks_2016__c","isvalue":false,"overwrite":false},"Interested_in_Number_of_Desks__c":{"fieldname":"Interested_in_Number_of_Desks__c","isvalue":false,"overwrite":false},"Number_of_Full_Time_Employees__c":{"fieldname":"Number_of_Full_Time_Employees__c","isvalue":false,"overwrite":false}}}';
        lstAllSettings.add(setting);
    }

    public static void createFieldMappingsContactToOpportunitySetting(){
        Setting__c setting = new setting__c();
        setting.Source_Object__c = 'Contact';
        setting.Destination_Object__c = 'Opportunity';
        setting.Name = 'FieldMappings:ContactToOpportunity';
        setting.Data__c = '{"version":"1","mappings":{"utm_campaign__c":{"fieldname":"utm_campaign__c","isvalue":false,"overwrite":false},"utm_campaign_id__c":{"fieldname":"utm_campaign_id__c","isvalue":false,"overwrite":false},"utm_content__c":{"fieldname":"utm_content__c","isvalue":false,"overwrite":false},"utm_medium__c":{"fieldname":"utm_medium__c","isvalue":false,"overwrite":false},"utm_source__c":{"fieldname":"utm_source__c","isvalue":false,"overwrite":false},"utm_term__c":{"fieldname":"utm_term__c","isvalue":false,"overwrite":false},"LeadSource":{"fieldname":"LeadSource","isvalue":false,"overwrite":false},"Lead_Source_Detail__c":{"fieldname":"Lead_Source_Detail__c","isvalue":false,"overwrite":false},"Market__c":{"fieldname":"Market__c","isvalue":false,"overwrite":false},"Company_Size__c":{"fieldname":"Company_Size__c","isvalue":false,"overwrite":false},"Number_of_Desks_2016__c":{"fieldname":"Number_of_Desks_2016__c","isvalue":false,"overwrite":false},"Locations_Interested__c":{"fieldname":"Location_Interested__c","isvalue":false,"overwrite":false},"Referrer_Name__c":{"fieldname":"Referrer_Name__c","isvalue":false,"overwrite":false},"Referrer_Email__c":{"fieldname":"Referrer_Email__c","isvalue":false,"overwrite":false},"Interested_in_Number_of_Desks__c":{"fieldname":"Interested_in_Number_of_Desks__c","isvalue":false,"overwrite":false},"Referral_Fail_Reason__c":{"fieldname":"Referral_Fail_Reason__c","isvalue":false,"overwrite":false},"Promo_Code__c":{"fieldname":"Promo_Code__c","isvalue":false,"overwrite":false}}}';
        lstAllSettings.add(setting);
    }

    public static void createFieldMappingsContactToTourSetting(){
        Setting__c setting = new setting__c();
        setting.Source_Object__c = 'Contact';
        setting.Destination_Object__c = 'Tour_Outcome__c';
        setting.Name = 'FieldMappings:ContactToTour';
        setting.Data__c = '{"version":"1","mappings":{"utm_campaign__c":{"fieldname":"utm_campaign__c","isvalue":false,"overwrite":false},"utm_campaign_id__c":{"fieldname":"utm_campaign_id__c","isvalue":false,"overwrite":false},"utm_content__c":{"fieldname":"utm_content__c","isvalue":false,"overwrite":false},"utm_medium__c":{"fieldname":"utm_medium__c","isvalue":false,"overwrite":false},"utm_source__c":{"fieldname":"utm_source__c","isvalue":false,"overwrite":false},"utm_term__c":{"fieldname":"utm_term__c","isvalue":false,"overwrite":false},"Locale__c":{"fieldname":"Locale__c","isvalue":false,"overwrite":false},"Country_Code__c":{"fieldname":"Country_Code__c","isvalue":false,"overwrite":false},"Primary_Member__c":{"fieldname":"Id","isvalue":false,"overwrite":false}}}';
        lstAllSettings.add(setting);
    }

    public static void createFieldMappingsJourneyToJourneySetting(){
        Setting__c setting = new setting__c();
        setting.Source_Object__c = 'Journey__c';
        setting.Destination_Object__c = 'Journey__c';
        setting.Name = 'FieldMappings:JourneyToJourney';
        setting.Data__c = '{"version":"1","mappings":{"Building_Interested_In__c":{"fieldname":"Building_Interested_In__c","isvalue":false,"overwrite":false},"Lead_Source_Detail__c":{"fieldname":"Lead_Source_Detail__c","isvalue":false,"overwrite":false},"Lead_Source__c":{"fieldname":"Lead_Source__c","isvalue":false,"overwrite":false},"Locale__c":{"fieldname":"Locale__c","isvalue":false,"overwrite":false},"Lost_Reason__c":{"fieldname":"Lost_Reason__c","isvalue":false,"overwrite":false},"Market__c":{"fieldname":"Market__c","isvalue":false,"overwrite":false},"NMD_Next_Contact_Date__c":{"fieldname":"NMD_Next_Contact_Date__c","isvalue":false,"overwrite":false},"Name":{"fieldname":"Name","isvalue":false,"overwrite":false},"Other_Reason__c":{"fieldname":"Other_Reason__c","isvalue":false,"overwrite":false},"Outreach_Result__c":{"fieldname":"Outreach_Result__c","isvalue":false,"overwrite":false},"Outreach_Stage__c":{"fieldname":"Outreach_Stage__c","isvalue":false,"overwrite":false},"Primary_Contact__c":{"fieldname":"Primary_Contact__c","isvalue":false,"overwrite":false},"Primary_Lead__c":{"fieldname":"Primary_Lead__c","isvalue":false,"overwrite":false},"Quick_Quote_Location__c":{"fieldname":"Quick_Quote_Location__c","isvalue":false,"overwrite":false},"Referrer__c":{"fieldname":"Referrer__c","isvalue":false,"overwrite":false},"utm_campaign__c":{"fieldname":"utm_campaign__c","isvalue":false,"overwrite":false},"utm_campaign_id__c":{"fieldname":"utm_campaign_id__c","isvalue":false,"overwrite":false},"utm_content__c":{"fieldname":"utm_content__c","isvalue":false,"overwrite":true},"utm_source__c":{"fieldname":"utm_source__c","isvalue":false,"overwrite":true},"utm_medium__c":{"fieldname":"utm_medium__c","isvalue":false,"overwrite":true},"utm_term__c":{"fieldname":"utm_term__c","isvalue":false,"overwrite":true}}}';
        lstAllSettings.add(setting);
    }

    public static void createFieldMappingsKickboxCSVToLeadSetting(){
        Setting__c setting = new setting__c();
        setting.Source_Object__c = 'Kickbox_Verification__c';
        setting.Destination_Object__c = 'Lead';
        setting.Name = 'FieldMappings:KickboxCSVToLead';
        setting.Data__c = '{"version":"1","mappings":{"First Name":{"fieldname":"First Name","isvalue":false,"overwrite":true},"Last Name":{"fieldname":"Last Name","isvalue":false,"overwrite":true},"Email":{"fieldname":"Email","isvalue":false,"overwrite":true},"Company":{"fieldname":"Company","isvalue":false,"overwrite":true},"Lead Source":{"fieldname":"Lead Source","isvalue":false,"overwrite":true},"Lead Source Detail":{"fieldname":"Lead Source Detail","isvalue":false,"overwrite":true}}}';
        lstAllSettings.add(setting);
    }

    public static void createFieldMappingsLeadToAccountSetting(){
        Setting__c setting = new setting__c();
        setting.Source_Object__c = 'Lead';
        setting.Destination_Object__c = 'Account';
        setting.Name = 'FieldMappings:LeadToAccount';
        setting.Data__c = '{"version":"1","mappings":{"Name":{"value":null,"overwrite":false,"isvalue":false,"fieldname":"Name"},"CurrencyIsoCode":{"value":null,"overwrite":false,"isvalue":false,"fieldname":"CurrencyIsoCode"},"Industry":{"fieldname":"Industry","isvalue":false,"overwrite":false},"Lead_Source__c":{"fieldname":"LeadSource","isvalue":false,"overwrite":false},"Company_Size__c":{"fieldname":"Company_Size__c","isvalue":false,"overwrite":false},"Number_of_Full_Time_Employees__c":{"fieldname":"Number_of_Full_Time_Employees__c","isvalue":false,"overwrite":false},"Interested_in_Number_of_Desks__c":{"fieldname":"Interested_in_Number_of_Desks__c","isvalue":false,"overwrite":false},"Locale__c":{"fieldname":"Locale__c","isvalue":false,"overwrite":false},"Market__c":{"fieldname":"Market__c","isvalue":false,"overwrite":false}}}';
        lstAllSettings.add(setting);
    }

    public static void createFieldMappingsLeadToActivitySetting(){
        Setting__c setting = new setting__c();
        setting.Source_Object__c = 'Lead';
        setting.Destination_Object__c = 'Task';
        setting.Name = 'FieldMappings:LeadToActivity';
        setting.Data__c = '{"version":"1","mappings":{"Locale__c":{"value":null,"overwrite":false,"isvalue":false,"fieldname":"Locale__c"},"Lead_Source__c":{"value":null,"overwrite":false,"isvalue":false,"fieldname":"LeadSource"},"Country_Code__c":{"value":null,"overwrite":false,"isvalue":false,"fieldname":"Country_Code__c"},"Lead_Source_Detail__c":{"value":null,"overwrite":false,"isvalue":false,"fieldname":"Lead_Source_Detail__c"},"utm_campaign__c":{"value":null,"overwrite":false,"isvalue":false,"fieldname":"utm_campaign__c"},"utm_campaign_id__c":{"value":null,"overwrite":false,"isvalue":false,"fieldname":"utm_campaign_id__c"},"utm_content__c":{"value":null,"overwrite":false,"isvalue":false,"fieldname":"utm_content__c"},"utm_medium__c":{"value":null,"overwrite":false,"isvalue":false,"fieldname":"utm_medium__c"},"utm_source__c":{"value":null,"overwrite":false,"isvalue":false,"fieldname":"utm_source__c"},"utm_term__c":{"value":null,"overwrite":false,"isvalue":false,"fieldname":"utm_term__c"},"Product_Interests__c":{"value":null,"overwrite":false,"isvalue":false,"fieldname":"Product_Interests__c"},"Broker_Email__c":{"fieldname":"Broker_Email__c","isvalue":false,"overwrite":false},"Broker_Phone__c":{"fieldname":"Broker_Phone__c","isvalue":false,"overwrite":false},"Company_Size__c":{"fieldname":"Company_Size__c","isvalue":false,"overwrite":false},"Company__c":{"fieldname":"Company","isvalue":false,"overwrite":false},"First_Name__c":{"fieldname":"FirstName","isvalue":false,"overwrite":false},"Industry__c":{"fieldname":"Industry","isvalue":false,"overwrite":false},"Last_Name__c":{"fieldname":"LastName","isvalue":false,"overwrite":false},"Locations_Interested__c":{"fieldname":"Locations_Interested__c","isvalue":false,"overwrite":false},"Product_Line__c":{"fieldname":"Product_Line__c","isvalue":false,"overwrite":false},"Promo_Code__c":{"fieldname":"Promo_Code__c","isvalue":false,"overwrite":false},"Quick_Quote_Location__c":{"fieldname":"Quick_Quote_Location__c","isvalue":false,"overwrite":false},"Referral_Code__c":{"fieldname":"Referral_Code__c","isvalue":false,"overwrite":false},"Referrer__c":{"fieldname":"Referrer__c","isvalue":false,"overwrite":false},"Contact_Broker__c":{"fieldname":"Contact_Broker__c","isvalue":false,"overwrite":false},"Description":{"fieldname":"Description","isvalue":false,"overwrite":false},"Market__c":{"fieldname":"Market__c","isvalue":false,"overwrite":false},"Phone__c":{"fieldname":"Phone","isvalue":false,"overwrite":false},"Email__c":{"fieldname":"Email","isvalue":false,"overwrite":false},"Markets_Interested__c":{"fieldname":"Markets_Interested__c","isvalue":false,"overwrite":false},"Interested_in_Number_of_Desks__c":{"fieldname":"Interested_in_Number_of_Desks__c","isvalue":false,"overwrite":false},"Number_of_Full_Time_Employees__c":{"fieldname":"Number_of_Full_Time_Employees__c","isvalue":false,"overwrite":false}}}';
        setting.Source_Object__c = 'Lead';
        lstAllSettings.add(setting);
    }
    public static void createFieldMappingsLeadToContactSetting(){
        Setting__c setting = new setting__c();
        setting.Source_Object__c = 'Lead';
        setting.Destination_Object__c = 'Contact';
        setting.Name = 'FieldMappings:LeadToContact';
        setting.Data__c = '{"version":"1","mappings":{"LeadSource":{"fieldname":"LeadSource","isvalue":false,"overwrite":false},"Company__c":{"fieldname":"Company","isvalue":false,"overwrite":false},"LastName":{"fieldname":"LastName","isvalue":false,"overwrite":false},"Country_Code__c":{"fieldname":"Country_Code__c","isvalue":false,"overwrite":false},"Email":{"fieldname":"Email","isvalue":false,"overwrite":false},"Phone":{"fieldname":"Phone","isvalue":false,"overwrite":false},"City__c":{"fieldname":"Country","isvalue":false,"overwrite":false},"utm_campaign__c":{"fieldname":"utm_campaign__c","isvalue":false,"overwrite":false},"utm_campaign_id__c":{"fieldname":"utm_campaign_id__c","isvalue":false,"overwrite":false},"utm_content__c":{"fieldname":"utm_content__c","isvalue":false,"overwrite":false},"utm_medium__c":{"fieldname":"utm_medium__c","isvalue":false,"overwrite":false},"utm_source__c":{"fieldname":"utm_source__c","isvalue":false,"overwrite":false},"utm_term__c":{"fieldname":"utm_term__c","isvalue":false,"overwrite":false},"Quick_Quote_Location__c":{"fieldname":"Quick_Quote_Location__c","isvalue":false,"overwrite":false},"Locale__c":{"fieldname":"Locale__c","isvalue":false,"overwrite":false},"Lead_Source_Detail__c":{"fieldname":"Lead_Source_Detail__c","isvalue":false,"overwrite":false},"Referrer__c":{"fieldname":"Referrer__c","isvalue":false,"overwrite":false},"Promo_Code__c":{"fieldname":"Promo_Code__c","isvalue":false,"overwrite":false},"Company_Name__c":{"fieldname":"Company","isvalue":false,"overwrite":false},"FirstName":{"fieldname":"FirstName","isvalue":false,"overwrite":false},"Market__c":{"fieldname":"Market__c","isvalue":false,"overwrite":false},"MobilePhone":{"fieldname":"MobilePhone","isvalue":false,"overwrite":false},"Product_Line__c":{"fieldname":"Product_Line__c","isvalue":false,"overwrite":false},"Location_Interested__c":{"fieldname":"Locations_Interested__c","isvalue":false,"overwrite":false},"Location__c":{"fieldname":"Building_Interested_In__c","isvalue":false,"overwrite":false},"Product_Interests__c":{"fieldname":"Product_Interests__c","isvalue":false,"overwrite":false},"Markets_Interested__c":{"fieldname":"Markets_Interested__c","isvalue":false,"overwrite":false},"Number_of_Desks_2016__c":{"fieldname":"Number_of_Desks_2016__c","isvalue":false,"overwrite":false},"Interested_in_Number_of_Desks__c":{"fieldname":"Interested_in_Number_of_Desks__c","isvalue":false,"overwrite":false},"Number_of_Full_Time_Employees__c":{"fieldname":"Number_of_Full_Time_Employees__c","isvalue":false,"overwrite":false}}}';
        lstAllSettings.add(setting);
    }

    public static void createFieldMappingsLeadToJourneySetting(){
        Setting__c setting = new setting__c();
        setting.Source_Object__c = 'Lead';
        setting.Destination_Object__c = 'Journey__c';
        setting.Name = 'FieldMappings:LeadToJourney';
        setting.Data__c = '{"version":"1","mappings":{"utm_campaign__c":{"fieldname":"utm_campaign__c","isvalue":false,"overwrite":false},"utm_campaign_id__c":{"fieldname":"utm_campaign_id__c","isvalue":false,"overwrite":false},"utm_content__c":{"fieldname":"utm_content__c","isvalue":false,"overwrite":false},"utm_medium__c":{"fieldname":"utm_medium__c","isvalue":false,"overwrite":false},"utm_source__c":{"fieldname":"utm_source__c","isvalue":false,"overwrite":false},"utm_term__c":{"fieldname":"utm_term__c","isvalue":false,"overwrite":false},"Lead_Source_Detail__c":{"fieldname":"Lead_Source_Detail__c","isvalue":false,"overwrite":false},"Name":{"fieldname":"Name","isvalue":false,"overwrite":false},"Lead_Source__c":{"fieldname":"LeadSource","isvalue":false,"overwrite":false},"Country_Code__c":{"fieldname":"Country_Code__c","isvalue":false,"overwrite":false},"Locale__c":{"fieldname":"Locale__c","isvalue":false,"overwrite":false},"Quick_Quote_Location__c":{"fieldname":"Quick_Quote_Location__c","isvalue":false,"overwrite":false},"Markets_Interested__c":{"fieldname":"Markets_Interested__c","isvalue":false,"overwrite":false},"Market__c":{"fieldname":"Market__c","isvalue":false,"overwrite":false},"Number_of_Desks_2016__c":{"fieldname":"Number_of_Desks_2016__c","isvalue":false,"overwrite":false},"Interested_in_Number_of_Desks__c":{"fieldname":"Interested_in_Number_of_Desks__c","isvalue":false,"overwrite":false},"Number_of_Full_Time_Employees__c":{"fieldname":"Number_of_Full_Time_Employees__c","isvalue":false,"overwrite":false},"Primary_Email__c":{"fieldname":"Email","isvalue":false,"overwrite":false},"Primary_Phone__c":{"fieldname":"Phone","isvalue":false,"overwrite":false},"Locations_Interested__c":{"fieldname":"Locations_Interested__c","isvalue":false,"overwrite":false},"Building_Interested_In__c":{"fieldname":"Building_Interested_In__c","isvalue":false,"overwrite":false},"Move_In_Time_Frame__c":{"fieldname":"Move_In_Time_Frame__c","isvalue":false,"overwrite":false},"Promo_Code__c":{"fieldname":"Promo_Code__c","isvalue":false,"overwrite":false},"CampaignId__c":{"fieldname":"Kickbox_CampaignId__c","isvalue":false,"overwrite":false},"Ts_and_Cs_Consent__c":{"fieldname":"Ts_and_Cs_Consent__c","isvalue":false,"overwrite":false},"Affiliate_Consent__c":{"fieldname":"Affiliate_Consent__c","isvalue":false,"overwrite":false},"Marketing_Consent__c":{"fieldname":"Marketing_Consent__c","isvalue":false,"overwrite":false}}}';
        lstAllSettings.add(setting);
    }

    public static void createFollowupOptionsSetting(){
        Setting__c setting = new setting__c();
        setting.Name = 'FollowupOptions';
        setting.Data__c = '{"options":"1 Day, 3 Days, 7 Days, 2 Weeks, 3 Months, 6 Months","_comment":"FollowupCallPeriod period is in hours","FollowupCallPeriod":48}';
        lstAllSettings.add(setting);
    }

    public static void createIconSetting(){
        Setting__c setting = new setting__c();
        setting.Name = 'IconSettings';
        setting.Data__c = '{"Account":"standard:account","Building__c":"custom:custom50","Building_Market__c":"custom:custom24","Building_Interest__c":"custom:custom61","Contact":"standard:contact","Contract":"standard:contract","Company":"standard:company","Case":"standard:case","Dashboard":"standard:dashboard","Document":"standard:document","Event":"standard:event","Journey__c":"custom:custom20","Kickbox_Verification__c":"custom:custom62","Lead":"standard:lead","Market__c":"custom:custom93","Note":"standard:note","Opportunity":"standard:opportunity","Opportunity_Reservable__c":"custom:custom76","Product":"standard:product","Pricebook":"standard:pricebook","Report":"standard:report","Reservable__c":"custom:custom87","Referral__c":"custom:custom15","Reservable_View__c":"custom:custom37","RecordType":"standard:quotes","Setting__c":"custom:custom67","Tour_Outcome__c":"custom:custom84","Task":"standard:task","Task__c":"standard:task","User":"standard:user","CombinedAttachment":"standard:file","CampaignMember":"standard:campaign_members","Product_Interested__c":"standard:product","AttachedContentNote":"standard:note"}';
        lstAllSettings.add(setting);
    }

    public static void createJourneyCreationSetting(){
        Setting__c setting = new setting__c();
        setting.Name = 'JourneyCreationSettings';
        setting.Data__c = '{"NextCallInDaysFromLeadCreation":0,"NoCompanyAccountId":"001F000001r0JbC","NextCallInDaysFromJourneyUpdation":0,"NewLeadActivityFields":{"Status":"Open","Subject":"Inbound Lead submission"},"NewJourneyFields":{"Status__c":"Started"},"ExistingJourneyStage":"Started","ExistingJourneyCreatedDateDifference":4,"JourneyAssignmentCutOffDays":30,"CloseInDaysFromJourneyCreation":2,"ClosedJourneyStages":["Completed-Lost","Completed-Won"]}';
     lstAllSettings.add(setting);
    }

    public static void createJourneyReport(){
        Setting__c setting = new setting__c();
        setting.Name = 'JourneyReport';
        setting.Data__c = '[{"ReportName":"Journey Updates","FolderName":"Journey Tracker"}]';
        lstAllSettings.add(setting);
    }

    public static void createJourneySetting(){
        Setting__c setting = new setting__c();
        setting.Name = 'JourneySettings';
        setting.Data__c = '[{"CallResult":"Left VM","NextDate":"3"},{"CallResult":"Busy / No answer","NextDate":"1"},{"CallResult":"Left message","NextDate":"2"}]';
        lstAllSettings.add(setting);
    }

    public static void createKickboxAPISetting(){
        Setting__c setting = new setting__c();
        setting.Name = 'KickboxAPI';
        setting.Data__c = '{"API":[{"Name":"Step1","url":"https://api.kickbox.io/v2/verify-batch?apikey=","apikey":"08322eb22f04597a8dc4fefb0fe5fec1b3e0fd6247b202a6540da75a86f7f54a"},{"Name":"Step2","url":"https://api.kickbox.io/v2/verify-batch/{JobId}?apikey=","apikey":"08322eb22f04597a8dc4fefb0fe5fec1b3e0fd6247b202a6540da75a86f7f54a"},{"Name":"CallbcakURL","url":"https://dev5-wework.cs45.force.com/KickboxCallback/services/apexrest/Kickbox","apikey":""}],"Attachments":{"ParentId":"0038A000005VOfH","Message":"Process is going to take some time, you will be notified via email once the process is complete."},"BatchDates":{"FromDate":"07-17-2016","ToDate":"08-20-2016"},"EmailQuality":["deliverable","risky"],"BatchRunEmailNotify":["mayuresh.ghodke@enzigma.in","sagar.bagul@enzigma.com","girish.bhandari@enzigma.in","priyanka.shinde@enzigma.in","shobhit.gahlot@enzigma.com"]}';
        lstAllSettings.add(setting);
    }

    public static void createLeadJourneyTriggerSetting(){
        Setting__c setting = new setting__c();
        setting.Name = 'LeadJourneyTrigger';
        setting.Data__c = '[{"LeadStatus":"Unqualified","JourneyStage":"Unqualified"}]';
        lstAllSettings.add(setting);
    }

    public static void createManageToursOpportunityStagesSetting(){
        Setting__c setting = new setting__c();
        setting.Name = 'ManageToursOpportunityStages';
        setting.Data__c = '["Closed Won","Closed Lost","Closing","Merged"]';
        lstAllSettings.add(setting);
    }

    public static void createNewTourButtonErrorMessageSetting(){
        Setting__c setting = new setting__c();
        setting.Name = 'NewTourButtonErrorMessage';
        //setting.Data__c = '{"message":{"title":"Tour Info","html":"<p style=\"margin-top: 10px;\">\r\n Tour cannot be booked from this button.\r\n <\/p>\r\n <p style=\"margin-top: 10px;\">\r\n Please go to your <a href=\"\/00Q/o\">Lead<\/a>, <a href=\"\/003/o\">Contact<\/a>, <a href=\"\/006/o\">Opportunity<\/a> or <a href=\"\/a0j/o\">Journey<\/a> and click Manage Tour button to book tour\r\n for your Lead, Contact, Opportunity or Journey./\r/\n <\/p>"}}';
        lstAllSettings.add(setting);
    }

    public static void createOpportunitySetting(){
        Setting__c setting = new setting__c();
        setting.Name = 'Opportunity Settings';
        setting.Data__c = '{"OpportunityCreationSetting":[{"RecordType":"Consumer","CompanySize":"1-99"},{"RecordType":"Mid Market","CompanySize":"100-999"},{"RecordType":"Enterprise Solutions","CompanySize":"1000+"}],"SendPaperworkStages":{"ExcludedStages":["Closed Won","Closed Lost","Closing"],"EnterpriseSolutions":["Qualifying","B"]}}';
        lstAllSettings.add(setting);
    }

    public static void createOpportunityFromLatestOpportunitySetting(){
        Setting__c setting = new setting__c();
        setting.Name = 'OpportunityFromLatestOpportunity';
        setting.Data__c = '{"LeadSource":{"name":"LeadSource","overwrite":false},"Lead_Source_Detail__c":{"name":"Lead_Source_Detail__c","overwrite":true},"utm_campaign__c":{"name":"utm_campaign__c","overwrite":true},"utm_campaign_id__c":{"name":"utm_campaign_id__c","overwrite":false},"utm_content__c":{"name":"utm_content__c","overwrite":false},"utm_medium__c":{"name":"utm_medium__c","overwrite":true},"utm_source__c":{"name":"utm_source__c","overwrite":false},"utm_term__c":{"name":"utm_term__c","overwrite":false},"Referrer__c":{"name":"Referrer__c","overwrite":false},"createDuration":{"upto":"6 Months"}}';
        lstAllSettings.add(setting);
    }

    public static void createOpportunityProductsMappingSetting(){
        Setting__c setting = new setting__c();
        setting.Name = 'OpportunityProductsMapping';
        setting.Data__c = '{"ReservableTypeProductMapping":[{"ReservableType":"HotDesk","ProductName":"Hot Desk"},{"ReservableType":"DedicatedDesk","ProductName":"Dedicated Desk"},{"ReservableType":"Office","ProductName":"Desk"},{"ReservableType":"SharedOfficeDesk","ProductName":"Shared Office Desk"}],"ConsiderProducts":["Desk","Dedicated Desk","Hot Desk","Enterprise Desk","Enterprise Solutions Desk","Shared Office Desk"]}';
        lstAllSettings.add(setting);
    }

    public static void createOpportunityRelatedObjectSetting(){
        Setting__c setting = new setting__c();
        setting.Name = 'OpportunityRelatedObjectSettings';
        setting.Data__c ='{"MergeObjectSettings":[{"ObjectType":"Tour_Outcome__c","FieldToUpdate":"Opportunity__c","Condition":[],"IsNew":false},{"ObjectType":"Task","FieldToUpdate":"WhatId","Condition":[],"IsNew":false},{"ObjectType":"Discount__c","FieldToUpdate":"Opportunity__c","FieldToQuery":"Promotion_code__c,Discount_Type__c,Type__c","Condition":["Promotion_code__c","Discount_Type__c","Type__c"],"IsNew":false},{"ObjectType":"Building_Interest__c","FieldToUpdate":"Opportunity__c","Condition":[],"IsNew":false},{"ObjectType":"dsfs__DocuSign_Status__c","FieldToUpdate":"dsfs__Opportunity__c","Condition":[],"IsNew":false},{"ObjectType":"Opportunity_Reservable__c","FieldToUpdate":"Opportunity__c","FieldToQuery":"Reservable__r.UUID__c","Condition":["Reservable__r.UUID__c"],"IsNew":false},{"ObjectType":"Reservable__c","FieldToUpdate":"On_Hold_For__c","Condition":[],"IsNew":false},{"ObjectType":"Opportunity_Role__c","FieldToUpdate":"Opportunity__c","Condition":[],"IsNew":false},{"ObjectType":"OpportunityLineItem","FieldToUpdate":"opportunityId","Condition":[],"IsNew":true,"ConditionField":"PricebookEntryId"},{"ObjectType":"OpportunityContactRole","FieldToUpdate":"opportunityId","Condition":[],"IsNew":true,"ConditionField":"contactId"},{"ObjectType":"OpportunityTeamMember","FieldToUpdate":"opportunityId","Condition":[],"IsNew":true,"ConditionField":"UserId"},{"ObjectType":"ContentDocumentLink","FieldToUpdate":"linkedentityId","Condition":[],"IsNew":true,"ConditionField":"contentdocumentId"},{"ObjectType":"Opportunity_Move_Outs__c","FieldToUpdate":"Opportunity__c","FieldToQuery":"Reservable__c","Condition":["Reservable__c"],"IsNew":false}],"OppStages":["Prospecting","Qualifying","Closing","Selling","Negotiating","E - Prospect","D - Qualified","C - Proposal Sent","B - Membership Agreement Sent","Tour Scheduled","Tour Complete","Office Hold","Contract Sent"],"OwnershipProfiles":["WeWork System Administrator","WeWork Support and Operations","WeWork System Administrator - New Layouts"]}';
        lstAllSettings.add(setting);
    }

    public static void createReferenceSetting(){
        Setting__c setting = new setting__c();
        setting.Name = 'ReferenceSettings';
        setting.Data__c = '{"expireafter":60,"ReferralSource":{"LeadSourceDetail":"Referral Web","LeadSource":"Referral Tool","Other":"Salesforce"}}';
        lstAllSettings.add(setting);
    }

    public static void createRestrictAccountDeletionSetting(){
        Setting__c setting = new setting__c();
        setting.Name = 'RestrictAccountDeletion';
        setting.Data__c = '["00e0G000001CCKfQAO","00eF0000000b0MXIAY"]';
        lstAllSettings.add(setting);
    }
    public static void createSendPaperWorkSetting(){
        Setting__c setting = new setting__c();
        setting.Name = 'SendPaperWorkSetting';
        setting.Data__c = '{"OpportunityCreationSetting":[{"RecordType":"Consumer","CompanySize":"1-20"},{"RecordType":"Mid Market","CompanySize":"21-999"},{"RecordType":"Enterprise Solutions","CompanySize":"1000+"}],"ExcludedProfiles":["WeWork System Administrator"],"AllowedEnterpriseProfiles":["WeWork System Administrator","WeWork Enterprise Solutions","WeWork Support and Operations"],"ExcludedProductTypes":["PxWe","Mixed"],"URL":"https://spacestation-v2-staging.wework.com/venus/index.html#/companies/Opportunity.Billing_Account__r.UUID__c/newPaperwork?noLayout=true&waitForSfSync=true&_k=fiy35i&sfOpportunityId=Opportunity.Encoded_ID__c&building=Opportunity.Building_uuid__c&moveindate=Opportunity.Actual_Start_Date__c"}';
        lstAllSettings.add(setting);
    }

    public static void createSFMCRepliesSetting(){
        Setting__c setting = new setting__c();
        setting.Name = 'SFMC Replies';
        setting.Data__c = '{"emails":[],"message":"Process is going to take some time, you will be notified via email once the process is complete.","opportunityType":["Internal Transfer"],"opportunityStages":["Inquiry","Tour Scheduled","Closed Won"],"parentId":"003F000002G1Y3y","size":500,"template":"SFMC Replies","timeout":5}';
        lstAllSettings.add(setting);
    }

    public static void createTasksUpdateToCompletedBatchSetting(){
        Setting__c setting = new setting__c();
        setting.Name = 'TasksUpdateToCompletedBatch';
        setting.Data__c = '{"NoOfDays":30,"emailId":["samadhan.kadam@enzigma.in"]}';
        lstAllSettings.add(setting);
    }

    public static void createTestSettiingForSkyviaSetting(){
        Setting__c setting = new setting__c();
        setting.Name = 'Test Settiing For Skyvia';
        setting.Data__c = '{"Name":"skyvia"}';
        lstAllSettings.add(setting);
    }

    public static void createTourContactEmailSetting(){
        Setting__c setting = new setting__c();
        setting.Name = 'TourContactEmailSettings';//"test@example.com","test1@example.com","inactiveu@example.com" added by Krishana
        setting.Data__c = '["joinus@wework.com","test@example.com","test1@example.com","inactiveu@example.com"]';
        lstAllSettings.add(setting);
    }

    public static void createTourOpportunityStatusTriggerSetting(){
        Setting__c setting = new setting__c();
        setting.Name = 'TourOpportunityStatusTrigger';
        setting.Data__c = '{"TourOpportunityStatusMappings":[{"TourStatus":"Scheduled","OpportunityStatus":"Qualifying"},{"TourStatus":"Completed","OpportunityStatus":"Selling"}],"ExcludedOpportunityStages":["Closing","Closed Won","Closed Lost"]}';
        lstAllSettings.add(setting);
    }

    public static void createTourOutcomeFormSetting(){
        Setting__c setting = new setting__c();
        setting.Name = 'TourOutcomeForm';
        setting.Data__c = '{"RestrictedProfiles":["WeWork NMD Admin","WeWork NMD User","WeWork NMD User - Beta","WeWork NMD User - Outbound"],"ReservableAvailabilityAPI":{"url":"https://sales-api-staging.wework.com/v2/office_availabilities/search","Headers":{"Authorization":"Token token=dIc0nYcdaPvmFzUq3e0-CQ"}},"CreateTourOutcomes":{"url":"https://sales-api-staging.wework.com/v1/tour_outcomes","Headers":{"Authorization":"Token token=dIc0nYcdaPvmFzUq3e0-CQ"}},"NoShow":{"url":"https://sales-api-staging.wework.com/v1/tours/tour_uuid/no_show","Headers":{"Authorization":"Token token=dIc0nYcdaPvmFzUq3e0-CQ"}},"Reasons":{"url":"https://sales-api-staging.wework.com/v1/reasons","Headers":{"Authorization":"Token token=dIc0nYcdaPvmFzUq3e0-CQ"}},"HowHeards":{"url":"https://sales-api-staging.wework.com/v2/how_heards","Headers":{"Authorization":"Token token=dIc0nYcdaPvmFzUq3e0-CQ"}},"Urgencies":{"url":"https://sales-api-staging.wework.com/v2/urgencies","Headers":{"Authorization":"Token token=dIc0nYcdaPvmFzUq3e0-CQ"}}}';
        lstAllSettings.add(setting);
    }

    public static void createTourReservableAPISetting(){
        Setting__c setting = new setting__c();
        setting.Name = 'TourReservableAPI';
        setting.Data__c = '{"ReservableTourBuildingAvailabilitiesAPI":{"Name":"ReservableTourBuildingAvailabilitiesAPI","url":"https://sales-api-staging.wework.com/v2/available_tour_times","headers":{"Authorization":"Token token=dIc0nYcdaPvmFzUq3e0-CQ"},"RetryAttempts":4,"RetryDelay":2000},"ReservableAvailabilityAPI":{"Name":"ReservableAvailabilityAPI","url":"https://sales-api-staging.wework.com/v2/office_availabilities/search","headers":{"Authorization":"Token token=dIc0nYcdaPvmFzUq3e0-CQ"}},"ReservableCancelAPI":{"Name":"ReservableCancelAPI","url":"https://sales-api-staging.wework.com/v1/tours/:id/cancel","headers":{"Authorization":"Token token=dIc0nYcdaPvmFzUq3e0-CQ"}},"ReservableCreateAPI":{"Name":"ReservableCreateAPI","url":"https://sales-api-staging.wework.com/v2/tours","headers":{"Authorization":"Token token=dIc0nYcdaPvmFzUq3e0-CQ"},"RetryAttempts":2,"RetryDelay":2000},"ReservableRescheduleAPI":{"Name":"ReservableRescheduleAPI","url":"https://sales-api-staging.wework.com/v1/tours/:id/reschedule","headers":{"Authorization":"Token token=dIc0nYcdaPvmFzUq3e0-CQ"}}}';
        lstAllSettings.add(setting);
    }

    public static void createUserRoleUpdateSetting(){
        Setting__c setting = new setting__c();
        setting.Name = 'UserRoleUpdate';
        // Modified by : Krishana
        setting.Data__c = '{"allowedDomains":["enzigma.com","enzigma.in","wework.com","example.com"]}';
        lstAllSettings.add(setting);
    }

    public static void createTourAssignedHostSettings(){
        Setting__c setting = new Setting__c();
        setting.Name = 'TourAssignedHost Settings';
        setting.Data__c = '{"AllowedProfiles":["WeWork System Administrator", "WeWork Regional Sales Lead - Beta","WeWork NMD User"]}';
        lstAllSettings.add(setting);
    }

    public static void createSendPaperworkSettings(){
        Setting__c setting = new Setting__c();
        setting.Name = 'SendPaperworkSetting';
        setting.Data__c = '{ "OpportunityCreationSetting": [ { "RecordType": "Consumer", "CompanySize": "1-20" }, { "RecordType": "Mid Market", "CompanySize": "21-999" }, { "RecordType": "Enterprise Solutions", "CompanySize": "1000+" } ], "ExcludedProfiles": ["WeWork System Administrator" ], "AllowedEnterpriseProfiles": [ "WeWork Support and Operations", "WeWork System Administrator" ], "ExcludedProductTypes": [ "PxWe", "Mixed" ], "URL": "https://spacestation-v2-staging.wework.com/#/companies/Opportunity.Account.UUID__c/newPaperwork?noLayout=true&waitForSfSync=true&_k=fiy35i&sfOpportunityId=Opportunity.Encoded_ID__c&building=Opportunity.Building_uuid__c&moveindate=Opportunity.Actual_Start_Date__c" }yId=Opportunity.Encoded_ID__c&building=Opportunity.Building_uuid__c&moveindate=Opportunity.Actual_Start_Date__c" }';
        lstAllSettings.add(setting);
    }

    public static void createKickboxLeadImporterUtilitySettings(){
        Setting__c setting = new Setting__c();
        setting.Name = 'KickboxLeadImporterUtility';
        setting.Data__c = '{"ChunkSize":100,"JsErrors":[{"FileNotFound":"Attachment required to proceed."},{"FileSize":"Attachment size not supported."},{"MaxRecords":"Maximum number of records allowed are 1000."},{"EmptyFile":"There is no record present in the file. Minimum one record is required."},{"ImporterFailed":"Kickbox Email verification undone. Please contact to system administrator."},{"RequiredColumnsMissing":"CSV File should contain missing columns :"},{"InvalidCSV":"Please select a valid CSV file."},{"RemoveErrorColumn":"Please remove auto generated Error column from file and then upload."}],"SampleCsvTemplate":"Lead Importer CSV Template","CsvAPINames":["Id","FirstName","Email","Company","Phone","Locations_Interested__c","Market__c"],"HelperText":"Please upload a valid CSV file with size under 25 MB and 1000 rows.","MaxAllowedRecords":1000}';
        lstAllSettings.add(setting);
    }

    public static void createUpdateJourneyOnCampaignMemberBatch(){
        Setting__c setting = new Setting__c();
        setting.Name = 'UpdateJourneyOnCampaignMemberBatch';
        setting.Data__c = '{"CampaignType":["Splash Event","Event"],"JourneyLeadSource":["Event","Cold Email","Outbound Email/Cold Call","WeWork.com"],"NotifyEmails":["test@example.com"]}';
        lstAllSettings.add(setting);
    }

    public static void createRestrictUserRoleToChangeLeadSourceSettings(){
        Setting__c setting = new setting__c();
        setting.Name = 'restrictUserRoleToChangeLeadSource';
        setting.Data__c = '["CM - Argentina","CM - Australia","CM - Brazil","CM - Canada","CM - China","CM - Colombia","CM - France","CM - Germany","CM - Hong Kong","CM - India","CM - Israel","CM - Korea","CM - Mexico","CM - Netherlands","CM - Spain","CM - UK","CM - US East","CM - US South","CM - US TriState","CM - US West","LEAD - Argentina Com Sales","LEAD - Argentina Key Sales","LEAD - Australia Com Sales","LEAD - Australia Key Sales","LEAD - Brazil Com Sales","LEAD - Brazil Key Sales","LEAD - Canada Com Sales","LEAD - Canada Key Sales","LEAD - China Com Sales","LEAD - China Key Sales","LEAD - Colombia Key Sales","LEAD - France Com Sales","LEAD - France Key Sales","LEAD - Germany Com Sales","LEAD - Germany Key Sales","LEAD - Hong Kong Key Sales","LEAD - India Com Sales","LEAD - India Key Sales","LEAD - Israel Com Sales","LEAD - Israel Key Sales","LEAD - Korea Com Sales","LEAD - Korea Key Sales","LEAD - Mexico Com Sales","LEAD - Mexico Key Sales","LEAD - Netherlands Com Sales","LEAD - Netherlands Key Sales","LEAD - Spain Com Sales","LEAD - Spain Key Sales","LEAD - UK Com Sales","LEAD - UK Key Sales","LEAD - US Com Sales East","LEAD - US Com Sales South","LEAD - US Com Sales TriState","LEAD - US Com Sales West","LEAD - US Key Sales East","LEAD - US Key Sales South","LEAD - US Key Sales TriState","LEAD - US Key Sales West","REP - Argentina Con Sales","REP - Australia Con Sales","REP - Brazil Con Sales","REP - Canada Con Sales","REP - China Con Sales","REP - Colombia Con Sales","REP - France Con Sales","REP - Germany Con Sales","REP - Hong Kong Con Sales","REP - India Con Sales","REP - Israel Con Sales","REP - Korea Con Sales","REP - Mexico Con Sales","REP - Netherlands Con Sales","REP - Spain Con Sales","REP - UK Con Sales","REP - US Con Sales East","REP - US Con Sales South","REP - US Con Sales TriState","REP - US Con Sales West","REP - US Ent Sales","Admin"]';
        lstAllSettings.add(setting);
    }

    public static void createCreateOpportunityTeamMember(){
        User userDetails =[SELECT Id, UserRole.Name FROM User where Id=:userinfo.getUserId() ];
        Setting__c setting = new Setting__c();
        setting.Name = 'OpportunityTeamMemberCreationSetting';
        setting.Data__c = '["'+userDetails.UserRole.Name+'","SalesOps - North America","Admin"]';
        lstAllSettings.add(setting);
    }

    public static void createreferralQueueSetting(){
        Setting__c setting = new Setting__c();
        setting.Name = 'Referral Queue';
        setting.Data__c = '["00G0G00000765tD"]';
        lstAllSettings.add(setting);
    }

    public static void createUpdateJourneysOwner(){
        Profile weworkSystemAdmin = [SELECT Id FROM Profile WHERE Name='Wework System Administrator'];
        Map<String,Object> apiUserRecordMap = new Map<String,Object>();
        apiUserRecordMap.put('LastName','API User');
        apiUserRecordMap.put('Username','testapiuser89833@example.com');
        apiUserRecordMap.put('Email','testapiuser8956@example.com');
        User apiUser = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, apiUserRecordMap, true);
        Setting__c setting = new Setting__c();
        setting.Name = 'UpdateJourneysOwner';
        setting.Data__c = '{ "ownerId":"'+apiUser.Id+'"}';
        lstAllSettings.add(setting);
    }

    public static void createAPIUserContactInfoSetting(){
        User objUser = [SELECT Id, Name, Email FROM User WHERE Id = '005F0000003Kmbw'];
        Setting__c setting = new Setting__c();
        setting.Name = 'APIUserContactInfo';
        setting.Data__c = '{"Name":"'+objUser.Name+'","UserId":"'+objUser.Id+'","Email":"'+objUser.Email+'","ContactId":"0031D0000016c1B","ContactUUID":"d6cf5cb1-9b44-4364-8746-e82f53877dfb"}';
        lstAllSettings.add(setting);
    }

    public static void JourneyForceFullyClose(){
        Setting__c setting = new Setting__c();
        setting.Name = 'JourneyForceFullyClose';
        setting.Data__c ='{"Stages":["Completed","Unqualified","Transferred","Nurture"],"NumberOfDays":"30","Emails":["omkar.kadam@enzigma.com","dipak.pawar@enzigma.in","jitesh.adwani@enzigma.com"],"StartDate":"2018-02-01","EndDate":"2018-11-30"}';
        lstAllSettings.add(setting);
    }

    public static void createQueueManagementSettings(){
        Setting__c setting = new Setting__c();
        setting.Name = 'QueueManagementSettings';
        setting.Data__c = '{"excludeprofiles":"","status":["Completed"],"types":["Call","Phone","Email"],"excludesubjects":["Inbound Lead submission"]}';
        lstAllSettings.add(setting);
    }

    public static void createRestrictBatchToChangeOwnerSettings(){
        Setting__c setting = new Setting__c();
        setting.Name = 'RestrictBatch To Change Owner Setting';
        setting.Data__c = '{"TourStatus":["Completed"],"JourneyStatus":["Completed"],"OpportunityStageName":["Closed Won","Closed Lost"]}';
        lstAllSettings.add(setting);
    }

    public static void createPublicDomainSettings(){
        Setting__c setting = new setting__c();
        setting.Name = 'PublicDomainSettings';
        setting.Data__c = '["gmail.com","yahoo.com","yahoo.co.in","hotmail.com","enzigma.in","facebook.com","yahoo.com"]';
        lstAllSettings.add(setting);
    }

    public static void createHoldReservableSettings(){
        Setting__c setting = new setting__c();
        setting.Name = 'HoldReservableSettings';
        setting.Data__c = '{"HoldReservableApi":{"url":"https://sales-api-staging.wework.com//v1/office_holds","Headers":{"Authorization":"Token token=dIc0nYcdaPvmFzUq3e0-CQ"}},"ReservableAvailabilityAPI":{"url":"https://sales-api-staging.wework.com/v2/office_availabilities/search","Headers":{"Authorization":"Token token=dIc0nYcdaPvmFzUq3e0-CQ"}},"HoldoffAPI":{"url":"https://sales-api-staging.wework.com/v1/office_holds/HOLD_UUID/remove","Headers":{"Authorization":"Token token=dIc0nYcdaPvmFzUq3e0-CQ"}},"ReservableType":["HotDeskArea","DedicatedDesk"],"AllowedStages":["Selling","Closing","Negotiating"],"AllowedRecordTyes":["Mid Market","Enterprise Solutions"]}';
        lstAllSettings.add(setting);
    }

    public static void createpurgeResolvedExceptionSettings(){
        Setting__c setting = new setting__c();
        setting.Name = 'PurgeResolvedException';
        setting.Data__c = '{"Criterias":{"No of Days Before":"20","Status":"Resolved" },"Emails":["krishana.tupe@enzigma.com","pranay.jadhav@enzigma.in","girish.bhandari@enzigma.in"],"Messages":["attempt to de-reference a null object"]}';
        lstAllSettings.add(setting);
    }

    public static void createReferralsourcesSettings(){
        Setting__c setting = new Setting__c();
        setting.Name = 'ReferralsourcesSettings';
        setting.Data__c = '["Employee Referral","Member Referral","Broker Referral","Broker"]';
        lstAllSettings.add(setting);
    }

    public static void createNMDProfilesSetting(){
        Setting__c setting = new Setting__c();
        setting.Name = 'NMDProfiles';
        setting.Data__c = '{"AllowedProfiles": ["00eF0000000br9P", "00eF0000000b0MX", "00e0G000001CCKp", "00e0G000001EONF", "00eF0000000b0MXIAY", "00eF0000000aice"], "ExcludedProfiles": ["00eF0000000aice"]}';
        lstAllSettings.add(setting);
    }

    public static void createUnassignedNMDUSQueueSetting(){
        Setting__c setting = new Setting__c();
        setting.Name = 'Unassigned NMD US Queue';
        setting.Data__c = '{"UnassignedNMDUSQueue":["00G0G00000768br"]}';
        lstAllSettings.add(setting);
    }

    public static Void createRetroactiveReferralSettings(){
        Setting__c setting = new Setting__c();
        setting.Name = 'RetroactiveReferralSettings';
        //setting.Data__c = '{"RetroactiveReferralApi":{"url":"https://sales-api-staging.wework.com/v1/retroactive_referrals","Headers":{"Authorization":"Token token=dIc0nYcdaPvmFzUq3e0-CQ"}},"RetroactiveReferralType":["Retroactive Referral","Confidential Referral"],"ContactRecordType":"0120G000001K6d4","AccountRecordType":"0120G000001K6d3","APIUser":"005F0000003Kmbw","AllowedStages":["Closed Won"],"AllowedUsersId":["005F0000006rTQQ","0050G0000096THD","0050G0000099oPl","0050G000009fXz6","0051g000000ULhg","0051g000000ULhZ","0051g000000ULhR"],"AllowedProfileId":["00eF0000000aice"]}';
        setting.Data__c ='{"RetroactiveReferralApi":{"url":"https://sales-api-staging.wework.com/v1/retroactive_referrals","Headers":{"Authorization":"Token token=dIc0nYcdaPvmFzUq3e0-CQ"}},"RetroactiveReferralType":["Retroactive Referral","Confidential Referral"],"ContactRecordType":"0120G000001K6d4","AccountRecordType":"0120G000001K6d3","APIUser":"005F0000003Kmbw","AllowedStages":["Closed Won"],"AllowedUsersId":["0050j000001NLwG","005F0000006rTQQ","0050G0000096THD","0050G00000A7iYvQAJ","0050G0000099oPl","0050G000009fsMAQAY","0050G000009fXz6","005F0000006u0HL","005F0000006rzfSIAQ","0051g000000G8uu","0050G00000A7zLA","005g00000062F0b","0051g000000tWpQ","0050G00000A7VXk","005g00000062F0U","005g00000062F0a","0050j000001NLwF","0050j000001NLwE"],"AllowedProfileId":["00eF0000000aice","00e0G000001Mjm5"],"referralTeamQueueDevloperNames":["Referral_Team"],"RetroactiveReferrType":["Employee","Member","Affiliate","Broker","Licensee"],"RestrictOppStages":["Closed Lost","Merged"],"RestrictCriteria":{"excludeReferralStatus":["Approved"],"allowedOppStages":["Qualifying","Selling","Negotiating","Closing","Closed Won","Licensee"],"excludedContractStages":["Contract Sent","Contract Signed"],"excludedOppStages":["Closed Lost","Merged"]}}';
        lstAllSettings.add(setting);
    }

    public static Void AccountHierarchy_OrgAssignBatchTime(){
        Setting__c setting = new Setting__c();
        setting.Name = 'AccountHierarchy:OrgAssignBatchTime';
        setting.Data__c = '{"lead":"10","account":"10","createdDate":"2017-02-5"}';
        lstAllSettings.add(setting);
    }

    public static Void Account_Hierarchy_Naming_Convention(){
        Setting__c setting = new Setting__c();
        setting.Name = 'Account Hierarchy : Naming Convention';
        setting.Data__c = '{"Org":"{{Name}}:Org","Sales":"{{Parent_Org_Name__c}}:{{Nickname__c}}"}';
        lstAllSettings.add(setting);

    }

    public static void createLeadScoreMechansimSettings(){
        Setting__c setting = new setting__c();
        setting.Name = 'LeadScoreMechanismSetting';
        setting.Data__c ='{"LeadSource":{"Website":["Google","Programmatic","SpaceStation Web","WeLive.com","WeWork.cn","WeWork.com"],"Outbound":["42 Floors","Cold Call","Cold Email","Outboudn/ Cold Call","Outbound","Outbound / Cold Call","Outbound Cold Call/Email","Outbound Email/ Cold Call","Outbound Email/Cold Call","Outbound/ Cold Call","Outbound/Cold Call","Unomy"],"Broker Referral":["Broker","Broker Referral"],"Affiliate Referral":["Affiliate Referral"],"Employee Referral":["Employee Referral"],"Member Referral":["Member Referral"],"Other Referral":["Other Referral"],"Partner Referral":["Partner Referral"],"Walk In":["Walk In"],"Guest Wifi & Events":["Event","Guest Wifi","Guest Wifi & Events"],"Inbound Call":["Inbound Call","Phone Call"],"Inbound Email":["Inbound Email"],"Facebook":["Facebook"]},"InterestedNumberOfDesks":{"0":["0"],"1":["1"],"2-9":["2-9"],"10-20":["10-20"],"21-100":["21-100"],"101-999":["101-999"],"1000+":["1000+"]},"UnomyCompanySize":{"1000+":["10,000+","1001-5000","5001-10,000"]}}';
        lstAllSettings.add(setting);
    }
    public static void createNotifyTeamMemberProfiles(){
        Setting__c setting = new setting__c();
        setting.Name = 'NotifyOppTeamMemberRoles';
        setting.Data__c = '{"OpportunityTeamMemberRoles":["Business Development"]}';
        lstAllSettings.add(setting);

    }

    public static void createValidateReferralLead(){
        Setting__c setting = new setting__c();
        setting.Name = 'ValidateReferralLead';
        setting.Data__c = '{ "validateBeforeDate" : "2018-09-05" }';
        lstAllSettings.add(setting);
    }

    public static void createManageBillingAccountSettings(){
        Setting__c setting = new setting__c();
        setting.Name = 'ManageBillingAccountSetting';
        setting.Data__c = '{"associateBillingAccount": {"withBillingAccount": {"allowedStages": ["qualifying","selling","negotiating","closing"],"allowedContractStages": ["contract voided","contract discarded"]},"withoutBillingAccount": {"allowedStages": ["closing"],"allowedContractStages": ["contract voided","contract discarded"]}},"disassociateBillingaccount": {"allowedOppStages": ["Qualifying","Selling","Negotiating","Closing"],"excludedContractStages": ["Contract Signed","Contract Sent"],"excludedOppStages": ["Closed Lost","Closed Won"]}}';
        lstAllSettings.add(setting);
    }


    public static Void Lead_Org_Assign_Batch_Time(){
        Setting__c setting = new Setting__c();
        setting.Name = 'OrgAssignBatchTime';
        setting.Data__c = '{"Interval":{"minutes":"10"}}';
        lstAllSettings.add(setting);
    }

    public static Void Account_SalesAccountSetting(){
        Setting__c setting = new Setting__c();
        setting.Name = 'SalesAccountSetting';
        setting.Data__c = '{"AccountFields":["Account_Type__c","Name","Website","Phone","BillingAddress","Fax","Company_Size__c","Id"]}';
        lstAllSettings.add(setting);
    }

    public static Void UserQueueJourneyCreation(){
        Profile p1 = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User testUser123 = new User(Alias = 'testU', Email='testUser@example.com',
                                    EmailEncodingKey='UTF-8', LastName='User', LanguageLocaleKey='en_US',
                                    LocaleSidKey='en_US', ProfileId = p1.Id, IsActive = true,
                                    TimeZoneSidKey='America/Los_Angeles', UserName='testUserNameSum12@example.com',
                                    CommunityNickname ='Test45'+TestingUtility.createUserCommunityName());
        insert testUser123;
        Group testGroup = new Group ();
        testGroup.Name = 'Test  Queue';
        testGroup.Type = 'Queue';
        insert testGroup;
        Setting__c setting = new Setting__c();
        setting.Name = 'User/Queue Journey Creation';
        setting.Data__C = '{"allowedUsers":[{"userName":"'+ UserInfo.getUserName() +'","Id":"'+UserInfo.getUserId() +'"}],"allowedQueues":[{"Id":"'+ testGroup.Id +'","queueName":"'+ testGroup.Name +'"}]}';
        lstAllSettings.add(setting);
    }

    public static void createLeadSourceAndDetailsSetting(){
        Setting__c setting = new Setting__c();
        setting.Name = 'Lead:Lead and Lead Source Details';
        setting.Data__c = '{ "LeadSource": [{ "name": "WeWork.com", "OverrideLeadSource": true },{"name":"Broker","OverrideLeadSoruce":false},{"name":"Test Broker","OverrideLeadSoruce":true}], "LeadSourceDetails": ["Book a Tour Form","Broker1","Broker2"]}';
        lstAllSettings.add(setting);
    }

    public static void createContractEventEndpointsSetting(){
        Setting__c setting = new Setting__c();
        setting.Name = 'ContractEventEndpoints';
        setting.Data__c = '{"API":[{"Name":"ContractDiscard","url":"https://sales-api-venus.wework.com/v2/membership_agreements/contractUUID/discard","apikey":"Token token=dIc0nYcdaPvmFzUq3e0-CQ","AllowedOppStage":["Closing"],"AllowedContractStage":["Contract Sent"]}]}';
        lstAllSettings.add(setting);
    }

    public static void createResendPaperworkSetting(){
        Setting__c setting = new Setting__c();
        setting.Name = 'ResendPaperwork';
        setting.Data__c = '{"API":[{"Name":"ContractResend","url":"https://sales-api-venus.wework.com/v2/membership_agreements/contractUUID/resend","apikey":"Token token=dIc0nYcdaPvmFzUq3e0-CQ"}]}';
        lstAllSettings.add(setting);
    }

     public static void createSplashEventJourney(){
        set<String> setUserName = new set<String>();
        set<String> setBuildingEmail = new set<String>();
        setUserName.add('testUserName1@example.com');
        setBuildingEmail.add('Building1@example.com');
        List<Building__c> lstBuilding = [SELECT Id FROM Building__C WHERE Email__c IN :setBuildingEmail];
        System.assert(lstBuilding.size() > 0);
        List<User> lstUser = [select id from User where UserName IN : setUserName];
        System.assert(lstUser.size() > 0);
        Setting__c SplashEventJourneysetting = new Setting__c();
        SplashEventJourneysetting.Name = 'SplashEventJourney';
        SplashEventJourneysetting.Data__c =  '[{"Buildings": ["'+lstBuilding[0].Id+'"],"userId": "'+lstUser[0].Id+'"},{"City":["New York City","Chicago"],"userId":"'+lstUser[0].Id+'"}]';
        insert SplashEventJourneysetting;
    }

    public static void createAllowedProfilesToManageCasesSettings(){
        Setting__c setting = new Setting__c();
        setting.Name = 'AllowedProfilesToManageCases';
        setting.Data__c = '{"profiles":["WeWork System Administrator","WeWork Enterprise Sales Administrator","WeWork NMD User"],"errorMessage":"Case cannot be closed"}';
        lstAllSettings.add(setting);
    }

    public static Void createFieldMappings_Product2ToOpportunityLineItem(){
        Setting__c setting = new Setting__c();
        setting.Name = 'FieldMappings:Product2ToOpportunityLineItem';
        setting.Data__c = '{"version":"1","mappings":{"ProductCode__c":{"fieldname":"ProductCode","isvalue":false,"overwrite":false},"Product_Category__c":{"fieldname":"Default_Product_Category__c","isvalue":false,"overwrite":false},"Family__c":{"fieldname":"Family","isvalue":false,"overwrite":false}}}';
        setting.Source_Object__c = 'Product2';
        setting.Destination_Object__c = 'OpportunityLineItem';
        lstAllSettings.add(setting);
    }

    public static void createFieldMappingsBillAccountToOrgAccount(){
        Setting__c setting = new Setting__c();
        setting.Source_Object__c = 'Account';
        setting.Destination_Object__c = 'Account';
        setting.Name = 'FieldMappings:BillAccountToOrgAccount';
        setting.Data__c = '{"version":"1","mappings":{"OwnerId":{"fieldname":"OwnerId","isvalue":false,"overwrite":false},"RecordTypeId":{"fieldname":"RecordTypeId","isvalue":false,"overwrite":false},"Lead_Source__c":{"value":"Batch","isvalue":true,"overwrite":true}}}';
        lstAllSettings.add(setting);
    }

    public static void createGoogleGeolocationAPI(){
        Setting__c setting = new Setting__c();
        setting.Name = 'Google Geolocation API';
        setting.Data__c = '{ "GeolocationAPI": { "url": "https://maps.googleapis.com/maps/api/geocode/json", "params": { "address": "ADDRESS", "key": "AIzaSyADSGLdP40esKxqpaPn6p4Z7hBGoW3cMS0" }, "headers": { "accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8", "accept-encoding": "gzip, deflate, br" } }, "GeolocationMap": { "url": "https://google-developers.appspot.com/maps/documentation/utils/geocoder/embed", "headers": { "accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8", "accept-encoding": "gzip, deflate, br" } } }';
        lstAllSettings.add(setting);
    }

    public static void createCampaignMemberStatusSetting(){
        Setting__c setting = new Setting__c();
        setting.Name = 'CampaignMemberStatusSetting';
        setting.Data__c = '{ "All": [ { "Campaign": "City__c", "Lead": "City" }, { "Campaign": "State__c", "Lead": "State" } ], "RSVP_Yes": [ { "Campaign": "Name", "Lead": "Last_Event_Name__c" }, { "Campaign": "StartDate", "Lead": "Last_Event_Date__c" } ] }';
        lstAllSettings.add(setting);
    }

    public static void createOpenOpportunityStages(){
        Setting__c setting = new Setting__c();
        setting.Name = 'OpenOpportunityStages';
        setting.Data__c = '["Qualifying","Selling"]';
        lstAllSettings.add(setting);
    }

    public static void createFieldMappingContactToAccountSetting(){
        Setting__c setting = new setting__c();
        setting.Source_Object__c = 'Contact';
        setting.Destination_Object__c = 'Account';
        setting.Name = 'FieldMappings:ContactToAccount';
        setting.Data__c = '{"version":"1","mappings":{"Account_Type__c":{"value":"Org","isvalue":true,"overwrite":false},"Number_of_Full_Time_Employees__c":{"fieldname":"Number_of_Full_Time_Employees__c","isvalue":false,"overwrite":false},"Unomy_Company_ID__c":{"fieldname":"Unomy_Company_ID__c","isvalue":false,"overwrite":false},"Unomy_Company_Name__c":{"fieldname":"Unomy_Company_Name__c","isvalue":false,"overwrite":false},"Name":{"fieldname":"Unomy_Company_Name__c","isvalue":false,"overwrite":false},"Primary_Member__c":{"fieldname":"Contact_ID__c","isvalue":false,"overwrite":false}}}';
        lstAllSettings.add(setting);
    }

    public static void createTransferPaperworkSetting(){
        Setting__c setting = new setting__c();
        setting.Name = 'TransferPaperwork';
        setting.Data__c = '{"AllowedStages":["Selling","Closing","Negotiating","Qualifying"],"AllowedContractStages":["Contract Sent"],"URL":["https://spacestation-v2-staging.wework.com/#/companies/Opportunity.Account.UUID__c"]}';
        lstAllSettings.add(setting);
    }

    public static void createReparentingBypassProfilesSettings(){
        Setting__c setting = new setting__c();
        setting.Name = 'ReparentingBypassProfilesSettings';
        setting.Data__c ='{"OpportunityReparenting":{"ExcludedProfiles":[]},"BillingAccountReparenting":{"ExcludedProfiles":[]},"SalesAccountReparenting":{"ExcludedProfiles":[]}}';
        lstAllSettings.add(setting);
    }

    public static void createMergeOrganizationsSetting(){
        Setting__c setting = new setting__c();
        setting.Name = 'MergeOrganizationsSetting';
        setting.Data__c ='{"metaFields":[{"name":"Name","label":"Name"},{"name":"RecordType.Name","label":"Segment"},{"name":"Primary_Member__r.Name","label":"Main Contact"},{"name":"Parent.Name","label":"Parent Account"},{"name":"HierarchyLevel__c","label":"Hierarchy Level"},{"name":"Number_Of_Open_Opportunities__c","label":"# of Open Opportunitites"}],"OwnershipProfiles":["WeWork NMD User","WeWork NMD Admin","WeWork System Administrator"],"searchFields":["Name"]}';
        lstAllSettings.add(setting);
    }

    public static void createAccountSelectorSettings(){
        Setting__c setting = new setting__c();
        setting.Name = 'AccountSelectorSettings';
        setting.Data__c ='{"Profiles":[""]}';
        lstAllSettings.add(setting);
    }

    public static void createFieldMappingsAccountToBillingAccountSetting(){
        Setting__c setting = new setting__c();
        setting.Source_Object__c = 'Account';
        setting.Destination_Object__c = 'Billing_Account__c';
        setting.Name = 'FieldMappings:AccountToBillingAccount';
        setting.Data__c ='{"version":"1","mappings":{"Cleansed_Unomy_Company_Name__c":{"fieldname":"Cleansed_Unomy_Company_Name__c","isvalue":false,"overwrite":false},"Unomy_Acquisitions__c":{"fieldname":"Unomy_Acquisitions__c","isvalue":false,"overwrite":false},"Unomy_Alexa_Global_Rank__c":{"fieldname":"Unomy_Alexa_Global_Rank__c","isvalue":false,"overwrite":false},"Unomy_Alexa_US_Rank__c":{"fieldname":"Unomy_Alexa_US_Rank__c","isvalue":false,"overwrite":false},"Unomy_Available_Contacts__c":{"fieldname":"Unomy_Available_Contacts__c","isvalue":false,"overwrite":false}}}';
        lstAllSettings.add(setting);
    }

    public static void createAccessTokenSettings(){
        Setting__c setting = new setting__c();
        setting.Name = 'AccessTokenSetting';
        setting.Data__c ='{"grant_type":"password","client_id":"3MVG9AzPSkglhtpvenc1ubvIHNqdSv2B8w9bFU2hNfvAOfxt5ri2SCQo_M.lflR7dukJ5s9LtXu.eZ3KzbmRO","client_secret":"8952510748675479529","username":"joinus@wework.com.cr1dev","password":"PkskoZEHTy67nB","redirect_uri":"https://test.salesforce.com/services/oauth2/callback","setEndpoint":"https://test.salesforce.com/services/oauth2/token","setMethod":"POST"}';
        lstAllSettings.add(setting);
    }
    public static void createRollbarConfigSetting(){
        Setting__c setting = new setting__c();
        setting.Name = 'RollbarConfig';
        setting.Data__c ='{"access-token":"89c57cb14b54dad84cc4f36cb289ed6","URL":"https://api.rollbar.com/api/1/item/"}';
        lstAllSettings.add(setting);
    }

    public static void createRestrictOpportunityCreation(){
        Setting__c setting = new setting__c();
        setting.Name = 'RestrictOpportunityCreation';
        setting.Data__c = '{"restrictCriteria" : {"LeadSource":["Partner Referral","Inbound Call","Walk In"]}, "leadSourceCriteriaForConvertedLead": {} }';
        lstAllSettings.add(setting);
    }


    public static void createSandboxConfigurationSetting(){
        Setting__c setting = new setting__c();
        setting.Name = 'SandboxConfiguration';
        setting.Data__c ='{"users":{"testUser1":{"name":"Test User1","email":"testUser1@example.com"},"testUser2":{"name":"Test User2","email":"testUser2@example.com"}},"sandboxes":{"TestSandBox":["testUser1","testUser2"]}}';
        lstAllSettings.add(setting);
    }

    public static void createCommunityViewApiSettings(){
        Setting__c setting = new setting__c();
        setting.Name = 'CommunityViewAPISetting';
        setting.Data__c ='{"ReservableCreateAPI":{"Name":"ReservableCreateAPI","url":"https://sales-api-staging.wework.com/v2/tours","headers":{"Authorization":"Token token=dIc0nYcdaPvmFzUq3e0-CQ"},"RetryAttempts":2,"RetryDelay":2000},"ReservableRescheduleAPI":{"url":"https://sales-api-staging.wework.com/v1/tours/:id/reschedule","Headers":{"Authorization":"Token token=dIc0nYcdaPvmFzUq3e0-CQ"}},"ReservableTourBuildingAvailabilitiesAPI":{"url":"https://sales-api-staging.wework.com/v2/available_tour_times","Headers":{"Authorization":"Token token=dIc0nYcdaPvmFzUq3e0-CQ"}},"ReservableCancelAPI":{"url":"https://sales-api-staging.wework.com/v1/tours/:id/cancel","Headers":{"Authorization":"Token token=dIc0nYcdaPvmFzUq3e0-CQ"}},"NoShowAPI":{"url":"https://sales-api-staging.wework.com/v1/tours/tour_uuid/no_show","Headers":{"Authorization":"Token token=dIc0nYcdaPvmFzUq3e0-CQ"}},"CreateAccountApi":{"url":"https://sales-api-staging.wework.com/v2/accounts","Headers":{"Authorization":"Token token=dIc0nYcdaPvmFzUq3e0-CQ"}},"ZendeskUrl":{"url":"https://www.zendesk.com/login"},"OppCloseStages":["Closed Lost","Closed Won","Merged"],"OppCloseContractStage":["Contract Sent","Contract Signed"]}';
        lstAllSettings.add(setting);
    }

    public static void createNewOrganizationCreationRequestEmails(){
        Setting__c setting = new setting__c();
        setting.Name = 'NewOrganizationCreationRequestEmails';
        setting.Data__c = '["test.user180918@example.com"]';
        lstAllSettings.add(setting);
    }

    public static void createEnterpriseOppTeamMemberCreation(){
        Setting__c setting = new setting__c();
        setting.Name = 'EnterpriseOppTeamMemberCreation';
        setting.Data__c ='{"ExcludedProfiles":["WeWork Enterprise Solutions"],"AllowedProfiles":[{"profile":"Wework System Administrator","role":"Sales Rep","Access":"Read"}],"DefaultRole":"DefaultRole","DefaultAccess":"Edit"}';
        lstAllSettings.add(setting);
    }

    public static void createTourCloseHour(){
        Setting__c setting = new setting__c();
        setting.Name = 'TourCloseHour';
        setting.Data__c = '{"Instructions":["Instruction1","Instruction2","Instruction3"]}';
        lstAllSettings.add(setting);
    }

    public static void createLeadScoreMechanismForLeadSourceDetail(){
        Setting__c setting = new setting__c();
        setting.Name = 'LeadScoreMechanismForLeadSourceDetail';
        setting.Data__c = '[{"leadSources":["WeWork.com"],"leadSourceDetails":["Book A Tour Availability"],"leadSourceExclude":[]},{"leadSources":[],"leadSourceDetails":["SOS Worldwide Ltd Referral","Inbound Call Page","Instant Offices Limited Referral","Miami re-engage"],"leadSourceExclude":[]},{"leadSources":["Affiliate Referral","Broker Referral"],"leadSourceDetails":["Referral Web"],"leadSourceExclude":[]},{"leadSources":["Broker Referral"],"leadSourceDetails":["Softbank Japan Referral"],"leadSourceExclude":[]},{"leadSources":["Partner Referral"],"leadSourceDetails":["spacingcoil Referral"],"leadSourceExclude":[]},{"leadSources":[],"leadSourceDetails":["NA"],"leadSourceExclude":["Programmatic","Google"]}]';
        lstAllSettings.add(setting);
    }

    public static void createContractUtilitySetting(){
        Setting__c setting = new setting__c();
        setting.Name = 'ContractEventUtility';
        setting.Data__c = '{"DealProductCode":"PRDL-000001","ActiveOwnerId":"005F0000003Kmbw","LostReason":[{"Event":"Contract Canceled","Reason":"Hot Desk Contract Canceled"},{"Event":"Contract Signed Downgrade Event","Reason":"Downgrade Event Contract Signed"},{"Event":"Hot Desk Contract Canceled New Opportunity","Reason":"Hot Desk Contract Canceled New Opportunity"}],"ConsideredProductCodes":["PRDL-000001","PRDD-000100","PRDE-000200","PRES-000300","PRHD-000400","PROF-000900","PRSO-000700","DESK","DEDICATEDDESK","HOTDESK","ENT-DESK","SHAREDOFFICEDESK","PRGA-000800"],"ConsideredDiscounts":["Commitment Term"],"RetainProductFields":["Product_Category__c"]}';
        lstAllSettings.add(setting);
    }

    public static void createUpdateJourneyOutreachStage(){
        Setting__c setting = new setting__c();
        setting.Name = 'UpdateJourneyOutreachStage';
        setting.Data__c = '["Call 1","Manual Outreach","MC Outreach 1","MC Outreach 2","MC Outreach 3","MC Outreach 4","MC Outreach 5","MC Outreach 6"]';
        lstAllSettings.add(setting);
    }

    public static void createJourneyCloseStages(){
        Setting__c setting = new setting__c();
        setting.Name = 'JourneyCloseStages';
        setting.Data__c = '["Completed","Unqualified","Transferred"]';
        lstAllSettings.add(setting);
    }

    public static void createAccountAssignmentByDesks(){
        Setting__c setting = new setting__c();
        setting.Name = 'AccountAssignmentByDesks';
        setting.Data__c = '{"EnterpriseFTE":[{"Size":"1-19","RecordType":"Cluster__r.Sales_Lead__c"},{"Size":"20-49","RecordType":"Mid Market,Consumer"},{"Size":"50+","RecordType":"Enterprise Solutions"}],"MidMarketFTE":[{"Size":"1-9","RecordType":"Community_Sales_Lead__c"},{"Size":"10-19","RecordType":"Cluster__r.Sales_Lead__c"},{"Size":"20+","RecordType":"Mid Market,Consumer"}],"ConsumerFTE":[{"Size":"1-9","RecordType":"Community_Sales_Lead__c"},{"Size":"10+","RecordType":"Cluster__r.Sales_Lead__c"}]}';
        lstAllSettings.add(setting);
    }

    public static void createContactOwnerShipSetting(){
        Setting__c setting = new setting__c();
        setting.Name = 'ContactOwnerShipSetting';
        setting.Data__c = '{"AllowedRecordTypes":["Consumer"]}';
        lstAllSettings.add(setting);
    }

    public static void createRestartLocationSettings(){
        Setting__c setting = new setting__c();
        setting.Name = 'RestartLocation';
        setting.Data__c = '{"a2V0G000003HBYYUA4":"0051F000002G2NWQA0"}';
        lstAllSettings.add(setting);
    }    
}