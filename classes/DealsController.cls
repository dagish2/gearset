public class DealsController {
    public DealsController(ApexPages.StandardController controller){
    }
    
    public ApexPages.StandardSetController SetController{get;set;}
    public DealsController(ApexPages.StandardSetController controller){
        SetController = controller;
    }
    
    public List<Deal__c>  getDeals() {
        if( SetController == null ){
            return [Select Id, Name, Priority__c, Group__c, Phase__c,Notes__c,Timing__c,
                    Adam_Actions__c, Status__c,Team__c,Percent_Value__c,Counter_Party__c,
                   Approver_1__c, Approver_2__c, Approver_3__c, Approver_4__c,
                    Approver_1__r.Name, Approver_2__r.Name, Approver_3__r.Name, Approver_4__r.Name, Approver_5__r.Name, Approver_6__r.Name
                    From Deal__c
                   Order By Priority_in_Number__c asc];
        }
        else {
            return [Select Id, Name, Code_Name__c, Priority__c, Group__c, Phase__c,Notes__c,Timing__c,
                    Adam_Actions__c, Status__c,Team__c,Percent_Value__c,Counter_Party__c,
                    Approver_1__c, Approver_2__c, Approver_3__c, Approver_4__c, 
                    Approver_1__r.Name, Approver_2__r.Name, Approver_3__r.Name, Approver_4__r.Name, Approver_5__r.Name, Approver_6__r.Name
                    From Deal__c
                    Where Id in :SetController.getRecords() Order By Priority_in_Number__c asc];
        }
    }
}