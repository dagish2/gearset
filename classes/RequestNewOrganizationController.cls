/************************************************************************************************************************************
    Author      :   Nikhil Mehta
    Description :   This class contains business logic for Request New Organization functionality

    History :
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                     	DETAIL
    1           20 July 2018        Nikhil Mehta            	Initial Developement	
**************************************************************************************************************************************/
public without sharing class RequestNewOrganizationController {
    class RequestNewOrganizationControllerException extends Exception{}
    public static Boolean isInvoker = false;
    static Savepoint sp {get;set;}
    static List<String> toAddresses = new List<String>();
    static {
        isInvoker = ApexDebugLog.registerRootInvoker(ApexDebugLog.InvokerType.AURA, 'RequestNewOrganizationController' + 'getsObjectPrefix', ApexDebugLog.InvokerType.AURA);        
    }
    
	/****************************************************************************************************************************
        Author              : Nikhil Mehta
        Description         : This method is used to send mail for new orgnanization request.
        Created Date        : 20 July 2018
		Issue No			: ST-2630
   *****************************************************************************************************************************/    
    @AuraEnabled
    public static DatabaseResult sendNewOrganizationRequest(Account objAccount, List<String> toAddress){
        return sendNewOrganizationRequest(objAccount);
    }
    
    /****************************************************************************************************************************
        Author              : Nikhil Mehta
        Description         : This method is used to send mail for new orgnanization request.
        Created Date        : 20 July 2018
		Issue No			: ST-2630
	-----------------------------------------------------------------------------------------------------------------------------
        Modified Date       : 18 September 2018
		Description         : This method is used to send mail for new orgnanization request using sales console setting.
		Issue No			: ST-2694
   *****************************************************************************************************************************/    
    @AuraEnabled
    public static DatabaseResult sendNewOrganizationRequest(Account objAccount){        
        try{
            sp = Database.setSavepoint();
            if(objAccount != null && objAccount.Name != null && objAccount.Number_of_Full_Time_Employees__c != null){
                Map <String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap();
                List<String> fields = new List<String>();
                for(Schema.SObjectField field : fieldMap.values()){
                    if(String.isNotBlank(String.valueOf(objAccount.get(field.getDescribe().getname())))){
                        fields.add(field.getDescribe().getname());
                    }
                }
                Setting__c newOrgRequestEmails = [SELECT Id, Data__c FROM Setting__c WHERE Name = 'NewOrganizationCreationRequestEmails' LIMIT 1];
                if(newOrgRequestEmails != null && newOrgRequestEmails.data__c != null){
                    List<String> lstEmails = (List<String>)JSON.deserialize(newOrgRequestEmails.data__c, List<String>.class);
                    if(lstEmails.size() > 0){
                        toAddresses.addAll(lstEmails);
                    }
                }
                if(toAddresses.size() > 0){
                    EmailTemplate emailTemplateRequestNewOrgCreation = [SELECT Id, Name, Markup FROM EmailTemplate Where DeveloperName = 'New_Organization_Creation_Request' LIMIT 1];
                    List<Messaging.SingleEmailMessage> lstEmails = new List<Messaging.SingleEmailMessage>();
                    Messaging.SingleEmailMessage objSingleMail;
                        for(String address : toAddresses ){
                            objSingleMail = new Messaging.SingleEmailMessage();
                            objSingleMail.setSubject('New Enterprise Organization Creation Request-'+objAccount.Name);
                            String htmlBody = emailTemplateRequestNewOrgCreation.Markup;
                            htmlBody = htmlBody.replace('{{loggedUser}}', UserInfo.getFirstName()+' '+UserInfo.getLastName());
                            for(String fieldName : fields){
                                htmlBody = htmlBody.replace('{{Account.'+fieldName+'}}', String.isNotBlank(String.valueOf(objAccount.get(fieldName)))?String.valueOf(objAccount.get(fieldName)):'');
                            }
                            while(htmlBody.countMatches('{{')>0 && htmlBody.countMatches('}}')>0){
                                htmlBody=htmlBody.replace(htmlBody.substring(htmlBody.indexOf('{{'),htmlBody.indexOf('}}')+2),'');
                            }
                            htmlBody = htmlBody.replace('<a href="/001/o">Click here</a>', '<a href="' + System.Label.URL + '/apex/NewOrganization">Click here</a>');
                            objSingleMail.htmlbody = htmlBody;
                            objSingleMail.setTreatTargetObjectAsRecipient(false);
                            objSingleMail.toAddresses = new List<String>{address};
                            objSingleMail.setSaveAsActivity(false);
                            lstEmails.add(objSingleMail);
                        }
                    Messaging.SendEmailResult[] emailResults =  Messaging.sendEmail(lstEmails);                    
                    for(Messaging.SendEmailResult emailResult :emailResults ){
                        if(emailResult.isSuccess()){
                            return new DatabaseResult(true);
                        }
                    }
                }
            }else if(objAccount == null ){
                throw new RequestNewOrganizationControllerException('Account is null');
            }
            return new DatabaseResult(false);
        }catch(Exception pEx) {            
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('RequestNewOrganizationController','sendOrgRequest', JSON.serialize(objAccount), pEx)
            );            
            return new DatabaseResult(pEx);
        }
    }
}