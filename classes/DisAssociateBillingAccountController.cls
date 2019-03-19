/************************************************************************************************************************************
    Author      :   Nikhil Mehta
    Description :   This class contain all aura methods related to Disassociate Billing Account.
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR              DETAIL
    1           19 September 2018   Nikhil Mehta      	Initial Developement
**************************************************************************************************************************************/
global without sharing class DisAssociateBillingAccountController {
    public class DisAssociateBillingAccountControllerException extends Exception{}
    public static Boolean isInvoker = false;
    static {
        isInvoker = ApexDebugLog.registerRootInvoker(ApexDebugLog.InvokerType.AURA, 'DisAssociateBillingAccountController' + 'getsObjectPrefix', ApexDebugLog.InvokerType.AURA);        
    }
    /************************************************************************************************************************************
        Author              : Nikhil Mehta
        Description         : This method is web service for disassocate billing account.
        Created Date        : 19 September 2018 
        Issue No            : ST-2753
    **************************************************************************************************************************************/
    @AuraEnabled
    webservice static String validForDisAssociationWeb(Opportunity oppRec, Boolean disassociateBillAccFromOpp){
        if(disassociateBillAccFromOpp){
            return JSON.serialize(isValidForDisAssociation(oppRec.Id));
        }else{
            Map<Id, Map<String, String>> mapOpportunityWithResult = checkValidForDisAssociation(new List<Opportunity>{oppRec});
            return JSON.serialize(mapOpportunityWithResult.get(oppRec.Id) != null ? mapOpportunityWithResult.get(oppRec.Id) : new Map<String, String>{'isValidForDisAssociation' => 'false', 'errorMessage' => 'Something went wrong, please contact system administrator.'});
        }
    }
    /************************************************************************************************************************************
        Author              : Nikhil Mehta
        Description         : This method valide disassociate billing account in lightning.
        Created Date        : 19 September 2018 
        Issue No            : ST-2753
    **************************************************************************************************************************************/
    @AuraEnabled  
    public static DatabaseResult isValidForDisAssociationforLightning(Opportunity oppRec, Boolean disassociateBillAccFromOpp){
        Map<String, String> mapResult;
        try{
            if(oppRec != null){
                if(disassociateBillAccFromOpp){
                    mapResult = isValidForDisAssociation(oppRec.Id);
                    return new DatabaseResult(mapResult);
                }else{
                    Map<Id, Map<String, String>> mapOpportunityWithResult = checkValidForDisAssociation(new List<Opportunity>{oppRec});
                    return new DatabaseResult(mapOpportunityWithResult.get(oppRec.Id) != null ? mapOpportunityWithResult.get(oppRec.Id) : new Map<String, String>{'isValidForDisAssociation' => 'false', 'errorMessage' => 'Something went wrong, please contact system administrator.'});
                }
            }else{
                throw new DisAssociateBillingAccountControllerException('opportunityId is null');
            }
        }catch(Exception pEx){
            ApexDebugLog.logException(pEx, '', 'DisAssociateBillingAccountController', 'isValidForDisAssociationforLightning');            
            return (new DatabaseResult(pEx));
        }
        
    }
    /************************************************************************************************************************************
        Author              : Nikhil Mehta
        Description         : This method used to valid and disassociate billing account on single opportunity.
        Created Date        : 19 September 2018 
        Issue No            : ST-2753
    **************************************************************************************************************************************/
    public static Map<String, String> isValidForDisAssociation(Id opportunityId){
        Map<Id, Map<String, String>> mapOpportunityWithResult = isValidForDisAssociation(new Set<Id>{opportunityId});
        return mapOpportunityWithResult.get(opportunityId) != null ? mapOpportunityWithResult.get(opportunityId) : new Map<String, String>{'isValidForDisAssociation' => 'false', 'errorMessage' => 'Something went wrong, please contact system administrator.'};
    }
    /************************************************************************************************************************************
        Author              : Nikhil Mehta
        Description         : This is bulkify method for valid and disassociate billing account from opportinity.
        Created Date        : 19 September 2018 
        Issue No            : ST-2753
    **************************************************************************************************************************************/
    public static Map<Id, Map<String, String>> isValidForDisAssociation(Set<Id> setOpportunityIds){
        List<Opportunity> lstOpportunities = [SELECT Id, StageName, Contract_Stage__c, Billing_Account__c, OwnerId FROM Opportunity WHERE Id IN : setOpportunityIds];
        Map<Id, Map<String, String>> mapOpportunityWithResult;
        if(! lstOpportunities.isEmpty()){
            mapOpportunityWithResult = checkValidForDisAssociation(lstOpportunities);
            Debug.Log('mapOpportunityWithResult---'+mapOpportunityWithResult);
            List<Opportunity> lstOpportunitiesToUpdate = new List<Opportunity>();
            for(Id oppId : setOpportunityIds){
                if(mapOpportunityWithResult.get(oppId) != null && Boolean.valueOf(mapOpportunityWithResult.get(oppId).get('isValidForDisAssociation'))){
                    lstOpportunitiesToUpdate.add(new Opportunity(Id = oppId, Billing_Account__c = null));
                }else if(mapOpportunityWithResult.get(oppId) == null){
                    mapOpportunityWithResult.put(oppId, new Map<String, String>{'isValidForDisAssociation' => 'false', 'errorMessage' => 'Something went wrong, please contact system administrator.'});
                }
            }
            Debug.Log('lstOpportunitiesToUpdate---'+lstOpportunitiesToUpdate);
            if(! lstOpportunitiesToUpdate.isEmpty()){
                update lstOpportunitiesToUpdate;
            }
        }
        return mapOpportunityWithResult;
    }    
    
    /************************************************************************************************************************************
        Author              : Nikhil Mehta
        Description         : This method checks the opportunity is valid for disassociation and disassociate if is valid.
        Created Date        : 19 September 2018 
        Issue No            : ST-2753
    **************************************************************************************************************************************/
    public static Map<Id, Map<String, String>> checkValidForDisAssociation(List<Opportunity> lstOpportunities){
        Debug.log('In isValidForDisAssociation lstOpportunities---' + lstOpportunities);
        Map<Id, Map<String, String>> mapOpportunityWithResult = new Map<Id, Map<String, String>>();
        List<CustomPermission> lstCustomPermissions;
        Id currentUserProfileId = UserInfo.getProfileId();
        Id currentUserId = UserInfo.getUserId();
        Boolean isValidForDisassociation = false;
        for(Opportunity objOpportunity : lstOpportunities){
            isValidForDisassociation = checkValidUserForDisAssociation(lstCustomPermissions, objOpportunity.OwnerId, currentUserId, currentUserProfileId);
            if(isValidForDisassociation && String.isNotBlank(objOpportunity.Billing_Account__c)){
                Setting__c manageBillingAccountSetting = Settings.get('ManageBillingAccountSetting');
                if(manageBillingAccountSetting != null && manageBillingAccountSetting.Data__c != null){
                    Map<String,object> mapSettingData = (Map<String, Object>) JSON.deserializeUntyped(manageBillingAccountSetting.Data__c.toLowerCase());
                    Debug.Log('mapSettingData---'+mapSettingData);
                    Map<String, Set<String>> mapDisAssociateBillingAccountSettingData = (Map<String, Set<String>>) JSON.deserialize(JSON.serialize(mapSettingData.get('disassociatebillingaccount')),Map<String, Set<String>>.class);
                    Debug.Log('mapDisAssociateBillingAccountSettingData---'+mapDisAssociateBillingAccountSettingData);
                    if(mapDisAssociateBillingAccountSettingData.get('excludedoppstages') != null && objOpportunity.StageName != null && mapDisAssociateBillingAccountSettingData.get('excludedoppstages').contains(objOpportunity.StageName.toLowerCase())){
                        mapOpportunityWithResult.put(objOpportunity.Id, new Map<String, String>{'isValidForDisAssociation' => 'false', 'errorMessage' => 'You can not perform this action for the Opportunity Stage : ' + objOpportunity.StageName});
                    }else if(mapDisAssociateBillingAccountSettingData.get('allowedoppstages') != null && objOpportunity.StageName != null && mapDisAssociateBillingAccountSettingData.get('allowedoppstages').contains(objOpportunity.StageName.toLowerCase())){
                        if(mapDisAssociateBillingAccountSettingData.get('excludedcontractstages') != null && objOpportunity.Contract_Stage__c != null && mapDisAssociateBillingAccountSettingData.get('excludedcontractstages').contains(objOpportunity.Contract_Stage__c.toLowerCase())){
                            mapOpportunityWithResult.put(objOpportunity.Id, new Map<String, String>{'isValidForDisAssociation' => 'false', 'errorMessage' => ' You can not perform this action for the Contract Stage : ' + objOpportunity.Contract_Stage__c});
                        }else{
                            mapOpportunityWithResult.put(objOpportunity.Id, new Map<String, String>{'isValidForDisAssociation' => 'true'});
                        }
                    }else{
                        mapOpportunityWithResult.put(objOpportunity.Id, new Map<String, String>{'isValidForDisAssociation' => 'false', 'errorMessage' => 'You can not perform this action for the Opportunity Stage : ' + objOpportunity.StageName});
                    }
                }else{
                    mapOpportunityWithResult.put(objOpportunity.Id, new Map<String, String>{'isValidForDisAssociation' => 'false', 'errorMessage' => 'Sales Console Setting (ManageBillingAccountSetting) not found.'});
                }
            }else if(isValidForDisassociation && String.isBlank(objOpportunity.Billing_Account__c)){
                mapOpportunityWithResult.put(objOpportunity.Id, new Map<String, String>{'isValidForDisAssociation' => 'false', 'errorMessage' => 'You can not perform this action as Billing Account is already blank.'});
            }else if(!isValidForDisassociation){
                mapOpportunityWithResult.put(objOpportunity.Id, new Map<String, String>{'isValidForDisAssociation' => 'false', 'errorMessage' => 'To update the billing account please contact Growth Ops.'});
            }
        }
        return mapOpportunityWithResult;
    }
    
    public static Boolean checkValidUserForDisAssociation(List<CustomPermission> lstCustomPermissions, Id oppOwerId, Id currentUserId, Id currentUserProfileId){
        if(lstCustomPermissions == null){
            lstCustomPermissions = [SELECT Id, DeveloperName, (SELECT Id, Parent.Name, Parent.Profile.Name FROM SetupEntityAccessItems WHERE Parent.Profile.Id =: currentUserProfileId) FROM CustomPermission WHERE DeveloperName = 'Can_Reparent_Billing_Account'];
        }
        if(oppOwerId.equals(currentUserId)){
            return true;
        }if(lstCustomPermissions != null && lstCustomPermissions.size() > 0 && lstCustomPermissions[0].SetupEntityAccessItems != null && lstCustomPermissions[0].SetupEntityAccessItems.size() > 0){
            return true;
        }
        return false;
    }
}