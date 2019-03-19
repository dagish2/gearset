/************************************************************************************************************************************
    Author 		: Dipak Pawar
    Description : This class will contain the business logic of UserTrigger.
    Issue No.	: ST-542,  ST-682
    History		: --
----------------------------------------------------------------------------------------------------------------------------------
	VERSION					DATE					AUTHOR							DETAIL
	1					    09,Sept 2016		    Dipak Pawar	                	Initial Developement
	2						26,Sept 2016			Dipak Pawar						--
**************************************************************************************************************************************/
public class UserTriggerHandler extends ITriggerHandler{
    public UserTriggerHandler(){
        super('User');
    }
    
 /****************************************************************************************************************************
    Author 				: Dipak Pawar
    Description  		: This method overrides before insert method from ITriggerHander which will control the execution flow.
    Created Date		: 09,Sept 2016
    Last Modified By 	: Shiv Patil
    Last Modified Date  : 02 Feb,2018
*****************************************************************************************************************************/  
    public override void  AfterUpdate(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems){       
        if(TriggerSettings.mappedField.SendObjectSummaryToDeactivatedUser){
            SendObjectSummaryToDeactivatedUser(listNewItems, mapNewItems, listOldItems, mapOldItems);
        }
        
        if(TriggerSettings.mappedField.User_BatchOwnerChangeofSobject){
            BatchOwnerChangeofSobject(listNewItems, mapNewItems, listOldItems, mapOldItems);
        }
             
    }
    static set<Id> setUserId = new set<Id>();
    public static Setting__c SendDeactivateUserStatusSetting;
    public static SendDeactivateUserStatus SendDeactivateUserStatusWrapper;  
   
    public static void BatchOwnerChangeofSobject(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems){
        set<User> setUsers = new set<User>();
        for(User currentUser : (List<User>)listNewItems) {
            if(currentUser.IsActive == false && ((Map<Id, User>)mapOldItems).get(currentUser.Id).IsActive != currentUser.IsActive) {
                setUsers.add(currentUser);
                setUserId.add(currentUser.Id);
            }
        }
        Debug.log('setUsers==>'+setUsers);
        if(setUsers.size() > 0) {
            Database.executeBatch(new BatchOwnerChangeofSobject(setUserId,new List<String>{'Lead','Contact','Account','Journey__c','Opportunity','Tour_Outcome__c'},0),1);  
            Debug.log('after execute BatchOwnerChangeofSobject==>'+setUsers);
        }
    }
    
    public static void SendObjectSummaryToDeactivatedUser(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems){
        set<User> setUsers = new set<User>();
        for(User currentUser : (List<User>)listNewItems) {
            if(currentUser.IsActive == false && ((Map<Id, User>)mapOldItems).get(currentUser.Id).IsActive != currentUser.IsActive) {
                setUsers.add(currentUser);
                setUserId.add(currentUser.Id);
            }
        }
        Debug.log('setUsers==>'+setUsers);
        if(setUsers.size() > 0) {
            SendDeactivateUserStatusSetting = Settings.get('SendDeactivateUserStatus');
            SendDeactivateUserStatusWrapper = (SendDeactivateUserStatus)JSON.deserialize(SendDeactivateUserStatusSetting.Data__c,SendDeactivateUserStatus.class );
            if(SendDeactivateUserStatusWrapper.searchInObjects.size() > 0 ){
                for(user itrUser: setUsers)
                    Database.executeBatch(new BatchToFindDeactivatedUserIdInObject(0,itrUser,new Map<String,String>(),SendDeactivateUserStatusWrapper));    
                
            } 
        } 
    } 
 
  /****************************************************************************************************************************
    Author 				: Shivprasad Patil
    Description  		: This method used to generate query dynamically.
    Created Date		: 02,April 2018
    Last Modified By 	: -
    Last Modified Date  : -
 *****************************************************************************************************************************/
    public static string queryGenerator(String objectName,List<String> lstFields,String userId,Boolean isTextArea, Map<String,Schema.SObjectField> mfields){
        if(isTextArea){
            return 'SELECT Id,Name,'+String.join(lstFields,',')+' FROM '+objectName ;
        }else{
            String query = 'SELECT Id,Name FROM '+objectName+' WHERE ';
            String fieldType;
            List<String> lstReference = new List<String>();
            List<String> lstFieldsAPI = new List<String>(lstFields);
            for(String fieldName: lstFields){
                fieldType = String.valueOf( mfields.get(fieldName).getDescribe().getType() );
                if(fieldType == 'ID' || fieldType == 'REFERENCE'){
                    lstReference.add(fieldName);
                    lstFieldsAPI.remove(lstFieldsAPI.indexOf(fieldName));
                }
            }
            if(lstReference.size() > 0 && lstFieldsAPI.size() > 0 )
                return query + String.join(lstReference,' = \''+userId+'\' OR ') + ' = \''+userId+'\' OR '+ String.join(lstFieldsAPI, ' LIKE \'%'+ userId+'%\' OR ')+' LIKE \'%'+ userId+'%\'';        
            else if( lstFieldsAPI.size() > 0 )
                return query + String.join(lstFieldsAPI, ' LIKE \'%'+ userId+'%\' OR ')+' LIKE \'%'+ userId+'%\'';    
            
            return query + String.join(lstReference,' = \''+userId+'\' OR ')+ ' = \''+userId+'\'';  
        }
    }
  /****************************************************************************************************************************
    Author 				: Shivprasad Patil
    Description  		: It is future method to send Email with CSV attachement.
    Created Date		: 03,April 2018
    Last Modified By 	: -
    Last Modified Date  : -
 *****************************************************************************************************************************/
    public static void sendEmail(String userId,String userName,Map<String,String> mapOfCSV,String emailSubject,String emailBody,Set<String> toEmailAddress){
        List<Messaging.EmailFileAttachment> lstCSVAttachments = new  List<Messaging.EmailFileAttachment>();
        String subject;
        String label;
        String[] toAddresses = new List<String>(toEmailAddress); 
        Messaging.EmailFileAttachment csvAttachment;
        for(String objectName : mapOfCSV.keySet() ){
            csvAttachment = new Messaging.EmailFileAttachment();
            label = Schema.getGlobalDescribe().get(objectName).getDescribe().getLabel();
            csvAttachment.setFileName(label+' Summary.csv');
            csvAttachment.setBody( blob.valueOf(mapOfCSV.get(objectName)));
            lstCSVAttachments.add(csvAttachment);
        }
        subject = emailSubject;
        subject = subject.contains('&userId') ? subject.replace('&userId', userId) :subject;
        subject = subject.contains('&userName') ? subject.replace('&userName', userName) :subject;
        Messaging.SingleEmailMessage  email = new Messaging.SingleEmailMessage();
        email.setSubject(subject);
        email.setPlainTextBody(emailBody);
        email.setToAddresses(toAddresses);
        email.setFileAttachments(lstCSVAttachments);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});  
    }
    
    public class SendDeactivateUserStatus{
        public set<String> Emails;
        public String subject; 
        public String csvName;
        public String emailBody;
        public List<Map<String,List<String>>> searchInObjects;
    }
}