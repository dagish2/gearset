/**
* Name			:	ContractEventDiscountsHandler	 
* Issue No.		: 	CSI-715 
* Purpose		:	This is used to update and create Discounts in contract event for all events.
* History		
Version			Author				Date			Detail						Feature			IssueNumber
1.0				Shobhit Gahlot		23/03/2018		Initial Development
***********************************************************************************************************************************************************
*/

public class ContractEventDiscountsHandler {

    //CSI-525
    public Static void updateDiscounts(WWTypes.ContractEvent objContractEvent, ContractEventUtilities.UtilityWapper objUtilityWapper){
        debug.log('objUtilityWapper.objContractEventUtilitySetting.ConsideredDiscounts ::'+objUtilityWapper.objContractEventUtilitySetting.ConsideredDiscounts);
        debug.log('objUtilityWapper.objOpp.Id ::'+objUtilityWapper.objOpp.Id);
        List<Discount__c> lstDiscount = new List<Discount__c>();
        lstDiscount = deleteDiscounts(objUtilityWapper);
        
        insertNewDiscounts(objContractEvent, objUtilityWapper, lstDiscount, null);
    }
    //CSI-525
    public static List<Discount__c> deleteDiscounts(ContractEventUtilities.UtilityWapper objUtilityWapper){
        List<Discount__c> lstdiscountsToBeDeleted = new List<Discount__c>();
        List<Discount__c> lstDiscount = new List<Discount__c>();
        Id updateopportunityId = ContractEventProductsHandler.updateopportunityId; 
        List<Discount__c> lstAllDiscountsOnOpp  = Database.Query('SELECT Id, ' +String.join(ContractEventUtilities.getEditableFields('Discount__c', new Set<String>{}), ',') +  ' FROM Discount__c WHERE Opportunity__c =: updateopportunityId');
        debug.log('updateDiscounts lstAllDiscountsOnOpp ::'+lstAllDiscountsOnOpp);
        for(Discount__c objDiscount : lstAllDiscountsOnOpp){
            if(objDiscount.Discount_Type__c != null && !objUtilityWapper.objContractEventUtilitySetting.ConsideredDiscounts.contains(objDiscount.Discount_Type__c.toLowerCase())){
                Map<String, Object> discountNotConsidered = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(objDiscount));
                discountNotConsidered.remove('Id');
                lstDiscount.add((Discount__c)JSON.deserialize(JSON.serialize(discountNotConsidered), Discount__c.class));
            }
            lstdiscountsToBeDeleted.add(objDiscount);
        }
        
        debug.log('lstdiscountsToBeDeleted ::'+lstdiscountsToBeDeleted);
        if(lstdiscountsToBeDeleted != null && lstdiscountsToBeDeleted.size() > 0){
            delete lstdiscountsToBeDeleted;
        }
        
        return lstDiscount;
    }
    //CSI-525
    public static void insertNewDiscounts(WWTypes.ContractEvent objContractEvent, ContractEventUtilities.UtilityWapper objUtilityWapper, List<Discount__c> lstDiscount, Id newOpportunityId){
        if(objContractEvent.discounts != null && objContractEvent.discounts.size() > 0){
            for(WWTypes.Discounts objcommitmentDiscount : objContractEvent.discounts){
                Discount__c objDiscount = new Discount__c();
                objDiscount.Start_Date__c = Date.valueOf(objcommitmentDiscount.start_date);
                //CSI-720 perpetual discounts
                if(String.isNotBlank(objcommitmentDiscount.end_date))
                	objDiscount.End_Date__c = Date.valueOf(objcommitmentDiscount.end_date);
                objDiscount.Discount_Type__c = 'Commitment Term';
                if(newOpportunityId != null)
                    objDiscount.Opportunity__c = newOpportunityId;
                else if(objUtilityWapper.objOpp != null)
                	objDiscount.Opportunity__c = objUtilityWapper.objOpp.Id;
                objDiscount.Amount__c = Decimal.valueOf(objcommitmentDiscount.amount);
                objDiscount.Building_UUID__c =  objcommitmentDiscount.building_uuid;
                objDiscount.Building__c = (objUtilityWapper.mapAllPayloadBuildings.size() > 0 && objUtilityWapper.mapAllPayloadBuildings.get(objcommitmentDiscount.building_uuid) != null)? objUtilityWapper.mapAllPayloadBuildings.get(objcommitmentDiscount.building_uuid).Id : null;
                lstDiscount.add(objDiscount);
            }
            debug.log('lstDiscount ::'+lstDiscount);
            if(lstDiscount != null && lstDiscount.size() > 0){
                insert lstDiscount;
            }
        }
    }
     
    public static void buildingUUIDExtractorFromPayload(WWTypes.ContractEvent objContractEvent, ContractEventUtilities.UtilityWapper objUtilityWapper){
        //Modified By: Shobhit Gahlot, Issue No: CSI-525, Comment: Discounts will come in payload under commitment for contract sent event
        if(objContractEvent.discounts != null && objContractEvent.discounts.size() > 0){
            for(WWTypes.Discounts obj :objContractEvent.discounts){
                if(String.isNotBlank(obj.building_uuid)){
                    objUtilityWapper.setPayloadBuildingUUID.add(obj.building_uuid);
                }
            }
        }
    }
}