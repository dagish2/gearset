@isTest
public class SalesConsoleSettingsTest {
    public static testMethod void testCreateSettings(){
    	List<Setting__c> lstSetting = new List<Setting__c>();
        SalesConsoleSettings.createSettings();
        lstSetting = [select ID,Name from Setting__c];
        System.assertNotEquals(0, lstSetting.size());
        //System.assertEquals(74, lstSetting.size());
    }
}