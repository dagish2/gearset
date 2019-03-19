/************************************************************************************************************************************
    Author      :  Nikhil Mehta    
    Description :  This class contain all test methods related to aura methods in RetroactiveServicesController.
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR          		DETAIL
     1          18 Oct 2018       	Nikhil Mehta    	    Initial Developement
**************************************************************************************************************************************/
public class RetroactiveServicesController {
    public class RetroactiveServicesControllerException extends Exception{}
    public static Boolean isInvoker = false;
    static {
        isInvoker = ApexDebugLog.registerRootInvoker(ApexDebugLog.InvokerType.AURA, 'RetroactiveServicesControllerException' + 'getsObjectPrefix', ApexDebugLog.InvokerType.AURA);        
    }
   /************************************************************************************************************************************
        Author              :   Nikhil Mehta
        Description         :   This method tests searchRecord method.
        Last Modified Date  :   1 Nov 2018
		Issue No			:   ST-2858
    **************************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult searchRecord(Id recordId, String email, Boolean isReferrer){
        try{
            if(String.isNotBlank(recordId)){
                if(String.valueOf(recordId).startsWithIgnoreCase('003')){
                    return new DatabaseResult([SELECT Id, Name, Email, phone, Type__c, UUID__c FROM Contact WHERE Id =: recordId]);
                }else{
                    return new DatabaseResult([SELECT Id, Name, UUID__c, Primary_Member__c, Primary_Member__r.Email, ID_Status__c, Parent_Account__c, Parent_Account__r.Name, Ultimate_Parent_Org__c FROM Billing_Account__c WHERE Id =: recordId]);
                }
            }else if(String.isNotBlank(email) && isReferrer){
                return new DatabaseResult([SELECT Id, FirstName, LastName, Phone, Email, Company__c, Type__c, UUID__c FROM Contact WHERE Email =: email]);
            }else if(String.isNotBlank(email)){
                return new DatabaseResult([SELECT Id, FirstName, LastName, Phone, Email, Billing_Account__c, AccountId, (SELECT Id, Name, Parent_Account__c, Ultimate_Parent_Org__c FROM Billing_Accounts__r) FROM Contact WHERE Email =: email]);
            }
            throw new RetroactiveServicesControllerException('Email is blank');
        }catch(Exception ex){
            ApexDebugLog.logException(ex,null, 'RetroactiveServicesController', 'searchContact');            
            return (new DatabaseResult(ex));
        }
    }
}