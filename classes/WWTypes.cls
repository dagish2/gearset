global class WWTypes {
	
	global class Company {
		global String name;
		global String legal_name;
		global String printer_login;
		global String uuid;
		global Date start_date;
		global String building_uuid;
		global String status;
		global String industry;
		global String size;
		global String funding;
		global String salesforce_id;
		global Boolean has_non_wework_space;
	}

	global class Members {
		global Member[] users = new Member[]{};
	}

	global class Member {
		global String company_uuid;
		global Date date_of_birth;
		global String email;
		global String gender;
		global String key_card_number;
		global String key_card_batch;
		global String additional_phone;
		global String member_type;
		global String name;
		global String first_name;
		global String last_name;
		global String phone;
		global String status;
		global String kind;
		global String uuid;
		global Address address = new Address();
		global String salesforce_id;
		global Datetime created_at;
	}
    
    global class Person {
        global String contact_sfid;
		global String company_name;
		global String email;
		global String first_name;
		global String last_name;
		global String phone;
		global String type;
        global String contact_uuid;
        global String account_uuid;
        global String lead_source;
        global String lead_source_detail;
        global String utm_campaign_id; 
        global String utm_campaign;
        global String utm_content;
        global String utm_medium;
        global String utm_source;
        global String utm_term;
        global String locale;
        global String country_code;
	}
    
    global class PrimaryMember {
        global String contact_sfid;
		global String company_name;
		global String email;
		global String first_name;
		global String last_name;
		global String phone;
		global String type;
        global String contact_uuid;
	}

	global class Address {
		global String street;
		global String city;
		global String state;
		global String zip;
		global String country;
	}

	global class Payment {
		global Invitation invitation = new Invitation();
	}

	global class Invitation {
		global String user_uuid;
		global String location_uuid;
		global String company_name;
		global String primary_member_name;
		global String opportunity_id;
	}

	global class PaymentResult {
		global Meta meta;
		global Result result;
	}

	global class CompanyResult {
		global Meta meta;
		global Result result;
	}

	global class Meta {
		global Boolean success;
		global String version;
		global Integer httpStatus;
	}

	global class Result {
		global Datetime created_at;
		global Datetime deleted_at;
		global Integer id;
		global String name;
		global String notes;
		global Integer printer_login;
		global Integer printer_pin;
		global Date start_date;
		global String status;
		global Datetime updated_at;
		global String uuid;
		global Integer weconnect_id;
		global String error;
		global String stack;
		global Params params;
		global Boolean success;
		global String url;
	}

	global class MemberResult {
		global Meta meta;
		global Result[] result;
	}

	global class Params {
		global String name;
	}

	global class Network_Membership_Details {
		global Decimal fee;
		global Decimal setup_fee;
		global Decimal conference_room_credits;
		global Boolean mail_and_package_handling;
	}

  global class OpportunityInsert {
  	global String company_uuid;
    global String building_uuid;
    global String opportunity_type; 
   	global String community_manager_uuid;
    global Integer desk_number;
    global Date actual_start_date;
    global String[] reservable_uuids;
    global Discount[] discounts = new Discount[]{};
    global Decimal parking_fee;
    global Decimal number_of_phones;
    global Decimal phone_setup_fee;
    global Decimal setup_fee;
    global String international_calling;
    global String membership_agreement_notes;
    global String internal_transfer_encoded_id;
    global String lead_source;
	global String lead_source_details;
	global String[] locations_interested_uuids = new String[]{};
	global String send_paperwork_by;
	global String contract_uuid;
	global String primary_member_email;
	global String CurrencyIsoCode;
    global String Contract_Stage;
    global String contract_pdf;
    global String community_user;
    global String stageName;
    global String type;
    global String downgrade_reason;
    global String downgrade_notes;
    global String contract_type;
    global String reservation_uuid;
    global List<move_insVal> move_ins;
    global String from_opportunity;  
	global String Paperwork_Sent_On_Date;
    global Decimal Commitment_Term_In_Months;
    global Date Commitment_Start_Date;
    global DateTime Contract_Expiration;
    global String Lost_Reason;
    global Boolean Move_outs_Closed_Lost;
    global Date CloseDate;
    global Date Contract_Signed_On_Date;
    global Id OwnerId;
    global Id Move_Out_Building;
    global Date Contract_Canceled_On_Date;
    global Date Contract_Voided_Discarded_On_Date;
  }

  global class OpportunityUpdate {
  	global String encoded_opportunity_id;
  	global String company_uuid;
    global String building_uuid;
    global String opportunity_type; 
   	global String community_manager_uuid;
    global String desk_number;
    global Date actual_start_date;
    global String[] reservable_uuids;
    global Discount[] discounts = new Discount[]{};
    global Decimal parking_fee;
    global Decimal number_of_phones;
    global Decimal phone_setup_fee;
    global Decimal setup_fee;
    global String international_calling;
    global String membership_agreement_notes;
    global String internal_transfer_encoded_id;
    global String lead_source;
	global String lead_source_details;
	global String[] locations_interested_uuids = new String[]{};
	global String send_paperwork_by;
  }
    
	global class OpportunityDetails {
		global Member primary_member;
		global Member authorized_signatory;
		global Company company;		
		global Reservable[] reservables = new Reservable[]{};
		global Member[] members = new Member[]{};
		global Network_Membership_Details network_membership_details;
		global String opportunity_stage;
		global String opportunity_type;
		global String encoded_opportunity_id;
		global String salesforce_id;
		global String location_uuid;
		global Date actual_start_date;
		global Decimal setup_fee;
		global Decimal number_of_phones;
		global String number_of_desks;
		global Decimal total_desks_reserved;
		global Decimal office_conference_room_credits;
		global Decimal prints_color;
		global Decimal prints_black_white;
		global Decimal parking_fee;
		global Decimal phone_setup_fee;
		global Decimal additional_members;
		global String international_calling;
		global String notes;
		global String payment_method;
		global Discount[] discounts = new Discount[]{};
		global String responsible_community_manager;
		global String building_email;
		global String lead_source;
		global String lead_source_details;
		global String[] locations_interested_uuids = new String[]{};		
		global String[] office_types_interested = new String[]{};
		global String send_paperwork_by;
	}

	global class Reservable {
		global String name;
		global String type;
		global String reservable_uuid;
		global Decimal prints_black_white;
		global Decimal prints_color;
		global Decimal monthly_price;
		global Decimal capacity;
		global Decimal conference_room_credits;
		global String station_number;
	}

	global class Discount {
		global Decimal amount;
		global String discount_type;
        global String building_uuid;
        global String building_id;
		global Date start_date;
		global Date end_date;
		global String promotion_code;
		global Boolean promotion_override;
	}

	global class Stage {
		global String name;
		global String reason;
	}

	global class BuildingAvailability {
		global String building_uuid;
		global TourDate[] dates = new TourDate[]{};
	}

	global class TourDate {
		global Date tour_date;
		global String[] times = new String[]{};
	}

	global class InboundLead {
		global String last_name; //required
		global String first_name;
		global String email; //required
		global String phone;
		global String lead_source;
		global String utm_campaign_id;
		global String utm_campaign;
		global String utm_content;
		global String utm_medium;
		global String utm_source;
		global String utm_term;
		global String referral_id;
		global String lead_source_detail;
		global String company_name; //required
		global String company_size;
		global String company_industry;
		global String lead_type;
		global String broker_name;
		global String broker_email;
		global String broker_phone;
		global String quick_quote_location;
		global String notes;
		global String referral_code;
		global String promo_code;
		global String[] buildings_interested_uuids = new String[]{};
        global String desks_interested_min;
        global String desks_interested_size;
        global String desks_interested_max;
        global String desks_interested_range;
		global Date tour_date;
		global String tour_time;
		global String tour_building_uuid;
		global String tour_notes;
		global String tour_uuid;
		global String tour_completed_by;
        global String tour_completed_by_sfid;
        global String tour_completed_by_uuid;
        global String tour_completed_by_name;
		global String account_uuid;
		global String contact_uuid;
		global String primary_member; // Contact UUID
		global String original_tour; // Tour UUID
        global String original_tour_uuid;
        global String sf_journey_uuid; // Journey UUID
		global String[] product_interests = new String[]{};
		global String product_line;
		global String locale;
		global String country_code;
        global String referrer;
        global String referrer_sfid;
        global Boolean contact_referrer_only;
        global Boolean generate_journeys;
        global String market;
        global String campaign_sfid;
        global String booked_by_contact_id;
        global String[] market_uuids = new String[]{};
        global String assigned_host;
        global String hosted_by;
        global Boolean booked_by_sales_lead;
        global String opportunity_id;
        global String move_in_time_frame;
        global Address lead_address = new Address();
        
        global String t_and_cs_consent;//Issue ST-2166
        global String marketing_consent;//Issue ST-2166
        global String affiliates_consent;//Issue ST-2166
        //global String referral_close_reason; //Issue CSI-788
        global String referral_fail_reason;       
        global String lead_source_subtype;//Issue ST-3221
        global String leadsource_sub_type;//Issue ST-3221
	}

	global class TourDetail {
		global String last_name; 
		global String first_name;
		global String contact_name;
		global String contact_uuid;
		global String email; 
		global String phone;
        global String t_and_cs_consent;//Issue ST-2166
        global String marketing_consent;//Issue ST-2166
        global String affiliates_consent;//Issue ST-2166

		global String company_name;
		global String company_uuid;
		global String company_size;
		global String company_industry;
		global String number_of_desks;
	
		global String tour_status;
		global Date tour_date;      
		global String tour_time;
		global String tour_building_uuid;
		global String tour_notes;
		global String tour_outcome_notes;
		global String tour_referred_by_code;
		global String tour_referral_code;
		global String tour_id;
		global String tour_uuid;
		global String opportunity_id;
		global String lead_source;
		global String lead_source_detail;
        
        global String product_line;
	}

	global class Waitlist {
        global Date actual_start_date;
        global String[] buildings_interested_uuids = new String[]{};
        global String email;
        global String notes;
	}
	
	global class TourOutcomeFormDetail {
		global String tour_id;
		global String status;
        global Date expected_start_date;
	}
	
	global class ContractEvent {
		global String event_name;//Stage update
		global String opportunity_id;
        global String company_uuid;
        global String contract_pdf;
        global String community_manager_uuid;//Buldngs mgr uuid
        global String primary_member_email;
        global String currencyVal;
        global List<move_insVal> move_ins;
        global List<products> products;
		global String original_contract_uuid;
		global String membership_agreement_uuid;//contract uuid
		global String community_user;
		global List<move_outssVal> move_outs;
		global String downgrade_reason;
		global String downgrade_notes;
		global String transfer_type;
		global String reservation_uuid; //If Opportunity for Hot desk then we will use reservation_uuid as membership_agreement_uuid.
        global String from_opportunity;
        global String contract_date;
        global List<Discounts> discounts;
        global List<commitmentTerms> commitments;
        global String contract_expires_at;
        global String lead_source;//CSI-1545
        global String lead_source_detail;//CSI-1545
	}
	global class move_insVal {
		global String reservable_uuid;
        global String building_uuid;
        global String start_date;
        global String price;
        global String quantity;
        
    }
	global class move_outssVal {
		global String reservable_uuid;
        global String building_uuid;
        global String move_out_date;
        global String price;
        global String quantity;
	}
    //CSI-441 for sellable
    global class products{
        global String product_code;
        global String quantity;
        global String unit_price;
        global String building_uuid;
        global String start_date;
    }
    //CSI-525
    global class Discounts{
        global String start_date;
        global String end_date;
        global String building_uuid;
        global String amount;
    }
    //CSI-525
    global class commitmentTerms{
        global String start_date;
        global String end_date;
        global String number_of_months;
        global String building_uuid;
    }
}