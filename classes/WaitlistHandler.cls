public with sharing class WaitlistHandler {
	public static String process_waitlist(WWTypes.Waitlist pWaitlist) {
		//locate primary member's email
		Contact[] Cs = [	SELECT id, email, AccountId 
											FROM Contact 
											WHERE email = :pWaitlist.email 
											LIMIT 1
										];
		//check member exists
		if (Cs.size() == 0 ) throw new WaitlistHandlerException('Primary members email not found within system.');

		//assign contact
		Contact c = Cs[0];

		//search for duplicate opportunity
		Opportunity[] Os = [	SELECT id, Locations_Interested__c, waitlist_notes__c 
													FROM Opportunity 
													WHERE 
														Primary_Member__c = :c.id AND 
														stagename = 'Negotiating'
													ORDER BY createddate DESC
													LIMIT 1
												];
		
		//container
		Opportunity o;

		//if previous waitlisted opportunity exists, update it
		if (Os.size() == 1) {
			o = Os[0];

			//merge building interests
			o.Locations_Interested__c = WaitlistHandler.merge_building_interests(
				o.Locations_Interested__c,
				BuildingHandler.getMultipicklistValuesFromUUID(pWaitlist.buildings_interested_uuids)
			);
			
			//update notes
			o.waitlist_notes__c = WaitlistHandler.add_notes(o.waitlist_notes__c, pWaitlist.notes);

			//dml
			update o;
		}

		//if no previous waitlisted opportunity exists, create a new one
		if (Os.size() == 0) {
			o = new Opportunity(
				name  									= 'Inbound waitlist opportunity',
				stagename 							= 'Negotiating',
				closeDate             	= system.today(),
				Primary_member__c 			= c.id,
				AccountId 							= c.AccountId,
				actual_start_date__c 		= pWaitlist.actual_start_date,
				waitlist_notes__c 			= WaitlistHandler.add_notes(null, pWaitlist.notes),
				locations_interested__c	= BuildingHandler.getMultipicklistValuesFromUUID(pWaitlist.buildings_interested_uuids)
			);
			insert o;
		}

		return String.valueOf(o.id);
	}

	private static String add_notes(String pOriginal, String pNew) {
		String result;
		try {
			//code here
			String new_entry = String.format(
													'[{0}] {1} \n', 
													new String[]{
														Datetime.now().format('yyyy-MM-dd HH:mm:ss'),
														pNew
													}
												 );

			result = new_entry + (pOriginal != null? pOriginal : '');
		}
		catch(Exception pEx) {
			result = pOriginal; //default value
		}
		
		return result;
	}

	private static String merge_building_interests(String pOriginal, String pNew) {
		String result;
		
		if (pOriginal == null) result = pNew;
		if (pNew == null) result = pOriginal;
		if (pNew == null & pOriginal == null) result = null;

		if (pNew != null && pOriginal != null) {
			Set<String> Ss = new Set<String>();

			//join splitted
			Ss.addAll(pOriginal.split(';', -1));
			Ss.addAll(pNew.split(';', -1));

			String[] Bs = new String[]{};
			Bs.addAll(Ss);

			//
			result = String.join(Bs, ';');
		}

		return result;
	}

	public class WaitlistHandlerException extends Exception{}
}