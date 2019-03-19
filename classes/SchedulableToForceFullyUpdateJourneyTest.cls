@isTest
public class SchedulableToForceFullyUpdateJourneyTest {
    /************************************************************************************************************************************
		Author 				: Jitesh Adwani 
		Description 		: This setup method is used to get all salesconsole settings for this class.
		Created Date		: 20 November 2018		
	**************************************************************************************************************************************/
    @TestSetup
    public static void setup(){
        SalesConsoleSettings.createSettings();
    }
    /************************************************************************************************************************************
		Author 				: Jitesh Adwani 
		Description 		: This setup method is used test Schedule class SchedulableToForceFullyUpdateJourney.
		Created Date		: 20 February 2016		
	**************************************************************************************************************************************/
    Static testMethod void schedulerTest(){
        Test.startTest();
        System.schedule('ScheduledApexTest', '0 0 * * * ?', new SchedulableToForceFullyUpdateJourney());
        Test.stopTest();
    }
}