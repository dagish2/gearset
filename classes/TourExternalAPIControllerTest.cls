/************************************************************************************************************************************
    Author      :   Rohit Nimase
    Description :   This class is used to test TourExternalAPIController class.
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE         Issue No.    AUTHOR                DETAIL
    1           8 Feb 2019   STL-127      Rohit Nimase        Initial Developement
**************************************************************************************************************************************/
@isTest
public class TourExternalAPIControllerTest {
    
/************************************************************************************************************************************
       	Author 			: Rohit Nimase
        Description 	: This method is used to test getSettingDataForBookTour method.
        Created Date	: 8 Feb 2019 
		Issue No.		: STL-127
**************************************************************************************************************************************/	
    public static testMethod void verifyGetSettingDataForBookTour(){
        DatabaseResult result = TourExternalAPIController.getSettingDataForBookTour();
        System.assertNotEquals(null, result.data);
        
        Map<String, Integration_Data__mdt> allTourAPIs = (Map<String, Integration_Data__mdt>) result.data;
        System.assertNotEquals(null, allTourAPIs.get('tourbuildingavailabilitiesapi'));
    }
}