/**
* Name			:	ContractEventCreateOppUtility	 
* Issue No.		: 	CSI-492 
* Purpose		:	This is used to create new oppotunity in contract event for all events.
* History		
	Version			Author				Date			Detail						Feature			IssueNumber
	1.0				Mayuresh Ghodke		1/1/2018		Initial Development
	2.0				Shobhit Gahlot		9/1/2018		Payload structure Change	Sellable		CSI-441
***********************************************************************************************************************************************************
*/ 
public class ContractEventCreateOppUtility { 
    //Create new Opportunity we do not found any opportunity from opportunity_id and membership_agreement_uuid.
    public static String createNewOpportunity(WWTypes.ContractEvent objContractEvent, ContractEventUtilities.UtilityWapper objUtilityWapper){
        Debug.log('objUtilityWapper :: '+objUtilityWapper);
        ContractEventPayloadMapping.OpportunityFieldsWrapper objOpportunityFieldsWrapper = ContractEventPayloadMapping.mapPayloadWithOpportunityFields(objContractEvent, objUtilityWapper);
        //Debug.log(''objOpportunityFieldsWrapper.mapOppFields.get(''));
        //Create new Opportunity by Opportunity Insert Endpoint
                
        Billing_Account__c objBillingAccount = ContractEventAccountHandler.createOrReuseBillingAccount(objContractEvent.company_uuid, objContractEvent.primary_member_email, objUtilityWapper.mapContactsMembers);
        
        Opportunity newCreatedOpp = OpportunityHelper.createOpportunityWithFieldValues(objOpportunityFieldsWrapper.mapOppFields, objOpportunityFieldsWrapper.mapOppMultiPickListFields);
        newCreatedOpp.Name = 'Inbound cloned opportunity';
        if(String.isBlank(newCreatedOpp.StageName)){//For contract discard and voided this will make it closing. 
            newCreatedOpp.StageName = 'Closing';
        }
        
        newCreatedOpp.Billing_Account__c = objBillingAccount.Id;
        if(objBillingAccount.Parent_Account__c != null){
            newCreatedOpp.AccountId = objBillingAccount.Parent_Account__c;
        }else{
            //ST-2680 for hotdesks billing acconts created directly from website so map all the fields
            Id OrgId = (String.isNotBlank(objContractEvent.reservation_uuid))? ContractEventAccountHandler.getOrgAccountOrCreate(objUtilityWapper.mapContactsMembers,true):ContractEventAccountHandler.getOrgAccountOrCreate(objUtilityWapper.mapContactsMembers,false);
            if(OrgId != null){
                newCreatedOpp.AccountId =  OrgId;
                Billing_Account__c objBillingAccountToUpdateParent = new Billing_Account__c();
                objBillingAccountToUpdateParent.Id = objBillingAccount.Id;
                objBillingAccountToUpdateParent.Parent_Account__c = OrgId;
                update objBillingAccountToUpdateParent;
                sObject objContact = ContractEventAccountHandler.contactUsedForOrgFinding(objUtilityWapper.mapContactsMembers);
                if(String.isBlank(String.valueOf(objContact.get('AccountId'))) && OrgId != null){
                    Contact contactToUpdate = new Contact();
                    contactToUpdate.Id = (Id)objContact.get('Id');
                    contactToUpdate.AccountId = OrgId;
                    Debug.log('objContact getOrgAccountOrCreate ::'+objContact);
                    update contactToUpdate;
                }
            }else{
                throw new ContractEventCreateOppUtilityException('Organization Account not found for the opportunity.');
            }
        }
		
        sobject objContact, objAccount;
        debug.log('objUtilityWrapper.mapContactsMembers.ge.get:::'+objUtilityWapper.mapContactsMembers.get('Contact').get('PrimaryMemberEmailInContact'));
        if(objUtilityWapper.mapContactsMembers.get('Contact') != null && objUtilityWapper.mapContactsMembers.get('Contact').get('PrimaryMemberEmailInContact') != null){
            objContact = objUtilityWapper.mapContactsMembers.get('Contact').get('PrimaryMemberEmailInContact');
            if(newCreatedOpp.Primary_Member__c == null){
                newCreatedOpp.Primary_Member__c = objUtilityWapper.mapContactsMembers.get('Contact').get('PrimaryMemberEmailInContact').Id;
            }
        }  
        
        Debug.log('Before creation fields newCreatedOpp : '+newCreatedOpp);
        insert newCreatedOpp;
        Debug.log('After creation fields newCreatedOpp : '+newCreatedOpp);
        Debug.log('Limits.getQueries() in createNewOpportunity 01::'+Limits.getQueries());        
        
        if(newCreatedOpp.Id != null){
            //CSI-525
            ContractEventDiscountsHandler.insertNewDiscounts(objContractEvent, objUtilityWapper, new List<Discount__c>{},newCreatedOpp.Id);
            ContractEventProductsHandler.createNewProducts(objContractEvent, objUtilityWapper, newCreatedOpp.Id);
            
            Debug.log('Limits.getQueries() in createNewOpportunity 02::'+Limits.getQueries());
            //CSI-525
            ContractEventCommitmentHandler.addCommitmentTermsOnOpportunity(objContractEvent, objUtilityWapper,newCreatedOpp.Id);
            Debug.log('Limits.getQueries() in createNewOpportunity 02.0::'+Limits.getQueries());
            ContractEventMoveInsHandler.createOpportunityReservables(objContractEvent, objUtilityWapper, null, newCreatedOpp.Id);
            Debug.log('Limits.getQueries() in createNewOpportunity 02.1::'+Limits.getQueries());
            //Create Opportunity_Move_Outs__c with Reservable and Opportunity
            ContractEventMoveOutsHandler.createOpportunityMoveOuts(objContractEvent, objUtilityWapper, null, newCreatedOpp.Id);
            Debug.log('Limits.getQueries() in createNewOpportunity 02.2::'+Limits.getQueries());
            debug.log('Updating Status : objUtilityWapper.setPayloadReservableUuid.size() :: '+objUtilityWapper.setPayloadReservableUuid);
            Opportunity createdOpp = new Opportunity();
			
            if(objContractEvent.event_name.toLowerCase() != 'contract sent'){
                if(objContractEvent.event_name.toLowerCase() == 'contract signed'){
                    ContractEventPayloadMapping.OpportunityFieldsWrapper objOpportunityFieldsWrapperForUpdate = ContractEventSignedVoidedDiscarded.contractSignedOpportunityMapping(objContractEvent, objUtilityWapper, new ContractEventPayloadMapping.OpportunityFieldsWrapper());
                    createdOpp = OpportunityHelper.createOpportunityWithFieldValues(objOpportunityFieldsWrapperForUpdate.mapOppFields, objOpportunityFieldsWrapperForUpdate.mapOppMultiPickListFields);
                    createdOpp.Id = newCreatedOpp.Id;
                    Id OwnerId;
                    if(!String.isBlank(objContractEvent.reservation_uuid)){
                        objAccount = ContractEventHotDesk.checkAndCreateAccountObject(null, objBillingAccount);
                        ContractEventHotDesk.updateLeadSourceOnContactAndAccount(new List<Sobject>{objContact, objAccount}, objContractEvent);
                        OwnerId = ContractEventHotDesk.hotDeskHandlingOfOppOwner(objContractEvent, objUtilityWapper);
                        if(OwnerId != null){
                            createdOpp.OwnerId =  OwnerId;
                        }
                    }
                }else if(objContractEvent.event_name.toLowerCase() == 'contract canceled' && String.isBlank(objContractEvent.reservation_uuid)){
                    createdOpp.Id = newCreatedOpp.Id;
                    createdOpp = ContractEventCancel.mapContractCancelFieldsToOpportunity(newCreatedOpp, objContractEvent);
                }else if(objContractEvent.event_name.toLowerCase() == 'contract canceled' && String.isNotBlank(objContractEvent.reservation_uuid)){
                    createdOpp = ContractEventHotDesk.hotDeskCancellationNewOpportunity(objContractEvent, objUtilityWapper);
                    createdOpp.put('Id',newCreatedOpp.Id);
                    createdOpp.Contract_Stage__c = objContractEvent.event_name;
                }else if(objContractEvent.event_name.toLowerCase() == 'contract discarded' || objContractEvent.event_name.toLowerCase() == 'contract voided'){
                    createdOpp.Id = newCreatedOpp.Id;
                    //CSI-358 changes made by shobhit
                    createdOpp.StageName = 'Closing';
                    createdOpp.Contract_Stage__c = objContractEvent.event_name;
                    //CSI-411 changes made by shobhit
                    createdOpp.Contract_Voided_Discarded_On_Date__c = (objContractEvent.contract_date != null && objContractEvent.contract_date != '') ? Date.valueOf(objContractEvent.contract_date) : Date.today();
                }
                debug.log('Updating Status :: '+createdOpp);
            }
            //If only Move out comes in the payload then also we will keep Opportunity as Closing for Contract Send
            //As when that contract comes back with Contract Signed that time we will make that contract as Close Lost
            //As per the discussion With Parag & Yaron & Mayuresh
            //Date 11th Sept'17 
            //So below code commented
            //if(objUtilityWapper.setPayloadReservableUuid.size()==0){
            // createdOpp.StageName = 'Closed Lost';
            //}
            Debug.log('Limits.getQueries() in createNewOpportunity 03::'+Limits.getQueries());
            Debug.log('createdOpp Before update new opp ::'+createdOpp);
            if(createdOpp.Id != null){
              update createdOpp;  
            }
            return newCreatedOpp.Id;
        }
        else{
            return 'Something went wrong please contact to your administrator.';
        }
    }
    public class ContractEventCreateOppUtilityException extends Exception{}
    
}