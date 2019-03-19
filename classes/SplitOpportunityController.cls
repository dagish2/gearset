/************************************************************************************************************************************
    Author      :   Pragalbha Mahajan    
    Description :   This class contain all aura methods that are used in split opportunity component.
    
    History     :
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1           17 July 2018        Pragalbha Mahajan       Initial Developement
**************************************************************************************************************************************/

global without sharing class SplitOpportunityController {
    public class SplitOpportunityControllerException extends Exception{}
    public static Savepoint sp {get;set;}
    public static Boolean isInvoker = false;
    static {
        isInvoker = ApexDebugLog.registerRootInvoker(ApexDebugLog.InvokerType.AURA, 'SplitOpportunityController' + 'getsObjectPrefix', ApexDebugLog.InvokerType.AURA);        
        sp = Database.setSavepoint();
    }
    
    /************************************************************************************************************************************
    Author         		:   Priyanka Ambre
    Description    		:   This method is used to create and deep clone opportunity.
    Issue No.      		:   ST-2043
    Last Modified Date  :  	17 July 2018
	Last Modified By  	: 	Pragalbha Mahajan
    **************************************************************************************************************************************/  
	@AuraEnabled
    public static DatabaseResult splitOpportunity(String oppRecId, OpportunityLineItem lineItemRec){
        try{
            DatabaseResult db = LightningComponentController.getObjectFields('Opportunity');
            List<String> listOppFields = (List<String>)db.data; 
            List<OpportunityLineItem> lstLineItemsToInsert = new List<OpportunityLineItem>();
            List<Id> listLineItemIdsToDelete = new List<Id>();
            Opportunity newOppRec;
            if(oppRecId != null && lineItemRec != null){
                List<Opportunity> lstOpp = Database.query('SELECT '+String.join(listOppFields, ',')+' FROM Opportunity WHERE Id=\''+ oppRecId+'\'');
                debug.log('lstOpp: '+lstOpp);
                if(lstOpp[0] != null){
                    newOppRec = lstOpp[0].clone(false, true, true, true);
                    newOppRec.Old_Opportunity__c = lstOpp[0].Id;
                    newOppRec.Interested_in_Number_of_Desks__c = 0;
                    newOppRec.Split_Opportunity__c = true;
                    newOppRec.Geography__c = (lineItemRec.Geography__c != null)?lineItemRec.Geography__c:null; 
                    newOppRec.Building__c = (lineItemRec.Building__c != null)?lineItemRec.Building__c:null;
                    newOppRec.Owner_Auto_Assign__c = false;
                    newOppRec.Do_Not_Create_Opportunity_Role__c = false; // Modified By Priyanka Ambre to Create Opportunity role
                    TriggerSettings.mappedField.Opportunity_inheritOrganizationRecordTypeAndOwner = false;//Modified by Priyanka Ambre for owner assignment.
                    insert newOppRec;     
                    
                    listLineItemIdsToDelete.add(lineItemRec.Id); 
                    lineItemRec.Id = null;
                    lineItemRec.TotalPrice = null;
                    lineItemRec.Is_Primary_Product__c = true;
                    lineItemRec.OpportunityId = newOppRec.Id;
                    
                    insert lineItemRec;
                    Database.delete(listLineItemIdsToDelete);
                }
            }
            Debug.log('In splitOpportunityController - SOQL LIMITS :: '+Limits.getQueries()); 
            return new DatabaseResult(newOppRec.Id); 
        } catch(Exception pEx) {
            ApexDebugLog.logException(pEx,oppRecId, 'SplitOpportunityController', 'splitOpportunity');            
            return (new DatabaseResult(pEx)); 
        } 
    } 
    
    /************************************************************************************************************************************
    Author         		:   Priyanka Ambre
    Description    		:   This method brings the all products for the given opp if logged in user have the permissions.
    Last Modified Date  :  	17 July 2018
	Last Modified By  	: 	Pragalbha Mahajan
    **************************************************************************************************************************************/  
    @AuraEnabled
    public static DatabaseResult getOppProductForSplit(Id oppId){
        OppSplitProductData oppSplitProductData = new OppSplitProductData();
        List<Opportunity> lstOpp = [Select Id, OwnerId, Owner.Profile.Name, Owner.Profile.Id, Name, (SELECT Id, Quantity, UnitPrice, TotalPrice, Description, PricebookEntry.Name, Geography__c,Geography__r.Name, ListPrice, PricebookEntry.Product2.Family, Building__c, Building__r.Name, Sq_Feet__c, Start_Date__c, Family__c, QuantityUnitOfMeasure__c, Product_Category__c, ProductCode__c, Building_UUID__c, Is_Primary_Product__c FROM OpportunityLineItems) FROM Opportunity WHERE Id =: oppId];
        oppSplitProductData.oppRec = (lstOpp[0] != null && lstOpp.size() > 0) ? lstOpp[0] : new Opportunity();
        oppSplitProductData.isValidForSplit = false;
        if(lstOpp != null && lstOpp[0].OwnerId != UserInfo.getUserId()){            
            List<CustomPermission> lstCustomPermissions = [SELECT Id, DeveloperName, (SELECT Id, Parent.Name, Parent.Profile.Name FROM SetupEntityAccessItems WHERE Parent.Profile.Id =: UserInfo.getProfileId()) FROM CustomPermission WHERE DeveloperName = 'Can_Split_Opportunity'];
            Debug.log('lstCustomPermissions---'+lstCustomPermissions);
            Debug.log('lstCustomPermissions---'+lstCustomPermissions[0].SetupEntityAccessItems);
            if(lstCustomPermissions != null && lstCustomPermissions.size() > 0 && lstCustomPermissions[0].SetupEntityAccessItems != null && lstCustomPermissions[0].SetupEntityAccessItems.size()>0){
                oppSplitProductData.isValidForSplit = true;
            }  
        }else {
            oppSplitProductData.isValidForSplit = true;
        }
        return new DatabaseResult(JSON.serialize(oppSplitProductData));
    }
    
     public Class OppSplitProductData {
        public Boolean isValidForSplit {get;set;}
        public Opportunity oppRec {get;set;}
    }
}