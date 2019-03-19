/************************************************************************************************************************************
    Author      :   Nikhil Mehta    
    Description :   This class contain all aura methods related to ManageLineItems.
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1           17 July 2018        Nikhil Mehta            Initial Developement
**************************************************************************************************************************************/
global without sharing class ManageLineItemController {
    public class ManageLineItemControllerException extends Exception{}
    public static Boolean isInvoker = false;
    static {
        isInvoker = ApexDebugLog.registerRootInvoker(ApexDebugLog.InvokerType.AURA, 'ManageLineItemController' + 'getsObjectPrefix', ApexDebugLog.InvokerType.AURA);        
    	
    }
    /************************************************************************************************************************************
        Author              : Priyanka Ambre
        Description         : This method brings the all products for the given opp if logged in user have the permissions.
        Created Date        : 04 May 2018 
        Issue No            : ST-2356
    **************************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult getManageProducts(Id oppId){
        OppManageProductData oppManageProductData = new OppManageProductData();
        List<Opportunity> lstOpp = [SELECT Id, OwnerId, Owner.Profile.Name, Owner.Profile.Id, Owner.Name, CurrencyIsoCode, Building__c, Geography__c, Primary_Member_Id__c, Primary_Member_Name__c, CloseDate, Name, Deal_Type__c, Type__c, Requirement_Quantity__c, Desired_Term_Length_in_months__c, Confirm_Products__c, StageName, (SELECT Id, Description, Product2Id, Product2.Name, Product2.Family, Product2.Product_Type__c, Quantity, Family__c, Product_Category__c, QuantityUnitOfMeasure__c, UnitPrice, Building__c, Geography__c, Sq_Feet__c, Is_Primary_Product__c, Desired_Term_Length__c  FROM OpportunityLineItems) FROM Opportunity WHERE Id = :oppId];
        oppManageProductData.oppRec = (lstOpp[0] != null && lstOpp.size() > 0) ? lstOpp[0] : new Opportunity();
        oppManageProductData.isValidForManageProduct = isValidForManageProduct(lstOpp[0].OwnerId, lstOpp[0].StageName);
        oppManageProductData.lstproduct2s = [SELECT Id, Name, Family, Product_Category__c, QuantityUnitOfMeasure, (Select Id, UnitPrice From PricebookEntries Where CurrencyIsoCode = 'USD' AND IsActive=true)  FROM Product2 WHERE IsActive=true AND For_Manage_Product__c =true];
        oppManageProductData.lstCurrencies = [SELECT Id, toLabel(IsoCode), ConversionRate FROM CurrencyType WHERE IsActive=true];
        return new DatabaseResult(JSON.serialize(oppManageProductData));
    }
    /************************************************************************************************************************************
        Author         : Priyanka Ambre
        Description     : Wrapper class used for getManageProducts.
        Created Date    : 04 May 2018 
        Issue No      : ST-2356
    **************************************************************************************************************************************/
    public Class OppManageProductData {
        public Opportunity oppRec {get;set;}
        public List<Product2> lstproduct2s {get;set;}
        public String isValidForManageProduct {get;set;}
        public List<CurrencyType> lstCurrencies {get;set;}
    }
    /************************************************************************************************************************************
        Author         : Ajaysinh Chauhan
        Description    : This method deletes all the products and saves new products.
        Created Date   : 20 March 2018
		Modified By	   : Nikhil Mehta
    **************************************************************************************************************************************/
   @AuraEnabled
    public static DatabaseResult saveOpportunityProducts(Id opportunityId, List<OpportunityLineItem> lstProducts, string currencyCode, Boolean confirmProduct){
        Savepoint lineITemSavePoint = Database.setSavePoint();
        try{
            Boolean isCurrencyChanged = false;
            Decimal desiredTermLength = 0;
            if(String.isNotBlank(opportunityId) && lstProducts != null && !lstProducts.isEmpty()){
                Boolean isOppUpdate = false;
                Opportunity oppRec = [SELECT Id, Building__c, Geography__c, CurrencyIsoCode, StageName, Confirm_Products__c FROM Opportunity WHERE Id =: opportunityId];
                if(!oppRec.CurrencyIsoCode.equalsIgnoreCase(currencyCode)){
                    oppRec.CurrencyIsoCode = currencyCode;
                    isCurrencyChanged = true;
                }
                if(confirmProduct){
                   oppRec.Confirm_Products__c = 'Confirmed';
                    isOppUpdate = true;
                }
                OpportunityLineItem primaryProduct;
                if(lstProducts != null && lstProducts.size() > 0){
                    for(OpportunityLineItem oppLineItem : lstProducts){
                        if(oppLineItem.Desired_Term_Length__c != null){
                           desiredTermLength += oppLineItem.Desired_Term_Length__c;  
                       } 
                        if(oppLineItem.Is_Primary_Product__c){
                            primaryProduct = oppLineItem;
                        }
                    }
                    Decimal desiredTermLengthAvg = desiredTermLength/lstProducts.size();
                    if(desiredTermLengthAvg != 0){
                        oppRec.term__c = desiredTermLengthAvg;
                        isOppUpdate = true;   
                    }
                    if(primaryProduct != null && primaryProduct.Family__c != null){
                        if(primaryProduct.Geography__c != null && primaryProduct.Building__c != null && primaryProduct.Geography__c != oppRec.Geography__c){
                            oppRec.Geography__c = primaryProduct.Geography__c;
                            oppRec.Building__c = primaryProduct.Building__c;
                            isOppUpdate = true;
                        }else if(primaryProduct.Geography__c != null && primaryProduct.Building__c == null){
                            if(oppRec.Geography__c == primaryProduct.Geography__c){
                                List<Geography__c> lstGeographies = [SELECT Id, Nearest_Building__c FROM Geography__c WHERE Id =: primaryProduct.Geography__c];
                                if(lstGeographies != null && !lstGeographies.isEmpty() && lstGeographies[0].Nearest_Building__c != oppRec.Building__c){
                                    oppRec.Building__c = lstGeographies[0].Nearest_Building__c;
                                    oppRec.Geography__c = primaryProduct.Geography__c;
                                    isOppUpdate = true;
                                }
                            }else{
                                oppRec.Geography__c = primaryProduct.Geography__c;
                                oppRec.Building__c = null;
                                isOppUpdate = true;
                            }
                        }else if(primaryProduct.Building__c != null && oppRec.Building__c != primaryProduct.Building__c && primaryProduct.Geography__c == null){
                            oppRec.Building__c = primaryProduct.Building__c;
                            oppRec.Geography__c = null;
                            isOppUpdate = true;
                        }else if(primaryProduct.Building__c == null && primaryProduct.Geography__c == null){
                            oppRec.Building__c = null;
                            oppRec.Geography__c = null;
                            isOppUpdate = true;
                        }
                    }
                }
                delete [Select Id From OpportunityLineItem Where OpportunityId=:opportunityId];
                //Clean the map of processed records to allow update processing.
                TriggerProcessingManager.mapNumOfIterationsByProcess.remove('TrOpportunityUpdateBuildingFromGeo');
                if(isOppUpdate || isCurrencyChanged){ update oppRec; }
                Map<String, Object> response = new Map<String, Object>();
                response.put('insertedOpportunityProducts', Database.insert(isCurrencyChanged ? mapProductsOnCurrencyChange(lstProducts, currencyCode) : lstProducts));
                DatabaseResult result = new DatabaseResult(JSON.serialize(response));
                return new DatabaseResult(JSON.serialize(response));
            }else{
                throw new ManageLineItemControllerException('Opportunity and List of Opportunity products are null');
            }
        }catch(Exception pEx) {
            Database.rollback(lineItemSavePoint);
            ApexDebugLog.logException(pEx,opportunityId, 'ManageLineItemController', 'saveOpportunityProducts');            
            return (new DatabaseResult(pEx));  
        }
    }
     /************************************************************************************************************************************
        Author          : Chandra Teja
        Description     : This Method checks for active pricebook entry of the particular currency, if found we will update it in the Lineitem otherwise we throw an error
        Created Date    : 18 November 2018 
        Issue No        : ST-3011
    **************************************************************************************************************************************/
    public static List<OpportunityLineItem> mapProductsOnCurrencyChange(List<OpportunityLineItem> lstProducts, String currencyCode){
        Set<String> setProductId = new Set<String>();
        Map<String,Id> mapProductsByPriceBook = new Map<String,Id>();
        for(OpportunityLineItem oppLineitem : lstProducts){
            setProductId.add(oppLineitem.Product2Id);
        }
        List<PricebookEntry> lstPricebookEntry = [SELECT Id, Name, Pricebook2Id, Product2Id, CurrencyIsoCode, UnitPrice, IsActive, ProductCode FROM PricebookEntry WHERE Product2Id IN: setProductId AND CurrencyIsoCode =: currencyCode and isActive = true];
        if(lstPricebookEntry.size() == 0){
            throw new ManageLineItemControllerException('Pricebook Entry not found for the selected products.');
        }
        List<String> lstProductsWithoutPriceBook;
        for(PricebookEntry priceBookEntry : lstPricebookEntry){
            mapProductsByPriceBook.put(priceBookEntry.Product2Id, priceBookEntry.Id); 
        }
        Map<Id,Product2> mapProductsToSave = new Map<Id,Product2>([SELECT Id, Name FROM Product2 WHERE Id IN: setProductId]);
        for(OpportunityLineItem oppLineitem : lstProducts){
            if(mapProductsByPriceBook.get(oppLineitem.Product2Id) != null){
                oppLineitem.PricebookEntryId = mapProductsByPriceBook.get(oppLineitem.Product2Id);
                oppLineitem.Product2Id = null; 
            }else{
                if(lstProductsWithoutPriceBook != null && !lstProductsWithoutPriceBook.contains(mapProductsToSave.get(oppLineitem.Product2Id).Name)){
                    lstProductsWithoutPriceBook.add(mapProductsToSave.get(oppLineitem.Product2Id).Name);
                }else{
                    lstProductsWithoutPriceBook = new List<String>();
                    lstProductsWithoutPriceBook.add(mapProductsToSave.get(oppLineitem.Product2Id).Name);
                }
            }
        }
        if(lstProductsWithoutPriceBook != null){
            throw new ManageLineItemControllerException('Pricebook Entry not found for products - '+String.join(lstProductsWithoutPriceBook, ',' ));
        }        
        return lstProducts;
    }
    /************************************************************************************************************************************
        Author          : Chandra Teja
        Description     : We will validate whether running user can access manage product using this method.
        Created Date    : 12 December 2018 
        Issue No        : 
    **************************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult isValidForManageProductLightning(Id opportunityId){
      Opportunity opportunity = [SELECT Id, Name, StageName, OwnerId FROM Opportunity WHERE Id = : opportunityId];
        String validationMessage = isValidForManageProduct(opportunity.OwnerId, opportunity.StageName);
         return new DatabaseResult(validationMessage);
    }
    /************************************************************************************************************************************
        Author          : Chandra Teja
        Description     : We will validate whether running user can access manage product using this method.
        Created Date    : 5 December 2018 
        Issue No        : 
    **************************************************************************************************************************************/
    webservice static String isValidForManageProduct(Id oppOwnerId, String opportunityStage){
        String messageToReturn = '{"Success":false,"Message":"You must be the Opportunity Owner to access the Manage Products page."}';
        set<String> setAllowedOppStages = getAllowedOpportunityStages('IsValidStageForManageProduct');
        if(!(setAllowedOppStages.contains(opportunityStage.toLowerCase()))){
            if(oppOwnerId != UserInfo.getUserId()){           
                List<CustomPermission> lstCustomPermissions = [SELECT Id, DeveloperName, (SELECT Id, Parent.Name, Parent.Profile.Name FROM SetupEntityAccessItems WHERE Parent.Profile.Id =: UserInfo.getProfileId()) FROM CustomPermission WHERE DeveloperName = 'Can_Manage_Product'];
                if(lstCustomPermissions != null && lstCustomPermissions.size() > 0 && lstCustomPermissions[0].SetupEntityAccessItems != null && lstCustomPermissions[0].SetupEntityAccessItems.size()>0){
                    messageToReturn = '{"Success":true,"Message":""}';
                }  
            }else{
                messageToReturn = '{"Success":true,"Message":""}';
            } 
        }else{
            messageToReturn = '{"Success":false,"Message":"User can not perform this action on opportunity having '+opportunityStage+' stage."}';
        }
        return messageToReturn;
    }
    /************************************************************************************************************************************
        Author          : Chandra Teja
        Description     : We have moved all the client side queries to server side using this method
        Created Date    : 20 November 2018 
        Issue No        : ST-3011
    **************************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult getQueryResultForLabel(String label, Map<String, Object> filters){
        String query = '';
        Switch on label{
            WHEN 'PriceBookEntry'{
                query ='SELECT Id,Product2Id,CurrencyIsoCode FROM PriceBookEntry ';
                query += 'WHERE CurrencyIsoCode=\''+filters.get('CurrencyIsoCode')+'\'';
            }
            WHEN 'Building'{
                query = 'SELECT Id FROM Building__c WHERE Name LIKE \'%'+filters.get('Name')+'%\'';
            }
        }
        return String.isNotEmpty(query) ? (new DatabaseResult(LightningComponentController.getQueryData(query))) : new DatabaseResult(false, null, 'Something went wrong, please contact your system administrator');
    }
    /************************************************************************************************************************************
        Author          : Chandra Teja
        Description     : This method is used to retrive allowed opportunity stage to update total price and desired term length
        Created Date    : 28 November 2018 
        Issue No        : ST-3011
    **************************************************************************************************************************************/
    public static Set<String> getAllowedOpportunityStages(string settingName){
        Set<String> setFields = new Set<String>();
        Set<String> setAllowedStages = new Set<String>();
        setFields.add('Stages__c');
        List<OpportunityStagesSetting__mdt> oppStageSettings = (List<OpportunityStagesSetting__mdt>)Settings.getFieldsFromMDT('OpportunityStagesSetting__mdt', settingName, setFields);
        if(!oppStageSettings.isEmpty()){
            if(String.isNotEmpty(oppStageSettings[0].Stages__c)){
                setAllowedStages.addAll(Settings.splitStringToSet(oppStageSettings[0].Stages__c, ';'));
            }
        }
        return setAllowedStages;
    }
}