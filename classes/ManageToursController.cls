/************************************************************************************************************************************
    Author      :   Samadhan Kadam
    Description :   This class contain all aura methods related to Manage Tour.
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1           30 Oct 2018         Samadhan Kadam      	Initial Developement
	2           10 Jan 2019         Prashant Mane			Seperate functionality from lightning component controller.
**************************************************************************************************************************************/
global without sharing class ManageToursController {
    public static Boolean isInvoker = false;
    public static Savepoint sp {get;set;}
    static {
        isInvoker = ApexDebugLog.registerRootInvoker(ApexDebugLog.InvokerType.AURA, 'ManageToursController' + 'getsObjectPrefix', ApexDebugLog.InvokerType.AURA);        
    }
	/************************************************************************************************************************************
		Author              : 	Samadhan Kadam
		Description         : 	This method is used to validate the opportunity before redirect user to Books Tour page. 
		Created Date        : 	18/07/2018
		Issue No.           : 	ST-2608
	*************************************************************************************************************************************/
    webservice static string isValidOpportunityForManageTour(Id oppId) {
        Opportunity  objOpp = [Select Id,Name,StageName,Contract_Stage__c from Opportunity where Id = : oppId];
        ValidResultWithOpportunity validResult = new ValidResultWithOpportunity();
        If(objOpp != null && objOpp.StageName == 'Closed Won' || objOpp.StageName == 'Closed Lost' || objOpp.StageName == 'Merged'){
            validResult.isValid = false;
            validResult.errorMsg  = 'Cannot Book Tours for Opportunity with stage Closed Won, Closed Lost or Merged';
        }else if(objOpp != null &&  objOpp.StageName == 'Closing' && (objOpp.Contract_Stage__c == 'Contract Sent' || objOpp.Contract_Stage__c == 'Contract Signed')){
            validResult.isValid = false;
            validResult.errorMsg  = 'Cannot Book Tours on Closing Opportunity with Contract Stage as Sent or Signed';
        }else{
            validResult.isValid = true;
        }
        return JSON.serialize(validResult);
    }
    
    /************************************************************************************************************************************
		Author              : 	Samadhan Kadam
		Description         : 	This method is used to validate the opportunity before redirect user to Books Tour page. 
		Created Date        : 	18/07/2018
		Issue No.           : 	ST-2608
	*************************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult isValidOpportunityForManageTourLightning(Id oppId) {     
        try{
            return new DatabaseResult(isValidOpportunityForManageTour(oppId));
        }catch(Exception pEx){
            ApexDebugLog.logException(pEx,'oppId==>'+oppId, 'ManageToursController', 'isValidOpportunityForManageTourLightning');            
            return (new DatabaseResult(pEx));   
        }
    }
	/************************************************************************************************************************************
		Author              : 	Prashant Mane
		Description         : 	This method is used to validate the Account before redirect user to Books Tour page. 
		Created Date        : 	27/07/2018
		Issue No.           : 	CSI-827 
	*************************************************************************************************************************************/
    webservice static String isValidAccountForManageTour(Id accountId) {        
        Account acc = [SELECT Id,Name,(SELECT Id,Name FROM Contacts) FROM Account WHERE Id = : accountId];
        ValidResultWithOpportunity validResult = new ValidResultWithOpportunity();
        if(acc != null && acc.contacts.size() < 1 ){
            validResult.isValid = false;
            validResult.errorMsg  = 'You cannot book a tour due to Contact not found under '+acc.Name+'';
        }else{
            validResult.isValid = true;
        }
          return JSON.serialize(validResult);
    }
    
    /************************************************************************************************************************************
		Author              : 	Samadhan Kadam
		Description         : 	This method is used to validate the Account before redirect user to Books Tour page. 
		Created Date        : 	27/07/2018
		Issue No.           : 	CSI-827 
	*************************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult isValidAccountForManageTourLightning(Id accountId) {  
        try{
            return new DatabaseResult(isValidAccountForManageTour(accountId));    
        }catch(Exception pEx){
            ApexDebugLog.logException(pEx,'accountId==>'+accountId, 'ManageToursController', 'isValidOpportunityForManageTourLightning');            
            return (new DatabaseResult(pEx));    
        } 
    }
    
    /************************************************************************************************************************************
		Author              : 	Samadhan Kadam
		Description         : 	This method is used to validate the Account before redirect user to Books Tour page. 
		Created Date        : 	01/10/2019
		Issue No.           : 	CSI-1571 
	*************************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult createOpportunityForManageTours(Id contactId,object noOfDesks){
        try{
            sp = Database.setSavepoint();
            Opportunity opp = OpportunityHelper.createOpportunity(contactId, 'Qualifying');
            debug.log('opp in create new opp--->'+opp);
            opp.Interested_in_Number_of_Desks__c = Integer.valueOf(noOfDesks) > 0 ? Integer.valueOf(noOfDesks) :null;
            //as per discussion with Sagar whenever new opportunity is created from Manage tour add Opporunity button owner shoul be logged in user. 
            opp.OwnerId = UserInfo.getUserId();            
            TriggerSettings.mappedField.Opportunity_inheritOrganizationRecordTypeAndOwner = false;
            insert opp;            
            return new DatabaseResult(JSON.serialize([Select Id,Name from Opportunity Where Id=:opp.Id])); 
        }catch(Exception pEx){
            LightningComponentController.rollbackTransaction(sp);
            ApexDebugLog.logException(pEx,'contactId==>'+contactId+'noOfDesks==>'+JSON.serialize(noOfDesks), 'ManageToursController', 'createOpportunityForManageTours');            
            return (new DatabaseResult(pEx));       
        } 
    }
    
    /************************************************************************************************************************************
		Author              : 	Samadhan Kadam
		Description         : 	This method is used to validate the Account before redirect user to Books Tour page. 
		Created Date        : 	01/10/2019
		Issue No.           : 	CSI-1571 
	*************************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult getDataForManageTours(String entityType,String accountId){
        try{
            Setting__c ManageToursOpportunityStagesSetting = Settings.get('ManageToursOpportunityStages');
            Set<String> setManageToursOpportunityStages;
            if(ManageToursOpportunityStagesSetting != null){
                setManageToursOpportunityStages = (Set<String>)(JSON.deserialize(ManageToursOpportunityStagesSetting.Data__c.toLowerCase(), Set<String>.class));
            }
            Map<String,Map<Id,Tour_Schedule__c>> mapBuildings = new Map<String,Map<Id,Tour_Schedule__c>>();
            mapBuildings.put('WeWork',new Map<Id,Tour_Schedule__c>([select Id,Name, Building__c,Tour_Spacing__c,Building__r.Name,Building__r.UUID__c,Product_Line__c From Tour_Schedule__c Where Product_Line__c='WeWork']));
            mapBuildings.put('WeLive',new Map<Id,Tour_Schedule__c>([select Id,Name, Building__c,Tour_Spacing__c,Building__r.Name,Building__r.UUID__c,Product_Line__c From Tour_Schedule__c Where Product_Line__c='WeLive']));
            Setting__c tourSetting = [Select Id,Data__c From Setting__c Where Name='TourReservableAPI'];
            List<Contact> currentUser = [Select Id From Contact Where Email=:UserInfo.getUserEmail()];
            if(currentUser.size()==0){
                User apiUser = [Select Email From User Where Name='Susie Romero'];
                currentUser = [Select Id From Contact Where Email=:apiUser.Email];
            }
            Map<String,Object> mapData = new Map<String,Object>();
            mapData.put('mapBuildings',mapBuildings);
            mapData.put('tourSetting',tourSetting);
            if(currentUser.size()>0){
                mapData.put('currentUser',currentUser[0]);
            }
            if(String.isNotBlank(accountId)){
                if(entityType=='account'){  
                    mapData.put('relatedOpportunities',[Select Id,Name From Opportunity Where StageName NOT IN:setManageToursOpportunityStages AND  AccountId = : accountId ORDER BY LastModifiedDate DESC ]);
                    mapData.put('relatedContacts',[Select Id,Name From Contact Where AccountId = : accountId]);               
                }else{
                    if(entityType=='contact'){
                        mapData.put('relatedOpportunities',[Select Id,Name From Opportunity Where AccountId=:accountId AND StageName NOT IN:setManageToursOpportunityStages Order By CreatedDate desc]);
                    }else if(entityType=='opportunity'){
                        mapData.put('relatedContacts',[Select Id,Name From Contact Where AccountId=:accountId]);
                    }
                }
            } 
            return new DatabaseResult(JSON.serialize(mapData));  
        }catch(Exception pEx){
            ApexDebugLog.logException(pEx,'entityType==>'+entityType+' accountId==>'+accountId, 'ManageToursController', 'getDataForManageTours');            
            return (new DatabaseResult(pEx));
        }  
    }
    
    /************************************************************************************************************************************
		Author              : 	Prashant Mane
		Description         : 	This method is used to get User And Buildings For Books Tour page. 
		Created Date        : 	01/10/2019
		Issue No.           : 	CSI-1571 
	*************************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult getUserAndBuildingForManageTours(String buildingId){
        try{
            Map<String,Object> response = new Map<String,Object>();
            List<Building__c> lstBuilding;
            if(buildingId != null && buildingId != ''){
                String buildingQuery = 'SELECT Id FROM Building__c WHERE ';
                if(buildingId.length() == 15 || buildingId.length() == 18){
                    buildingQuery += 'Id =: buildingId';
                    lstBuilding  = Database.query(buildingQuery);
                    if(lstBuilding != null && lstBuilding.size()>0){
                        response.put('building',lstBuilding[0]);
                    }
                }else if(buildingId.length() > 18){
                    buildingQuery += 'UUID__c =: buildingId';
                    lstBuilding  = Database.query(buildingQuery);
                    if(lstBuilding != null && lstBuilding.size()>0){
                        response.put('building',lstBuilding[0]);
                    }
                }else{
                    response.put('building',null);
                }
                Debug.log('buildingQuery ::'+buildingQuery);
            }
            DatabaseResult info =  LightningComponentController.getUserInfo();
            response.put('userInfo',info);
            return new DatabaseResult(JSON.serialize(response));
        }catch(Exception pEx){                       
            ApexDebugLog.logException(pEx, buildingId, 'ManageToursController', 'getUserAndBuildingForManageTours');            
            return (new DatabaseResult(pEx));            
        }
    }
     
    global class ValidResultWithOpportunity{
        global Boolean isValid {get;set;}   
        global string errorMsg {get;set;}      
    }
    
    public class ManageToursControllerException extends Exception{}
}