/************************************************************************************************************************************
    Author 		: 	Pragalbha Mahajan
    Description : 	This class contains the business logic of createOpportunityProduct Trigger.
    History		:
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE				AUTHOR					DETAIL
	1			15 November 2018	Pragalbha Mahajan     	Initial Development	 
**************************************************************************************************************************************/
public class TrOpportunityCreateOppProduct implements IProcessHandler{
    public static String defaultProductCode ;
    
    public void handle(List<sObject> triggerNew, Map<Id, sObject> triggerOldMap){
        createOpportunityProduct((list<Opportunity>)triggerNew);
    }
    
    /************************************************************************************************************************************
    Author 				: 	Pragalbha Mahajan
    Description 		: 	This method is used to create Opportunity Line Item. 
    Issue No.			:	ST-3076
	Created Date		:	15 November 2018
    **************************************************************************************************************************************/ 
    public static void createOpportunityProduct(list<Opportunity> lstNewOpportunity){
        Set<String> setAllowedStages = new Set<String>();
        getInitialSettingData(setAllowedStages);
        Set<Id> setAccountIds = new Set<Id>();
        Set<Id> setBillingAccount = new Set<Id>();
        Set<String> setCurrencies = new Set<String>();
        for(Opportunity opp : lstNewOpportunity){
            if(String.isNotBlank(opp.StageName) && setAllowedStages.contains(opp.StageName.toLowerCase())){
                setCurrencies.add(opp.CurrencyISOCode);
                setAccountIds.add(opp.AccountId);
                setBillingAccount.add(opp.Billing_Account__c);
            }
        }
        if(setCurrencies.size() > 0){
            List<OpportunityLineItem> lstOpportunityProduct = getProducts(lstNewOpportunity, setCurrencies, setAllowedStages);
            if(lstOpportunityProduct.size() > 0){
                mapProductFamilyAndCategory(lstOpportunityProduct);
                Database.insert(lstOpportunityProduct);
            }
        }
    }
    
    /************************************************************************************************************************************
    Author 				: 	Milanjeet Singh
    Description 		: 	This helper method is used to get the quantity of Products by Interested in Number of Desks and Company Size 
    Issue No.			:	-
	Created Date		:	16 November 2018
    **************************************************************************************************************************************/ 
    public static Map<Id, Integer> getQuantityMap(List<Opportunity> lstOpportunity){
        Map<Id, Integer> mapQuantity = new Map<Id, Integer>();
        for(Opportunity objOpportunity : lstOpportunity){
            if(String.isEmpty(String.valueOf(objOpportunity.Interested_in_Number_of_Desks__c))){
                String strCompanySize = (String.isBlank(objOpportunity.Company_Size__c) ? '1' : (objOpportunity.Company_Size__c.contains('-') ? (objOpportunity.Company_Size__c.split('-')[0]) : (objOpportunity.Company_Size__c.contains('+') ? (objOpportunity.Company_Size__c.substring(0, objOpportunity.Company_Size__c.indexOf('+'))) : (objOpportunity.Company_Size__c.split(' ')[0]))));
                if(String.isNotBlank(strCompanySize) && strCompanySize.contains(',')){
                    strCompanySize = strCompanySize.remove(',');
                }
                strCompanySize = strCompanySize.trim();
                mapQuantity.put(objOpportunity.Id, Integer.valueOf(strCompanySize));
            }else{
                mapQuantity.put(objOpportunity.Id, Integer.valueOf(objOpportunity.Interested_in_Number_of_Desks__c));
            }
        }
        return mapQuantity;
    }
    
    /************************************************************************************************************************************
    Author 				: 	Milanjeet Singh
    Description 		: 	This helper method is used to get the Products by quantity
    Issue No.			:	-
	Created Date		:	16 November 2018
    **************************************************************************************************************************************/ 
    public static List<OpportunityLineItem> getProducts(List<Opportunity> lstOpportunity, Set<String> setCurrencies, Set<String> setAllowedStages){
        List<OpportunityLineItem> lstOpportunityProduct = new List<OpportunityLineItem>();
        Map<Id, Integer> mapQuantity = getQuantityMap(lstOpportunity);
        Map<String, PricebookEntry> mapEntries = getPriceBookEntryByProductCode(defaultProductCode, setCurrencies);
        for(Opportunity objOpportunity : lstOpportunity){
            if(String.isNotBlank(objOpportunity.StageName) && setAllowedStages.contains(objOpportunity.StageName.toLowerCase()) && mapEntries.size() > 0){ 
                if(mapEntries.containsKey(objOpportunity.CurrencyISOCode) && mapEntries.get(objOpportunity.CurrencyISOCode) != null && mapQuantity.get(objOpportunity.Id) > 0){
                    lstOpportunityProduct.add(new OpportunityLineItem(PricebookEntryId = mapEntries.get(objOpportunity.CurrencyISOCode).Id, OpportunityId = objOpportunity.Id, Quantity = mapQuantity.get(objOpportunity.Id), UnitPrice = 450, Building__c = objOpportunity.Building__c, Geography__c = objOpportunity.Geography__c, Building_UUID__c = objOpportunity.Building_uuid__c, Is_Primary_Product__c = true));
                }
            }
        }
        return lstOpportunityProduct;
    }
    
    /************************************************************************************************************************************
    Author 				: 	Milanjeet Singh
    Description 		: 	This helper method is used to get pricebook entries by currencies and product code.
    Issue No.			:	-
	Created Date		:	16 November 2018
    **************************************************************************************************************************************/ 
    public static Map<String, PricebookEntry> getPriceBookEntryByProductCode(String productCode, Set<String> setCurrencies){
        Map<String, PricebookEntry> mapPricebookEntries = new Map<String,PricebookEntry>();
        for(PricebookEntry entry:[SELECT Id, Name, CurrencyIsoCode, UnitPrice FROM PricebookEntry WHERE ProductCode =: productCode AND CurrencyIsoCode IN:setCurrencies]){
            mapPricebookEntries.put(entry.CurrencyISOCode, entry);
        }
        return mapPricebookEntries;
    }
    
    /************************************************************************************************************************************
    Author 				: 	Milanjeet Singh
    Description 		: 	This helper method is used to map the product family and category
    Issue No.			:	-
	Created Date		:	16 November 2018
    **************************************************************************************************************************************/ 
    public static void mapProductFamilyAndCategory(List<OpportunityLineItem> lstOpportunityProduct){
        List<Product2> lstProducts = Settings.getProductsByProductCode(defaultProductCode);
        Product2 objDefaultProduct = lstProducts != null ? lstProducts[0] : null;
        for(OpportunityLineItem oppLineItem : lstOpportunityProduct){
            if(objDefaultProduct != null && objDefaultProduct.Default_Product_Category__c != null){
                oppLineItem.Product_Category__c = objDefaultProduct.Default_Product_Category__c;
            }
            if(objDefaultProduct != null && objDefaultProduct.Family != null){
                oppLineItem.Family__c = objDefaultProduct.Family;
            }
        }
    }
    
	/************************************************************************************************************************************
    Author 				: 	Pragalbha Mahajan
    Description 		: 	This method is used to get InitialSettingData
    Issue No.			:	ST-3076
	Created Date		:	20 November 2018
    **************************************************************************************************************************************/     
    public static Set<String> getInitialSettingData(Set<String> setAllowedStages){
        Set<String> setFields = new Set<String>();
        setFields.add('Stages__c');
        setFields.add('DefaultProductCode__c'); 
        List<OpportunityStagesSetting__mdt> oppStageSettings = (List<OpportunityStagesSetting__mdt>)Settings.getFieldsFromMDT('OpportunityStagesSetting__mdt', 'AllowedStagesForOppProduct', setFields);
        if(oppStageSettings != null && !oppStageSettings.isEmpty()){
            if(String.isNotEmpty(oppStageSettings[0].Stages__c)){
                setAllowedStages.addAll(Settings.splitStringToSet(oppStageSettings[0].Stages__c, ';'));
            }
            defaultProductCode = oppStageSettings[0].DefaultProductCode__c;
        }
        return setAllowedStages;
    }
}