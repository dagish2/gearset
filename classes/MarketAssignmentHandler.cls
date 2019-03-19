/************************************************************************************************************************************
	Author		: 	Nikhil Mehta
	Description	: 	This is handler class for MarketAssignmentController.
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE	        	AUTHOR                     DETAIL
	1	    	4 December 2018		Nikhil Mehta            Initial Developement
**************************************************************************************************************************************/
public class MarketAssignmentHandler {
	/************************************************************************************************************************************
        Author              :   Nikhil Mehta
        Description         :   This method returns List depends on boolean value it will update market on list of sobjects.
        Created Date  		:   04 December 2018
		Issue No.			:	ST-3200
    **************************************************************************************************************************************/    
    public static List<sObject> updateMarketOnSObject(List<sObject> records, Boolean updateRecords){
        Map<Id, Id> mapGeography = MarketAssignmentHandler.getSObjectRelatedGeographyId(records);
        Debug.log('mapGeography value---'+mapGeography);
        Map<Id, Market__c> mapMarkets = MarketAssignmentHandler.getSObjectRelatedMarket(mapGeography);
        Debug.log('mapMarkets value---'+mapMarkets);
        List<sObject> lstSObjectsToUpdate = new List<sObject>();
        for(sObject record : records){
            Id recordId = String.valueOf(record.get('Id'));
            if((!mapMarkets.isEmpty() && mapMarkets.get(recordId) != NULL) || (!mapGeography.isEmpty() && mapGeography.get(recordId) != NULL)){
                switch on record {
                    when Account accountRec {
                        lstSObjectsToUpdate.add(new Account(Id = recordId, Account_Market__c = mapMarkets.get(recordId) != NULL ? mapMarkets.get(recordId).Id : NULL, Geography__c = mapGeography.get(recordId), Market_Identified_On__c = System.now()));
                    }
                    when Lead leadRec {
                        lstSObjectsToUpdate.add(new Lead(Id = recordId, Lead_Market__c = mapMarkets.get(recordId) != NULL ? mapMarkets.get(recordId).Id : NULL,  Geography__c = mapGeography.get(recordId), Market_Identified_On__c = System.now()));
                    }
                }
            }
        }
        if(!lstSObjectsToUpdate.isEmpty()){
            if(updateRecords){
                Database.update(lstSObjectsToUpdate);
            }
            return lstSObjectsToUpdate;
        }
        return NULL;
    }
    
    /************************************************************************************************************************************
        Author              :   Nikhil Mehta
        Description         :   This method returns market for sobject.
        Created Date  		:   04 December 2018
    **************************************************************************************************************************************/    
    public static Market__c getSObjectRelatedMarket(sObject record){
        Map<Id, Market__c> mapMarkets = getSObjectRelatedMarket(new List<sObject>{ record });
        return mapMarkets.isEmpty() ? NULL : mapMarkets.get(String.valueOf(record.get('Id')));
    }
    
    /************************************************************************************************************************************
        Author              :   Nikhil Mehta
        Description         :   This method returns map sobject id and geography id for list sobjects.
        Created Date  		:   17 December 2018
		Issue No.			:	ST-3200
    **************************************************************************************************************************************/    
    public static Map<Id, Id> getSObjectRelatedGeographyId(List<sObject> lstRecords){
        Map<Id, Id> mapGeography = new Map<Id, Id>();
        Set<Id> setIds = new Set<Id>();
        for(sObject record : lstRecords){
            setIds.add(String.valueOf(record.get('Id')));
        }
        if(!setIds.isEmpty()){
            Map<Id, Map<String, String>> mapSobjectsAddresses = getSObjectAddresses(setIds);
            Debug.log('mapSobjectsAddresses value---'+mapSobjectsAddresses);
            if(mapSobjectsAddresses != null && !mapSobjectsAddresses.isEmpty()){
                mapGeography.putAll(GeographyHandler.getGeogrphies(mapSobjectsAddresses));
            }
        }
        return mapGeography;
    }
    
    /************************************************************************************************************************************
        Author              :   Nikhil Mehta
        Description         :   This method returns map sobject id and market for map of record id and grography id.
        Created Date  		:   17 December 2018
		Issue No.			:	ST-3200
    **************************************************************************************************************************************/    
    public static Map<Id, Market__c> getSObjectRelatedMarket(Map<Id, Id> mapGeography){
        Map<Id, Market__c> mapMarkets = new Map<Id, Market__c>();
        if(!mapGeography.isEmpty()){
            Set<Id> setGeographies = new Set<Id>();
            for(Id geographyId : mapGeography.values()){
                if(String.isNotBlank(geographyId)){
                    setGeographies.add(geographyId);
                }
            }
            Map<Id, Geography__c> mapGeographies = new Map<Id, Geography__c>([SELECT Id, Nearest_Building__c, Nearest_Building__r.Id, Nearest_Building__r.Name, Nearest_Building__r.Market__r.Id, Nearest_Building__r.Market__r.Name FROM Geography__c WHERE Id IN : setGeographies]);
            for(Id recordId : mapGeography.keySet()){
                mapMarkets.put(recordId, NULL);
                Id geographyId = mapGeography.get(recordId);
                Geography__c geographyRecWithData;
                if(String.isNotBlank(geographyId)){
                    geographyRecWithData = mapGeographies.get(geographyId);
                }
                if(geographyRecWithData != NULL && geographyRecWithData.Nearest_Building__r != NULL && geographyRecWithData.Nearest_Building__r.Market__r != NULL){
                    mapMarkets.put(recordId, geographyRecWithData.Nearest_Building__r.Market__r);
                }
            }
        }
        return mapMarkets;
    }
    
    /************************************************************************************************************************************
        Author              :   Nikhil Mehta
        Description         :   This method returns map sobject id and market for list sobjects.
        Created Date  		:   04 December 2018
		Issue No.			:	ST-3200
    **************************************************************************************************************************************/    
    public static Map<Id, Market__c> getSObjectRelatedMarket(List<sObject> lstRecords){
        return getSObjectRelatedMarket(getSObjectRelatedGeographyId(lstRecords));
    }
    
    /************************************************************************************************************************************
        Author              :   Nikhil Mehta
        Description         :   This method map id with addresses for set of sobjects id.
        Created Date  		:   04 December 2018
		Issue No.			:	ST-3200
    **************************************************************************************************************************************/    
    public static Map<Id, Map<String, String>> getSObjectAddresses(Set<Id> setIds){
        if(!setIds.isEmpty()){
            Set<Id> setAccountIds = new Set<Id>();
            Set<Id> setLeadIds = new Set<Id>();
            for(Id recordId : setIds){
                switch on recordId.getSObjectType().getDescribe().getName() {
                    when 'Account' {
                        setAccountIds.add(recordId);
                    }
                    when 'Lead'{
                        setLeadIds.add(recordId);
                    }
                }
            }
            
            Map<Id, Account> mapAccounts = setAccountIds.size() > 0 ? new Map<Id, Account>([SELECT Id, Unomy_Updated_DateTime__c, Unomy_Location_Address__c, Unomy_Location_City__c, Unomy_Location_State__c, Unomy_Location_Country__c, BillingAddress, BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode FROM Account WHERE Id IN :setAccountIds]) : new Map<Id, Account>();
            Map<Id, Lead> mapLeads = setLeadIds.size() > 0 ? new Map<Id, Lead>([SELECT Id, Unomy_Updated_DateTime__c, Unomy_Location_Address__c, Unomy_Location_City__c, Unomy_Location_State__c, Unomy_Location_Country__c, Address, Street, City, State, Country, PostalCode FROM Lead WHERE Id IN :setLeadIds AND IsConverted = false]): new Map<Id, Lead>();
            Map<Id, Map<String, String>> mapIdWithAddresses = new Map<Id, Map<String, String>>();
            Map<String, String> mapAddress;
            for(Id recordId : setIds){
                mapIdWithAddresses.put(recordId, NULL);
                mapAddress = new Map<String, String>();
                Account accountRec;
                Lead LeadRec;
                sObject record;
                switch on recordId.getSObjectType().getDescribe().getName() {
                    when 'Account' {
                        accountRec = mapAccounts.containsKey(recordId) ? mapAccounts.get(recordId) : mapAccounts.containsKey(Id.valueOf(recordId)) ? mapAccounts.get(Id.valueOf(recordId)) : NULL;
                        record = accountRec;
                    }
                    when 'Lead'{
                        LeadRec = mapLeads.containsKey(recordId) ? mapLeads.get(recordId) : mapLeads.containsKey(Id.valueOf(recordId)) ? mapLeads.get(Id.valueOf(recordId)) : NULL;
                        record = LeadRec;
                    }
                }
                if(record != NULL && record.get('Unomy_Updated_DateTime__c') != NULL && ((String.isNotBlank(String.valueOf(record.get('Unomy_Location_State__c'))) &&  String.isNotBlank(String.valueOf(record.get('Unomy_Location_City__c')))) || (String.isNotBlank(String.valueOf(record.get('Unomy_Location_City__c'))) &&  String.isNotBlank(String.valueOf(record.get('Unomy_Location_State__c')))) || (String.isNotBlank(String.valueOf(record.get('Unomy_Location_Country__c')))))){                    
                    mapAddress.put('address', getValue(String.valueOf(record.get('Unomy_Location_Address__c'))));
                    mapAddress.put('city', getValue(String.valueOf(record.get('Unomy_Location_City__c'))));
                    mapAddress.put('state', getValue(String.valueOf(record.get('Unomy_Location_State__c'))));
                    mapAddress.put('country', getValue(String.valueOf(record.get('Unomy_Location_Country__c'))));
                    if(accountRec != NULL && accountRec.BillingAddress != null && String.isBlank(mapAddress.get('address')) && String.isBlank(mapAddress.get('city')) && String.isBlank(mapAddress.get('state')) &&  String.isBlank(mapAddress.get('country'))){                        
                        setBillingAddressDataInMap(mapAddress, accountRec, null);  
                    }else if(LeadRec != NULL && LeadRec.Address != null && String.isBlank(mapAddress.get('address')) && String.isBlank(mapAddress.get('city')) && String.isBlank(mapAddress.get('state')) &&  String.isBlank(mapAddress.get('country'))){
                        setBillingAddressDataInMap(mapAddress, NULL, LeadRec);
                    }
                }else if(accountRec != NULL && accountRec.BillingAddress != NULL){
                    setBillingAddressDataInMap(mapAddress, accountRec, null);
                }else if(LeadRec != NULL && LeadRec.Address != NULL){
                    setBillingAddressDataInMap(mapAddress, NULL, LeadRec);
                }
                if(!mapAddress.isEmpty()){
                    mapIdWithAddresses.put(recordId, mapAddress);
                }
            }
            return mapIdWithAddresses;
        }
        return NULL;
    }
    
    /************************************************************************************************************************************
        Author              :   Nikhil Mehta
        Description         :   This method put address in map for account and lead.
        Created Date  		:   04 December 2018
		Issue No.			:	ST-3200
    **************************************************************************************************************************************/    
    public static void setBillingAddressDataInMap(Map<String, String> mapAddress, Account accountRec, Lead leadRec){
        if(accountRec != NULL){
            getMappedAddress(accountRec.BillingStreet, accountRec.BillingCity, accountRec.BillingState, accountRec.BillingCountry, accountRec.BillingPostalCode, mapAddress);
        }else if(leadRec != NULL){
            getMappedAddress(leadRec.Street, leadRec.City, leadRec.State, leadRec.Country, leadRec.PostalCode, mapAddress);
        }
    }
    /************************************************************************************************************************************
        Author              :   Nikhil Mehta
        Description         :   This method check address value and put in map.
        Created Date  		:   04 December 2018
		Issue No.			:	ST-3200
    **************************************************************************************************************************************/    
    public static void getMappedAddress(String street, String city, String state, String country, String zip, Map<String, String> mapAddress){
        if((String.isNotBlank(state) &&  String.isNotBlank(city)) || (String.isNotBlank(city) &&  String.isNotBlank(country)) || (String.isNotBlank(country))){
            mapAddress.put('address', getValue(street));
            mapAddress.put('city', getValue(city));
            mapAddress.put('state', getValue(state));
            mapAddress.put('country', getValue(country));
            mapAddress.put('zip', getValue(zip));
        }   
    }
    
    /************************************************************************************************************************************
        Author              :   Nikhil Mehta
        Description         :   This method returns string and if blank then return null.
        Created Date  		:   04 December 2018
		Issue No.			:	ST-3200
    **************************************************************************************************************************************/    
    public static String getValue(String fieldValue){
        if(String.isNotBlank(fieldValue)){
            return fieldValue;
        }
        return NULL;        
    }
}