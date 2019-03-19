public class CampaignEmailAdminController {
	@AuraEnabled
    public static Object saveCampaign(Campaign campaign,List<Campaign_Email_Content__c> emails,List<String> emailsToDelete) {
        try{
            System.debug(campaign);
            System.debug(emails);
            List<Database.UpsertResult> saveResult = new List<Database.UpsertResult>();
            campaign.OwnerId = UserInfo.getUserId();
            //campaign.IsActive = true;
            LightningComponentController.saveRecord(campaign);
            for(Campaign_Email_Content__c email : emails){
                email.Name = email.Default_Email_Template__c+'-'+UserInfo.getUserName()+'-'+campaign.Campaign_Cadence__c;
                email.OwnerId = UserInfo.getUserId();
                email.Campaign_Name__c = campaign.Id;
                email.Campaign_Target__c = campaign.Campaign_Target__c;
                email.Campaign_Cadence__c = campaign.Campaign_Cadence__c;
                email.Audience__c = campaign.Campaign_Audience__c;
                email.Sales_User__c = UserInfo.getUserId();
                email.Active_Content__c = true;
                email.Unique_Key__c = campaign.Id+'-'+UserInfo.getUserId()+'-'+campaign.Campaign_Cadence__c+'-'+campaign.Campaign_Cadence__c+'-'+email.Sequence__c;
            }
            LightningComponentController.saveRecords(emails);
            if(emailsToDelete.size()>0)
            	Database.delete(emailsToDelete);
            return JSON.serialize(saveResult);
        }catch(Exception ex){
            System.debug(ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static Object saveEmailContent(Campaign campaign,List<Campaign_Email_Content__c> emails){
        List<Database.UpsertResult> saveResult = new List<Database.UpsertResult>();
        for(Campaign_Email_Content__c email : emails){
            email.Name = email.Default_Email_Template__c+'-'+UserInfo.getUserName()+'-'+campaign.Campaign_Cadence__c;
            email.OwnerId = UserInfo.getUserId();
            email.Campaign_Name__c = campaign.Id;
            email.Campaign_Target__c = campaign.Campaign_Target__c;
            email.Campaign_Cadence__c = campaign.Campaign_Cadence__c;
            email.Audience__c = campaign.Campaign_Audience__c;
            email.Sales_User__c = UserInfo.getUserId();
            email.Active_Content__c = true;
            email.Unique_Key__c = campaign.Id+'-'+UserInfo.getUserId()+'-'+campaign.Campaign_Cadence__c+'-'+campaign.Campaign_Cadence__c+'-'+email.Sequence__c;
        }
        LightningComponentController.saveRecords(emails);
        return JSON.serialize(saveResult); 
    }
    
    @AuraEnabled
    public static Object getCampaign(Id campaignId) {
        try{
            Campaign objCampaign = [Select Id,Name,Type,Campaign_Cadence__c,Campaign_Target__c,Campaign_Audience__c,Building__c,Email_Address__c,City__c,State__c,Email_Sendout_Start_Date__c,Email_Sendout_End_Date__c,Description from Campaign where Id=:campaignId];
           	List<Campaign_Email_Content__c> lstEmails = [Select Id,Name,Default_Email_Template__c,Subject_Line__c,Sequence__c,Dynamic_Email_Content__c from Campaign_Email_Content__c where Campaign_Name__c=:campaignId];
            Map<String,Object> mapReturnData = new Map<String,Object>();
            mapReturnData.put('campaign',objCampaign);
            mapReturnData.put('emails',lstEmails);
            return mapReturnData;
        }catch(Exception ex){
            System.debug(ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }
    @AuraEnabled
    public static List<sObject> getQueryData(String query) {
        try{
            return Database.query(query);
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }
}