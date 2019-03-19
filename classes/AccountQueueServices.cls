/************************************************************************************************************************************
Author 		: 	Pragalbha Mahajan
Description : 	This class contains the business logic of Account Queue related services.
History		:
----------------------------------------------------------------------------------------------------------------------------------
VERSION		DATE				AUTHOR					DETAIL
1			31 Jan 2019	        Pragalbha Mahajan     	Initial Development	 
**************************************************************************************************************************************/

public without sharing class AccountQueueServices {
    public static Map<Id,Market__c> mapMarkets;
    public static Map<Id, Map<String, List<Account_Queue__c>>> mapQueuesByTeritoryRegionAndMarketId = new Map<Id, Map<String, List<Account_Queue__c>>>();
    public static Map<Id, Account_Queue__c> mapAccountQueueToUpdate = new Map<Id, Account_Queue__c>();
    
    /************************************************************************************************************************************
    Author 				: 	Pragalbha Mahajan
    Description 		: 	This method is used to get all markets.
    Issue No.			:	ST-3300
	Created Date		:	1 Feb 2019
    **************************************************************************************************************************************/ 
    public static void getAllMarket(){
        if(mapMarkets == null || mapMarkets.isEmpty()){
            mapMarkets = new Map<Id, Market__c>([SELECT Id, Name, TerritoryID__c, TerritoryID__r.RegionID__c, Mid_Market_Assignment_Override__c, Enterprise_Assignment_Override__c, (SELECT Id, Name, Member__c, Account_Record_Type__c, Last_Account_Assigned__c, Market__c, Portfolio__r.TerritoryID__c, Portfolio__r.TerritoryID__r.RegionID__c FROM Account_Queues__r WHERE Is_Queue_Active__c = TRUE AND Is_Member_Active__c = TRUE) FROM Market__c]);
        }
    }
    
    /************************************************************************************************************************************
    Author 				: 	Pragalbha Mahajan
    Description 		: 	This method is used to update Account queues.
    Issue No.			:	ST-3300
	Created Date		:	1 Feb 2019
    **************************************************************************************************************************************/ 
    public static void updateAccountQueues(){
        if(!mapAccountQueueToUpdate.isEmpty()){
            Database.update(mapAccountQueueToUpdate.values());
        }
    }
    
    /************************************************************************************************************************************
    Author 				: 	Pragalbha Mahajan
    Description 		: 	This method is used to get queue owner by Market, Territory Or Region.
    Issue No.			:	ST-3300
	Created Date		:	1 Feb 2019
    **************************************************************************************************************************************/ 
    public static Id getQueueOwnerByMarketTerritoryOrRegion(List<String> lstRecordType, String marketId, String recordTypeNameToSearch){
        debug.log('recordTypeNameToSearch: '+recordTypeNameToSearch);
        Debug.log('recordType: '+lstRecordType);
        Debug.log('marketId: '+marketId);
        getAllMarket();
        createPortfolioTerritoryRegionMap();
        debug.log('mapMarkets: '+mapMarkets);
        if(String.isNotBlank(marketId) && mapMarkets.containsKey(marketId)){
            String territoryOrRegion;
            String territoryOrRegionId;
            if(String.isNotBlank(recordTypeNameToSearch)){
                territoryOrRegion = recordTypeNameToSearch.equalsIgnoreCase('Enterprise Solutions') ?  mapMarkets.get(marketId).Enterprise_Assignment_Override__c : recordTypeNameToSearch.equalsIgnoreCase('Mid Market') ? mapMarkets.get(marketId).Mid_Market_Assignment_Override__c : NULL;
            }
            debug.log('territoryOrRegion: '+territoryOrRegion);
            if(String.isNotBlank(territoryOrRegion)){
                territoryOrRegionId = territoryOrRegion.equalsIgnoreCase('Portfolio') ? marketId : territoryOrRegion.equalsIgnoreCase('Territory') ? String.valueOf(mapMarkets.get(marketId).TerritoryID__c) : String.valueOf(mapMarkets.get(marketId).TerritoryID__r.RegionID__c);
            }
			debug.log('territoryOrRegionId: '+territoryOrRegionId);
            Account_Queue__c queue;
            List<Account_Queue__c> lstAccQueues;
            queue = getLatestQueue(getQueueByRecordType(String.isNotBlank(territoryOrRegionId) ? territoryOrRegionId :  marketId, lstRecordType));
            Debug.log('queue====='+queue);
            if(queue != null && String.isNotBlank(queue.Id)){
                mapAccountQueueToUpdate.put(queue.Id, new Account_Queue__c(Id = queue.Id, Last_Account_Assigned__c = System.now()));
                return queue.Member__c; 
            }
        }
        return null;
    }
    
    /************************************************************************************************************************************
        Author 				: 	Pragalbha Mahajan
        Description 		: 	This method is used to update queue by last assigned date.
        Issue No.			:	ST-3300
        Created Date		:	2 Feb 2019
    **************************************************************************************************************************************/ 
    public static void createPortfolioTerritoryRegionMap(){
        if(mapQueuesByTeritoryRegionAndMarketId.isEmpty()){
            getAllMarket();
            List<Account_Queue__c> lstAccountQueues;
            for(Market__c objMarket : mapMarkets.values()){
                for(Account_Queue__c objAccQueue : objMarket.Account_Queues__r){
                    if(String.isNotBlank(objAccQueue.Portfolio__c)){
                        createPortfolioTerritoryRegionMap(objAccQueue.Portfolio__c, objAccQueue);
                        if(String.isNotBlank(objAccQueue.Portfolio__r.TerritoryID__c)){
                            createPortfolioTerritoryRegionMap(objAccQueue.Portfolio__r.TerritoryID__c, objAccQueue);
                            if(String.isNotBlank(objAccQueue.Portfolio__r.TerritoryID__r.RegionID__c)){
                                createPortfolioTerritoryRegionMap(objAccQueue.Portfolio__r.TerritoryID__r.RegionID__c, objAccQueue);
                            }
                        }
                    }
                }
            }
        }
        debug.log('mapQueuesByTeritoryRegionAndMarketId: '+mapQueuesByTeritoryRegionAndMarketId);
    }
    
    /************************************************************************************************************************************
        Author 				: 	Pragalbha Mahajan
        Description 		: 	This method is used to create Map according to portfolio territory and region.
        Issue No.			:	ST-3300
        Created Date		:	2 Feb 2019
    **************************************************************************************************************************************/ 
    public static void createPortfolioTerritoryRegionMap(Id recordId, Account_Queue__c objAccountQueue){
        if(String.isNotBlank(recordId)){
            Map<String, List<Account_Queue__c>> mapRecordTypeIdWithAccountQueue;
            if(mapQueuesByTeritoryRegionAndMarketId == NULL || !mapQueuesByTeritoryRegionAndMarketId.containsKey(recordId)){
                if(mapQueuesByTeritoryRegionAndMarketId == NULL){
                    mapQueuesByTeritoryRegionAndMarketId = new Map<Id, Map<String, List<Account_Queue__c>>>();
                }
                mapRecordTypeIdWithAccountQueue = new Map<String, List<Account_Queue__c>>();
                mapQueuesByTeritoryRegionAndMarketId.put(recordId, mapRecordTypeIdWithAccountQueue);
            }else{
                 mapRecordTypeIdWithAccountQueue = mapQueuesByTeritoryRegionAndMarketId.get(recordId);
            }
            if(!mapRecordTypeIdWithAccountQueue.containsKey(objAccountQueue.Account_Record_Type__c)){
                mapRecordTypeIdWithAccountQueue.put(objAccountQueue.Account_Record_Type__c, new List<Account_Queue__c>());
            }
            mapRecordTypeIdWithAccountQueue.get(objAccountQueue.Account_Record_Type__c).add(objAccountQueue);
        }
    }
        
    /************************************************************************************************************************************
        Author 				: 	Pragalbha Mahajan
        Description 		: 	This method is used to filter queues by record type.
        Issue No.			:	ST-3300
        Created Date		:	3 Feb 2019
    **************************************************************************************************************************************/ 
    public static List<Account_Queue__c> getQueueByRecordType(Id recordId, List<String> recordTypes){       
        List<Account_Queue__c> lstQueues = new List<Account_Queue__c>();
        Map<String, List<Account_Queue__c>> mapRecordTypeWithAccountQueue = mapQueuesByTeritoryRegionAndMarketId.get(recordId);
        if(mapRecordTypeWithAccountQueue != NULL && !mapRecordTypeWithAccountQueue.isEmpty()){
            for(String recordTypeName : recordTypes){
                if(mapRecordTypeWithAccountQueue.get(recordTypeName) != NULL){
                    lstQueues.addAll(mapRecordTypeWithAccountQueue.get(recordTypeName));
                }
            }
        }
        Debug.log('lstQueues==>'+lstQueues);
        return lstQueues; 
    }
    
    /************************************************************************************************************************************
        Author 				: 	Krishana Tupe
        Description 		: 	This method is used to get queue owner by Market.
        Issue No.			:	ST-3300
        Created Date		:	07 April 2018
        Last Modified by	: 	Pragalbha Mahajan
    **************************************************************************************************************************************/ 
    public static Id getQueueOwnerByMarket(List<String> lstRecordType, String marketId){
        return getQueueOwnerByMarketTerritoryOrRegion(lstRecordType, marketId, NULL);
    }
    
    /************************************************************************************************************************************
        Author 				: 	Krishana Tupe
        Description 		: 	This method is used to filter queues by record type.
        Issue No.			:	ST-3300
        Created Date		:	07 April 2018
        Last Modified By	:	Pragalbha Mahajan
    **************************************************************************************************************************************/ 
    public static Account_Queue__c getLatestQueue(List<Account_Queue__c> lstAccountQueues){
        Debug.log('In getLatestQueue queues===>'+lstAccountQueues);
        Account_Queue__c accountQueueRec; 
        DateTime lastAccountAssignedDate;
        if(lstAccountQueues != null && !lstAccountQueues.isEmpty()){
            for(Account_Queue__c objAccountQueue : lstAccountQueues){
                if(objAccountQueue.Last_Account_Assigned__c == null){
                    return objAccountQueue;
                }else{
                    if(lastAccountAssignedDate == NULL){
                        accountQueueRec = objAccountQueue;
                        lastAccountAssignedDate = objAccountQueue.Last_Account_Assigned__c;
                    }else if(lastAccountAssignedDate > objAccountQueue.Last_Account_Assigned__c){
                        accountQueueRec = objAccountQueue;
                        lastAccountAssignedDate = objAccountQueue.Last_Account_Assigned__c;
                    }
                }
            }        
        }
        return accountQueueRec;
    }
}