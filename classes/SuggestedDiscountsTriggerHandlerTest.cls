/************************************************************************************************************************************
Author : Mayuresh Ghodke
Description : ---
History:
----------------------------------------------------------------------------------------------------------------------------------
VERSION	DATE	        AUTHOR           DETAIL
1	05,July 2016	Mayuresh Ghodke  Initial Developement
**************************************************************************************************************************************/

@isTest
public class SuggestedDiscountsTriggerHandlerTest {
    static Boolean settingsInitialized = false;
    static{
        SalesConsoleSettings.createSettings();
    }
    
    /************************************************************************************************************************************
Author :
Issue No :
Description : 
Created Date :
Last Modified Date	: 2 Feb, 2018
Last Modified By	: Shivprasad Patil
**************************************************************************************************************************************/

    public static testMethod void verifysetBuildingLocation(){
        List<Building__c> lstBuildings = new List<Building__c>();
        
    	Building__c objbuilding1 = new Building__c();
        objbuilding1.Name = 'Test Building 1';
        objbuilding1.CurrencyIsoCode = 'USD';
        objbuilding1.UUID__c = 'Test UUID 1';
        lstBuildings.add(objbuilding1);
        
        Building__c objbuilding2 = new Building__c();
        objbuilding2.Name = 'Test Building 2';
        objbuilding2.CurrencyIsoCode = 'USD';
        objbuilding2.UUID__c = 'test uuid 2';
        lstBuildings.add(objbuilding2);
        
        insert lstBuildings;
        
   		List<Suggested_Discounts__c> lstSuggeestedDiscounts = new List<Suggested_Discounts__c>();
        Suggested_Discounts__c objsuggesteddiscount = preparesuggestedDiscountObject(1, 2, 3, 4, 5, 6, 7, 8, 9, '1-2 Desks', objbuilding1.UUID__c);
        lstSuggeestedDiscounts.add(objsuggesteddiscount);
        insert lstSuggeestedDiscounts;
        System.assertEquals(objbuilding1.ID, [SELECT Id, Location__c FROM Suggested_Discounts__c WHERE Location_UUID__c =: objbuilding1.UUID__c].Location__c);
        
        objsuggesteddiscount.Location_UUID__c = objbuilding2.UUID__c;
        update objsuggesteddiscount;
        System.assertEquals(objbuilding2.ID, [SELECT Id, Location__c FROM Suggested_Discounts__c WHERE Location_UUID__c =: objbuilding2.UUID__c].Location__c);
    }
    
/************************************************************************************************************************************
Author :
Issue No :
Description : 
Created Date :
Last Modified Date	: 2 Feb, 2018
Last Modified By	: Shivprasad Patil
**************************************************************************************************************************************/
    
    public static Suggested_Discounts__c preparesuggestedDiscountObject(decimal A12M, decimal A24M, decimal A6M, decimal C12M, decimal C24M, decimal C6M, decimal SA12M, decimal SA24M, decimal SA6M, String SKU, String LocationUUID){
        Suggested_Discounts__c objsuggesteddiscount = new Suggested_Discounts__c();
        objsuggesteddiscount.A12M__c = A12M;
        objsuggesteddiscount.A24M__c = A24M;
        objsuggesteddiscount.A6M__c  = A6M;
        objsuggesteddiscount.C12M__c = C12M;
        objsuggesteddiscount.C24M__c = C24M;
        objsuggesteddiscount.C6M__c  = C6M;
        objsuggesteddiscount.Location_UUID__c = LocationUUID;
        objsuggesteddiscount.SA12M__c = SA12M;
        objsuggesteddiscount.SA24M__c = SA24M;
        objsuggesteddiscount.SA6M__c = SA6M;
        objsuggesteddiscount.SKU__c = SKU;
        return objsuggesteddiscount;
    }
}