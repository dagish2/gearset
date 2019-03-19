/*********************************************************************************************
Name   : KickboxVerificationApiHandler
Purpose: This class will get call from Process builder. Name : Kickbox API Callout Queueable
		 If Kickbox_Verification__c object record get update after 10mins from its creation time.
		 then above Proccess builder will get fir and sendKickboxApiRequest() method get call.
		 Which will send list of job id to Queueable class 'QueueKickBoxApiRequest' which will send callout request to Kickbox API.
		 And Kickbox_Verification__c's will get set to Process_Leads_After_N_Mins__c -56 mins from current time to breck queable call.
		 Again after 4 mins Time base work flow will get call Named : 'Process Leads' which will update  Process Leads field 'true' 
		 Which will fir new Process builder Named : 'Process Leads of Kickbox' and call this class's method Named : 'processLeads()'
		 Which will fetch that Kickbox_Verification__c's attahment Named 'Kickbox Response : JobId : '+Job_Id and process that file to insert leads.
  		 And Cover Test methods in KickboxVerificationTest Apex class.
History:
         VERSION      DATE      	AUTHOR                 DETAIL				ISSUE
          1.0      11 Dec 2016   Mayuresh Ghodke	 Initial Developement.		ST-684
		  2.0          _     	 Shobhit Ghalot	 	 
		  3.0	   11 Jan 2018	 Amol Darekar		

*********************************************************************************************/
global class KickboxVerificationApiHandler {
    //Method will get call from process builder. Name : Kickbox API Callout Queueable
    @InvocableMethod
    global static void sendKickboxApiRequest(List<Id> lstJobId) {        
        List<Kickbox_Verification__c> lstKickboxVerificationJobIdFromPB = [Select Id, Campaign__c, Process_Leads__c, Generate_Journey__c,Kickbox_API_Request_Send__c,Kickbox_Job_Id__c From Kickbox_Verification__c Where Id IN : lstJobId];
        if(lstJobId!=null && !lstJobId.isEmpty() && !lstKickboxVerificationJobIdFromPB[0].Process_Leads__c)
        	System.enqueueJob(new QueueKickBoxApiRequest(lstJobId,true));
	}
   
    /*Purpose: This method is use to create csv file to be send as attachment in email*/
     global static map<string,string> createCSV(successWrapper objsuccessWrapper){
        String csvSuccess = '';
        String csvFailure = '';
        map<string,string> mapCSV = new map<string,string>(); 
    
         if(objsuccessWrapper.lstsuccessLeads != null && objsuccessWrapper.lstsuccessLeads.size() >0){
             if(objsuccessWrapper.setHeadersSuccessCsv != null){
                for(string currentHeader : objsuccessWrapper.setHeadersSuccessCsv){
                    csvSuccess += currentHeader+',';
                }
         }
    
        csvSuccess = csvSuccess.removeEnd(',');
        csvSuccess+='\n';
         //if(objsuccessWrapper.lstsuccessLeads != null && objsuccessWrapper.lstsuccessLeads.size() > 0)
             for(Map<string,string> mapLead : objsuccessWrapper.lstsuccessLeads){
                 for(String header: objsuccessWrapper.setHeadersSuccessCsv)
                 	csvSuccess += mapLead.get(header) + ',';
                 csvSuccess += '\n';
             }
         } 
         
         if(objsuccessWrapper.mapErrors != null && !objsuccessWrapper.mapErrors.isEmpty()){
             csvFailure = 'Email, Error \n';
             for(string currentKey : objsuccessWrapper.mapErrors.keySet()){
                 csvFailure += currentKey + ','+ objsuccessWrapper.mapErrors.get(currentKey) + '\n';
             }
         }
      //Debug.log('csvSuccess::'+csvSuccess);
      //Debug.log('csvFailure::'+csvFailure);
      mapCSV.put('csvSuccess',csvSuccess);
      mapCSV.put('csvFailure',csvFailure);
      return mapCSV;
    }
        
	global class successWrapper {
        public List<Map<string,string>> lstsuccessLeads;
        public List<Map<string,string>> lstErrorLeads;
        public Map<String,String> mapErrors;
        public Id kickboxId;
        public Set<String> setHeadersSuccessCsv;
	} 
}