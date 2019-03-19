/**
* Name			:	ContractEventHotDesk	 
* Issue No.		: 	CSI-492 
* Purpose		:	This is contains the logic for Contract Event HotDesk.
* History		
	Version			Author				Date			Detail						Feature			IssueNumber
	1.0				Mayuresh Ghodke		1/1/2018		Initial Development
	2.0				Shobhit Gahlot		9/1/2018		Payload structure Change	Sellable		CSI-441
***********************************************************************************************************************************************************
*/ 
public class ContractEventHotDesk {
    /*
    Issue No.   : ST-1389
    Created By  : Mayuresh Ghodke
    Date    : 25 Sept'17
    Comment   : Synch Hotdesk Opportunity
    */
    public static String hotDesk(WWTypes.ContractEvent objContractEvent, ContractEventUtilities.UtilityWapper objUtilityWrapper){

        if(objUtilityWrapper.oppToUse != null){
            //Opportunity should be open and Payload shloud cointains reservable_uuids            
            Billing_Account__c objBillingAccount;
            if(objUtilityWrapper.oppToUse.Billing_Account__c == null){
                objBillingAccount = ContractEventAccountHandler.createOrReuseBillingAccount(objContractEvent.company_uuid, objContractEvent.primary_member_email, objUtilityWrapper.mapContactsMembers);
            }
            if(objBillingAccount != null){
                objUtilityWrapper.objOpp.Billing_Account__c = objBillingAccount.Id;
                if(objBillingAccount.Parent_Account__c != null){
                    objUtilityWrapper.objOpp.AccountId = objBillingAccount.Parent_Account__c;
                }
            }
            ContractEventPayloadMapping.OpportunityFieldsWrapper objOpportunityFieldsWrapper = ContractEventPayloadMapping.mapPayloadWithOpportunityFields(objContractEvent, objUtilityWrapper);
            objOpportunityFieldsWrapper.mapOppFields.put('StageName' ,'Closed Won'); 
            objOpportunityFieldsWrapper.mapOppFields.put('Contract_Signed_On_Date__c' , (String.isNotBlank(objContractEvent.contract_date)) ? objContractEvent.contract_date : String.valueOf(Date.today()));
            objOpportunityFieldsWrapper.mapOppFields.put('Contract_Stage__c', 'Contract Signed');
            if(objOpportunityFieldsWrapper.mapOppMultiPickListFields.get('Locations_Interested__c') != null && objOpportunityFieldsWrapper.mapOppMultiPickListFields.get('Locations_Interested__c').size() > 0 && String.isNotBlank(objUtilityWrapper.oppToUse.Locations_Interested__c)){
               objOpportunityFieldsWrapper.mapOppMultiPickListFields.put('Locations_Interested__c',OpportunityHelper.getUniquePickListValues(objUtilityWrapper.oppToUse.Locations_Interested__c, objOpportunityFieldsWrapper.mapOppMultiPickListFields.get('Locations_Interested__c')));
            }
            sobject objContact, objAccount;
            if(objUtilityWrapper.mapContactsMembers!= null && objUtilityWrapper.mapContactsMembers.get('Contact') != null && objUtilityWrapper.mapContactsMembers.get('Contact').get('PrimaryMemberEmailInContact') != null){
                objContact = objUtilityWrapper.mapContactsMembers.get('Contact').get('PrimaryMemberEmailInContact');
                if(objUtilityWrapper.oppToUse.Primary_Member__c == null)
                    objUtilityWrapper.objOpp.Primary_Member__c = objContact.Id;
            }
            debug.log('objContact=='+objContact);
            objAccount = checkAndCreateAccountObject(objUtilityWrapper.oppToUse, null);
            
            objUtilityWrapper.objOpp = OpportunityHelper.createOpportunityWithFieldValues(objOpportunityFieldsWrapper.mapOppFields,objOpportunityFieldsWrapper.mapOppMultiPickListFields);
            objUtilityWrapper.objOpp.Id = objUtilityWrapper.oppToUse.Id;
            
            updateLeadSourceOnContactAndAccount(new List<Sobject>{objContact, objAccount}, objContractEvent);
            
            User objUser = Settings.getUserById(objUtilityWrapper.oppToUse.OwnerId);
            if(objUser.Id == '005F0000003Kmbw' || objUser.Profile.Name != 'WeWork NMD User'){
                Id OwnerId = hotDeskHandlingOfOppOwner(objContractEvent, objUtilityWrapper);
                if(OwnerId != null){
                  objUtilityWrapper.objOpp.OwnerId =  OwnerId;
                }
            }
            //Update Opportunity Product, Update Opportunity Reservables, Update Opportunity MoveOuts
            String result = ContractEventUpdateOppUtility.updateOpportunityRelatedObjects(objContractEvent, objUtilityWrapper);
            return ContractEventUtilities.getResult(result, false);
        }else{
            //Create New Opportunity
            String result = ContractEventCreateOppUtility.createNewOpportunity(objContractEvent,objUtilityWrapper);
            return ContractEventUtilities.getResult(result, true);
        }
    }

    public static Id hotDeskHandlingOfOppOwner(WWTypes.ContractEvent objContractEvent, ContractEventUtilities.UtilityWapper objUtilityWrapper){
        Id ownerId;
        if(!String.isBlank(objContractEvent.reservation_uuid)){
            Debug.log('String.isBlank(objContractEvent.reservation_uuid) : '+String.isBlank(objContractEvent.reservation_uuid));
            Building__c buildingForCM = objUtilityWrapper.mapAllPayloadBuildings.get(objUtilityWrapper.opportunityBuildingUUID);
            if(buildingForCM != null && buildingForCM.Responsible_CM__c != null && Settings.getUserActive(buildingForCM.Responsible_CM__c)){
                ownerId= buildingForCM.Responsible_CM__c;
            }else if(buildingForCM != null  && objUtilityWrapper.objContractEventUtilitySetting != null && objUtilityWrapper.objContractEventUtilitySetting.ActiveOwnerId != null){
                if((objUtilityWrapper.objContractEventUtilitySetting.ActiveOwnerId.length() == 15 || objUtilityWrapper.objContractEventUtilitySetting.ActiveOwnerId.length() == 18) && Pattern.matches('^[a-zA-Z0-9]*$', objUtilityWrapper.objContractEventUtilitySetting.ActiveOwnerId))
                    ownerId =  objUtilityWrapper.objContractEventUtilitySetting.ActiveOwnerId;
            }
            Debug.log('hotDeskHandlingOfOppOwner : '+ownerId);                        
        }
        return ownerId;
    }
    
    public Static string hotDeskCancellation(WWTypes.ContractEvent objContractEvent, ContractEventUtilities.UtilityWapper objUtilityWrapper){
        
        Debug.log('ContractEvent : Update objUtilityWrapper.oppToUse  From reservation_uuid : '+objUtilityWrapper.oppToUse );
        if(objUtilityWrapper.oppToUse != null){
            objUtilityWrapper.udpateOpp = true;
            Billing_Account__c objBillingAccount;
            if(objUtilityWrapper.oppToUse.Billing_Account__c == null){
                objBillingAccount = ContractEventAccountHandler.createOrReuseBillingAccount(objContractEvent.company_uuid, objContractEvent.primary_member_email, objUtilityWrapper.mapContactsMembers);
            }
            if(objBillingAccount != null){
                objUtilityWrapper.objOpp.Billing_Account__c = objBillingAccount.Id;
                if(objBillingAccount.Parent_Account__c != null){
                    objUtilityWrapper.objOpp.AccountId = objBillingAccount.Parent_Account__c;
                }
            }
            ContractEventPayloadMapping.OpportunityFieldsWrapper objOpportunityFieldsWrapper = ContractEventPayloadMapping.mapPayloadWithOpportunityFields(objContractEvent, objUtilityWrapper);
            objUtilityWrapper.objOpp.Id = objUtilityWrapper.oppToUse.Id;
            objOpportunityFieldsWrapper.mapOppFields.put('StageName', 'Closed Lost');
            objOpportunityFieldsWrapper.mapOppFields.put('Lost_Reason__c',objUtilityWrapper.mapCloseLostReason.get('contract canceled'));
            objOpportunityFieldsWrapper.mapOppFields.put('Contract_Stage__c' ,'Contract Canceled');
            objOpportunityFieldsWrapper.mapOppFields.put('Reservation_UUID__c' ,objContractEvent.reservation_uuid);
            objUtilityWrapper.objOpp = OpportunityHelper.createOpportunityWithFieldValues(objOpportunityFieldsWrapper.mapOppFields,objOpportunityFieldsWrapper.mapOppMultiPickListFields);
            objUtilityWrapper.objOpp.Id = objUtilityWrapper.oppToUse.Id;
            //CSI-411 changes made by shobhit
            objUtilityWrapper.objOpp.Contract_Canceled_On_Date__c = (objContractEvent.contract_date != null && objContractEvent.contract_date != '') ? Date.valueOf(objContractEvent.contract_date) : Date.today();
            //Update Opportunity Product, Update Opportunity Reservables, Update Opportunity MoveOuts
            String result = ContractEventUpdateOppUtility.updateOpportunityRelatedObjects(objContractEvent, objUtilityWrapper);
            return ContractEventUtilities.getResult(result, false);
        }else{
            String result = ContractEventCreateOppUtility.createNewOpportunity(objContractEvent,objUtilityWrapper);
            return ContractEventUtilities.getResult(result, true);
        }
        //we do not have to send an error as per the SS team's requirement. ST-1428 and CSI-267
        return 'Update Opportunity : ';
    }
        
    
    
    public Static Opportunity hotDeskCancellationNewOpportunity(WWTypes.ContractEvent objContractEvent, ContractEventUtilities.UtilityWapper objUtilityWrapper){
        Opportunity createdOpp = new Opportunity();
        if(String.isNotBlank(objContractEvent.reservation_uuid)){//HotDesk Cancellation
            List<Opportunity> lstOpportunity = [SELECT Id, OwnerId FROM opportunity WHERE Reservation_UUID__c =: objContractEvent.reservation_uuid AND Contract_Stage__c = 'Contract Signed'];
            if(lstOpportunity.Size() > 0){
                objUtilityWrapper.oppToUse = lstOpportunity[0];
                createdOpp.Old_Opportunity__c = objUtilityWrapper.oppToUse.Id;
                if(objUtilityWrapper.oppToUse.OwnerId != null){
                    if(Settings.getUserActive(objUtilityWrapper.oppToUse.OwnerId)){
                        createdOpp.OwnerId = objUtilityWrapper.oppToUse.OwnerId;
                    }else{
                        if((objUtilityWrapper.objContractEventUtilitySetting.ActiveOwnerId.length() == 15 || objUtilityWrapper.objContractEventUtilitySetting.ActiveOwnerId.length() == 18) && Pattern.matches('^[a-zA-Z0-9]*$', objUtilityWrapper.objContractEventUtilitySetting.ActiveOwnerId))
                            createdOpp.OwnerId =  objUtilityWrapper.objContractEventUtilitySetting.ActiveOwnerId;
                    }
                } 
            }
            //CSI-411 changes made by shobhit
            createdOpp.Contract_Canceled_On_Date__c = (objContractEvent.contract_date != null && objContractEvent.contract_date != '') ? Date.valueOf(objContractEvent.contract_date) : Date.today();
            createdOpp.StageName = 'Closed Lost';
            createdOpp.Lost_Reason__c = objUtilityWrapper.mapCloseLostReason.get('hot desk contract canceled new opportunity');
        }
        return createdOpp;
    }
   /************************************************************************************************************************************
            Author              :   samadhan Kadam
            Description         :   ST-3428 This method used to map lead source and lead source detail for contract hot desk event
            Last Modified Date  :   10 Feb 2019
            Last Modified By    :   Samadhan Kadam
    **************************************************************************************************************************************/
    public static void updateLeadSourceOnContactAndAccount(List<sObject> lstObjectsToUpdate, WWTypes.ContractEvent objContractEvent){
        debug.log('lstObjectsToUpdate::'+lstObjectsToUpdate);
        if(lstObjectsToUpdate.size() > 0 && (String.isNotBlank(objContractEvent.lead_source) || String.isNotBlank(objContractEvent.lead_source_detail))){
            Map<String, String> mapContactFields = new Map<String, String>{'Lead_Source_Detail__c'=>'lead_Source_detail', 'LeadSource'=>'lead_source'};
            Map<String, String> mapAccountFields = new Map<String, String>{'Lead_Source__c'=>'lead_source'};
            Map<String, String> mapobjectPayloadmapping = new Map<String, String>{'Lead_Source_Detail__c'=>objContractEvent.lead_source_detail, 'LeadSource'=>objContractEvent.lead_source, 'Lead_Source__c'=>objContractEvent.lead_source};
            List<sobject> lstContactOrAccountToUpdate = new List<sobject>();
            String objectId;
            Boolean IdExistsForObject;
            for(sobject objectToupdate: lstObjectsToUpdate){
                if(objectToupdate != null){
                    objectId = String.valueOf(objectToupdate.Id);
                    if(String.isNotBlank(objectId)){
                        if(objectId.startsWith('003')){
                            checkObjectToupdate(objectToupdate, mapContactFields, lstContactOrAccountToUpdate, mapobjectPayloadmapping);
                        }else{
                            checkObjectToupdate(objectToupdate, mapAccountFields, lstContactOrAccountToUpdate, mapobjectPayloadmapping);
                        }
                    }
                }
            }
            Debug.log('updateLeadSourceOnContactAndAccount lstObjectsToUpdate==>'+lstContactOrAccountToUpdate);
            if(lstContactOrAccountToUpdate.size() > 0){
                update lstContactOrAccountToUpdate;
            }
        }
    }
    ////ST-3428 Used for mapping lead source and lead source detail for contract hot desk event
    public static void checkObjectToupdate(sobject objectToupdate, Map<String, String> mapFields, List<sobject> lstContactOrAccountToUpdate, Map<String, String> mapobjectPayloadmapping){
        Debug.log('checkObjectToupdate=='+objectToupdate);
        Boolean updateFlag = false;
        for(string field : mapFields.keyset()){
            if( String.isBlank(String.valueOf(objectToupdate.get(field))) && String.isnotBlank(mapobjectPayloadmapping.get(field))){
                objectToupdate.put(field, mapobjectPayloadmapping.get(field));
                updateFlag = true;
            }
        }
        if(updateFlag){
            lstContactOrAccountToUpdate.add(objectToupdate); 
        }
    }
    //ST-3428 Used for mapping lead source and lead source detail for contract hot desk event
    public static Account checkAndCreateAccountObject(Opportunity objOpportunity, Billing_Account__c billingAccount){
        Account objAccount = new Account();
        if(objOpportunity != null){
            objAccount.Id = objOpportunity.AccountId;
            objAccount.Lead_Source__c = objOpportunity.Account.Lead_Source__c;
        }else{
            objAccount.Id = billingAccount.Parent_Account__c;
            objAccount.Lead_Source__c = billingAccount.Parent_Account__r.Lead_Source__c;
        }
        return objAccount;
    }
}