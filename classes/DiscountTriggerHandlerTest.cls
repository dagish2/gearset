/************************************************************************************************************************************
	Author 		: Anant Kumar	
	Description :  This class contain all test methods related to DiscountTriggers.

History:
----------------------------------------------------------------------------------------------------------------------------------
	VERSION			DATE				AUTHOR					DETAIL												ISSUE
	1				07 July 2016		Anant Kumar				Code moved from DiscountStartDate trigger.			-
	2				13 January 2018		Kishor Shinde			added new trigger structure							-
**************************************************************************************************************************************/
@isTest
private class DiscountTriggerHandlerTest {
    
	static Opportunity o = new Opportunity();
    static{
      	SalesConsoleSettings.createSettings();
        Account a = new Account(
            name = 'Test Account',
            UUID__c = 'abcd1234',
            WW_Synced__c = true,
            WW_Sync_Request__c = false,
            ID_Creation_Status_Code__c = '200'
        );
        
        TestingUtility.insertWithAssert(a);
        
        Contact john = new Contact(
            firstname = 'John',
            lastname 	= 'Rambo',
            email 		= 'john@rambo.com',
            accountID = a.Id,
            Status__c = 'active'
        );
        
        TestingUtility.insertWithAssert(john);
       
        a.Primary_Member__c = john.Id;
        TestingUtility.updateWithAssert(a);
        
        Contact paul = new Contact(
            firstname = 'Paul',
            lastname 	= 'Rambo',
            email 		= 'paul@rambo.com',
            accountID = a.Id,
            Status__c = 'active'
        );
        TestingUtility.insertWithAssert(paul);
        
        Building__c b = new Building__c(
            Name 		= 'b1',
            uuid__c = 'abc123'
        );
        TestingUtility.insertWithAssert(b);
        
      
        o.AccountID = a.Id;
        o.CloseDate = system.today();
        o.Actual_Start_Date__c  = system.today();
        o.StageName = 'Qualifying';
        o.Name = 'test Opoortunity';
        o.Building__c= b.Id;
        TestingUtility.insertWithAssert(o);
        
        Discount__c d1 = new Discount__c(
            Opportunity__c = o.Id,
            Amount__c = 10,
            Discount_Type__c = 'Regular Discount',
            Start_Date__c = system.today(),
            End_Date__c = system.today().addDays(7)
        );
        TestingUtility.insertWithAssert(d1);
    }
  
    /************************************************************************************************************************************
        Author 				: Anant Kumar
        Description 		: This test method will verify the StartDate of Discount__c.
        Created Date		: 07 July 2016
        Last Modified By	: Anant Kumar
    **************************************************************************************************************************************/  
    @isTest 
    static void test_1() {		
      
        Test.startTest();        
        Discount__c d2 = new Discount__c(
            Opportunity__c = o.Id,
            Amount__c = 20,
            Discount_Type__c = 'Regular Discount',
            Start_Date__c = system.today(),
            End_Date__c = system.today().addDays(7)
        );
        
        Boolean errorFlag = false;
        try {
            insert d2;	
        }
        catch (System.DmlException pEx) {
            errorFlag = true;
        }        
        system.assertEquals(true,errorFlag,'There is an existing discount for the given start date');        
        Test.stopTest();
    }
	
    @isTest 
    static void testByPassStartDateValidationForCommitmentTerm() {		
        
        Test.startTest();        
        Discount__c d2 = new Discount__c(
            Opportunity__c = o.Id,
            Amount__c = 20,
            Discount_Type__c = 'Commitment Term',
            Start_Date__c = system.today(),
            End_Date__c = system.today().addDays(7)
        );
        insert d2;	
        Test.stopTest();
        List<Discount__c> lstDiscounts = new List<Discount__c>([SELECT Id FROM Discount__c]);
        system.assertEquals(2, lstDiscounts.Size());
    }
    
    @isTest 
    static void testInsertionDiscountWithoutDiscountType() {		
        
        Test.startTest();        
        Discount__c d2 = new Discount__c(
            Opportunity__c = o.Id,
            Amount__c = 20,
            Start_Date__c = system.today(),
            End_Date__c = system.today().addDays(7)
        );
        
        Boolean errorFlag = false;
        try {
            insert d2;	
        }
        catch (System.DmlException pEx) {
            errorFlag = true;
        }        
        system.assertEquals(true,errorFlag,'There is an existing discount for the given start date');        
        Test.stopTest();
    }
}