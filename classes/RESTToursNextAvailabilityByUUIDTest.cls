@isTest
private class RESTToursNextAvailabilityByUUIDTest {
    
    @isTest static void test_good_1() {
        //pre-context
            
        Building__c b = new Building__c(
            City__c = 'Test City',
            uuid__c = 'bui001',
            Name = 'b1'
        );
        insert b;
        
        Tour_Schedule__c tour_Schedule = new Tour_Schedule__c(
            Building__c =b.Id,
            Simultaneous_Tours__c = '2',
            Tour_Spacing__c = 'Half Hour',
            Product_Line__c = 'Office Space',
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
      req.requestURI = String.format('{0}/{1}/{2}',
                                                                    new String[]{
                                                                        //'https://cs8.salesforce.com/services/apexrest/Tours/RESTToursNextAvailabilityByUUID',                                                                         
                                                                                '/Tours/RESTToursNextAvailabilityByUUID',                                                                                                                                               
                                                                        b.uuid__c,
                                                                        '5'
                                                                    }
                                                                );     
      req.httpMethod = 'GET';

            //assign rest context
            RestContext.request     = req;
            RestContext.response    = res;
            system.debug(logginglevel.info,'Response of rest availability Request Body '+ req);
            RESTToursNextAvailabilityByUUID.Response response = RESTToursNextAvailabilityByUUID.doGet();
            system.debug(logginglevel.info,'Response of rest availability '+ response);
            system.assertEquals(true,response.success);
            system.assertNotEquals(null,response.result);

        Test.stopTest();
    }

    @isTest static void test_good_2() {
        //pre-context
            
        Building__c b = new Building__c(
            City__c = 'Test City',
            uuid__c = 'bui001',
            Name = 'b1'
        );
        insert b;
        
        Tour_Schedule__c tour_Schedule = new Tour_Schedule__c(
            Building__c =b.Id,
            Simultaneous_Tours__c = '2',
            Tour_Spacing__c = 'Half Hour',
            Product_Line__c = 'Office Space',
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
      req.requestURI = String.format('{0}/{1}',
                                                                    new String[]{
                                                                        '/Tours/RESTToursNextAvailabilityByUUID',                                                                       
                                                                        b.uuid__c
                                                                    }
                                                                );     
      req.httpMethod = 'GET';

            //assign rest context
            RestContext.request     = req;
            RestContext.response    = res;

            RESTToursNextAvailabilityByUUID.Response response = RESTToursNextAvailabilityByUUID.doGet();

            system.assertEquals(
                true,
                response.success
            );

            system.assertNotEquals(
                null,
                response.result
            );

        Test.stopTest();
    }
    
}