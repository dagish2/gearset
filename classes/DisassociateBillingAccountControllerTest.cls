/************************************************************************************************************************************
    Author      :   Nikhil Mehta
    Description :   This class contains test methods for Disassociate Billing Account functionality

    History :
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR             DETAIL
    1           20 september 2018   Nikhil Mehta       Initial Developement	
**************************************************************************************************************************************/
@isTest
public class DisassociateBillingAccountControllerTest {
	@TestSetup
    static void initData(){
        SalesConsoleSettings.createSettings();
        
        Profile adminProfile;
        Profile enterpriseProfile;
        Profile nmdProfile;
        for(Profile objProfile : [SELECT Id, Name FROM Profile WHERE Name = 'Wework System Administrator' OR Name = 'WeWork Enterprise Solutions' OR Name = 'WeWork NMD User']){
            if(adminProfile != null && enterpriseProfile != null && nmdProfile != null){
                break;
            }else if(objProfile.Name.equalsIgnoreCase('Wework System Administrator')){
                adminProfile = objProfile;
            }else if(objProfile.Name.equalsIgnoreCase('WeWork Enterprise Solutions')){
                enterpriseProfile = objProfile;
            }else if(objProfile.Name.equalsIgnoreCase('WeWork NMD User')){
                nmdProfile = objProfile;
            }
        }
        List<User> lstUsers = new List<User>();
        System.runAs([SELECT Id FROM User WHERE Id =: UserInfo.getUserId()][0]) {
            List<PermissionSet> lstPermissionSets = [SELECT Id FROM PermissionSet WHERE IsOwnedByProfile = true AND (ProfileId =: adminProfile.Id OR ProfileId =: enterpriseProfile.Id)];
            
            List<SetupEntityAccess> lstSetupEntityAccesses = new List<SetupEntityAccess>();
            Id customPermissionId = [select Id from CustomPermission where DeveloperName = 'Can_Reparent_Billing_Account'][0].Id;
            List<SetupEntityAccess> lstSetupEntityAccessesInSystem = [SELECT Id, ParentId FROM SetupEntityAccess WHERE SetupEntityId =: customPermissionId AND (ParentId =: lstPermissionSets[0].Id OR ParentId =: lstPermissionSets[1].Id)];
            if(lstSetupEntityAccessesInSystem.size() == 0){
                lstSetupEntityAccesses.add(new SetupEntityAccess(ParentId = lstPermissionSets[0].Id, SetupEntityId = customPermissionId));
                lstSetupEntityAccesses.add(new SetupEntityAccess(ParentId = lstPermissionSets[1].Id, SetupEntityId = customPermissionId)); 
            }else if(lstSetupEntityAccessesInSystem.size() < 2 ){
                if(lstSetupEntityAccessesInSystem[0].ParentId == lstPermissionSets[0].Id){
                    lstSetupEntityAccesses.add(new SetupEntityAccess(ParentId = lstPermissionSets[1].Id, SetupEntityId = customPermissionId)); 
                }else{
                    lstSetupEntityAccesses.add(new SetupEntityAccess(ParentId = lstPermissionSets[0].Id, SetupEntityId = customPermissionId)); 
                }
            }
            if(!lstSetupEntityAccesses.isEmpty()){
                insert lstSetupEntityAccesses;
            }
            lstUsers.add(TestingUtility.insertUserWithAssert(enterpriseProfile.Id, new Map<String, Object>{'Alias' => 'admin', 'Email' => 'admin_user1@example.com', 'LastName' => 'admin User 1', 'UserName' => 'admin_user1@example.com', 'ProfileId' => adminProfile.Id}, false));
            lstUsers.add(TestingUtility.insertUserWithAssert(enterpriseProfile.Id, new Map<String, Object>{'Alias' => 'enterp', 'Email' => 'enterprise_user1@example.com', 'LastName' => 'Enterprize User 1', 'UserName' => 'enterprise_user1@example.com', 'ProfileId' => enterpriseProfile.Id}, false));
            lstUsers.add(TestingUtility.insertUserWithAssert(nmdProfile.Id, new Map<String, Object>{'Alias' => 'nmd', 'Email' => 'nmd_user1@example.com', 'LastName' => 'NMD User 1', 'UserName' => 'nmd_user1@example.com', 'ProfileId' => nmdProfile.Id}, false));
            TestingUtility.insertListWithAssert(lstUsers);
            
            List<CustomPermission> lstCustomPermissions = [SELECT Id, DeveloperName, (SELECT Id, Parent.Name, Parent.Profile.Name FROM SetupEntityAccessItems WHERE Parent.Profile.Id =: lstUsers[0].ProfileId) FROM CustomPermission WHERE DeveloperName = 'Can_Reparent_Billing_Account'];
            Debug.Log('lstCustomPermissions--->'+lstCustomPermissions);
            Debug.Log('lstCustomPermissions--->'+lstCustomPermissions[0].SetupEntityAccessItems);
            System.assert(lstCustomPermissions[0].SetupEntityAccessItems.size() > 0);
            lstCustomPermissions = [SELECT Id, DeveloperName, (SELECT Id, Parent.Name, Parent.Profile.Name FROM SetupEntityAccessItems WHERE Parent.Profile.Id =: lstUsers[1].ProfileId) FROM CustomPermission WHERE DeveloperName = 'Can_Reparent_Billing_Account'];
            Debug.Log('lstCustomPermissions--->'+lstCustomPermissions);
            Debug.Log('lstCustomPermissions--->'+lstCustomPermissions[0].SetupEntityAccessItems);
            System.assert(lstCustomPermissions[0].SetupEntityAccessItems.size() > 0);
        }
        
        Map<String, RecordTypeInfo> mapRecordTypeOfAccount = Schema.SObjectType.Account.getRecordTypeInfosByName();
        List<Account> lstAccounts = TestingUtility.createAccounts( 3, 'WeWork', false);
        lstAccounts[0].RecordTypeId = mapRecordTypeOfAccount.get('Enterprise Solutions').getRecordTypeId();
        lstAccounts[1].RecordTypeId = mapRecordTypeOfAccount.get('Mid Market').getRecordTypeId();
        lstAccounts[2].RecordTypeId = mapRecordTypeOfAccount.get('Consumer').getRecordTypeId();
        lstAccounts[0].OwnerId = lstUsers[0].Id;
        TestingUtility.insertListWithAssert(lstAccounts);
        
        List<Contact> lstContacts = new List<Contact>();
        lstContacts.add(TestingUtility.createContact(new Map<String, Object>{'FirstName' => 'Paul','LastName' => 'enterpriseBoss', 'Email' => 'paul@enterpriseBoss.com', 'AccountId' => lstAccounts[0].Id, 'UUID__c' => 'xxx123'}, false));
        lstContacts.add(TestingUtility.createContact(new Map<String, Object>{'FirstName' => 'Paul','LastName' => 'midmarketBoss', 'Email' => 'paul@midmarketBoss.com', 'AccountId' => lstAccounts[1].Id, 'UUID__c' => 'xxx456'}, false));
        lstContacts.add(TestingUtility.createContact(new Map<String, Object>{'FirstName' => 'Paul','LastName' => 'consumerBoss', 'Email' => 'paul@consumerBoss.com', 'AccountId' => lstAccounts[2].Id, 'UUID__c' => 'xxx789'}, false));
        TestingUtility.insertListWithAssert(lstContacts);
        
        List<Billing_Account__c> lstBillAccounts = new List<Billing_Account__c>();
        lstBillAccounts.add(TestingUtility.createBillingAccount(new Map<String,Object>{'Name'=>'Test Billing Account 1','UUID__c'=>UUIDHandler.generateVersion4()},false));
        lstBillAccounts.add(TestingUtility.createBillingAccount(new Map<String,Object>{'Name'=>'The Enzigma Software & sons pvt ltd','UUID__c'=>UUIDHandler.generateVersion4()},false));
        lstBillAccounts.add(TestingUtility.createBillingAccount(new Map<String,Object>{'Name'=>'The Jack & Jones','UUID__c'=>UUIDHandler.generateVersion4()},false));
        lstBillAccounts.add(TestingUtility.createBillingAccount(new Map<String,Object>{'Name'=>'The Enzigma Software pvt ltd','UUID__c'=>UUIDHandler.generateVersion4()},false));
        TestingUtility.insertListWithAssert(lstBillAccounts);
        
        List<Opportunity> lstOpportunities = new List<Opportunity>();
        lstOpportunities.add(TestingUtility.createOpportunity(new Map<String, Object>{'Name' => 'Enterprise Opportunity1','Primary_Member__c' => lstContacts[0].Id, 'AccountId' => lstAccounts[0].Id, 'closeDate' => System.today(), 'Contract_Stage__c' => 'Contract Sent', 'Billing_Account__c'=> lstBillAccounts[0].Id}, false));
        lstOpportunities.add(TestingUtility.createOpportunity(new Map<String, Object>{'Name' => 'Enterprise Opportunity2','Primary_Member__c' => lstContacts[0].Id, 'AccountId' => lstAccounts[0].Id, 'closeDate' => System.today(), 'Billing_Account__c'=> lstBillAccounts[1].Id}, false));
        lstOpportunities.add(TestingUtility.createOpportunity(new Map<String, Object>{'Name' => 'Mid Market Opportunity1','Primary_Member__c' => lstContacts[1].Id, 'AccountId' => lstAccounts[1].Id, 'closeDate' => System.today(), 'Contract_Stage__c' => 'Contract Signed', 'Billing_Account__c'=> lstBillAccounts[2].Id}, false));
        lstOpportunities.add(TestingUtility.createOpportunity(new Map<String, Object>{'Name' => 'Mid Market Opportunity2','Primary_Member__c' => lstContacts[1].Id, 'AccountId' => lstAccounts[1].Id, 'closeDate' => System.today(), 'Billing_Account__c'=> lstBillAccounts[3].Id}, false));
        lstOpportunities.add(TestingUtility.createOpportunity(new Map<String, Object>{'Name' => 'Consumer Opportunity1','Primary_Member__c' => lstContacts[2].Id, 'AccountId' => lstAccounts[2].Id, 'closeDate' => System.today(), 'Contract_Stage__c' => 'Contract Voided', 'Billing_Account__c'=> lstBillAccounts[3].Id}, false));
        lstOpportunities.add(TestingUtility.createOpportunity(new Map<String, Object>{'Name' => 'Consumer Opportunity2','Primary_Member__c' => lstContacts[2].Id, 'AccountId' => lstAccounts[2].Id, 'closeDate' => System.today()}, false));
        lstOpportunities.add(TestingUtility.createOpportunity(new Map<String, Object>{'Name' => 'Consumer Opportunity3','Primary_Member__c' => lstContacts[2].Id, 'AccountId' => lstAccounts[2].Id, 'closeDate' => System.today(), 'Billing_Account__c'=> lstBillAccounts[3].Id}, false));
        lstOpportunities[0].StageName = 'Selling';
        lstOpportunities[1].StageName = 'Closed Won';
        lstOpportunities[2].StageName = 'Negotiation';
        lstOpportunities[3].StageName = 'Qualifying';
        lstOpportunities[4].StageName = 'Negotiating';
        lstOpportunities[5].StageName = 'Closing';
        lstOpportunities[6].StageName = 'Closed Lost';
        TestingUtility.insertListWithAssert(lstOpportunities);
    }
    /****************************************************************************************************************************
        Author              : Nikhil Mehta
        Description         : This method is used to send mail for new orgnanization request.
        Created Date        : 19 September 2018
		Issue No			: ST-2753
   *****************************************************************************************************************************/    
    static testMethod void verifyDisassociateBillingAccount(){
        try{
            List<User> lstUsers = [SELECT Id FROM User WHERE Email = 'admin_user1@example.com' OR Email = 'enterprise_user1@example.com' OR Email = 'nmd_user1@example.com'];
            List<Opportunity> lstOpportunities = [SELECT Id, Name, Contract_Stage__c, StageName, Billing_Account__c, OwnerId FROM Opportunity];
            System.runAs(lstUsers[0]) {
                System.assertEquals(false, Boolean.valueOf(((Map<String, Object>)JSON.deserializeUntyped(DisAssociateBillingAccountController.validForDisAssociationWeb(lstOpportunities[0], false))).get('isValidForDisAssociation')), 'check the webservice without update billing account');
                System.assertEquals(false, Boolean.valueOf(((Map<String, Object>)JSON.deserializeUntyped(DisAssociateBillingAccountController.validForDisAssociationWeb(lstOpportunities[0], true))).get('isValidForDisAssociation')), 'check the webservice with update billing account');
                System.assertEquals(false, Boolean.valueOf(((Map<String,String>)DisAssociateBillingAccountController.isValidForDisAssociationforLightning(lstOpportunities[1], false).data).get('isValidForDisAssociation')), 'check the aura method without update billing account');
                System.assertEquals(false, Boolean.valueOf(((Map<String,String>)DisAssociateBillingAccountController.isValidForDisAssociationforLightning(lstOpportunities[1], true).data).get('isValidForDisAssociation')), 'check the aura method without update billing account');
            	System.assertEquals(false, Boolean.valueOf(DisAssociateBillingAccountController.isValidForDisAssociation(lstOpportunities[2].Id).get('isValidForDisAssociation')), 'check by single opportunity for disassociative billing account');
            }
            System.runAs(lstUsers[1]) {
                Map<Id, Map<String, String>> mapOpprtunityResults = DisAssociateBillingAccountController.isValidForDisAssociation(new Set<Id>{lstOpportunities[4].Id, lstOpportunities[5].Id, lstOpportunities[6].Id});
                System.assertEquals(true, Boolean.valueOf(mapOpprtunityResults.get(lstOpportunities[4].Id).get('isValidForDisAssociation')), 'check by bulkify the for disassociative billing account');
                System.assertEquals(false, Boolean.valueOf(mapOpprtunityResults.get(lstOpportunities[5].Id).get('isValidForDisAssociation')), 'check by bulkify the for disassociative billing account');
                System.assertEquals(false, Boolean.valueOf(mapOpprtunityResults.get(lstOpportunities[6].Id).get('isValidForDisAssociation')), 'check by bulkify the for disassociative billing account');
            }
            System.runAs(lstUsers[2]) {
                System.assertEquals(true, Boolean.valueOf(DisAssociateBillingAccountController.isValidForDisAssociation(lstOpportunities[3].Id).get('isValidForDisAssociation')), 'check by single opportunity for disassociative billing account');
            }
            DisAssociateBillingAccountController.isValidForDisAssociationforLightning(null, true);
        } catch(Exception exc){
            Debug.Log('exception');
            System.assertNotEquals(null, exc);
        }    
    }
}