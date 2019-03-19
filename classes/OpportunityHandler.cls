/************************************************************************************************************************************
    Author      :   Amol Darekar
    Description :   This class will contain the business logic of Opportunity Merge functionality.

    History:
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  ISSUE			DETAIL 
    1           06 April 2017       Amol Darekar            ST-987			Initial Developement
    2           13 June 2016        Amol Darekar            -				Made changes for related object move
	3			-					Milanjeet Singh 		ST-1628			Made required changes for opportunity merge functionality
	4			18 July 2018 		Krishana Tupe 			-				Code optimization and changes in opportunity merge functionality.
**************************************************************************************************************************************/
global without sharing class OpportunityHandler {
    //public static Opportunity ObjPrimOppty;
    @AuraEnabled
    public static String getUserId() {
        return UserInfo.getUserId();
    }
    
  /*****************************************************************************************************************************************
        Author              :   Amol Darekar
        Description         :   This method is used to merge field of secondary opprtunities on primary opportunity.
        Created Date        :   06 April 2017
		Issue 				: 	ST-987,ST-1027
  *****************************************************************************************************************************************
		Modified By      	:   Milanjeet Singh 
 		Last Modified Date  :   -
		Issue 				: 	ST-1628
  ****************************************************************************************************************************************
		Modified By      	:   Krishana Tupe 
 		Last Modified Date  :   18 July 2018 		
  *******************************************************************************************************************************************/
    @AuraEnabled
    public static boolean mergeOpprtunities(string mergeOppIds,string primaryOpprtunity){       
        Set<string> setMergeOppIds = new Set<string>();
        setMergeOppIds.addAll((List<String>)JSON.deserialize(mergeOppIds, List<String>.class));
        Map<Id,Opportunity> mapOpprtunitiesToMerge = new Map<Id,Opportunity>([SELECT Id, Name,Membership_Agreement_Notes__c, Tour_Notes__c, Tour_Outcome_Notes__c, Description,Merged_Opprtunity__c, Locations_Interested__c, Merged_On__c FROM Opportunity WHERE Id IN : setMergeOppIds]);
        Debug.log('mapOpprtunitiesToMerge ==> '+mapOpprtunitiesToMerge);
        Debug.log('primaryOpprtunity ==> '+primaryOpprtunity);
        Opportunity objPrimaryOpprtunity = mapOpprtunitiesToMerge.get(primaryOpprtunity);
        
        if(String.isNotBlank(objPrimaryOpprtunity.Tour_Notes__c) && !objPrimaryOpprtunity.Tour_Notes__c.contains(objPrimaryOpprtunity.Name+' : ')){
            objPrimaryOpprtunity.Tour_Notes__c = (objPrimaryOpprtunity.Tour_Notes__c != null && objPrimaryOpprtunity.Tour_Notes__c != '') ? '\r\n'+objPrimaryOpprtunity.Name+' : '+ objPrimaryOpprtunity.Tour_Notes__c : '';   
        } 
        if(String.isNotBlank(objPrimaryOpprtunity.Membership_Agreement_Notes__c) && !objPrimaryOpprtunity.Membership_Agreement_Notes__c.contains(objPrimaryOpprtunity.Name+' : ')){
            objPrimaryOpprtunity.Membership_Agreement_Notes__c = (objPrimaryOpprtunity.Membership_Agreement_Notes__c != null && objPrimaryOpprtunity.Membership_Agreement_Notes__c != '') ? '\r\n'+objPrimaryOpprtunity.Name +' : '+ objPrimaryOpprtunity.Membership_Agreement_Notes__c : '';   
        }
        if(String.isNotBlank(objPrimaryOpprtunity.Tour_Outcome_Notes__c) && !objPrimaryOpprtunity.Tour_Outcome_Notes__c.contains(objPrimaryOpprtunity.Name+' : ')){
            objPrimaryOpprtunity.Tour_Outcome_Notes__c  = (objPrimaryOpprtunity.Tour_Outcome_Notes__c != null && objPrimaryOpprtunity.Tour_Outcome_Notes__c != '') ? '\r\n'+objPrimaryOpprtunity.Name+' : '+ objPrimaryOpprtunity.Tour_Outcome_Notes__c : '';   
        }
        if(String.isNotBlank(objPrimaryOpprtunity.Description) && !objPrimaryOpprtunity.Description.contains(objPrimaryOpprtunity.Name+' : ')){
            objPrimaryOpprtunity.Description = (objPrimaryOpprtunity.Description != null && objPrimaryOpprtunity.Description != '') ? '\r\n'+objPrimaryOpprtunity.Name+' : '+ objPrimaryOpprtunity.Description : '';   
        }
        mapOpprtunitiesToMerge.remove(primaryOpprtunity);
        debug.log('mapOpprtunitiesToMerge ==> '+mapOpprtunitiesToMerge);
        Opportunity objOppToMerge = new Opportunity();
        Set<String> setLocationNames = new Set<String>();
        Set<String> setPrimaryOppLocationNames = new Set<String>();            
        if(String.isNotBlank(objPrimaryOpprtunity.Locations_Interested__c)){
            setPrimaryOppLocationNames.addAll(new list<string>(objPrimaryOpprtunity.Locations_Interested__c.split(';')));   
        }
        for(Opportunity currentOpp : mapOpprtunitiesToMerge.values()){
            currentOpp.StageName = 'Merged';
            //Changes Made by Milanjeet
            //Purpose: To Resolve apending of string in null
            if(String.isBlank(objPrimaryOpprtunity.Tour_Notes__c))
                objPrimaryOpprtunity.Tour_Notes__c ='';
            if(String.isBlank(objPrimaryOpprtunity.Membership_Agreement_Notes__c))
                objPrimaryOpprtunity.Membership_Agreement_Notes__c = '';
            if(String.isBlank(objPrimaryOpprtunity.Tour_Outcome_Notes__c))
                objPrimaryOpprtunity.Tour_Outcome_Notes__c ='';
            if(String.isBlank(objPrimaryOpprtunity.Description))
                objPrimaryOpprtunity.Description ='';
            
            objPrimaryOpprtunity.Tour_Notes__c += String.isNotBlank(currentOpp.Tour_Notes__c) ? '\r\n'+currentOpp.Name+':'+ currentOpp.Tour_Notes__c : '';
            objPrimaryOpprtunity.Membership_Agreement_Notes__c += String.isNotBlank(currentOpp.Membership_Agreement_Notes__c) ? '\r\n'+currentOpp.Name+':'+ currentOpp.Membership_Agreement_Notes__c : '';
            objPrimaryOpprtunity.Tour_Outcome_Notes__c += String.isNotBlank(currentOpp.Tour_Outcome_Notes__c) ? '\r\n'+currentOpp.Name+':'+ currentOpp.Tour_Outcome_Notes__c : '';
            objPrimaryOpprtunity.Description += String.isNotBlank(currentOpp.Description) ? '\r\n'+currentOpp.Name+':'+ currentOpp.Description : '';
            currentOpp.Merged_Opprtunity__c = objPrimaryOpprtunity.Id;
            currentOpp.Merged_On__c = DateTime.now();
            
            if(currentOpp.Amount == null){
                currentOpp.Amount = 0; 
            }                   
            debug.log('currentOpp.Locations_Interested__c: '+currentOpp.Locations_Interested__c);
            if(String.isNotBlank(currentOpp.Locations_Interested__c)){
                setLocationNames.addAll(new list<string>(currentOpp.Locations_Interested__c.split(';')));  
            }                
            currentOpp.Locations_Interested__c = null;
        }
        Debug.log('setLocationNames ==>'+setLocationNames);
        for(String currentLocationName : setLocationNames){
            if(String.isNotBlank(objPrimaryOpprtunity.Locations_Interested__c) && !setPrimaryOppLocationNames.contains(currentLocationName)){
                objPrimaryOpprtunity.Locations_Interested__c +=';'+currentLocationName;
            }else if(!setPrimaryOppLocationNames.contains(currentLocationName)){
                objPrimaryOpprtunity.Locations_Interested__c = currentLocationName;   
            }
        }
        mapOpprtunitiesToMerge.put(objPrimaryOpprtunity.Id,objPrimaryOpprtunity);
        Debug.log('mapOpprtunitiesToMerge after primary opp added==>'+mapOpprtunitiesToMerge);
        update mapOpprtunitiesToMerge.values();
        OpportunityHandler.moveRelatedObjects(mergeOppIds,primaryOpprtunity);            
        return true;
    }
    
  /*****************************************************************************************************************************************
        Author              :   Amol Darekar
        Description         :   This method is used to create sObjects present on primary opportunity on secondory opportunity.
        Created Date        :   25 April 2017
		Issue 				: 	ST-987
  *****************************************************************************************************************************************
		Modified By      	:   Milanjeet Singh 
 		Last Modified Date  :   -
		Issue 				: 	ST-1628
  ****************************************************************************************************************************************
		Modified By      	:   Krishana Tupe 
 		Last Modified Date  :   18 July 2018 		
  *******************************************************************************************************************************************/
  @AuraEnabled
    public static void moveRelatedObjects(string mergeOppIds,string primaryOpprtunity){
        Set<string> setMergeOppIds = new Set<string>();
        setMergeOppIds.addAll((List<String>)JSON.deserialize(mergeOppIds, List<String>.class));
        List<sObject> lstAllSobjToUpdate = new List<sObject>();
        List<sObject> lstReturnedSobjToUpdate = new List<sObject>();
        String strQuery;
        Setting__c opportunityRelatedObjectsSettings = Settings.get('OpportunityRelatedObjectSettings');        
        MergeOpportunityContainer objOppMergeSettings = (MergeOpportunityContainer)JSON.deserialize(opportunityRelatedObjectsSettings.Data__c, MergeOpportunityContainer.class);
        for(RelatedObjectSettings currentSettings : objOppMergeSettings.MergeObjectSettings){
            debug.Log('currentSettings ==>'+currentSettings);
            if(!currentSettings.IsNew){                
                //ST-1628 Changes Done by Milanjeet Singh
                strQuery = 'SELECT '+ currentSettings.FieldToUpdate;
                if(String.isNotBlank(currentSettings.FieldToQuery)){
                    debug.Log('currentSettings.FieldToQuery------'+currentSettings.FieldToQuery);
                    strQuery +=', '+currentSettings.FieldToQuery;
                }                
                strQuery +=' FROM '+currentSettings.ObjectType +' WHERE '+ currentSettings.FieldToUpdate +' IN : setMergeOppIds'; 
                Debug.log('strDynamic Query::'+strQuery);
                Debug.log('primaryOpprtunity::'+primaryOpprtunity);
                if(currentSettings.ObjectType != 'Opportunity_Role__c'){
                    lstReturnedSobjToUpdate = OpportunityHandler.fetchRelatedSobjects(setMergeOppIds,primaryOpprtunity,strQuery, currentSettings.FieldToUpdate,currentSettings.Condition);    
                }else{
                    lstReturnedSobjToUpdate = OpportunityHandler.getOpportunityRoles(setMergeOppIds,primaryOpprtunity);  
                }                   
                Debug.log('lstAllSobjToUpdate Before ==>'+lstAllSobjToUpdate);  
                if(lstReturnedSobjToUpdate != null && lstReturnedSobjToUpdate.size() > 0){
                    lstAllSobjToUpdate.addAll(lstReturnedSobjToUpdate);
                } 
            }
        }
        OpportunityHandler.insertOppRelatedObjects(mergeOppIds,primaryOpprtunity);
        Debug.log('lstAllSobjToUpdate After==>'+lstAllSobjToUpdate);
        if(lstAllSobjToUpdate != null && lstAllSobjToUpdate.size()>0){
            update lstAllSobjToUpdate; 
        }
    }
 
 /************************************************************************************************************************************
        Author              :   Amol Darekar
        Description         :   This method is used to create sObjects present on primary opportunity on secondory opportunity.
        Created Date        :   25 April 2017.
 		Modified By      	:   Krishana Tupe
 		Last Modified Date  :   18 July 2018
 		Issue 				: 	ST-987
 **************************************************************************************************************************************/
   public static void insertOppRelatedObjects(String mergeOppIds,String primaryOpprtunity){       
            set<string> setMergeOppIds = new set<string>();
            setMergeOppIds.addAll((List<String>)JSON.deserialize(mergeOppIds, List<String>.class));
            list<sObject>lstInsertAllsObject = new list<sObject>();
            Setting__c opportunityRelatedObjectsSettings = Settings.get('OpportunityRelatedObjectSettings');           
            MergeOpportunityContainer objOppMergeSettings = (MergeOpportunityContainer)JSON.deserialize(opportunityRelatedObjectsSettings.Data__c, MergeOpportunityContainer.class);
            for(RelatedObjectSettings currentSettings : objOppMergeSettings.MergeObjectSettings){
                Debug.Log('currentSettings ==> '+currentSettings);
                if(currentSettings.IsNew){
                    String strQuery = 'SELECT '+  OpportunityHandler.getSObjectFieldsForQuery(currentSettings.objectType)+' FROM '+currentSettings.objectType+' WHERE '+ currentSettings.FieldToUpdate +' IN: setMergeOppIds';//WHERE OpportunityId IN: setMergeOppIds';		
                    Debug.log('setMergeOppIds::'+setMergeOppIds);
                    Debug.Log('strQuery ==> '+strQuery);
                    List<sObject> lstsObjectToBeFetched = Database.query(strQuery);
                    Debug.log('Related Records of '+currentSettings.objectType+' ==>'+lstsObjectToBeFetched);
                    
                    Map<Id,List<sObject>> mapsObjectItems = new Map<Id,List<sObject>>();
                    Set<Id> setPrimaryObjectsIds =  new Set<Id>();
                    for(sObject currentsObject: lstsObjectToBeFetched){
                        if(mapsObjectItems.containsKey((Id)currentsObject.get(currentSettings.FieldToUpdate))){
                            list<sObject> newlist = mapsObjectItems.get((Id)currentsObject.get(currentSettings.FieldToUpdate));
                            newlist.add(currentsObject);
                            mapsObjectItems.put((Id)currentsObject.get(currentSettings.FieldToUpdate),newlist);
                        }else{
                            mapsObjectItems.put((Id)currentsObject.get(currentSettings.FieldToUpdate),new list<sObject>{currentsObject});
                        }                        
                        if(!setPrimaryObjectsIds.contains((Id)currentsObject.get(currentSettings.ConditionField))){
                            if((String)currentsObject.get(currentSettings.FieldToUpdate) == primaryOpprtunity && currentSettings.objectType == 'OpportunityTeamMember')
                                setPrimaryObjectsIds.add((Id)currentsObject.get(currentSettings.ConditionField));
                            else if((String)currentsObject.get(currentSettings.FieldToUpdate) == primaryOpprtunity && currentSettings.objectType != 'OpportunityTeamMember')
                                setPrimaryObjectsIds.add((Id)currentsObject.get(currentSettings.ConditionField));
                        }
                        Debug.log('setPrimaryObjectsIds::'+setPrimaryObjectsIds);
                    }
                    Debug.Log('mapsObjectItems ==>'+mapsObjectItems);
                    mapsObjectItems.remove(primaryOpprtunity);
                    
                    List<sObject> lstsObjectsToBeCreated = new List<sObject>();                    
                    for(string currentOppId : mapsObjectItems.keySet()){
                        list<sObject> lstCurrentsObjecs = mapsObjectItems.get(currentOppId);
                        for(sObject currentsObject : lstCurrentsObjecs){
                            if(!setPrimaryObjectsIds.contains((Id)currentsObject.get(currentSettings.ConditionField))){
                                lstsObjectsToBeCreated.add(currentsObject);
                            }
                        }
                    }
                    Debug.Log('lstsObjectsToBeCreated==>'+lstsObjectsToBeCreated);
                    List<sObject>lstNewsObjects = OpportunityHandler.createSObjects(currentSettings.objectType,lstsObjectsToBeCreated);
                    Debug.log('lstNewsObjects Before ==>'+lstNewsObjects);
                    for(sObject currentSObject : lstNewsObjects){
                        currentSObject.put(currentSettings.FieldToUpdate,primaryOpprtunity);
                        if(currentSettings.objectType == 'OpportunityLineItem'){
                            currentSObject.put('TotalPrice',null);   
                        } 
                    }
                    Debug.log('lstNewsObjects After==>'+lstNewsObjects);
                    lstInsertAllsObject.addAll(lstNewsObjects);
                }
            }
        if(lstInsertAllsObject != null && lstInsertAllsObject.size() >0){
            insert lstInsertAllsObject; 
        }          
    }

 /************************************************************************************************************************************
        Author              :   Amol Darekar
        Description         :   This method is used for dynamic query and update opprtunity related field so secondory opprtunity is moved to primary opprtunity.
        Created Date        :   07 April 2017 
 		Modified By      	:   Krishana Tupe
 		Last Modified Date  :   18 July 2018
 		Issue 				: 	ST-987
 **************************************************************************************************************************************/
    public static list<sObject> fetchRelatedSobjects(set<string> setMergeOppIds,string primaryOpprtunity,string strQuery,string FieldToUpdate,List<String> conditions){
        Debug.log('conditions==>'+conditions);
        Debug.log('strQuery==>'+strQuery);
        List<String> lstDuplicateConditionFields;
        if(conditions!=null && conditions.size() >0 ){
            lstDuplicateConditionFields = new List<String>(conditions);
        }
        Debug.log('lstDuplicateConditionFields ==>'+lstDuplicateConditionFields);
        List<sObject> lstSobjToUpdate = new List<sObject>();
        List<sObject> sobjList = Database.query(strQuery);
        Debug.log('List of records of related object ==>'+sobjList);
        
        //ST-1628
        //Changes by Milanjeet
        Set<String> setDuplicateCriteria = new Set<String>();
        if(lstDuplicateConditionFields!=null){
            for(sObject currentSObject : sobjList){
                if(currentSObject.get(FieldToUpdate)==primaryOpprtunity){
                    setDuplicateCriteria.add(getDuplicateCriteria(currentSObject,lstDuplicateConditionFields));
                }
            }
        }        
        debug.Log('setDuplicateCriteria ==>'+setDuplicateCriteria);
        for(sObject currentSObject : sobjList){
            String criteria;
            if(lstDuplicateConditionFields!=null){
                criteria = getDuplicateCriteria(currentSObject,lstDuplicateConditionFields);
            }
            Debug.Log('criteria==> '+criteria);
            if(criteria==null || (!setDuplicateCriteria.contains(criteria))){
                debug.Log('Not in criteria==>');
                currentSObject.put(FieldToUpdate,primaryOpprtunity);
            }
        }
        Debug.log('List of records to reparent==> '+sobjList);
        return sobjList;
    }
  
 /************************************************************************************************************************************
        Author              :   Ajaysinh Chauhan
        Description         :   This method returns the duplicate criteria strings.
        Created Date        :   16 April 2017 
 		Modified By      	:   Krishana Tupe
 		Last Modified Date  :   18 July 2018
 **************************************************************************************************************************************/ 
    public static String getDuplicateCriteria(sObject obj,List<String> fields){
        List<String> lstCriteria = new List<String>();
        debug.Log('getDuplicateCriteria Obj:'+obj);
        debug.Log('getDuplicateCriteria fields:'+fields);
        for(String field : fields){
            debug.Log('field-------'+field);
            if(field.contains('__r')){
                List<String> tempFields = field.split('\\.');
                debug.Log('tempFields');
                if(tempFields.size()==2){
                    debug.Log('Relational Field---'+String.valueOf(obj.getSObject(tempFields[0]).get(tempFields[1])));
                    lstCriteria.add(String.valueOf(obj.getSObject(tempFields[0]).get(tempFields[1])));
                }else if(tempFields.size()==3){
                    lstCriteria.add(String.valueOf(obj.getSObject(tempFields[0]).getSObject(tempFields[1]).get(tempFields[2])));
                }
            }else{
                lstCriteria.add(String.valueOf(obj.get(field)));
            }
        }
        debug.Log('lstCriteria--------'+lstCriteria);
        return String.join(lstCriteria, '<=!=>');
    }
   
  /************************************************************************************************************************************
        Author              :   Amol Darekar
        Description         :   This method returns the OpportunityRelatedObjectSettings settings data.
        Created Date        :   16 April 2017 
 		Modified By      	:   Krishana Tupe
 		Last Modified Date  :   18 July 2018
  **************************************************************************************************************************************/ 
    @AuraEnabled
    public static list<String> getOpportunityStagesForMerge(){       
        Setting__c opportunityRelatedObjectsSettings = Settings.get('OpportunityRelatedObjectSettings');
        MergeOpportunityContainer objOppMergeSettings = (MergeOpportunityContainer)JSON.deserialize(opportunityRelatedObjectsSettings.Data__c, MergeOpportunityContainer.class);
        return objOppMergeSettings.OppStages;
    }
   
  /************************************************************************************************************************************
        Author              :   Amol Darekar
        Description         :   This method is used to create sObject record return list of sObject record to be inserted on primary opportunity.
        Created Date        :   16 April 2017 
 		Modified By      	:   Krishana Tupe
 		Last Modified Date  :   18 July 2018
  **************************************************************************************************************************************/ 
    public static list<sObject> createSObjects(string sObjectName, list<sObject> lstsObjectRecordToCreate){        
        // sObject objNewSobject = Schema.getGlobalDescribe().get(sObjectName).newSObject();        
        /*DescribeSObjectResult objDef = objToken.getDescribe();      
        Map<String, SObjectField> mapOfFields = objDef.fields.getMap();
        Set<String> fieldSet = mapOfFields.keySet();*/
        Map<String, SObjectField> mapOfFields = Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap();
        List<sObject> lstNewsObjects = new List<sObject>();        
        for(sObject currentSObject: lstsObjectRecordToCreate){
            sObject newSobject = Schema.getGlobalDescribe().get(sObjectName).newSObject();                
            for(string currentFieldName : mapOfFields.keySet()){
                if(mapOfFields.get(currentFieldName).getDescribe().isCreateable()){
                    newSobject.put(currentFieldName,currentSObject.get(currentFieldName));
                }
            } 
            lstNewsObjects.add(newSobject);
        }
        Debug.log('lstNewsObjects==>'+lstNewsObjects);
        return lstNewsObjects;
    }    
  
  /************************************************************************************************************************************
        Author              :   Amol Darekar
        Description         :   This method is used to get sObject fields whose value we can assign at the time of creation.
        Created Date        :   16 April 2017 
 		Modified By      	:   Krishana Tupe
 		Last Modified Date  :   18 July 2018
  **************************************************************************************************************************************/ 
    public static String getSObjectFieldsForQuery(String objectAPIName){ 
            /*sObject objNewSobject = Schema.getGlobalDescribe().get(objectAPIName).newSObject();
            SObjectType objToken = Schema.getGlobalDescribe().get(objectAPIName);
            DescribeSObjectResult objDef = objToken.getDescribe();      
            Map<String, SObjectField> mapOfFields = objDef.fields.getMap();
            Set<String> fieldSet = mapOfFields.keySet();*/
        String objectFieldsToQuery = '';
        Map<String, SObjectField> mapOfFields = Schema.getGlobalDescribe().get(objectAPIName).getDescribe().fields.getMap();
        for(string currentFieldName : mapOfFields.keySet()){
            if(mapOfFields.get(currentFieldName).getDescribe().isCreateable())
                objectFieldsToQuery += currentFieldName +',';
        } 
        if(String.isNotBlank(objectFieldsToQuery) && objectFieldsToQuery.endsWith(',')){
            objectFieldsToQuery= objectFieldsToQuery.substring(0,objectFieldsToQuery.length()-1);  
        } 
        Debug.log('objectFieldsToQuery==>'+objectFieldsToQuery);            
        return objectFieldsToQuery;
    }
    
 /************************************************************************************************************************************
        Author              :   Amol Darekar
        Description         :   This method is used to get sObject fields whose value we can assign at the time of creation.
        Created Date        :   16 April 2017 
 		Modified By      	:   Krishana Tupe
 		Last Modified Date  :   18 July 2018
  **************************************************************************************************************************************/ 
    public static list<sObject> getOpportunityRoles(set<string> setMergeOppIds,string primaryOpprtunity){      
        List<Opportunity_Role__c> lstPrimaryOppRoles = [Select Contact__c,Is_Primary_Member__c,Opportunity__c FROM Opportunity_Role__c where Opportunity__c =:primaryOpprtunity];
        List<Opportunity_Role__c> lstSecondaryOppRoles	 = [Select Contact__c,Is_Primary_Member__c,Opportunity__c FROM Opportunity_Role__c where Opportunity__c IN: setMergeOppIds];
        List<Opportunity_Role__c> lstOpportunityRolesToMove = new List<Opportunity_Role__c>();
        set<string> setPrimaryOppIds = new set<string>();
        Boolean isPrimary = false;
        Debug.log('OpportunityHandler:getOpportunityRoles:lstPrimaryOppRoles==>'+lstPrimaryOppRoles);
        Debug.log('OpportunityHandler:getOpportunityRoles:lstSecondaryOppRoles==>'+lstSecondaryOppRoles);
        for(Opportunity_Role__c currentSObject : lstPrimaryOppRoles){
            setPrimaryOppIds.add(currentSObject.Contact__c);
            if(currentSObject.Is_Primary_Member__c){
                isPrimary = true;
            }
        }
        for(Opportunity_Role__c currentSObject : lstSecondaryOppRoles){
            if(currentSObject.Is_Primary_Member__c && isPrimary){
                currentSObject.Is_Primary_Member__c = false;
            } 
            if(!setPrimaryOppIds.contains(currentSObject.Contact__c) && currentSObject.Id != primaryOpprtunity){
                currentSObject.Opportunity__c = primaryOpprtunity;
                currentSObject.Role__c = 'Influencer';
                lstOpportunityRolesToMove.add(currentSObject);
            }
        }
        Debug.log('OpportunityHandler:getOpportunityRoles:setPrimaryOppIds::'+setPrimaryOppIds);	
        Debug.log('OpportunityHandler:getOpportunityRoles:lstPrimaryRoles::'+lstOpportunityRolesToMove);
        return lstOpportunityRolesToMove;
    }
    
    public class MergeOpportunityContainer {
        public List<RelatedObjectSettings> MergeObjectSettings;
        public List<String> OppStages;
    }
    
    public class RelatedObjectSettings {
        public String ObjectType;
        public String FieldToUpdate;
        public List<String> Condition;
        public boolean IsNew;
        public String ConditionField;
        public String FieldToQuery;
    }
    
    public class OpportunityHandlerException extends Exception{}
}