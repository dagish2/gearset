/************************************************************************************************************************************
   	Author 		: Dipak Pawar
   	Description : Logic of AccountQueueTriggers.

   	History		:
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE				AUTHOR				DETAIL
	1			26 April 2017		Dipak Pawar 		Initial Developement
**************************************************************************************************************************************/

public with sharing class AccountQueueTriggerHandler extends ITriggerHandler{
    public AccountQueueTriggerHandler(){
        super('Account_Queue__c');
    }
    
    /************************************************************************************************************************************
         Author 			: Pragalbha Mahajan
         Description 		: This method overrides before insert method from ITriggerHander which will control the execution flow.
         Last Modified Date	: 02 February 2018
         Last Modified By	: Pragalbha Mahajan (added Comment)
	**************************************************************************************************************************************/
    public override void BeforeInsert(List<SObject> listNewItems){
        if(TriggerSettings.mappedField.AccountQueue_RestrictDuplicateRecordsForAccountAssignment){
            restrictDuplicateRecordsForAccountAssignment((List<Account_Queue__c>)listNewItems,null,null,null);
        }
    }
    
    /************************************************************************************************************************************
    	Author 				: Pragalbha Mahajan
        Description 		: This method overrides before update method from ITriggerHander which will control the execution flow.
        Last Modified Date	: 02 February 2018
        Last Modified By	: Pragalbha Mahajan (added Comment)
	**************************************************************************************************************************************/
    public override void BeforeUpdate(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems){
        if(TriggerSettings.mappedField.AccountQueue_RestrictDuplicateRecordsForAccountAssignment){
            restrictDuplicateRecordsForAccountAssignment((List<Account_Queue__c>) listNewItems, (Map<Id, Account_Queue__c>) mapNewItems, (List<Account_Queue__c>) listOldItems, (Map<Id, Account_Queue__c>) mapOldItems);
        }
    }
    
	/************************************************************************************************************************************
  		Author 				: Dipak Pawar
        Description 		: Restrict duplicate records for account assignment based on Account_Record_Type__c, Market__c and Member__c of AccountQueue.
        Last Modified Date	: 26,April 2017
        Last Modified By	: Dipak Pawar
	**************************************************************************************************************************************/
    public static void restrictDuplicateRecordsForAccountAssignment(List<Account_Queue__c> listNewItems, Map<Id, Account_Queue__c> mapNewItems, List<Account_Queue__c> listOldItems, Map<Id, Account_Queue__c> mapOldItems) {     
        Debug.log('Trigger.New :: '+(List<Account_Queue__c>)listNewItems);
        Set<String> setAccountRecordTypes = new Set<String>();
        Set<String> setPortfolios = new Set<String>();
        Set<String> setMembers = new Set<String>();
        Map<String, Account_Queue__c> mapAccountQueue = new Map<String, Account_Queue__c>();
        Map<Id, Account_Queue__c> triggerOldMap = new Map<Id, Account_Queue__c>();
        if(Trigger.IsUpdate) {
            triggerOldMap = (Map<Id, Account_Queue__c>)mapOldItems;
        }
        for(Account_Queue__c accountQueueRec : (List<Account_Queue__c>)listNewItems) {
            if(Trigger.IsInsert) {
                setAccountRecordTypes.add(accountQueueRec.Account_Record_Type__c);
                setPortfolios.add(accountQueueRec.Portfolio__c);
                setMembers.add(accountQueueRec.Member__c);
            } else if(Trigger.IsUpdate) {
                if((accountQueueRec.Is_Queue_Active__c != null && accountQueueRec.Is_Queue_Active__c != triggerOldMap.get(accountQueueRec.Id).Is_Queue_Active__c) || (accountQueueRec.Account_Record_Type__c != null && accountQueueRec.Account_Record_Type__c != triggerOldMap.get(accountQueueRec.Id).Account_Record_Type__c) || (accountQueueRec.Portfolio__c != null && accountQueueRec.Portfolio__c != triggerOldMap.get(accountQueueRec.Id).Portfolio__c) || (accountQueueRec.Member__c != null && accountQueueRec.Member__c != triggerOldMap.get(accountQueueRec.Id).Member__c) ){
                    setAccountRecordTypes.add(accountQueueRec.Account_Record_Type__c);
                    setPortfolios.add(accountQueueRec.Portfolio__c);
                    setMembers.add(accountQueueRec.Member__c);
                }
            }            
        }
        Debug.log('setAccountRecordTypes :: '+setAccountRecordTypes);
        Debug.log('setPortfolios :: '+setPortfolios);
        Debug.log('setMembers :: '+setMembers);
        
        if(setAccountRecordTypes.size() > 0 && setPortfolios.size() > 0 && setMembers.size() > 0) {
            for(Account_Queue__c accountQueueRec : [SELECT Id, 
                                                    Account_Record_Type__c,
                                                    Is_Member_Active__c,
                                                    Is_Queue_Active__c,
                                                    Market__c,
                                                    Portfolio__c,
                                                    Member__c
                                                    FROM Account_Queue__c
                                                    WHERE
                                                    Account_Record_Type__c IN :setAccountRecordTypes
                                                    AND Portfolio__c IN :setPortfolios
                                                    AND Member__c IN :setMembers
                                                    AND Is_Member_Active__c =: true
                                                    AND Is_Queue_Active__c =: true
                                                   ]) {
                                                       mapAccountQueue.put(accountQueueRec.Account_Record_Type__c+'-'+accountQueueRec.Portfolio__c+'-'+accountQueueRec.Member__c, accountQueueRec);
                                                   }
            Debug.log('mapAccountQueue :: '+mapAccountQueue);
            for(Account_Queue__c accountQueueRec : (List<Account_Queue__c>)Trigger.New) {
                if(accountQueueRec.Is_Queue_Active__c && mapAccountQueue.get(accountQueueRec.Account_Record_Type__c+'-'+accountQueueRec.Portfolio__c+'-'+accountQueueRec.Member__c) != null)
                    accountQueueRec.addError('Duplicate Record found, ID:'+mapAccountQueue.get(accountQueueRec.Account_Record_Type__c+'-'+accountQueueRec.Portfolio__c+'-'+accountQueueRec.Member__c).Id);                
            } 
        }        
    }   
}