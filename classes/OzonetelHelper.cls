/************************************************************************************************************************************
    Author      :   Milanjeet Singh 
    Description :   This class contains the helper methods to update activity in salesforce from ozonetel(External System).

    History:
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1           23 March 2018        ---                    Initial Developement
**************************************************************************************************************************************/
public without sharing class OzonetelHelper {
	/*Local variables declarations*/
    Task task {get;set;}
    List<Task> lstTask {get;set;}
    
    /* No Argument Constructor */
    public OzonetelHelper(){
        debug.Log('Inside ctor');
        /* More Code Here */
    }
    public DatabaseResult updateActivityFromOzonetel(RESTOzonetel.Ozonetel body){
        try{
            debug.Log('Inside updateActivityFromOzonetel');
            //List<Task> lstTask
            //task = new Task();
            DatabaseResult result;
            if(body.monitorUCID !=null && body.monitorUCID !=''){
               lstTask = new List<Task>([Select Id,FastCall__Call_Recording__c,CallDurationInSeconds,FastCall__Call_Id__c from Task Where FastCall__Call_Id__c=:body.monitorUCID]);
            }
            if(lstTask!=null && !lstTask.isEmpty() && lstTask.size()>0){
                Debug.Log('task ::: '+task);
                lstTask[0].FastCall__Call_Recording__c = body.AudioFile;
                if(body.CallDuration != null && (body.CallDuration.split(':')).size()==3){
                    lstTask[0].CallDurationInSeconds = Integer.valueOf(body.CallDuration.split(':')[0])*3600+Integer.valueOf(body.CallDuration.split(':')[1])*60+Integer.valueOf(body.CallDuration.split(':')[2]);
                }
                result = new DatabaseResult(Database.Update(lstTask));
            }
            return result;
        }
        catch(DmlException ex){                    
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('OzonetelHelper','updateActivityFromOzonetel DML Exception Occured', 'record'+task, ex)
            );
            return (new DatabaseResult(ex));           
        }
       /* catch(Exception ex){                    
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('OzonetelHelper','updateActivityFromOzonetel', 'record'+task, ex)
            );
            return (new DatabaseResult(ex));           
        }*/
    }
}