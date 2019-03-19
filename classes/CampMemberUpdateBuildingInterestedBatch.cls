/*
 * Created By : Anant
 * Date : 20/Dec/2016
 */
global class CampMemberUpdateBuildingInterestedBatch  implements Database.Batchable<SObject>, Schedulable {
    
    global void execute(SchedulableContext SC) {
        CampMemberUpdateBuildingInterestedBatch CMBatch = new CampMemberUpdateBuildingInterestedBatch();
        ID batchprocessid = Database.executeBatch(CMBatch);
    } 
    
	global Database.QueryLocator start(Database.BatchableContext context) {
		Datetime beforeAnHour = datetime.now().addhours(-1);
		return Database.getQueryLocator('SELECT Id, CampaignId FROM CampaignMember WHERE CreatedDate >: beforeAnHour');
	}

   	global void execute(Database.BatchableContext context, List<CampaignMember> CampaignMembers) {
		// Class Deprecated .
	}
	
	global void finish(Database.BatchableContext context) {
		
	}
    
    public class Campaingsettings {
        public List<SplashSettings> SplashSettings;
        public List<String> AddJourneysToCampaign;
    } 
    public class SplashSettings {
        public String splasheventtype;
    }
}