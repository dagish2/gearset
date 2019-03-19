/************************************************************************************************************************************
    Author 		: Krishana Tupe
    Description : Test Methods For ScheduledBatches Which run multiple Schedule Batches. 

    History:
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE						AUTHOR					DETAIL
    1			20 February 2018			Krishana Tupe			Initial Developement.
**************************************************************************************************************************************/
@isTest
public class ScheduledBatchesTests {
    /************************************************************************************************************************************
		Author 				: Krishana Tupe 
		Description 		: This setup method is used to get all salesconsole settings for this class.
		Created Date		: 20 February 2016		
	**************************************************************************************************************************************/
    @TestSetup
    public static void setup(){
        SalesConsoleSettings.createSettings();
    }
    /************************************************************************************************************************************
		Author 				: Krishana Tupe 
		Description 		: This setup method is used test Schedule class ScheduledBatches.
		Created Date		: 20 February 2016		
	**************************************************************************************************************************************/ 
    static testmethod void testScheduledJob() {
        Test.startTest(); 		      
        System.schedule('ScheduledApexTest','0 0 * * * ?',new ScheduledBatches()); 
        Test.stopTest();        
    }
}