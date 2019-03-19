/******************************************************************************************************************** 
Name              : Rollbar.cls 
Description       : Rollbar class for set and submit the request.

Revision History  :-
Created/Modified by         Created/Modified Date       Requested by         Technical Design Proposal
---------------------------------------------------------------------------------------------------------------------
1. Rashad Saeed (Creator)      31 DEC 2018              WeWork                 SF - Rollbar Integration  Google Doc  
---------------------------------------------------------------------------------------------------------------------
*********************************************************************************************************************/
public class Rollbar {

    public static HttpResponse submitItem(RollbarItem item, String project) {
        String itemMessage = setRollbarMessage(item, project);
        APIConnection srv = new APIConnection(project);
        HttpResponse resp = srv.sendRequest(itemMessage); 
        return resp; 
    }

    private static String setRollbarMessage(RollbarItem item, String project) {
        Integration_Data__mdt  apiSetting = [SELECT ApiKey__c FROM Integration_Data__mdt WHERE DeveloperName = :project LIMIT 1];
        String organizationEnviroment;
        if ([SELECT IsSandbox FROM Organization].IsSandbox) {
            organizationEnviroment = 'development';
        } else { 
            organizationEnviroment = 'production';
        }
        Map<String, Object> messageMap = item.buildRollbarItemMessage(apiSetting.ApiKey__c, organizationEnviroment);
        return JSON.serialize(messageMap);
    }
}