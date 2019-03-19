/************************************************************************************************************************************
    Author      :   Prashant Mane
    Description :   This class contain all aura methods related to AssignCaseToUser Lightning Component.
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1           10 Jan 2019         Prashant Mane        	Initial Developement
**************************************************************************************************************************************/
global without sharing class AssignCaseToUserController {
    public static Boolean isInvoker = false;
    public static Savepoint sp {get;set;}
    static {
        isInvoker = ApexDebugLog.registerRootInvoker(ApexDebugLog.InvokerType.AURA, 'AssignCaseToUserController' + 'getsObjectPrefix', ApexDebugLog.InvokerType.AURA);        
    }
    /************************************************************************************************************************************
		Author              : Prashant Mane
		Description         : This Method is used to get all data related to AssignCaseToUserController.
		Created Date        : 01/21/2019
		Issue No.           : CSI-1571
	**************************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult getOnLoadAssignCaseToUserData(String recordId){ 
        try{
            Map<String, Object> mapFormData = new Map<String, Object>();
            Setting__c objSetting = Settings.get('AllowedProfilesToManageCases');
            if(objSetting != null){
                mapFormData.put('settings', objSetting.Data__c);
            }
            
            List<Case> lstCases = Database.query('SELECT Id, Status, OwnerId, User_Profile__c, Record_Type_Name__c, Opportunity__c, AccountId FROM Case WHERE Id =: recordId');
            mapFormData.put('caseRecords', lstCases[0]);
        
            DatabaseResult loggedInUserData = LightningComponentController.getUserInfo();
            mapFormData.put('userData', loggedInUserData.data);
           
            return new DatabaseResult(mapFormData);  
        }catch(Exception pEx){
            ApexDebugLog.logException(pEx,'caseId==>'+recordId,'AssignCaseToUserController', 'getOnLoadAssignCaseToUserData');                       
            return new DatabaseResult(pEx);   
        }
    }       
    
    /************************************************************************************************************************************
		Author              : Nikhil Mehta
		Description         : This method takes case Id and user Id, the user will owner of that case and opportunity team 
							  member should be created with that user.
		Created Date        : 
		Issue No.           : ST-1995,ST-1965
		Last Modified Date  : 10 February 2018
		Last Modified By    : Nikhil Mehta
	**************************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult UpdateCaseToUser(String caseId, String userId, boolean isProfileAllowed){
        //Gad 18/10/2018 - Moved the logic of creating opportunity team member to the class "TrCaseCreateOppTeamMember".
        DatabaseResult result; 
        try{
            sp = Database.setSavepoint();
            Case caseRec = new Case(Id = caseId, OwnerId = userId);
            update caseRec;
            result = new DatabaseResult(true);
        } catch(Exception pEx){  
            LightningComponentController.rollbackTransaction(sp);
            ApexDebugLog.logException(pEx,'caseId==>'+caseId+' userId==>'+userId, 'AssignCaseToUserController', 'UpdateCaseToUser');                       
            return new DatabaseResult(pEx);  
        }
        return result;
    } 
 }