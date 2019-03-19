/************************************************************************************************************************************
    Author      :   Prashant Mane
    Description :   This controller class for Account Type Conversion functionality.
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1           28 Aug 2018         Prashant Mane           Initial Developement
**************************************************************************************************************************************/
public without sharing class AccountTypeConversionController {
    public static Boolean isInvoker = false;
    static {
        isInvoker = ApexDebugLog.registerRootInvoker(ApexDebugLog.InvokerType.AURA, 'AccountTypeConversionController' + 'getsObjectPrefix', ApexDebugLog.InvokerType.AURA);    	
    }
    
	/************************************************************************************************************************************
        Author        	:   Prashant Mane
		Description   	:   This method is used to get AccountTypeConversion data
        Created Date  	:   28 Aug 2018
        Issue No    	:   ST-2715
    **************************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult changeAccountType(Account objAccount) {
        Savepoint sp = Database.setSavepoint(); 
        try {
            List<Account> lstAccountsToUpdate = new List<Account>();
            lstAccountsToUpdate.add(objAccount);
            for(Account objChildAccount : [SELECT Id, Name, ParentId, Parent_Org__c FROM Account WHERE Account_Type__c = 'Org' AND ParentId =: objAccount.Id]) {
                if(objAccount.Account_Type__c == 'Sales') {
                    objChildAccount.ParentId = objAccount.ParentId;
                    lstAccountsToUpdate.add(objChildAccount);
                }
            }
            Database.update(lstAccountsToUpdate);
            return new DatabaseResult(JSON.serialize(objAccount));
        }catch(Exception pEx){
            if(sp != null){
                Database.rollback(sp);
            }
            ApexDebugLog.logException(pEx, JSON.serialize(objAccount), 'AccountTypeConversionController', 'changeAccountType');                      
            return new DatabaseResult(pEx);  
        } 
    }    
}