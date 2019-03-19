/**
* Returns the next N days of available times for a building
*
*   endpoint: /Tours/NextAvailabilityByUuid/{building_uuid}/{next_N_days}
*
* {building_uuid}   = (String) a valid an existing building uuid
*   {next_N_days}       = (String) a number with the next N days' times to show. 
*                                           if not specified, 15 will be used as default
*
**/
@RestResource(urlMapping='/Tours/NextAvailabilityByUuid/*')
global with sharing class RESTToursNextAvailabilityByUUID {   
    @HttpGet
    global static Response doGet() {
        //wrapper class
        WWTypes.BuildingAvailability result = new WWTypes.BuildingAvailability();
    
    //response

    RESTToursNextAvailabilityByUUID.Response response = new RESTToursNextAvailabilityByUUID.Response();

        try {
            String building_uuid = null;
            String product_line = 'WeWork';
            Integer next_N_days = null;
            String uri = RestContext.request.requestURI;

            if( RestContext.request.params.size() > 0 ) {
                building_uuid = RESTToursNextAvailabilityByUUID.getBuildingUUID(uri);
                next_N_days = RESTToursNextAvailabilityByUUID.getNextNDays(RestContext.request.params.get('next_n_days'));
                product_line = RestContext.request.params.get('product_line');
                if(String.isEmpty(product_line))
                    product_line ='WeWork';
            }
            else {
                building_uuid   = RESTToursNextAvailabilityByUUID.getBuildingUUID(uri);
                next_N_days     = RESTToursNextAvailabilityByUUID.getNextDays(uri); 
            }
            
            //get building
            Building__c b = [  SELECT id, time_zone__c
                                                FROM Building__c 
                                                WHERE uuid__c = :building_uuid
                                                LIMIT 1
                                            ];

            //get building timezone
            TimeZone building_timezone = TimeZone.getTimeZone(
                                                                        b.time_zone__c != null ? 
                                                                            b.time_zone__c : 
                                                                            'America/Los_Angeles'
                                                                     );
            //set result values
            result.building_uuid = building_uuid;

            for (Integer i = 1; i <= next_N_days; i++) {
                //wrapper child class
                WWTypes.TourDate td = new WWTypes.TourDate();

                //get date + N
                Date d = system.today().addDays(i);
                td.tour_date = d;
                system.debug(logginglevel.info, 'TourDate modified: ' + d);
                //get available times for date and building
                for (Time t : TourServices.getAvailableTimes(d, b.Id,product_line)) {
                    td.times.add(
                        DateTime.newInstance(d, t).format('h:mma',building_timezone.getId())
                    );
                }
                //collect
                result.dates.add(td);
            }

            //success
            response.setSuccess(result);
            
        }
        catch(Exception pEx) {
            response.setFailure('unable to process: ' + pEx.getMessage() );
            system.debug(pEx);
        }
        
        return response;
    }

    //get building uuid parameter
    private static String getBuildingUUID(String pSource) {
        return pSource.split('/')[3];
    }

    //get next days parameter
    private static Integer getNextDays(String pSource) {
        Integer DEFAULT_DAYS = 15;
        Integer result;
        try {
            //get next days param
            result = Integer.valueOf(pSource.split('/')[4]);

            //we might need to limit this number
        }
        catch(Exception pEx) {
            result = DEFAULT_DAYS; 
        }
        
        return result;
    }
    
    private static Integer getNextNDays(String pSource) {
        Integer DEFAULT_DAYS = 15;
        Integer result;
        try {
            //get next days param
            result = Integer.valueOf(pSource);
            //we might need to limit this number
        }
        catch(Exception pEx) {
            result = DEFAULT_DAYS; 
        }
        
        return result;
    }

  //inner class to wrap response
  global class Response {
    public Boolean success;
    public String message;
    public String result;

    public void setSuccess(Object pResult) {
        this.success = true; 
        this.result = pResult != null ? JSON.serializePretty(pResult) : '';
    }
    
    public void setFailure(String pMessage) {
        this.success = false; 
        this.message = pMessage;
    }
    }
}