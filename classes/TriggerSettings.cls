/* 
* Created by @anant.kumar@enzigma.com on 11 July 2016
* This class should contain all the triggers  settings
*/
public class TriggerSettings {
    public static TriggerSettings.TriggersMappedField  mappedField = null;
    
    Static{
        get();
    }
    public static TriggerSettings.TriggersMappedField get()
    {
        if(mappedField == null){
            Setting__c setting = Settings.get('TriggerSettings');
            if(setting != null){
                mappedField = (TriggerSettings.TriggersMappedField)JSON.deserialize(setting.Data__c, TriggerSettings.TriggersMappedField.class);
                setRestApiLogTriggerSettings(false);
            }
            else{
                mappedField = new TriggerSettings.TriggersMappedField();
                mappedField.Account_SetAccountPrimaryMember = true;
                mappedField.Account_GenerateUUID = true;
                mappedField.Account_UpdateRelatedOpportunities = false;
                mappedField.Account_UnomyMergeAccounts = true;
                mappedField.Account_OwnerAssignment = true;
                mappedField.Account_UpdateRecordType = true;
                mappedField.Account_CreateMergedAccounts = true;
                mappedField.Account_UpdateMergedAccountUUID = true;             
                mappedField.Account_DeleteAccounts = true;
                mappedField.Account_NotifyPushTopicsForMerge = true;
                mappedField.Account_UpdateCleansedAccNameAndUnomyName = true;
                mappedField.Account_assignmentOnRecordTypeChange = true;
                mappedField.Account_updateAccountName = true;
                mappedField.Account_checkDuplicateNicknameInOrg = true;
                mappedField.Account_deleteAccountValidations = true;
                mappedField.Account_retrictDuplicateOrgName = true; 
                mappedField.Account_reparentChildAccounts = true; 
                mappedField.Account_HierarchyAccountAndOpportunityNameOnMerge = true;
                mappedField.Account_updateOnReparent = true;
                mappedField.Account_SendEmailOnOwnerChange = true;
                mappedField.Setting_createSettingHistory = true;
                mappedField.Setting_validateJsonData = true;
                
                mappedField.Billing_Account_SetAccountPrimaryMember = true;
                mappedField.Billing_Account_GenerateUUID = true;
                mappedField.Billing_Account_SetDefaultAccountOwner = true;
                mappedField.Billing_Account_SetUltimateParent = true;
                mappedField.Billing_Account_UpdateBillingAccountName = true;
                mappedField.Billing_Account_changeChildRecordsParent = true;
                mappedField.Billing_Account_UpdateCleansedAccNameAndUnomyName = true;
                mappedField.Billing_Account_mapParentAccount = true;
                mappedField.Billing_Account_UpdateContactsWithoutAccountId = true;
                
                mappedField.Contact_CheckForDuplicateEmail = true;
                mappedField.Contact_GenerateUUID = true;
                mappedField.Contact_ConvertMatchingLead = true;
                mappedField.Contact_SetPrimaryContactOnAccount = false;
                //This is not in use trigger because it was firing unnecesarily account updates...Commented by Dipak Pawar
                mappedField.Contact_UpdateAccounts = false;
                
                mappedField.Contact_UpdateActiveReferrerOnContact = true;
                mappedField.Contact_RestartJourney = true;
                mappedField.Contact_update_Custom_CRM_User = true;
                mappedField.Contact_SetReferralRecordType = false;
                mappedField.Contact_restrictOverrideLeadSource = true;
                mappedField.Contact_UpdateRecordType = true; 
                mappedField.Contact_updateCleansedUnomyCompanyName = true;
                mappedField.Contact_inheritOrganizationRecordTypeAndOwner = true;
                mappedField.Contact_UpdateOpportunityPromoCode = true;
                mappedField.CampMember_updateLeadFromSplashCampaigns = true;                
                mappedField.CampMember_MemberOwnerAssignment = true;
                mappedField.Contact_UpdateCleansedName = true;
                
                mappedField.Lead_SetOpprtunityStageDependsOnTour = true;
                mappedField.Lead_UpdateBuildingInterestOnLead = true;
                mappedField.Lead_CreateDeleteBuildingInterest = true;
                mappedField.Lead_DeleteBuildingInterestOnLeadDelete = true;
                mappedField.Lead_CopyOfficeTypeFromLeadToBuildingInterest = true;
                mappedField.Lead_ChangeRelatedJourneyStatus = true;
                mappedField.Lead_ConvertLeadsToJourneys = true;
                mappedField.Lead_BlankEmailOrPhoneOnLead = true;
                mappedField.Lead_UpdateJourneyPrimaryContact = true;
                mappedField.Lead_UpdateActiveReferrerOnLead = true;
                mappedField.Lead_UpdateLeadRecordType = false;
                mappedField.Lead_RestartJourney = true;
                mappedField.Lead_CheckForRelatedJourney = true;
                mappedField.Lead_UpdateRecordType = true;
                mappedField.Lead_UpdateCleansedCompanyName = true;
                mappedField.Lead_UpdateLeadOwner = true;
                mappedField.Lead_UpdateLeadSourceAndLeadSourceDetail = true;
                mappedField.Lead_UpdateCleansedName = true;
                mappedField.Lead_PopulateOrganization =true;
                mappedField.Lead_UpdateLeadScore = true;
                mappedField.Opportunity_ExtendReference = true;
                mappedField.Opportunity_UpdateActiveReferrer = true;
                mappedField.Opportunity_CreateDealOnOpportunityCreate = true;
                mappedField.Opportunity_UpdateWeLiveOpportunityType = true;
                mappedField.Opportunity_UpdateOpportunityName = true;
                mappedField.Opportunity_UpdateDealOnOpportunityUpdate = true;
                mappedField.Opportunity_GenerateBuildingInterests = true;
                mappedField.Opportunity_UpdateEncodedID = true;
                mappedField.Opportunity_UpdateOpportunityPrimaryMember = false;
                mappedField.Opportunity_CopyFieldsFromLastOpportunity = true;
                mappedField.Opportunity_DeleteBuildingInterests = true;
                mappedField.Opportunity_MapWithLatestTour = true;
                /* ST-490 - Workflow Cleanup : Move the workflows into a trigger on Opportunity Object not in current scope. */
                mappedField.Opportunity_UpdateRelatedAccountLeadSource = true;
                mappedField.Opportunity_ClearPaymentDetails = false;
                mappedField.Opportunity_UpdateAddressAndAuthorizeOnAccount = false;
                mappedField.Opportunity_UpdateAccountStartDate = false;
                mappedField.Opportunity_UpdateContractSentDate = false;
                mappedField.Opportunity_SetOpportunityInquiryDate = false;
                mappedField.Opportunity_SetBuildingEmailField = false;
                mappedField.Opportunity_ChangeStagefromContractSent_UpdatePaymentDetailsStatustoNullandPaymentURL = false;
                mappedField.Opportunity_UpdateCampaignAuditFields = false;
                mappedField.Opportunity_CreateTaskRayProject = false;
                mappedField.Opportunity_UpdateOpporunityOwnerOnSendPaperwork = true;
                mappedField.Opportunity_MapOpportunityContactRole = true;
                mappedField.Opportunity_UpdateCompanySize = false;
                mappedField.Opportunity_SetOwnerByDealType = true;
                mappedField.Opportunity_PopulateTerritoryStructure = true;
                mappedField.Opportunity_RestrictUserToChangeLeadSource = true;
                mappedField.Opportunity_inheritOrganizationRecordTypeAndOwner = true;
                mappedField.Opportunity_SendEmailOnOwnerChange = true;
                mappedField.Opportunity_UpdateOppForecastCategory = true;
                mappedField.OpportunityLineItem_UpdateOpportunityType = true;
                mappedField.OpportunityLineItem_PopulateProductFieldsOnLineItems = true;
                mappedField.Opportunity_ChangeBillAccountConventionalName = true;
                mappedField.Opportunity_ReparentOpportunity = true;
                mappedField.Opportunity_updateBrokerAccount = true;
                mappedField.Opportunity_SetBrokerInvolved = true;
                mappedField.Opportunity_NotifyEmailAlertToReferralTeam = true;
                
                mappedField.Tour_UpdateActiveReferrerOnTour = true;
                mappedField.Tour_ExtendValidityOfReference = true;
                mappedField.Tour_CloseAllOpenInboundLeadActivities = true;
                mappedField.Tour_UpdateTourEnditme = true;
                mappedField.Tour_ScheduledConvertLead = true;
                mappedField.Tour_StageUpdateforJourneyRecords = true;
                mappedField.Tour_countTour = true;
                mappedField.Tour_tourCreateTaskForEmailReminderSent = true;
                mappedField.Tour_updateOpportunityStage = true;
                //As per discussion with parag we have off this tigger Tour_updateCountOfDeskOnOpportunity
                //Off By Amol Darekar
                mappedField.Tour_updateCountOfDeskOnOpportunity = false;                
                mappedField.Tour_CreateORUpdateTourOutcome = true;
                mappedField.Tour_UpdateOwnerForAssignedHost = true;
                mappedField.Tour_UpdateOwnerForCompletedBy = true;
                // Changed the trigger settings name from Tour_UpdateInterestedBuildingsByUUIDs to Tour_CleanTourOutcomeData
                mappedField.Tour_CleanTourOutcomeData = true;
                mappedField.Tour_EmailAlertToOpportunityOwner = true;
                mappedField.Tour_tourOwnerUpdateNotification = true;
                mappedField.Tour_primaryContractValidation = false;
                mappedField.Tour_updateBookedByOnReschedule = true;
                mappedField.Tour_setTourCanceledDate = true;
                mappedField.Tour_setTourCompletedDate = true;
                mappedField.Tour_setTourScheduledWithEmail = true;
                mappedField.Tour_setLocationEmail = true;
                mappedField.Tour_setTourDate = true;
                mappedField.Journey_SetPrimaryLeadToUnqualified = true;
                mappedField.Journey_UpdateActiveReferrerOnJourney = true;
                mappedField.Journey_CreateJourneyContactOnMemberChange = true;
                mappedField.Journey_GenerateUUID = true;
                mappedField.Journey_WeekendCadence = true;
                mappedField.Journey_UpdateOwnerOnPrimaryContact = false;              
                mappedField.Journey_updateJourneyOnProductInterest =true;

				mappedField.Journey_setContactOutreachStageWhenJourneyStatusChange = true;                
                mappedField.Journey_updateHasActiveJourneyField = true;
                mappedField.Journey_updateWhoIdForTask = true;
                mappedField.Journey_updateJourneysOwner  = true;              
                mappedField.Task_UpdateLeadEngagementFields = true;
                mappedField.Task_ChangeOwnerToFirstUserWhoRespond = true;
                mappedField.Task_UpdateJourneyStageToCompletedLost = true;
                mappedField.Task_CallResultUpdateJourneyNMDDate = true;
                mappedField.Task_UpdateActiveReferrer = true;
                mappedField.Task_UpdateOutreachStageOnJourney = true;                
                mappedField.Task_updateContactOnTask = true;
                
                mappedField.Discount_VerifyStartDate = true;
                
                mappedField.DocuSign_CloseOpportunity = true;
                
                mappedField.Deal_SetClosedDealStatusToBlank = true;
                
                mappedField.Reservable_UpdateSpaceBasedOnSpaceUUID = true;
                
                mappedField.Referral_PreventDuplicateActiveReference = true;
                
                mappedField.User_ChangeLeadOwnerToActiveUser = true;
                
                mappedField.AccountQueue_RestrictDuplicateRecordsForAccountAssignment = true;
                
                mappedField.OpportunityRole_UpdateOpportunityRole = true;
                mappedField.OpportunityRole_UpdateOpportunityContactRole=true;
                mappedField.OpportunityTeamMember_UpdateSplitPercentage = true;
                mappedField.SuggestedDiscounts_SetBuildingLocation = true;
                mappedField.Opportunity_CreateOpportunityTeamMember = true;
                mappedField.Building_SetTerritoryStructure = true;
                mappedField.Cluster_UpdateClusterInfoOnBuilding = true;
                mappedField.Portfolio_UpdatePortfolioInfoOnBuilding = true;
                mappedField.Region_UpdateRegionInfoOnBuilding = true;
                
                mappedField.Territory_UpdateTerritoryInfoOnBuilding = true;
                mappedField.ReservableHold_CallReservableHoldAPI = true;
                mappedField.ReservableHold_UpdateAccResOpp = true;              
                mappedField.ReservableHold_setOpportunity = true;               
                mappedField.ReservableHold_sendHoldEmailAlerts = true;
                mappedField.EnableLogException = true;
                
                mappedField.Update_Space_BasedOn_SpaceUUID = true;
                
                mappedField.Geography_UpdateNearestBuilding = true; 
                mappedField.Opportunity_ManageEnterpriseOppTeamMembers = true;
                mappedField.OpportunityTeamMember_ChangeOpenOppCasesOwner = true;
                mappedField.OpportunityTeamMember_StoreOldOppTeamMemberUserIds = true;
                mappedField.Case_CaseOwnerAssignment = true;
                mappedField.Case_AutoDocumentCreation = true;
                mappedField.Case_AutoDocumentGenerator = true;
                mappedField.Case_ValidateUserToCloseCases = true;                   
                mappedField.Case_RestrictCaseCreationBasedOnOppStages = true;
                mappedField.Case_UpdateCaseSubject = true;
                mappedField.Case_RestrictDuplicateCaseCreation = true;
                mappedField.OpportunityLineItem_UpdateBuildingFromGeography = true;
                mappedField.OpportunityLineItem_UpdateBuildingUUID = true;
                mappedField.Opportunity_NotifyTeamMember = true;
                mappedField.Building_ManageBuildingRelatedGeographies = true;
                mappedField.SendObjectSummaryToDeactivatedUser = true;
                mappedField.LogException_InsertApexDebugLog = true;
                mappedField.LogException_InsertInRollbar =true;
                mappedField.User_BatchOwnerChangeofSobject = true;
                
                //These settings are only used for Trigger Dispatcher Test Methods
                setRestApiLogTriggerSettings(false);

            }
        }
        return mappedField;
    }
    
    public static void setRestApiLogTriggerSettings(Boolean isActive){
        setRestApiLog_BeforeInsertException(isActive);
        setRestApiLog_AfterInsertException(isActive);
        
        setRestApiLog_BeforeUpdateException(isActive);
        setRestApiLog_AfterUpdateException(isActive);
            
        setRestApiLog_BeforeDeleteException(isActive);
        setRestApiLog_AfterDeleteException(isActive);
        
        setRestApiLog_UnDeleteException(isActive);
    }
    public static void setRestApiLog_BeforeInsertException(Boolean isActive){
        mappedField.RestApiLog_BeforeInsertException = isActive;
    }
    public static void setRestApiLog_AfterInsertException(Boolean isActive){
        mappedField.RestApiLog_AfterInsertException = isActive;
    }
    public static void setRestApiLog_BeforeUpdateException(Boolean isActive){
        mappedField.RestApiLog_BeforeUpdateException = isActive;
    }
    public static void setRestApiLog_AfterUpdateException(Boolean isActive){
        mappedField.RestApiLog_AfterUpdateException = isActive;
    }
    public static void setRestApiLog_BeforeDeleteException(Boolean isActive){
       mappedField.RestApiLog_BeforeDeleteException = isActive;
    }
    public static void setRestApiLog_AfterDeleteException(Boolean isActive){
        mappedField.RestApiLog_AfterDeleteException = isActive;
    }
    public static void setRestApiLog_UnDeleteException(Boolean isActive){
        mappedField.RestApiLog_UnDeleteException = isActive;
    }
    
    public class TriggersMappedField {
        public boolean Account_SetAccountPrimaryMember {get; set;}
        public boolean Account_GenerateUUID {get; set;}
        public boolean Account_UpdateRelatedOpportunities {get; set;}
        public boolean Account_UnomyMergeAccounts {get; set;}
        public boolean Account_OwnerAssignment {get;set;} 
        public boolean Account_UpdateRecordType {get;set;}
        public boolean Account_CreateMergedAccounts {get;set;}
        public boolean Account_UpdateMergedAccountUUID {get;set;}
        public boolean Account_DeleteAccounts {get;set;} 
        public boolean Account_NotifyPushTopicsForMerge {get;set;}
        public boolean Account_UpdateCleansedAccNameAndUnomyName {get;set;}
        public boolean Account_assignmentOnRecordTypeChange {get;set;}
        public boolean Account_updateAccountName {get;set;}
        public boolean Account_checkDuplicateNicknameInOrg {get;set;}
        public boolean Account_deleteAccountValidations {get;set;}
        public boolean Account_retrictDuplicateOrgName {get;set;}
        public boolean Account_reparentChildAccounts {get;set;}
        public boolean Account_HierarchyAccountAndOpportunityNameOnMerge {get;set;}
        public boolean Account_updateOnReparent{get;set;}
        public boolean Account_SendEmailOnOwnerChange{get;set;}
        public boolean Setting_createSettingHistory {get;set;}
        public boolean Setting_validateJsonData{get;set;}
        
        public boolean Billing_Account_SetAccountPrimaryMember {get; set;}
        public boolean Billing_Account_GenerateUUID {get; set;}
        public boolean Billing_Account_SetDefaultAccountOwner {get; set;}
        public boolean Billing_Account_SetUltimateParent {get; set;}
        public boolean Billing_Account_UpdateBillingAccountName {get;set;}
        public boolean Billing_Account_changeChildRecordsParent {get;set;}
        public boolean Billing_Account_UpdateCleansedAccNameAndUnomyName {get;set;}
        public boolean Billing_Account_mapParentAccount {get;set;}
        public boolean Billing_Account_UpdateContactsWithoutAccountId {get;set;}

        public boolean Contact_CheckForDuplicateEmail {get; set;}
        public boolean Contact_GenerateUUID {get; set;}
        public boolean Contact_ConvertMatchingLead {get; set;}
        public boolean Contact_SetPrimaryContactOnAccount {get; set;}
        public boolean Contact_UpdateAccounts {get; set;}
        public boolean Contact_UpdateActiveReferrerOnContact {get;set;}
        public boolean Contact_RestartJourney {get;set;}
        public boolean Contact_update_Custom_CRM_User {get;set;}
        public boolean Contact_SetReferralRecordType;
        public boolean Contact_restrictOverrideLeadSource {get;set;} 
        public boolean Contact_UpdateRecordType {get;set;}
        public boolean Contact_updateCleansedUnomyCompanyName {get;set;}
        public boolean Contact_inheritOrganizationRecordTypeAndOwner {get;set;}
        public boolean Contact_UpdateOpportunityPromoCode {get;set;}
        public boolean Contact_UpdateCleansedName {get;set;}
        
        public boolean CampMember_updateLeadFromSplashCampaigns {get; set;}        
        public boolean CampMember_MemberOwnerAssignment {get; set;}
        
        public boolean Lead_SetOpprtunityStageDependsOnTour {get; set;}
        public boolean Lead_UpdateBuildingInterestOnLead {get; set;}
        public boolean Lead_CreateDeleteBuildingInterest {get; set;}
        public boolean Lead_DeleteBuildingInterestOnLeadDelete {get; set;}
        public boolean Lead_CopyOfficeTypeFromLeadToBuildingInterest {get; set;}
        public boolean Lead_ChangeRelatedJourneyStatus {get; set;}
        public boolean Lead_ConvertLeadsToJourneys {get; set;}
        public boolean Lead_UpdateJourneyPrimaryContact {get; set;}
        public boolean Lead_BlankEmailOrPhoneOnLead {get; set;}
        public boolean Lead_UpdateActiveReferrerOnLead {get; set;}
        public boolean Lead_UpdateLeadRecordType {get; set;}
        public boolean Lead_RestartJourney {get;set;}
        public boolean Lead_CheckForRelatedJourney {get;set;}
        public boolean Lead_UpdateRecordType {get;set;}
        public boolean Lead_UpdateCleansedCompanyName {get;set;}
        public boolean Lead_UpdateLeadOwner{get;set;}
        public boolean Lead_UpdateLeadSourceAndLeadSourceDetail{get;set;}
        public boolean Lead_UpdateCleansedName{get;set;}
        public boolean Lead_PopulateOrganization{get;set;}
        public boolean Lead_UpdateLeadScore{get;set;}
        
        public boolean Opportunity_UpdateActiveReferrer {get; set;}
        public boolean Opportunity_ExtendReference {get; set;}
        public boolean Opportunity_CreateDealOnOpportunityCreate {get;set;}
        public boolean Opportunity_UpdateWeLiveOpportunityType {get;set;}
        public boolean Opportunity_UpdateOpportunityName {get;set;}
        public boolean Opportunity_UpdateDealOnOpportunityUpdate {get;set;}
        public boolean Opportunity_GenerateBuildingInterests {get;set;}
        public boolean Opportunity_UpdateEncodedID {get;set;}
        public boolean Opportunity_UpdateOpportunityPrimaryMember {get;set;}
        public boolean Opportunity_CopyFieldsFromLastOpportunity {get;set;}
        public boolean Opportunity_DeleteBuildingInterests {get;set;}
        public boolean Opportunity_UpdateCampaignAuditFields {get;set;} 
        public boolean Opportunity_CreateTaskRayProject {get;set;} 
        
        public boolean Opportunity_UpdateRelatedAccountLeadSource {get;Set;}    
        public boolean Opportunity_ClearPaymentDetails {get;Set;}   
        public boolean Opportunity_UpdateAddressAndAuthorizeOnAccount {get;Set;}    
        public boolean Opportunity_UpdateAccountStartDate {get;Set;}    
        public boolean Opportunity_UpdateContractSentDate {get;Set;}    
        public boolean Opportunity_SetOpportunityInquiryDate {get;Set;}     
        public boolean Opportunity_SetBuildingEmailField {get;Set;} 
        public boolean Opportunity_ChangeStagefromContractSent_UpdatePaymentDetailsStatustoNullandPaymentURL {get;Set;}
        
        public boolean Opportunity_MapWithLatestTour {get;set;}
        public boolean Opportunity_UpdateOpporunityOwnerOnSendPaperwork {get;Set;}
        public boolean Opportunity_MapOpportunityContactRole {get;set;}
        public boolean Opportunity_UpdateCompanySize {get;set;}
        public boolean Opportunity_SetOwnerByDealType {get;set;}
        public boolean Opportunity_PopulateTerritoryStructure {get;set;}
        public boolean Opportunity_RestrictUserToChangeLeadSource    {get;set;}
        public boolean Opportunity_CreateOpportunityTeamMember{get;set;}  
        public boolean Opportunity_inheritOrganizationRecordTypeAndOwner {get;set;}  
        public boolean Opportunity_SendEmailOnOwnerChange {get;set;}
        public boolean Opportunity_UpdateOppForecastCategory {get;set;}
        public boolean Opportunity_NotifyEmailAlertToReferralTeam{get; set;}
        
        public boolean OpportunityLineItem_UpdateOpportunityType{get;set;}
        public boolean OpportunityLineItem_PopulateProductFieldsOnLineItems{get;set;}
        public boolean Opportunity_ChangeBillAccountConventionalName{get;set;}
        public boolean Opportunity_ReparentOpportunity{get;set;}
        public boolean Opportunity_NotifyTeamMember{get;set;}
        
        public boolean Tour_UpdateActiveReferrerOnTour {get; set;}
        public boolean Tour_ExtendValidityOfReference {get;set;}
        public boolean Tour_CloseAllOpenInboundLeadActivities {get;set;}
        public boolean Tour_UpdateTourEnditme {get;set;}
        public boolean Tour_ScheduledConvertLead {get;set;}
        public boolean Tour_StageUpdateforJourneyRecords {get;set;}
        public boolean Tour_countTour {get;set;}
        public boolean Tour_tourCreateTaskForEmailReminderSent{get;set;}
        public boolean Tour_updateOpportunityStage{get;set;}
        public boolean Tour_updateCountOfDeskOnOpportunity{get;set;}        
        public boolean Tour_UpdateOwnerForAssignedHost{get;set;}
        public boolean Tour_UpdateOwnerForCompletedBy{get;set;}
        public boolean Tour_updateBookedByOnReschedule {get;set;}
        // Changed the trigger settings name from Tour_UpdateInterestedBuildingsByUUIDs to Tour_CleanTourOutcomeData
        public boolean Tour_CleanTourOutcomeData{get;set;}
        public boolean Tour_CreateORUpdateTourOutcome {get;set;}
        public boolean Tour_EmailAlertToOpportunityOwner{get;set;}
        public boolean Tour_tourOwnerUpdateNotification{get;set;}
        public boolean Tour_primaryContractValidation{get;set;}
        public boolean Tour_setTourCanceledDate {get;set;}
        public boolean Tour_setTourCompletedDate {get;set;}
        public boolean Tour_setTourScheduledWithEmail {get;set;}
        public boolean Tour_setLocationEmail {get;set;}
        public boolean Tour_setTourDate {get;set;}
        public boolean Journey_SetPrimaryLeadToUnqualified {get; set;}
        public boolean Journey_UpdateActiveReferrerOnJourney {get;set;}
        public boolean Journey_CreateJourneyContactOnMemberChange {get;set;}
        public boolean Journey_GenerateUUID {get;set;}
        public boolean Journey_SetPrimaryLeadStatusWhenJourneyStatusChange {get;set;}
        public boolean Journey_WeekendCadence {get;set;}
        public boolean Journey_UpdateOwnerOnPrimaryContact {get;set;}
        public boolean Journey_updateHasActiveJourneyField {get;set;}
        public boolean Journey_updateWhoIdForTask {get;set;}
        public boolean Journey_setContactOutreachStageWhenJourneyStatusChange{get;set;}
        
        public boolean Task_UpdateLeadEngagementFields {get;set;}
        public boolean Task_ChangeOwnerToFirstUserWhoRespond {get;set;}
        public boolean Task_UpdateJourneyStageToCompletedLost {get;set;}
        public boolean Task_CallResultUpdateJourneyNMDDate {get;set;}
        public boolean Task_UpdateActiveReferrer {get;set;}
        public boolean Task_UpdateOutreachStageOnJourney {get;set;}
        public boolean Task_updateContactOnTask{get;set;}
        
        public boolean Discount_VerifyStartDate {get; set;} 
        public boolean DocuSign_CloseOpportunity {get; set;}    
        public boolean Deal_SetClosedDealStatusToBlank {get;set;}
        public boolean Reservable_UpdateSpaceBasedOnSpaceUUID {get;set;}  
        public boolean Referral_PreventDuplicateActiveReference{get;set;}
        public boolean User_ChangeLeadOwnerToActiveUser{get;set;}
        
        public boolean AccountQueue_RestrictDuplicateRecordsForAccountAssignment{get;set;}
        
        public boolean OpportunityRole_UpdateOpportunityRole{get;set;}
        public boolean OpportunityRole_UpdateOpportunityContactRole{get;set;}
        public boolean OpportunityTeamMember_UpdateSplitPercentage{get;set;}
        public boolean SuggestedDiscounts_SetBuildingLocation{get;set;}
        
        public boolean Building_SetTerritoryStructure{get;set;}
        public boolean Journey_updateJourneysOwner {get;set;}
        public boolean Cluster_UpdateClusterInfoOnBuilding{get;set;}
        public boolean Portfolio_UpdatePortfolioInfoOnBuilding{get;set;}
        
        public boolean Region_UpdateRegionInfoOnBuilding{get;set;}
        public boolean Territory_UpdateTerritoryInfoOnBuilding{get;set;}
        
        public boolean ReservableHold_CallReservableHoldAPI{get;set;}
        public boolean ReservableHold_UpdateAccResOpp{get;set;}
        public boolean ReservableHold_setOpportunity{get;set;}
        public boolean ReservableHold_sendHoldEmailAlerts{get;set;}
        public boolean EnableLogException{get;set;}
        
        public boolean Update_Space_BasedOn_SpaceUUID {get;set;}
        
        public boolean Geography_UpdateNearestBuilding {get;set;}
        public boolean Opportunity_ManageEnterpriseOppTeamMembers{get;set;}
        public boolean OpportunityTeamMember_ChangeOpenOppCasesOwner{get;set;}
        public boolean OpportunityTeamMember_StoreOldOppTeamMemberUserIds{get;set;}        
        public boolean Case_CaseOwnerAssignment{get;set;}
        public boolean Case_AutoDocumentCreation{get;set;}
        public boolean Case_AutoDocumentGenerator{get;set;}
        public boolean Case_ValidateUserToCloseCases{get;set;}
        public boolean Case_RestrictCaseCreationBasedOnOppStages{get;set;}
        public boolean Case_UpdateCaseSubject{get;set;}
        public boolean Case_RestrictDuplicateCaseCreation{get;set;}
        public boolean OpportunityLineItem_UpdateBuildingFromGeography{get;set;}
        public boolean OpportunityLineItem_UpdateBuildingUUID{get;set;}
        public boolean Building_ManageBuildingRelatedGeographies {get;set;}
        public boolean SendObjectSummaryToDeactivatedUser {get;set;}
        public boolean LogException_InsertApexDebugLog {get;set;}
        public boolean LogException_InsertInRollbar {get;set;}
        public boolean Journey_updateJourneyOnProductInterest {get;set;}
        public boolean Opportunity_updateBrokerAccount {get;set;}
        public boolean Opportunity_SetBrokerInvolved{get;set;}
        public boolean User_BatchOwnerChangeofSobject {get;set;}
        
        //These settings are only used for Trigger Dispatcher Test Methods 
        public boolean RestApiLog_BeforeInsertException {get;set;}
        public boolean RestApiLog_AfterInsertException {get;set;}
        public boolean RestApiLog_BeforeUpdateException {get;set;}
        public boolean RestApiLog_AfterUpdateException {get;set;}
        public boolean RestApiLog_BeforeDeleteException {get;set;}
        public boolean RestApiLog_AfterDeleteException {get;set;}
        public boolean RestApiLog_UnDeleteException {get;set;}
    }
}