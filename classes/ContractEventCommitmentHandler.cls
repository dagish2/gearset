/**
* Name			:	ContractEventCommitmentHandler	 
* Issue No.		: 	CSI-715 
* Purpose		:	This is used to update and create Commitment Terms in contract event for all events.
* History		
Version			Author				Date			Detail						Feature			IssueNumber
1.0				Shobhit Gahlot		21/03/2018		Initial Development
***********************************************************************************************************************************************************
*/ 
public class ContractEventCommitmentHandler {

    //CSI-525 CommitmentTerms in months calculation for opportunity
    public Static Decimal calculateCommitmentTermsInMonth(WWTypes.ContractEvent objContractEvent, Map<String,List<WWTypes.products>> mapProducsWithBuilding, Decimal totalProduct){
        Decimal commitmentTermsInMonthForopp = 0.0;
        if(mapProducsWithBuilding.size() > 0){
            for(WWTypes.commitmentTerms objCommitmment : objContractEvent.commitments){
                if(mapProducsWithBuilding.containsKey(objCommitmment.building_uuid) && mapProducsWithBuilding.get(objCommitmment.building_uuid) != null){
                    if(String.isNotBlank(objCommitmment.number_of_months) && mapProducsWithBuilding.size() > 0){
                        List<WWTypes.products> lstProduct = mapProducsWithBuilding.get(objCommitmment.building_uuid);
                        Decimal productCommitment = 0.0;
                        Decimal additionOfProductQuantity = 0.0;
                        for(WWTypes.products objProduct : lstProduct){
                            if(String.isNotBlank(objProduct.quantity)){
                               additionOfProductQuantity += Decimal.valueOf(objProduct.quantity);
                            }
                        }
                        productCommitment = Decimal.valueof(objCommitmment.number_of_months) * additionOfProductQuantity;
                        commitmentTermsInMonthForopp += productCommitment;
                    }
                }
            }
        }
        Debug.log('totalProduct ::'+totalProduct+'commitmentTermsInMonthForopp ::'+commitmentTermsInMonthForopp);
        if(totalProduct > 0.0){
            return commitmentTermsInMonthForopp/totalProduct;
        }else{
            return null;
        }       
    }
    
    //CSI-525
    public Static void addCommitmentTermsOnOpportunity(WWTypes.ContractEvent objContractEvent, ContractEventUtilities.UtilityWapper objUtilityWapper, Id newOpportunityId){
        if(objUtilityWapper.objOpp != null && newOpportunityId == null){
            List<Commitment_Term__c> lstCommittmentsToBeDeleted = [SELECT Id  From Commitment_Term__c where Opportunity__c =: objUtilityWapper.objOpp.Id];
            debug.log('lstCommittmentsToBeDeleted ::'+lstCommittmentsToBeDeleted);
            if(lstCommittmentsToBeDeleted.size() > 0){
                delete lstCommittmentsToBeDeleted;
            } 
        }
        List<Commitment_Term__c> lstcommitmentsToBeInserted = new List<Commitment_Term__c>();
        if(objContractEvent.commitments != null && objContractEvent.commitments.Size() > 0){
            for(WWTypes.commitmentTerms objPayLoadCommitmment : objContractEvent.commitments){
                Commitment_Term__c objCommitment = new Commitment_Term__c();
                objCommitment.Building_UUID__c = objPayLoadCommitmment.building_uuid;
                objCommitment.Commitment_Start_Date__c = Date.valueOf(objPayLoadCommitmment.start_date);
                //CSI-722 
				objCommitment.Commitment_End_Date__c = Date.valueOf(objPayLoadCommitmment.end_date);
                objCommitment.Commitment_Term_in_Months__c = Integer.valueOf(objPayLoadCommitmment.number_of_months);
                objCommitment.Building__c = (objUtilityWapper.mapAllPayloadBuildings.size() > 0 && objUtilityWapper.mapAllPayloadBuildings.get(objPayLoadCommitmment.building_uuid) != null)? objUtilityWapper.mapAllPayloadBuildings.get(objPayLoadCommitmment.building_uuid).Id : null;
                if(newOpportunityId == null)
                  objCommitment.Opportunity__c = objUtilityWapper.objOpp.Id;
                else
                  objCommitment.Opportunity__c = newOpportunityId;
                lstcommitmentsToBeInserted.add(objCommitment);
            }
        }
        
        Debug.log('lstcommitmentsToBeInserted ::'+lstcommitmentsToBeInserted);
        if(lstcommitmentsToBeInserted.size() > 0){
            insert lstcommitmentsToBeInserted;
            for(Commitment_Term__c obj : lstcommitmentsToBeInserted){
                if(obj.Building_UUID__c != null && obj.Id != null){
                    objUtilityWapper.mapBuildingUUIDWithCommitmentId.put(obj.Building_UUID__c, obj.Id);
                }  	  	
            }
        }
        Debug.log('objUtilityWapper.mapBuildingUUIDWithCommitmentId in addCommitmentTermsOnOpportunity::'+objUtilityWapper.mapBuildingUUIDWithCommitmentId);
    }
    
    public static void utilityWrapperInitializerCommitment(WWTypes.ContractEvent objContractEvent, ContractEventUtilities.UtilityWapper objUtilityWapper, Map<String,List<WWTypes.products>> mapProducsWithBuilding){ 
    	if(objContractEvent.commitments != null && objContractEvent.commitments.size() > 0){
            for(WWTypes.commitmentTerms objCommitmment : objContractEvent.commitments){
                if(String.isNotBlank(objCommitmment.building_uuid)){
                    objUtilityWapper.setPayloadBuildingUUID.add(objCommitmment.building_uuid);         
                }       
            }
            objUtilityWapper.CommitmentTermInMonthsForopp = calculateCommitmentTermsInMonth(objContractEvent, mapProducsWithBuilding, objUtilityWapper.totalProduct);
        }
    }
}