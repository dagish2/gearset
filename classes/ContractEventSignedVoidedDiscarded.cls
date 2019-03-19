/**
* Name			:	ContractEventSignedVoidedDiscarded	 
* Issue No.		: 	CSI-492 
* Purpose		:	This is contains the logic for Contract Signed, Contract Voided and Contract Discarded events.
* History		
Version			Author				Date			Detail						Feature			IssueNumber
1.0				Mayuresh Ghodke		1/1/2018		Initial Development
2.0				Shobhit Gahlot		9/1/2018		Payload structure Change	Sellable		CSI-441
***********************************************************************************************************************************************************
*/ 
public class ContractEventSignedVoidedDiscarded {
    public static String contractSignedVoidedDiscarded(WWTypes.ContractEvent objContractEvent, ContractEventUtilities.UtilityWapper objUtilityWapper){
        Debug.log('ContractEvent : In Else : '+objContractEvent.event_name);
        Debug.log('Before objUtilityWapper.oppToUse ====>'+objUtilityWapper.oppToUse);      
        if(objUtilityWapper.oppToUse != null){
            Debug.log('Before objUtilityWapper.objOpp ====>'+objUtilityWapper.objOpp);
            objUtilityWapper.udpateOpp = true;
            //CSI-545 : due to change in search critiria now for contract signed, voided, discarded contract uuid will be updated with membeshipagreement uuid
            //          previously it was updated only if the contract uuid of the fetched opportunity is blank
            Billing_Account__c objBillingAccount;
            if(objUtilityWapper.oppToUse.Billing_Account__c == null){
                objBillingAccount = ContractEventAccountHandler.createOrReuseBillingAccount(objContractEvent.company_uuid, objContractEvent.primary_member_email, objUtilityWapper.mapContactsMembers);
            }
            if(objBillingAccount != null){
                objUtilityWapper.objOpp.Billing_Account__c = objBillingAccount.Id;
                if(objBillingAccount.Parent_Account__c != null){
                    objUtilityWapper.objOpp.AccountId = objBillingAccount.Parent_Account__c;
                }
            }
            objUtilityWapper.objOpp.Contract_UUID__c = objContractEvent.membership_agreement_uuid;
            if(!String.isBlank(objContractEvent.original_contract_uuid)){
                objUtilityWapper.objOpp.Original_Contract_UUID__c = objContractEvent.original_contract_uuid;
            }  
            objUtilityWapper.objOpp.Contract_Stage__c =objContractEvent.event_name;
            Debug.log('objContractEvent.contract_pdf : '+objContractEvent.contract_pdf);
            objUtilityWapper.objOpp.Contract_Pdf__c = (objContractEvent.contract_pdf != null && objContractEvent.contract_pdf != '') ? objContractEvent.contract_pdf.replace(',',', ') : objContractEvent.contract_pdf;
            ContractEventPayloadMapping.OpportunityFieldsWrapper objOpportunityFieldsWrapper = ContractEventPayloadMapping.mapPayloadWithOpportunityFields(objContractEvent, objUtilityWapper);
            if(objContractEvent.event_name.toLowerCase() == 'contract signed'){
                objOpportunityFieldsWrapper = contractSignedOpportunityMapping(objContractEvent, objUtilityWapper, objOpportunityFieldsWrapper);
                objUtilityWapper.objOpp = OpportunityHelper.createOpportunityWithFieldValues(objOpportunityFieldsWrapper.mapOppFields,objOpportunityFieldsWrapper.mapOppMultiPickListFields);
                objUtilityWapper.objOpp.Id = objUtilityWapper.oppToUse.Id;
                String result = ContractEventUpdateOppUtility.updateOpportunityRelatedObjects(objContractEvent, objUtilityWapper);
                Debug.log('ContractEvent : result updateOpportunityRelatedObjects : '+result);
                return ContractEventUtilities.getResult(result, false);
            }else if(objContractEvent.event_name.toLowerCase() == 'contract voided' || objContractEvent.event_name.toLowerCase() == 'contract discarded'){
                objUtilityWapper.objOpp.Id = objUtilityWapper.oppToUse.Id;
                if(String.isNotBlank(objContractEvent.lead_source)){
                    objUtilityWapper.objOpp.LeadSource = objContractEvent.lead_source;
                }
                if(String.isNotBlank(objContractEvent.lead_source_detail)){
                    objUtilityWapper.objOpp.Lead_Source_Detail__c = objContractEvent.lead_source_detail;
                }
                //CSI-358 changes made by shobhit
                objUtilityWapper.objOpp.StageName = 'Closing';
                //CSI-411 changes made by shobhit
                objUtilityWapper.objOpp.Contract_Voided_Discarded_On_Date__c = (objContractEvent.contract_date != null && objContractEvent.contract_date != '') ? Date.valueOf(objContractEvent.contract_date) : Date.today();
                update objUtilityWapper.objOpp;
                Debug.log('contract voided Or contract discarded opportunity: '+objUtilityWapper.objOpp);
                return ContractEventUtilities.getResult(objUtilityWapper.objOpp.Id, false);
            }else{
                return 'Something went wrong please contact to your administrator.';
            }   
        }else{
            //return 'Opportunity for given opportunity_id or membership_agreement_uuid not found hence can not be updated.';
            //Create New Opportunity
            String result = ContractEventCreateOppUtility.createNewOpportunity(objContractEvent,objUtilityWapper);
            return ContractEventUtilities.getResult(result, true); 
        }
    }
    
    public static ContractEventPayloadMapping.OpportunityFieldsWrapper contractSignedOpportunityMapping(WWTypes.ContractEvent objContractEvent, ContractEventUtilities.UtilityWapper objUtilityWapper, ContractEventPayloadMapping.OpportunityFieldsWrapper objOpportunityFieldsWrapper){
        //If only Move out comes in the payload then also we will keep Opportunity as Closing for Contract Send
        //As when that contract comes back with Contract Signed that time we will make that contract as Close Lost
        //As per the discussion With Parag & Yaron & Mayuresh
        //Date 11th Sept'17 
        Debug.Log('objUtilityWapper.setPayloadReservableUuid.size() :: '+objUtilityWapper.setPayloadReservableUuid.size());
        Debug.Log('objUtilityWapper.setMoveOutPayloadReservableUuid.Size() ContractEventSignedVoidedDiscarded :: '+objUtilityWapper.setMoveOutPayloadReservableUuid.Size());
        objOpportunityFieldsWrapper.mapOppFields.put('CloseDate',(String.isNotBlank(objContractEvent.contract_date)) ? objContractEvent.contract_date : String.valueOf(Date.today()));
        //CSI-411 changes made by shobhit
        objOpportunityFieldsWrapper.mapOppFields.put('Contract_Signed_On_Date__c',(String.isNotBlank(objContractEvent.contract_date)) ? objContractEvent.contract_date : String.valueOf(Date.today()));
        objOpportunityFieldsWrapper.mapOppFields.put('Contract_Stage__c','Contract Signed'); // New Line by Parag
        if(objUtilityWapper.setPayloadReservableUuid.size()==0 && objUtilityWapper.setMoveOutPayloadReservableUuid.Size() > 0){
            objOpportunityFieldsWrapper.mapOppFields.put('StageName','Closed Lost');//downgrade event only move out. for sellable both moveout and movein are empty
            objOpportunityFieldsWrapper.mapOppFields.put('Lost_Reason__c',objUtilityWapper.mapCloseLostReason.get('contract signed downgrade event'));
            Debug.log('Selected Opp Stage test: '+objUtilityWapper.objOpp.StageName);
            objOpportunityFieldsWrapper.mapOppFields.put('Move_outs_Closed_Lost__c', 'false');
        }else{
            objOpportunityFieldsWrapper.mapOppFields.put('StageName','Closed Won');
            
        }
        return objOpportunityFieldsWrapper;
    }
    public class ContractEventSignedVoidedDiscardedException extends Exception {}
}