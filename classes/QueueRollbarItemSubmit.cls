/******************************************************************************************************************** 
Name              : QueueRollbarItemSubmit.cls 
Description       : Future class for posting requst to rollbar.

Revision History  :-
Created/Modified by         Created/Modified Date       Requested by         Technical Design Proposal
---------------------------------------------------------------------------------------------------------------------
1. Rashad Saeed (Creator)      31 DEC 2018              WeWork                 SF - Rollbar Integration  Google Doc  
---------------------------------------------------------------------------------------------------------------------
*********************************************************************************************************************/
public class QueueRollbarItemSubmit implements Queueable, Database.AllowsCallouts {
   private RollbarItem item;
    private String project;
    Private List <Apex_Debug_Log__c >Alog;
    Private Apex_Debug_Log__c apexLog;
    public QueueRollbarItemSubmit() {
        List <AsyncApexJob> AsyncApexJob  = [SELECT  Id , Status  FROM AsyncApexJob WHERE ApexClassId IN
                                 (SELECT Id from ApexClass WHERE NamespacePrefix = null
                                  AND Name = 'QueueRollbarItemSubmit') and Status ='Queued' ]; 
        if (!AsyncApexJob.isEmpty())
            System.abortJob(AsyncApexJob[0].id);
        Integer HoursFilter = (Integer)[SELECT HoursFilter__c FROM Integration_Data__mdt WHERE DeveloperName = :'RollBar' LIMIT 1].HoursFilter__c; 
        if (HoursFilter == null)
            HoursFilter = 1; 
        DateTime LastNHours = System.Now().addHours(-HoursFilter);
        this.Alog = [select Id ,Name,Apex_Class__c ,
                     ApexLogId__c ,ErrorLineNumber__c ,
                     Type__c ,ExceptionTypeName__c ,
                     InstanceName__c ,Login_UserId__c ,
                     Login_User_ProfileId__c ,Message__c ,
                     Method__c ,Record_Id__c ,ReplayId__c ,
                     Stack_Trace__c ,Status__c 
                     from Apex_Debug_Log__c
                     where RollBar_Integration_status__c  = NULL
                     and CreatedDate >=: LastNHours
                     limit 1
                    ];
        if (!Alog.isEmpty()) {
            this.item = new RollbarItem(Alog[0]);
            this.project = 'RollBar';
            this.apexLog =Alog[0]; 
        }
    }
    public void execute(QueueableContext qc) {
        if (!Alog.isEmpty()){
        	apexLog.RollBar_Integration_status__c = String.ValueOf (Rollbar.submitItem(item, project).getStatusCode());
            Update apexLog;
            system.enqueueJob(new QueueRollbarItemSubmit());
        }
    }
}