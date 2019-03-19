/************************************************************************************************************************************
    Author 		: 	Hemanshu Shah	
    Description : 	This class contain buisness logic to run trigger handler methods in context of trigger from which they are called.
    
    History		:
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION		DATE				AUTHOR					DETAIL
    1			15 January 2018		Hemanshu Shah			Initial Developement
    2			03 May 2018 		Krishana Tupe			Chnages for exception logging.
**************************************************************************************************************************************/
public class TriggerDispatcher{
    static String className;
    public static boolean isRootInvoker(){
        return ApexDebugLog.registerRootInvoker(ApexDebugLog.InvokerType.Triggered, className + '.' + getTriggerMethodName(), ApexDebugLog.InvokerType.Triggered);       
    }
    
    static String getTriggerMethodName() {
        String strMethodName = (Trigger.IsBefore) ? 'Before' : 'After';        
        if (Trigger.IsInsert)
            strMethodName += 'Insert';
        else if (Trigger.IsUpdate)
            strMethodName += 'Update';
        else if (trigger.IsDelete)
            strMethodName += 'Delete';
        else if (trigger.isUndelete)
            strMethodName += 'Undelete';
        return strMethodName;
    }
 /************************************************************************************************************************************
    Author 				: 	Hemanshu Shah
    Description 		: 	Call this method from your trigger, passing in an instance of a trigger handler which implements ITriggerHandler.
    						This method will fire the appropriate methods on the handler depending on the trigger context.
    Created Date		:	15 January 2018	
**************************************************************************************************************************************/
    public static void Run(ITriggerHandler handler)    {      
        className = String.valueOf(handler).split(':')[0];                    
        Debug.log('TriggerDispatcher isRootInvoker==>'+ApexDebugLog.currentInvoker);
        Debug.log('className==>'+className);
        // Before trigger logic
        if (Trigger.IsBefore){  
            // Before Insert trigger logic
            if (Trigger.IsInsert){                  
                if(isRootInvoker()){                     
                    try{ 
                        handler.BeforeInsert(trigger.new);
                    }catch(Exception pEx){                        
                        ApexDebugLog.logException(pEx,JSON.serialize(trigger.new), className, getTriggerMethodName());
                        Debug.log('Exception-'+pEx.getStackTraceString());
                        throw new TriggerDispatcherCustomException('Exception Message-'+pEx.getMessage());
                    }
                }else{                  
                    handler.BeforeInsert(trigger.new);
                }
            }
            
            // Before Update trigger logic            
            if (Trigger.IsUpdate){
                if(isRootInvoker()){
                    try{ handler.BeforeUpdate(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);
                       }catch(Exception pEx){ 
                           ApexDebugLog.logException(pEx,JSON.serialize(trigger.new), className, getTriggerMethodName());
                           Debug.log('Exception-'+pEx.getStackTraceString());
                           throw new TriggerDispatcherCustomException('Exception Message-'+pEx.getMessage());
                       }                       
                }else{
                    handler.BeforeUpdate(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);
                }
            }
            
            // Before Delete trigger logic 
            if(Trigger.IsDelete){
                if(isRootInvoker()){
                    try{ handler.BeforeDelete(trigger.old, trigger.oldMap); }
                    catch(Exception pEx){                            
                        Debug.log('Exception Catched BeforeDelete==>');
                        ApexDebugLog.logException(pEx,JSON.serialize(trigger.new), className, getTriggerMethodName());
                        Debug.log('\nException==>\n'+pEx.getStackTraceString());
                        throw new TriggerDispatcherCustomException('Exception Message==>\n'+pEx.getMessage());
                    }  
                }
                else{
                    handler.BeforeDelete(trigger.old, trigger.oldMap);
                }
            }
        }
        
        // After trigger logic
        if (Trigger.IsAfter ){
            
            // After insert trigger logic 
            if(Trigger.IsInsert){ 
                try{ 
                    handler.AfterInsert(trigger.new, Trigger.newMap); 
                }catch(Exception pEx){ 
                    ApexDebugLog.logException(pEx,JSON.serialize(trigger.new), className, getTriggerMethodName());                                                 
                    Debug.log('\nException==>\n'+pEx.getStackTraceString());
                    throw new TriggerDispatcherCustomException('Exception Message==>\n'+pEx.getMessage());
                }
            }
            
            // After Update trigger logic 
            if (Trigger.IsUpdate){
                try{
                    handler.AfterUpdate(trigger.new, trigger.newMap, trigger.old, trigger.oldMap); 
                }catch(Exception pEx){ 
                    ApexDebugLog.logException(pEx,JSON.serialize(trigger.new), className, getTriggerMethodName());
                    Debug.log('\nException==>\n'+pEx.getStackTraceString());
                    throw new TriggerDispatcherCustomException('Exception Message==>\n'+pEx.getMessage());
                } 
            }
            
            // After Delete trigger logic
            if(trigger.IsDelete){                
                try{
                    handler.AfterDelete(trigger.old, trigger.oldMap);
                }catch(Exception pEx){
                    ApexDebugLog.logException(pEx,JSON.serialize(trigger.new), className, getTriggerMethodName());
                    Debug.log('\nException==>\n'+pEx.getStackTraceString());
                    throw new TriggerDispatcherCustomException('Exception Message==>\n'+pEx.getMessage());
                }
            }   
            
            // After Undelete trigger logic
            if (trigger.isUndelete){               
                try{
                    handler.AfterUndelete(trigger.old, trigger.oldMap);
                }catch(Exception pEx){ 
                    ApexDebugLog.logException(pEx,JSON.serialize(trigger.new), className, getTriggerMethodName());
                    Debug.log('\nException==>\n'+pEx.getStackTraceString());
                    throw new TriggerDispatcherCustomException('Exception Message==>\n'+pEx.getMessage());
                }   
            }
        }
        
    }
    
    public class TriggerDispatcherCustomException extends Exception {}    
}