/**
* Name			:	ContractEventSellableHandler	 
* Issue No.		: 	ST-2523 
* Purpose		:	This is contains the logic for Sellable Contract.
* History		
	Version			Author				Date			Detail						Feature			IssueNumber
	1.0				Shobhit Gahlot	   11/6/2018		Initial Development
	
***********************************************************************************************************************************************************
*/ 
public class ContractEventSellableHandler {
//CSI-548 Move sellable Products to custom object
    public static ContractEventUtilities.ContractEventUtilitiesVal separateProductsForSellable(ContractEventUtilities.UtilityWapper objUtilityWapper, WWTypes.ContractEvent objContractEvent){
        List<WWTypes.products> lstDealProducts = new List<WWTypes.products>();
        if(objContractEvent.products != null && objContractEvent.products.size() > 0){
            for(WWTypes.products product : objContractEvent.products){
                if(string.isNotBlank(product.product_code) && product.product_code == objUtilityWapper.objContractEventUtilitySetting.DealProductCode){
                    lstDealProducts.add(product);
                }else if(string.isNotBlank(product.product_code) && objUtilityWapper.objContractEventUtilitySetting.ConsideredProductCodes.contains(product.product_code)){
                    objUtilityWapper.lstSellableProductsInUpdate.add(product);
                }
            }
        }
        objUtilityWapper.lstALLProducts = lstDealProducts;
        ContractEventUtilities.ContractEventUtilitiesVal objContractEventUtilitiesVal = new ContractEventUtilities.ContractEventUtilitiesVal();
        objContractEventUtilitiesVal.objContractEvent = objContractEvent;
        objContractEventUtilitiesVal.objUtilityWapper = objUtilityWapper;
        return objContractEventUtilitiesVal;
    }
    
    //CSI-548 Move sellable Products to custom object
    public Static Boolean moveSellableProductsToCustom(WWTypes.ContractEvent objContractEvent, ContractEventUtilities.UtilityWapper objUtilityWapper,  Map<String,PricebookEntry> mapPricebookEntry, Id newOpportunityId){
        List<Sellable_Opportunity_Product__c> lstsellableProductsToInsert = new List<Sellable_Opportunity_Product__c>();
        
        for(WWTypes.products product : objUtilityWapper.lstSellableProductsInUpdate){
            Sellable_Opportunity_Product__c objSellableOpportunityProduct = new Sellable_Opportunity_Product__c();
            if(mapPricebookEntry.get(product.product_code) != null){
                objSellableOpportunityProduct.List_Price__c = mapPricebookEntry.get(product.product_code).UnitPrice;
                if(newOpportunityId == null){
                  objSellableOpportunityProduct.Opportunity__c = objUtilityWapper.objOpp.Id;  
                }else{
                    objSellableOpportunityProduct.Opportunity__c = newOpportunityId;
                }
                objSellableOpportunityProduct.Unit_Price__c = Decimal.valueOf(product.unit_price);
                objSellableOpportunityProduct.Quantity__c = Decimal.valueOf(product.quantity);
                objSellableOpportunityProduct.Product__c = mapPricebookEntry.get(product.product_code).Product2Id;
                objSellableOpportunityProduct.CurrencyIsoCode = objContractEvent.currencyVal;
                objSellableOpportunityProduct.Building__c = (product.building_uuid != null && product.building_uuid != ''  && objUtilityWapper.mapAllPayloadBuildings.get(product.building_uuid) != null)? objUtilityWapper.mapAllPayloadBuildings.get(product.building_uuid).Id : null;
                objSellableOpportunityProduct.Building_UUID__c = (product.building_uuid != null && product.building_uuid != '')? product.building_uuid : null;
                objSellableOpportunityProduct.Start_Date__c = (product.start_date != null && product.start_date != '') ? Date.valueOf(product.start_date): null;
                objSellableOpportunityProduct.Total_Price__c = (objSellableOpportunityProduct.Quantity__c != null && objSellableOpportunityProduct.Unit_Price__c != null)?(objSellableOpportunityProduct.Unit_Price__c * objSellableOpportunityProduct.Quantity__c) : null;
                lstsellableProductsToInsert.add(objSellableOpportunityProduct);
            }else if(mapPricebookEntry.get(product.product_code) == null){
                Debug.log('Product not found from price book entry in sellable');
                return false;
            }
        }
        if(lstsellableProductsToInsert.size() > 0){
            Debug.log('lstsellableProductsToInsert :: '+lstsellableProductsToInsert);
            insert lstsellableProductsToInsert;
        }
        return true;
    }
}