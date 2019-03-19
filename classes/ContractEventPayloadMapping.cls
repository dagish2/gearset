/**
* Name			:	ContractEventPayloadMapping	 
* Issue No.		: 	ST-2520 
* Purpose		:	This is contains the logic for mapping the contract payload with opportunity fields.
* History		
	Version			Author				Date			Detail						Feature			IssueNumber
	1.0				Shobhit Gahlot	   11/6/2018		Initial Development
***********************************************************************************************************************************************************
*/ 
public class ContractEventPayloadMapping {
    
    public static OpportunityFieldsWrapper mapPayloadWithOpportunityFields(WWTypes.ContractEvent objContractEvent, ContractEventUtilities.UtilityWapper objUtilityWapper){
        OpportunityFieldsWrapper objOpportunityFieldsWrapper = new OpportunityFieldsWrapper();
        if(objUtilityWapper.opportunityBuildingUUID  != null){
            if(objUtilityWapper.mapAllPayloadBuildings.get(objUtilityWapper.opportunityBuildingUUID) != null){
                objOpportunityFieldsWrapper.mapOppFields.put('Building__c',objUtilityWapper.mapAllPayloadBuildings.get(objUtilityWapper.opportunityBuildingUUID).Id);
            }else{
                throw new ContractEventPayloadMappingException('Can\'t locate building by UUID '+objUtilityWapper.opportunityBuildingUUID);
            }
        }
        //Map Move Out Building with Opportunity it will be Move_outs's 1st building
        if(objUtilityWapper.opportunityBuildingMoveOutUUID != null){
            if(objUtilityWapper.mapAllPayloadBuildings.get(objUtilityWapper.opportunityBuildingMoveOutUUID) != null){
                objOpportunityFieldsWrapper.mapOppFields.put('Move_Out_Building__c', objUtilityWapper.mapAllPayloadBuildings.get(objUtilityWapper.opportunityBuildingMoveOutUUID).Id);
            }else{
                throw new ContractEventPayloadMappingException('Can\'t locate building by UUID '+objUtilityWapper.opportunityBuildingMoveOutUUID);
            }
        }
        objOpportunityFieldsWrapper.mapOppFields.put('billingAccountUUID',objContractEvent.company_uuid);
        objOpportunityFieldsWrapper.mapOppFields.put('Community_Manager_UUID__c',objContractEvent.community_manager_uuid);
      	objOpportunityFieldsWrapper.mapOppFields.put('Actual_Start_Date__c',String.ValueOf(objUtilityWapper.latestDate));
      	objOpportunityFieldsWrapper.mapOppFields.put('Reservation_UUID__c',objContractEvent.reservation_uuid);
        objOpportunityFieldsWrapper.mapOppFields.put('Contract_UUID__c',objContractEvent.membership_agreement_uuid);
        //ST-2223 Remove Mapping of Contract Type to Opportunity Type and make it dependent on opportunity Line item 
        //mapOppFields.put('Type__c','Office Space');
        objOpportunityFieldsWrapper.mapOppFields.put('CurrencyIsoCode',objContractEvent.currencyVal);
        objOpportunityFieldsWrapper.mapOppFields.put('Contract_Type__c',objContractEvent.transfer_type);
        
        objOpportunityFieldsWrapper.mapOppFields.put('LeadSource',objContractEvent.lead_source);//CSI-1545
        objOpportunityFieldsWrapper.mapOppFields.put('Lead_Source_Detail__c',objContractEvent.lead_source_detail);//CSI-1545
        
        objOpportunityFieldsWrapper.mapOppFields.put('Old_Opportunity__c',objUtilityWapper.fromOpp);
        objOpportunityFieldsWrapper.mapOppFields.put('Contract_Pdf__c',String.isNotBlank(objContractEvent.contract_pdf)?objContractEvent.contract_pdf.replace(',',', '):null);
        objOpportunityFieldsWrapper.mapOppFields.put('Community_Manager_UUID__c',objContractEvent.community_manager_uuid);
        objOpportunityFieldsWrapper.mapOppFields.put('Downgrade_Reason__c',objContractEvent.downgrade_reason);
        objOpportunityFieldsWrapper.mapOppFields.put('Downgrade_Notes__c',objContractEvent.downgrade_notes);
        //CSI-553
        objOpportunityFieldsWrapper.mapOppFields.put('Contract_Expiration__c',objContractEvent.contract_expires_at);
        //CSI-553
        if(objUtilityWapper.CommitmentTermInMonthsForopp != null){
          objOpportunityFieldsWrapper.mapOppFields.put('Commitment_Term_in_months__c',String.ValueOf(objUtilityWapper.CommitmentTermInMonthsForopp));  
        }else{
           objOpportunityFieldsWrapper.mapOppFields.put('Commitment_Term_in_months__c','1.0');  
        }
        if(String.isNotBlank(objContractEvent.community_manager_uuid)){
            objOpportunityFieldsWrapper.mapOppFields.put('Community_Manager_UUID__c',objContractEvent.community_manager_uuid);
        }
        //If Payload contains community_manager_uuid and Current Opportunity's Community_Manager_UUID__c is null then update that value
        if(objUtilityWapper.mapContactsMembers.get('Contact') != null && objUtilityWapper.mapContactsMembers.get('Contact').get('CommunityManagerUUIDInContact') != null){
            objOpportunityFieldsWrapper.mapOppFields.put('Community_User__c',objUtilityWapper.mapContactsMembers.get('Contact').get('CommunityManagerUUIDInContact').Id);
            if(objContractEvent.event_name.toLowerCase() == 'contract sent'){
                objOpportunityFieldsWrapper.mapOppFields.put('Send_Paperwork_By__c',objUtilityWapper.mapContactsMembers.get('Contact').get('CommunityManagerUUIDInContact').Id);              
            }
        }
        
        Debug.log('objUtilityWapper.opportunityBuildingMoveOutUUID Create::'+objUtilityWapper.opportunityBuildingMoveOutUUID );
        Debug.log('objUtilityWapper.mapAllPayloadBuildings Create::'+objUtilityWapper.mapAllPayloadBuildings.get(objUtilityWapper.opportunityBuildingMoveOutUUID));
        Set<String> setpickListValues = new Set<String>();
        if(objUtilityWapper.lstBuilding.size() > 0){
            for(Building__c obj : objUtilityWapper.lstBuilding){
                setpickListValues.add(obj.Name);
            }
        }
        if(objContractEvent.event_name.toLowerCase() == 'contract sent'){
            objOpportunityFieldsWrapper.mapOppFields.put('Contract_Stage__c','Contract Sent');
            objOpportunityFieldsWrapper.mapOppFields.put('StageName','Closing');
            objOpportunityFieldsWrapper.mapOppFields.put('Paperwork_Sent_On_Date__c',(String.isNotBlank(objContractEvent.contract_date)) ? objContractEvent.contract_date : String.valueOf(Date.today()));
        }
        Debug.log('mapPayloadWithOpportunityFields setpickListValues::'+setpickListValues);
        objOpportunityFieldsWrapper.mapOppMultiPickListFields.put('Locations_Interested__c',setpickListValues);
        return objOpportunityFieldsWrapper;
    }
    public class OpportunityFieldsWrapper{
        public Map<String, String> mapOppFields = new Map<String, String>();
        public Map<String, Set<String>> mapOppMultiPickListFields = new Map<String, Set<String>>();
    }
    public class ContractEventPayloadMappingException extends Exception{}
}