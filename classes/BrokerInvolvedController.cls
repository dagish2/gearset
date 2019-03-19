/*****************************************************************************************************************************
    Author 		:  Pragalbha Mahajan
    Description :  This class is used to BrokerInvolvedController
    Date		:  19 December 2018
    Issue		:  ST-3250
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION					DATE					AUTHOR							DETAIL
    1.0					15,July 2018		    Sunil Bhosale	                Initial Developement
******************************************************************************************************************************/
global without sharing class BrokerInvolvedController {
    
    /************************************************************************************************************************************
        Author              :   Pragalbha Mahajan
        Description         :   This method is used to update broker on opportunity.
        Created Date  		:   19 December 2018
		Issue No.			:	ST-3250
    **************************************************************************************************************************************/    
    @AuraEnabled
    webservice static Boolean updateBrokerInvolved(Id opportunityId){
        List<Opportunity> lstOpportunity = [SELECT Id, Broker_Involved__c, Broker_Involved_DateTime__c, Broker_Involvement_Indicated__c FROM Opportunity WHERE Id = :  opportunityId AND (Broker_Involvement_Indicated__c <> 'Yes' OR Broker_Involved_DateTime__c = NULL OR Broker_Involved_Rep__c = NULL)];
        if(!lstOpportunity.isEmpty()){
            Boolean isUpdate = false;
            Opportunity objOpportunity = lstOpportunity[0];
            if(String.isBlank(objOpportunity.Broker_Involvement_Indicated__c) || !objOpportunity.Broker_Involvement_Indicated__c.equalsIgnoreCase('Yes')){
                objOpportunity.Broker_Involvement_Indicated__c = 'Yes';
                isUpdate = true;
            }            
            if(String.isBlank(String.valueOf(objOpportunity.Broker_Involved_DateTime__c))){
                objOpportunity.Broker_Involved_DateTime__c = Date.today();
                isUpdate = true;
            }            
            if(String.isBlank(objOpportunity.Broker_Involved_Rep__c)){
                objOpportunity.Broker_Involved_Rep__c = UserInfo.getFirstName()+' '+UserInfo.getLastName();  
                isUpdate = true;
            }
            if(isUpdate){
                update objOpportunity;   
                return true;
            } 
        } 
        return false;
    } 
}