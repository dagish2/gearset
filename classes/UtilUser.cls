/**
* @author Gad Sharon    
* @date 01/10/18
* @description Util class for the user object.
*/

public class UtilUser {
   
    public static List<User> createUsers (Integer numberOfRecords, Id profileId, Boolean doInsert)
    {
        List<Map<String,Object>> listOfMapFields = new List<Map<String,Object>>();
        
        for (Integer i = 0; i < numberOfRecords; i++)
        {
            ListOfMapFields.add(addValuesToMap(string.valueOf(i), profileId));
        }

        return UtilGeneral.createTestRecords(User.sObjectType, listOfMapFields, doInsert); 
    }

    public static List<User> createUsersByProfileId (list <Id> lstProfileIds, Boolean doInsert)
    {
        List<Map<String,Object>> listOfMapFields = new List<Map<String,Object>>();
        
        for (Integer i = 0; i < lstProfileIds.size(); i++)
        {
            ListOfMapFields.add(addValuesToMap(string.valueOf(lstProfileIds[i]), lstProfileIds[i]));
        }

        return UtilGeneral.createTestRecords(User.sObjectType, listOfMapFields, doInsert); 
    }

    public static User createUser (Id profileId, Boolean DoInsert)
    {
    	return createUsers(1, profileId, DoInsert)[0];
    }

    public static map <string, Object> addValuesToMap(string differentiator, Id profileId)
    {
    	Map<String,Object> mapUserFields = new Map<String,Object>();
        
        mapUserFields.put('LastName', 'UtilUser_' + differentiator);
        mapUserFields.put('Username', 'UtilUser_' + differentiator + '@UtilUser.com');
        mapUserFields.put('Email', 'UtilUser_' + differentiator + '@UtilUser.com');
        mapUserFields.put('CommunitynickName', 'UtilUser_' + differentiator + '@UtilUser.com');
        mapUserFields.put('LanguageLocaleKey','en_US');
        mapUserFields.put('LocaleSidKey','en_US');
        mapUserFields.put('TimeZoneSidKey','America/Los_Angeles');
        mapUserFields.put('EmailEncodingKey','ISO-8859-1');
        mapUserFields.put('ProfileId', profileId);

        return mapUserFields;
    }
}