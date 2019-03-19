global class JourneyDetailController {

    public JourneyDetailController(ApexPages.StandardSetController controller) {

    }

    public String journeyId {get; set;}
    public Journey__c journey {get; set;} 
    public Contact contact {get; set;}
    public Lead lead {get; set;}
    public String toId {get; set;}
    public Map<string,List<EmailTemplate>> mapEmailTemplate {get; set;}
    public static Map<string,List<EmailTemplate>> mapEmailTemplateRet {get; set;}
    public JourneyDetailController(ApexPages.StandardController controller) {
        journeyId = controller.getId();
        if(journeyId != null){
                journey = [Select Id,Name,Primary_Contact__c,Primary_Lead__c From Journey__c Where Id=:journeyId];

                if(journey.Primary_Contact__c != null){
                    contact =[SELECT Id,Name FROM Contact Where Id=:journey.Primary_Contact__c Limit 1];
                    toId = contact.Id;
                }
                if(journey.Primary_Lead__c != null){
                    lead =  [SELECT Id,Name FROM Lead Where Id=:journey.Primary_Lead__c Limit 1];
                    toId =  lead.Id;
                }
            
            List<EmailTemplate> lstEmailTemplates = [SELECT Name, Folder.Id,Folder.name, Id FROM EmailTemplate order by Name]; 
            mapEmailTemplate = new Map<string,List<EmailTemplate>>();  

            for(EmailTemplate currentEmailTemplate : lstEmailTemplates) { 
                if(currentEmailTemplate.Folder.name != null) {
                    if(mapEmailTemplate.containsKey(currentEmailTemplate.Folder.name)) {
                    List<EmailTemplate> lstEmailTemplate =  mapEmailTemplate.get(currentEmailTemplate.Folder.name);
                    lstEmailTemplate.add(currentEmailTemplate);
                    mapEmailTemplate.put(currentEmailTemplate.Folder.name,lstEmailTemplate);
                    }
                    else {
                        List<EmailTemplate> lstEmailTemplate = new List<EmailTemplate>();
                        lstEmailTemplate.add(currentEmailTemplate);
                        mapEmailTemplate.put(currentEmailTemplate.Folder.name,lstEmailTemplate);
                    } 
                }   
            }     
        }
    }  
  /**
  * @author pranay.jadhav@wework.com.dev5
  * @Issue : ST-591 Apex : Send Email Button on Journey Detail page should have AutoComplete for searching
  * @description : 
  * @date : 13/Aug/2016
  */
    @remoteAction
    global static Map<string,List<EmailTemplate>> getStringMap() { 
        mapEmailTemplateRet = new Map<string,List<EmailTemplate>>(); 
        List<EmailTemplate> lstEmailTemplates = [SELECT Name, Folder.Id,Folder.name, Id FROM EmailTemplate order by Name]; 

        for(EmailTemplate currentEmailTemplate : lstEmailTemplates) { 
            if(currentEmailTemplate.Folder.name != null) {
                if(mapEmailTemplateRet.containsKey(currentEmailTemplate.Folder.name)) {
                List<EmailTemplate> lstEmailTemplate =  mapEmailTemplateRet.get(currentEmailTemplate.Folder.name);
                lstEmailTemplate.add(currentEmailTemplate);
                mapEmailTemplateRet.put(currentEmailTemplate.Folder.name,lstEmailTemplate);
                }
                else {
                    List<EmailTemplate> lstEmailTemplate = new List<EmailTemplate>();
                    lstEmailTemplate.add(currentEmailTemplate);
                    mapEmailTemplateRet.put(currentEmailTemplate.Folder.name,lstEmailTemplate);
                } 
            }   
        }      
        return mapEmailTemplateRet;
    }
}