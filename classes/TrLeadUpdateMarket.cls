/************************************************************************************************************************************
	Author		: 	Krishana Tupe
	Description	: 	This trigger is used to update market on Lead.
					Runs on Before insert and Before update.
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE	        	AUTHOR                     	DETAIL
	1	    	17 December 2018	Krishana Tupe       	Initial Developement
	2	    	23 January 2019		Krishana Tupe           Made changes for Lead update Market logic
**************************************************************************************************************************************/
public class TrLeadUpdateMarket implements IProcessHandler {
	
    /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   Overide handle method from IProcessHandler.
        Created Date  		:   17 December 2018
		LastModified Date	:	24 January 2019
		Issue No.			:	ST-3255,ST-3343
    **************************************************************************************************************************************/    
    public void handle(list<sObject> triggerNew, map<Id, sObject> triggerOldMap){       
        for(Lead objLead : (List<Lead>) triggerNew){           
            Lead  objOldLead = triggerOldMap != NULL ? (Lead)triggerOldMap.get(objLead.Id) : NULL;
            if(objOldLead != NULL && Settings.isChanged(objLead.Processing_Stage__c, objOldLead.Processing_Stage__c)){
                objLead.Last_Lead_Processing_Update__c = System.now();  
            }else if(objOldLead == NULL && objLead.Last_Lead_Processing_Update__c == NULL){
                objLead.Last_Lead_Processing_Update__c = System.now();     
            }            
            if(!objLead.IsConverted && checkValidForUpdateMarket(objLead, objOldLead)){
                objLead.Update_HQ_Market_Status__c = 'Pending';                
            }
        }
    }
    
    /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is usde to validate if Lead record data is enough to find market.
        Created Date  		:   06 December 2018
		LastModified Date	:	24 January 2019
		Issue No.			:	ST-3255,ST-3343
    **************************************************************************************************************************************/    
    public Boolean checkValidForUpdateMarket(Lead objNewLead, Lead objOldLead){       
        Boolean isAddressCriteriaMatched = ((String.isNotBlank(objNewLead.City) && String.isNotBlank(objNewLead.State)) || (String.isNotBlank(objNewLead.City) && String.isNotBlank(objNewLead.Country)) || String.isNotBlank(objNewLead.Country));
        Boolean isUnomyAddressCriteriaMatched = ((String.isNotBlank(objNewLead.Unomy_Location_City__c) && String.isNotBlank(objNewLead.Unomy_Location_State__c))|| (String.isNotBlank(objNewLead.Unomy_Location_City__c) && String.isNotBlank(objNewLead.Unomy_Location_Country__c)) || String.isNotBlank(objNewLead.Unomy_Location_Country__c));
        Boolean isUnomyDateTimeUpdated = (objOldLead != null && String.isNotBlank(String.valueOf(objNewLead.Unomy_Updated_DateTime__c)) && objNewLead.Unomy_Updated_DateTime__c != objOldLead.Unomy_Updated_DateTime__c);
        Boolean isUnomyAddressChanged = (objOldLead != null && (Settings.isChanged(objNewLead.Unomy_Location_City__c, objOldLead.Unomy_Location_City__c)  || Settings.isChanged(objNewLead.Unomy_Location_State__c, objOldLead.Unomy_Location_State__c) || Settings.isChanged(objNewLead.Unomy_Location_Country__c, objOldLead.Unomy_Location_Country__c)));
        Boolean isAddressChanged = (objOldLead != NULL && (Settings.isChanged(objNewLead.City, objOldLead.City)  ||  Settings.isChanged(objNewLead.State, objOldLead.State) || Settings.isChanged(objNewLead.Country, objOldLead.Country)));
        if(objOldLead == NULL && (isUnomyAddressCriteriaMatched || isAddressCriteriaMatched)){
            return true;
        }else if(objOldLead != NULL && ((isUnomyAddressChanged && isUnomyAddressCriteriaMatched) || (isUnomyDateTimeUpdated && (isAddressCriteriaMatched || isUnomyAddressCriteriaMatched)) || (isAddressCriteriaMatched && isAddressChanged))){
            return true;
        }
        return false;
    }
}