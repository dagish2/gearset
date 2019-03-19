/************************************************************************************************************************************
    Author      :   Jitesh Adwani	
    Description :   This class will contain buisness logic of Opportunity trigger.
	Issue No    : 	ST-3136
    History		:	
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1           26 November 2018    Jitesh             Initial Developement
**************************************************************************************************************************************/
public class TrRelateCampaignOnOpportunity implements IProcessHandler{
    
	public void handle(List<sObject> triggerNew, Map<Id, sObject> triggerOldMap) {
        insertCampaignOnOpportunity((List<Opportunity>)triggerNew);        
    }
    
/************************************************************************************************************************************
    Author         : Jitesh Adwani
    Description    : This method is used to insert Campaign Name on Opportunity From Contact.
    Created Date   : 26 Nov 2018 
    Issue No       : ST-3136
**************************************************************************************************************************************/
    public void insertCampaignOnOpportunity(List<Opportunity> triggerNew){
        Set<Id> setPrimaryContactId = new Set<Id>();
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        for(Opportunity objNewOpportunity : triggerNew){
            if(objNewOpportunity.Primary_Member__c != NULL){
                setPrimaryContactId.add(objNewOpportunity.Primary_Member__c);
                lstOpportunity.add(objNewOpportunity);
            }
        } 
        if(!setPrimaryContactId.isEmpty()){
            Map<Id, Id> mapPrimaryMembersCampaign = new Map<Id, Id>();
            for(Contact objContact : [SELECT Id, (SELECT Id, Name, CampaignId FROM CampaignMembers ORDER BY LastModifiedDate DESC) FROM Contact WHERE Id IN :setPrimaryContactId]){
                for(CampaignMember objCampaign : objContact.CampaignMembers){
                    mapPrimaryMembersCampaign.put(objContact.Id, objCampaign.CampaignId);
                    break;
                }    
            }
            
            if(!mapPrimaryMembersCampaign.isEmpty()){
                for(Opportunity objOpportunity : lstOpportunity){
                    objOpportunity.CampaignId =  mapPrimaryMembersCampaign.get(objOpportunity.Primary_Member__c);
                }
            }
        }
    }
}