/************************************************************************************************************************************
    Author      :   Dipak Pawar    
    Description :   This class contain methods that are used in TourCloseHourContoller
    
    History     :
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1          25-10-2018         	Dipak Pawar        		Initial Developement
**************************************************************************************************************************************/
global with sharing class TourCloseHourController {      
    public static Boolean isInvoker = false;
    public static Savepoint sp {get; set;}
    public String mode {get; set;}
    
    static {
        isInvoker = ApexDebugLog.registerRootInvoker(ApexDebugLog.InvokerType.AURA, 'TourCloseHourController' + 'getsObjectPrefix', ApexDebugLog.InvokerType.AURA);        
    }
    
   /****************************************************************************************************************************
        Author              : Dipak Pawar
        Description         : This Method returns the pagedata
        Created Date        : 25/10/2018
       	Issue               : ST-2939
		LastModified Date   : 22/02/2019
		LastModified By		: Krishana Tupe
   *****************************************************************************************************************************/
    public TourCloseHourController(ApexPages.StandardController controller) {
        Map<String, String> mapParamerters = ApexPages.currentPage().getParameters();
        if(mapParamerters.containsKey('retURL')){
            String retURL = mapParamerters.get('retURL'); 
            mode = retURL.length() ==  3 ? 'NEW' : 'EDIT';
            //added for lightning view/edit 
            if(String.isNotBlank(retURL)){
                if(retURL.contains('actionName=view')){
                    mode = 'VIEW';
                } else if(retURL.contains('actionName=new')){
                    mode = 'EDIT'; 
                }  
            }            
        }else{
            mode = 'VIEW';
        }       
    }
    
    /****************************************************************************************************************************
        Author              : Dipak Pawar
        Description         : This Method returns the pagedata
        Created Date        : 25/10/2018
       	Issue               : ST-2939
   *****************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult getPageData(String strSettingName, String tourScheduleId, String tourCloseHourId){
        try{
            Map<String, Object> mapPageData = new Map<String, Object>();
            
            String tourclosedHourPrefix = Tour_closed_hour__c.SObjectType.getDescribe().getKeyPrefix();
            mapPageData.put('objectPrefix', tourclosedHourPrefix);
            
            Setting__c objSettings = [SELECT Data__c FROM Setting__c WHERE Name =: strSettingName];
            SettingData objSettingData = (SettingData)JSON.deserialize(objSettings.Data__c, SettingData.class);
            mapPageData.put('instructions', objSettingData.Instructions);
            
            Id recordId = String.isNotBlank(tourCloseHourId) ? Id.valueOf(tourCloseHourId) : Id.valueOf(tourScheduleId);
            List<UserRecordAccess> lstUserRecordAccess = new List<UserRecordAccess>([SELECT RecordId, HasReadAccess, HasEditAccess, HasDeleteAccess FROM UserRecordAccess WHERE UserId =: UserInfo.getUserId() AND RecordId =: recordId ]);
            if(lstUserRecordAccess.size() > 0){
                UserRecordAccess objUserRecordAccess = lstUserRecordAccess[0];
                mapPageData.put('userHasReadAccess', objUserRecordAccess.HasReadAccess);
                mapPageData.put('userHasEditAccess', objUserRecordAccess.HasEditAccess);
                mapPageData.put('userHasDeleteAccess', objUserRecordAccess.HasDeleteAccess);
            }
            
            List<Tour_Schedule__c> lstTourSchedules = new List<Tour_Schedule__c>([SELECT Id, Name, CurrencyIsoCode, Building__c, Maximum_Tour_Days__c, Product_Line__c, Tour_Spacing__c, Start_Time__c, End_Time__c FROM Tour_Schedule__c WHERE Id =: tourScheduleId]);
            mapPageData.put('objTourSchedule', lstTourSchedules.isEmpty() ? null : lstTourSchedules[0]);            
            
            return new DatabaseResult(mapPageData);
        } catch(Exception pEx){
            ApexDebugLog.logException(pEx, strSettingName + ' ' + tourScheduleId, 'TourCloseHourController', 'getPageData');            
            return (new DatabaseResult(pEx));
        }
    }
    
    /****************************************************************************************************************************
        Author              : Dipak Pawar
        Description         : Wrapper class for Setting Data
        Created Date        : 26-10-2018
       	Issue               : ST-2939
   *****************************************************************************************************************************/
    public class SettingData {
        public List<String> Instructions {get;set;}        
    }
    
    public class TourCloseHourControllerException extends Exception{}
}