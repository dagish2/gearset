/************************************************************************************************************************************
    Author 		: 	Dipak Pawar
    Description : 	This class contains the wrappers of all versions for Tour API
    
    History		:
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION		DATE				AUTHOR					DETAIL
    1			19 June 2018		Dipak Pawar			Initial Developement
**************************************************************************************************************************************/
public class RESTAPITourModel {
    
	/************************************************************************************************************************************
        Author              :   Dipak Pawar
        Description         :   This wrapper class is used to wrap the tour payload from external system through REST api V2 request.
        Created Date  		:   19 June 2018
		Issue No			:	ST-2477
   **************************************************************************************************************************************/    
    public class InputV2 {
		public String last_name;
		public String first_name;
		public String email;
		public String phone;
		public String lead_source;
		public String utm_campaign_id;
		public String utm_campaign;
		public String utm_content;
		public String utm_medium;
		public String utm_source;
		public String utm_term;
		public String referral_id;
		public String lead_source_detail;
		public String company_name;
		public String company_size;
		public String company_industry;
		public String lead_type; // Not required
		public String broker_name; // Not Required
		public String broker_email; // Not Required
		public String broker_phone; // Not Required
		public String quick_quote_location;
		public String notes;
		public String referral_code; 
		public String promo_code; 
		public String[] buildings_interested_uuids = new String[]{};
        public String desks_interested_min;
        public String desks_interested_size;
        public String desks_interested_max;
        public String desks_interested_range;
		public Date tour_date;
		public String tour_time;
		public String tour_building_uuid;
		public String tour_notes;
		public String tour_uuid;
		public String tour_completed_by;
        public String tour_completed_by_sfid;
        public String tour_completed_by_uuid;
        public String tour_completed_by_name;		
		public String contact_uuid;
		public String primary_member;
		public String original_tour;
        public String original_tour_uuid;
        public String sf_journey_uuid;
		public String[] product_interests = new String[]{};
		public String product_line;
		public String locale;
		public String country_code;
        public String referrer;
        public String referrer_sfid;
        public Boolean contact_referrer_only;
        public Boolean generate_journeys; // Not Required
        public String market; // Not Required
        public String campaign_sfid; // Not Required
        public String booked_by_contact_id;
        public String[] market_uuids = new String[]{}; // Not Required
        public String assigned_host; 
        public String hosted_by;
        public Boolean booked_by_sales_lead;
        public String opportunity_id; 
        public String move_in_time_frame;        
        public String t_and_cs_consent;
        public String marketing_consent;
        public String affiliates_consent;        
        public String referral_fail_reason;
	}
}