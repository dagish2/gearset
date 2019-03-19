/************************************************************************************************************************************
    Author      :   Dipak Pawar
    Description :   This class is used to test ListViewController

    History :
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1           23 June 2016        Dipak Pawar            	Initial Developement
**************************************************************************************************************************************/
@isTest
public class TestListViewController {    
    /************************************************************************************************************************************
        Author              :   Dipak Pawar
        Description         :   This method is used to verify ListViewController.getName method
        Created Date  		:   23 June 2016
    **************************************************************************************************************************************/
	@isTest
    private static void testGetName() {
        List<SelectOption> options = new List<SelectOption>();
        options = ListViewController.getName();
        System.assert(options != null);
        System.assert(options.size() > 1);
    }
    
    /************************************************************************************************************************************
        Author              :   Dipak Pawar
        Description         :   This method is used to verify ListViewController.getViews method
        Created Date  		:   23 June 2016
    **************************************************************************************************************************************/
    @isTest
    private static void testGetViews() {
        Map<Id, string> views = new Map<Id, string>();
        views = ListViewController.getViews('Lead');
        System.assert(views != null);
        System.assert(views.size() > 1);
    }
    
    /************************************************************************************************************************************
        Author              :   Dipak Pawar
        Description         :   This method is used to verify ListViewController.Query method
        Created Date  		:   23 June 2016
    **************************************************************************************************************************************/
    @isTest
    private static void testGetQuery() {
        sObject[] objectList;
        Building__c b = new Building__c(
            City__c = 'Test',
            Name = 'b1',
            uuid__c = 'bui001',
            time_zone__c = 'America/New_York'
        );
        insert b;
        objectList = ListViewController.Query('SELECT Id,Name From Building__c');
        System.assert(objectList != null);
        System.assert(objectList.size() > 0);
    }
}