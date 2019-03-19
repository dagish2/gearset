/************************************************************************************************************************************
    Author      :   Dipak Pawar
    Description :   This class contains business logic for ListViews page

    History :
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1           23 June 2016        Dipak Pawar            	Initial Developement
**************************************************************************************************************************************/
public class ListViewController {
    /************************************************************************************************************************************
        Author              :   Dipak Pawar
        Description         :   This method returns the list of Object Names
        Created Date  		:   23 June 2016
		Issue No			:	ST-382
    **************************************************************************************************************************************/
    @RemoteAction
    public static List<SelectOption> getName() {
    List<Schema.SObjectType> gd = Schema.getGlobalDescribe().Values();     
    List<SelectOption> options = new List<SelectOption>();
    for(Schema.SObjectType f : gd){
       options.add(new SelectOption(f.getDescribe().getName(),f.getDescribe().getName()));
    }
    options.sort();
    return options;
   }
    
    /************************************************************************************************************************************
        Author              :   Dipak Pawar
        Description         :   This method returns the list of ListViews for the given Object Name
        Created Date  		:   23 June 2016
		Issue No			:	ST-382
    **************************************************************************************************************************************/
    @RemoteAction    
    public static Map<Id, string> getViews(string objectName) {        
        Map<Id, string> views = new Map<Id, string>();
        try {
            string queryString = 'Select Id,Name FROM '+objectName+' order by Name limit 1';
            ApexPages.StandardSetController setCtrl = new ApexPages.StandardSetController(Database.getqueryLocator(queryString));
            for(selectoption s: setCtrl.getListViewOptions()) {
                views.put(s.getValue(),s.getLabel());
            }
           return views;
        }
        catch(Exception exc) {
            System.debug(exc);
            return null;
        }                
    }
    
    /************************************************************************************************************************************
        Author              :   Dipak Pawar
        Description         :   This method returns the result of given querystring.
        Created Date  		:   23 June 2016
		Issue No			:	ST-382
    **************************************************************************************************************************************/
    @RemoteAction
    public static sObject[] Query(String strQuery) {
        return Database.Query(strQuery);
    }
}