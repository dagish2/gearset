/************************************************************************************************************************************
    Author      :   Jitesh Adwani	
    Description :   This class will contain Logic of Campaign Naming Convention .
	Issue No    : 	ST-3114
    History		:
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1          28 November 2018     Jitesh             Initial Developement
**************************************************************************************************************************************/
public class TrCampaignNamingConvention implements IProcessHandler {
    
    public void handle(List<sObject> triggerNew, Map<Id, sObject> triggerOldMap){
    	updateCampaignName(triggerNew, triggerOldMap);    
    }
    
/************************************************************************************************************************************
    Author         : Jitesh Adwani
    Description    : This method is used UpdateCampaignName.
    Created Date   : 28 Nov 2018 
    Issue No       : ST-3114
**************************************************************************************************************************************/
    static void updateCampaignName(List<sObject> triggerNew, Map<Id, Object> triggerOldMap){
        Datetime priorCampaignDate = Datetime.newInstance(2018, 12, 6, 00, 00, 00);
        for(Campaign objCampaign : (List<Campaign>)triggerNew){
            if(!triggerOldMap.isEmpty()){//on Update
                Campaign objOldCampaign = (Campaign)triggerOldMap.get(objCampaign.Id);
                if(objCampaign.CreatedDate >=  priorCampaignDate){
                    objCampaign.Name = getCampaignName(objCampaign, String.isNotBlank(objCampaign.Program__c), triggerOldMap.isEmpty());
                } else {
                    objCampaign.Name = String.isNotBlank(objCampaign.Name__c) ? String.valueOf(objCampaign.Name__c).abbreviate(80) : objCampaign.Name;   
                }
            } else {// on Insert
                objCampaign.Name = getCampaignName(objCampaign, String.isNotBlank(objCampaign.Program__c), triggerOldMap.isEmpty());
            }
        }
    }
    
/************************************************************************************************************************************
    Author         : Jitesh Adwani
    Description    : This method is used to convert fields into string.
    Created Date   : 28 Nov 2018 
    Issue No       : ST-3114
**************************************************************************************************************************************/
    public static String getCampaignName(Campaign objCampaign, Boolean isProgram, Boolean isInsert){
        String strCampaignName = '', separator = '-';        
        Integer year = isInsert ? System.today().year() : objCampaign.CreatedDate.year();
        strCampaignName += year;
        if(isProgram){
            strCampaignName += separator + objCampaign.Program__c;
        }
        if(String.isNotBlank(objCampaign.Region__c)){
            strCampaignName += separator + getCampaignRegion(objCampaign.Region__c);
        }
        if(String.isNotBlank(objCampaign.Type)){
            strCampaignName += separator + objCampaign.Type;
        }        
        if(String.isNotBlank(objCampaign.ParentId) && String.isNotBlank(objCampaign.Name__c)){
            strCampaignName += separator + objCampaign.Name__c;
        } 
        if(strCampaignName.length() > 80){
            strCampaignName = strCampaignName.substring(0, 77) + '...';
        }
        return strCampaignName;
    }
    
/************************************************************************************************************************************
    Author         : Jitesh Adwani
    Description    : This method converts Region into string and Region__c is required field, so no need to check if strRegions is blank or null.
    Created Date   : 28 Nov 2018 
    Issue No       : ST-3114
**************************************************************************************************************************************/
    static String getCampaignRegion(String strRegions){
        String strRegion = '';
        List<String> lstRegions = new List<String>(strRegions.split(';'));
        if(lstRegions.size() == 1){
            strRegion = lstRegions[0];
        } else {
        	strRegion = 'Multi';    
        }
        return strRegion;
    }
}