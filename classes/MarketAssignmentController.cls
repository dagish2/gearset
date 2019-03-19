/************************************************************************************************************************************
	Author		: 	Nikhil Mehta
	Description	: 	This class is used for assign market to sobject and update it.
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE	        	AUTHOR                     DETAIL
	1	    	4 December 2018		Nikhil Mehta            Initial Developement
**************************************************************************************************************************************/
global class MarketAssignmentController {
    public class MarketAssignmentControllerException extends Exception{}
    public static Boolean isInvoker = false;
    
    static {
        isInvoker = ApexDebugLog.registerRootInvoker(ApexDebugLog.InvokerType.AURA, 'MarketAssignmentController' + 'getsObjectPrefix', ApexDebugLog.InvokerType.AURA);        
    }
    
    /************************************************************************************************************************************
        Author              :   Nikhil Mehta
        Description         :   This method get market on account for webservice.
        Created Date  		:   17 December 2018
		Issue No.			:	ST-3200, ST-3256
    **************************************************************************************************************************************/    
    webservice static String getMarketForWebservice(Id recordId){
        return JSON.serialize(getMarket(recordId));
    }
    
     /************************************************************************************************************************************
        Author              :   Nikhil Mehta
        Description         :   This method get market on account for Lightning.
        Created Date  		:   17 December 2018
		Issue No.			:	ST-3200, ST-3256
    **************************************************************************************************************************************/    
    @AuraEnabled
    public static DatabaseResult getMarketForLightning(Id recordId){
        return new DatabaseResult(getMarket(recordId));
    }
    
    /************************************************************************************************************************************
        Author              :   Nikhil Mehta
        Description         :   This method returns map of object for recordId.
        Created Date  		:   17 December 2018
		Issue No.			:	ST-3200, ST-3256
    **************************************************************************************************************************************/    
    public static Map<String, Object> getMarket(Id recordId){
        Map<String, Object> mapResults = new Map<String, Object>();
        try{
            if(String.isBlank(recordId)){
                throw new MarketAssignmentControllerException('Record Id is Blank');
            }
            switch on recordId.getSObjectType().getDescribe().getName() {
                when 'Account' {
                    mapResults = checkValidMarket(new Account(Id = recordId));
                    mapResults.put('sObjectName', 'Account');
                }
                when 'Lead' {
                    mapResults = checkValidMarket(new Lead(Id = recordId));
                    mapResults.put('sObjectName', 'Lead');
                }
            }
            return mapResults;
        }catch(Exception pEx){
            ApexDebugLog.logException(pEx, '', 'MarketAssignmentController', 'UpdateMarketOnAccount');            
            mapResults.put('isValid', false);
            mapResults.put('errorMessage', pEx.getMessage());    
            return mapResults;
        }
    }
    
    /************************************************************************************************************************************
        Author              :   Nikhil Mehta
        Description         :   This method update market on sobject for webservice.
        Created Date  		:   17 December 2018
		Issue No.			:	ST-3200, ST-3256
    **************************************************************************************************************************************/    
    webservice static String updateMarketForWebservice(Id recordId, Id marketId, Id geographyId){
        return JSON.serialize(updateMarket(recordId, new Map<String, Object>{'marketId' => marketId, 'geographyId' => geographyId}));
    }
    
    /************************************************************************************************************************************
        Author              :   Nikhil Mehta
        Description         :   This method update market on sobject for Lightning.
        Created Date  		:   17 December 2018
		Issue No.			:	ST-3200, ST-3256
    **************************************************************************************************************************************/    
    @AuraEnabled
    public static DatabaseResult updateMarketForLightning(Id recordId, Map<String, Object> mapResult){
        return new DatabaseResult(updateMarket(recordId, mapResult));
    }
    
    /************************************************************************************************************************************
        Author              :   Nikhil Mehta
        Description         :   This method update market on sobject.
        Created Date  		:   17 December 2018
		Issue No.			:	ST-3200, ST-3256
    **************************************************************************************************************************************/    
    public static Map<String, Object> updateMarket(Id recordId, Map<String, Object> mapResult){
        Map<String, Object> mapResults = new Map<String, Object>();
        try{
            if(String.isBlank(recordId) || mapResult == null){
                throw new MarketAssignmentControllerException('Record Id or map is Blank');
            }
            sObject sObjectRec;
                switch on recordId.getSObjectType().getDescribe().getName() {
                    when 'Account' {
                        sObjectRec = new Account(Id = recordId, Update_HQ_Market_Status__c = 'Completed', Account_Market__c = String.valueOf(mapResult.get('marketId')), Geography__c = String.valueOf(mapResult.get('geographyId')), Market_Identified_By__c = UserInfo.getUserId(), Market_Identified_On__c = System.now());
                    }
                    when 'Lead'{
                        sObjectRec = new Lead(Id = recordId, Update_HQ_Market_Status__c = 'Completed', Lead_Market__c = String.valueOf(mapResult.get('marketId')), Geography__c = String.valueOf(mapResult.get('geographyId')), Market_Identified_By__c = UserInfo.getUserId(), Market_Identified_On__c = System.today());
                    }
                }
            if(sObjectRec != NULL){
                update sObjectRec;
                mapResults.put('isValid', true);
                mapResults.put('updated', true);
            }else{
                mapResults.put('isValid', false);
            }
            return mapResults;
        }catch(Exception pEx){
            ApexDebugLog.logException(pEx, '', 'MarketAssignmentController', 'UpdateMarketOnAccount');            
            mapResults.put('isValid', false);
            mapResults.put('errorMessage', pEx.getMessage());    
            return mapResults;
        }
    }
    
    /************************************************************************************************************************************
        Author              :   Nikhil Mehta
        Description         :   This method returns map of object, check market is valid or not for sObject record.
        Created Date  		:   17 December 2018
		Issue No.			:	ST-3200, ST-3256
    **************************************************************************************************************************************/    
    public static Map<String, Object> checkValidMarket(sObject record){
        Map<String, Object> mapResults = new Map<String, Object>();
        String marketFieldName;
        String addressFieldName;
        String cityFieldName;
        String stateFieldName;
        String countryFieldName;
        String sObjectName;
        List<SObject> records;
        switch on record {
            when Account objAccount {
                records = [SELECT Id, Account_Market__c, Unomy_Updated_DateTime__c, Unomy_Location_Address__c, Unomy_Location_City__c, Unomy_Location_State__c, Unomy_Location_Country__c, BillingAddress, BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode FROM Account WHERE Id =: objAccount.Id];
                marketFieldName = 'Account_Market__c';
                addressFieldName = 'BillingAddress';
                cityFieldName = 'BillingCity';
                stateFieldName = 'BillingState';
                countryFieldName = 'BillingCountry';
                sObjectName = 'Account';
            }
            when Lead objLead {
                records = [SELECT Id, Lead_Market__c, Unomy_Updated_DateTime__c, Unomy_Location_Address__c, Unomy_Location_City__c, Unomy_Location_State__c, Unomy_Location_Country__c, Address, Street, City, State, Country, PostalCode FROM Lead WHERE Id =: objLead.Id];
                marketFieldName = 'Lead_Market__c';
                addressFieldName = 'Address';
                cityFieldName = 'City';
                stateFieldName = 'State';
                countryFieldName = 'Country';
                sObjectName = 'Lead';
            }
        }
        
        if(!records.isEmpty()){
            record = records[0];
            String marketId = getString(record.get(marketFieldName));
            Object address = record.get(addressFieldName) != null ? record.get(addressFieldName) : null;
            String city = getString(record.get(cityFieldName));
            String state = getString(record.get(stateFieldName));
            String country = getString(record.get(countryFieldName));
            if((String.isBlank(String.valueOf(record.get('Unomy_Updated_DateTime__c')))) && (address == null && String.isBlank(city) && String.isBlank(state) &&  String.isBlank(country))){
                mapResults.put('isValid', false);
                mapResults.put('errorMessage', 'We can not find the HQ Market, '+sObjectName+' does not have any Unomy or Billing address information, Please update the Billing Address.');  
            }else{
                Map<Id, Id> mapGeography = MarketAssignmentHandler.getSObjectRelatedGeographyId(records);
                if(!mapGeography.isEmpty() && String.isNotBlank(String.valueOf(record.get('Id')))){
                    Map<Id, Market__c> mapMarkets = MarketAssignmentHandler.getSObjectRelatedMarket(mapGeography);
                    if(!mapMarkets.isEmpty() && mapMarkets.get(String.valueOf(record.get('Id'))) != NULL){
                        Market__c marketRec = mapMarkets.get(String.valueOf(record.get('Id')));
                        if(marketRec != null && String.isNotBlank(marketId) && (marketId.equals(String.valueOf(marketRec.Id).substring(0,15)) || marketId.equals(marketRec.Id))){
                            mapResults.put('isValid', false);
                            mapResults.put('errorMessage', 'The correct HQ Market is already present on '+sObjectName+', You don\'t need to update it.');
                        }else if(marketRec != null){
                            mapResults.put('marketId', marketRec.Id);
                            mapResults.put('marketName', marketRec.Name);
                            mapResults.put('geographyId', mapGeography.get(String.valueOf(record.get('Id'))));
                            mapResults.put('isValid', true);
                        }
                    }else{
                        mapResults.put('isValid', false);
                        mapResults.put('errorMessage', 'Unfortunately we cannot find a HQ Market, There is no Portfolio defined in the system. Please contact your System Administrator');
                    }
                }else{
                    mapResults.put('isValid', false);
                    mapResults.put('errorMessage', 'Unfortunately we cannot find a HQ Market, '+sObjectName+' does not have adequate Unomy or HQ address information. Please contact your System Administrator');
                }
            }
        }
        Debug.log('mapResults==>'+mapResults);
        return mapResults;
    }
    
    public static String getString(Object fieldValue){
        String value = String.valueOf(fieldValue);
        if(String.isNotBlank(value)){
            return value;
        }
        return null;
    }
}