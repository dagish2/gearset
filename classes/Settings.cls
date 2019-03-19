/* Created by @hemanshu.shah@enzigma.com on 24 Apr 2016
* This class should contain all the triggers related to Settings
* As well as static methods to retreive Settings with Caching for optimized usage.
* 
*/

public class Settings {
    public static List<Product2> lstProducts;
    public static List<User> lstUsers;    
	public static Map<Id,User> mapUserById = new Map<Id,User>();
	public static Map<String,User> mapUserByName = new Map<String,User>();
	public static Map<String,User> mapUserByEmail = new Map<String,User>();
    public static Map<Id,User> mapAllUsersById = new Map<Id,User>();
    public static List<EmailTemplate> lstEmailTemplates;
    public static Map<Id,EmailTemplate> mapEmailTemplateById = new Map<Id,EmailTemplate>();
    public static Map<String,EmailTemplate> mapEmailTemplateByDeveloperName = new Map<String,EmailTemplate>();
    
    public static List<Group> lstQueues;
    public static Map<Id, Group> mapQueueById = new Map<Id, Group>();
	public static Map<String, Group> mapQueueByName = new Map<String, Group>();
    
    public static List<Building__c> lstBuildings;
    public static Map<Id,Building__c> mapBuildingById = new Map<Id,Building__c>();
    public static Map<String,Building__c> mapBuildingByUUID = new Map<String,Building__c>();
    public static Map<String,Building__c> mapBuildingByEmail = new Map<String,Building__c>();
    public static Map<String, List<Product2>> mapProductsByProductCode = new Map<String, List<Product2>>(); 
    public static Map<Id, Product2> mapProductsById = new Map<Id, Product2>();
    
    public static List<MetadataSetting__mdt> lstMetadasettings;
    public static Map<String, MetadataSetting__mdt> mapMetadataSettings = new Map<String, MetadataSetting__mdt>();
    
    /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is used to get all journey metadata by developer name.
      	Created Date  		:   28 Nov 2018 
        Last Modified By    :   Krishana Tupe
 	*************************************************************************************************************************************/
    public static MetadataSetting__mdt getMetadataSettingByDevName(String strDevName){
        if(lstMetadasettings == null){           
            lstMetadasettings = [SELECT Id, DeveloperName, Data__c FROM MetadataSetting__mdt];
        }       
        if(lstMetadasettings != null && !lstMetadasettings.isEmpty()){
            for(MetadataSetting__mdt objMetadataSetting : lstMetadasettings){
                mapMetadataSettings.put(objMetadataSetting.DeveloperName.toLowerCase(), objMetadataSetting);
            }    
        } 
        if(mapMetadataSettings != null && mapMetadataSettings.containsKey(strDevName.toLowerCase())){
            return  mapMetadataSettings.get(strDevName.toLowerCase()); 
        }
        return null;
    }
    
   /************************************************************************************************************************************
    Author 				: 	Pragalbha Mahajan
    Description 		: 	This method is used to get Products by productcode
    Issue No.			:	ST-3076
	Created Date		:	20 November 2018
    **************************************************************************************************************************************/     
    public static List<Product2> getProductsByProductCode(String productCode){
        getAllProducts();
        if(mapProductsByProductCode != null && mapProductsByProductCode.containskey(productCode)){
            return mapProductsByProductCode.get(productCode);
        }
        return null;
    }
    
    /************************************************************************************************************************************
    Author 				: 	Pragalbha Mahajan
    Description 		: 	This method is used to get all Products
    Issue No.			:	ST-3076
	Created Date		:	20 November 2018
    **************************************************************************************************************************************/    
    public static List<Product2> getAllProducts(){
        if(lstProducts == null){
            lstProducts  =  [SELECT Id, Name, CurrencyIsoCode, Product_Category__c, Family, Product_Type__c, Default_Product_Category__c, ProductCode FROM Product2 ];        
            for(Product2 objProduct : lstProducts){
                mapProductsById.put(objProduct.Id, objProduct);
                if(String.isNotBlank(objProduct.ProductCode)){
                    if(!mapProductsByProductCode.containskey(objProduct.ProductCode)){
                        mapProductsByProductCode.put(objProduct.ProductCode, new List<Product2>()); 
                    }
                    mapProductsByProductCode.get(objProduct.ProductCode).add(objProduct);
                }
            }
        }
        return lstProducts;
    }
    
    public static void fetchQueues(){
        if(lstQueues==null){
            lstQueues = [Select Id, Name, Type From Group WHERE Type = 'Queue'];
            for(Group groupRec : lstQueues){
                mapQueueById.put(groupRec.Id, groupRec);
                mapQueueByName.put(groupRec.Name, groupRec);
            }
        }
    }
    
    public static Group getQueueById(Id queueId){
        fetchQueues();
        if(mapQueueById.containsKey(queueId)){
            return mapQueueById.get(queueId);
        }else{
            return null;
        }
    }
    
    public static Group getQueueByName(String name){
        fetchQueues();
        if(mapUserByName.containsKey(name)){
            return mapQueueByName.get(name);
        }else{
            return null;
        }
    }
    
    public static void fetchUsers(){
        fetchAllUsers();
    }
    
    /*****************************************************************************************************************************************
        Author              :   Pragalbha Mahajan
        Description         :   This method is used to fetch all(Active/Inactive) Users.
        Created Date        :   01 October 2018
        Issue No            :   ST-2795
    ******************************************************************************************************************************************/
    public static List<User> fetchAllUsers(){
        if(lstUsers==null){
            lstUsers = [Select Id, Name, Email, UserRole.Name,Sales_Role__c, Sales_Pod__c, IsActive, ProfileId, Profile.Name, TimeZoneSidKey from User];
            for(User u:lstUsers){
                mapAllUsersById.put(u.Id, u);
                if(u.IsActive){
                    mapUserById.put(u.Id,u);
                    mapUserByName.put(u.Name,u);
                    mapUserByEmail.put(u.Email,u);
                }
            }
        }
        return lstUsers;
    }
    
    public static User getUserById(Id userId){        
        fetchUsers();      
        if(mapAllUsersById.containsKey(userId)){
            return mapAllUsersById.get(userId);
        }else{
            return null;
        }
    }
    
    public static User getUserByName(String userName){
        fetchUsers();
        if(mapUserByName.containsKey(userName)){
            return mapUserByName.get(userName);
        }else{
            return null;
        }
    }
    
    public static User getUserByEmail(String userEmail){
        fetchUsers();
        if(mapUserByEmail.containsKey(userEmail)){
            return mapUserByEmail.get(userEmail);
        }else{
            return null;
        }
    }
    
    public static Boolean getUserActive(Id userId){
        fetchUsers();
        if(String.isNotBlank(userId) && (String.valueOf(userId).toLowerCase().startsWith('00g') || mapUserById.containsKey(userId))){
            return true;
        }else{
            return false;
        }
    }
    
    public static List<User> getAllUsers(){
        fetchUsers();
        return lstUsers;
    }
    
    /*****************************************************************************************************************************************
        Author              :   Pragalbha Mahajan
        Description         :   This method is used to fetch email templates.
        Created Date        :   01 October 2018
        Issue No            :   ST-2696
    ******************************************************************************************************************************************/
    public static void fetchEmailTemplates(){
        if(lstEmailTemplates==null){
            lstEmailTemplates = [SELECT Id, Name, Markup, DeveloperName, IsActive FROM EmailTemplate];
            for(EmailTemplate objEmailTemplate: lstEmailTemplates){
                mapEmailTemplateById.put(objEmailTemplate.Id, objEmailTemplate);
                mapEmailTemplateByDeveloperName.put(objEmailTemplate.DeveloperName, objEmailTemplate);
            }
        }
    }
    
    /*****************************************************************************************************************************************
        Author              :   Pragalbha Mahajan
        Description         :   This method is used to fetch email template by Id.
        Created Date        :   01 October 2018
        Issue No            :   ST-2696
    ******************************************************************************************************************************************/
    public static EmailTemplate getEmailTemplateById(Id EmailTemplateId){
        fetchEmailTemplates();       
        if(mapEmailTemplateById.containsKey(EmailTemplateId)){
            return mapEmailTemplateById.get(EmailTemplateId);            
        }else{
            return null;
        }
    }
    
    /*****************************************************************************************************************************************
        Author              :   Pragalbha Mahajan
        Description         :   This method is used to fetch email template by Name.
        Created Date        :   01 October 2018
        Issue No            :   ST-2696
    ******************************************************************************************************************************************/
    public static EmailTemplate getEmailTemplateByDeveloperName(String developerName){
        fetchEmailTemplates();       
        if(mapEmailTemplateByDeveloperName.containsKey(developerName)){
            return mapEmailTemplateByDeveloperName.get(developerName);            
        }else{
            return null;
        }
    }
    
    /*
    *   Created By      : Amol Darekar
    *   Created Date    : 29-Oct-2017
    *   Summary         : This method is use to fetch all building information and store this information into map
    *                     it internally uses cached data to avoid queries.  
    *   Issue No.       : -
    */  
    public static void fetchBuildings(){
        if(lstBuildings == null){             
            lstBuildings = [SELECT Id, Name, Email__c, UUID__c, City__c, State__c,  Country__c, Geography__r.Geocode__c, Geography__r.City__c, Geography__r.State__c, Geography__r.Country__c, Community_Sales_Lead__c, Responsible_CM__c, Market__c, Market__r.Name, Market__r.TerritoryID__c, Market__r.TerritoryID__r.RegionID__c, Market__r.Mid_Market_Assignment_Override__c, Market__r.Enterprise_Assignment_Override__c, Cluster__c, Portfolio_Name__c, Cluster_Name__c, Territory_Name__c, Region_Name__c,Cluster__r.Sales_Lead__c FROM Building__c];            
            for(Building__c currentBuilding:lstBuildings){
                mapBuildingById.put(currentBuilding.Id,currentBuilding);
                mapBuildingByUUID.put(currentBuilding.UUID__c,currentBuilding);
                mapBuildingByEmail.put(currentBuilding.Email__c,currentBuilding);
            }
        }
    }
    
    /*
    *   Created By      : Amol Darekar
    *   Created Date    : 29-Oct-2017
    *   Summary         : This method is use to fetch building information by Id from map
    *                     it internally uses cached data to avoid queries.  
    *   Issue No.       : -
    */  
    public static Building__c getBuildingById(Id buildingId){
        fetchBuildings();
        if(mapBuildingById.containsKey(buildingId)){
            return mapBuildingById.get(buildingId);
        }else{
            return null;
        }
    }
    
   /*
    *   Created By      : Amol Darekar
    *   Created Date    : 29-Oct-2017
    *   Summary         : This method is use to fetch building information by UUID from map
    *                     it internally uses cached data to avoid queries.  
    *   Issue No.       : -
    */  
    public static Building__c getBuildingByUUID(String buildingUUID){
        fetchBuildings();
        if(mapBuildingByUUID.containsKey(buildingUUID)){
            return mapBuildingByUUID.get(buildingUUID);
        }else{
            return null;
        }
    }
    
    public static Building__c getBuildingByEmail(String buildingEmail){
        fetchBuildings();
        if(mapBuildingByEmail.containsKey(buildingEmail)){
            return mapBuildingByEmail.get(buildingEmail);
        }else{
            return null;
        }
    }
    
    public static List<Building__c> getAllBuildings(){
        fetchBuildings();
        return lstBuildings;
    }
    
    /* Created by hemanshu.shah@enzigma.com on 24 Apr 2016
     * This method used by the trigger to update the Unique Key so there are no duplicate Settings with same name.
     * In future if we use user or profile based settings, this should be modified to make sure there are no duplicates.
     */    
    public static void UpdateUniqueKey(Setting__c[] settings){
        for(Setting__c setting : settings ){
            setting.Unique_Key__c = setting.Name;
        }
    }

    static Triggers__c triggerSettings = null;
    public static Triggers__c getTriggerSettings(){
        if( triggerSettings == null ) {
            triggerSettings = Triggers__c.getOrgDefaults();
            if( String.isBlank(triggerSettings.Id) ) {                
                triggerSettings.Debug__c = true;
                triggerSettings.Change_Owner_To_First_User_Who_Respond__c = true;
                triggerSettings.Close_All_Open_Inbound_Lead_Activities__c = true;
                triggerSettings.Copy_Fields_From_Last_Opportunity__c = true;
                triggerSettings.Create_Deal_On_Opportunity_Create__c = true;
                triggerSettings.Create_Journey_Contact_On_Journey_Create__c = true;
                triggerSettings.Create_Journey_Contact_On_Member_Change__c = true;
                triggerSettings.Deals_Set_Closed_Deal_Status_To_Blank__c = true;
                triggerSettings.Generate_Building_Interests__c = true;
                triggerSettings.Opportunity_Upate_Encoded_ID__c = true;
                triggerSettings.Task_Call_Result_Update_Journey_NMD_Date__c = true;
                triggerSettings.Tour_Scheduled_Convert_Lead__c = true;
                triggerSettings.Update_Building_Interest_On_Lead__c = true;
                triggerSettings.Update_ClosedWon_Accounts__c = true;
                triggerSettings.Update_Contact_Most_Recent_Opp_Stage__c = true;
                triggerSettings.Update_Deal_On_Opportunity_Update__c = true;
                triggerSettings.Update_Journey_Stage_To_CompletedLost__c = true;
                triggerSettings.Update_Most_Recent_Tour_Date__c = true;
                triggerSettings.Update_Name_for_EnterpriseSolution_Type__c = true;
                triggerSettings.Update_Opportunity_Name__c = true;
                triggerSettings.Update_Space_BasedOn_SpaceUUID__c = true;
                triggerSettings.Update_Task_Due_Date_From_Journey_NMD__c = true;
                triggerSettings.Update_Task_Owner__c = true;
                triggerSettings.Update_Tour_Enditme__c = true;
                triggerSettings.Update_WeLive_Opportunity_Type__c = true;                
                upsert triggerSettings;
            }
        }
        return triggerSettings;
    }
    
    /* Created by hemanshu.shah@enzigma.com on 24 Apr 2016
     * This method caches queried setttings so for subsequent usage it does not query it again.
     */
    static Map<String,Setting__c> mapSettingsToName = new Map<String, Setting__c>();
    public static Setting__c getTest(String strName){
        strName = strName.toLowerCase();
        if( !mapSettingsToName.containsKey(strName) ){
            Setting__c[] settings = [Select Id, Name, Data__c,Source_Object__c,Destination_Object__c From Setting__c Where Name = :strName];
            if(settings.size() > 0){
                mapSettingsToName.put(strName, settings[0]);
                return settings[0];
            }
            return null;
        }
        return mapSettingsToName.get(strName);
    }
    
    // New Code
    static Set<String> settingNames = new Set<String>();
    public static Setting__c get(String strName){
        strName = strName.toLowerCase();
        if( !mapSettingsToName.containsKey(strName)){
            Setting__c[] settings = new List<Setting__c>();            
            settings = [Select Id, Name, Data__c,Source_Object__c,Destination_Object__c From Setting__c];
            if(settings.size() > 0){
                for(Setting__c setting : settings){
                    mapSettingsToName.put(setting.Name.toLowerCase() , setting);
                }
            }
            if(mapSettingsToName.containsKey(strName))
                return mapSettingsToName.get(strName);
            else{
                if(Test.isRunningTest()){
                    settingNames.add(strName);
                }
            }
            return null;
        }       
        return mapSettingsToName.get(strName);
    }
        
    /* Created by hemanshu.shah@enzigma.com on 24 Apr 2016
     * This method caches all given settings using one query so
     * query is not fired for each setting
     */
    public static object get(string strName, Type type){
        Setting__c setting = get(strName);
        if(setting != null){
            return JSON.deserialize(setting.Data__c, type);
        }          
        return null;
    }
    
    /* Created by hemanshu.shah@enzigma.com on 24 Apr 2016
     * This method caches all given settings using one query so
     * query is not fired for each setting
     */
    public static void LoadSettings(String[] names){
        Setting__c[] settings = [Select Id, Name, Data__c From Setting__c Where Name in :names];
        for(Setting__c setting : settings){
            mapSettingsToName.put(setting.Name.toLowerCase(), setting);
        }
    }
    
    /* Created by hemanshu.shah@enzigma.com on 24 Apr 2016
     * This method caches all given field mappings settings using one query so
     * query is not fired for each setting
     */
    public static void LoadFieldMappings(){
        Setting__c[] settings = [Select Id, Name, Data__c From Setting__c Where Name Like 'FieldMappings:%'];
        for(Setting__c setting : settings){
            mapSettingsToName.put(setting.Name.toLowerCase(), setting);
        }
    }
    
    /* Created by hemanshu.shah@enzigma.com on 23 June 2016
     * Use this method to load field mapping which always returns map of string of string
     * it internally uses cached data to avoid queries
     */
    public static Database.UpsertResult saveFieldMappings(String strName, Settings.FieldMappings mappings){
        String strSettingsName = 'FieldMappings:' + strName;
        Setting__c settings = get(strSettingsName);
        if( settings == null ){
            settings = new Setting__c(Name = strSettingsName);
            if(Test.isRunningTest())
                settingNames.clear();
        }            
        settings.Data__c = JSON.serialize(mappings);
        return Database.upsert(settings);
    }
    
    /* Created by hemanshu.shah@enzigma.com on 24 Apr 2016
     * Use this method to load field mapping which always returns map of string of string
     * it internally uses cached data to avoid queries
     */
    static Map<String, FieldMappings> mapFieldMappings = new Map<String, FieldMappings>();
    public static FieldMappings getFieldMappings(String strName){
        if(mapFieldMappings.containsKey(strName)){
            return mapFieldMappings.get(strName);
        } 
        Setting__c setting = get('FieldMappings:' + strName);
        if(setting == null){
            return null;  
        }
        Settings.FieldMappings fieldMappings = (Settings.FieldMappings)JSON.deserialize(setting.Data__c, Settings.FieldMappings.class);
        mapFieldMappings.put(strName, fieldMappings);
        return fieldMappings;
    }
    
    public class FieldMappings {
        public integer version {get; set;}
        public Map<String, MappedField> mappings{get; set;}
    }
    
    public static Settings.FieldMappings BillAccountToOrgAccountMapping() {
        Settings.FieldMappings BillAccountToOrgAccountMappings = new Settings.FieldMappings();
        BillAccountToOrgAccountMappings.version = 1;
        BillAccountToOrgAccountMappings.mappings = new Map<String, Settings.MappedField>();
        BillAccountToOrgAccountMappings.mappings.put('Lead_Source__c', new Settings.MappedField('Lead_Source__c'));
        BillAccountToOrgAccountMappings.mappings.put('RecordTypeId', new Settings.MappedField('RecordTypeId'));
        BillAccountToOrgAccountMappings.mappings.put('OwnerId', new Settings.MappedField('OwnerId'));
        return BillAccountToOrgAccountMappings;
    }    
    
    public class MappedField {        
        public MappedField(String strValue){
            this(strValue, false);
        }        
        public MappedField(String strValue, Boolean isValue){
            this.isvalue = isValue;
            if(isValue){
                this.value = strValue;   
            }             
            else{
                this.fieldname = strValue;  
            }            
            this.overwrite = false;
        }        
        public boolean isvalue {get; set;}
        public String value{get; set;}
        public String fieldname {get;set;}
        public boolean overwrite {get; set;}
    }
    
    /************************************************************************************************************************************
    Author 				: 	Pragalbha Mahajan
    Description 		: 	This method is used to get fields from custom metadata settings.
	Created Date		:	20 November 2018
    **************************************************************************************************************************************/ 
    public static List<sObject> getFieldsFromMDT(String metadataType, String developerName, Set<String> setFields){
        List<sObject> records;
        if(setFields != null && !(setFields.isEmpty()) && String.isNotBlank(metadataType) && String.isNotBlank(developerName)){
            List<String> lstFields = new List<String>(setFields);
            String strQuery = 'SELECT Id, ' + String.join(lstFields, ',');
            strQuery += ' FROM ' + metadataType + ' WHERE DeveloperName =: developerName ';
            records = Database.query(strQuery);
        } 
        return records;
    }
    
    /************************************************************************************************************************************
    Author 				: 	Milanjeet Singh
    Description 		: 	This method is used to split string value by splitor (e.g. ';' ',' or'.' etc) to set of values
						: 	String value = 'Name;Label;DeveloperName' will split to set(Name,Label,DeveloperName)
	Created Date		:	20 November 2018
    **************************************************************************************************************************************/ 
    public static Set<String> splitStringToSet(String stringValue, String splitor){
        Set<String> setValues = new Set<String>();
        if(String.valueOf(stringValue).contains(splitor)){
            setValues.addAll(String.valueOf(stringValue).split(splitor));
        }else{
            setValues.add(stringValue.trim());
        }
        return setValues;
    }
    
    static Map<String, MetadataSetting__mdt> mapMetadataSettingWithName = new Map<String, MetadataSetting__mdt>();
    public static MetadataSetting__mdt getMetadataSetting(String devloperName){
        List<MetadataSetting__mdt> lstSettings;
        if(mapMetadataSettingWithName.get(devloperName) == null){
            lstSettings = [SELECT Id, Data__c FROM MetadataSetting__mdt WHERE DeveloperName =: devloperName];
            mapMetadataSettingWithName.put(devloperName, (!lstSettings.isEmpty() ? lstSettings[0] : null));
        }
        return mapMetadataSettingWithName.get(devloperName);
    }
    
   /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is usde to check is record value changed.
        Created Date  		:   12 December 2018		
    **************************************************************************************************************************************/ 
    public static Boolean isChanged(String newValue, String oldValue){
        if((String.isBlank(newValue) && String.isNotBlank(oldValue)) || (String.isNotBlank(newValue) && String.isBlank(oldValue))){
            return true;
        }
        if(String.isNotBlank(newValue) && String.isNotBlank(oldValue) && !newValue.equalsIgnoreCase(oldValue)){
            return true;
        }
        return false;
    }   
    
}