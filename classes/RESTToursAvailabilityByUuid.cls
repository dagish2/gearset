@RestResource(urlMapping='/Tours/AvailabilityByUuid/*')
global with sharing class RESTToursAvailabilityByUuid {

  @HttpGet
  global static String[] doGet() {
    
    String[] res = new String[]{};
    try {   
        String withoutBuildingId = null;
        String tourBuildingUuid = null;
        String product_line = 'WeWork';
        Date tourDate = null;
        String uri = RestContext.request.requestURI;

        if( RestContext.request.params.size() > 0 ) {
            Integer lastDashIndex = uri.lastIndexOf('/');
            withoutBuildingId = uri.substring(0, lastDashIndex);
            tourBuildingUuid = uri.substring(lastDashIndex + 1);
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
            tourBuildingUuid = uri.substring(lastDashIndex + 1);
            tourDate = Date.valueOf(withoutBuildingId.substring(withoutBuildingId.lastIndexOf('/') + 1)); 
        }           
            /*system.debug(logginglevel.info, 'tourBuildingUuid: ' + tourBuildingUuid);
            system.debug(logginglevel.info, 'tourDate: ' + tourDate);
            system.debug(logginglevel.info, 'product_line: ' + product_line);*/
            
        //Tour_Schedule__c b = [  SELECT id, time_zone__c,Building__c FROM Tour_Schedule__c WHERE Building__r.uuid__c = :tourBuildingUuid LIMIT 1];
        Building__c b = [  SELECT id, Time_Zone__c FROM Building__c WHERE uuid__c = :tourBuildingUuid LIMIT 1];

        TimeZone buildingTZ = TimeZone.getTimeZone(b.Time_Zone__c != null ? b.Time_Zone__c : 'America/Los_Angeles');
        for (Time t:TourServices.getAvailableTimes(tourDate, b.Id, product_line)) {
          res.add(DateTime.newInstance(tourDate, t).format('h:mma', buildingTZ.getID()));
        }
    }  
    catch (Exception pEx) {
        res = null;
      system.debug(logginglevel.info, 'exception: ' + pEx.getMessage());
    }
   
    return res;     
  }
}