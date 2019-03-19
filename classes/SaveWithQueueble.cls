/************************************************************************************************************************************
   	Author 		: Ajaysinh Chauhan
   	Description : This class contains Logic of Save With Queueble

   	History		:
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE				AUTHOR				DETAIL
	1			13 June 2017		Ajaysinh Chauhan	Initial Developement
**************************************************************************************************************************************/

public class SaveWithQueueble implements Queueable{
	List<sObject> lstRecordsToInsert;
    List<sObject> lstRecordsToUpdate;
    
    /************************************************************************************************************************************
        Author 				: Ajaysinh Chauhan
        Description 		: static method for save with record
        Last Modified Date	: 13 June 2017
        Last Modified By	: Ajaysinh Chauhan
	**************************************************************************************************************************************/
    public static void save(sObject record){
        System.enqueueJob(new SaveWithQueueble(record));
    }
    
    /************************************************************************************************************************************
        Author 				: Ajaysinh Chauhan
        Description 		: static method for save with list of records
        Last Modified Date	: 13 June 2017
        Last Modified By	: Ajaysinh Chauhan
	**************************************************************************************************************************************/
    public static void save(List<sObject> lstRecordsToSave){
        System.enqueueJob(new SaveWithQueueble(lstRecordsToSave));
    }
    
    /************************************************************************************************************************************
        Author 				: Ajaysinh Chauhan
        Description 		: Constructor for SaveWithQueueble with record
        Last Modified Date	: 13 June 2017
        Last Modified By	: Ajaysinh Chauhan
	**************************************************************************************************************************************/
    public SaveWithQueueble(sObject record){
        lstRecordsToInsert = new List<sObject>();
        lstRecordsToUpdate = new List<sObject>();
        if(record.Id==null){
            lstRecordsToInsert.add(record);
        }else{
            lstRecordsToUpdate.add(record);
        }
    }
    
    /************************************************************************************************************************************
        Author 				: Ajaysinh Chauhan
        Description 		: Constructor for SaveWithQueueble with list of records
        Last Modified Date	: 13 June 2017
        Last Modified By	: Ajaysinh Chauhan
	**************************************************************************************************************************************/
    public SaveWithQueueble(List<sObject> lstRecordsToSave){
        lstRecordsToInsert = new List<sObject>();
        lstRecordsToUpdate = new List<sObject>();
        for(sObject record:lstRecordsToSave){
            if(record.Id==null){
                lstRecordsToInsert.add(record);
            }else{
                lstRecordsToUpdate.add(record);
            }
        }
    }
    
    /************************************************************************************************************************************
        Author 				: Ajaysinh Chauhan
        Description 		: Method for Execution
        Last Modified Date	: 13 June 2017
        Last Modified By	: Ajaysinh Chauhan
	**************************************************************************************************************************************/
    public void execute(QueueableContext context) {
        if(lstRecordsToInsert.size()>0){
            insert lstRecordsToInsert;
        }
        if(lstRecordsToUpdate.size()>0){
            try{
                update lstRecordsToUpdate;
            }catch(Exception ex){
                Debug.log('saveWithQueueble::'+ex);
            }
        }
    }
}