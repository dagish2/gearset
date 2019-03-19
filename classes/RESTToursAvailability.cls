/**
 * Exposes the tour availability schedule via SFDC's REST API.
 *
 * The format of the resource is /Tours/Availability/yyyy-mm-dd/buildingId
 *
 * @author  Antonio Grassi
 * @date    02/14/2014
 */
@RestResource(urlMapping='/Tours/Availability/*')
global with sharing class RESTToursAvailability {
    @HttpGet
    global static String[] doGet() {
        String withoutBuildingId = null;
        String tourBuildingId = null;
        String product_line = 'WeWork';
    String uri = RestContext.request.requestURI;
        Date tourDate = null;
        if( RestContext.request.params.size() > 0 ) {
            Integer lastDashIndex = uri.lastIndexOf('/');
          withoutBuildingId = uri.substring(0, lastDashIndex);
          tourBuildingId = uri.substring(lastDashIndex + 1);
            product_line = RestContext.request.params.get('product_line');
            if(String.isEmpty(product_line))
          product_line ='WeWork';
            String ptourDate = RestContext.request.params.get('date');
            if(String.isNotEmpty(ptourDate))
                tourDate = Date.valueOf(ptourDate);
        }
        else {
            Integer lastDashIndex = uri.lastIndexOf('/');
          withoutBuildingId = uri.substring(0, lastDashIndex);
          tourBuildingId = uri.substring(lastDashIndex + 1);
            tourDate = Date.valueOf(withoutBuildingId.substring(withoutBuildingId.lastIndexOf('/') + 1)); 
        }
        String[] res = new String[]{};
        
        Building__c buildingTimezone = [select Time_Zone__c from Building__c where Id = :tourBuildingId];
        TimeZone buildingTZ = TimeZone.getTimeZone(buildingTimezone.Time_Zone__c != null ? buildingTimezone.Time_Zone__c : 'America/Los_Angeles');

        for (Time t: TourServices.getAvailableTimes(tourDate, tourBuildingId, product_line)) {
            res.add(DateTime.newInstance(tourDate, t).format('h:mma', buildingTZ.getID()));
        }
        return res;     
    }
}