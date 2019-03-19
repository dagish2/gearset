/************************************************************************************************************************************
    Author      :   Shobhit Gahlot
    Description :   This class contains business logic for search and get Records of objects for searched keyword.
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE         Issue No.     AUTHOR                DETAIL
    1           3 Feb 2019   STL-127      Shobhit Gahlot        Initial Developement
**************************************************************************************************************************************/
public class SOSLSearchController {
/************************************************************************************************************************************
    Author      :   Shobhit Gahlot
    Description :   This Method returns Records of objects for searched keyword.
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE         Issue No.     AUTHOR                DETAIL
    1           3 Feb 2019   STL-127      Shobhit Gahlot        Initial Developement
**************************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult getRecordsWithSOSLSearch(string keywordToSearch, string objWithFields, String strLimit, string whereClause){
        Debug.log('keywordToSearch==>'+keywordToSearch);
        Debug.log('objWithFields==>'+objWithFields);
        Debug.log('strLimit==>'+strLimit);
        Map<String, List<String>> mapobjWithFields =(Map<String, List<String>>)JSON.deserialize(objWithFields, Map<String, List<String>>.class);
        Map<String, String> mapobjWithWhereClause = new Map<String, String>();
        if(string.isnotBlank(whereClause)){
            mapobjWithWhereClause =(Map<String, String>)JSON.deserialize(whereClause, Map<String, String>.class);
        }
        List<String> lstOfQueries = new List<String>();
        for (string objectName : mapobjWithFields.keySet()){
         	List<string> stringFields = mapobjWithFields.get(objectName);
            String Query = 'FIND \''+keywordToSearch+'\' IN ALL FIELDS RETURNING '+objectName+'('+string.join(stringFields, ',')+' ';
            if(mapobjWithWhereClause != null && mapobjWithWhereClause.get(objectName) != null){
               Query += mapobjWithWhereClause.get(objectName) + ' ';
            }
            Query += ' ORDER BY CreatedDate Asc ) ';
            Query += ' LIMIT '+strLimit;
            lstOfQueries.add(Query);
        }
        debug.log('lstOfQueries==>'+lstOfQueries);
        return LightningComponentController.getListQueryDataBySOSL(lstOfQueries);
    }
}