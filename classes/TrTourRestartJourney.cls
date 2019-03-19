/************************************************************************************************************************************
    Author      	: Dipak Pawar
    Description 	: This class contains business logic of Restart Journeys for Tours
	History:
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1           11 Dec 2018    		Dipak Pawar            	Initial Developement.(ST-3213)
	2			18 Jan 2019			Dipak Pawar				Modify Logic for NMD users and for Non NMD Users.(ST-3352)
	3			12 Feb 2019			Shivprasad Patil		Modify Logic for NMD users and for Non NMD Users.(ST-3397)
**************************************************************************************************************************************/
public class TrTourRestartJourney implements IProcessHandler{ 
    static Map<Id, Contact> mapTourPrimaryMembers;
    public void handle(List<sObject> lstNewTours, Map<Id, sObject> mapOldTours){ 
        restartJourneyForTours((List<Tour_Outcome__c>)lstNewTours, mapOldTours);
    }
    
    /************************************************************************************************************************************
        Author          : Dipak Pawar
        Description     : This method will restart Journeys For Tours
        Created Date    : 11 December 2018
		Issue No        : ST-3213
		Modified By		: Dipak Pawar
		Modified Date	: 18 January 2019
		Issue No        : ST-3352
    ********************************************************************************************************************************/
    static void restartJourneyForTours(List<Tour_Outcome__c> lstNewTours, Map<Id, sObject> mapOldTours) {        
        MetadataSetting__mdt objMetadataSetting = Settings.getMetadataSettingByDevName('TourRestartJourneyStatus');
        Set<String> setTourStatus = (Set<String>)JSON.deserialize(objMetadataSetting.Data__c.toLowerCase(), Set<String>.class);
        Set<Id> setOfLocationIds = new Set<Id>();
        Set<Id> setTourPrimaryMembers = new Set<Id>();
        Set<Id> setBookedByContactIds = new Set<Id>();
        List<Tour_Outcome__c> lstToursForRestartJourney = new List<Tour_Outcome__c>();
        for(Tour_Outcome__c objTour : lstNewTours){ 
            Tour_Outcome__c objOldTour = (Tour_Outcome__c)mapOldTours.get(objTour.Id);
            if(String.isNotBlank(objTour.Primary_Member__c) && String.isNotBlank(objTour.Status__c) && objTour.Status__c != objOldTour.Status__c && !setTourStatus.contains(objOldTour.Status__c.toLowerCase()) && setTourStatus.contains(objTour.Status__c.toLowerCase())){
                setTourPrimaryMembers.add(objTour.Primary_Member__c);
                setBookedByContactIds.add(objTour.booked_by_contact_id__c);
                lstToursForRestartJourney.add(objTour);
                setOfLocationIds.add(objTour.Location__c);
            }
        }
        
        if(lstToursForRestartJourney.size() > 0){
            Map<Id, Id> mapBookedByContactRelatedOwners = getTourJourneyOwners(lstToursForRestartJourney, setBookedByContactIds, setTourPrimaryMembers, setOfLocationIds);
            Map<Id, sObject> mapPrimaryMemberRelatedJourneys = getJourneysToRestart(setTourPrimaryMembers);
            List<Journey__c> lstJourneysToInsert = new List<Journey__c>();
            for(Tour_Outcome__c objTour : lstToursForRestartJourney){
                Contact tourPrimaryMember =  mapTourPrimaryMembers.get(objTour.Primary_Member__c);
                
                Journey__c objJourney = (Journey__c)mapPrimaryMemberRelatedJourneys.get(objTour.Primary_Member__c);
                String strJourneyName = tourPrimaryMember.Name + '-' + Settings.getBuildingById(objTour.Location__c).City__c + '-' + tourPrimaryMember.LeadSource;
                objJourney.Name = strJourneyName.abbreviate(80);
                objJourney.Primary_Contact__c = objTour.Primary_Member__c;
                objJourney.NMD_Next_Contact_Date__c = System.today();
                objJourney.OwnerId = mapBookedByContactRelatedOwners.get(objTour.Id);           
                objJourney.Outreach_Stage__c = 'Manual Outreach';
                objJourney.Status__c = 'Trying to Reach';
                objJourney.Restart_Journey_Reason__c = objTour.Status__c;                
                objJourney.Building_Interested_In__c = objTour.Location__c;
                
                Set<String> setLocationsInterested = new Set<String>();
                if(String.isNotBlank(objJourney.Locations_Interested__c)){
                    setLocationsInterested.addAll(objJourney.Locations_Interested__c.split(';'));
                }
                setLocationsInterested.add(Settings.getBuildingById(objTour.Location__c).Name);                
                objJourney.Locations_Interested__c = String.join(new List<String>(setLocationsInterested), ';');
                
                lstJourneysToInsert.add(objJourney);
            }
            
            if(!lstJourneysToInsert.isEmpty()){
                insert lstJourneysToInsert;
            }
        }
    }
    
    /************************************************************************************************************************************
        Author          : Dipak Pawar
        Description     : This method will return the Journeys related to Tour's Primary Member
        Created Date    : 11 December 2018
		Issue No        : ST-3213
    ********************************************************************************************************************************/
    static Map<Id, sObject> getJourneysToRestart(Set<Id> setTourPrimaryMembers){ 
        return (FieldMappingsHelper.getMappings(setTourPrimaryMembers, 'FieldMappings:ContactToJourney'));
    }
    
    /************************************************************************************************************************************
        Author          : Dipak Pawar
        Description     : This method maps the Tour related Journey owners
        Created Date    : 18 January 2019
		Issue No        : ST-3352
    ********************************************************************************************************************************/
    static Map<Id, Id> getTourJourneyOwners(List<Tour_Outcome__c> lstToursForRestartJourney, Set<Id> setBookedByContactIds, Set<Id> setTourPrimaryMembers, Set<Id> setOfLocationIds){                
        Id unassignedNMDUserQueueId = getUnassignedNMDUserQueueId();
        Map<Id, Id> mapBookedByContactIdRelatedUserIds = getBookedByContactIdRelatedUsers(setBookedByContactIds, setTourPrimaryMembers);
        Map<Id, Id> mapBuildingRelatedOwners = getBuildingRelatedUsers(lstToursForRestartJourney, setOfLocationIds);
        Map<Id, Id> mapTourJourneyOwners = new Map<Id, Id>();
        
        for(Tour_Outcome__c objTour : lstToursForRestartJourney){
            Id journeyOwnerId; 
            if(mapBookedByContactIdRelatedUserIds.containsKey(objTour.booked_by_contact_id__c) && mapBookedByContactIdRelatedUserIds.get(objTour.booked_by_contact_id__c) != null){
                journeyOwnerId = mapBookedByContactIdRelatedUserIds.get(objTour.booked_by_contact_id__c);
            } else if(mapBuildingRelatedOwners.containsKey(objTour.Location__c) && mapBuildingRelatedOwners.get(objTour.Location__c) != null && Settings.getUserActive(mapBuildingRelatedOwners.get(objTour.Location__c))){
                journeyOwnerId = mapBuildingRelatedOwners.get(objTour.Location__c);
            } else {
                journeyOwnerId = unassignedNMDUserQueueId;
            }
            mapTourJourneyOwners.put(objTour.Id, journeyOwnerId);
        }
        return mapTourJourneyOwners;
    }
    
    /************************************************************************************************************************************
        Author          : Dipak Pawar
        Description     : This method maps the Contact related User id by Email
        Created Date    : 11 December 2018
		Issue No        : ST-3213
		Modified By		: Dipak Pawar
		Modified Date	: 18 January 2019
		Issue No        : ST-3352
    ********************************************************************************************************************************/
    static Map<Id, Id> getBookedByContactIdRelatedUsers(Set<Id> setBookedByContactIds, Set<Id> setTourPrimaryMembers){
        Map<Id, Id> mapBookedByContactIdRelatedUserIds = new Map<Id, Id>();
        Id apiUserContactId = getAPIUserContactId();
        Set<Id> setNMDProfileIds = getNMDProfileIds();
        mapTourPrimaryMembers = new Map<Id, Contact>();
        for(Contact objContact : [SELECT Id, Name, Email, LeadSource FROM Contact WHERE Id IN :setBookedByContactIds OR Id IN :setTourPrimaryMembers]){
            if(setTourPrimaryMembers.contains(objContact.Id)){
                mapTourPrimaryMembers.put(objContact.Id, objContact);
            }
            
            User objUser = Settings.getUserByEmail(objContact.Email);
            if(objUser != null && objContact.Id != apiUserContactId && setNMDProfileIds.contains(objUser.ProfileId)){
                mapBookedByContactIdRelatedUserIds.put(objContact.Id, objUser.Id);
            }
        }
        return mapBookedByContactIdRelatedUserIds;
    }
    
    /************************************************************************************************************************************
        Author          : Dipak Pawar
        Description     : This method gives Building related Users
        Created Date    : 18 January 2019
		Issue No        : ST-3352		
    ********************************************************************************************************************************/
    static Map<Id, Id> getBuildingRelatedUsers(List<Tour_Outcome__c> lstTours, Set<Id> setOfLocationIds){
        Map<Id, Id> mapContactRelatedOwnerIds = new Map<Id, Id>();
        Setting__c objRestartLocationSetting = Settings.get('RestartLocation');
        if(objRestartLocationSetting != null){
            Map<Id, Id> mapOfPortfolioToUserId = (Map<Id, Id>)JSON.deserialize(objRestartLocationSetting.Data__c, Map<Id, Id>.class);
            Map<Id, Building__c> mapOfBuilding = new Map<Id, Building__c>([SELECT Id, Market__c FROM Building__c WHERE Id IN :setOfLocationIds]);
            Building__c objBuilding;
            for(Tour_Outcome__c objTour : lstTours){
				objBuilding = mapOfBuilding.get(objTour.Location__c);
                if(objBuilding!=null){
                    if(mapOfPortfolioToUserId.containsKey(objBuilding.Market__c)){
                        mapContactRelatedOwnerIds.put(objTour.Location__c, mapOfPortfolioToUserId.get(objBuilding.Market__c));
                    }
                }
            }
            return mapContactRelatedOwnerIds;
        }
        return null;
    }
    
    /************************************************************************************************************************************
        Author          : Dipak Pawar
        Description     : This method gives the API user contact id
        Created Date    : 11 December 2018
		Issue No        : ST-3352
    ********************************************************************************************************************************/
    static Id getAPIUserContactId(){
        Setting__c objSetting = Settings.get('APIUserContactInfo');
        if(objSetting != null){
            Map<String, String> mapAPIUserSetting = new Map<String, String>();
            mapAPIUserSetting = (Map<String, String>)JSON.deserialize(objSetting.Data__c, Map<String, String>.class);
            if(mapAPIUserSetting != null && mapAPIUserSetting.containsKey('ContactId')){
                return mapAPIUserSetting.get('ContactId');
            }
        }
        return null;
    }
    
    /************************************************************************************************************************************
        Author          : Dipak Pawar
        Description     : This method gives the "Unassigned NMD US Queue" id
        Created Date    : 11 December 2018
		Issue No        : ST-3213
    ********************************************************************************************************************************/  
    public static Id getUnassignedNMDUserQueueId(){
        MetadataSetting__mdt objMetadataSetting = Settings.getMetadataSetting('Unassigned_NMD_US_Queue');        
        if(objMetadataSetting != null && String.isNotBlank(objMetadataSetting.Data__c)){
            return Id.valueOf(objMetadataSetting.Data__c);
        }
        return UserInfo.getUserId();
    }
    
    /************************************************************************************************************************************
        Author          : Dipak Pawar
        Description     : This method gives NMD User Profiles from Custom Metadata
        Created Date    : 18 January 2019
		Issue No        : ST-3352
    ********************************************************************************************************************************/
    static Set<Id> getNMDProfileIds(){
        Setting__c objNMDProfilesSetting = Settings.get('NMDProfiles');
        if(objNMDProfilesSetting != null && String.isNotBlank(objNMDProfilesSetting.Data__c)){
            Map<String, Set<Id>> mapNMDProfiles = (Map<String, Set<Id>>)JSON.deserialize(objNMDProfilesSetting.Data__c, Map<String, Set<Id>>.class);
            if(mapNMDProfiles != null && mapNMDProfiles.containsKey('AllowedProfiles')){
               return mapNMDProfiles.get('AllowedProfiles');
            }
        }
        return null;
    }
}