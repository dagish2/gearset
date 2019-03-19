/************************************************************************************************************************************
    Author      :   Shivprasad Patil	
    Description :   
	Issue No    : 	ST-3397
    History		:
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1          6 Feburary 2019     Shivprasad             Initial Developement
**************************************************************************************************************************************/
@isTest
public class BuildingSelectorControllerTest {
/************************************************************************************************************************************
    Author         : Shivprasad Patil
    Description    : This method is setup for BuildingSelectorControllerTest.
    Created Date   : 6 Feb 2019 
    Issue No       : ST-3397
**************************************************************************************************************************************/
    @TestSetup
    public static void setup(){
        Market__c objMarket = new Market__c(Name = 'Test Portfolio');
        TestingUtility.insertWithAssert(objMarket, 'Portfolio not inserted');
        System.assertNotEquals(null, objMarket.Id);
        insert new Setting__c(Name='RestartLocation', Data__c = '{"'+objMarket.Id+'":"'+UserInfo.getuserid()+'"}');
    }
    
/************************************************************************************************************************************
    Author         : Shivprasad Patil
    Description    : This methods covers getSetup method of BuildingSelectorController class.
    Created Date   : 6 Feb 2019 
    Issue No       : ST-3397
**************************************************************************************************************************************/
    @isTest
    public static void verifyGetSetup(){
        DatabaseResult objResult = BuildingSelectorController.getSetup();
        System.assert(objResult.success);
        Map<String, Object> mapOfResult = (Map<String, Object>)objResult.data;
        Map<Id, sObject> mapOfBuildings = (Map<Id, sObject>)mapOfResult.get('mapSelectedMarkets'); 
        System.assertNotEquals(null, mapOfBuildings);
        System.assertEquals(1, mapOfBuildings.size());
        
        Map<Id, sObject> mapOfMarket = (Map<Id, sObject>)mapOfResult.get('mapOfMarket'); 
        System.assertNotEquals(null, mapOfMarket);
        System.assertEquals(1, mapOfMarket.size());
    }
    
/************************************************************************************************************************************
    Author         : Shivprasad Patil
    Description    : This methods covers GetRelatedBuildings method of BuildingSelectorController class.
    Created Date   : 6 Feb 2019 
    Issue No       : ST-3397
**************************************************************************************************************************************/
    @isTest
    public static void verifyGetRelatedBuildings(){
        Building__c objBuilding = new Building__c(City__c = 'Frankfurt', Country__c = 'Germany',Name = 'HE-Goetheplatz', CurrencyIsoCode = 'USD',Time_Zone__c = 'Europe/Amsterdam');
        TestingUtility.insertWithAssert(objBuilding);
        DatabaseResult objResult = BuildingSelectorController.getRelatedBuildings(new List<String>{objBuilding.Id});
        System.assert(objResult.success);
        List<sObject> lstOfBuilding = (List<sObject>)objResult.data;
        System.assertNotEquals(null, lstOfBuilding);
        System.assertEquals(1, lstOfBuilding.size());
    }

/************************************************************************************************************************************
    Author         : Shivprasad Patil
    Description    : This methods covers GetUserData method of BuildingSelectorController class.
    Created Date   : 6 Feb 2019 
    Issue No       : ST-3397
**************************************************************************************************************************************/
    @isTest
    public static void verifyGetUserData(){
        DatabaseResult objResult = BuildingSelectorController.getUserData(UserInfo.getuserid());
        System.assert(objResult.success);
        List<sObject> lstOfUser = (List<sObject>)objResult.data;
        System.assertNotEquals(null, lstOfUser);
        System.assertEquals(1, lstOfUser.size());
        
        objResult = BuildingSelectorController.getUserData(null);
        System.assert(!objResult.success);
    }
}