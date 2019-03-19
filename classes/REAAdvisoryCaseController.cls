/************************************************************************************************************************************
Author		 	:	Rohit Nimase
Description 	:	This class has business logic for REAAdvisoryCase validations
---------------------------------------------------------------------------------------------------------------------------------------------
VERSION	  	DATE	          			AUTHOR                      DETAIL
1	     	21 November 2018			Rohit Nimase            	Initial Developement
**************************************************************************************************************************************/
global without sharing class REAAdvisoryCaseController {
    
    public class REAAdvisoryCaseControllerException extends Exception{}
    public static Savepoint sp {get; set;}
    public static Boolean isInvoker = false;
    static {
        isInvoker = ApexDebugLog.registerRootInvoker(ApexDebugLog.InvokerType.AURA, 'REAAdvisoryCaseController' + 'getsObjectPrefix', ApexDebugLog.InvokerType.AURA);        
        sp = Database.setSavepoint();
    }
    /************************************************************************************************************************************
Author		 	:	Rohit Nimase
Description 	:	This Method perform validation for REAAdvisoryCase button on Opportunity
---------------------------------------------------------------------------------------------------------------------------------------------
VERSION	  	DATE	          			AUTHOR                      DETAIL
1	     	21 November 2018			Rohit Nimase            	Initial Developement
**************************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult checkValidOppForREAAdvisory(Id opportunityId){
        Opportunity opportunity = [SELECT Id, AccountId, OwnerId, Name, StageName, REA_Case_Status__c, RecordTypeId, RecordType.Name FROM Opportunity WHERE Id =: opportunityId];
        String message;
        Map<String, Object> mapData = new Map<String, Object>();
        if(opportunity != null){   
            if(String.isNotBlank(opportunity.StageName) && opportunity.StageName.equalsIgnoreCase('Closed Won')){
                message = 'REA case cannot be opened on Closed Opportunity.'; 
                mapData.put('isValid', false);
                mapData.put('message', message);                    
                
            }else if(String.isNotBlank(opportunity.REA_Case_Status__c) && opportunity.REA_Case_Status__c.equalsIgnoreCase('Open')){
                message = 'Only one REA case can be opened per Opportunity.';
                mapData.put('isValid', false);
                mapData.put('message', message); 
            }else{
                mapData.put('isValid', true);
                mapData.put('opportunity', opportunity);
            } 
        }
        return new DatabaseResult(mapData);  
    }
}