/************************************************************************************************************************************
Author      :   RamseySolutions 
Description :   This class contains buisness logic of addCampaign from Sales console.

History     :
----------------------------------------------------------------------------------------------------------------------------------
VERSION     DATE                AUTHOR                  DETAIL
1.0         09 September 2016   Amol Darekar       		Initial Developement

**************************************************************************************************************************************/
global class AddMembersToCampaignController{
    
     /************************************************************************************************************************************
    Author              :   
    Description         :   This method returns the Campaign Types from "CampaignSettings" Sales console setting.
    Last Modified Date  :   06 June 2018    
    **************************************************************************************************************************************/
     @RemoteAction
    global static list<string> CampaignTypes(){
        list<Campaign> lstCampaign = new list<Campaign>();
        Setting__c objCampaignTypes = Settings.get('CampaignSettings');
        Debug.log('objCampaignTypes : '+objCampaignTypes);
        list<string> lstTypes = new list<string>();
        Campaingsettings objCampaingsettings = new Campaingsettings();
        if(objCampaignTypes != null){
            objCampaingsettings = (Campaingsettings)JSON.deserialize(objCampaignTypes.Data__c ,Campaingsettings.class);
            lstTypes = objCampaingsettings.AddJourneysToCampaign;
        }
        return lstTypes;
    } 
    
    /************************************************************************************************************************************
    Author              :   Amol Darekar
    Description         :   Get Campaigns list of given Type and it is active. 
    Last Modified Date  :   30 Aug 2016  
	Issue No			:	ST-647
    **************************************************************************************************************************************/
    @RemoteAction
    global static list<Campaign> CampaignInfo(string campaignType){
        list<Campaign> lstCampaign = new list<Campaign>();
        lstCampaign = [SELECT Id, Name FROM Campaign WHERE Type =: campaignType AND IsActive =: true];
        return lstCampaign;
    }
 
    /************************************************************************************************************************************
    Author              :   Amol Darekar
    Description         :   Add new members to Campaign and Change journey Outreach Stage. 
    Last Modified Date  :   30 Aug 2016  
	Issue No			:	ST-647
	Last Modified By    :   Pranay Jadhav, Issue No: ST-702 
    **************************************************************************************************************************************/
    @RemoteAction
    global static boolean addNewCampaignMembers(string campaignId,string strJourneyIds){ 
        Set<Id> setJourneyIds = new Set<Id>();
        set<Id> setLeadIds = new set<Id>();
        set<Id> setContactIds = new set<Id>();
        for(String key : strJourneyIds.split(',')){
            setJourneyIds.add(key);
        }
        list<Journey__c>  lstJourneys = [SELECT Primary_contact__c,Primary_lead__c FROM journey__c WHERE Id IN:setJourneyIds];
        for(Journey__c currentJourney : lstJourneys){
            if(currentJourney.Primary_contact__c != null){
                setContactIds.add(currentJourney.Primary_contact__c);
                
            }
            else if(currentJourney.Primary_lead__c != null){
                setLeadIds.add(currentJourney.Primary_lead__c);      
            }
        }
        list<CampaignMember> lstCampaignMembers = [SELECT leadId,contactId FROM CampaignMember WHERE campaignid =: campaignId];
        set<Id> setCampainMemberIds = new set<Id>();
        for(CampaignMember currentMember : lstCampaignMembers){
            if(currentMember.leadId !=null)
                setCampainMemberIds.add(currentMember.leadId);
            if(currentMember.contactId !=null)
                setCampainMemberIds.add(currentMember.contactId);
        }
        
        list<CampaignMember> lstCampaignMembersToAdd = new list<CampaignMember>();
        
        for(Id leadId : setLeadIds){
            if(setCampainMemberIds !=null && !setCampainMemberIds.contains(leadId)){
                CampaignMember mem = new CampaignMember(campaignid = campaignId,leadId = leadId);
                lstCampaignMembersToAdd.add(mem);
            }
        }
        
        for(Id contactId:setContactIds){
            if(setCampainMemberIds !=null && !setCampainMemberIds.contains(contactId)){
                CampaignMember mem = new CampaignMember(campaignid = campaignId,contactId = contactId);
                lstCampaignMembersToAdd.add(mem);
            }
        }
        Debug.log('lstCampaignMembersToAdd'+lstCampaignMembersToAdd);
        insert lstCampaignMembersToAdd;
        
        list<Journey__c> lstJourneyToUpdate = [SELECT Id,Status__c,Outreach_Stage__c FROM Journey__c WHERE Id IN :setJourneyIds];
        
        for(Journey__c currentJourney: lstJourneyToUpdate){
            currentJourney.Outreach_Stage__c = 'NMD Drip';
        }
        
        update lstJourneyToUpdate;
        return true; 
    }
    
    /************************************************************************************************************************************
    Author              : Amol Darekar
    Description         : This wrapper class is used to store Building and City Details.
    Created Date        : 
    **************************************************************************************************************************************/    
    global class Campaingsettings {
        public List<SplashSettings> SplashSettings;
        public List<String> AddJourneysToCampaign;
    } 
    global class SplashSettings {
        public String splasheventtype;
    }
}