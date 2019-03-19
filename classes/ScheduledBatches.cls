/************************************************************************************************************************************
    Author 		: Krishana Tupe
    Description : ScheduledBatches class is used to run multiple Schedule Batches. 
    
    History:
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION		DATE						AUTHOR					DETAIL
    1			20 February 2018			Krishana Tupe			Initial Developement.
**************************************************************************************************************************************/
public class ScheduledBatches implements Schedulable {
    public Map<String,Map<String,String>> mapScheduleSettingData = new Map<String,Map<String,String>>();    
    public void execute(SchedulableContext sc) {
        try{
            Setting__c ScheduleBatchesInMinuitesSetting = Settings.get('ScheduleBatchesInMinuitesSetting');      
            mapScheduleSettingData = new Map<String,Map<String,String>>();
            if(ScheduleBatchesInMinuitesSetting != null){
                mapScheduleSettingData = (Map<String,Map<String,String>>)JSON.deserialize(ScheduleBatchesInMinuitesSetting.Data__c,Map<String,Map<String,String>>.class);  
            }
            debug.log('mapScheduleSettingData==>'+mapScheduleSettingData);
            if(mapScheduleSettingData !=null){
                for(String batchName : mapScheduleSettingData.keySet()){  
                    Map<String,String> batchSettingData = mapScheduleSettingData.get(batchName); 
                    Integer interval = Integer.valueOf(batchSettingData.get('Interval'));
                    Integer batchSize = Integer.valueOf(batchSettingData.get('BatchSize'));  
                    debug.log('interval==> '+interval+' : batchSize==>'+batchSize);                    
                    if(interval != 0 && interval>0 && interval<=59){                
                        for(Integer minuites=interval; minuites <= 59; minuites += interval){                 	
                            Type t = Type.forName(batchName); 
                            debug.log('Type==>'+t); 
                            System.scheduleBatch(((SchedulableBatch)(t.newInstance())),batchName+'-'+minuites,minuites,batchSize);                       
                        }  
                    }else{
                        debug.log('You entered Schedule time is less than 1');
                    }   
                }                    
            }                
        } catch(Exception pEx) {          
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('ScheduledBatches','execute',mapScheduleSettingData !=null ? JSON.serialize(mapScheduleSettingData):'Setting ScheduleBatchesInMinuitesSetting Not Found',pEx)
            );            
        }  
    }        
}