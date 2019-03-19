/************************************************************************************************************************************
    Author 				: 	Shivprasad Patil
    Description 		: 	This class is used create campaign member if campaignId is present in inboundPayload 
    Created Date		:	07 June 2018
    Issue				:	ST-2242
    Description			: 	This class is created to adjust the campaign member creation and journey creation flows.
	Comment		:	Code is commeneted as this class is depricated
	Code commented by : Sunil b.		
    
**************************************************************************************************************************************/
public class CampaignServices {
    /************************************************************************************************************************************
    Author 				: 	Shivprasad Patil
    Description 		: 	This class is used create campaign member if not present in system
    Created Date		:	07 June 2018
    Issue				:	-
**************************************************************************************************************************************/

    /*public void insertCampaignMember(WWTypes.InboundLead pInboundLead, List<Id> lstIds){
        if(pInboundLead.campaign_sfid != null && pInboundLead.campaign_sfid != '' && !pInboundLead.campaign_sfid.equalsIgnoreCase('null') && !(lstIds.isEmpty()) && pInboundLead.email != null && pInboundLead.email != ''){
            List<campaign> lstCampaign = [SELECT Id,(SELECT Id,Email FROM CampaignMembers WHERE Email = :pInboundLead.email) FROM Campaign  Where Id = : Id.valueof(pInboundLead.campaign_sfid)];
            if(lstCampaign.size() > 0 && (lstCampaign[0].CampaignMembers).size() == 0 ){
                insert new CampaignMember(CampaignId=lstCampaign[0].Id ,LeadId=lstIds[0], Status='Sent');
            }
        }
    }    */
}