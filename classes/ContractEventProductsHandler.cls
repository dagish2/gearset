/**
* Name			:	ContractEventProductsHandler	 
* Issue No.		: 	ST-2521 
* Purpose		:	This is contains the logic for handling products in contract Event.
* History		
	Version			Author				Date			Detail						Feature			IssueNumber
	1.0				Shobhit Gahlot	   11/6/2018		Initial Development
***********************************************************************************************************************************************************
*/ 
public class ContractEventProductsHandler {
	public static Id updateopportunityId;
    public static Set<String> setOpportunityLineItemFields;
    public static Map<String,Map<String,OpportunityLineItem>> mapOppLineItemBuildingProductCode;
    // Name    : Shobhit Gahlot
    // Issue No. : 
    // Date    : 6th June 2018
    // Comment : This method is used to handle products for all 
    public static void handleProducts(WWTypes.ContractEvent objContractEvent, ContractEventUtilities.UtilityWapper objUtilityWapper){
        updateopportunityId = objUtilityWapper.objOpp.Id;
        List<String> lstOpportunityLineItemFields = ContractEventUtilities.getEditableFields('OpportunityLineItem', new Set<String>{});
        Debug.log('lstOpportunityLineItemFields :: '+lstOpportunityLineItemFields);
        setOpportunityLineItemFields = new Set<String>();
        setOpportunityLineItemFields.addAll(lstOpportunityLineItemFields);
        Set<String> setConsideredProduct = new Set<String>();
        setConsideredProduct.addAll(objUtilityWapper.objContractEventUtilitySetting.ConsideredProductCodes);
        List<OpportunityLineItem> lstOpportunityLineItem  = Database.Query('SELECT Id, Product2.Name, PricebookEntryId, ProductCode, ' +String.join(lstOpportunityLineItemFields, ',') +  ' FROM OpportunityLineItem WHERE OpportunityId =: updateopportunityId AND ProductCode In : setConsideredProduct FOR UPDATE');
        mapOppLineItemBuildingProductCode = retainOppLineItemBuildingProductCode(lstOpportunityLineItem);
        
        List<OpportunityLineItem> lstOpportunityLineItemOtherProducts  = Database.Query('SELECT Id, Product2.Name, PricebookEntryId, ProductCode, OpportunityId, ' +String.join(ContractEventUtilities.getEditableFields('OpportunityLineItem', new Set<String>{'totalprice'}), ',') +  ' FROM OpportunityLineItem WHERE OpportunityId =: updateopportunityId and ProductCode Not In : setConsideredProduct');
        Debug.log('lstOpportunityLineItemOtherProducts for updating opportunity id ::  '+lstOpportunityLineItemOtherProducts);
        objUtilityWapper.lstOpportunityLineItemOtherProductsWillUpsert = createNewOppLineItems(lstOpportunityLineItemOtherProducts);
        //If searched Opportunity's CurrencyIsoCode is diffrent than payload's CurrencyIsoCode then update Opportunity's CurrencyIsoCode
        if(objUtilityWapper.oppToUse.CurrencyIsoCode != objContractEvent.currencyVal){
            Debug.log('Currency Change delete all products');
            objUtilityWapper.objOpp.CurrencyIsoCode = objContractEvent.currencyVal;
            Debug.log('ContractEvent : Opportunity Update :: '+objUtilityWapper.objOpp);
            objUtilityWapper.deleteOpportunityLineItem = true;
            delete lstOpportunityLineItem;
            delete lstOpportunityLineItemOtherProducts;
        }
        if(!objUtilityWapper.deleteOpportunityLineItem){
            Debug.log('Currency not change delete all our products. : '+lstOpportunityLineItem);
            delete lstOpportunityLineItem;      
        }
    }
    
    // Name    : Shobhit Gahlot
    // Issue No. : 
    // Date    : 6th June 2018
    // Comment : This method is used to insert products that are considered and are
    public static void createNewProducts(WWTypes.ContractEvent objContractEvent, ContractEventUtilities.UtilityWapper objUtilityWapper, String newOppId){
        set<Id> setProduct = new set<Id>();
        List<Product2> lstProduct2 = [Select Id, Name, ProductCode From Product2 Where ProductCode In : objUtilityWapper.objContractEventUtilitySetting.ConsideredProductCodes];
        for(Product2 objProduct : lstProduct2){
            setProduct.add(objProduct.id);
        }
        List<OpportunityLineItem> lstOpportunityLineItemToInsert = new List<OpportunityLineItem>();
        
        List<PricebookEntry> lstPricebookEntry = [SELECT Id, Product2Id, Product2.Name, UnitPrice, ProductCode FROM PricebookEntry WHERE Product2Id IN: setProduct and CurrencyIsoCode =: objContractEvent.currencyVal];
        Debug.log('lstPricebookEntry update check:: '+lstPricebookEntry);
        Debug.log('objUtilityWapper.objContractEventUtilitySetting.RetainProductFields:: '+objUtilityWapper.objContractEventUtilitySetting.RetainProductFields);
        Debug.log('mapOppLineItemBuildingProductCode:: '+mapOppLineItemBuildingProductCode );
        Map<String,PricebookEntry> mapPricebookEntry = new Map<String,PricebookEntry>();
        Debug.log('objUtilityWapper.lstALLProducts update class ::'+objUtilityWapper.lstALLProducts);
        if(lstPricebookEntry != null && lstPricebookEntry.Size() > 0){
            if(objUtilityWapper.lstALLProducts != null && objUtilityWapper.lstALLProducts.size() > 0){ 
                for(PricebookEntry objPbook : lstPricebookEntry){
                    mapPricebookEntry.put(objPbook.ProductCode,objPbook);
				}  
                Debug.log('mapPricebookEntry ::'+mapPricebookEntry);
                for(WWTypes.products product : objUtilityWapper.lstALLProducts){
                    OpportunityLineItem objOpportunityLineItem = new OpportunityLineItem();
                    if(mapPricebookEntry.get(product.product_code) != null){
                        //Modified by Shobhit Gahlot for ST-2289 map product category with opportunityLineItem
                        if(newOppId == null && product.building_uuid != null && product.product_code != null && mapOppLineItemBuildingProductCode != null && mapOppLineItemBuildingProductCode.containsKey(product.building_uuid) != null && mapOppLineItemBuildingProductCode.get(product.building_uuid) != null){                            
                            if(mapOppLineItemBuildingProductCode.get(product.building_uuid).containsKey(product.product_code)){
                                for(String field : objUtilityWapper.objContractEventUtilitySetting.RetainProductFields){
                                    if(setOpportunityLineItemFields.contains(field.toLowerCase())){
                                        objOpportunityLineItem.put(field,mapOppLineItemBuildingProductCode.get(product.building_uuid).get(product.product_code).get(field));  
                                    }       
                                }
                            }
                        }
                        objOpportunityLineItem.PricebookEntryId = mapPricebookEntry.get(product.product_code).Id;
                        if(newOppId != null){
                            objOpportunityLineItem.OpportunityId = newOppId; 
                        }else{
                           objOpportunityLineItem.OpportunityId = objUtilityWapper.objOpp.Id; 
                        }
                        objOpportunityLineItem.UnitPrice = Decimal.valueOf(product.unit_price);
                        objOpportunityLineItem.Quantity = Decimal.valueOf(product.quantity);
                        //For Sellable
                        objOpportunityLineItem.Building__c = (product.building_uuid != null && product.building_uuid != ''  && objUtilityWapper.mapAllPayloadBuildings.get(product.building_uuid) != null)? objUtilityWapper.mapAllPayloadBuildings.get(product.building_uuid).Id : null;
                        //For Sellable
                        objOpportunityLineItem.Building_UUID__c = (product.building_uuid != null && product.building_uuid != '')? product.building_uuid : null;
                        objOpportunityLineItem.Start_Date__c = (product.start_date != null && product.start_date != '') ? Date.valueOf(product.start_date): null;
                        lstOpportunityLineItemToInsert.add(objOpportunityLineItem);
                    }else if(mapPricebookEntry.get(product.product_code) == null){
                        throw new ContractEventProductsHandlerException('Product not found. Contact to your administrator.');
                    }
                }
                //CSI-548 Move sellable Products to custom object
                if(newOppId == null){
                    List<Sellable_Opportunity_Product__c> lstsellableProductsToDelete = [SELECT Id FROM Sellable_Opportunity_Product__c WHERE Opportunity__c =:objUtilityWapper.objOpp.Id AND Product_Code__c IN : objUtilityWapper.objContractEventUtilitySetting.ConsideredProductCodes]; 
                    Debug.log('Delete lstsellableProductsToDelete ::'+lstsellableProductsToDelete);
                    if(lstsellableProductsToDelete.size() > 0){
                        delete lstsellableProductsToDelete;
                    }
                }
                //CSI-548 Move sellable Products to custom object
                Boolean status;
                if(objUtilityWapper.considerSellableProductSeparation && objUtilityWapper.lstSellableProductsInUpdate.Size() > 0){
                    if(newOppId != null){
                        status = ContractEventSellableHandler.moveSellableProductsToCustom(objContractEvent, objUtilityWapper,mapPricebookEntry,newOppId);
                    }else{
                      status = ContractEventSellableHandler.moveSellableProductsToCustom(objContractEvent, objUtilityWapper,mapPricebookEntry,null);  
                    }
                    if(!status){
                        throw new ContractEventProductsHandlerException('Product not found. Contact to your administrator.');
                    }
                }		
                Debug.log('lstOpportunityLineItemToInsert :: '+lstOpportunityLineItemToInsert);
                if(lstOpportunityLineItemToInsert != null && lstOpportunityLineItemToInsert.size()>0){
                    insert lstOpportunityLineItemToInsert;
                }
            }
        }else{
            Debug.log('Product not found. Contact to your administrator.');
            throw new ContractEventProductsHandlerException('Product not found. Contact to your administrator.');
        }
    }
        
    // Name    : Shobhit Gahlot
    // Issue No. : 
    // Date    : 6th June 2018
    // Comment : This method is used to upsert unconsiderd products if the currency of opportunity was changed.
    public static void unconsideredLineItemWithCurrencyChange(WWTypes.ContractEvent objContractEvent, ContractEventUtilities.UtilityWapper objUtilityWapper){
        //Insert other products which we deleted for currency change.
        set<string> setOtherProduct = new set<string>();
        for(OpportunityLineItem obj: objUtilityWapper.lstOpportunityLineItemOtherProductsWillUpsert){
            setOtherProduct.add(obj.ProductCode);
        }
        Debug.log('setOtherProduct : '+setOtherProduct);
        Debug.log('objContractEvent.currencyVal : '+objContractEvent.currencyVal);
        List<PricebookEntry> lstPricebookEntryOther = [Select Id, Product2Id, Product2.Name,ProductCode From PricebookEntry Where ProductCode IN: setOtherProduct and CurrencyIsoCode =: objContractEvent.currencyVal];
        
        Map<String,PricebookEntry> mapPricebookEntryOther = new Map<String,PricebookEntry>();
        Debug.log('lstPricebookEntryOther : '+lstPricebookEntryOther);
        for(PricebookEntry objPbook : lstPricebookEntryOther){
           mapPricebookEntryOther.put(objPbook.ProductCode,objPbook); 
        }        
        Debug.log('mapPricebookEntryOther : '+mapPricebookEntryOther);
        List<String> lstIsoCode = new List<String>{objUtilityWapper.oppToUse.CurrencyIsoCode,objContractEvent.currencyVal};
        Decimal orgConversionRate;
        Decimal orgConversionRateToOther;
        list<CurrencyType> lstConversionRate = [SELECT ISOCode, ConversionRate FROM CurrencyType WHERE IsActive=TRUE and IsoCode IN: lstIsoCode];
        for(CurrencyType curr : lstConversionRate){
            if(curr.IsoCode == objUtilityWapper.oppToUse.CurrencyIsoCode)
                orgConversionRate = curr.ConversionRate; 
            else
                orgConversionRateToOther = curr.ConversionRate;
        }
        
        for(OpportunityLineItem obj : objUtilityWapper.lstOpportunityLineItemOtherProductsWillUpsert){
            if(mapPricebookEntryOther.get(obj.ProductCode) != null){
                Debug.log('convertToOrgCurrency : ');
                Decimal resultPriceToOrg = ContractEventServices.convertToOrgCurrency(obj.UnitPrice,orgConversionRate);
                Debug.log('resultPriceToOrg : '+resultPriceToOrg);
                if(objContractEvent.currencyVal != 'USD'){
                    Debug.log('convertFromOrgCurrency : ');
                    Debug.log('objContractEvent.currencyVal : '+objContractEvent.currencyVal+' : '+resultPriceToOrg);
                    Decimal resultPriceToOther = ContractEventServices.convertFromOrgCurrency(resultPriceToOrg,orgConversionRateToOther);
                    Debug.log('obj.UnitPrice : '+resultPriceToOther);
                    obj.UnitPrice = resultPriceToOther;
                }else{
                    Debug.log('obj.UnitPrice : '+resultPriceToOrg);
                    obj.UnitPrice = resultPriceToOrg;
                }
                obj.PricebookEntryId = mapPricebookEntryOther.get(obj.ProductCode).Id; 
            }else if(mapPricebookEntryOther.get(obj.ProductCode) == null){
                throw new ContractEventProductsHandlerException('Product not found. Contact to your administrator.');
            }
            
        }
        upsert objUtilityWapper.lstOpportunityLineItemOtherProductsWillUpsert;
    }
    // Name    : Shobhit Gahlot
    // Issue No. : 
    // Date    : 6th June 2018
    // Comment : This method is used to separate considered products and un considered products
    public static Map<String, List<OpportunityLineItem>> separateProductsUsingProductCodes(List<OpportunityLineItem> lstOpportunityLineItem, Set<String> productCodes){
        Map<String, List<OpportunityLineItem>> mapProducts = new Map<String, List<OpportunityLineItem>>();
        List<OpportunityLineItem> consideredProducts = new List<OpportunityLineItem>();
        List<OpportunityLineItem> notConsideredProducts = new List<OpportunityLineItem>();
        for(OpportunityLineItem objLineItem : lstOpportunityLineItem){
            if(productCodes.contains(objLineItem.ProductCode)){
                consideredProducts.add(objLineItem);
            }else{
                notConsideredProducts.add(objLineItem);
            }
        }
        mapProducts.put('ConsideredProducts',consideredProducts);
        mapProducts.put('NotConsideredProducts',notConsideredProducts);
        Debug.log('mapProducts ::'+mapProducts);
        return mapProducts;
    }
    // Name    : Shobhit Gahlot
    // Issue No. : ST-2289
    // Date    : 6th June 2018
    // Comment : This method is used to retain productcode on line items depending on the building uuid
    public static Map<String,Map<String,OpportunityLineItem>> retainOppLineItemBuildingProductCode(List<OpportunityLineItem> lstOpportunityLineItem){
        Map<String,Map<String,OpportunityLineItem>> mapOppLineItemBuildingProductCode = new Map<String,Map<String,OpportunityLineItem>>();
        if(lstOpportunityLineItem != null && lstOpportunityLineItem.size() > 0){
            for(OpportunityLineItem objOppLineItem : lstOpportunityLineItem){
                if(objOppLineItem.Building_UUID__c != null && mapOppLineItemBuildingProductCode.containsKey(objOppLineItem.Building_UUID__c) && mapOppLineItemBuildingProductCode.get(objOppLineItem.Building_UUID__c) != null){ 
                    if(!mapOppLineItemBuildingProductCode.get(objOppLineItem.Building_UUID__c).containsKey(objOppLineItem.ProductCode)){
                       mapOppLineItemBuildingProductCode.get(objOppLineItem.Building_UUID__c).put(objOppLineItem.ProductCode,objOppLineItem); 
                    }
                }else if(objOppLineItem.Building_UUID__c != null && objOppLineItem.ProductCode != null){
                    mapOppLineItemBuildingProductCode.put(objOppLineItem.Building_UUID__c,new Map<String,OpportunityLineItem>{objOppLineItem.ProductCode => objOppLineItem});
                }	
            }
        }
        Debug.log('mapOppLineItemBuildingProductCode ::'+mapOppLineItemBuildingProductCode);
        return mapOppLineItemBuildingProductCode;
    }
    
    //Clone list for insert again Opportunity Products.
    public static List<OpportunityLineItem> createNewOppLineItems(List<OpportunityLineItem> lineItemsToDelete){
        List<OpportunityLineItem> lineItemsToInsert = new List<OpportunityLineItem>();
        try{
            for(OpportunityLineItem lineItemToDelete : lineItemsToDelete){    
                Map<String, Object> lineItem = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(lineItemToDelete));
                lineItem.remove('Id');
                lineItemsToInsert.add((OpportunityLineItem)JSON.deserialize(JSON.serialize(lineItem), OpportunityLineItem.class));
            }
            Debug.log('lineItemsToDelete => '+lineItemsToDelete);
            Debug.log('lineItemsToInsert => '+lineItemsToInsert);
            return lineItemsToInsert; 
        }catch(Exception exc){
            Debug.log('createNewOppLineItems Exception => '+ exc);
            return null;
        }
        
    }
    public class ContractEventProductsHandlerException extends Exception{}
}