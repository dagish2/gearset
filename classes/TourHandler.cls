public with sharing class TourHandler {

  private Map<Datetime, Integer> availability = new Map<Datetime, Integer>();
  public Time[] open_times {get; set;} {this.open_times = new Time[]{}; }
  private Boolean show_past_times = false;
  private Date tour_date;
  private Id building_id;
  private String product_line;
  private Building__c building;
  private Tour_Schedule__c tour_schedule;
  private Integer time_interval; //minutes
  private Timezone building_tz;
  private Integer building_simultaneous_tours;
 
 /*
  public TourHandler(Date pTourDate, Id pBuildingId, Boolean pShowPastTimes) {
      this.tour_date              = pTourDate;
      this.building_id            = pBuildingId;
      this.show_past_times    		= pShowPastTimes;
      this.init();
  }*/
	/*
    Introduce new method for Product Family
    */
  public TourHandler(Date pTourDate, Id pBuildingId, Boolean pShowPastTimes, String pProductFamily) {
      this.tour_date              = pTourDate;
      this.building_id            = pBuildingId;
      this.show_past_times    		= pShowPastTimes;
      this.product_line = pProductFamily;		
      this.init();
  }

  public void init() {        
      try {
          //calculate open times
          this.load_building();
          this.create_open_slots();
          this.remove_closed_hours();
          this.remove_scheduled_tours();
          this.filter_availability();            
      }
      catch(Exception pEx) {
          this.open_times = new Time[]{};
          system.debug(logginglevel.info, pEx.getMessage());
      }
      
  }

  private void load_building(){
    // Fetch the details of the Building 	
		this.tour_schedule = [SELECT 
    					  Id,
		                  Simultaneous_Tours__c,
		                  Tour_Spacing__c,
		                  Building__r.Time_Zone__c
		                 FROM Tour_Schedule__c
		                 WHERE (Building__c = :this.building_id AND Product_Line__c = :this.product_line)
		                ];
                
      this.time_interval = this.tour_schedule.Tour_Spacing__c == 'Half Hour' ? 
                                                              30 : 
                                                              60;

      this.building_tz = TimeZone.getTimeZone(this.tour_schedule.Building__r.Time_Zone__c != null ? 
                                               	this.tour_schedule.Building__r.Time_Zone__c : 
                                                'America/Los_Angeles' //default
                                             );  

      this.building_simultaneous_tours = Integer.valueOf(
                                                            tour_schedule.Simultaneous_Tours__c != null ? 
                                                                tour_schedule.Simultaneous_Tours__c : 
                                                                '1'
                                                        );                  
  }

  // Construct a brand new schedule with open slots
  private void create_open_slots(){
      

      Tour_Open_Hour__c[] OHs = [ SELECT date__c, weekday__c, start_time__c, end_time__c
                                                              FROM Tour_Open_Hour__c
                                                              WHERE 
                                                                  Tour_Schedule__c = : this.tour_schedule.Id AND
                                                                      (   date__c = :this.tour_date OR
                                                                          weekday__c = :this.to_weekday(this.tour_date)
                                                                      )
                                                              ];

      //containers
      Map<Datetime, Integer> weekdays_intervals = new Map<Datetime, Integer>();
      Map<Datetime, Integer> date_intervals       = new Map<Datetime, Integer>();

      //create iteration
      for (Tour_Open_Hour__c oh : OHs) {
          if ( oh.weekday__c != null) { //it's a weekday
              weekdays_intervals.putAll(
                  this.generate_intervals(
                      this.tour_date,
                      this.to_time(oh.start_time__c),
                      this.to_time(oh.end_time__c)
                  )
              );
          }
          else { //it's a custom date
              date_intervals.putAll(
                  this.generate_intervals(
                      this.tour_date,
                      this.to_time(oh.start_time__c),
                      this.to_time(oh.end_time__c)
                  )                   
              );
          }
      }

      //set open clean schedule
      this.availability = date_intervals.size() > 0 ?
                                                  date_intervals :
                                                  weekdays_intervals;

      //debug
      system.debug(logginglevel.info, 'availability after create_open_slots()');
      system.debug(logginglevel.info, this.availability);
  }

    

  private void remove_closed_hours(){
      Tour_Closed_Hour__c[] CHs = [   SELECT date__c, weekday__c, start_time__c, end_time__c
                                      FROM Tour_Closed_Hour__c
                                      WHERE 
                                          Tour_Schedule__c = :this.tour_schedule.Id AND
                                              (   date__c = :this.tour_date OR
                                                  weekday__c = :this.to_weekday(this.tour_date)
                                              )
                                  ];

      //containers
      Map<Datetime, Integer> weekdays_intervals = new Map<Datetime, Integer>();
      Map<Datetime, Integer> date_intervals       = new Map<Datetime, Integer>();
      Map<Datetime, Integer> closed_intervals     = new Map<Datetime, Integer>();

      //collect intervals for weekdays and custom specific dates, we will use later
      for (Tour_Closed_Hour__c ch : CHs) {
          if ( ch.weekday__c != null) { //it's a weekday
              weekdays_intervals.putAll(
                  this.generate_intervals(
                      this.tour_date,
                      this.to_time(ch.start_time__c),
                      this.to_time(ch.end_time__c)
                  )
              );
          }
          else { //it's a custom date
              date_intervals.putAll(
                  this.generate_intervals(
                      this.tour_date,
                      this.to_time(ch.start_time__c),
                      this.to_time(ch.end_time__c)
                  )                   
              );
          }
      }

      //set closed intervals to remove based on previous collected intervals
      closed_intervals = date_intervals.size() > 0 ?
                          date_intervals :
                          weekdays_intervals;

      //remove entries from availability
      for (Datetime slot : this.availability.keyset()) {
          if (closed_intervals.containsKey(slot))
              this.availability.remove(slot);
      }

    //debug
    system.debug(logginglevel.info, 'closed intervals to be removed()');
    system.debug(logginglevel.info, closed_intervals);

    //debug
    system.debug(logginglevel.info, 'availability after remove_closed_slots()');
    system.debug(logginglevel.info, this.availability);
  }    

  //remove already scheduled tours from availablity by checking number of simultaneous tours
  private void remove_scheduled_tours(){

    for (Tour_Outcome__c t : [SELECT Start_Time__c,
                                   		End_Time__c
                              FROM Tour_Outcome__c
                              WHERE 
                              	Tour_Date__c = :this.tour_date AND
                              	Location__c = :this.building_id AND
                              	Start_Time__c != null AND
                              	Status__c != 'Cancelled'
                              ]) {

        for (Datetime slot : this.generate_tour_intervals(this.tour_date,
                                                          this.to_time(t.start_time__c),
                                                          this.to_time(t.end_time__c))) {
                                                         
            if (this.availability.containsKey(slot) ) {
                
                Integer available_tours = this.availability.get(slot);
                
                if (available_tours == 1) {
                    this.availability.remove(slot);
                }
                else {
                    this.availability.put(slot, available_tours - 1);
                }
            }
        }                                                       
    }
  }

  private void filter_availability(){
    //right now on GMT
    Datetime right_now = Now.dt();

    //debug
    system.debug(logginglevel.info, 'availability before filter_availability()');
    system.debug(logginglevel.info, this.availability);

    system.debug(logginglevel.info, 'building timezone:');
    system.debug(logginglevel.info, this.building_tz);

    for (Datetime slot : this.availability.keyset()) {
      //add slots if they are on future or show_past_time flag was enabled
      if (slot > right_now || this.show_past_times) {
          //Datetime dt = this.to_timezone(
          //                      slot.date(), 
          //                      slot.time(), 
          //                      this.building_tz
          //              );

          Datetime dt = slot;

          //collect
          this.open_times.add(
              dt.time()
          );
      }
    }
  }

  //helper
  private Map<Datetime, Integer> generate_intervals(Datetime pStartTime, Integer pDurationInMinutes) {
    Date d          = pStartTime.dateGMT(); //should be non GMT?
    Time start_time = pStartTime.timeGMT();
    Time end_time   = pStartTime.timeGMT()
                                .addMinutes(pDurationInMinutes);

    return this.generate_intervals(d, start_time, end_time);                                                    
  }

  private Map<Datetime, Integer> generate_intervals(Date pDate, Time pStartTime, Time pEndTime) {
    //uses class instance timezone
    //uses class instance time_interval

    //fix endtime
    if (pEndTime == null) pEndTime = pStartTime.addMinutes(this.time_interval);
    
    //start datetime
    Datetime start_time = to_timezone(
                            pDate,
                            pStartTime,
                            this.building_tz
                          );

    //end datetime
    Datetime end_time = to_timezone(
                          pDate,                          
                          pEndTime,
                          this.building_tz
                        );

    Map<Datetime, Integer> m = new Map<Datetime, Integer>();

    while (start_time < end_time) {
        //assign to map datetime -> number_of_tours per time slot
        m.put(
            start_time,
            this.building_simultaneous_tours
        );

        //increase
        start_time = start_time.addMinutes(this.time_interval);
    }

    return m;
  }

  //helpers
  private Set<Datetime> generate_tour_intervals(Date pDate, Time pStartTime, Time pEndTime) {
    //re-use existing logic
    Map<Datetime, Integer> m = this.generate_intervals(pDate, pStartTime, pEndTime);
    
    //return a Set of Datetime or null
    return m != null ?
            m.keySet() :
            null;
  }

  //helpers
  private Datetime to_timezone(Date d, Time t, TimeZone tz) {
    return 
      Datetime.newInstanceGMT(d, t)
                      .addSeconds( //calculate offset in milliseconds
                          -(
                              tz.getOffset(
                                  Datetime.newInstanceGMT(d, t)
                              ) / 1000
                          )
                      );      
  }

  //helpers
  private String to_weekday(Date d) {
    return 
        Datetime.newInstance(
            d, 
            Time.newInstance(0, 0, 0, 0)
        ).format('EEEE');
  }

  //helpers
  public Time to_time(String timeString) {      
    String[] t      = timeString.split(':');
    Boolean is_pm = t[1].subString(2, 4).equalsIgnoreCase('pm');

    Integer am_hours = Integer.valueOf(t[0]);
    Integer pm_hours = is_pm && t[0] != '12' ? 12 : 0;
    Integer hours = am_hours + pm_hours;

    Integer minutes = Integer.valueOf(t[1].subString(0, 2));
    
    Integer seconds = 0;
    Integer mseconds = 0;

    return 
        Time.newInstance(
            hours,                                           
        minutes,
        seconds,
        mseconds
      );
  }



}