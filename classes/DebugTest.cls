@isTest
public class DebugTest {
    public testMethod static void testDebugLog(){
        Debug.Log('Test 1');
        
        MySettings settingsMy = new MySettings();
        settingsMy.count = 10;
        settingsMy.timestamp = Date.today();
        settingsMy.name = 'Test';
        
        Setting__c setting = new Setting__c( Name = 'Test Settings', Data__c = JSON.serialize(settingsMy));
        insert setting;
    }
    public class MySettings {
        Integer count;
        Date timestamp;
        String name;
    }
}