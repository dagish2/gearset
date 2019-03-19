@isTest
private class RESTToursAvailabilityByUUIDTest {
    
    @isTest static void test_good() {
        //pre-context
        Building__c b = new Building__c(
            City__c = 'Test',
            Name = 'b1',
            uuid__c = 'bui001'
        );
        insert b;
        
        Tour_Schedule__c tour_Schedule = new Tour_Schedule__c(
            Building__c = b.Id,
            Simultaneous_Tours__c = '2',
            Product_Line__c = 'Office Space',
            Tour_Spacing__c = 'Half Hour',
            Maximum_Tour_Days__c = 1
        );
        insert tour_Schedule;

        insert new Tour_Open_Hour__c[]{
            new Tour_Open_Hour__c(
                weekday__c = 'Monday',
                start_time__c = '8:00AM',
                end_time__c = '8:00PM',
                Tour_Schedule__c = tour_Schedule.id,
                Building__c = b.Id
            ),
            new Tour_Open_Hour__c(
                weekday__c = 'Tuesday',
                start_time__c = '8:00AM',
                end_time__c = '8:00PM',
                Tour_Schedule__c = tour_Schedule.id,
                Building__c = b.Id
            ),
            new Tour_Open_Hour__c(
                weekday__c = 'Wednesday',
                start_time__c = '8:00AM',
                end_time__c = '8:00PM',
                Tour_Schedule__c = tour_Schedule.id,
                Building__c = b.Id
            ),
            new Tour_Open_Hour__c(
                weekday__c = 'Thursday',
                start_time__c = '8:00AM',
                end_time__c = '8:00PM',
                Tour_Schedule__c = tour_Schedule.id,
                Building__c = b.Id
            ),
            new Tour_Open_Hour__c(
                weekday__c = 'Friday',
                start_time__c = '8:00AM',
                end_time__c = '8:00PM',
                Tour_Schedule__c = tour_Schedule.id,
                Building__c = b.Id
            ),
            new Tour_Open_Hour__c(
                weekday__c = 'Saturday',
                start_time__c = '8:00AM',
                end_time__c = '8:00PM',
                Tour_Schedule__c = tour_Schedule.id,
                Building__c = b.Id
            ),
            new Tour_Open_Hour__c(
                weekday__c = 'Sunday',
                start_time__c = '8:00AM',
                end_time__c = '8:00PM',
                Tour_Schedule__c = tour_Schedule.id,
                Building__c = b.Id
            )
        };


        //test
        Test.startTest();

        RestRequest req     = new RestRequest(); 
        RestResponse res    = new RestResponse();
      
      Date today = Date.today().addDays(1);

      // pass the req and resp objects to the method         
      req.requestURI = String.format('{0}{1}-{2}-{3}/{4}',
                                                                    new String[]{
                                                                        URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/Tours/AvailabilityByUuid/',
                                                                        String.valueOf(today.year()),
                                                                        String.valueOf(today.month()),
                                                                        String.valueOf(today.day()),
                                                                        b.uuid__c
                                                                    }
                                                                );  
      System.debug(LoggingLevel.ERROR,'Request URI '+ req.requestURI);                                                           
      req.httpMethod = 'GET';

            //assign rest context
            RestContext.request     = req;
            RestContext.response    = res;

            String[] result = RESTToursAvailabilityByUuid.doGet();

            system.assertNotEquals(
                null,
                result,
                'A valid response needs to be supplied'
            );
            /*
            system.assertEquals(
                true,
                result.size() >= 1,
                'An open building\'s tour must have at least an available space for new tour'
            );*/

        Test.stopTest();
    }

    @isTest static void test_wrong_uuid() {
        //pre-context
        Building__c b = new Building__c(
            City__c = 'Test',
            Name = 'b1',
            uuid__c = 'bui001'
        );
        insert b;
        
        Tour_Schedule__c tour_Schedule = new Tour_Schedule__c(
            Building__c = b.Id,
            Simultaneous_Tours__c = '2',
            Product_Line__c = 'Office Space',
            Tour_Spacing__c = 'Half Hour',
            Maximum_Tour_Days__c = 1
        );
        insert tour_Schedule;
        
        insert new Tour_Open_Hour__c[]{
            new Tour_Open_Hour__c(
                weekday__c = 'Monday',
                start_time__c = '8:00AM',
                end_time__c = '8:00PM',
                Tour_Schedule__c = tour_Schedule.id,
                Building__c = b.Id
            ),
            new Tour_Open_Hour__c(
                weekday__c = 'Tuesday',
                start_time__c = '8:00AM',
                end_time__c = '8:00PM',
                Tour_Schedule__c = tour_Schedule.id,
                Building__c = b.Id
            ),
            new Tour_Open_Hour__c(
                weekday__c = 'Wednesday',
                start_time__c = '8:00AM',
                end_time__c = '8:00PM',
                Tour_Schedule__c = tour_Schedule.id,
                Building__c = b.Id
            ),
            new Tour_Open_Hour__c(
                weekday__c = 'Thursday',
                start_time__c = '8:00AM',
                end_time__c = '8:00PM',
                Tour_Schedule__c = tour_Schedule.id,
                Building__c = b.Id
            ),
            new Tour_Open_Hour__c(
                weekday__c = 'Friday',
                start_time__c = '8:00AM',
                end_time__c = '8:00PM',
                Tour_Schedule__c = tour_Schedule.id,
                Building__c = b.Id
            ),
            new Tour_Open_Hour__c(
                weekday__c = 'Saturday',
                start_time__c = '8:00AM',
                end_time__c = '8:00PM',
                Tour_Schedule__c = tour_Schedule.id,
                Building__c = b.Id
            ),
            new Tour_Open_Hour__c(
                weekday__c = 'Sunday',
                start_time__c = '8:00AM',
                end_time__c = '8:00PM',
                Tour_Schedule__c = tour_Schedule.id,
                Building__c = b.Id
            )
        };

        //test
        Test.startTest();

        RestRequest req     = new RestRequest(); 
        RestResponse res    = new RestResponse();
      
      // pass the req and resp objects to the method         
      req.requestURI = 'https://cs8.salesforce.com/services/apexrest/Tours/AvailabilityByUuid/2015-01-07/unexisting_uuid';  
      req.httpMethod = 'GET';

            //assign rest context
            RestContext.request     = req;
            RestContext.response    = res;

            String[] result = RESTToursAvailabilityByUuid.doGet();

            system.assertEquals(
                null,
                result,
                'When a wrong uuid is provided the response should be null'
            );

        Test.stopTest();
    }

    @isTest static void test_wrong_date() {
        //pre-context
        Building__c b = new Building__c(
            City__c = 'Test',
            Name = 'b1',
            uuid__c = 'bui001'
        );
        insert b;
        
        Tour_Schedule__c tour_Schedule = new Tour_Schedule__c(
            Building__c = b.Id,
            Simultaneous_Tours__c = '2',
            Product_Line__c = 'Office Space',
            Tour_Spacing__c = 'Half Hour',
            Maximum_Tour_Days__c = 1
        );
        insert tour_Schedule;
            
        //test
        Test.startTest();

        RestRequest req     = new RestRequest(); 
        RestResponse res    = new RestResponse();
      
      // pass the req and resp objects to the method         
      req.requestURI = 'https://cs8.salesforce.com/services/apexrest/Tours/AvailabilityByUuid/01-07-2015/unexisting_uuid';  
      req.httpMethod = 'GET';

            //assign rest context
            RestContext.request     = req;
            RestContext.response    = res;

            String[] result = RESTToursAvailabilityByUuid.doGet();

            system.assertEquals(
                null,
                result,
                'When a wrong uuid is provided the response should be null'
            );

        Test.stopTest();
    }
    
}