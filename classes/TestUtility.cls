/*
reid.carlberg@salesforce.com
creates entities required for testing.
*/

public with sharing class TestUtility {
    
    private static String[] nummap = new String[] { '0','1','2','3','4','5','6','7','8','9' };
    private static String[] charmap = new String[] {
        '0','1','2','3','4','5','6','7','8','9',
        'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z',
        'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'
    };
    
    /*
        A random user is useful for testing in order to be 
        sure that you are able to see data across posts regardless
        of follow status.
    */  
    public static User createTestUser() {
        Profile p = [Select Id, Name from Profile where Name = 'System Administrator'];
        return TestUtility.createTestUser(p);
    }
    
    public static User createTestUser(Profile p) {
        
        String namePrefix = 'Doe';
        
        AggregateResult[] userCount = [Select count(id) userCount From user where username like :namePrefix];
        
        Object users = userCount[0].get('userCount');
        
        User testUser = new User();
        testUser.Email = 'test'  + TestUtility.generateRandomNum(2) + '@test.com';
        testUser.Username = namePrefix + TestUtility.generateRandomString(8) + '@testuser.com';

        testUser.LastName = 'test';
        testUser.Alias = 'test' + TestUtility.generateRandomNum(2);
        testUser.ProfileId = p.Id;
        testUser.LanguageLocaleKey = 'en_US';
        testUser.LocaleSidKey = 'en_US';
        testUser.TimeZoneSidKey = 'America/Chicago';
        testUser.EmailEncodingKey = 'UTF-8';
        insert testUser;
        return testUser;
    }
    
    public static User createTestUser(String profileName) {
        Profile p = [select Id from Profile where Name = :profileName limit 1];
        User u = new User(
            LastName = '#test-user',
            Alias = '#tu',
            Email = 'user@unit-test.com',
            Username = 'unit-test-user@gold-event.com',
            CommunityNickname = '#tu',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = p.Id
        );
        insert u;
        return u;
    }
    
    /**
    * Create a  random string
    * @param strLength string Length 
    */
    public static String generateRandomString( Integer strLength ) {
        String nonce = '';
        for (Integer i = 0; i < strLength; ++i) {
            nonce += charmap.get(Math.min((Math.random() * charmap.size()).intValue(), charmap.size() - 1));
        }
        return nonce;
    }
    /**
    * Create a  random email
    */
    public static String generateRandomEmail() {
        String nonce = '';
        String partA = generateRandomString(8);
        String partB = generateRandomString(6);
        
        nonce = partA +'@'+ partB +'.com';
        
        return nonce;
    }
    /**
    * Create a  random numb
    * @param strLength string Length 
    */
    public static String generateRandomNum( Integer strLength ) {
        String nonce = '';
        for (Integer i = 0; i < strLength; ++i) {
            nonce += nummap.get(Math.min((Math.random() * nummap.size()).intValue(), nummap.size() - 1));
        }
        return nonce;
    }
    
 
         

    
   
    
    
    
}