/************************************************************************************************************************************
    Author      :   Chandra Teja    
    Description :   This class contain all aura methods related to ClientSolutionsCase button of Opportunity record.
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1           6 December 2018   Chandra Teja             Initial Developement
**************************************************************************************************************************************/
public class ValidateClientSolutionsCaseController {   
    /************************************************************************************************************************************
        Author              : Chandra Teja
        Description         : This method validates opportunity record stage and provides output based on product type of Opportunity.
        Created Date        : 6 December 2018
        Issue No            : ST-3208
    **************************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult getOpportunityData(Id opportunityId){
        Opportunity opportunity = [SELECT Id, Name, StageName, Type__c FROM Opportunity WHERE Id = :opportunityId]; 
        String messageToReturn;
        if(opportunity.StageName != 'Qualifying'){
            if(opportunity.Type__c == 'Global Access'){ 
                messageToReturn = '{"Success":false, "Message":"Client Solutions Case cannot be opened for product type of Global access."}'; 
            }else if(opportunity.Type__c == 'PxWe'){ 
                messageToReturn = '{"Success":true, "Message":"'+System.Label.ClientSolutionsCaseURLForPxWe+'"}';  
            }else{ 
                messageToReturn = '{"Success":true, "Message":"'+System.Label.ClientSolutionsCaseURLForOtherThanPxWe+'"}'; 
            }
        }else{
            messageToReturn = '{"Success":false,"Message":"Client Solutions Case cannot be opened on Opportunity with stage as Qualifying."}';
        }
        Debug.log('messageToReturn'+ messageToReturn);
        return new DatabaseResult(messageToReturn);
    }
}