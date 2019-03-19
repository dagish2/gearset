/************************************************************************************************************************************
    Author 		: 	Chandra Teja
    Description : 	This class contains the business logic to populate account manager's email value on opportunity insertion.
    History		:
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE				AUTHOR					DETAIL
	1			19 February 2019	ChandraTeja     	Initial Development	 
**************************************************************************************************************************************/
public class TrOpportunityUpdateAccountManagerEmail implements IProcessHandler {
    
    public void handle(List<sObject> triggerNew, Map<Id, sObject> triggerOldMap){
        filterOpportunities((List<Opportunity>)triggerNew);
    }
    
    static void filterOpportunities(List<Opportunity> lstOpportunities){
        Map<Opportunity, Id> mapFilteredOpportunitiesWithAccount = new Map<Opportunity, Id>();
        for(Opportunity objOpportunity : lstOpportunities){
            if(String.isNotBlank(objOpportunity.AccountId)){
                mapFilteredOpportunitiesWithAccount.put(objOpportunity, objOpportunity.AccountId);
            }
        }
        
        if(!mapFilteredOpportunitiesWithAccount.isEmpty()){
            updateAccountManagerEmailOnOpportunities(mapFilteredOpportunitiesWithAccount);
        }
		
    }
    
    /************************************************************************************************************************************
        Author          : Chandra Teja
        Description     : This method is used to populate account manager's email value on insertion
        Created Date    : 19 February 2019 
        Issue No        : ST-3430
    **************************************************************************************************************************************/
    static void updateAccountManagerEmailOnOpportunities(Map<Opportunity, Id> mapFilteredOpportunitiesWithAccount){
        Map<Id, Account> mapAccounts = new Map<Id, Account>([SELECT Id, Account_Manager_Lookup__c, Account_Manager_Lookup__r.Email FROM Account WHERE Id IN :mapFilteredOpportunitiesWithAccount.values() AND Account_Manager_Lookup__c != null]);
        for(Opportunity objOpportunity : mapFilteredOpportunitiesWithAccount.keySet()){
            String strAccountManagerEmail = mapAccounts.containsKey(objOpportunity.AccountId) ? mapAccounts.get(objOpportunity.AccountId).Account_Manager_Lookup__r.Email : null;
            if(String.isNotBlank(strAccountManagerEmail)){
                objOpportunity.Account_Manager_Email__c = strAccountManagerEmail;
            }            
        }
    }	
}