/************************************************************************************************************************************
    Author      :   RamseySolutions 
    Description :   This class contains buisness logic of CampaignMember trigger.
    
    History     : 
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1.0         22 January 2016     RamseySolutions         Initial Developement
    2.0         05 July 2016        Pranay Jadhav           New Class CampaignMemberTriggerHandler
    3.0         15 March 2018       Sunil Bhosale           New campaign member assignement flow.
    4.0         06 June 2018        Priyanka Ambre          Changes According to ST-2499
**************************************************************************************************************************************/
public class CampaignMemberTriggerHandler extends ITriggerHandler {
    public CampaignMemberTriggerHandler(){
        super('CampaignMember');
    }    
    
  /************************************************************************************************************************************
        Author              :   Priyanka Ambre
        Description         :   This method overrides after insert method from ITriggerHander which will contactRectrol the execution flow.
        Last Modified Date  :   06 June 2018  
		LatsModified        : 	Krishana Tupe on 26 October 2018 for ST-2845
		Description			: 	Fixed duplicate journey creation on Tour booking
  **************************************************************************************************************************************/
    public override void AfterInsert(List<SObject> listNewItems, Map<Id, SObject> mapNewItems){        
        if(TriggerSettings.mappedField.CampMember_updateLeadFromSplashCampaigns){
            updateLeadFromSplashCampaigns((List<CampaignMember>)listNewItems, (Map<Id, CampaignMember>)mapNewItems, null, null); 
        }
    }
    
  /************************************************************************************************************************************
        Author              :   Priyanka Ambre
        Description         :   This method overrides after update method from ITriggerHander which will contactRectrol the execution flow.
        Last Modified Date  :   06 June 2018    
   **************************************************************************************************************************************/
    public override void AfterUpdate(List<SObject> listNewItems, Map<Id, SObject> mapNewItems,List<SObject> listOldItems, Map<Id, SObject> mapOldItems){
        if(TriggerSettings.mappedField.CampMember_updateLeadFromSplashCampaigns)
            updateLeadFromSplashCampaigns((List<CampaignMember>)listNewItems, (Map<Id, CampaignMember>)mapNewItems, null, null);       
    }
    
  /************************************************************************************************************************************
        Author              : Priyanka Ambre
        Description         : This method will update Campaigns fields on Lead.
        Created Date        : 
  **************************************************************************************************************************************/    
    public static void updateLeadFromSplashCampaigns(List<CampaignMember> listNewItems, Map<Id, CampaignMember> mapNewItems, List<CampaignMember> listOldItems, Map<Id, CampaignMember> mapOldItems){        
        List<Lead> lstLeadsToupdate = new List<Lead>();
        Map<Id, Lead> mapLeadsIds ;
        Map<Id, Campaign> mapCampaignIds ;
        Set<Id> setLeadIds = new Set<Id>();
        Set<Id> setCampaignIds = new Set<Id>();
        Set<String> setLeadFields = new Set<String>();
        Set<String> setCampaignFields = new Set<String>();
        Map<String, String> mapAllstatusFields = new Map<String, String>();//Map<Leadfield,CampaignField>
        Map<String, String> mapRSVP_YesstatusFields = new Map<String, String>();
        Map<String, List<Map<String, String>>> mapcampMemberStatus ;
        
        for(CampaignMember member : listNewItems){
            if(String.isNotBlank(member.LeadId)){ // When Lead
                setLeadIds.add(member.LeadId);
            }
            if(String.isNotBlank(member.CampaignId)){
                setCampaignIds.add(member.CampaignId);
            }
        }
        
        Setting__c campMemberStatusSettings = Settings.get('CampaignMemberStatusSetting');
        if(campMemberStatusSettings != null && campMemberStatusSettings.Data__c != null){
            mapcampMemberStatus = (Map<String, List<Map<String, String>>>) JSON.deserialize(campMemberStatusSettings.Data__c, Map<String, List<Map<String, String>>>.class);
        }
        for(String status : mapcampMemberStatus.keySet()){
            for(Map<String, String> mapfields:mapcampMemberStatus.get(status)){
                setLeadFields.add(mapfields.get('Lead'));
                if(status.equalsIgnoreCase('All')){
                    mapAllStatusFields.put(mapfields.get('Lead'), mapfields.get('Campaign'));
                }else if(status.equalsIgnoreCase('RSVP_Yes')){
                    mapRSVP_YesstatusFields.put(mapfields.get('Lead'),mapfields.get('Campaign'));
                }
                setCampaignFields.add(mapfields.get('Campaign'));
            }
        }
       
        if(!setLeadIds.isEmpty() && !setLeadFields.isEmpty()){
            mapLeadsIds = new Map<Id, Lead>((List<Lead>)Database.query('SELECT '+String.join(new List<String>(setLeadFields), ',' )+' FROM Lead WHERE Id IN :setLeadIds'));
        }
        if(!setCampaignIds.isEmpty() && !setCampaignFields.isEmpty()){
            mapCampaignIds = new Map<Id, Campaign>((List<Campaign>)Database.query('SELECT '+String.join(new List<String>(setCampaignFields), ',' )+', Type, Status FROM Campaign WHERE Id IN :setCampaignIds'));
        }
        for(CampaignMember member : listNewItems){
            if(mapLeadsIds != null && mapCampaignIds != null && member.LeadId!=null && mapLeadsIds.containsKey(member.LeadId) && mapLeadsIds.get(member.LeadId) != null && member.CampaignId!=null && mapCampaignIds.containsKey(member.CampaignId) && mapCampaignIds.get(member.CampaignId) != null){
                Lead leadRec = mapLeadsIds.get(member.LeadId);
                Campaign campaignRec = mapCampaignIds.get(member.CampaignId);
                Boolean isLeadUpdated = false;
                if(campaignRec.Type !=null && campaignRec.Type == 'Splash Event'){                    
                    if(mapOldItems == null){//only for after Insert
                        for(String leadField : mapAllStatusFields.keySet()){
                            if( String.isBlank((String)leadRec.get(leadField)) ){
                                leadRec.put(leadField, campaignRec.get(mapAllStatusFields.get(leadField)));
                                isLeadUpdated = true;
                            }
                        }
                    }                    
                    //after insert and after update mapRSVP_YesstatusFields
                    if(mapcampMemberStatus.containsKey('RSVP_Yes') && member.Status == 'RSVP_Yes' ||(mapOldItems != null && mapOldItems.get(member.Id).Status == 'RSVP_Yes' && member.Status == 'RSVP_Yes')){
                        if(mapRSVP_YesstatusFields != null && mapRSVP_YesstatusFields.size()>0){
                            for(String leadField : mapRSVP_YesstatusFields.keySet()){
                                if( String.isBlank(String.valueOf(leadRec.get(leadField)) )){
                                    leadRec.put(leadField, campaignRec.get(mapRSVP_YesstatusFields.get(leadField)));
                                    isLeadUpdated = true;                                    
                                }
                            }
                        }
                    }
                    if(isLeadUpdated == true){
                        lstLeadsToupdate.add(leadRec);
                    }
                }
            }             
        }   
        debug.log('lstLeadsToupdate: '+lstLeadsToupdate);
        if(lstLeadsToupdate != null && lstLeadsToupdate.size() > 0){
            update lstLeadsToupdate;
        }
    }
    
}