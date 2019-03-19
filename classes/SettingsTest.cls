/********************************************************************************************************************************
    Author 		: @hemanshu.shah@enzigma.com
    Description : This class should contain all test methods related to Settings 
    History		: --

-----------------------------------------------------------------------------------------------------------------------------------
	VERSION							DATE						AUTHOR 							DETAIL
  	1							    24,Apr 2016				    hemanshu shah 			        Initial Developement
***********************************************************************************************************************************/
@isTest
public class SettingsTest {
    
    static{ 
        Profile weworkSystemAdmin = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        Map<String,Object> userRecordMap1 = new Map<String,Object>();
        userRecordMap1.put('LastName','Last Name 1');
        userRecordMap1.put('Username','testweworkuser11@example.com');
        userRecordMap1.put('Email','testweworkuser1@example.com');
        userRecordMap1.put('CommunitynickName','test111'+system.now());
        user testUser1 = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, userRecordMap1, true);
    }
    
    public static Settings.FieldMappings getTestMappings(){
        Settings.FieldMappings settingsMapping = new Settings.FieldMappings();
        settingsMapping.version = 1;
        settingsMapping.mappings = new Map<String, Settings.MappedField>();
        settingsMapping.mappings.put('Name', new Settings.MappedField('Name'));
        settingsMapping.mappings.put('Lead_Source__c', new Settings.MappedField('WeWork.com', true));
        return settingsMapping;
    }
    
	/***************************************************************************************************************************
       Author 				: Hemanshu Shah
       Description 			: Tehst Method for Settings increase code coverage
       Created Date			: 24,Apr 2016
	   Last Modified By 	: Prashant Mane
	   Last Modified Date   : 02 Feb,2018
	******************************************************************************************************************************/
    @isTest
    public static void testSettingsforIncreaseCodeCoverage(){
        user testUser1=[Select Id,Name,UserName,Email From User Where UserName='testweworkuser11@example.com'];
        User getUserById=Settings.getUserById(testUser1.Id);
        system.assert(getUserById !=null);
        User getUserByEmail=Settings.getUserByEmail('testweworkuser1@example.com');
        system.assert(getUserByEmail !=null);
        getUserByEmail=Settings.getUserByEmail('testweworkuser_123@example.com');
        system.assertEquals(null, getUserByEmail);
        User getUserByName= Settings.getUserByName('Last Name 1');
        system.assert(getUserByName !=null);
        getUserByName= Settings.getUserByName('Last Name_123');
        system.assertEquals(null, getUserByName);
        Boolean getUserActive=Settings.getUserActive(testUser1.Id);
        system.assertEquals(true, getUserActive);
        List<User> lstAllUsers=Settings.getAllUsers();
        
        MySettings settingsMy = new MySettings();
        settingsMy.count = 10;
        settingsMy.timestamp = Date.today();
        settingsMy.name = 'Test';
        
        Setting__c setting = new Setting__c( Name = 'Test Settings', Data__c = JSON.serialize(settingsMy));
        insert setting;
        Setting__c settingName= Settings.getTest('Test Settings');
        System.assert(settingName !=null);
        Building__c objBuilding = new Building__c(
            City__c = 'Test',
            Name = 'NYC-Penn Station',          
            uuid__c = 'abc123');
        insert objBuilding;
        Building__c getBuildingById= Settings.getBuildingById(objBuilding.Id);
        system.assert(getBuildingById !=null);
        Building__c getBuildingByUUID=Settings.getBuildingByUUID('abc123');
        system.assert(getBuildingByUUID !=null);
        List<Building__c> lstBuildings=Settings.getAllBuildings();
        System.assertEquals(1, lstBuildings.size());
    }
    
	/*************************************************************************************************
       Author 				: Hemanshu Shah
       Description 			: test Settings Trigger Update UniqueKey
       Created Date			: 24,Apr 2016
	   Last Modified By 	: Prashant Mane
	   Last Modified Date   : 02 Feb,2018
	****************************************************************************************************/
	@isTest
	public static void testSettingsTriggerUpdateUniqueKey(){
        String strName = 'Test';
        Settings.FieldMappings fieldMappings = getTestMappings();
        String strData = JSON.serialize(fieldMappings);
        Setting__c setting = new Setting__c(Name = strName, Data__c = strData );
        insert setting;
        System.assert(setting.Id != null);        
        Setting__c setting2 = null;
        try{
            setting2 = new Setting__c(Name = strName, Data__c = strData );
            insert setting2;
        }
        catch(Exception ex){
            System.assert(true);
        }
        
        setting2 = new Setting__c(Name = strName + '2', Data__c = strData );
        insert setting2;
        System.assert(setting2.Id != null);
        
        try{
            setting2.Name = strName;
            update setting2;
        }
        catch(Exception ex){
            System.assert(true);
        }
	}
    
	/*************************************************************************************************
       Author 				: Hemanshu Shah
       Description 			: test Settings Caching
       Created Date			: 24,Apr 2016
	   Last Modified By 	: Prashant Mane
	   Last Modified Date   : 02 Feb,2018
	****************************************************************************************************/
    @isTest
    public static void testSettingsCaching(){
        String strName = 'FieldMappings:LeadToContact';
        Settings.FieldMappings fieldMappings = getTestMappings();
        
        Database.UpsertResult result = Settings.saveFieldMappings('LeadToContact', fieldMappings);
        System.assert(result.getId() != null);
        
        Integer iQueriesSoFar = Limits.getQueries();
        Setting__c setting = Settings.get(strName);
        System.assert(setting != null);
        System.assert(iQueriesSoFar + 1 == Limits.getQueries());
        
        setting = Settings.get(strName);
        System.assert(setting != null);
        System.assert(iQueriesSoFar + 1 == Limits.getQueries());
        
        Settings.FieldMappings mappings = Settings.getFieldMappings('LeadToContact');
        System.assert(mappings != null);
        Settings.MappedField mappedField = mappings.mappings.get('Name');
        System.assert(mappedField.fieldname == 'Name');
        
        setting = new Setting__c(Name = strName + '-2', Data__c = setting.Data__c );
        insert setting;
        System.assert(setting.Id != null);
        
        iQueriesSoFar = Limits.getQueries();
        Settings.LoadFieldMappings();
        System.assert(iQueriesSoFar + 1 == Limits.getQueries());
        mappings = Settings.getFieldMappings('LeadToContact');
        System.assert(mappings != null);
        mappedField = mappings.mappings.get('Name');
        System.assert(mappedField.fieldname == 'Name');
        System.assert(iQueriesSoFar + 1 == Limits.getQueries());
    }
    
	/*************************************************************************************************
       Author 				: Hemanshu Shah
       Description 			: test method for Load Settings
       Created Date			: 24,Apr 2016
	   Last Modified By 	: Prashant Mane
	   Last Modified Date   : 02 Feb,2018
	****************************************************************************************************/
    @isTest
    public static void testLoadSettings(){
        String strName = 'FieldMappings:LeadToContact';
        Settings.FieldMappings fieldMappings = getTestMappings();
        
        Database.UpsertResult result = Settings.saveFieldMappings('LeadToContact', fieldMappings);
        System.assert(result.getId() != null);
        
        Settings.LoadSettings(new List<String>{strName});
        integer iQueriesSoFar = Limits.getQueries();
        
        Setting__c setting = Settings.get(strName);
        System.assert( setting != null);
        System.assert( iQueriesSoFar == Limits.getQueries());
        
        Settings.LoadFieldMappings();
        iQueriesSoFar = Limits.getQueries();
        
        setting = Settings.get(strName);
        System.assert( setting != null);
        System.assert( iQueriesSoFar == Limits.getQueries());
    }
    
	/*************************************************************************************************
       Author 				: Hemanshu Shah
       Description 			: test method for Typed Setings
       Created Date			: 24,Apr 2016
	   Last Modified By 	: Prashant Mane
	   Last Modified Date   : 02 Feb,2018
	****************************************************************************************************/
    @isTest
    public static void testTypedSetings(){
        MySettings settingsMy = new MySettings();
        settingsMy.count = 10;
        settingsMy.timestamp = Date.today();
        settingsMy.name = 'Test';
        
        Setting__c setting = new Setting__c( Name = 'Test', Data__c = JSON.serialize(settingsMy));
        insert setting;
        
        settingsMy = (MySettings)Settings.get('Test', MySettings.class);
        System.assert(settingsMy.count == 10);
        System.assert(settingsMy.timestamp == Date.today());
        System.assert(settingsMy.name == 'Test');
    }
    public class MySettings {
        Integer count;
        Date timestamp;
        String name;
    }
    
    /*****************************************************************************************************************************************
        Author              :   Pragalbha Mahajan
        Description         :   This method is used to test fetchEmailTemplates method
        Created Date        :   01 October 2018
        Issue No            :   ST-2696
    ******************************************************************************************************************************************/
    @isTest
    public static void testFetchEmailTemplates(){
        User objUser = [SELECT Id, Name, Email FROM User WHERE Email =: 'testweworkuser1@example.com'];
        system.runAs(objUser){
            EmailTemplate objEmailTemplate = new EmailTemplate (developerName = 'test', FolderId = UserInfo.getUserId(), TemplateType= 'Text', Name = 'test'); 
            TestingUtility.insertWithAssert(objEmailTemplate);
            system.assertNotEquals(null, objEmailTemplate.Id);
            Settings.fetchEmailTemplates();
            EmailTemplate objEmailTemplateById = Settings.getEmailTemplateById(objEmailTemplate.Id);
            system.assertNotEquals(null, objEmailTemplateById);
            EmailTemplate objEmailTemplateById1 = Settings.getEmailTemplateById(objUser.Id);
            system.assertEquals(null, objEmailTemplateById1);
            EmailTemplate objEmailTemplateByName = Settings.getEmailTemplateByDeveloperName('test');
            system.assertNotEquals(null, objEmailTemplateByName);
            EmailTemplate objEmailTemplateByName1 = Settings.getEmailTemplateByDeveloperName('tst');
            system.assertEquals(null, objEmailTemplateByName1);
        }
    } 
    
  /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is usde to check is record value changed.
        Created Date  		:   12 December 2018		
  **************************************************************************************************************************************/ 
    @isTest
    public static void verifyIsChange(){     
        System.assertEquals(true, Settings.isChanged('Test', null));
        System.assertEquals(true, Settings.isChanged(null, 'test'));
        System.assertEquals(true, Settings.isChanged('null', 'test'));
        System.assertEquals(true, Settings.isChanged('test', 'null'));
        System.assertEquals(false, Settings.isChanged(null, null));
        System.assertEquals(false, Settings.isChanged('Test', 'Test'));
        System.assertEquals(false, Settings.isChanged('Test', 'test'));
    }
    
}