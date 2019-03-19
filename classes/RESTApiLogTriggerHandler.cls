/************************************************************************************************************************************
    Author      :   Milanjeet Singh
    Description :   This class contains the trigger handler methods for REST_API_Log__c object to cover the trigger dispatcher class

    History :
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                     DETAIL
    1           22 Oct 2018        Milanjeet Singh            Initial Developement
**************************************************************************************************************************************/
public class RESTApiLogTriggerHandler extends ITriggerHandler{
    public RESTApiLogTriggerHandler(){ 
        super('REST_API_Log__c');
    }
     /************************************************************************************************************************************
        Author              :   Shobhit Gahlot
        Description         :   This method overrides before insert method from ITriggerHander which will control the execution flow.
        Last Modified Date  :   22 Oct 2018
    ************************************************************************************************************************************/   
    public override void BeforeInsert(List<SObject> listNewItems){
        if(TriggerSettings.mappedField.RestApiLog_BeforeInsertException){
            createExceptionInLead();    
        }
    }
    /************************************************************************************************************************************
        Author              :   Shobhit Gahlot
        Description         :   This method overrides after insert method from ITriggerHander which will control the execution flow.
        Last Modified Date  :   22 Oct 2018
    ************************************************************************************************************************************/
    public override void AfterInsert(List<SObject> listNewItems, Map<Id, SObject> mapNewItems){
        if(TriggerSettings.mappedField.RestApiLog_AfterInsertException){
          createExceptionInLead();    
        }
    }
    /************************************************************************************************************************************
        Author              :   Shobhit Gahlot
        Description         :   This method overrides before update method from ITriggerHander which will control the execution flow.
        Last Modified Date  :   22 Oct 2018
    ************************************************************************************************************************************/
    public override void BeforeUpdate(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems){
        if(TriggerSettings.mappedField.RestApiLog_BeforeUpdateException){ 
            createExceptionInLead();    
        }
    }
    /************************************************************************************************************************************
        Author              :   Shobhit Gahlot
        Description         :   This method overrides after update method from ITriggerHander which will control the execution flow.
        Last Modified Date  :   22 Oct 2018
    ************************************************************************************************************************************/
    public override void AfterUpdate(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems){
         if(TriggerSettings.mappedField.RestApiLog_AfterUpdateException){ 
             createExceptionInLead();    
        }
    }
    /************************************************************************************************************************************
        Author              :   Shobhit Gahlot
        Description         :   This method overrides before delete method from ITriggerHander which will control the execution flow.
        Last Modified Date  :   22 Oct 2018
    ************************************************************************************************************************************/
    public override void BeforeDelete(List<SObject> listOldItems, Map<Id, SObject> mapOldItems){
        if(TriggerSettings.mappedField.RestApiLog_BeforeDeleteException){ 
             createExceptionInLead();    
        }
    }
    /************************************************************************************************************************************
        Author              :   Shobhit Gahlot
        Description         :   This method overrides after delete method from ITriggerHander which will control the execution flow.
        Last Modified Date  :   22 Oct 2018
    ************************************************************************************************************************************/
    public override void AfterDelete(List<SObject> listOldItems, Map<Id, SObject> mapOldItems){
        if(TriggerSettings.mappedField.RestApiLog_AfterDeleteException){ 
             createExceptionInLead();    
        }
    }
    /************************************************************************************************************************************
        Author              :   Shobhit Gahlot
        Description         :   This method overrides after undelete method from ITriggerHander which will control the execution flow.
        Last Modified Date  :   22 Oct 2018
    ************************************************************************************************************************************/
    public override void AfterUndelete(List<SObject> listOldItems, Map<Id, SObject> mapOldItems){
        if(TriggerSettings.mappedField.RestApiLog_UnDeleteException){        
            createExceptionInLead();     
        }
        
    }
    /************************************************************************************************************************************
        Author              :   Shobhit Gahlot
        Description         :   This is a helper method to create an exception
        Last Modified Date  :   22 Oct 2018
    ************************************************************************************************************************************/
    public static void createExceptionInLead(){
        if(Test.isRunningTest()){
            insert new Lead();
        }
    }
}