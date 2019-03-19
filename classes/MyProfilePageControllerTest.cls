/**
 * An apex class that keeps updates of a portal user in sync with its corresponding contact.
   Guest users are never able to access this page.
 */
@IsTest public with sharing class MyProfilePageControllerTest {
    static{
        /*List<Setting__c> lstSettings = new List<Setting__c>();
       lstSettings.add(new Setting__c(Name = 'AccountCleansingSetting',Data__c = '{"starts_with":["The","An","A"],"ends_with":["pvt","ltd"],"specialCharacters":"@#^&*!():?/><"}'));
       Insert lstSettings;*/
        SalesConsoleSettings.createSettings();
    }
    static testMethod void testSetContactFields() {        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new user();
        u.LastName = 'Test';
        u.firstname = 'User';
        u.email = 'testUser@example.com';
        u.phone = '9874563210';
        u.mobilephone = '9874563210';
        u.fax = '';
        u.street = 'testStreet';
        u.city = 'testCity';
        u.state = 'testState';
        u.postalcode = 'testPostalcode';
        u.country = 'testCountry';
        u.Username = 'testUserNameEnzigma@example.com';
        u.Alias = 'alias';
        //added by Milanjeet Singh : Duplicate community nickname
        u.CommunityNickname = 'testCommunityNickname'+system.now();
        u.TimeZoneSidKey = 'GMT';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.ProfileId = p.Id;
        u.LanguageLocaleKey = 'en_US';
        
        insert u;
        Debug.log('User U :: '+u.Id);
        Contact c = new Contact();
		System.RunAs(u) {
            MyProfilePageController.setContactFields(c, u);
            System.assertEquals(c.firstname, u.firstname, 'firstname should have been set as the firstname of the user for the contact');
            System.assertEquals(c.lastname, u.lastname, 'lastname should have been set as the lastname of the user for the contact');
        }
    }
	
    static testMethod void testSave() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        
        User currentUser = new user();
        currentUser.LastName = 'Test';
        currentUser.firstname = 'User';
        currentUser.email = 'testUser@example.com';
        currentUser.phone = '9874563210';
        currentUser.mobilephone = '9874563210';
        currentUser.fax = '';
        currentUser.street = 'testStreet';
        currentUser.city = 'testCity';
		currentUser.state = 'testState';
        currentUser.postalcode = 'testPostalcode';
        currentUser.country = 'testCountry';
        currentUser.Username = 'testUserNameEnzigma@example.com';
        currentUser.Alias = 'alias';
        //added by Milanjeet Singh : Duplicate community nickname
        currentUser.CommunityNickname = 'testCommunityNickname'+System.now();
        currentUser.TimeZoneSidKey = 'GMT';
        currentUser.LocaleSidKey = 'en_US';
        currentUser.EmailEncodingKey = 'UTF-8';
        currentUser.ProfileId = p.Id;
        currentUser.LanguageLocaleKey = 'en_US';
        
        insert currentUser;
        // Modify the test to query for a portal user that exists in your org
        List<User> existingPortalUsers = [SELECT id, profileId, userRoleId FROM User WHERE UserRoleId <> null AND UserType='CustomerSuccess'];

        if (existingPortalUsers.isEmpty()) {
            System.RunAs(currentUser) {
                //User currentUser = [select id, title, firstname, lastname, email, phone, mobilephone, fax, street, city, state, postalcode, country FROM User WHERE id =: UserInfo.getUserId()];
                MyProfilePageController controller = new MyProfilePageController();
                System.assertEquals(currentUser.Id, controller.getUser().Id, 'Did not successfully load the current user');
                System.assert(controller.getIsEdit() == false, 'isEdit should default to false');
                controller.edit();
                System.assert(controller.getIsEdit() == true);
                controller.cancel();
                System.assert(controller.getIsEdit() == false);
    
                Contact c = new Contact();
                c.LastName = 'TestContact';
                c.Email = 'testcontact@example.com';
                insert c;
    
                c.title = currentUser.title;
                c.firstname = currentUser.firstname;
                c.lastname = currentUser.lastname;
                c.email = currentUser.email;
                c.phone = currentUser.phone;
                c.mobilephone = currentUser.mobilephone;
                c.fax = currentUser.fax;
                c.mailingstreet = currentUser.street;
                c.mailingcity = currentUser.city;
                c.mailingstate = currentUser.state;
                c.mailingpostalcode = currentUser.postalcode;
                c.mailingcountry = currentUser.country;
                controller.save();
                System.assert(Page.ChangePassword.getUrl().equals(controller.changePassword().getUrl()));
            }
        } else {
            User existingPortalUser = existingPortalUsers[0];
            String randFax = Math.rint(Math.random() * 1000) + '5551234';

            System.runAs(existingPortalUser) {
                MyProfilePageController controller = new MyProfilePageController();
                System.assertEquals(existingPortalUser.Id, controller.getUser().Id, 'Did not successfully load the current user');
                System.assert(controller.getIsEdit() == false, 'isEdit should default to false');
                controller.edit();
                System.assert(controller.getIsEdit() == true);

                controller.cancel();
                System.assert(controller.getIsEdit() == false);

                controller.getUser().Fax = randFax;
                controller.save();
                System.assert(controller.getIsEdit() == false);
            }
            // verify that the user and contact were updated
            existingPortalUser = [Select id, fax, Contact.Fax from User where id =: existingPortalUser.Id];
            System.assert(existingPortalUser.fax == randFax);
            System.assert(existingPortalUser.Contact.fax == randFax);
        }
    }
}