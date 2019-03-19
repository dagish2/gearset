/************************************************************************************************************************************
	Author		: 	Nikhil Mehta
	Description	: 	This batch class is to update record.
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE	        		AUTHOR                     	DETAIL
	1	    	22 February 2019		Nikhil Mehta             	Initial Developement
**************************************************************************************************************************************/
public class BatchToUpdateOrInsertSObjects implements Database.Batchable<sObject>, Database.Stateful{
    public List<sObject> lstRecordsToUpdate;
    
  /************************************************************************************************************************************
        Author              :   Nikhil Mehta
        Description         :   Constructor for initialization.
        Created Date  		:   22 February 2019
		Issue No.			:	-
  **************************************************************************************************************************************/    
    public BatchToUpdateOrInsertSObjects(List<sObject> lstRecordsToUpdate){
        this.lstRecordsToUpdate = lstRecordsToUpdate;
    }
    
  /************************************************************************************************************************************
        Author              :   Nikhil Mehta
        Description         :   Start method of batch.
        Created Date  		:   22 February 2019
		Issue No.			:	-
  **************************************************************************************************************************************/    
    public List<sObject> start(Database.BatchableContext BC){ 
            return lstRecordsToUpdate;
    }
    
  /************************************************************************************************************************************
        Author              :   Nikhil Mehta
        Description         :   this method is used for update.
        Created Date  		:   22 February 2019
		Issue No.			:	-
  **************************************************************************************************************************************/    
    public void execute(Database.BatchableContext BC, List<sObject> lstRecordsToUpdate){
        if(lstRecordsToUpdate != NULL && !lstRecordsToUpdate.isEmpty()){
            if(string.isNotBlank(lstRecordsToUpdate[0].Id)){
                Database.update(lstRecordsToUpdate, false);
            }/*else{This is for future use
                Database.insert(lstRecordsToUpdate, false);
            }*/
        }
    }
    
  /************************************************************************************************************************************
        Author              :   Nikhil Mehta
        Description         :   finish mehod
        Created Date  		:   22 February 2019
		Issue No.			:	-
  **************************************************************************************************************************************/    
    public void finish(Database.BatchableContext BC){}
}