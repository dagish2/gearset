/************************************************************************************************************************************
Author 		: 	Pragalbha Mahajan
Description : 	This class contains the business logic of CreateOppTeamMember Trigger.
History		:
----------------------------------------------------------------------------------------------------------------------------------
VERSION		DATE				AUTHOR					DETAIL
1			08 Jan 2019	        Pragalbha Mahajan     	Initial Development
**************************************************************************************************************************************/
public class TrOpportunityCreateOppTeamMember implements IProcessHandler{
    public void handle(List<sObject> triggerNew, Map<Id, sObject> triggerOldMap){
        createOpportunityTeamMember((list<Opportunity>)triggerNew, triggerOldMap);
    }  

    /************************************************************************************************************************************
    Author 				: 	Pragalbha Mahajan
    Description 		: 	This method is used to Create Opportunity Team Member.
    Issue No.			:	ST-3293
	Created Date		:	08 Jan 2019
    **************************************************************************************************************************************/
    public static void createOpportunityTeamMember(List<Opportunity> lstNewOpportunities, Map<Id, sobject> mapOldOpportunities){
        List<OpportunityTeamMember> lstOpportunityTeamMembers = new List<OpportunityTeamMember>();
        if(mapOldOpportunities.isEmpty()){ // Insert Context
            Set<Id> setOppIdofApiUser = new Set<Id>();
            Map<String, User> mapUserByContactId = new Map<String, User>();

            Map<String, String>  mapApiUserInfo = getApiUserInfoFromSetting();
            Map<String, Set<Id>> mapNMDProfiles = getNMDProfileSetting();
            Set<Id> setNMDProfilesSetting = new Set<Id>(mapNMDProfiles.get('AllowedProfiles'));
            Set<Id> setExcludeProfiles = new Set<Id>(mapNMDProfiles.get('ExcludedProfiles'));

            User susieRomero = (mapApiUserInfo != null &&  String.isNotBlank(mapApiUserInfo.get('UserId'))) ? Settings.getUserById(mapApiUserInfo.get('UserId')) : Settings.getUserById('005F0000003Kmbw');
            User currentUser = Settings.getUserById(UserInfo.getUserId());
            Map<Id,User> mapUserById =  Settings.mapAllUsersById;

            for(Opportunity objOpportunity : lstNewOpportunities){
                if(String.isNotBlank(objOpportunity.Tour_Booked_By__c) && susieRomero != null  && objOpportunity.CreatedById == susieRomero.Id){
                    setOppIdofApiUser.add(objOpportunity.Id);
                    mapUserByContactId.put(objOpportunity.Tour_Booked_By__c, null);
                }
            }
            if(!mapUserByContactId.isEmpty() && mapUserByContactId.size() > 0){
                for(Contact objContact : [SELECT Id, Email FROM Contact WHERE Id IN : mapUserByContactId.keySet()]){
                    User objUser = Settings.getUserByEmail(objContact.Email);
                    if(objUser != null){
                        mapUserByContactId.put(objContact.Id, objUser);
                    }else{
                        mapUserByContactId.put(objContact.Id, currentUser);
                    }
                }
            }
            if(!setNMDProfilesSetting.isEmpty()){
                for(Opportunity objOpportunity : lstNewOpportunities){
                    User objOppTeamUser = setOppIdofApiUser.contains(objOpportunity.Id) ? mapUserByContactId.get(objOpportunity.Tour_Booked_By__c) : currentUser;
                    if(objOppTeamUser.ProfileId != null && setNMDProfilesSetting.contains(String.valueOf(objOppTeamUser.ProfileId).substring(0, 15)) && !setExcludeProfiles.contains(String.valueOf(objOppTeamUser.ProfileId).substring(0, 15))){
                        lstOpportunityTeamMembers.add(helperCreateOpportunityTeamMember(objOppTeamUser,objOpportunity));
                    }
                }
            }
        }
        manageOpportunityTeamMembers(lstOpportunityTeamMembers, lstNewOpportunities, mapOldOpportunities);

        Map<ID,ID> mapOfOppWithReff = new Map<ID,ID>();
        for(Opportunity objOpportunity : lstNewOpportunities){
            Opportunity oldOpportunity = (!mapOldOpportunities.isEmpty()) ? (Opportunity)mapOldOpportunities.get(objOpportunity.Id) : NULL;
            if(String.isNotBlank(objOpportunity.Referrer__c) && (Trigger.isInsert || (Trigger.isUpdate &&  oldOpportunity.Referrer__c != objOpportunity.Referrer__c))){
                mapOfOppWithReff.put(objOpportunity.Id, objOpportunity.Referrer__c);
            }
        }
        if(mapOfOppWithReff.size() > 0){
            List<OpportunityTeamMember> lstOppTeam = addReferrerOwnerAsTeamMember(lstNewOpportunities, mapOldOpportunities, mapOfOppWithReff);
            if(lstOppTeam != null && lstOppTeam.size() > 0){
                lstOpportunityTeamMembers.addAll(lstOppTeam);
            }
        }
        if(OpportunityHelper.lstOpportunityTeamMembers != null && OpportunityHelper.lstOpportunityTeamMembers.size() > 0){
            OpportunityTeamMemberCreation memberCreationSetting = getOppTeamMemberCreationSetting();
            List<OpportunityTeamMember> lstOppTeamMemberToInsert = new List<OpportunityTeamMember>();
            if(memberCreationSetting != null){
                for(OpportunityTeamMember objoppTeamMember: OpportunityHelper.lstOpportunityTeamMembers){
                    User objteamMemberUser = settings.getUserById(objoppTeamMember.userId);
                    if(!memberCreationSetting.ExcludedProfiles.contains(objteamMemberUser.Profile.Name.toLowerCase())){
                        lstOppTeamMemberToInsert.add(objoppTeamMember);
                    }
                }
            }else{
                lstOppTeamMemberToInsert.addAll(OpportunityHelper.lstOpportunityTeamMembers);
            }
            OpportunityHelper.lstOpportunityTeamMembers.clear();
            lstOpportunityTeamMembers.addAll(lstOppTeamMemberToInsert);
        }
        if(lstOpportunityTeamMembers.size() > 0){
            Database.insert(lstOpportunityTeamMembers, false);
        }
    }

    /************************************************************************************************************************************
    Author 				: 	Pragalbha Mahajan
    Description 		: 	This method is used to manage creation of opportunity Team Member Creation.
    Issue No.			:	ST-3293
	Created Date		:	10 Jan 2019
    **************************************************************************************************************************************/
    public static void manageOpportunityTeamMembers(List<OpportunityTeamMember> lstOpportunityTeamMembers, List<Opportunity> lstNewOpportunities, Map<Id, sobject> mapOldOpportunities) {
        List<Opportunity> lstOpportunityToUpdate = new List<Opportunity>();
        Set<Id> setOppIds = new Set<Id>();
        for(Opportunity objOpportunity : lstNewOpportunities){
            Opportunity oldOpportunity = (!mapOldOpportunities.isEmpty()) ? (Opportunity)mapOldOpportunities.get(objOpportunity.Id) : NULL;
            if(oldOpportunity == null || (oldOpportunity != null && (objOpportunity.OwnerId != oldOpportunity.OwnerId))){
                lstOpportunityToUpdate.add(objOpportunity);
            }
        }
        if(!lstOpportunityToUpdate.isEmpty() && lstOpportunityToUpdate.size() > 0){
            Settings.fetchUsers();
            Map<String, String> mapProfileRoles = new Map<String, String>();
            Map<String, String> mapProfileAccess = new Map<String, String>();
            OpportunityTeamMemberCreation memberCreationSetting = getOppTeamMemberCreationSetting();
            if(memberCreationSetting != null){
                for(AllowedProfiles objAllowedProfiles : memberCreationSetting.AllowedProfiles){
                    mapProfileRoles.put(objAllowedProfiles.Profile.toLowerCase(), objAllowedProfiles.Role);
                    mapProfileAccess.put(objAllowedProfiles.Profile.toLowerCase(), objAllowedProfiles.Access);
                }
            }
            String profileName, role, access;
            User oppOwner;
            for(Opportunity oppRec : lstOpportunityToUpdate){
                if(OpportunityTriggerHandler.mapOppRelatedTeamMembers != null && OpportunityTriggerHandler.mapOppRelatedTeamMembers.get(oppRec.Id) != null){
                    lstOpportunityTeamMembers.addAll(OpportunityTriggerHandler.mapOppRelatedTeamMembers.get(oppRec.Id));
                }
                oppOwner = Settings.getUserById(oppRec.OwnerId);
                if(String.isNotBlank(oppOwner.Profile.Name) && (memberCreationSetting.ExcludedProfiles == null || !memberCreationSetting.ExcludedProfiles.Contains(oppOwner.Profile.Name))) {
                    profileName = oppOwner.Profile.Name.toLowerCase();
                    role = (mapProfileRoles.get(profileName) != null) ? mapProfileRoles.get(profileName) : memberCreationSetting.DefaultRole;
                    access = (mapProfileAccess.get(profileName) != null) ? mapProfileAccess.get(profileName) : memberCreationSetting.DefaultAccess;
                    lstOpportunityTeamMembers.add(new OpportunityTeamMember(OpportunityId = oppRec.Id, TeamMemberRole = role, UserId = oppOwner.Id, OpportunityAccessLevel = access));
                }
            }
            Debug.log('lstOpportunityTeamMembers after ---' + lstOpportunityTeamMembers);
        }

    }

    /************************************************************************************************************************************
    Author 				: 	Pragalbha Mahajan
    Description 		: 	This method is used to get API User Setting.
    Issue No.			:	ST-3293
	Created Date		:	10 Jan 2019
    **************************************************************************************************************************************/
    public static Map<String, String> getApiUserInfoFromSetting(){
        Setting__c apiUserContactInfo = Settings.get('APIUserContactInfo');
        if(apiUserContactInfo != null){
            return (Map<String, String>)JSON.deserialize(apiUserContactInfo.Data__c,  Map<String, String>.class);
        }
        return null;
    }

    /************************************************************************************************************************************
    Author 				: 	Pragalbha Mahajan
    Description 		: 	This method is used to get NMD Profile Setting.
    Issue No.			:	ST-3293
	Created Date		:	10 Jan 2019
    **************************************************************************************************************************************/
    public static Map<String, Set<Id>> getNMDProfileSetting(){
        Setting__c objNMDProfilesSetting = Settings.get('NMDProfiles');
        if(objNMDProfilesSetting != null && String.isNotBlank(objNMDProfilesSetting.Data__c)){
           return (Map<String, Set<Id>>)JSON.deserialize(objNMDProfilesSetting.Data__c, Map<String, Set<Id>>.class);
        }
        return null;
    }

    /************************************************************************************************************************************
    Author 				: 	Pragalbha Mahajan
    Description 		: 	This method is used to map Opportunity and Userdetails to Opportunity team member.
    Issue No.			:	ST-3293
	Created Date		:	10 Jan 2019
    **************************************************************************************************************************************/
    public static OpportunityTeamMember helperCreateOpportunityTeamMember(User userDetails, Opportunity opp){
        return  new OpportunityTeamMember(OpportunityId = opp.Id, UserId = userDetails.Id, TeamMemberRole = userDetails.UserRole.Name);
    }

    /************************************************************************************************************************************
        Author              :   Samadhan Kadam
        Description         :   This method is used to add Referrer owner as a OpportunityTeamMember
        Created Date        :   06-Dec-2018
        Issue No.           :   ST-3196
        Last Modified       :
    **************************************************************************************************************************************/
    public static List<OpportunityTeamMember> addReferrerOwnerAsTeamMember(List<Opportunity> lstNewOpportunities, Map<Id, sobject> mapOldOpportunities, Map<ID,ID> mapOfOppWithReff){
        List<OpportunityTeamMember> lstOpportunityTeamMembers;
        if(!mapOfOppWithReff.isEmpty()){
            OpportunityTeamMember objTeamMember;
            Map<String, User> mapOfContactUser = new Map<String, User>();
            for(Contact objContact : [SELECT Id, Email, Owner.Email FROM Contact WHERE Id IN : mapOfOppWithReff.Values()]){
                User objUser = Settings.getUserByEmail(objContact.Owner.Email);
                if(objUser != null){
                    mapOfContactUser.put(objContact.Id, objUser);
                }
            }
			debug.log('mapOfContactUser: '+mapOfContactUser);
            if(mapOfContactUser.size() > 0){
                MetadataSetting__mdt objMeataData = [SELECT Id, DeveloperName, Data__c FROM MetadataSetting__mdt WHERE DeveloperName ='RestrictTeamMemberProfiles'];
                if(objMeataData != null && objMeataData.Data__c != null){
                    Map<String, List<string>> mapExcludedProfiles = (Map<String,List<String>>)JSON.deserialize(objMeataData.Data__c, Map<String,List<String>>.class);
                    lstOpportunityTeamMembers = new List<OpportunityTeamMember>();
                    for(Id oppId : mapOfOppWithReff.keySet()){
                        User referreOwner = mapOfContactUser.get(mapOfOppWithReff.get(oppId));
                        if(!mapExcludedProfiles.get('Excluded Profiles').contains(String.valueOf(referreOwner.ProfileId).substring(0, 15))){
                            lstOpportunityTeamMembers.add(new OpportunityTeamMember(OpportunityId = oppId, UserId = referreOwner.Id, TeamMemberRole = mapExcludedProfiles.get('RoleName')[0]));
                        }
                    }
                }
            }
        }
        debug.log('lstOpportunityTeamMembers: '+lstOpportunityTeamMembers);
        return lstOpportunityTeamMembers;
    }

    public static OpportunityTeamMemberCreation getOppTeamMemberCreationSetting(){
        MetadataSetting__mdt objMetaData = Settings.getMetadataSettingByDevName('ManageOppTeamMemberCreation');
        OpportunityTeamMemberCreation memberCreationSetting;
        if(objMetaData != null && objMetaData.Data__c != null){
            memberCreationSetting = (OpportunityTeamMemberCreation)JSON.deserialize(objMetaData.Data__c, OpportunityTeamMemberCreation.class);
        	return memberCreationSetting;
        }
        return Null;
    }

    public class AllowedProfiles{
        public String Role{get;set;}
        public String Profile{get;set;}
        public String Access{get;set;}
    }
    public class OpportunityTeamMemberCreation {
        public list<AllowedProfiles> AllowedProfiles {get;set;}
        public String DefaultRole {get;set;}
        public String DefaultAccess {get;set;}
        public Set<String> ExcludedProfiles {get;set;}
    }
}