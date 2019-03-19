//************************************************************************************************************************************
//	Author      :   Shobhit Gahlot
//	Description :   This class contains business Logic of ReservableHoldTriggers

//	History :
//----------------------------------------------------------------------------------------------------------------------------------
//	VERSION     DATE                	AUTHOR                     DETAIL
//	1           05th Dec, 2017        	Shobhit Gahlot            Initial Developement
//**************************************************************************************************************************************/
public with sharing class ReservableHoldTriggerHandler extends ITriggerHandler{
    public ReservableHoldTriggerHandler(){
        super('Reservable_Hold__c');
    }
    //************************************************************************************************************************************
    //Author              :   Shobhit Gahlot
    //Description         :   This method overrides before insert method from ITriggerHander which will control the execution flow.
    //Last Modified Date  :   22/06/2018
    //Last Modified By    :   Rupesh Patil
    //**************************************************************************************************************************************/
    public override void BeforeInsert(List<SObject> listNewItems){
        if(TriggerSettings.mappedField.ReservableHold_UpdateAccResOpp){
            setAccConResOppForHold((List<Reservable_Hold__c>)listNewItems); 
        }
    }
    //************************************************************************************************************************************
    //    Author              :   Shobhit Gahlot
    //    Description         :   This method overrides before update method from ITriggerHander which will control the execution flow.
    //    Last Modified Date  :   05th Dec, 2017
    //    Last Modified By    :   Shobhit Gahlot
    //**************************************************************************************************************************************/
    public override void BeforeUpdate(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems){
            setOpportunity(listNewItems , mapOldItems);
    }
    //************************************************************************************************************************************
    //    Author              :   Samadhan Kadam
    //    Description         :   This method overrides after insert method from ITriggerHander which will control the execution flow.
    //    Last Modified Date  :   26 Feb, 2018
    //    Last Modified By    :   Samadhan Kadam
    //**************************************************************************************************************************************/
       public override void AfterInsert(List<SObject> listNewItems, Map<Id, SObject> mapNewItems){
            sendHoldEmailAlerts(listNewItems, null);
    }
    //************************************************************************************************************************************
    //    Author              :   Shobhit Gahlot
    //    Description         :   This method overrides after update method from ITriggerHander which will control the execution flow.
    //    Last Modified Date  :   05th Dec, 2017
    //    Last Modified By    :   Shobhit Gahlot
    //**************************************************************************************************************************************/
    public override void AfterUpdate(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems){
        if(TriggerSettings.mappedField.ReservableHold_CallReservableHoldAPI){
            List<Reservable_Hold__c> lstHoldsToBeReleased = new List<Reservable_Hold__c>();
            for(Reservable_Hold__c newHoldRecord : (List<Reservable_Hold__c>) listNewItems){  
                if(mapOldItems.get(newHoldRecord.Id).get('Approval_Status__c') != null && newHoldRecord.get('Approval_Status__c') != null && String.valueOf(mapOldItems.get(newHoldRecord.Id).get('Approval_Status__c')).toLowerCase() == 'hold' && String.valueOf(newHoldRecord.get('Approval_Status__c')).toLowerCase() == 'released'){
                    lstHoldsToBeReleased.add(newHoldRecord);
                }
            }
            if(lstHoldsToBeReleased.size() > 0){
               QueueReservableHold objHold = new QueueReservableHold(lstHoldsToBeReleased);
               ID jobID = System.enqueueJob(objHold);
            }
        }
               sendHoldEmailAlerts(listNewItems, mapOldItems);
    }
    /************************************************************************************************************************************
        Author              :   Shobhit Gahlot
        Description         :   This method sets account, opportunity and reservable lookups of reservable hold by uuid of account.
        Last Modified Date  :   23/06/2018
        Last Modified By    :   Rupesh Patil
        Comment			  	:	Functionality is changed. It sets contact, account,opportunity and reservable lookups by uuid of CONTACT if company uuid is not present
    **************************************************************************************************************************************/
    public static void setAccConResOppForHold(List<Reservable_Hold__c> listNewItems){
        Debug.log('listNewItems in setAccConResOppForHold==>'+listNewItems);
        List<Opportunity> lstOpportunity;
        Set<String> setClosedStage;
        Set<Id> setOpportunityIds = new Set<Id>();
        Set<String> setHoldsWithNoOpp = new Set<String>();
        Set<Id> setOrgAccountIds = new Set<Id>();
        Set<String> setContactUUIDs = new Set<String>();
        Set<String> setReservableUUIDs =  new Set<String>();
        Set<String> setBillingAccountsToMap =  new Set<String>();
        Map<String,sObject> mapContactsAndBillAccountsWithUUID = new Map<String,sObject>();
        Map<String,List<Opportunity>> mapOppWithUUIDs = new Map<String,List<Opportunity>>();
        Map<String,List<Opportunity>> mapOppWithBuildingUUIDAndContactUUID = new Map<String,List<Opportunity>>();        
        Map<String, Reservable__c> mapReservablesWithUUIDs = new Map<String, Reservable__c>(); 
        if(Settings.get('ContractEndpointOpportunityStages') != null){
            setClosedStage = new Set<String>();
            setClosedStage = (Set<String>)JSON.deserialize(Settings.get('ContractEndpointOpportunityStages').Data__c,Set<String>.class);
        }else{
            setClosedStage = new Set<String>{'Closed Won','Closed Lost','Merged'}; 
        }
        for(Reservable_Hold__c objReservableHold :  listNewItems){
            if(String.isNotBlank(objReservableHold.reservable_uuid__c)){
                setReservableUUIDs.add(objReservableHold.reservable_uuid__c);
            }
            if(String.isNotBlank(objReservableHold.Company_UUID__c)){//if Company_uuid is present
                setBillingAccountsToMap.add(objReservableHold.Company_UUID__c);
            }
            if(String.isNotBlank(objReservableHold.Contact_UUID__c)){//if contact_uuid is present
                setContactUUIDs.add(objReservableHold.Contact_UUID__c);
            }
            if(objReservableHold.starts_at__c != null && objReservableHold.starts_at__c <= Date.today()){
                objReservableHold.Approval_Status__c = 'Hold';
            }
        }
        if(setReservableUUIDs.size() > 0){
            for(Reservable__c objRes : [Select Id, UUID__c,Building_UUID__c,Building__c,Building__r.Name From Reservable__c Where UUID__c In : setReservableUUIDs]){
                mapReservablesWithUUIDs.put(objRes.UUID__c, objRes);
            } 
        }
        Debug.log('mapReservablesWithUUIDs =>'+mapReservablesWithUUIDs);
        Debug.log('setContactUUIDs=>'+setContactUUIDs);
        if(setContactUUIDs.size() > 0){
            for(Contact objContact : [SELECT Id, UUID__c, Billing_Account__c, AccountId, Account.Parent_Org_Id__c FROM Contact WHERE UUID__c IN : setContactUUIDs]){
                mapContactsAndBillAccountsWithUUID.put(objContact.UUID__C,objContact);
                if(objContact.Account != null){
                    if(String.isNotBlank(objContact.Account.Parent_Org_Id__c)){//If contact is related to standard account
                        setOrgAccountIds.add(objContact.Account.Parent_Org_Id__c);
                    }else{
                        setOrgAccountIds.add(objContact.AccountId);
                    }
                }
                /*if(objContact.Account == null && objContact.Billing_Account__c == null){
                    setHoldsWithNoOpp.add(objContact.UUID__c);
                } */
            }
            /*for(String contactUUID : setContactUUIDs){
                if(!mapContactsAndBillAccountsWithUUID.containskey(contactUUID)){
                    setHoldsWithNoOpp.add(contactUUID);
                }
            }*/
        }
        Debug.log('setOrgAccountIds:'+setOrgAccountIds); 
        if(setOrgAccountIds.contains(null)){
            setOrgAccountIds.remove(null);
        }
        if(setOrgAccountIds.size() > 0){
            for(Account objAccount : [Select Id,Name,(SELECT Id FROM Opportunities WHERE StageName NOT IN : setClosedStage) From Account where Id IN : setOrgAccountIds Or Parent.Id IN : setOrgAccountIds Or Parent.Parent.Id IN : setOrgAccountIds  Or Parent.Parent.Parent.Id IN : setOrgAccountIds  Or Parent.Parent.Parent.Parent.Id IN : setOrgAccountIds Or Parent.Parent.Parent.Parent.Parent.Id IN : setOrgAccountIds]){              
                for(Opportunity objOppo : objAccount.Opportunities){
                    setOpportunityIds.add(objOppo.Id);
                }               
            }
        }
        if(setBillingAccountsToMap.size() > 0){
            for(Billing_Account__c objBillingAccount : [SELECT Id, UUID__c, Ultimate_Parent_Org__c, Parent_Account__c, (SELECT Id FROM Opportunities__r WHERE StageName NOT IN : setClosedStage) FROM Billing_Account__c WHERE Ultimate_Parent_Org__c In: setOrgAccountIds OR UUID__c In : setBillingAccountsToMap]){
                if(String.isNotBlank(objBillingAccount.UUID__c) && setBillingAccountsToMap.contains(objBillingAccount.UUID__c)){
                    mapContactsAndBillAccountsWithUUID.put(objBillingAccount.UUID__c, objBillingAccount);
                }
                for(Opportunity objOppo : objBillingAccount.Opportunities__r){
                    setOpportunityIds.add(objOppo.Id);
                }              
            }
        }
        Debug.log('setOpportunityIds:'+setOpportunityIds);
        if(setOpportunityIds.size() > 0){
            lstOpportunity = new List<Opportunity>([SELECT Id, Name, Primary_Member__c, Primary_Member__r.UUID__c, Account.Id, Billing_Account__c, Building_uuid__c, Billing_Account__r.UUID__c,LastModifiedDate FROM Opportunity WHERE Id IN : setOpportunityIds order BY LastModifiedDate DESC]);
        }
        Debug.log('lstOpportunity==>'+lstOpportunity);
        Debug.log('setHoldsWithNoOpp==>'+setHoldsWithNoOpp);
        Debug.log('mapContactsAndBillAccountsWithUUID==>'+mapContactsAndBillAccountsWithUUID);
        if(lstOpportunity != null && lstOpportunity.size() > 0){
            for(Opportunity objOpportunity : lstOpportunity){
                if(String.isNotBlank(objOpportunity.Primary_Member__c) && String.isNotBlank(objOpportunity.Primary_Member__r.UUID__c) && String.isNotBlank(objOpportunity.Building_uuid__c)){
                    if(mapOppWithBuildingUUIDAndContactUUID.get(objOpportunity.Primary_Member__r.UUID__c + ';'+objOpportunity.Building_uuid__c) != null && mapOppWithBuildingUUIDAndContactUUID.get(objOpportunity.Primary_Member__r.UUID__c + ';'+objOpportunity.Building_uuid__c).size() > 0){
                        List<Opportunity> lstTempOpportunity = mapOppWithBuildingUUIDAndContactUUID.get(objOpportunity.Primary_Member__r.UUID__c + ';'+objOpportunity.Building_uuid__c);
                        lstTempOpportunity.add(objOpportunity);
                        mapOppWithBuildingUUIDAndContactUUID.put(objOpportunity.Primary_Member__r.UUID__c + ';'+objOpportunity.Building_uuid__c, lstTempOpportunity);
                    }else{
                        mapOppWithBuildingUUIDAndContactUUID.put(objOpportunity.Primary_Member__r.UUID__c + ';'+objOpportunity.Building_uuid__c,new List<Opportunity>{objOpportunity});
                    }
                }
                if(String.isNotBlank(objOpportunity.Primary_Member__c) && String.isNotBlank(objOpportunity.Primary_Member__r.UUID__c)){
                    if(mapOppWithUUIDs.get(objOpportunity.Primary_Member__r.UUID__c) != null && mapOppWithUUIDs.get(objOpportunity.Primary_Member__r.UUID__c).size() > 0){
                        List<Opportunity> lstTempOpportunity = mapOppWithUUIDs.get(objOpportunity.Primary_Member__r.UUID__c);
                        lstTempOpportunity.add(objOpportunity);
                        mapOppWithUUIDs.put(objOpportunity.Primary_Member__r.UUID__c,lstTempOpportunity);
                    }else{
                        mapOppWithUUIDs.put(objOpportunity.Primary_Member__r.UUID__c,new List<Opportunity>{objOpportunity});
                    }
                }
                if(String.isNotBlank(objOpportunity.Building_uuid__c)){
                    if(mapOppWithUUIDs.get(objOpportunity.Building_uuid__c) != null && mapOppWithUUIDs.get(objOpportunity.Building_uuid__c).size() > 0){
                        List<Opportunity> lstTempOpportunity = mapOppWithUUIDs.get(objOpportunity.Building_uuid__c);
                        lstTempOpportunity.add(objOpportunity);
                        mapOppWithUUIDs.put(objOpportunity.Building_uuid__c,lstTempOpportunity);
                    }else{
                        mapOppWithUUIDs.put(objOpportunity.Building_uuid__c,new List<Opportunity>{objOpportunity});
                    }
                }
                if(String.isNotBlank(objOpportunity.Billing_Account__c) && String.isNotBlank(objOpportunity.Billing_Account__r.UUID__c) && setBillingAccountsToMap.contains(objOpportunity.Billing_Account__r.UUID__c)){
                    if(mapOppWithUUIDs.get(objOpportunity.Billing_Account__r.UUID__c) != null && mapOppWithUUIDs.get(objOpportunity.Billing_Account__r.UUID__c).size() > 0){
                        List<Opportunity> lstTempOpportunity = mapOppWithUUIDs.get(objOpportunity.Billing_Account__r.UUID__c);
                        lstTempOpportunity.add(objOpportunity);
                        mapOppWithUUIDs.put(objOpportunity.Billing_Account__r.UUID__c,lstTempOpportunity);
                    }else{
                        mapOppWithUUIDs.put(objOpportunity.Billing_Account__r.UUID__c,new List<Opportunity>{objOpportunity});
                    }
                }
            }  
        }
        
        Debug.log('mapOppWithUUIDs =>'+mapOppWithUUIDs);
        Debug.log('mapOppWithBuildingUUIDAndContactUUID =>'+mapOppWithBuildingUUIDAndContactUUID);
        Map<String, Opportunity> mapOpportunitiesToCreate = new Map<String, Opportunity>();
        for(Reservable_Hold__c objReservableHold :  listNewItems){
            if(!mapContactsAndBillAccountsWithUUID.containsKey(objReservableHold.Contact_UUID__c)){
                objReservableHold.Contact_UUID__c.addError('Contact with uuid '+objReservableHold.Contact_UUID__c +' is not present in the system.');
            }
            /*if(String.isNotBlank(objReservableHold.Company_UUID__c) && !mapContactsAndBillAccountsWithUUID.containsKey(objReservableHold.Company_UUID__c)){
                objReservableHold.Company_UUID__c.addError('Billing Account with uuid '+objReservableHold.Company_UUID__c +' is not present in the system.');
            }*/
            if(String.isNotBlank(objReservableHold.Opportunity__c)){
                if(objReservableHold.Approval_Status__c == 'Hold'){
                    objReservableHold.Opportunity_For_Related_List__c = objReservableHold.Opportunity__c;
                }
                objReservableHold.Account__c = (mapOppWithUUIDs.get(objReservableHold.Contact_UUID__c) != null && mapOppWithUUIDs.get(objReservableHold.Contact_UUID__c).size() > 0)? mapOppWithUUIDs.get(objReservableHold.Contact_UUID__c)[0].Account.Id : null;
            }
            if(mapReservablesWithUUIDs.containsKey(objReservableHold.reservable_uuid__c) && mapReservablesWithUUIDs.get(objReservableHold.reservable_uuid__c) != null){
                objReservableHold.Reservable__c = mapReservablesWithUUIDs.get(objReservableHold.reservable_uuid__c).Id;
                if(objReservableHold.Approval_Status__c == 'Hold'){
                    objReservableHold.Reservable_For_Related_List__c = mapReservablesWithUUIDs.get(objReservableHold.reservable_uuid__c).Id;
                }
            }else{
                objReservableHold.reservable_uuid__c.addError('Reservable with uuid '+objReservableHold.reservable_uuid__c +' is not present in the system. Please contact with the administrator.');    
            }  
            if(mapContactsAndBillAccountsWithUUID.containsKey(objReservableHold.Contact_UUID__c) && mapContactsAndBillAccountsWithUUID.get(objReservableHold.Contact_UUID__c) != null){
               objReservableHold.Contact__c = (Id)mapContactsAndBillAccountsWithUUID.get(objReservableHold.Contact_UUID__c).get('Id');
            }
            if(objReservableHold.Company_UUID__c != null && mapContactsAndBillAccountsWithUUID.get(objReservableHold.Company_UUID__c) != null){
                objReservableHold.Billing_Account__c = (Id)mapContactsAndBillAccountsWithUUID.get(objReservableHold.Company_UUID__c).get('Id');
                if(objReservableHold.Opportunity__c == null){
                    if(mapOppWithUUIDs.get(objReservableHold.Company_UUID__c) != null && mapOppWithUUIDs.get(objReservableHold.Company_UUID__c).size() > 0){
                        objReservableHold.Opportunity__c = mapOppWithUUIDs.get(objReservableHold.Company_UUID__c)[0].Id;
                        if(objReservableHold.Approval_Status__c == 'Hold'){
                            objReservableHold.Opportunity_For_Related_List__c = mapOppWithUUIDs.get(objReservableHold.Company_UUID__c)[0].Id;
                        }
                        objReservableHold.Account__c = mapOppWithUUIDs.get(objReservableHold.Company_UUID__c)[0].Account.Id;
                    }else{
                        Opportunity newOpportunityToCreate = createOpportunityForHold(mapContactsAndBillAccountsWithUUID, mapReservablesWithUUIDs, objReservableHold); 
                        if(String.isBlank(newOpportunityToCreate.AccountId) && String.isBlank(newOpportunityToCreate.Billing_Account__c)){
                            objReservableHold.Billing_Account__c.addError('Billing Account not found');
                            objReservableHold.Account__c.addError('Org Account not found');
                        }else{   
                            mapOpportunitiesToCreate.put(objReservableHold.Company_UUID__c, newOpportunityToCreate); 
                        }
                    } 
                }
            }
            if(objReservableHold.Contact_UUID__c != null && objReservableHold.Opportunity__c == null && !mapOpportunitiesToCreate.containsKey(objReservableHold.Company_UUID__c) && mapContactsAndBillAccountsWithUUID.containsKey(objReservableHold.Contact_UUID__c)){
                if(mapReservablesWithUUIDs.containsKey(objReservableHold.reservable_uuid__c) && mapReservablesWithUUIDs.get(objReservableHold.reservable_uuid__c) != null && mapReservablesWithUUIDs.get(objReservableHold.reservable_uuid__c).Building_UUID__c != null && mapOppWithBuildingUUIDAndContactUUID.containsKey(objReservableHold.Contact_UUID__c +';'+mapReservablesWithUUIDs.get(objReservableHold.reservable_uuid__c).Building_UUID__c)){
                    objReservableHold.Opportunity__c = mapOppWithBuildingUUIDAndContactUUID.get(objReservableHold.Contact_UUID__c +';'+mapReservablesWithUUIDs.get(objReservableHold.reservable_uuid__c).Building_UUID__c)[0].Id;
                    if(objReservableHold.Approval_Status__c == 'Hold'){
                        objReservableHold.Opportunity_For_Related_List__c = mapOppWithBuildingUUIDAndContactUUID.get(objReservableHold.Contact_UUID__c +';'+mapReservablesWithUUIDs.get(objReservableHold.reservable_uuid__c).Building_UUID__c)[0].Id;
                    }
                    objReservableHold.Account__c =mapOppWithBuildingUUIDAndContactUUID.get(objReservableHold.Contact_UUID__c +';'+mapReservablesWithUUIDs.get(objReservableHold.reservable_uuid__c).Building_UUID__c)[0].Account.Id;
                }else if(mapOppWithUUIDs.containsKey(objReservableHold.Contact_UUID__c)){
                    objReservableHold.Opportunity__c = mapOppWithUUIDs.get(objReservableHold.Contact_UUID__c)[0].Id;
                    if(objReservableHold.Approval_Status__c == 'Hold'){
                        objReservableHold.Opportunity_For_Related_List__c = mapOppWithUUIDs.get(objReservableHold.Contact_UUID__c)[0].Id;
                    }
                    objReservableHold.Account__c = mapOppWithUUIDs.get(objReservableHold.Contact_UUID__c)[0].Account.Id;
                }else if(mapReservablesWithUUIDs.get(objReservableHold.reservable_uuid__c) != null && mapReservablesWithUUIDs.get(objReservableHold.reservable_uuid__c).Building_UUID__c != null && mapOppWithUUIDs.containsKey(mapReservablesWithUUIDs.get(objReservableHold.reservable_uuid__c).Building_UUID__c)){
                    objReservableHold.Opportunity__c = mapOppWithUUIDs.get(mapReservablesWithUUIDs.get(objReservableHold.reservable_uuid__c).Building_UUID__c)[0].Id;
                    if(objReservableHold.Approval_Status__c == 'Hold'){
                        objReservableHold.Opportunity_For_Related_List__c = mapOppWithUUIDs.get(mapReservablesWithUUIDs.get(objReservableHold.reservable_uuid__c).Building_UUID__c)[0].Id;
                    }
                    objReservableHold.Account__c = mapOppWithUUIDs.get(mapReservablesWithUUIDs.get(objReservableHold.reservable_uuid__c).Building_UUID__c)[0].Account.Id;
                }else if(lstOpportunity != null && lstOpportunity.size() > 0){
                    objReservableHold.Opportunity__c = lstOpportunity[0].Id;
                    if(objReservableHold.Approval_Status__c == 'Hold'){
                        objReservableHold.Opportunity_For_Related_List__c = lstOpportunity[0].Id;
                    }
                    objReservableHold.Account__c = lstOpportunity[0].Account.Id;
                }else{
                    Opportunity newOpportunityToCreate = createOpportunityForHold(mapContactsAndBillAccountsWithUUID, mapReservablesWithUUIDs, objReservableHold); 
                    if(String.isBlank(newOpportunityToCreate.AccountId) && String.isBlank(newOpportunityToCreate.Billing_Account__c)){
                        objReservableHold.Billing_Account__c.addError('Billing Account not found');
                        objReservableHold.Account__c.addError('Org Account not found');
                    }else{
                        mapOpportunitiesToCreate.put(objReservableHold.Contact_UUID__c, newOpportunityToCreate);  
                    }
                }
            }
        }
        if(!mapOpportunitiesToCreate.isEmpty()){
            insert mapOpportunitiesToCreate.values();
            for(Reservable_Hold__c objReservableHold :  listNewItems){
                if(mapOpportunitiesToCreate.containsKey(objReservableHold.Company_UUID__c)){                   
                    objReservableHold.Opportunity__c = mapOpportunitiesToCreate.get(objReservableHold.Company_UUID__c).Id;
                    objReservableHold.Account__c = mapOpportunitiesToCreate.get(objReservableHold.Company_UUID__c).AccountId;
                    if(objReservableHold.Approval_Status__c != null && objReservableHold.Approval_Status__c == 'Hold'){
                        objReservableHold.Opportunity_For_Related_List__c = mapOpportunitiesToCreate.get(objReservableHold.Company_UUID__c).Id;
                    }
                }else if(mapOpportunitiesToCreate.containsKey(objReservableHold.Contact_UUID__c)){                   
                    objReservableHold.Opportunity__c = mapOpportunitiesToCreate.get(objReservableHold.Contact_UUID__c).Id;
                    objReservableHold.Account__c = mapOpportunitiesToCreate.get(objReservableHold.Contact_UUID__c).AccountId;
                    if(objReservableHold.Approval_Status__c != null && objReservableHold.Approval_Status__c == 'Hold'){
                        objReservableHold.Opportunity_For_Related_List__c = mapOpportunitiesToCreate.get(objReservableHold.Contact_UUID__c).Id;
                    }
                }
                
            }           
            
        } 
    }
    
    private static Opportunity createOpportunityForHold(Map<String,sObject> mapContactsAndBillAccountsWithUUID, Map<String, Reservable__c> mapReservablesWithUUIDs, Reservable_Hold__c objReservableHold){
        Map<String, String> mapOppFieldsWithValues = new Map<String,String>{'StageName'=>'Selling'};
        Map<String, Set<String>> mapOppPickListValues = new Map<String, Set<String>>();
        if(mapReservablesWithUUIDs.containsKey(objReservableHold.reservable_uuid__c) && mapReservablesWithUUIDs.get(objReservableHold.reservable_uuid__c).Building_UUID__c != null){
            mapOppPickListValues.put('Locations_Interested__c',new set<String>{mapReservablesWithUUIDs.get(objReservableHold.reservable_uuid__c).Building__r.Name});
            mapOppFieldsWithValues.put('Type__c','Hold');
            mapOppFieldsWithValues.put('Building__c',(mapReservablesWithUUIDs.get(objReservableHold.reservable_uuid__c) != null) ? mapReservablesWithUUIDs.get(objReservableHold.reservable_uuid__c).Building__c : null);
        }
        if(String.isNotBlank(objReservableHold.Company_UUID__c)){
            mapOppFieldsWithValues.put('billingAccountUUID', (mapContactsAndBillAccountsWithUUID.get(objReservableHold.Company_UUID__c) != null) ? (Id)mapContactsAndBillAccountsWithUUID.get(objReservableHold.Company_UUID__c).get('Id') : null);
            mapOppFieldsWithValues.put('AccountUUID', (mapContactsAndBillAccountsWithUUID.get(objReservableHold.Company_UUID__c) != null) ? (Id)mapContactsAndBillAccountsWithUUID.get(objReservableHold.Company_UUID__c).get('Parent_Account__c') : null);
        }
        if(mapContactsAndBillAccountsWithUUID.get(objReservableHold.Contact_UUID__c) != null && mapOppFieldsWithValues.get('AccountUUID') == null){
            Contact contact = (Contact)mapContactsAndBillAccountsWithUUID.get(objReservableHold.Contact_UUID__c);
            mapOppFieldsWithValues.put('AccountUUID', (mapContactsAndBillAccountsWithUUID.get(objReservableHold.Contact_UUID__c) != null && mapContactsAndBillAccountsWithUUID.get(objReservableHold.Contact_UUID__c).get('AccountId') != null) ? contact.AccountId : null);
        }
        mapOppFieldsWithValues.put('Name', 'Opportunity For Hold');
        return OpportunityHelper.createOpportunityWithFieldValues(mapOppFieldsWithValues,mapOppPickListValues);
    }
    
    /************************************************************************************************************************************
            Author              :   Shobhit Gahlot
            Description         :   This method sets restricts the opportunity to be nullified when an upsert is performed from SAPI on hold off
            Last Modified Date  :   05th Dec, 2017
            Last Modified By    :   Shobhit Gahlot
    **************************************************************************************************************************************/
    public static void setOpportunity(List<SObject> listNewItems , Map<Id, SObject> mapOldItems) {
        if(TriggerSettings.mappedField.ReservableHold_setOpportunity){
        	for (Reservable_Hold__c obj : (List<Reservable_Hold__c>)listNewItems) {
            	Map<Id, Reservable_Hold__c> oldObjMap = new Map<Id, Reservable_Hold__c>();
        		oldObjMap = (Map<Id, Reservable_Hold__c>)mapOldItems;
            	debug.log('oldObjMap.get(obj.Id).Approval_Status__c :: '+oldObjMap.get(obj.Id).Approval_Status__c );
            	debug.log('obj.Approval_Status__c :: '+obj.Approval_Status__c );         
            	if(oldObjMap.get(obj.Id).Opportunity__c != null)
                	obj.Opportunity__c = oldObjMap.get(obj.Id).Opportunity__c;
                if(oldObjMap.get(obj.Id).Opportunity_For_Related_List__c == null && obj.Approval_Status__c == 'Hold'){
                    obj.Opportunity_For_Related_List__c = oldObjMap.get(obj.Id).Opportunity__c;
                }
                if(oldObjMap.get(obj.Id).Reservable_For_Related_List__c == null && obj.Approval_Status__c == 'Hold'){
                    obj.Reservable_For_Related_List__c= oldObjMap.get(obj.Id).Reservable__c;
                }
        	}
        }
    }
  
    /************************************************************************************************************************************
            Author              :   Samadhan Kadam
            Description         :   CSI-512 This method is used to send email alerts to Opportunity owner,Team member,Community Lead, Building Responsible CM, Building Regional Sales Manager, Building Territory Sales Manager, 
           							 Building Cluster Sales Manager, Building Cluster Sales Lead,Building Portfolio Sales Manager when Reservable Hold record is created and 
            						we send reminder email after 21 days to same people if hold record is still on hold.  
            Last Modified Date  :   26 Feb 2018
            Last Modified By    :   Samadhan Kadam
    **************************************************************************************************************************************/
    public static void sendHoldEmailAlerts(List<SObject> listNewItems,Map<Id, SObject> mapOldItems){
        if(TriggerSettings.mappedField.ReservableHold_sendHoldEmailAlerts){
            Map<Id, Id> mapHoldOppIds = new Map<Id, Id>();
            Map<Id, Id> mapHoldReservableIds = new Map<Id, Id>();
            Map<Id, Opportunity> mapHoldRelatedOpps;
            Map<Id, Reservable__c> mapHoldReservables;
            Map<Id, string> mapHoldReservablesReleasedStatus = new Map<Id, string>();
            Map<Id, string> mapHoldReservablesExpiredStatus = new Map<Id, string>();
            Map<Id, string> mapHoldReservablesHoldStatus = new Map<Id, string>();
            Map<Id, boolean> mapHoldReservableReminder = new Map<Id, boolean>();
            Map<Id, Opportunity> mapReservablesOpportunity = new Map<Id, Opportunity>();
            Set< String> setOppTeamRoles = new Set<String>();//{'rep', 'split rep', 'member success manager'};
            Set<String> setEmailTemplateNames = new Set<String>{'Reservable Hold','Reservable Hold Reminder','Email Notification After Hold Released','Reservable Hold Expired','Hold Reminder After 21 Days'};
            Map<String, EmailTemplate> mapEmailTemplates = new Map<String, EmailTemplate>();
            List<Messaging.SingleEmailMessage> lstSingleMail = new List<Messaging.SingleEmailMessage>(); 
            Map<Id, Set<String>> mapHoldRelatedEmails = new Map<Id, Set<String>>();
            Set<String> setEmailsToSend;
            if(!setEmailTemplateNames.isEmpty()){
                for(EmailTemplate template : [SELECT Id, Name FROM EmailTemplate WHERE Name IN : setEmailTemplateNames]){
                    mapEmailTemplates.put(template.Name.toLowerCase(), template);
                }
            }
            
            for(Reservable_Hold__c resHoldRec : (List<Reservable_Hold__c>)listNewItems){
                if((mapOldItems == null && resHoldRec.Opportunity__c != null && resHoldRec.Reservable__c != null) && resHoldRec.Approval_Status__c == 'Hold') { 
                    mapHoldOppIds.put(resHoldRec.Id, resHoldRec.Opportunity__c);
                    mapHoldReservableIds.put(resHoldRec.Id, resHoldRec.Reservable__c);
                } else if((mapOldItems != null && resHoldRec.Opportunity__c != null && resHoldRec.Reservable__c != null) && (resHoldRec.Send_Reminder_Alert__c || resHoldRec.Approval_Status__c == 'Expired' || resHoldRec.Approval_Status__c == 'Released' || resHoldRec.Approval_Status__c == 'Hold' || resHoldRec.Reminder_After_21_Days__c)) {
                    Map<Id, Reservable_Hold__c> oldObjMap = new Map<Id, Reservable_Hold__c>();
                    oldObjMap = (Map<Id, Reservable_Hold__c>)mapOldItems;
                    Reservable_Hold__c oldResHoldRec = oldObjMap.get(resHoldRec.Id);
                    if(oldResHoldRec != null && oldResHoldRec.Approval_Status__c != resHoldRec.Approval_Status__c &&  resHoldRec.Approval_Status__c == 'Hold'){
                        mapHoldOppIds.put(resHoldRec.Id, resHoldRec.Opportunity__c);
                        mapHoldReservableIds.put(resHoldRec.Id, resHoldRec.Reservable__c);
                        mapHoldReservablesHoldStatus.put(resHoldRec.Id, resHoldRec.Approval_Status__c);
                    }
                    if(oldResHoldRec != null && oldResHoldRec.Send_Reminder_Alert__c != resHoldRec.Send_Reminder_Alert__c &&  resHoldRec.Send_Reminder_Alert__c){
                        mapHoldOppIds.put(resHoldRec.Id, resHoldRec.Opportunity__c);
                        mapHoldReservableIds.put(resHoldRec.Id, resHoldRec.Reservable__c);
                    }
					if(oldResHoldRec != null && oldResHoldRec.Approval_Status__c != resHoldRec.Approval_Status__c && resHoldRec.Approval_Status__c == 'Released'){
                        mapHoldOppIds.put(resHoldRec.Id, resHoldRec.Opportunity__c);
                        mapHoldReservableIds.put(resHoldRec.Id, resHoldRec.Reservable__c);
                        mapHoldReservablesReleasedStatus.put(resHoldRec.Id, resHoldRec.Approval_Status__c);
                    }
                    if(oldResHoldRec != null && oldResHoldRec.Approval_Status__c != resHoldRec.Approval_Status__c && resHoldRec.Approval_Status__c == 'Expired'){
                        mapHoldOppIds.put(resHoldRec.Id, resHoldRec.Opportunity__c);
                        mapHoldReservableIds.put(resHoldRec.Id, resHoldRec.Reservable__c);
                        mapHoldReservablesExpiredStatus.put(resHoldRec.Id, resHoldRec.Approval_Status__c);
                    }
                    if(oldResHoldRec != null && oldResHoldRec.Reminder_After_21_Days__c != resHoldRec.Reminder_After_21_Days__c && resHoldRec.Reminder_After_21_Days__c){
                        mapHoldOppIds.put(resHoldRec.Id, resHoldRec.Opportunity__c);
                        mapHoldReservableIds.put(resHoldRec.Id, resHoldRec.Reservable__c);
                        mapHoldReservableReminder.put(resHoldRec.Id, resHoldRec.Reminder_After_21_Days__c);
                    }                    
                }
            }
            
            if(!mapHoldOppIds.isEmpty() && !mapHoldReservableIds.isEmpty()){
                mapHoldRelatedOpps = new Map<Id, Opportunity>([SELECT Id, OwnerId, Owner.Email, (SELECT Id, OpportunityId, UserId, User.Email, TeamMemberRole FROM OpportunityTeamMembers ) FROM Opportunity WHERE Id IN :mapHoldOppIds.values()]);
                mapHoldReservables = new Map<Id, Reservable__c>([SELECT Id, Building__r.Community_Lead__r.Email, Building__r.Responsible_CM__r.Email, Building__r.Regional_Sales_Manager_Email__c, Building__r.Territory_Sales_Manager_Email__c, Building__r.Cluster_Sales_Manager_Email__c, Building__r.Cluster_Sales_Lead_Email__c, Building__r.Portfolio_Sales_Manager_Email__c FROM Reservable__c WHERE Id IN : mapHoldReservableIds.values()]);
                Setting__c holdReservableSetting = Settings.get('HoldReservableSettings'); 
                HoldReservableController.HoldReservableSettings holdReservableSettings = (HoldReservableController.HoldReservableSettings)JSON.deserialize(holdReservableSetting.Data__c, HoldReservableController.HoldReservableSettings.class);
                Debug.log('mapHoldRelatedOpps ==>'+mapHoldRelatedOpps);
                for(Reservable_Hold__c resHoldRec : (List<Reservable_Hold__c>)listNewItems){
                    if(resHoldRec.Opportunity__c != null && resHoldRec.Reservable__c != null) { 
                        setEmailsToSend = new Set<String>();
                        if(mapHoldRelatedOpps != null && mapHoldRelatedOpps.containsKey(resHoldRec.Opportunity__c) && mapHoldRelatedOpps.get(resHoldRec.Opportunity__c) != null){
                            if(mapHoldRelatedOpps.get(resHoldRec.Opportunity__c).OpportunityTeamMembers != null && mapHoldRelatedOpps.get(resHoldRec.Opportunity__c).OpportunityTeamMembers.size() > 0){
                                for(OpportunityTeamMember oppTeamMember : mapHoldRelatedOpps.get(resHoldRec.Opportunity__c).OpportunityTeamMembers){
                                    if(oppTeamMember.TeamMemberRole=='Rep' || oppTeamMember.TeamMemberRole=='Split Rep' || oppTeamMember.TeamMemberRole.contains('Member Success'))
                                        setEmailsToSend.add(String.valueOf(oppTeamMember.User.Email));
                                }
                            }
                            Reservable__c reservableRec = (Reservable__c)mapHoldReservables.get(resHoldRec.Reservable__c);
                            Debug.log('reservableRec ==>'+reservableRec);
                            if(resHoldRec.Opportunity__c != null && mapHoldRelatedOpps.get(resHoldRec.Opportunity__c).Owner.Email != null)
                                setEmailsToSend.add(mapHoldRelatedOpps.get(resHoldRec.Opportunity__c).Owner.Email);
                            //Modified by Samadhan kadam for CSI-673 
                            // setEmailsToSend.add(String.valueOf(reservableRec.Building__r.Community_Lead__r.Email));
                            // setEmailsToSend.add(String.valueOf(reservableRec.Building__r.Responsible_CM__r.Email));
                            // setEmailsToSend.add(String.valueOf(reservableRec.Building__r.Regional_Sales_Manager_Email__c));
                            // setEmailsToSend.add(String.valueOf(reservableRec.Building__r.Territory_Sales_Manager_Email__c));
                            setEmailsToSend.add(String.valueOf(reservableRec.Building__r.Cluster_Sales_Manager_Email__c));
                            setEmailsToSend.add(String.valueOf(reservableRec.Building__r.Cluster_Sales_Lead_Email__c));
                            // setEmailsToSend.add(String.valueOf(reservableRec.Building__r.Portfolio_Sales_Manager_Email__c));
                            mapReservablesOpportunity.put(resHoldRec.Id, mapHoldRelatedOpps.get(resHoldRec.Opportunity__c));
                            mapHoldRelatedEmails.put(resHoldRec.Id, setEmailsToSend);
                        }
                        Debug.log('holdReservableSettings.EmailsForAlerts ::'+holdReservableSettings);
                        Debug.log('setEmailsToSend Before setting::'+setEmailsToSend);
                        
                        if(holdReservableSettings != null && holdReservableSettings.EmailsForAlerts != null && holdReservableSettings.EmailsForAlerts.size() > 0){
                            for(String strEmail : holdReservableSettings.EmailsForAlerts){
                                setEmailsToSend.add(strEmail.toLowerCase());
                            }
                            mapHoldRelatedEmails.put(resHoldRec.Id, setEmailsToSend);
                        }
                        
                    }
                    Debug.log('setEmailsToSend After setting::'+setEmailsToSend);
                }
                Debug.log('mapHoldRelatedEmails ==>'+mapHoldRelatedEmails);
                if(!mapHoldRelatedEmails.isEmpty()){
                    Messaging.SingleEmailMessage objSingleMail; 
                    Set<String> setEmails;
                    List<String> lstEmails;
                    List<String> lstSingleEmails;
                    for(Id recordId : mapHoldRelatedEmails.keySet()){
                        setEmails = new Set<String>();
                        lstEmails = new List<String>();
                        if(mapHoldRelatedEmails.containsKey(recordId)){
                            setEmails.addAll(mapHoldRelatedEmails.get(recordId));
                        }
                        Debug.log('setEmails Email ::==> '+setEmails);
                        setEmails.remove(null);
                        lstEmails.addAll(setEmails);
                        Debug.log('List Email ::==> '+lstEmails);
                        Debug.log('mapReservablesOpportunity ::==> '+mapReservablesOpportunity);
                        for(String email : lstEmails){
                            objSingleMail = new Messaging.SingleEmailMessage();
                            lstSingleEmails = new List<String>();
                            Debug.log('mapReservablesOpportunity ::'+mapReservablesOpportunity);
                            if(mapReservablesOpportunity.containsKey(recordId) && mapReservablesOpportunity.get(recordId).OwnerId != null){
                                objSingleMail.setTargetObjectId(mapReservablesOpportunity.get(recordId).OwnerId);
                                objSingleMail.setWhatId(recordId);
                                if(mapOldItems != null){
                                    if(mapHoldReservablesReleasedStatus.containsKey(recordId) && mapHoldReservablesReleasedStatus.get(recordId) == 'Released'){
                                        objSingleMail.setTemplateId(mapEmailTemplates.get('email notification after hold released').Id);
                                    }else if(mapHoldReservablesExpiredStatus.containsKey(recordId) && mapHoldReservablesExpiredStatus.get(recordId) == 'Expired'){
                                        objSingleMail.setTemplateId(mapEmailTemplates.get('reservable hold expired').Id);
                                    }
                                    else if(mapHoldReservableReminder.containsKey(recordId) && mapHoldReservableReminder.get(recordId) == true){
                                        objSingleMail.setTemplateId(mapEmailTemplates.get('hold reminder after 21 days').Id);
                                    } 
                                    else if(mapHoldReservablesHoldStatus.containsKey(recordId) && mapHoldReservablesHoldStatus.get(recordId) == 'Hold'){
                                        objSingleMail.setTemplateId(mapEmailTemplates.get('reservable hold').Id);
                                    }                                
                                    else{
                                        objSingleMail.setTemplateId(mapEmailTemplates.get('reservable hold reminder').Id);
                                    }
                                }else if(mapOldItems == null){
                                    objSingleMail.setTemplateId(mapEmailTemplates.get('reservable hold').Id); 
                                }     
                                lstSingleEmails.add(email);
                                objSingleMail.setTreatTargetObjectAsRecipient(false);
                                objSingleMail.toAddresses = lstSingleEmails;
                                objSingleMail.setSaveAsActivity(false);
                                lstSingleMail.add(objSingleMail);
                                Debug.log('lstSingleMail Emails ::==> '+lstSingleEmails);
                            }
                        }
                    }
                } 
                Messaging.sendEmail(lstSingleMail);
            }
        } 
    }
}