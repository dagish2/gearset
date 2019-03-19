/************************************************************************************************************************************
    Author      :   Shobhit Gahlot
    Description :   This class contains business logic for Tour API Endpoints.
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE         Issue No.     AUTHOR                DETAIL
    1           5 Feb 2019   STL-127      Shobhit Gahlot        Initial Developement
**************************************************************************************************************************************/
public class TourExternalAPIController {
 /************************************************************************************************************************************
    Author      :   Shobhit Gahlot
    Description :   This Method returns data for Tour APIs.
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE         Issue No.     AUTHOR                DETAIL
    1           5 Feb 2019   STL-127      Shobhit Gahlot        Initial Developement
 **************************************************************************************************************************************/ 
    @AuraEnabled
    public static DatabaseResult getSettingDataForBookTour(){
        try{
            Set<String> setTourEndpoint = new set<String>();
            for(Integration_Data__mdt tourEndpoint : [SELECT Label FROM Integration_Data__mdt]){
                setTourEndpoint.add(tourEndpoint.Label);
            }
            Map<String, Integration_Data__mdt> allTourAPIs = LightningComponentController.getExternalSystemEndPoints(setTourEndpoint);
            Debug.log('getSettingDataForBookTour allTourAPIs==>'+allTourAPIs);
            return new DatabaseResult(allTourAPIs);
        }catch(Exception pEx){
            ApexDebugLog.logException(pEx,'', 'TourAPIController', 'getSettingDataForBookTour');            
            return (new DatabaseResult(pEx));
        }
    }
}