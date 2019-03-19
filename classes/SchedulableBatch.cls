/************************************************************************************************************************************
	Author 		: Krishana Tupe
	Description : SchedulableBatch abstract class is used to run multiple Schedule Batches.It is invoked from SchedulableBatches Batch.  

	History:
----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE						AUTHOR					DETAIL
	1			20 February 2018			Krishana Tupe			Initial Developement.
**************************************************************************************************************************************/
public abstract class SchedulableBatch implements Database.Batchable<sObject> {  
    //public SchedulableBatch(){}    
    //public virtual void execute(SchedulableContext sc) {}
    public virtual Database.QueryLocator start(Database.BatchableContext bc) {return null;}
    public virtual void execute(Database.BatchableContext bc, List<sObject>scope){}
    public virtual void finish(Database.BatchableContext bc){}    
}