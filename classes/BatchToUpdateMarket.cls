/************************************************************************************************************************************
	Author		: 	Krishana Tupe
	Description	: 	This batch class handle Geography insertion using google api account update related market on Account record.
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE	        		AUTHOR                     	DETAIL
	1	    	12 December 2018		Krishana Tupe             	Initial Developement
	2	    	23 January 2019			Krishana Tupe            	Made changes for Lead/Account update Market logic
**************************************************************************************************************************************/
public class BatchToUpdateMarket implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{  
    public String sObjectName;
    public String strQuery; 
    public Boolean isStopBatch = TRUE; 
    public Boolean isStop = TRUE; 
    public String strQueryLabel = 'ContinuousBatchQuery'; 
    public Integer batchSize = 80;
    public Map<String, List<sObject>> mapSObjectsToUpdate;
    
    /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   Constructor use to initializa the sobject name of which records to find and update the market.
        Created Date  		:   23 January 2019	
		Issue No.			:	ST-3343
  **************************************************************************************************************************************/
    public BatchToUpdateMarket(String sobjectName){
        this.sObjectName =  sobjectName; 
        this.initializeMetadata();
    }
    
    /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   Constructor use to initializa the sobject name of which records to find and update the market.
        Created Date  		:   23 January 2019	
		Issue No.			:	ST-3343
  **************************************************************************************************************************************/
    public BatchToUpdateMarket(String sobjectName, Map<String, List<sObject>> mapSObjectsToUpdate){
        this.sObjectName =  sobjectName;
        if(mapSObjectsToUpdate != NULL && !mapSObjectsToUpdate.isEmpty()){
            BatchToUpdateMarketHelper.mapSObjectsToUpdate = mapSObjectsToUpdate;
        }
        this.initializeMetadata();
    }
    
    public void initializeMetadata(){
        Map<String, object> mapUpdateMarketBatchMDT = BatchToUpdateMarketHelper.getUpdateMarketBatchMetadata('UpdateMarketBatchMetadata');       
        if(mapUpdateMarketBatchMDT != null){
            if(mapUpdateMarketBatchMDT.get('StopBatch') != NULL ){
                isStopBatch = Boolean.valueOf(mapUpdateMarketBatchMDT.get('StopBatch'));
            }
            if(mapUpdateMarketBatchMDT.get(sObjectName) != NULL){
                Map<String, object> mapBatchInfo = (Map<String, object>)mapUpdateMarketBatchMDT.get(sObjectName);           
                if(mapBatchInfo != NULL){
                    if(mapBatchInfo.get(strQueryLabel) != NULL){
                        strQuery = String.valueOf(mapBatchInfo.get(strQueryLabel));
                    }
                    if(mapBatchInfo.get('Chunk Size') != NULL){
                        batchSize = Integer.valueOf(mapBatchInfo.get('Chunk Size'));
                    }
                }                
                isStop = BatchToUpdateMarketHelper.isReRunBatch(sObjectName, mapUpdateMarketBatchMDT);
            }
        }
        if(String.isNotBlank(strQuery)){
            strQuery = strQuery.replace('\"','\''); 
        } 
    }    
    
 /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method quries the records on which we need to find and update market.
        Created Date  		:   23 January 2019	
		Issue No.			:	ST-3343
  **************************************************************************************************************************************/
    public Database.QueryLocator start(Database.BatchableContext BC){ 
        Debug.log('strQuery In Batch ==>'+strQuery);
        if(String.isNotBlank(strQuery)){
            return Database.getQueryLocator(strQuery);
        }
        return NULL;        
    }  
    
  /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   execute method process the records according to batch size and find Geography/Market and update on it.
        Created Date  		:   23 January 2019	
		Issue No.			:	ST-3343
  **************************************************************************************************************************************/
    public void execute(Database.BatchableContext BC, List<sObject> lstRecords){
        Map<Id, sObject> mapUpdateMarketResult = BatchToUpdateMarketHelper.getMarketAssignement(lstRecords);        
        if(sObjectName.equalsIgnoreCase('Lead')){
            BatchToUpdateMarketHelper.updateMarketonLead(lstRecords, mapUpdateMarketResult);
        }else if(sObjectName.equalsIgnoreCase('Account')){
            BatchToUpdateMarketHelper.updateMarketonAccount(lstRecords, mapUpdateMarketResult); 
        }
        mapSObjectsToUpdate = BatchToUpdateMarketHelper.mapSObjectsToUpdate;
    }
    
 /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This finish method is used to chaining the batch(SELF) to find the Market for Lead and Account recursively. 
        Created Date  		:   23 January 2019	
		Issue No.			:	ST-3343
  **************************************************************************************************************************************/    
    public void finish(Database.BatchableContext BC){
        Debug.Log('sObjectName ==>'+sObjectName);
        Debug.Log('mapSObjectsToUpdate ==>'+BatchToUpdateMarketHelper.mapSObjectsToUpdate);
        BatchToUpdateMarketHelper.mapSObjectsToUpdate = mapSObjectsToUpdate;
        if(!Test.isRunningTest()){
            BatchToUpdateMarketHelper.executeBatchInChain(isStopBatch, isStop, sObjectName, batchSize);           
        }        
    } 
    
}