/**
* @Created By   	: Mayuresh Ghodke
* @Created Date 	: 11 Dec'16
* @Issue No.		: ST-684
* @Comment			: Class will call Kickbox API to check email ids. And Cover Test methods in KickboxVerificationTest Apex class.
*/
public class QueueKickBoxApiRequest implements Queueable, Database.AllowsCallouts { 
	List<id> lstJob_ids = new List<id>();
	Boolean importLead;
    public QueueKickBoxApiRequest(List<id> lstJobId, Boolean importLead){
        Debug.log('In QueueKickBoxApiRequest lstJobId ::'+lstJobId);	
        this.lstJob_ids = lstJobId;
        this.importLead = importLead;
    }

    public void execute(QueueableContext context){
        try {
            Debug.log('In QueueKickBoxApiRequest :: lstJob_ids.size'+lstJob_ids.size());	
            Debug.log('In QueueKickBoxApiRequest :: lstJob_ids'+lstJob_ids);
            //API Calling.
            //if(importLead)
            	//KickboxVerificationApiHandler.sendKickboxApiRequestQueue(lstJob_ids);
            //else
                KickboxVerificationApiHandlerForBatch.sendKickboxApiRequestQueueforBatch(lstJob_ids); //For batch class which will check all contacts and leads email quality which are currently present in salesforce
        } catch (Exception e){
            Debug.log('Error in QueueKickBoxApiRequest :: '+e);
        }
    }
}