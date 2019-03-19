/************************************************************************************************************************************
    Author 		: 	Rupesh Patil
    Description : 	This class will contain the test methods of TrCaseAssignment
    History:
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE				AUTHOR			Issue No		DETAIL
	1			4 March 2019		Chandra Teja 	ST-3452     	Initial Development	 
**************************************************************************************************************************************/
public class TrCaseAssignment implements IProcessHandler {
    public void handle(List<sObject> triggerNew, Map<Id, sObject> triggerOldMap) {
        fireDefaultCaseAssignment((List<Case>)triggerNew, triggerOldMap);
    }
    static void fireDefaultCaseAssignment(List<Case> lstcases, Map<Id, sObject> mapOldCases) {
        Case objOldcase;
        Set<Id> setCaseIdsToFireAssignment = new Set<Id>();
        for(Case objCase: lstcases){
            if(!mapOldCases.isEmpty()) {
                objOldcase =(Case) mapOldCases.get(objCase.Id);
                if(objOldcase!= null && objOldcase.REA_Region__c != objCase.REA_Region__c){
                    setCaseIdsToFireAssignment.add(objCase.Id);
                }
            }else{
                setCaseIdsToFireAssignment.add(objCase.Id);
            }
        }
        if(AvoidRecurssion.firstRun && !setCaseIdsToFireAssignment.isEmpty()){
            AvoidRecurssion.firstRun = false;
            fireAssignment(setCaseIdsToFireAssignment);
        }
    }
    
    @future
    static void fireAssignment(Set<Id> setIdsToFireCaseAssignment){
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule = true;
        dmo.EmailHeader.triggerUserEmail = true;
        List<Case> lstCasesToFireAssignment = [SELECT Id FROM Case WHERE Id IN : setIdsToFireCaseAssignment];
        Debug.log('lstCasesToFireAssignment:'+lstCasesToFireAssignment);
        Database.update(lstCasesToFireAssignment, dmo);
    }
}