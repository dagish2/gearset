/************************************************************************************************************************************
    Author      :   Shivprasad Patil	
    Description :   
	Issue No    : 	ST-3397
    History		:
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1          6 Feburary 2019     Shivprasad             Initial Developement
**************************************************************************************************************************************/
public class BuildingSelectorController {
	/************************************************************************************************************************************
    Author         : Shivprasad Patil
    Description    : This method is used to get initial setup for building selector component
    Created Date   : 4 Feb 2019 
    Issue No       : ST-3397
	**************************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult getSetup(){
        try{
            Setting__c objSetting  = Settings.get('RestartLocation');
            Map<Id, sObject> mapSelectedMarkets;
            Map<String, String> mapOfPortfolioToUser = new Map<String, String>();
            if(objSetting!=null){
                mapOfPortfolioToUser = (Map<String, String>)JSON.deserialize(objSetting.Data__c, Map<String, String>.class);
                if(!mapOfPortfolioToUser.isEmpty()){
                    mapSelectedMarkets = new Map<Id, sObject>([SELECT Id, Name, Region__c, Territory__c, Email__c, Portfolio_Sales_Manager__r.Name, Phone__c FROM Market__c WHERE Id IN :mapOfPortfolioToUser.keySet()]);
                    debug.log('mapSelectedMarkets=='+mapSelectedMarkets);
                } 
            } 
            return new DatabaseResult(new Map<String, Object>{'objSetting'=> objSetting, 'mapSelectedMarkets'=> mapSelectedMarkets, 'mapOfMarket'=> new Map<Id, sObject>([SELECT Id, Name, Region__c, Territory__c, Email__c, Portfolio_Sales_Manager__r.Name, Phone__c FROM Market__c WHERE No_Longer_in_Use__c = false ORDER BY Name])});
        }catch(Exception pEx){                       
            ApexDebugLog.logException(pEx,'', 'BuildingSelectorController', 'getSetup');            
            return new DatabaseResult(pEx);
        }        
    }
    
    /************************************************************************************************************************************
    Author         : Shivprasad Patil
    Description    : This method is used to get related building information by using building ids
    Created Date   : 6 Feb 2019 
    Issue No       : ST-3397
	**************************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult getRelatedBuildings(List<String> lstOfBuildingIds){
        try{
            return new DatabaseResult([SELECT Id, Name, Email__c, Country__c FROM Building__c WHERE Id IN :new Set<String>(lstOfBuildingIds)]);
        }catch(Exception pEx){                       
            ApexDebugLog.logException(pEx,'', 'BuildingSelectorController', 'getRelatedBuildings');            
            return new DatabaseResult(pEx);
        }  
    }
	
    /************************************************************************************************************************************
    Author         : Shivprasad Patil
    Description    : This method gets user or group information using user or group id
    Created Date   : 6 Feb 2019 
    Issue No       : ST-3397
	**************************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult getUserData(String strUserOrGroupId){
        try{
            String query = 'SELECT Id, Name, Email FROM '+(strUserOrGroupId.startsWith('00G') ? 'Group' : 'User')+' WHERE Id=:strUserOrGroupId';
            return new DatabaseResult(Database.query(query)); 
        }catch(Exception pEx){                       
            ApexDebugLog.logException(pEx,'', 'BuildingSelectorController', 'getRelatedBuildings');            
            return new DatabaseResult(pEx);
        }  
    }
}