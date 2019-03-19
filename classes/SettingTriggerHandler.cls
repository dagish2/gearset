/********************************************************************************************************************************
    Author 		: Hemanshu Shah
    Description : This trigger should be used to redirect all the triggers of Settings to correct class. 
                  So that there is only one trigger for Settings object system wide

    History:  
-----------------------------------------------------------------------------------------------------------------------------------
	VERSION				DATE				AUTHOR				DETAIL
	1					24 April 2016		Hemanshu Shah		Initial Developement
***********************************************************************************************************************************/
public class SettingTriggerHandler extends ITriggerHandler{
    
    /************************************************************************************************************************************
      Author 			: Krishana Tupe
      Description 		: This is ITriggerHandler constructor which will be used in future.
      Created Date		: 05 February 2018          
    **************************************************************************************************************************************/ 
    public SettingTriggerHandler(){
        super('Setting__c');
    }
    
	/****************************************************************************************************************************
       Author 				: Hemanshu Shah 
       Description 			: This method overrides before insert method from ITriggerHander which will control the execution flow.
       Created Date			: 05 July 2016
	   Last Modified By 	: Prashant Mane
	   Last Modified Date   : 02 February 2018
	*****************************************************************************************************************************/
    public override void BeforeInsert(List<SObject> listNewItems){        
        //if(TriggerSettings.mappedField.Setting_createSettingHistory)
           // createSettingHistory(listNewItems,null,null,null);
        //if(TriggerSettings.mappedField.Setting_validateJsonData){
            validateJsonData(listNewItems);
        //}
    }
	/****************************************************************************************************************************
       Author 				: Hemanshu Shah 
       Description 			: This method overrides before update method from ITriggerHander which will control the execution flow.
       Created Date			: 05 July 2016
	   Last Modified By 	: Prashant Mane
	   Last Modified Date   : 02 February 2018
	*****************************************************************************************************************************/
    public override void BeforeUpdate(List<sObject> lstNewItems, Map<Id,sObject> mapNewItems, List<sObject> lstOldItems, Map<Id,sObject> mapOldItems){
        //if(TriggerSettings.mappedField.Setting_createSettingHistory)
           // createSettingHistory(lstNewItems,mapNewItems,lstOldItems,mapOldItems);
       // if(TriggerSettings.mappedField.Setting_validateJsonData){
            validateJsonData(lstNewItems);
       // }
    }
	/**********************************************************************************************************************************
       Author 				: Ajaysinh Chauhan
       Description 			: This method is used to create setting history
       Created Date			: 24 April 2016
	   Last Modified By 	: Prashant Mane
	   Last Modified Date   : 02 February 2018
	------------------------------------------------------------------------------------------------------------------------------------
	   Last Modified By		: Milanjeet Singh
	   Last Modified Date   : 10 July, 2018
	   Comments				: Removed Exception Handling as it is moved in ItriggerHandler
	*************************************************************************************************************************************/
    /*public static void createSettingHistory(List<sObject> lstNewItems, Map<Id,sObject> mapNewItems, List<sObject> lstOldItems, Map<Id,sObject> mapOldItems){
        List<Setting_History__c> lstHistories = new List<Setting_History__c>();
        for(Setting__c setting:(List<Setting__c>)lstNewItems){
            if(Trigger.isInsert){
                lstHistories.add( new Setting_History__c(OwnerId = UserInfo.getUserId(),User__c = UserInfo.getUserId(), Setting__c = setting.Id, New_Data__c = setting.Data__c));
            }else if(setting.Data__c != mapOldItems.get(setting.Id).get('Data__c')){
                lstHistories.add(new Setting_History__c(User__c = UserInfo.getUserId(), Setting__c = setting.Id, New_Data__c = setting.Data__c, Old_Data__c = String.valueOf(mapOldItems.get(setting.Id).get('Data__c'))));
            }
        }
        if(lstHistories!= null && lstHistories.size() > 0)
            insert lstHistories;     
    }*/
	/**********************************************************************************************************************************
       Author 				: Milanjeet Singh
       Description 			: This method is used to validate the JSON in Data__c field before Insertion and updation to avoid invalid
							  JSON to be store in Setting Data.
       Created Date			: 10 July, 2018
	   Issue No				: -
	*************************************************************************************************************************************/
    public static void validateJsonData(List<Setting__c> lstNewItems){
        for(Setting__c setting : lstNewItems){
            try{
                if(setting.Data__c != null){
                    JSON.deserializeUntyped(setting.Data__c);
                }
            }catch(Exception ex){
                setting.addError('JSON Data is not valid, rectify the JSON and try again.');
            }
        }
    }
    /************************************************************************************************************************************
        Author 		: Krishana Tupe
        Description : This Exception class is used to handle the exception for this class.
        
        History:
        ----------------------------------------------------------------------------------------------------------------------------------
        VERSION			DATE				AUTHOR					DETAIL							ISSUE		
        1				05 February 2018	Krishana Tupe			Initial Development				-	
    **************************************************************************************************************************************/
    public class SettingTriggerHandlerException extends Exception{}
}