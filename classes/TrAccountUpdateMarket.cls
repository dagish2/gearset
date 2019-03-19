/************************************************************************************************************************************
	Author		: 	Nikhil Mehta
	Description	: 	This trigger is used to update market on account.
					Runs on before insert and before update.
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE	        	AUTHOR                     	DETAIL
	1	    	6 December 2018		Nikhil Mehta            	Initial Developement
	2	    	23 January 2019		Krishana Tupe            	Made changes for Account update Market logic
**************************************************************************************************************************************/
public class TrAccountUpdateMarket implements IProcessHandler {
	
    /************************************************************************************************************************************
        Author              :   Nikhil Mehta
        Description         :   Overide handle method from IProcessHandler.
        Created Date  		:   06 December 2018
		Issue No.			:	ST-3198 
    **************************************************************************************************************************************/    
    public void handle(list<sObject> triggerNew, map<Id, sObject> triggerOldMap){
        for(Account accountRec : (List<Account>) triggerNew){
            Account accountOldRec = triggerOldMap != NULL ? (Account)triggerOldMap.get(accountRec.Id) : NULL;
            if(checkValidForUpdateMarket(accountRec, accountOldRec)){
                accountRec.Update_HQ_Market_Status__c = 'Pending';
            }
        }
    }
         
    /************************************************************************************************************************************
        Author              :   Nikhil Mehta
        Description         :   This method returns Boolean check valide account.
        Created Date  		:   06 December 2018
		Issue No.			:	ST-3198
    **************************************************************************************************************************************/    
    public Boolean checkValidForUpdateMarket(Account accountRec, Account accountOldRec){
        Boolean isAddressCriteriaMatched = ((String.isNotBlank(accountRec.BillingCity) && String.isNotBlank(accountRec.BillingState)) || (String.isNotBlank(accountRec.BillingCity) && String.isNotBlank(accountRec.BillingCountry)) || String.isNotBlank(accountRec.BillingCountry));
        Boolean isUnomyAddressCriteriaMatched = ((String.isNotBlank(accountRec.Unomy_Location_City__c) && String.isNotBlank(accountRec.Unomy_Location_State__c))|| (String.isNotBlank(accountRec.Unomy_Location_City__c) && String.isNotBlank(accountRec.Unomy_Location_Country__c)) || String.isNotBlank(accountRec.Unomy_Location_Country__c));
        Boolean isUnomyDateTimeUpdated = (accountOldRec != null && String.isNotBlank(String.valueOf(accountRec.Unomy_Updated_DateTime__c)) && accountRec.Unomy_Updated_DateTime__c != accountOldRec.Unomy_Updated_DateTime__c);
        Boolean isUnomyAddressChanged = (accountOldRec != null && (Settings.isChanged(accountRec.Unomy_Location_City__c,accountOldRec.Unomy_Location_City__c)  ||  Settings.isChanged(accountRec.Unomy_Location_State__c,accountOldRec.Unomy_Location_State__c) || Settings.isChanged(accountRec.Unomy_Location_Country__c,accountOldRec.Unomy_Location_Country__c)));
        Boolean isAddressChanged = (accountOldRec != null  && (Settings.isChanged(accountRec.BillingCity, accountOldRec.BillingCity)  ||  Settings.isChanged(accountRec.BillingState, accountOldRec.BillingState) || Settings.isChanged(accountRec.BillingCountry, accountOldRec.BillingCountry)));
        if(accountOldRec == NULL && (isUnomyAddressCriteriaMatched || isAddressCriteriaMatched)){
            return true;
        }else if(accountOldRec != NULL && ((isUnomyAddressChanged && isUnomyAddressCriteriaMatched) || (isUnomyDateTimeUpdated && (isUnomyAddressCriteriaMatched || isAddressCriteriaMatched)) || (isAddressChanged && isAddressCriteriaMatched))){
            return true;
        }
        return false;
    }
    
}