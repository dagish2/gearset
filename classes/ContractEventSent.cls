/**
* Name			:	ContractEventSent	 
* Issue No.		: 	CSI-492 
* Purpose		:	This is contains the logic for Contract Sent.
* History		
	Version			Author				Date			Detail						Feature			IssueNumber
	1.0				Mayuresh Ghodke		1/1/2018		Initial Development
	2.0				Shobhit Gahlot		9/1/2018		Payload structure Change	Sellable		CSI-441
//Modified By: Mayuresh Ghodke, Issue No:ST-1359, Date:29/08/2017, Comment: update contract uuid with new uuid received in payload for a closing opportunity with contract discarded stage
***********************************************************************************************************************************************************
*/ 
public class ContractEventSent {
    public static String contractSent(WWTypes.ContractEvent objContractEvent, ContractEventUtilities.UtilityWapper objUtilityWapper){

        //If any opportunity found then Update that Opportunity. Else Create new Opportunity.
        debug.log('objUtilityWapper.oppToUse ::'+objUtilityWapper.oppToUse);
        if(objUtilityWapper.oppToUse != null){
            Billing_Account__c objBillingAccount;
            if(objUtilityWapper.oppToUse.Billing_Account__c == null){
                objBillingAccount = ContractEventAccountHandler.createOrReuseBillingAccount(objContractEvent.company_uuid, objContractEvent.primary_member_email, objUtilityWapper.mapContactsMembers);
            }
            objUtilityWapper.udpateOpp = true;
            //Opportunity should be open and Payload should cointain reservable_uuids
            if(objUtilityWapper.setPayloadReservableUuid != null){
                ContractEventPayloadMapping.OpportunityFieldsWrapper objOpportunityFieldsWrapper = ContractEventPayloadMapping.mapPayloadWithOpportunityFields(objContractEvent, objUtilityWapper);
                if(objOpportunityFieldsWrapper.mapOppMultiPickListFields.get('Locations_Interested__c') != null && objOpportunityFieldsWrapper.mapOppMultiPickListFields.get('Locations_Interested__c').size() > 0 && String.isNotBlank(objUtilityWapper.oppToUse.Locations_Interested__c)){
                    objOpportunityFieldsWrapper.mapOppMultiPickListFields.put('Locations_Interested__c',OpportunityHelper.getUniquePickListValues(objUtilityWapper.oppToUse.Locations_Interested__c, objOpportunityFieldsWrapper.mapOppMultiPickListFields.get('Locations_Interested__c')));
                }
                if(String.isNotBlank(objUtilityWapper.objOpp.StageName) && String.isNotBlank(objUtilityWapper.objOpp.Original_Contract_UUID__c)){
                    objUtilityWapper.objOpp  = OpportunityHelper.createOpportunityWithFieldValues(objOpportunityFieldsWrapper.mapOppFields, objOpportunityFieldsWrapper.mapOppMultiPickListFields);
                    //CSI-534 now closed won opp will be updated so Stagname will also be updated as per discussion with Vidu, vaibhav
                    objUtilityWapper.objOpp.put('StageName','Closing');
                    objUtilityWapper.objOpp.put('Original_Contract_UUID__c',objUtilityWapper.oppToUse.Contract_UUID__c);
                }else{
                    objUtilityWapper.objOpp = OpportunityHelper.createOpportunityWithFieldValues(objOpportunityFieldsWrapper.mapOppFields, objOpportunityFieldsWrapper.mapOppMultiPickListFields);
                }
                objUtilityWapper.objOpp.Id = objUtilityWapper.oppToUse.Id;
                if(objBillingAccount != null){
                    objUtilityWapper.objOpp.Billing_Account__c = objBillingAccount.Id;
                }
                Debug.log('objUtilityWapper.objOpp.Contract_UUID__c in contract sent : '+objUtilityWapper.objOpp.Contract_UUID__c);
                
                objUtilityWapper.objOpp.Contract_UUID__c = objContractEvent.membership_agreement_uuid;
                if(objUtilityWapper.oppToUse.Primary_Member__c == null && objUtilityWapper.mapContactsMembers!= null && objUtilityWapper.mapContactsMembers.get('Contact') != null && objUtilityWapper.mapContactsMembers.get('Contact').get('PrimaryMemberEmailInContact') != null){
                    objUtilityWapper.objOpp.Primary_Member__c = objUtilityWapper.mapContactsMembers.get('Contact').get('PrimaryMemberEmailInContact').Id;
                }
                //If current opportunities record type id Consumer then only change StageName sholud change to Closing
                //ST-2078 Stage will be Closing for all recordtypes in case of contract sent as pointed out by Rachell during account heirarchy deployment
                //if(objUtilityWapper.oppToUse.RecordType.Name == 'Consumer')
                objUtilityWapper.objOpp.StageName ='Closing';
                objUtilityWapper.objOpp.Contract_Stage__c ='Contract Sent';
                //Modified By: Mayuresh Ghodke, Date: 29/12/2017, Issue No. :CSI-467, Comment: Apex: Don't Update the Close Date of the opportunity when the contract is sent.
                //objUtilityWapper.objOpp.CloseDate=system.today();
                //CSI-411 old field Contract_Sent_Date__c will not be update as per discussion with parag also Paperwork_Sent_On_c datetime field will not be used
                objUtilityWapper.objOpp.Paperwork_Sent_On_Date__c = (objContractEvent.contract_date != null && objContractEvent.contract_date != '') ? Date.valueOf(objContractEvent.contract_date) : Date.today();
                
                //ST-2223 Only opportunity Line items will decide the oppotunity type
                //if( objContractEvent.transfer_type != 'New Business')
                //   objUtilityWapper.objOpp.Type__c = 'Internal Transfer';
                if(!String.isBlank(objContractEvent.original_contract_uuid)){
                    objUtilityWapper.objOpp.Original_Contract_UUID__c = objContractEvent.original_contract_uuid;
                }
                //Update Opportunity Reservables, Opportunity MoveOuts,Opportunity Product
                String result = ContractEventUpdateOppUtility.updateOpportunityRelatedObjects(objContractEvent, objUtilityWapper);
                return ContractEventUtilities.getResult(result, false);
            }else{
                return 'objContractEvent.reservable_uuids is required field for API';
            }
        }else{
            debug.log('Opportunity to update not found in contract sent');
            //Create New Opportunity
            String result = ContractEventCreateOppUtility.createNewOpportunity(objContractEvent,objUtilityWapper);                       
            return ContractEventUtilities.getResult(result, true);
        }
    }
}