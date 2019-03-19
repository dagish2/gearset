/*
 * @ Created By : Anant Kumar
 * @ Created Date : 20 June 2016
 */
 
@isTest
private class ReferenceHandlerTest {
	static{
        SalesConsoleSettings.createSettings();
		/*ReferenceSettings settingsMy = new ReferenceSettings();
        settingsMy.expireafter = 10;

        Setting__c setting = new Setting__c( Name = 'ReferenceSettings', Data__c = JSON.serialize(settingsMy));
        insert setting;
        
        List<Setting__c> lstSettings = new List<Setting__c>();
        lstSettings.add(new Setting__c(Name = 'AccountCleansingSetting',Data__c = '{"starts_with":["The","An","A"],"ends_with":["pvt","ltd"],"specialCharacters":"@#^&*!():?/><"}'));
        insert lstSettings;*/
	}

    public static testMethod void checkSettings(){
	/*ReferenceSettings settingsNew;
		settingsNew = (ReferenceSettings) Settings.get('ReferenceSettings',ReferenceSettings.class);
        System.assert(settingsNew.expireafter == 10);*/
    }

    static testMethod void testReferenceHandler()
    {
        Account accRec = TestingUtility.createAccount('strAccountName', true);
        Contact referrer1 = new Contact();
        referrer1.LastName = 'referrer1';
        referrer1.Email = 'referrer1@example.com';
        TestingUtility.insertWithAssert(referrer1);
        
        Contact referrer2 = new Contact();
        referrer2.LastName = 'referrer1';
        referrer2.Email = 'referrer2@example.com';
        TestingUtility.insertWithAssert(referrer2);
        
        Referral__c reference1 = new Referral__c();
        reference1.Referral_Email__c= 'reference1@example.com';
        reference1.IsActive__c = true;
        reference1.Referrer__c = referrer1.Id;
        reference1.Expires_On__c = Date.today().addDays(10);
        TestingUtility.insertWithAssert(reference1);
        
        Referral__c reference2 = new Referral__c();
        reference2.Referral_Email__c= 'reference2@example.com';
        reference2.IsActive__c = false;
        reference2.Referrer__c = referrer1.Id;
        reference2.Expires_On__c = Date.today().addDays(10);
        TestingUtility.insertWithAssert(reference2);
        
        Set<String> setEmails = new Set<String>();
        setEmails.add(reference1.Referral_Email__c);
        
        ReferenceHandler.ExtendReference(setEmails);

        Referral__c existingReference = [SELECT Id, Name, Expires_On__c FROM Referral__c WHERE Id=:reference1.Id];
        Debug.Log('Test : reference1 ::: ' + existingReference);
        Time tNow = Time.newInstance(0, 0, 0, 0);
        DateTime todayTime = DateTime.newInstance(Date.today(), tNow);
        //System.assertEquals(todayTime.addDays(60), existingReference.Expires_On__c);

        ReferenceHandler.ExtendReference(reference1.Id,Date.today(), Date.today());

        Map <string,Id> mapReferrer = ReferenceHandler.getActiveReference(setEmails);
        System.assertEquals(referrer1.Id, mapReferrer.get(reference1.Referral_Email__c));
        
        System.assertEquals(referrer1.Id, ReferenceHandler.getActiveReference(reference1.Referral_Email__c));
        System.assertEquals(null, ReferenceHandler.getActiveReference(reference2.Referral_Email__c));
    }
    
    static testMethod void PreventDuplicateActiveReference()
    {
        Account accRec = TestingUtility.createAccount('strAccountName', true);
        Contact referrer1 = new Contact();
        referrer1.LastName = 'referrer1';
        referrer1.Email = 'referrer1@example.com';
        TestingUtility.insertWithAssert(referrer1);
        
        Contact referrer2 = new Contact();
        referrer2.LastName = 'referrer1';
        referrer2.Email = 'referrer2@example.com';
        TestingUtility.insertWithAssert(referrer2);
        
        Referral__c reference1 = new Referral__c();
        reference1.Referral_Email__c= 'referenced1@example.com';
        reference1.IsActive__c = true;
        reference1.Referrer__c = referrer1.Id;
        reference1.Expires_On__c = Date.today().addDays(60);
        TestingUtility.insertWithAssert(reference1);
       
       try{ 
        reference1 = new Referral__c();
        reference1.Referral_Email__c= 'referenced123@example.com';
        reference1.IsActive__c = true;
        reference1.Referrer__c = referrer1.Id;
        reference1.Expires_On__c = Date.today().addDays(60);
        TestingUtility.insertWithAssert(reference1);
       }
       catch(Exception ex){
       	 Debug.log('Exception::'+ex);
       }
    }

	public class ReferenceSettings {
		public Integer expireafter{get;Set;}
	}
}