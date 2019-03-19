@isTest
private class TestTourServices {
   /*
     static {
         SalesConsoleSettings.createSettings();
    }
    
    @isTest
    private static void testGetAvailableTimes() {
        
        Date thisDate = Date.today();
        
        Building__c b = new Building__c(
            City__c = 'Test',
            Name = 'b1',
            uuid__c = 'bui001',
            time_zone__c = 'America/New_York'
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
        Event e = new Event(
            StartDateTime = Datetime.newInstance(thisDate, Time.newInstance(8, 15, 0, 0)),
            EndDateTime = Datetime.newInstance(thisDate, Time.newInstance(18, 15, 0, 0)),
            WhatId = b.Id
        );
        insert e;
        
        Tour_Outcome__c t1 = new Tour_Outcome__c(
            Tour_Date__c = thisDate,
            Location__c = b.Id,
            Start_Time__c = '4:00PM',
            End_Time__c = '7:00PM'
        );
        insert t1;
        
        Tour_Outcome__c t2 = new Tour_Outcome__c(
            Tour_Date__c = thisDate,
            Location__c = b.Id,
            Start_Time__c = '18:30PM',
            End_Time__c = '7:30PM'
        );
        insert t2;
        
        Set<Time> availableTimes = TourServices.getAvailableTimesAsSet(thisDate, b.Id,tour_Schedule.Product_Line__c );
    }
    
    @isTest
    private static void testScheduleTour() {
        //List<Building__c> lstBuiding = new List<Building__c>();
        Building__c b = new Building__c(
            City__c = 'Test',
            Name = 'Test',
            uuid__c = 'bui001',
            time_zone__c = 'America/New_York'
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
        
        Lead l = new Lead(FirstName = 'Test', LastName = 'Test', Company = 'Test', Email = 'testlead@example.com');
        insert l;
        
        Date thisDate = Date.today();
        
        TriggersFlags.allowTourUpdates = false; 
        Tour_Outcome__c tour = TourServices.scheduleTour(l.Id, null, b.Id, thisDate, '8:00AM', 'WeWork');
        
        System.assertEquals(l.Id, tour.Lead__c);
        System.assertEquals(b.Id, tour.Location__c);
        System.assertEquals(thisDate, tour.Tour_Date__c);
        System.assertEquals('8:00AM', tour.Start_Time__c);
        System.assertEquals('8:30AM', tour.End_Time__c);
    }
    
    @isTest static void test_available_tours_east_coast_sameday() {
        //pre-context
        
        //set internal clock
        Now.setGMT(2016, 2, 5, 8, 0, 0); //friday 2/5/16 8:00am 
        
        //create a building and open it
        Building__c b = new Building__c(
            City__c = 'Test',
            uuid__c = 'abc123',
            time_zone__c = 'America/New_York',
            Name = 'NYC-Penn Station'
        );
        insert b;
        
        Tour_Schedule__c tour_Schedule = new Tour_Schedule__c(
            Building__c = b.Id,
            Simultaneous_Tours__c = '2',
            Product_Line__c = 'Residential Space',
            Tour_Spacing__c = 'Half Hour',
            Maximum_Tour_Days__c = 1
        );
        insert tour_Schedule;
        
        insert new Tour_Open_Hour__c[]{
            new Tour_Open_Hour__c(
                weekday__c = 'Monday',
                start_time__c = '9:00AM',
                end_time__c = '1:00PM',
                Tour_Schedule__c = tour_Schedule.id,
                Building__c = b.Id
            ),
                new Tour_Open_Hour__c(
                    weekday__c = 'Tuesday',
                    start_time__c = '9:00AM',
                    end_time__c = '1:00PM',
                    Tour_Schedule__c = tour_Schedule.id,
                    Building__c = b.Id
                ),
                new Tour_Open_Hour__c(
                    weekday__c = 'Wednesday',
                    start_time__c = '9:00AM',
                    end_time__c = '1:00PM',
                    Tour_Schedule__c = tour_Schedule.id,
                    Building__c = b.Id
                ),
                new Tour_Open_Hour__c(
                    weekday__c = 'Thursday',
                    start_time__c = '9:00AM',
                    end_time__c = '1:00PM',
                    Tour_Schedule__c = tour_Schedule.id,
                    Building__c = b.Id
                ),
                new Tour_Open_Hour__c(
                    weekday__c = 'Friday',
                    start_time__c = '9:00AM',
                    end_time__c = '1:00PM',
                    Tour_Schedule__c = tour_Schedule.id,
                    Building__c = b.Id
                ),
                new Tour_Open_Hour__c(
                    weekday__c = 'Saturday',
                    start_time__c = '9:00AM',
                    end_time__c = '1:00PM',
                    Tour_Schedule__c = tour_Schedule.id,
                    Building__c = b.Id
                ),
                new Tour_Open_Hour__c(
                    weekday__c = 'Sunday',
                    start_time__c = '9:00AM',
                    end_time__c = '1:00PM',
                    Tour_Schedule__c = tour_Schedule.id,
                    Building__c = b.Id
                )
                };
                    
                    Tour_Closed_Hour__c tch = new Tour_Closed_Hour__c(
                        date__c = Now.date(),
                        start_time__c = '10:00AM',
                        end_time__c = '12:00PM',
                        Tour_Schedule__c = tour_Schedule.id,
                        Building__c = b.Id
                    );
        
        insert tch;
        
        //test
        Test.startTest();
        
        
        
        //get available times      
        Time[] Ts = TourServices.getAvailableTimes(
            Now.date(), 
            b.id,
            tour_Schedule.Product_Line__c
        );
        
        Debug.log('available times on test same day:');
        //Debug.log(Ts);   
        //Debug.log('--- available times Zones ----'+ tour_Schedule.Time_Zone__c ); 
        Integer offset =  Timezone.getTimezone(b.Time_Zone__c).getOffset(Now.date())
            - 
            Userinfo.getTimezone().getOffset(Now.date());
        
        Time[] expected = new Time[]{
            Time.newInstance(9,0,0,0).addMilliseconds(-offset),
                Time.newInstance(9,30,0,0).addMilliseconds(-offset),
                Time.newInstance(12,0,0,0).addMilliseconds(-offset),
                Time.newInstance(12,30,0,0).addMilliseconds(-offset)
                };
                    
                    System.assertEquals(
                        expected,
                        Ts,
                        'There are differences on the open times'
                    );            
        
        Test.stopTest();
    }
    
    @isTest static void test_available_tours_east_coast_anotherday() {
        //pre-context
        //set internal clock
        Now.setGMT(2016, 2, 5, 8, 0, 0); //friday 2/5/16 8am 
        
        //create a building and open it
        Building__c b = new Building__c(
            City__c = 'Test',
            uuid__c = 'abc123',
            time_zone__c = 'America/New_York',
            Name = 'NYC-Penn Station'
        );
        insert b;
        
        Tour_Schedule__c tour_Schedule = new Tour_Schedule__c(
            Building__c = b.Id,
            Simultaneous_Tours__c = '2',
            Product_Line__c = 'Residential Space',
            Tour_Spacing__c = 'Half Hour',
            Maximum_Tour_Days__c = 1
        );
        insert tour_Schedule;
        
        insert new Tour_Open_Hour__c[]{
            new Tour_Open_Hour__c(
                weekday__c = 'Monday',
                start_time__c = '9:00AM',
                end_time__c = '1:00PM',
                Tour_Schedule__c = tour_Schedule.id,
                Building__c = b.Id
            ),
                new Tour_Open_Hour__c(
                    weekday__c = 'Tuesday',
                    start_time__c = '9:00AM',
                    end_time__c = '1:00PM',
                    Tour_Schedule__c = tour_Schedule.id,
                    Building__c = b.Id
                ),
                new Tour_Open_Hour__c(
                    weekday__c = 'Wednesday',
                    start_time__c = '9:00AM',
                    end_time__c = '1:00PM',
                    Tour_Schedule__c = tour_Schedule.id,
                    Building__c = b.Id
                ),
                new Tour_Open_Hour__c(
                    weekday__c = 'Thursday',
                    start_time__c = '9:00AM',
                    end_time__c = '1:00PM',
                    Tour_Schedule__c = tour_Schedule.id,
                    Building__c = b.Id
                ),
                new Tour_Open_Hour__c(
                    weekday__c = 'Friday',
                    start_time__c = '9:00AM',
                    end_time__c = '1:00PM',
                    Tour_Schedule__c = tour_Schedule.id,
                    Building__c = b.Id
                ),
                new Tour_Open_Hour__c(
                    weekday__c = 'Saturday',
                    start_time__c = '9:00AM',
                    end_time__c = '1:00PM',
                    Tour_Schedule__c = tour_Schedule.id,
                    Building__c = b.Id
                ),
                new Tour_Open_Hour__c(
                    weekday__c = 'Sunday',
                    start_time__c = '9:00AM',
                    end_time__c = '1:00PM',
                    Tour_Schedule__c = tour_Schedule.id,
                    Building__c = b.Id
                )
                };
                    
                    Tour_Closed_Hour__c tch = new Tour_Closed_Hour__c(
                        date__c = Now.date().addDays(3),
                        start_time__c = '10:00AM',
                        end_time__c = '12:00PM',
                        Tour_Schedule__c = tour_Schedule.id,
                        Building__c = b.Id
                    );
        
        insert tch;
        
        //test
        Test.startTest();
        
        //get available times      
        Time[] Ts = TourServices.getAvailableTimes(
            Now.date().addDays(3), 
            b.id,
            tour_Schedule.Product_Line__c
        );
        
        Debug.log('available times on test same day:');
        //Debug.log(Ts);
        
        Integer offset =  Timezone.getTimezone(b.Time_Zone__c).getOffset(Now.date())
            - 
            Userinfo.getTimezone().getOffset(Now.date());
        
        Time[] expected = new Time[]{
            Time.newInstance(9,0,0,0).addMilliseconds(-offset),
                Time.newInstance(9,30,0,0).addMilliseconds(-offset),
                Time.newInstance(12,0,0,0).addMilliseconds(-offset),
                Time.newInstance(12,30,0,0).addMilliseconds(-offset)
                };
                    
                    System.assertEquals(
                        expected,
                        Ts,
                        'There are differences on the open times'
                    ); 
        
        Test.stopTest();
    }
    
    @isTest static void test_available_tours_west_coast_sameday() {
        //pre-context
        
        //set internal clock
        Now.setGMT(2016, 2, 5, 8, 0, 0); //friday 2/5/16 8:00am 
        
        //create a building and open it
        Building__c b = new Building__c(
            City__c = 'Test',
            uuid__c = 'abc123',
            time_zone__c = 'America/New_York',
            Name = 'NYC-Penn Station'
        );
        insert b;
        
        Tour_Schedule__c tour_Schedule = new Tour_Schedule__c(
            Building__c = b.Id,
            Simultaneous_Tours__c = '2',
            Product_Line__c = 'Residential Space',
            Tour_Spacing__c = 'Half Hour',
            Maximum_Tour_Days__c = 1
        );
        insert tour_Schedule;
        
        insert new Tour_Open_Hour__c[]{
            new Tour_Open_Hour__c(
                weekday__c = 'Monday',
                start_time__c = '9:00AM',
                end_time__c = '1:00PM',
                Tour_Schedule__c = tour_Schedule.id,
                Building__c = b.Id
            ),
                new Tour_Open_Hour__c(
                    weekday__c = 'Tuesday',
                    start_time__c = '9:00AM',
                    end_time__c = '1:00PM',
                    Tour_Schedule__c = tour_Schedule.id,
                    Building__c = b.Id
                ),
                new Tour_Open_Hour__c(
                    weekday__c = 'Wednesday',
                    start_time__c = '9:00AM',
                    end_time__c = '1:00PM',
                    Tour_Schedule__c = tour_Schedule.id,
                    Building__c = b.Id
                ),
                new Tour_Open_Hour__c(
                    weekday__c = 'Thursday',
                    start_time__c = '9:00AM',
                    end_time__c = '1:00PM',
                    Tour_Schedule__c = tour_Schedule.id,
                    Building__c = b.Id
                ),
                new Tour_Open_Hour__c(
                    weekday__c = 'Friday',
                    start_time__c = '9:00AM',
                    end_time__c = '1:00PM',
                    Tour_Schedule__c = tour_Schedule.id,
                    Building__c = b.Id
                ),
                new Tour_Open_Hour__c(
                    weekday__c = 'Saturday',
                    start_time__c = '9:00AM',
                    end_time__c = '1:00PM',
                    Tour_Schedule__c = tour_Schedule.id,
                    Building__c = b.Id
                ),
                new Tour_Open_Hour__c(
                    weekday__c = 'Sunday',
                    start_time__c = '9:00AM',
                    end_time__c = '1:00PM',
                    Tour_Schedule__c = tour_Schedule.id,
                    Building__c = b.Id
                )
                };
                    
                    Tour_Closed_Hour__c tch = new Tour_Closed_Hour__c(
                        date__c = Now.date(),
                        start_time__c = '10:00AM',
                        end_time__c = '12:00PM',
                        Tour_Schedule__c = tour_Schedule.id,
                        Building__c = b.Id
                    );
        
        insert tch;
        
        //test
        Test.startTest();
        
        
        
        //get available times      
        Time[] Ts = TourServices.getAvailableTimes(
            Now.date(), 
            b.id,
            tour_Schedule.Product_Line__c
        );
        
        Debug.log('available times on test same day:');
        //Debug.log(Ts);
        
        Integer offset =  Timezone.getTimezone(b.Time_Zone__c).getOffset(Now.date())
            - 
            Userinfo.getTimezone().getOffset(Now.date());
        
        Time[] expected = new Time[]{
            Time.newInstance(9,0,0,0).addMilliseconds(-offset),
                Time.newInstance(9,30,0,0).addMilliseconds(-offset),
                Time.newInstance(12,0,0,0).addMilliseconds(-offset),
                Time.newInstance(12,30,0,0).addMilliseconds(-offset)
                };
                    
                    System.assertEquals(
                        expected,
                        Ts,
                        'There are differences on the open times'
                    );            
        
        Test.stopTest();
    }
    
    @isTest static void test_available_tours_west_coast_anotherday() {
        //pre-context
        //set internal clock
        Now.setGMT(2016, 2, 5, 8, 0, 0); //friday 2/5/16 8am 
        
        //create a building and open it
        Building__c b = new Building__c(
            City__c = 'Test',
            uuid__c = 'abc123',
            time_zone__c = 'America/New_York',
            Name = 'NYC-Penn Station'
        );
        insert b;
        
        Tour_Schedule__c tour_Schedule = new Tour_Schedule__c(
            Building__c = b.Id,
            Simultaneous_Tours__c = '2',
            Product_Line__c = 'Residential Space',
            Tour_Spacing__c = 'Half Hour',
            Maximum_Tour_Days__c = 1
        );
        insert tour_Schedule;
        
        insert new Tour_Open_Hour__c[]{
            new Tour_Open_Hour__c(
                weekday__c = 'Monday',
                start_time__c = '9:00AM',
                end_time__c = '1:00PM',
                Tour_Schedule__c = tour_Schedule.id,
                Building__c = b.Id
            ),
                new Tour_Open_Hour__c(
                    weekday__c = 'Tuesday',
                    start_time__c = '9:00AM',
                    end_time__c = '1:00PM',
                    Tour_Schedule__c = tour_Schedule.id,
                    Building__c = b.Id
                ),
                new Tour_Open_Hour__c(
                    weekday__c = 'Wednesday',
                    start_time__c = '9:00AM',
                    end_time__c = '1:00PM',
                    Tour_Schedule__c = tour_Schedule.id,
                    Building__c = b.Id
                ),
                new Tour_Open_Hour__c(
                    weekday__c = 'Thursday',
                    start_time__c = '9:00AM',
                    end_time__c = '1:00PM',
                    Tour_Schedule__c = tour_Schedule.id,
                    Building__c = b.Id
                ),
                new Tour_Open_Hour__c(
                    weekday__c = 'Friday',
                    start_time__c = '9:00AM',
                    end_time__c = '1:00PM',
                    Tour_Schedule__c = tour_Schedule.id,
                    Building__c = b.Id
                ),
                new Tour_Open_Hour__c(
                    weekday__c = 'Saturday',
                    start_time__c = '9:00AM',
                    end_time__c = '1:00PM',
                    Tour_Schedule__c = tour_Schedule.id,
                    Building__c = b.Id
                ),
                new Tour_Open_Hour__c(
                    weekday__c = 'Sunday',
                    start_time__c = '9:00AM',
                    end_time__c = '1:00PM',
                    Tour_Schedule__c = tour_Schedule.id,
                    Building__c = b.Id
                )
                };
                    
                    Tour_Closed_Hour__c tch = new Tour_Closed_Hour__c(
                        date__c = Now.date().addDays(3),
                        start_time__c = '10:00AM',
                        end_time__c = '12:00PM',
                        Tour_Schedule__c = tour_Schedule.id,
                        Building__c = b.Id
                    );
        
        insert tch;
        
        //test
        Test.startTest();
        
        //get available times      
        Time[] Ts = TourServices.getAvailableTimes(
            Now.date().addDays(3), 
            b.id,
            tour_Schedule.Product_Line__c
        );
        
        Debug.log('available times on test same day:');
        //Debug.log( Ts);
        
        Integer offset =  Timezone.getTimezone(b.Time_Zone__c).getOffset(Now.date())
            - 
            Userinfo.getTimezone().getOffset(Now.date());
        
        Time[] expected = new Time[]{
            Time.newInstance(9,0,0,0).addMilliseconds(-offset),
                Time.newInstance(9,30,0,0).addMilliseconds(-offset),
                Time.newInstance(12,0,0,0).addMilliseconds(-offset),
                Time.newInstance(12,30,0,0).addMilliseconds(-offset)
                };
                    
                    System.assertEquals(
                        expected,
                        Ts,
                        'There are differences on the open times'
                    ); 
        
        Test.stopTest();
    }
    
    @isTest static void testGetDayOfWeek(){
        Date d = Date.today();
        TourServices.getDayOfWeek(d);
    }
    
    @isTest static void test_duplicate_event_to_buildings(){
        Date thisDate = Date.today();
        List<Building__c> lstBuilding = new List<Building__c>();
        Building__c b1 = new Building__c(
            City__c = 'Test',
            Name = 'b1',
            uuid__c = 'bui001',
            time_zone__c = 'America/New_York',
            Country__c = 'USA',
            State__C = 'WD'
        );
      //  insert b;
        Building__c b2 = new Building__c(
            City__c = 'Test',
            Name = 'b2',
            uuid__c = 'bui002',
            time_zone__c = 'America/New_York',
            Country__c = 'USA',
            State__c = 'CA'
        );
        //insert b2;
        lstBuilding.add(b1);
        lstBuilding.add(b2);
        debug.Log('Before lstBuilding'+lstBuilding);
        insert(lstBuilding);
        debug.Log('After lstBuilding'+lstBuilding);
        
        Tour_Schedule__c tour_Schedule = new Tour_Schedule__c(
            Building__c = lstBuilding[0].Id,
            Simultaneous_Tours__c = '2',
            Product_Line__c = 'Office Space',
            Tour_Spacing__c = 'Half Hour',
            Maximum_Tour_Days__c = 1
        );
        insert tour_Schedule;
        
        Event e = new Event(
            StartDateTime = Datetime.newInstance(thisDate, Time.newInstance(8, 15, 0, 0)),
            EndDateTime = Datetime.newInstance(thisDate, Time.newInstance(18, 15, 0, 0)),
            WhatId = lstBuilding[0].Id,
            copy_to_buildings_in_same_country__c = true
        );
        insert e;
        TourServices.duplicate_event_to_buildings(e);

    }
    
    //eventsOverlap
    // Added by Milanjeet
    @isTest static void test_eventsOverlap(){
        Date thisDate = Date.today();
        List<Building__c> lstBuilding = new List<Building__c>();
        Building__c b1 = new Building__c(
            City__c = 'Test',
            Name = 'b1',
            uuid__c = 'bui001',
            time_zone__c = 'America/New_York',
            Country__c = 'USA',
            State__c = 'CA'
        );
      //  insert b;
        Building__c b2 = new Building__c(
            City__c = 'Test',
            Name = 'b2',
            uuid__c = 'bui002',
            time_zone__c = 'America/New_York',
            Country__c = 'USA',
            State__c = 'CA'
        );
        //insert b2;
        lstBuilding.add(b1);
        lstBuilding.add(b2);
        debug.Log('Before lstBuilding'+lstBuilding);
        insert(lstBuilding);
        debug.Log('After lstBuilding'+lstBuilding);
        
        Tour_Schedule__c tour_Schedule = new Tour_Schedule__c(
            Building__c = lstBuilding[0].Id,
            Simultaneous_Tours__c = '2',
            Product_Line__c = 'Office Space',
            Tour_Spacing__c = 'Half Hour',
            Maximum_Tour_Days__c = 1
        );
        insert tour_Schedule;
        
        Event e1 = new Event(
            StartDateTime = Datetime.newInstance(thisDate, Time.newInstance(8, 15, 0, 0)),
            EndDateTime = Datetime.newInstance(thisDate, Time.newInstance(8, 45, 0, 0)),
            WhatId = lstBuilding[0].Id,
            copy_to_buildings_in_same_country__c = true
        );
        insert e1;
        
        Tour_Schedule__c tour_Schedule2 = new Tour_Schedule__c(
            Building__c = lstBuilding[0].Id,
            Simultaneous_Tours__c = '2',
            Product_Line__c = 'Office Space',
            Tour_Spacing__c = 'Half Hour',
            Maximum_Tour_Days__c = 1
        );
        insert tour_Schedule2;
        
        Event e2 = new Event(
            StartDateTime = Datetime.newInstance(thisDate, Time.newInstance(9, 00, 0, 0)),
            EndDateTime = Datetime.newInstance(thisDate, Time.newInstance(9, 30, 0, 0)),
            WhatId = lstBuilding[0].Id,
            copy_to_buildings_in_same_country__c = true
        );
        insert e2;
        //eventsOverlap(Datetime aStartTime, Datetime aEndTime, Datetime bStartTime, Datetime bEndTime)
        Boolean isOverlaping = TourServices.eventsOverlap(e1.StartDateTime,e1.EndDateTime,e2.StartDateTime,e2.EndDateTime);
       	debug.Log('isOverlaping' + isOverlaping);
        //TourServices.get_tour_by_id(tour_Schedule2.Id);
        // TourServices.duplicate_event_to_buildings(e);

    }
    //ST-619 : Test booked_by_contact_id__c field value is null then update field value with contact having email as loggedin user
    //or fetch get Id from email store in settings JSON
    static testMethod void test_check_contactId_not_blank() {
        
        //pre-context
        WWTypes.InboundLead j       = new WWTypes.InboundLead();
        j.company_name                      = 'A company';
        j.first_name                            = 'Test';
        j.last_name                             = 'Test';
        j.tour_building_uuid            =   'abc123';
        J.Email = 'testREST@example.com';
        j.account_uuid = 'account-uuid';
        j.contact_uuid = 'contact-uuid';
        
        RestRequest req     = new RestRequest(); 
        RestResponse res    = new RestResponse();
        
        // pass the req and resp objects to the method       
        req.requestURI = 'https://cs8.salesforce.com/services/apexrest/Tour';  
        req.httpMethod = 'POST';
        
        //assign rest context
        RestContext.request     = req;
        RestContext.response    = res;
        
        Contact primaryContact = new Contact(
            FirstName = 'Test',
            LastName = 'Test',
            LeadSource = 'Id',
            UUID__c = 'pm-contact-uuid',
            Email = 'test@example.com');
        
        insert primaryContact;
        //submit post
        // Test
        Test.startTest();
        RESTTour.Response response = RESTTour.doPost(j);
        Debug.log('response---'+response);
        response.result = response.result.replace('\"','');
        //confirm response
        Debug.Log('response.result : '+response.result);
        system.assertEquals(true, response.success, 'Response msg: ' + response.message);
        list<Tour_Outcome__c> testlstTourOutCome = [Select Id, booked_by_contact_id__c from Tour_Outcome__c where Id =:response.result];
        
        system.assertNotEquals(null, testlstTourOutCome[0].booked_by_contact_id__c);
        Test.stopTest();
    }

    static testMethod void test_check_Contact_uuid_changed() {

		WWTypes.InboundLead j = new WWTypes.InboundLead();
		j.first_name 			= 'test_firstname';
		j.last_name 			= 'test_lastname';
		j.email 				= 'new.test01_a1@example.com';
		j.phone 				= '78452568920';
		j.product_line			= 'WeWork';
		j.company_name 		  	= 'Test Company Name';
		j.booked_by_sales_lead 	= true;
		j.contact_uuid			= '9b07cfq0-374d-0135-efe0-0242ac113614';
		j.account_uuid			= '18756er9-b6a2-437b-8154-2a4d6606d721';
		j.tour_uuid				= 'aee0ty34-551f-11e7-b2d7-22erdt90d359';
		j.tour_notes			= 'Test tours notes';
		j.lead_source 			= 'Walk-In Tour';
		j.tour_building_uuid 	= 'abc123';
		j.tour_date 			= System.today();
		j.tour_time 			= '4:00PM';

		RestRequest req 	= new RestRequest(); 
		RestResponse res 	= new RestResponse();
      
		// pass the req and resp objects to the method		 
		req.requestURI = 'https://cs8.salesforce.com/services/apexrest/Tour';  
		req.httpMethod = 'POST';
      
		//assign rest context
		RestContext.request 	= req;
		RestContext.response 	= res;

		Test.startTest();
		Contact primaryContact = new Contact(
            FirstName = 'Test',
            LastName = 'Test',
            LeadSource = 'Id',
            UUID__c = '9b07cfq0-374d-0135-efe0-0242ac113614',
            Email = 'new.test01_a1@example.com');
        
        insert primaryContact;
		//submit post
		primaryContact.UUID__c = '9bedffed-374d-0135-efe0-0242ac113614';
		update primaryContact;
		RESTTour.Response response = RESTTour.doPost(j);
		primaryContact.UUID__c = 'kty7cfed-374d-0135-efe0-0242ac113614';
		update primaryContact;
		Test.stopTest();

	}
	*/
}