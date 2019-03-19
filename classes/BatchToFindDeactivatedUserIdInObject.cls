global class BatchToFindDeactivatedUserIdInObject implements Database.Batchable<sObject>,Database.Stateful {
    Integer currentIndex;
    Boolean isTextArea = false;
    User objUser; 
    Map<String,String> mapOfCSV;
    UserTriggerHandler.SendDeactivateUserStatus settingWrapper;
    Map<String,List<String>> mapOfCurrentObjectFields;
    String sObjectName;
    
    public BatchToFindDeactivatedUserIdInObject(Integer currentIndex,user objUser,Map<String,String> mapOfCSV,UserTriggerHandler.SendDeactivateUserStatus settingWrapper){
        Debug.log('In BatchToFindDeactivatedUserIdInObject ctor==');
        Debug.log('currentIndex=='+currentIndex);
        this.currentIndex = currentIndex;
        this.objUser = objUser;
        this.mapOfCSV = mapOfCSV;
        this.settingWrapper = settingWrapper;
        mapOfCurrentObjectFields = settingWrapper.searchInObjects[currentIndex]; 
        sObjectName = new List<String>(mapOfCurrentObjectFields.keySet())[0];
        Debug.log('sObjectName=='+sObjectName);
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query;
        Map<String,Schema.SObjectField> mfields = Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap();
        for(String field:mapOfCurrentObjectFields.values()[0]){
            System.debug('::::field::'+field);
            if( String.valueOf( mfields.get(field).getDescribe().getType() ) == 'TEXTAREA' ){
                isTextArea = true;
                break;
            }
        }
        query = UserTriggerHandler.queryGenerator(sObjectName,mapOfCurrentObjectFields.values()[0],String.valueOf(objUser.Id).substring(0, 15),isTextArea,mfields);
        Debug.log('sObjectName=='+sObjectName);
        Debug.log('query=='+query);
        return Database.getQueryLocator(query);  
    }
    global void execute(Database.BatchableContext bc, List<sObject> lstRecords){
        try{
            String body = '';
            if(isTextArea){
                String data;
                for(sObject itrObj : lstRecords){ 
                    data = '';
                    for(String strField : settingWrapper.searchInObjects[currentIndex].values()[0]){
                        data += (String)itrObj.get(strField);
                    }
                    if( data.contains(String.valueOf(objUser.Id).substring(0, 15)) ){
                        if(mapOfCSV.containsKey(sObjectName)){
                            body = mapOfCSV.get(sObjectName);
                            mapOfCSV.put(sObjectName, body+'\n'+itrObj.Id+'\t'+itrObj.get('Name'));
                        }else{
                            mapOfCSV.put(sObjectName, 'Id \t Name \n'+itrObj.Id+'\t'+itrObj.get('Name')); 
                        }
                    }
                }
            }else{
                String tempBody;
                for( sObject itrObj : lstRecords ){
                    body += itrObj.Id+'\t'+itrObj.get('Name')+'\n';
                }
                if(mapOfCSV.containsKey(sObjectName)){
                    tempBody = mapOfCSV.get(sObjectName);
                    mapOfCSV.put(sObjectName,tempBody+body);  
                }else{
                    mapOfCSV.put(sObjectName, 'Id \t Name \n'+body); 
                }
            }
        } catch(Exception pEx) {           
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('BatchToFindDeactivatedUserIdInObject',' ',null,pEx)
            );
        }
    }    
    global void finish(Database.BatchableContext bc){
        Debug.log('In finish==');
        ++currentIndex;
        Debug.log('currentIndex=='+currentIndex);
        Debug.log('settingWrapper.searchInObjects.size()=='+settingWrapper.searchInObjects.size());
        if(currentIndex < settingWrapper.searchInObjects.size()){
            Database.executeBatch(new BatchToFindDeactivatedUserIdInObject(currentIndex,objUser,new Map<String,String>(mapOfCSV),settingWrapper));    
        }else{ 
            if(mapOfCSV.size() > 0){
                List<Messaging.EmailFileAttachment> lstCSVAttachments = new  List<Messaging.EmailFileAttachment>();
                UserTriggerHandler.sendEmail(objUser.Id,objUser.lastName+' '+objUser.FirstName,mapOfCSV,settingWrapper.subject,settingWrapper.emailBody,settingWrapper.Emails);
            }
        } 
    }    
}