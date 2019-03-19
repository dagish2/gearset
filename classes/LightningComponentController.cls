/************************************************************************************************************************************
    Author      :   Ajaysinh Chauhan
    Description :   This class contain all aura methods that are used in lightning components.

    History     :
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1           -                   Ajaysinh Chauhan        Initial Developement
    2           03 May 2018         Krishana Tupe           Chnages for exception logging.
**************************************************************************************************************************************/
global without sharing class LightningComponentController{
    public class LightningComponentControllerException extends Exception{}
    public static Boolean isInvoker = false;
    public static Savepoint sp {get;set;}
    static {
        isInvoker = ApexDebugLog.registerRootInvoker(ApexDebugLog.InvokerType.AURA, 'LightningComponentController' + 'getsObjectPrefix', ApexDebugLog.InvokerType.AURA);
    }
   /****************************************************************************************************************************
        Author              : Ajaysinh Chauhan
        Description         : This method used to delete users Logs.Used in apex Log Lightning component
        Created Date        : -
        Last Modified By    : Ashish Mishra
        Last Modified Date  : 31,May 2018
   *****************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult getsObjectPrefix(String objName){
        try{
            DatabaseResult result = new DatabaseResult(Schema.getGlobalDescribe().get(objName).getDescribe().getKeyPrefix());
            return  result;
        }catch(Exception pEx){
            ApexDebugLog.logException(pEx,objName, 'LightningComponentController', 'getsObjectPrefix');
            return (new DatabaseResult(pEx));
        }
    }

    /****************************************************************************************************************************
        Author              : Ajaysinh Chauhan
        Description         : This method used to get TimezoneOffset.
        Created Date        : -
        Last Modified By    : Ashish Mishra
        Last Modified Date  : 31,May 2018
   *****************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult getTimezoneOffset(){
        try{
            TimeZone tz = UserInfo.getTimeZone();
            DatabaseResult result = new DatabaseResult(tz.getOffset(DateTime.newInstance(2017,04,05)));
            return result;
        }catch(Exception pEx){
            ApexDebugLog.logException(pEx,'', 'LightningComponentController', 'getTimezoneOffset');
            return (new DatabaseResult(pEx));
        }
    }

    /****************************************************************************************************************************
        Author              : Ajaysinh Chauhan
        Description         : This method is take a query as a argument in string format and processed the result of Query.
        Created Date        : -
        Last Modified By    : Ashish Mishra
        Last Modified Date  : 31,May 2018
   *****************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult getQueryData(String query) {
        try{
            debug.Log('Query==>'+query);
            DatabaseResult result = new DatabaseResult(Database.query(query));
            debug.Log('result==>'+result);
            return result;
        }catch(Exception pEx){
            ApexDebugLog.logException(pEx,query, 'LightningComponentController', 'getQueryData');
            return (new DatabaseResult(pEx));
        }
    }

    webservice static String getQueryDataService(String query) {
        return JSON.serialize(getQueryData(query));
    }


    /****************************************************************************************************************************
        Author              : Ajaysinh Chauhan
        Description         : This method is take list of query as a argument in string format and processed the result of Queries.
        Created Date        : -
        Last Modified By    : Ashish Mishra
        Last Modified Date  : 31,May 2018
   *****************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult getListQueryData(List<String> arrQuery) {
        try{
            List<List<sObject>> lstData = new List<List<sObject>>();
            for(String s:arrQuery){
                lstData.add(Database.query(s));
            }
            DatabaseResult result = new DatabaseResult(lstData);
            return result;
        }catch(Exception pEx){
            ApexDebugLog.logException(pEx,arrQuery != null ? String.join(arrQuery,','): '', 'LightningComponentController', 'getListQueryData');
            return (new DatabaseResult(pEx));
        }
    }
     /************************************************************************************************************************************
    Author              : Rupesh Patil
    Description         : This method is used to get data by SOSL queries.
    Created Date        : 15 May 2018
    Issue No.           : ST-2379
   **************************************************************************************************************************************/
     @AuraEnabled
    public static DatabaseResult getListQueryDataBySOSL(List<String> arrQuery) {
        try{
            List<List<sObject>> lstData = new List<List<sObject>>();
            for(String s:arrQuery){
                lstData.add(Search.query(s)[0]);
            }
            DatabaseResult result = new DatabaseResult(lstData);
            return result;
        }catch(Exception pEx){
            ApexDebugLog.logException(pEx,arrQuery != null ? String.join(arrQuery,','): '', 'LightningComponentController', 'getListQueryDataBySOSL');
            return (new DatabaseResult(pEx));
        }
    }

    /*******************************************************************************************************************************************
        Author              : Ajaysinh Chauhan
        Description         : This method is takes list of Records as a argument and save newly inserted record and updated record in salesforce.
        Created Date        : -
        Last Modified By    : Ashish Mishra
        Last Modified Date  : 31,May 2018
   ********************************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult saveRecords(List<sObject> records) {
        try{
            sp = Database.setSavepoint();
            List<sObject> lstInsert = new List<sObject>();
            List<sObject> lstUpdate = new List<sObject>();
            for(sObject record : records){
                if(String.isBlank(record.Id))
                    lstInsert.add(record);
                else
                    lstUpdate.add(record);
            }
            Map<String,Object> response = new Map<String,Object>();
            response.put('insertedRecords',Database.insert(lstInsert));
            response.put('updatedRecords',Database.update(lstUpdate));
            DatabaseResult result = new DatabaseResult(JSON.serialize(response));
            Debug.log('Result of saveRecords'+result);
            return result;
            //return JSON.serialize(response);
        }catch(Exception pEx){
            if(sp != null){
                Database.rollback(sp);
            }
            System.debug('records::==>'+records);
            ApexDebugLog.logException(pEx,records != null ? JSON.serialize(records) : '', 'LightningComponentController', 'saveRecords');
            return (new DatabaseResult(pEx));
        }
    }

    /****************************************************************************************************************************
        Author              : Ajaysinh Chauhan
        Description         : This method is takes single Records as a argument and save newly inserted record and updated record in salesforce.
        Created Date        : -
        Last Modified By    : Ashish Mishra
        Last Modified Date  : 31,May 2018
   *****************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult saveRecord(sObject record) {
        debug.log('Record==>'+ record);
        try{
            sp = Database.setSavepoint();
            if(String.isBlank(record.Id)){
                DatabaseResult result = new DatabaseResult(JSON.serialize(Database.insert(record)));
                return result;
            }else{
                DatabaseResult result = new DatabaseResult(JSON.serialize(Database.update(record)));
                return result;
            }
        }catch(Exception pEx){
            if(sp != null){
                Database.rollback(sp);
            }
            ApexDebugLog.logException(pEx,JSON.serialize(record), 'LightningComponentController', 'saveRecord');
            return (new DatabaseResult(pEx));
        }
    }

   /****************************************************************************************************************************
        Author              : Krishna Tupe
        Description         : This method is use to delete single record.
        Created Date        : -
        Last Modified By    : Ashish Mishra
        Last Modified Date  : 31,May 2018
   *****************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult deleteRecord(String recordToDelete) {
        try{
            sp = Database.setSavepoint();
            Id deleteRecord=(Id)recordToDelete;
            Debug.log('recordId------'+deleteRecord);
            DatabaseResult result = new DatabaseResult(JSON.serialize(Database.delete(deleteRecord)));
            return result;
        }catch(Exception pEx){
            if(sp != null){
                Database.rollback(sp);
            }
            ApexDebugLog.logException(pEx,recordToDelete, 'LightningComponentController', 'deleteRecord');
            return (new DatabaseResult(pEx));
        }
    }

   /****************************************************************************************************************************
        Author              : Ajaysinh Chauhan
        Description         : This method is use to delete list of records.
        Created Date        : -
        Last Modified By    : Ashish Mishra
        Last Modified Date  : 31,May 2018
   *****************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult deleteRecords(List<String> recordsToDelete) {
        try{
            sp = Database.setSavepoint();
            DatabaseResult result = new DatabaseResult(JSON.serialize(Database.delete(recordsToDelete)));
            return result;
        }catch(Exception pEx){
            if(sp != null){
                Database.rollback(sp);
            }
            ApexDebugLog.logException(pEx,recordsToDelete != null ? String.join(recordsToDelete,','): '', 'LightningComponentController', 'deleteRecords');
            return (new DatabaseResult(pEx));
        }
    }

   /****************************************************************************************************************************
        Author              : Ajaysinh Chauhan
        Description         : This method is use to get Object field metadate by using getDescribe().
        Created Date        : -
        Last Modified By    : Ashish Mishra
        Last Modified Date  : 31,May 2018
   *****************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult getFieldsMetadata(String sObjectName,List<String> fields) {
        try{
            Map<String,Object> mapFields = new Map<String,Object>();
            for(String fieldName : fields){
                mapFields.put(fieldName,Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap().get(fieldName).getDescribe());
            }
            DatabaseResult result = new DatabaseResult(JSON.serialize(mapFields));
            return result;
        }catch(Exception pEx){
            ApexDebugLog.logException(pEx,'sObjectName==>'+sObjectName+' fields==>'+String.join(fields, ','), 'LightningComponentController', 'getFieldsMetadata');
            return (new DatabaseResult(pEx));
        }
    }

    /****************************************************************************************************************************
        Author              : Ajaysinh Chauhan
        Description         : This method is use to get Relation Fields Metadata metadate by using getDescribe().
        Created Date        : -
        Last Modified By    : Ashish Mishra
        Last Modified Date  : 31,May 2018
   *****************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult getRelationFieldsMetadata(List<String> fields) {
        try{
            Map<String,Object> mapFields = new Map<String,Object>();
            for(String field:fields){
                String name = field.split(':')[0];
                String relation = field.split(':')[1];
                String sObjectName = relation.substring(0,relation.indexOf('.'));
                String fieldName = relation.substring(relation.indexOf('.')+1,relation.length());
                mapFields.put(name,Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap().get(fieldName).getDescribe());
            }
             DatabaseResult result = new DatabaseResult(JSON.serialize(mapFields));
            return result;
        }catch(Exception pEx){
            ApexDebugLog.logException(pEx,fields != null ? String.join(fields,','): '', 'LightningComponentController', 'getRelationFieldsMetadata');
            return (new DatabaseResult(pEx));
        }
    }
    /****************************************************************************************************************************
        Author              : Ajaysinh Chauhan
        Description         : This method is use to get field Metadata by using getDescribe().
        Created Date        : -
        Last Modified By    : Ashish Mishra
        Last Modified Date  : 31,May 2018
   *****************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult getFieldMetadata(String sObjectName,String fieldName) {
        Debug.log('sObjectName----'+sObjectName);
        Debug.log('fieldName---'+fieldName);
        try{
            DatabaseResult result = new DatabaseResult(JSON.serialize(Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap().get(fieldName).getDescribe()));
            return result;
        }catch(Exception pEx){
            ApexDebugLog.logException(pEx,'sObjectName==>'+sObjectName+' fields==>'+fieldName, 'LightningComponentController', 'getFieldMetadata');
            return (new DatabaseResult(pEx));
        }
    }

   /****************************************************************************************************************************
        Author              : Ajaysinh Chauhan
        Description         : This method is takes sobject name as a argument and get All the Fields.
        Created Date        : -
        Last Modified By    : Ashish Mishra
        Last Modified Date  : 31,May 2018
   *****************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult getAllFields(String sObjectName) {
        try{
            Map<String,Object> mapFields = new Map<String,Object>();
            List<Schema.DescribeFieldResult> lstFields = new List<Schema.DescribeFieldResult>();
            for(String fieldName:Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap().keyset()){
                Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap().get(fieldName).getDescribe();
                if(fieldResult.isCreateable()){
                    lstFields.add(fieldResult);
                }
            }
            mapFields.put('name',sObjectName);
            mapFields.put('label',Schema.getGlobalDescribe().get(sObjectName).getDescribe().getLabel());
            mapFields.put('fields',lstFields);
            DatabaseResult result = new DatabaseResult(JSON.serialize(mapFields));
            return result;
        }catch(Exception pEx){
            ApexDebugLog.logException(pEx,sObjectName, 'LightningComponentController', 'getAllFields');
            return (new DatabaseResult(pEx));
        }
    }

   /****************************************************************************************************************************
        Author              : Ajaysinh Chauhan
        Description         : This method is used to get Related Refernces.
        Created Date        : -
        Last Modified By    : Ashish Mishra
        Last Modified Date  : 31,May 2018
   *****************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult getRelatedRefernces(String sObjectName,List<String> childs) {
        try{
            Map<String,Object> mapFields = new Map<String,Object>();
            for(String child:childs){
                List<Map<String,String>> lstFields = new List<Map<String,String>>();
                for(String fieldName:Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap().keyset()){
                    Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap().get(fieldName).getDescribe();
                    if(String.valueOf(fieldResult.getType())=='REFERENCE' && String.valueOf(fieldResult.getReferenceTo()[0])==sObjectName.toUpperCase()){
                        lstFields.add(new Map<String,String>{'name'=>fieldResult.getName(),'label'=>fieldResult.getLabel()});
                    }
                }
                mapFields.put(child,lstFields);
            }

          DatabaseResult result = new DatabaseResult(JSON.serialize(mapFields));
          return result;
        }
        catch(Exception pEx){
            ApexDebugLog.logException(pEx,'sObjectName==>'+sObjectName+' childs==>'+String.join(childs, ','), 'LightningComponentController', 'getRelatedRefernces');
            return (new DatabaseResult(pEx));
        }
    }

   /****************************************************************************************************************************
        Author              : Ajaysinh Chauhan
        Description         : This method is used to get all Objects.
        Created Date        : -
        Last Modified By    : Ashish Mishra
        Last Modified Date  : 31,May 2018
   *****************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult getAllObjects() {
        try{
            Map<String,Map<String,Object>> mapObjects = new Map<String,Map<String,Object>>();
            Map<String, Schema.SObjectType> mapDescribedObjects = Schema.getGlobalDescribe();
            Map<String, DescribeSObjectResult> mapDescribedResults = new Map<String, DescribeSObjectResult>();
            Set<String> setStandardObjects = new Set<String>{'lead','account','contact','opportunity','campaign'};
                for(String objectName:mapDescribedObjects.keyset()){
                    DescribeSObjectResult objectResult = mapDescribedObjects.get(objectName).getDescribe();
                    if(objectResult.getName().split('__').size()<=2 && (objectResult.isCustom() || setStandardObjects.contains(objectResult.getName().toLowerCase())) && objectResult.isAccessible() && objectResult.isCreateable() && objectResult.isDeletable() && objectResult.isQueryable() && !objectResult.isCustomSetting()){
                        mapDescribedResults.put(objectResult.getName(),objectResult);
                    }
                }
            for(DescribeSObjectResult obj:mapDescribedResults.values()){
                List<Map<String,String>> lstChilds = new List<Map<String,String>>();
                Set<String> setChilds = new Set<String>();
                for(Schema.ChildRelationship child:obj.getChildRelationships()){
                    if(obj.getName()!=String.valueOf(child.getChildSObject()) && mapDescribedResults.keyset().contains(String.valueOf(child.getChildSObject())) && !setChilds.contains(String.valueOf(child.getChildSObject()))){
                        DescribeSObjectResult childObjectResult = mapDescribedResults.get(String.valueOf(child.getChildSObject()));
                        lstChilds.add(new Map<String,String>{'name'=>childObjectResult.getName(),'label'=>childObjectResult.getLabel()});
                        setChilds.add(childObjectResult.getName());
                    }
                }
                mapObjects.put(obj.getName(),new Map<String,Object>{'name'=>obj.getName(),'label'=>obj.getLabel(),'childs'=>lstChilds});
            }
            DatabaseResult result = new DatabaseResult( JSON.serialize(mapObjects.values()) );
            return result;
        }catch(Exception pEx){
            ApexDebugLog.logException(pEx,'', 'LightningComponentController', 'getAllObjects');
            return (new DatabaseResult(pEx));
        }


    }

   /****************************************************************************************************************************
        Author              : Ajaysinh Chauhan
        Description         : This method is used to get query/table data.
        Created Date        : -
        Last Modified By    : Ashish Mishra
        Last Modified Date  : 31,May 2018
   *****************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult getTableData(String query) {
        try{
            Debug.Log('Get Table Data query==>'+query);
            String resultedQuery = escapeSpecialChars(query);
            //Debug.Log('Get Table Data resultedQuery==>'+resultedQuery);
            String countQuery = query.split(' LIMIT')[0];
            // Modified by Dipak Pawar for handler exception
            if(countQuery.containsAny(' Offset 0')){
                countQuery = countQuery.replace(' Offset 0','');
            }
            Map<String,Object> tableData = new Map<String,Object>();
            tableData.put('totalRecords',Database.query(countQuery+' LIMIT 2000').size());
            tableData.put('records',Database.query(query));
            DatabaseResult result = new DatabaseResult( tableData );
        return result;
        } catch(Exception pEx){
            ApexDebugLog.logException(pEx,'getTableData==>'+query, 'LightningComponentController', 'getTableData');
            return (new DatabaseResult(pEx));
        }
    }

    /****************************************************************************************************************************
        Author              : Shivprasad Patil
        Description         : This method is used to get Page Layout for creating new record.
        Created Date        : 17 Oct 2018
        Last Modified By    :
        Last Modified Date  :
   *****************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult getLayoutForNewRecord(String sObjectName) {
        try{
            Schema.DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get(sObjectName).getDescribe();
            String masterRecordTypeId = describeResult.getRecordTypeInfosByName().get('Master').getRecordTypeId();
            DatabaseResult result = LightningComponentController.executeRestQuery(false,'GET',( URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v37.0/sobjects/'+sObjectName+'/describe/layouts/'+masterRecordTypeId ),new Map<String,String>{'Authorization'=>'Standard'},'');
            if(result.success){
                Map<String,Object> mapLayout = new Map<String,Object>();
                mapLayout.put('sObjectName',sObjectName);
                mapLayout.put('label',describeResult.getLabel());
                mapLayout.put('layout',result.data);
                return new DatabaseResult(JSON.serialize(mapLayout));
            }
            return result;
        }catch(Exception pEx){
            ApexDebugLog.logException(pEx,'sObjectName==>'+sObjectName, 'LightningComponentController', 'getLayoutForNewRecord');
            return (new DatabaseResult(pEx));
        }
    }

   /****************************************************************************************************************************
        Author              : Ajaysinh Chauhan
        Description         : This method is used to get Page Layout according to record type.
        Created Date        : -
        Last Modified By    : Ashish Mishra
        Last Modified Date  : 31,May 2018
   *****************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult getLayout(Id recordId) {
        try{
            Debug.Log('recordId::'+recordId);
            String sessionId = UserInfo.getSessionId();
            HttpRequest request = new HttpRequest();
            request.setHeader('Authorization', 'Bearer ' + sessionId);
            request.setHeader('Content-Length', '0');
            request.setMethod('GET');
            String sObjectName = recordId.getSobjectType().getDescribe().getName();
            debug.log('sObjectName:::'+sObjectName);
            List<sObject> lstRecordTypes = [Select Id,Name from RecordType where SObjectType =:sObjectName];
            debug.Log('lstRecordTypes:::'+lstRecordTypes);
            List<sObject> lstRecord;
            if(lstRecordTypes.size()>0){
                lstRecord = Database.query('Select Id,Name,RecordTypeId,RecordType.Name,CreatedDate,CreatedBy.Name,LastModifiedDate,LastModifiedBy.Name from '+sObjectName+' where Id=\''+recordId+'\'');
                debug.Log('lstRecord in IF:::'+lstRecord);
                String recordTypeId;
                if(lstRecord != null && lstRecord.size()>0){
                    recordTypeId = String.valueOf(lstRecord[0].get('RecordTypeId'));
                }

                debug.Log('recordTypeId:::'+recordTypeId);
                if(recordTypeId != null)
                    request.setEndPoint(URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v37.0/sobjects/'+sObjectName+'/describe/layouts/'+recordTypeId);
                else{
                    debug.Log('In Else no recordType:::'+ recordId.getSobjectType().getDescribe().getRecordTypeInfosByName().get('Master').getRecordTypeId());
                    recordTypeId = recordId.getSobjectType().getDescribe().getRecordTypeInfosByName().get('Master').getRecordTypeId();
                    request.setEndPoint(URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v37.0/sobjects/'+sObjectName+'/describe/layouts/'+recordTypeId);
                }
            }else{
                lstRecord = Database.query('Select Id,Name,CreatedDate,CreatedBy.Name,LastModifiedDate,LastModifiedBy.Name from '+sObjectName+' where Id=\''+recordId+'\'');
                debug.Log('lstRecord in Else:::'+lstrecord);
                request.setEndPoint(URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v37.0/sobjects/'+sObjectName+'/describe/layouts');
            }
            Http req = new Http();
            HttpResponse response = req.send(request);
            Debug.Log('response:::'+response.getBody());
            Map<String,Object> mapLayout = new Map<String,Object>();
            mapLayout.put('sObjectName',sObjectName);
            mapLayout.put('label',recordId.getSobjectType().getDescribe().getLabel());
            mapLayout.put('layout',response.getBody());
            Debug.Log('lstRecordTypes ==>'+lstRecordTypes.size());
            if(lstRecord != null && lstRecord.size()>0)
            {
                if(lstRecordTypes.size()>0){
                    debug.log('lstRecord ==>>'+lstRecord);
                    debug.log('lstRecord11 ==>>'+lstRecord[0].get('RecordTypeId'));
                    if(lstRecord[0].get('RecordTypeId') != null){
                        mapLayout.put('recordTypeId',lstRecord[0].get('RecordTypeId'));
                        mapLayout.put('recordTypeName',lstRecord[0].getSObject('RecordType').get('Name'));
                    }else{
                        mapLayout.put('recordTypeId',recordId.getSobjectType().getDescribe().getRecordTypeInfosByName().get('Master').getRecordTypeId());
                        mapLayout.put('recordTypeName',recordId.getSobjectType().getDescribe().getRecordTypeInfosByName().get('Master').getName());
                    }
                }
                mapLayout.put('recordName',lstRecord[0].get('Name'));
            }
            mapLayout.put('lstRecordTypes',lstRecordTypes);
            debug.Log('mapLayout:::'+mapLayout);
            return new DatabaseResult( JSON.serialize(mapLayout) );
       }catch(Exception pEx){
            ApexDebugLog.logException(pEx,'recordId==>'+recordId, 'LightningComponentController', 'getLayout');
            return (new DatabaseResult(pEx));
        }
    }

   /****************************************************************************************************************************
        Author              : Ajaysinh Chauhan
        Description         : This method is used to get Page Layout with mapping.
        Created Date        : -
        Last Modified By    : Ashish Mishra
        Last Modified Date  : 31,May 2018
   *****************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult getLayoutWithMapping(String sObjectName) {
        try{
            String sessionId = UserInfo.getSessionId();
            HttpRequest request = new HttpRequest();
            request.setHeader('Authorization', 'Bearer ' + sessionId);
            request.setHeader('Content-Length', '0');
            request.setMethod('GET');
            List<sObject> lstRecordTypes = [Select Id,Name from RecordType where SObjectType =:sObjectName];
            Map<String,Object> mapResponse = new Map<String,Object>();
            Map<String,Object> tempMap;
            if(lstRecordTypes.size()==0){
                tempMap = new Map<String,Object>();
                tempMap.put('recordTypeId','default');
                tempMap.put('recordTypeName','Default');
                request.setEndPoint(URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v37.0/sobjects/'+sObjectName+'/describe/layouts');
                Http req = new Http();
                HttpResponse response = req.send(request);
                tempMap.put('layout',response.getBody());
                mapResponse.put('default',tempMap);
            }else{
                for(sObject rec:lstRecordTypes){
                    tempMap = new Map<String,Object>();
                    tempMap.put('recordTypeId',rec.get('Id'));
                    tempMap.put('recordTypeName',rec.get('Name'));
                    request.setEndPoint(URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v37.0/sobjects/'+sObjectName+'/describe/layouts/'+rec.Id);
                    Http req = new Http();
                    HttpResponse response = req.send(request);
                    tempMap.put('layout',response.getBody());
                    mapResponse.put(String.valueOf(rec.get('Id')),tempMap);
                }
            }
            mapResponse.put('recordTypes',lstRecordTypes);
            DatabaseResult result = new DatabaseResult( mapResponse );
      return result;
        }catch(Exception pEx){
            ApexDebugLog.logException(pEx,'sObjectName==>'+sObjectName, 'LightningComponentController', 'getLayoutWithMapping');
            return (new DatabaseResult(pEx));
        }
    }

   /****************************************************************************************************************************
        Author              : Ajaysinh Chauhan
        Description         : This method is used to describe By Id.
        Created Date        : -
        Last Modified By    : Ashish Mishra
        Last Modified Date  : 31,May 2018
   *****************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult describeById(List<Id> lstIds) {
        try{
            Map<Id,String> mapResponse = new Map<Id,String>();
            for(Id rec:lstIds){
                mapResponse.put(rec,rec.getSobjectType().getDescribe().getLabel());
            }
            DatabaseResult result = new DatabaseResult( mapResponse );
      return result;
        } catch(Exception pEx){
            ApexDebugLog.logException(pEx,'lstIds==>'+lstIds, 'LightningComponentController', 'describeById');
            return (new DatabaseResult(pEx));
        }

    }

   /****************************************************************************************************************************
        Author              : Ajaysinh Chauhan
        Description         : This method is used to get Sobject name by record Id.
        Created Date        : -
        Last Modified By    : Ashish Mishra
        Last Modified Date  : 31,May 2018
   *****************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult getSobjectNameById(Id recordId) {
        try{
            Schema.SObjectType sobjectType = recordId.getSObjectType();
            DatabaseResult result = new DatabaseResult( sobjectType.getDescribe().getName() );
            return result;
        }catch(Exception pEx){
            ApexDebugLog.logException(pEx,'recordId==>'+recordId, 'LightningComponentController', 'getSobjectNameById');
            return (new DatabaseResult(pEx));
        }
    }

   /****************************************************************************************************************************
        Author              : Ajaysinh Chauhan
        Description         : This method is used to get all record types by record Id.
        Created Date        : -
        Last Modified By    : Ashish Mishra
        Last Modified Date  : 31,May 2018
   *****************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult getAllRecordTypesById(Id recordId) {
        try{
            Schema.SObjectType sobjectType = recordId.getSObjectType();
            List<RecordType> lstRecordTypes = [Select Id,Name from RecordType where SobjectType=:sobjectType.getDescribe().getName()];
            DatabaseResult result = new DatabaseResult( lstRecordTypes );
      return result;
        }catch(Exception pEx){
            ApexDebugLog.logException(pEx,'recordId==>'+recordId, 'LightningComponentController', 'getAllRecordTypesById');
            return (new DatabaseResult(pEx));
        }
    }

   /****************************************************************************************************************************
        Author              : Ajaysinh Chauhan
        Description         : This method is used to get User Information.
        Created Date        : -
        Last Modified By    : Ashish Mishra
        Last Modified Date  : 31,May 2018
   *****************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult getUserInfo() {
        try{
            DatabaseResult result = new DatabaseResult( JSON.serialize([Select Id,Name,Email,SmallPhotoUrl,Profile.Name,TimeZoneSidKey from User Where Id=:UserInfo.getUserId()]) );
            return result;
        }catch(Exception pEx){
            ApexDebugLog.logException(pEx,'', 'LightningComponentController', 'getUserInfo');
            return (new DatabaseResult(pEx));
        }
    }

   /****************************************************************************************************************************
        Author              : Ajaysinh Chauhan
        Description         : This method is used to get UI Theme.
        Created Date        : -
        Last Modified By    : Ashish Mishra
        Last Modified Date  : 31,May 2018
   *****************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult getUITheme() {
        try{
            DatabaseResult result = new DatabaseResult( UserInfo.getUiTheme() );
      return result;
        }catch(Exception pEx){
            ApexDebugLog.logException(pEx,'', 'LightningComponentController', 'getUITheme');
            return (new DatabaseResult(pEx));
        }
    }

   /****************************************************************************************************************************
        Author              : Ajaysinh Chauhan
        Description         : This method is used to get Record Type Information.
        Created Date        : -
        Last Modified By    : Ashish Mishra
        Last Modified Date  : 31,May 2018
   *****************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult getRecordTypeInfo(String objName) {
        try{
            Map<Id,String> recTypeNameWithIdMap= new Map<Id,String>();
            if(objName!= null){
                for(Schema.RecordTypeInfo recInfo : Schema.getGlobalDescribe().get(objName).getDescribe().getRecordTypeInfosByName().values()){
                    recTypeNameWithIdMap.put(recInfo.getRecordTypeId(),recInfo.getName());
                }
            }
            DatabaseResult result = new DatabaseResult( recTypeNameWithIdMap );
            return result;
        } catch(Exception pEx){
            ApexDebugLog.logException(pEx,'sObjectName==>'+objName, 'LightningComponentController', 'getRecordTypeInfo');
            return (new DatabaseResult(pEx));
        }
    }

    /****************************************************************************************************************************
        Author              : Ajaysinh Chauhan
        Description         : Class for SendPaperwork data.
        Created Date        : -
        Last Modified By    : Ashish Mishra
        Last Modified Date  : 31,May 2018
   *****************************************************************************************************************************/
    global class SendPaperwork {
        @AuraEnabled
        public List<OpportunityCreationSetting> OpportunityCreationSetting;
        @AuraEnabled
        public String URL;
        @AuraEnabled
        public List<String> ExcludedProfiles;
    }

    /****************************************************************************************************************************
        Author              : Ajaysinh Chauhan
        Description         : Class for OpportunityCreationSetting.
        Created Date        : -
        Last Modified By    : Ashish Mishra
        Last Modified Date  : 31,May 2018
   *****************************************************************************************************************************/
    public class OpportunityCreationSetting {
        @AuraEnabled
        public String RecordType;
        @AuraEnabled
        public String CompanySize;
    }

/****************************************************************************************************************************
        Author              : Ajaysinh Chauhan
        Description         : This is a class for ValidResultWithOpp data.
        Created Date        : -
        Last Modified By    : Ashish Mishra
        Last Modified Date  : 31,May 2018
   *****************************************************************************************************************************/
    global class ValidResultWithOpp{
        @AuraEnabled
        Public Boolean isValid {get;set;}
        @AuraEnabled
        Public Boolean isValidOwner {get;set;}
        @AuraEnabled
        Public String errorMsg {get;set;}
        @AuraEnabled
        Public Opportunity objOpportunity {get;set;}
        @AuraEnabled
        Public List<String> opportunityBuildings {get;set;}
    }

   /****************************************************************************************************************************
        Author              : Ajaysinh Chauhan
        Description         : This method is used to check Oppourtunity is valid for SendProposal.
        Created Date        : -
        Last Modified By    : Ashish Mishra
        Last Modified Date  : 31,May 2018
   *****************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult isValidOppforSendProposal(Id oppId){
        try{
            ValidResultWithOpp validResult = new ValidResultWithOpp();
            List<Opportunity> lstOpportunities = [SELECT Id,recordTypeID,Account.uuid__c,Encoded_ID__c,OwnerId from Opportunity WHERE Id =: oppId Limit 1];
            validResult.isValid = true;
            validResult.objOpportunity = lstOpportunities.get(0);
            validResult.objOpportunity.Proposal_Sent_On__c = datetime.now();
            update validResult.objOpportunity;
            DatabaseResult result = new DatabaseResult( validResult );
            return result;
        } catch(Exception pEx){
            ApexDebugLog.logException(pEx,'', 'LightningComponentController', 'isValidOppforSendProposal');
            return (new DatabaseResult(pEx));
        }
    }

   /****************************************************************************************************************************
        Author              : Ajaysinh Chauhan
        Description         : This method is used to check Oppourtunity is valid for SendProposal.
        Created Date        : -
        Last Modified By    : Ashish Mishra
        Last Modified Date  : 31,May 2018
   *****************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult describeTable(String sObjectName,List<String> fields){
        try{
            Map<String,Object> mapFields = new Map<String,Object>();
            for(String field:fields){
                if(field.contains('.')){
                    String objectName = sObjectName;
                    String fieldName;
                    Schema.DescribeFieldResult fResult;
                    for(Integer i=0;i<field.split('\\.').size();i++){
                        if(i==field.split('\\.').size()-1){
                            mapFields.put(field,Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(field.split('\\.')[i]).getDescribe());
                        }else{
                            if(field.split('\\.')[i].contains('__r')){
                                fieldName = field.split('\\.')[i].split('__r')[0]+'__c';
                            }else{
                                fieldName = field.split('\\.')[i]+'Id';
                            }
                            fResult = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe();
                            objectName = fResult.getReferenceTo()[0]+'';
                        }
                    }
                }
                else
                    mapFields.put(field,Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap().get(field).getDescribe());
            }
            DatabaseResult result = new DatabaseResult( JSON.serialize(mapFields) );
            return result;
        } catch(Exception pEx){
            ApexDebugLog.logException(pEx,'sObjectName==>'+sObjectName+'fields==>'+string.join(fields, ','), 'LightningComponentController', 'describeTable');
            return (new DatabaseResult(pEx));
        }
    }

   /****************************************************************************************************************************
        Author              : Ajaysinh Chauhan
        Description         : This method is used to get today Date.
        Created Date        : -
        Last Modified By    : Ashish Mishra
        Last Modified Date  : 31,May 2018
   *****************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult getTodaysDate(){
        Debug.log('System.today() ==>>'+System.today());
        return new DatabaseResult(System.today());
    }

   /****************************************************************************************************************************
        Author              : Ajaysinh Chauhan
        Description         :
        Created Date        : -
        Last Modified By    : Ashish Mishra
        Last Modified Date  : 31,May 2018
   *****************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult executeRest(String method,String endPointUrl,Map<String,String> headers,String body){
            Debug.log('method :: '+method);
            Debug.log('endPointUrl :: '+endPointUrl);
            Debug.log('headers :: '+headers);
            Debug.log('body :: '+body);
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endPointUrl);
            req.setMethod(method);
            for(String header:headers.keyset()){
                req.setHeader(header, headers.get(header));
            }

            if(method.toLowerCase()!='get'){
                req.setbody(body);
                debug.Log('Inside body:::'+body);
            }

            Debug.log('req :: '+req);
            Http http = new Http();
            HTTPResponse response = http.send(req);
            Debug.log('response :: '+response);
            return new DatabaseResult(response.getBody());

    }

    /****************************************************************************************************************************
        Author              : Milanjeet
        Description         : Overload executeRest for GET Method to set correct EndpointURL and Session Id
        Created Date        : 2:50 AM 7/6/2017
        Last Modified By    : Ashish Mishra
        Last Modified Date  : 31,May 2018
   *****************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult executeRestQuery(Boolean setUrl,String method,String endPointUrl,Map<String,String> headers,String body){
        String endPoint_Url;
            debug.Log('SetUrl ::' + setUrl);
            debug.Log('method ::' + method);
            debug.Log('endPointUrl ::' + endPointUrl);
            debug.Log('headers ::' + headers);
            debug.Log('body ::' + body);
            Object response;
            if(setUrl){
                String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
                baseUrl = baseUrl.replace('--c.', '.');
                baseUrl = baseUrl.replace('visual.force', 'my.salesforce');
                endPoint_Url = baseUrl+endPointUrl;
            }else{
                endPoint_Url = endPointUrl;
            }
            if(headers.containsKey('Authorization') && headers.get('Authorization')=='Standard'){
                headers.put('Authorization','Bearer '+userInfo.getSessionId());
            }
            if(!headers.containsKey('Content-type') && method.equalsIgnoreCase('post')){
                headers.put('Content-type','application/json');
            }
            debug.Log('End Point Url :: '+endPoint_Url);
            if(method.equalsIgnoreCase('post')){
                response = executeRest(method, endPoint_Url, headers, body).data;
            }else{
               response = executeRest(method, endPoint_Url, headers, '').data;
            }
            Debug.log('response------'+response);
            return new DatabaseResult(response);

    }

   /****************************************************************************************************************************
        Author              : Ajaysinh Chauhan
        Description         : This method is used to get Session Id.
        Created Date        : -
        Last Modified By    : Ashish Mishra
        Last Modified Date  : 31,May 2018
   *****************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult getSessionId(){
        try{
            return new DatabaseResult(UserInfo.getSessionId());
        }catch(Exception pEx){
            ApexDebugLog.logException(pEx,'', 'LightningComponentController', 'getSessionId');
            return (new DatabaseResult(pEx));
        }
    }

   /****************************************************************************************************************************
        Author              : Ajaysinh Chauhan
        Description         : This method is used to check tour is valid for TourOutcome.
        Created Date        : -
        Last Modified By    : Ashish Mishra
        Last Modified Date  : 31,May 2018
   *****************************************************************************************************************************/
    @AuraEnabled
   public static DatabaseResult isValidForTourOutcome(Id tourId){
        try{
            TourOutcomeResult result = new TourOutcomeResult();
            Tour_Outcome__c tour =[SELECT Id,Name,Tour_Date__c,uuid__c From Tour_Outcome__c WHERE Id =: tourId LIMIT 1];
            String strobjTour = JSON.serialize(tour);
            Map<String,Object> objTour = (Map<String,Object>) JSON.deserializeUntyped(strobjTour);
            Id profileId = USERInfo.getProfileId();
            String profileName = [Select Id,Name FROM Profile WHERE Id=:profileId][0].Name;
            Setting__c settingRecord = Settings.get('TourOutcomeForm');
            Debug.log('settingRecord :: '+settingRecord);
            TourOutcomeFormController.TourOutcomeFormSettings setting = new TourOutcomeFormController.TourOutcomeFormSettings();
            setting = (TourOutcomeFormController.TourOutcomeFormSettings)JSON.deserialize(settingRecord.Data__c ,TourOutcomeFormController.TourOutcomeFormSettings.class);
            Debug.log('setting :: '+setting);
            if(objTour != null ){
                if(tour.uuid__c ==null || setting.RestrictedProfiles.contains(profileName)){
                    result.isValid = false;
                    if( setting.RestrictedProfiles.contains(profileName))
                        result.errorMsg = 'You cannot complete a tour';
                    else
                        result.errorMsg ='You cannot complete a tour outcome form for a tour because UUID is NULL.  If the tour already occurred or was cancelled, please update by clicking Manage/Book a Tour button on the opportunity prior to proceeding.';
                    return new DatabaseResult( result );
                }else{
                    result.isValid = true;
                    result.errorMsg ='';
                    return new DatabaseResult( result );
                }
            }else {
                result.isValid = false;
                result.errorMsg ='You cannot fill a new outcome for the tour. Please contact your system administrator.';

                return new DatabaseResult( result );
            }
        }catch(Exception pEx){
            ApexDebugLog.logException(pEx,'tourId==>'+tourId, 'LightningComponentController', 'isValidForTourOutcome');
            return (new DatabaseResult(pEx));
        }
    }

    global class TourOutcomeResult{
        @AuraEnabled
        Public Boolean isValid {get;set;}
        @AuraEnabled
        Public String errorMsg {get;set;}
    }

   /****************************************************************************************************************************
        Author              : Sunil Bhosale
        Description         : this method is used to add BusinessDays.
        Created Date        : 02/07/2017
        Last Modified By    : Ashish Mishra
        Last Modified Date  : 31,May 2018
   *****************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult addBusinessDays(Integer utcYear, Integer utcMonth, Integer utcDate, Integer daysToAdd){
        try{
            Date date1 =  Date.newinstance(Integer.valueOf(utcYear+''),Integer.valueOf(utcMonth+'') ,Integer.valueOf(utcDate+'') );
            String dt = date1.format();
            Date givenDate = date.parse(dt);
            return new DatabaseResult(DateUtilities.addBusinessDays(givenDate,Integer.valueOf(daysToAdd+'') ));
        }catch(Exception pEx){
            ApexDebugLog.logException(pEx,'utcYear==>'+utcYear+'utcMonth==>'+utcMonth+'utcDate==>'+utcDate+'daysToAdd==>'+daysToAdd, 'LightningComponentController', 'getUserProfileInfo');
            return (new DatabaseResult(pEx));
        }
    }

    /****************************************************************************************************************************
        Author              : Ajaysinh Chauhan
        Description         : This method is used to save Records.
        Created Date        : -
        Last Modified By    : Ashish Mishra
        Last Modified Date  : 31,May 2018
   *****************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult callSaveRecords (List<sObject> lstObj){
        try{
            return new DatabaseResult(WeworkEngine.SaveRecords(lstObj));
        }catch(Exception pEx){
            ApexDebugLog.logException(pEx,lstObj != null ? JSON.serialize(lstObj) : '', 'LightningComponentController', 'callSaveRecords');
            return (new DatabaseResult(pEx));
        }
    }

   /****************************************************************************************************************************
        Author              : Ajaysinh Chauhan
        Description         : This method is used to check is valid for TourOutcome.
        Created Date        : -
        Last Modified By    : Ashish Mishra
        Last Modified Date  : 31,May 2018
   *****************************************************************************************************************************/
    public static DatabaseResult Contact2Opportunity() {
        try{
            Settings.FieldMappings contactToActivityMappings = new Settings.FieldMappings();
            contactToActivityMappings.version = 1;
            contactToActivityMappings.mappings = new Map<String, Settings.MappedField>();
            contactToActivityMappings.mappings.put('LeadSource', new Settings.MappedField('LeadSource'));
            contactToActivityMappings.mappings.put('Lead_Source_Detail__c', new Settings.MappedField('Lead_Source_Detail__c'));
            contactToActivityMappings.mappings.put('utm_campaign_id__c', new Settings.MappedField('utm_campaign_id__c'));
            contactToActivityMappings.mappings.put('utm_content__c', new Settings.MappedField('utm_content__c'));
            contactToActivityMappings.mappings.put('utm_medium__c', new Settings.MappedField('utm_medium__c'));
            contactToActivityMappings.mappings.put('utm_source__c', new Settings.MappedField('utm_source__c'));
            return new DatabaseResult(contactToActivityMappings);
        }catch(Exception pEx){
            ApexDebugLog.logException(pEx,'', 'LightningComponentController', 'getUserProfileInfo');
            return (new DatabaseResult(pEx));
        }
    }


    /*************************************************************************************************************************************************************
        Author              : Shobhit Galot
        Description         : This method is used for GenerateJourney Lightning Component it is used to return a wrapper of setting 'User/Queue Journey Creation'
        Created Date        : -
        Issue No            : ST-1316
        Last Modified By    : Ashish Mishra
        Last Modified Date  : 31,May 2018
   **************************************************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult getJourneyUserQueue(string settingId){
        try{
            debug.log('inside getJourneyUserQueue ::'+settingId);
            List<Setting__c> settings = new List<Setting__c>();
            set<Id> setUsersIds = new set<Id>();
            set<Id> setQueueIds = new set<Id>();
            UserQueueJourneyWrap objUserQueueJourneyWrap = new UserQueueJourneyWrap();
            if(string.isNotBlank(settingId)){
                settings = [SELECT Id, Name, Data__c FROM Setting__c WHERE Id =: settingId LIMIT 1];
                debug.log('settings UserQueueJourneySettings ::'+settings);
                UserQueueJourneySettings wrap = (UserQueueJourneySettings)JSON.deserialize(settings[0].Data__c, UserQueueJourneySettings.class);

                for(AllowedUsersSettings user : wrap.allowedUsers){
                    setUsersIds.add(user.Id);
                }
                for(AllowedQueueSettings queue : wrap.allowedQueues){
                    setQueueIds.add(queue.Id);
                }

                if(setUsersIds.size() > 0 && setUsersIds != null){
                    objUserQueueJourneyWrap.lstactiveUsers =  [SELECT Name, Username, Email FROM User WHERE IsActive = true AND Id IN : setUsersIds  ORDER BY Name Asc];
                }
                if(setQueueIds.size() > 0 && setQueueIds != null){
                    objUserQueueJourneyWrap.lstQueues =  [Select Id, Name from Group where Type = 'Queue' AND Id IN : setQueueIds ORDER BY Name Asc];
                }
                objUserQueueJourneyWrap.settings =  JSON.serialize(settings);
            }
            return new DatabaseResult(JSON.serialize(objUserQueueJourneyWrap));
        } catch(Exception pEx){
            ApexDebugLog.logException(pEx,'settingId==>'+settingId, 'LightningComponentController', 'getJourneyUserQueue');
            return (new DatabaseResult(pEx));
        }
    }
    /****************************************************************************************************************************
        Author              : Ajaysinh Chauhan
        Description         : This method is used to check, is get MyDomain.
        Created Date        : -
        Last Modified By    : Ashish Mishra
        Last Modified Date  : 31,May 2018
   *****************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult getMyDomain(){
        try{
            String urlToReturn = URL.getSalesforceBaseUrl().toExternalForm();
            urlToReturn = urlToReturn.replace('--c', '');
            urlToReturn = urlToReturn.replace('visual.force', 'my.salesforce');
            return new DatabaseResult(urlToReturn);
        }catch(Exception pEx){
            ApexDebugLog.logException(pEx,'', 'LightningComponentController', 'getMyDomain');
            return (new DatabaseResult(pEx));
        }
    }

   /****************************************************************************************************************************
        Author              : Ajaysinh Chauhan
        Description         : This method is used to convert leads to existing lead and create account,contact and opportunity.
        Created Date        : -
        Last Modified By    : Ashish Mishra
        Last Modified Date  : 31,May 2018
   *****************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult convertLeadsToExisting(Lead objLead){
        Debug.log('objLead----'+objLead);
        try{           
            update objLead;
            List<Lead> lstLeads = checkChangeInLeadForFTE(objLead);
            RESTAPITourModelsV2.Input objTourPayload = new RESTAPITourModelsV2.Input();
            objTourPayload.email = String.isNotBlank(objLead.Email) ? objLead.Email.toLowerCase() : NULL;
            LeadConverterHelper.setLeadGenerateJourney(objLead);
            Map<String,Map<String,Id>> mapConvertedLead = LeadConverterHelper.manageLead(new List<Lead>{objLead},objTourPayload);
            Debug.log('mapConvertedLead in LightningComponentController==>'+mapConvertedLead);
            LeadConverterHelper.markLeasTasksCompletedOnLeadConversion(lstLeads);
            return new DatabaseResult(JSON.serialize(mapConvertedLead.get(objLead.Email.toLowerCase())));
        } catch(Exception pEx){
            ApexDebugLog.logException(pEx,JSON.serializePretty(objLead), 'LightningComponentController', 'convertLeadsToExisting');
            return (new DatabaseResult(false,pEx,pEx.getMessage()));
        }
    }

    public Static List<Lead> checkChangeInLeadForFTE(Lead objlead){
        List<Lead> lstLeads = [SELECT Id, Email, Account__c, Account__r.Unomy_Company_Size__c, Account__r.RecordType.Name, Account__r.Number_of_Full_Time_Employees__c, Account__r.RecordType.Id, (SELECT Id, Status, WhoId, WhatId FROM Tasks WHERE Status <> 'Completed') From Lead WHERE Id =: objLead.Id];
        if(lstLeads.size() > 0 && String.isBlank(lstLeads[0].Account__r.Unomy_Company_Size__c) &&  lstLeads[0].Account__r.RecordType.Name != 'Referral' && lstLeads[0].Account__r.Number_of_Full_Time_Employees__c == null && objLead.Number_of_Full_Time_Employees__c != null){
            if(AccountAssignmentHelper.getRecordTypeIdFromCompanySize(new Account(Number_of_Full_Time_Employees__c = objLead.Number_of_Full_Time_Employees__c, Unomy_Company_Size__c = null)) != String.valueOf(lstLeads[0].Account__r.RecordType.Id)){
                Account objAccount = new Account(Id = lstLeads[0].Account__c, Number_of_Full_Time_Employees__c = objLead.Number_of_Full_Time_Employees__c);
                update objAccount;
            }
        }
        return lstLeads;
    }
    /****************************************************************************************************************************
        Author              : Ajaysinh Chauhan
        Description         : This class is for AllowedUsersSettings data.
        Created Date        : -
        Last Modified By    : Ashish Mishra
        Last Modified Date  : 31,May 2018
   *****************************************************************************************************************************/
    global class AllowedUsersSettings {
        @AuraEnabled
        public String userName;
        @AuraEnabled
        public String Id;
    }
    /****************************************************************************************************************************
        Author              : Ajaysinh Chauhan
        Description         : This class is for AllowedQueueSettings data.
        Created Date        : -
        Last Modified By    : Ashish Mishra
        Last Modified Date  : 31,May 2018
   *****************************************************************************************************************************/
    global class AllowedQueueSettings {
        @AuraEnabled
        public String queueName;
        @AuraEnabled
        public String Id;
    }

    /****************************************************************************************************************************
        Author              : Ajaysinh Chauhan
        Description         : This class is for UserQueueJourneySettings data.
        Created Date        : -
        Last Modified By    : Ashish Mishra
        Last Modified Date  : 31,May 2018
   *****************************************************************************************************************************/
    global class UserQueueJourneySettings{
        @AuraEnabled
        public AllowedUsersSettings[] allowedUsers;
        @AuraEnabled
        public AllowedQueueSettings[] allowedQueues;
    }

    /****************************************************************************************************************************
        Author              : Ajaysinh Chauhan
        Description         : This class is for UserQueueJourneyWrap data.
        Created Date        : -
        Last Modified By    : Ashish Mishra
        Last Modified Date  : 31,May 2018
   *****************************************************************************************************************************/
    global class UserQueueJourneyWrap{
        @AuraEnabled
        public List<Group> lstQueues;
        @AuraEnabled
        public List<User> lstactiveUsers;
        @AuraEnabled
        public string settings;
    }

  /****************************************************************************************************************************
        Author              : Ajaysinh Chauhan
        Description         : This method is used for getUserProfileInfo.
        Created Date        : -
        Last Modified By    : Ashish Mishra
        Last Modified Date  : 31,May 2018
   *****************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult getUserProfileInfo(){
        try{
            return new DatabaseResult(JSON.serialize([Select Id, Name from profile where Id=:UserInfo.getProfileId()]));
        }catch(Exception pEx){
            ApexDebugLog.logException(pEx,'', 'LightningComponentController', 'getUserProfileInfo');
            return (new DatabaseResult(pEx));
        }
    }


   /****************************************************************************************************************************
        Author              : Milanjeet
        Description         : This function is used to send csv file to current user.
        Created Date        : 27-sept-2017
        Last Modified By    : Ashish Mishra
        Last Modified Date  : 31,May 2018
   *****************************************************************************************************************************/
    @AuraEnabled
    global static DatabaseResult SendMail(string csvSettingBackUp){
        try{
            debug.log('in objUser ::'+csvSettingBackUp);

            Id userId = UserInfo.getUserId();
            User objUser = [Select Id,Email,Name From user Where id =: userId];

            Messaging.SingleEmailMessage emailsuccess =new Messaging.SingleEmailMessage();
            emailsuccess.setHtmlBody('Hello '+objUser.Name+', <br/>Setting has been successfuly updated on your instance from preprod.<br/> Backup for old setting has been attached to this mail for backup purpose.<br/>  Thank you.');

            String[] toAllAddresses = new list<string>();
            toAllAddresses.add(objUser.Email);
            String subject ='Setting Backup Data Before Updation from Pre-Prod';
            emailsuccess.setSubject(subject);
            emailsuccess.setToAddresses(toAllAddresses);
            emailsuccess.setTargetObjectId(objUser.Id);
            emailsuccess.setSaveAsActivity(false);

            Messaging.EmailFileAttachment csvAttcSettingBackUp = new Messaging.EmailFileAttachment();

            List<Messaging.Emailfileattachment> lstAttachments = new List<Messaging.Emailfileattachment>();
            if(String.isNotBlank(csvSettingBackUp)){
                blob csvBlob = Blob.valueOf(csvSettingBackUp);
                string csvname= 'Settings Backup.csv';
                csvAttcSettingBackUp.setFileName(csvname);
                csvAttcSettingBackUp.setBody(csvBlob);
                Debug.Log('csvAttcSettingBackUp :: '+csvAttcSettingBackUp);
                lstAttachments.add(csvAttcSettingBackUp);
            }
            Debug.Log('lstAttachments :: '+lstAttachments);

            if(lstAttachments.size()>0 && lstAttachments != null)
                emailsuccess.setFileAttachments(lstAttachments );
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {emailsuccess});
            return new DatabaseResult('done');
     } catch(Exception pEx){
            ApexDebugLog.logException(pEx,'csvSettingBackUp==>'+csvSettingBackUp, 'LightningComponentController', 'SendMail');
            return (new DatabaseResult(pEx));
        }
    }


   /**************************************************************************************************************************************************
        Author              : Ajaysinh Chauhan
        Description         : This is a Class to Wrappe Account and Contact Details.
        Created Date        : -
        Last Modified By    : Ashish Mishra
        Last Modified Date  : 31,May 2018
   ***************************************************************************************************************************************************/
    public class WrapperAccountContact{
        @AuraEnabled
        public String Name;
        @AuraEnabled
        public String UUID;
        @AuraEnabled
        public String PrimaryMemberName;
        @AuraEnabled
        public String PrimaryMemberEmail;
        @AuraEnabled
        public String PrimaryMemberPhone;
        @AuraEnabled
        public String PrimaryMemberUUID;

    }

	@AuraEnabled
    public static DatabaseResult getOrg(String accountId){
        Set<Id> acctoproceed = new set<Id>{accountId};
            Map<Id,Id> ultimateOrgForContact = OrganizationHelper.getUltimateParents(acctoproceed);
        Debug.log('ultimateOrgForContact---'+ultimateOrgForContact);
        if(String.isNotBlank(ultimateOrgForContact.get(accountId))){
            return (new DatabaseResult(Id.valueOf(ultimateOrgForContact.get(accountId))));
        }
        return null;

    }

   /****************************************************************************************************************************
        Author              : Ajaysinh Chauhan
        Description         : This method is used to escape Special Character.
        Created Date        : -
        Last Modified By    : Ashish Mishra
        Last Modified Date  : 31,May 2018
   *****************************************************************************************************************************/
    public static String escapeSpecialChars(String target){
        Map<String,String> mapRegExp = new Map<String,String>{'\''=>'\\\\\'','\\\\'=>'\\\\\\\\'};
        String regExp;
        List<String> lstStr = new List<String>(mapRegExp.keySet());
        String res = String.join(lstStr,'');
        if(target.containsAny(res))
        {
            if( target.indexOf('\\') !=-1 && mapRegExp.containsKey('\\\\') )
            {
                regExp =  '[\\\\]';
                target = target.replaceAll(regExp,mapRegExp.get('\\\\'));
                mapRegExp.remove('\\\\');
            }

            for(String strKey : mapRegExp.keySet())
            {
                if(target.indexOf(strKey) !=-1)
                {
                    regExp =  '['+strKey+']';
                    target = target.replaceAll(regExp,mapRegExp.get(strKey));
                }
            }
        }
        Debug.log('target ::== '+target);
        return target;
    }

   /****************************************************************************************************************************
        Author              : Ajaysinh Chauhan
        Description         : This method is used to get Object Fields.we should just pass a object name in string format.
        Created Date        : -
        Last Modified By    : Ashish Mishra
        Last Modified Date  : 31,May 2018
   *****************************************************************************************************************************/
    public static DatabaseResult getObjectFields(String sObjectName){
        try{
            List<String> listSObjectFields = new List<String>();
            Map<String, Schema.SObjectField> mapSObjectDesc = Schema.getGlobalDescribe().get(sObjectName.toLowerCase()).getDescribe().Fields.getMap();
            for(Schema.SObjectField field : mapSObjectDesc.values()){
                if (field.getDescribe().isCreateable()){
                    listSObjectFields.add(field.getDescribe().getName());
                }
            }
            return new DatabaseResult(listSObjectFields);
        } catch(Exception pEx) {
            ApexDebugLog.logException(pEx,sObjectName, 'LightningComponentController', 'getObjectFields');
            return (new DatabaseResult(pEx));
        }
    }
    @AuraEnabled
    public static DatabaseResult getSalesConsoleSetting(String salesConsoleSettingName ){
        DatabaseResult result = new DatabaseResult(JSON.serialize([SELECT Id, Name, Data__c FROM Setting__c WHERE Name =: salesConsoleSettingName ]));
        return result;
    }

   /****************************************************************************************************************************
        Author              : Ajaysinh Chauhan
        Description         : This method is used to search Query Data.
        Created Date        : -
        Last Modified By    : Ashish Mishra
        Last Modified Date  : 31,May 2018
   *****************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult searchQueryData(String strQuery){debug.log('strQuery =>>'+strQuery);
                                                                  List<List<sObject>> searchResult = WeworkEngine.searchQuery(strQuery);
                                                                  DatabaseResult result = new DatabaseResult(JSON.serialize(searchResult));
                                                                  debug.log('result =>>'+result);
                                                                  return result;
                                                                 }

   /****************************************************************************************************************************
        Author              : Ajaysinh Chauhan
        Description         : This method is used to get Parent Account.
        Created Date        : -
        Last Modified By    : Ashish Mishra
        Last Modified Date  : 31,May 2018
   *****************************************************************************************************************************/
    public static string getParentAccount(String objId){
        Debug.log('objId ==>'+objId);
        String UltimateParentId;
        Boolean topLevelParent = false;
        if(!String.isBlank(objId)){
            while ( !topLevelParent ) {
                List<Account> lstAcc = [ Select Id, ParentId,Account_Type__c,Parent_Org_Id__c From Account WHERE Id =: objId limit 1 ];
                if( lstAcc.size() > 0 && lstAcc.get(0).Parent_Org_Id__c != null && (lstAcc.get(0).Id != lstAcc.get(0).Parent_Org_Id__c) ){
                    objId = lstAcc.get(0).Parent_Org_Id__c;
                    Debug.log('Parent Org If ==>'+objId);
                }else if ( lstAcc.size() > 0 && lstAcc.get(0).ParentId != null ) {
                    if(lstAcc.get(0).Account_Type__c == 'Org'){
                        UltimateParentId = lstAcc.get(0).ParentId;
                        Debug.log('If ==>'+objId);
                    }
                    objId = lstAcc.get(0).ParentId;
                    Debug.log('If ==>'+objId);
                } else if(lstAcc.size() > 0 && lstAcc.get(0).ParentId == null ) {
                    if(lstAcc.get(0).Account_Type__c == 'Org'){
                        UltimateParentId = lstAcc.get(0).Id;
                    }
                    objId = lstAcc.get(0).Id;
                    Debug.log('Else if==>'+objId);
                    topLevelParent = true;
                } else {
                    Debug.log('Else ==>');
                    return null;
                    topLevelParent = true;
                }
            }
            return UltimateParentId;
        } else {
            return null;
        }
    }

   /****************************************************************************************************************************
        Author              : Ajaysinh Chauhan
        Description         : This method is used to get Ultimate Parent Account.
        Created Date        : -
        Last Modified By    : Ashish Mishra
        Last Modified Date  : 31,May 2018
   *****************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult getUltimateParentAccount(String objId){
        Debug.log('Ret Data '+getParentAccount(objId));
        DatabaseResult result = new DatabaseResult(getParentAccount(objId));
        return result;
    }

    /****************************************************************************************************************************
        Author              : Ajaysinh Chauhan
        Description         : This method is used to get API SessionId.
        Created Date        : -
        Last Modified By    : Ashish Mishra
        Last Modified Date  : 31,May 2018
   *****************************************************************************************************************************/
    @AuraEnabled
    global static  DatabaseResult getAPISessionId(){
        try{
            PageReference pr = new PageReference('/apex/LightningEval');
            String body = pr.getContent().toString();
            Debug.log('body:'+body);
            Integer startIndex = body.indexOf('START_OF_SESSION_ID_FOR_LIGHTNING')+33;
            Integer endIndex = body.indexOf('END_OF_SESSION_ID_FOR_LIGHTNING');
            String sessionId = body.substring(startIndex, endIndex);
            Debug.log('sessionId:'+sessionId);
            DatabaseResult result = new DatabaseResult(sessionId);
            return result;
        } catch(Exception pEx){
            ApexDebugLog.logException(pEx,'', 'LightningComponentController', 'getAPISessionId');
            return (new DatabaseResult(pEx));
        }
    }

   /****************************************************************************************************************************
        Author              : Ajaysinh Chauhan
        Description         : This method is used to get REST CalloutData.
        Created Date        : -
        Last Modified By    : Ashish Mishra
        Last Modified Date  : 31,May 2018
   *****************************************************************************************************************************/
    @AuraEnabled
    global static DatabaseResult getRESTCalloutData(){
        try{
            RESTCalloutData objRESTCalloutData = new RESTCalloutData();
            objRESTCalloutData.apiSessionId = String.valueOf(LightningComponentController.getAPISessionId().data);
            objRESTCalloutData.endPointUrl = URL.getSalesforceBaseUrl().toExternalForm();
            objRESTCalloutData.userId = UserInfo.getUserId();
            Debug.log('objRESTCalloutData :: '+objRESTCalloutData);
            DatabaseResult result = new DatabaseResult(JSON.serialize(objRESTCalloutData));
            return result;
        } catch(Exception pEx){
            ApexDebugLog.logException(pEx,'', 'LightningComponentController', 'getRESTCalloutData');
            return (new DatabaseResult(pEx));
        }
    }
   /****************************************************************************************************************************
        Author              : Ajaysinh Chauhan
        Description         : This Class is created to hold REST CalloutData data.
        Created Date        : -
        Last Modified By    : Ashish Mishra
        Last Modified Date  : 31,May 2018
   *****************************************************************************************************************************/
    global Class RESTCalloutData {
        @AuraEnabled
        public String apiSessionId {get;set;}
        @AuraEnabled
        public String endPointUrl {get;set;}
        @AuraEnabled
        public Id userId {get;set;}
    }

    /************************************************************************************************************************************
        Author         : Ajaysinh Chauhan
        Description     : This method upserts geolocation records with place id.
        Created Date    : 19 March 2018
  **************************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult upsertGeolocation(Geography__c objGeography){
        try{
            upsert objGeography Place_ID__c;
            Debug.log('In upsertGeolocation SOQL LIMITS :: '+Limits.getQueries());
            return new DatabaseResult([Select Id From Geography__c Where Place_ID__c=:objGeography.Place_ID__c][0].Id);
        } catch(Exception pEx) {
            ApexDebugLog.logException(pEx,'objGeography==>'+objGeography, 'LightningComponentController', 'upsertGeolocation');
            return (new DatabaseResult(pEx));
        }
    }


     /************************************************************************************************************************************
        Author              : Priyanka Ambre
        Description         : This method returns the Record Type Id's of Opportunity, Account, Contact from RecordType Name.
    **************************************************************************************************************************************/

    @AuraEnabled
    public static DatabaseResult getRecordTypeIds(String recordType){
        Map<String,Id> mapRecordTypes = new Map<String,Id>();
        mapRecordTypes.put('Opportunity',Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(recordType).getRecordTypeId());
        mapRecordTypes.put('Account',Schema.SObjectType.Account.getRecordTypeInfosByName().get(recordType).getRecordTypeId());
        mapRecordTypes.put('Contact',Schema.SObjectType.Contact.getRecordTypeInfosByName().get(recordType).getRecordTypeId());
        return new DatabaseResult(mapRecordTypes);
    }
/****************************************************************************************************************************
        Author              : Ajaysinh Chauhan
        Description         : This method is used to get Record Type Information.
        Created Date        : -
        Last Modified By    : Ashish Mishra
        Last Modified Date  : 31,May 2018
   *****************************************************************************************************************************/

      @AuraEnabled
    public static DatabaseResult getRecordTypeInfos(List<String> objectNames){
        Map<String, Map<String, Id>> mapRecordTypes = new Map<String, Map<String, Id>>();
        if(objectNames != null && objectNames.size() > 0) {
            for(String objName : objectNames) {
                Map<String, Id> recTypeNameWithIdMap = new Map<String, Id>();
                for(Schema.RecordTypeInfo recInfo : Schema.getGlobalDescribe().get(objName).getDescribe().getRecordTypeInfosByName().values()){
                    recTypeNameWithIdMap.put(recInfo.getName(), recInfo.getRecordTypeId());
                }
                mapRecordTypes.put(objName, recTypeNameWithIdMap);
            }
        }
        return new DatabaseResult(mapRecordTypes);
    }

     /****************************************************************************************************************************
        Author              : Shivprasad Patil
        Description         : This method used to retrive users Logs.Used in apex Log Lightning component
        Created Date        : 27,April 2018
        Last Modified By    : Shivprasad Patil
        Last Modified Date  : 27,April 2018
    *****************************************************************************************************************************/
   @AuraEnabled
    public static DatabaseResult getUserLogs(List<String> users,String startDate,String endDate,String size,String searchTerm,List<String> operations,String startTime,String endTime){
        System.debug('In getUserLogs==='+operations);
        try{
            String query;
            Set<String> setOfOperations = new set<String>(operations);
            System.debug('strConditions==='+setOfOperations);
            Set<String> setOfUsers = new Set<String>(users);
            String[] arrOfStartDate = startDate.split('-');
            String[] arrOfStartTime = startTime.split(':');
            String[] arrOfendDate = endDate.split('-');
            String[] arrOfEndTime = endTime.split(':');
            DateTime startDateTime = DateTime.newInstance(Integer.valueOf(arrOfStartDate[0]), Integer.valueOf(arrOfStartDate[1]), Integer.valueOf(arrOfStartDate[2]), Integer.valueOf(arrOfStartTime[0]), Integer.valueOf(arrOfStartTime[1]), 0);
            DateTime endDateTime = DateTime.newInstance(Integer.valueOf(arrOfendDate[0]), Integer.valueOf(arrOfendDate[1]), Integer.valueOf(arrOfendDate[2]),Integer.valueOf(arrOfEndTime[0]), Integer.valueOf(arrOfEndTime[1]), 0);
            System.debug('startDateTime=='+startDateTime);
            System.debug('endDateTime=='+endDateTime);
            query = 'SELECT Id,LogUser.name,operation,startTime,status FROM ApexLog WHERE LogUserId IN :setOfUsers AND startTime >= :startDateTime AND startTime <= :endDateTime '+ (setOfOperations.size() > 0 ? 'AND operation IN :setOfOperations ' : '') +'  LIMIT '+size;//
            System.debug('query::'+query);
            List<apexLog> lstApexLog = (List<apexLog>)Database.query(query);
            System.debug('lstApexLog::'+lstApexLog);
            if(searchTerm!=null && searchTerm!='' && lstApexLog.size() > 0){
                List<apexLog> lstApexLogToReturn = new List<apexLog>();
                HttpRequest req;
                DatabaseResult result;
                String baseURL = URL.getSalesforceBaseUrl().toExternalForm();
                for(ApexLog itrApexLog : lstApexLog){
                    //result = LightningComponentController.executeRestQuery(true,'GET',('/services/data/v40.0/sobjects/ApexLog/'+itrApexLog.Id+'/Body/'),new Map<String,String>{'Authorization'=>'Standard'},'');
                    System.debug('baseURL=='+(baseURL +'/services/data/v40.0/sobjects/ApexLog/'+itrApexLog.Id+'/Body/'));
                    result = LightningComponentController.executeRestQuery(false,'GET',( baseURL+'/services/data/v40.0/sobjects/ApexLog/'+itrApexLog.Id+'/Body/'),new Map<String,String>{'Authorization'=>'Standard'},'');
                    Debug.log('result=='+(result));
                    if( (String.valueOf(result.data)).toLowerCase().contains(searchTerm.toLowerCase()) )
                        lstApexLogToReturn.add(itrApexLog);
                }
                System.debug('lstApexLogToReturn=='+lstApexLogToReturn);
                return new DatabaseResult(lstApexLogToReturn);
            }
            return new DatabaseResult(lstApexLog);
        }catch(Exception pEx){
            ApexDebugLog.logException(pEx,'startDate==>'+startDate, 'LightningComponentController', 'getListQueryDataBySOSL');
            return (new DatabaseResult(pEx));
        }
    }
    /****************************************************************************************************************************
        Author              : Shivprasad Patil
        Description         : This method used to delete users Logs.Used in apex Log Lightning component
        Created Date        : 27,April 2018
        Last Modified By    : Shivprasad Patil
        Last Modified Date  : 27,April 2018
    *****************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult deleteLogs(List<Id> lstLogIds){
        List<String> lstResponse = new List<String>();
        DatabaseResult result;
        for(Id logId:lstLogIds){
            result = LightningComponentController.executeRestQuery(true,'DELETE',('/services/data/v40.0/sobjects/ApexLog/'+logId+'?HttpMethod=DELETE'),new Map<String,String>{'Authorization'=>'Standard'},'');
            lstResponse.add(String.valueOf(result.data));
        }
        return new DatabaseResult(lstResponse);
    }

 /****************************************************************************************************************************
	Author              :   Samadhan kadam
	Description         :   This method is used to create table of object which is inserted by Lead/Journey importer and send to
                        user by email template.
	Created Date        :   12 June 2018
 *********************************************************************************************************************************/
    public static string getTableBody(set<string> setTblFields,map<string,list<sObject>> mapSobjectRecords){
        String htmlBody = '';
        List<sObject> myList = new List<sObject>();
        //open table..
        map<string,map<string,string>> mapObjectAndFields = new map<string,map<string,string>>();
        mapObjectAndFields.put('New Journeys',new map<string,string>{'Primary_Email__c' =>'Email','Id'=>'Id'});
        mapObjectAndFields.put('Existing Journeys',new map<string,string>{'Primary_Email__c' =>'Email','Id'=>'Id'});
        mapObjectAndFields.put('Existing Leads',new map<string,string>{'Email' =>'Email of Lead','Id'=>'Id'});
        mapObjectAndFields.put('New Leads',new map<string,string>{'Email' =>'Email of Lead','Id'=>'Id'});
        mapObjectAndFields.put('Existing Contacts',new map<string,string>{'Email' =>'Email of Contact','Id'=>'Id'});

        Debug.log('mapSobjectRecords getTableBody==>'+mapSobjectRecords);
        for(string currentObject : mapSobjectRecords.keySet()){
            myList = mapSobjectRecords.get(currentObject);
            if(myList != null && myList.size()>0){
                htmlBody += '<table border="1" style="border-collapse: collapse;width:60%;text-align: center;"><caption style="text-align: left;margin: 4px 0px 2px 0px;"><b>'+currentObject+'</b></caption>';
                htmlBody+= '<tr style="height: 25px;background:#563d7c;color:white;"><th>Sr.no</th>';

                map<string,string> mapFieldsWithLabel =  mapObjectAndFields.get(currentObject);
                for(string currentField : mapFieldsWithLabel.keySet())
                {
                    htmlBody+= '<th>' + mapFieldsWithLabel.get(currentField) + '</th>';
                }
                htmlBody+= '</tr>';
                Integer Index = 0;
                string background = '';
                for(sObject l : myList){
                    if(math.mod(Index, 2) == 0){
                        background = '#d5e9e5';
                    }
                    else{
                        background = '#ffffff';
                    }
                    htmlBody+= '<tr style="height:25px;background-color:'+background+'"><td>'+ ++Index +'</td>';
                    for(string currentField :  mapFieldsWithLabel.keySet())
                    {
                        htmlBody+= '<td>' + l.get(currentField) + '</td>';
                    }
                    htmlBody+= '</tr>';
                }
                //close table...
                htmlBody += '</table><br></br><br></br>';
            }
        }
        return htmlBody;
    }

    public class MetaFields {
        public String name;
        public String label;
    }

    public class ReturnValidResults{
        public boolean isSuccess;
        public String message;
    }

  /****************************************************************************************************************************
        Author              : Rohit Nimase
        Description         : This method will rollback the transaction if exception is occured in AURA
        Created Date        : 16/01/2019
  *****************************************************************************************************************************/
    public static void rollbackTransaction(Savepoint savePoint){
        if(savePoint != null){
            Database.rollback(savePoint);
        }
    }

    /************************************************************************************************************************************
        Author              : Jitesh Adwani
        Description         : This method validate the Referrer field validation.
        Created Date        : 22/08/2018
        Issue No            : ST-2702
        Last Modified By    : Shivprasad Patil
        Last Modified Date  : 11,Sept 2018
    **************************************************************************************************************************************/
    webservice static WebServiceWrapper validateLeadforWebService(Id recordId){
        try{
            debug.log('IN validateLeadforWebService');
            DatabaseResult result = validateLead(recordId);
            return new WebServiceWrapper(result.success,JSON.serialize(result.data),result.message);
        }catch(Exception pEx){
            ApexDebugLog.logException(pEx,'', 'LightningComponentController', 'validateLeadforWebService');
            return new WebServiceWrapper(false, null, pEx.getMessage());
        }
    }

    @AuraEnabled
    public static DatabaseResult validateLead(Id recordId){
        try{
            if(String.isNotBlank(recordId)){
            Set<String> setOfLeadSource = new Set<String>{'Broker Referral','Member Referral','Employee Referral','Affiliate Referral','Partner Referral'};
            List<sObject> lstRecords = new List<sObject>();
            String query;
            String objName = recordId.getSObjectType().getDescribe().getName();
            Debug.log('objName=='+objName);

            if(objName=='Lead'){
                query = 'SELECT id,LeadSource,Referrer__c FROM Lead WHERE id = :recordId AND LeadSource IN :setOfLeadSource AND Referrer__c = null';
            }else if(objName=='Journey__c'){
                query = 'SELECT id, Primary_Lead__c, Primary_Contact__c, Primary_Lead__r.LeadSource, Primary_Lead__r.Referrer__c, Primary_Contact__r.LeadSource, Primary_Contact__r.Referrer__c FROM Journey__c WHERE id = :recordId AND ( (Primary_Lead__c!=null AND Primary_Lead__r.LeadSource IN :setOfLeadSource  AND  Primary_Lead__r.Referrer__c = null) OR (Primary_Contact__c!=null AND Primary_Contact__r.LeadSource IN :setOfLeadSource  AND  Primary_Contact__r.Referrer__c = null) )';
            }

            lstRecords = Database.query(query);
            if(!lstRecords.isEmpty()){
                return new DatabaseResult(false,null,'Referrer is blank. Add a referrer in the referrer lookup field.');
            }
            return new DatabaseResult(true,null,null);
        }else{
              return new DatabaseResult(false,null,'record id is blank.');
        }
        }catch(Exception pEx){
            ApexDebugLog.logException(pEx,'', 'LightningComponentController', 'validateLead');
            return (new DatabaseResult(pEx));
        }
    }

    /************************************************************************************************************************************
        Author              : Shivprasad Patil
        Description         : This method returns default picklist value for given field according to record type.
        Created Date        : 1 Jan 2019
    **************************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult getDefaultPickListValue(String objectApiName, String fieldApiName){
        try{
            sObject newObj = (sObject)Type.forName(objectApiName).newInstance();
            List<Schema.RecordTypeInfo> lstInfos = newObj.getSObjectType().getDescribe().getRecordTypeInfos();
            String strDefaultRecordTypeId;
            for (Schema.RecordTypeInfo objInfo : lstInfos) {
                if (objInfo.DefaultRecordTypeMapping) {
                    strDefaultRecordTypeId = objInfo.RecordTypeId;
                    break;
                }
            }

            DatabaseResult result = LightningComponentController.executeRestQuery(true,'GET',('/services/data/v43.0/ui-api/object-info/'+objectApiName+'/picklist-values/'+strDefaultRecordTypeId+'/'+fieldApiName),new Map<String,String>{'Authorization'=>'Standard'},'');
            if(result.success){
                Map<String, Object> mapOfData = (Map<String, Object>)JSON.deserializeUntyped(String.valueOf(result.data));
                return new DatabaseResult(mapOfData.get('defaultValue'));
            }
            return result;
        }catch(Exception pEx){
            ApexDebugLog.logException(pEx,'', 'LightningComponentController', 'getDefaultPickListValue');
            return (new DatabaseResult(pEx));
        }
    }

    /****************************************************************************************************************************
        Author              : Sunil Bhosale
        Description         : This Method is used to update bulk of journey.
        Created Date        : 03/07/2017
        Last Modified By    : Ashish Mishra
        Last Modified Date  : 31,May 2018
   *****************************************************************************************************************************/
    @AuraEnabled
    global static DatabaseResult bulkJourneyUpdates(List<String> journeyIds,String nmdNextContactDate1,String description) {
        Debug.log('journeyIds::'+journeyIds);
        set<String> setIds = new set<String>();
        setIds.addAll(journeyIds);
        Setting__c objSetting = Settings.get('JourneyCloseStages');
           Set<String> setJourneyCloseStages = new Set<String>();
           if(objSetting != null){
               setJourneyCloseStages = (Set<String>)JSON.deserialize(objSetting.Data__c, Set<String>.class);
           }
        try
        {
            sp = Database.setSavepoint();
            Settings.FieldMappings mapLeadToActivity;
            debug.log('nmdNextContactDate1 before change==>'+nmdNextContactDate1);
            Date dToday = Date.valueOf(nmdNextContactDate1);
            DateTime nmdNextContactDate = datetime.newInstance(dToday.year(), dToday.month(),dToday.day());

            set <String> setJourneyIds = new set<String>();
            set<String> setLeadIds = new set<String>();
            set<String> setContactIds = new set<String>();
            list<Task> lstTasks = new list<Task>();
            list<String> lstContactFields = new list<String>();
            set<String> setContactFields = new set<String>();
            Task objTask;

            //setJourneyIds.addAll(journeyIds.split(','));
            //Debug.log('setJourneyIds::'+setJourneyIds);



            //Get values for contact field mappings
            Settings.FieldMappings mapContactToActivity;
            mapContactToActivity = Settings.getFieldMappings('ContactToActivity');
            Debug.log('In WeWorkengine mapContactToActivity :: '+mapContactToActivity);

            if(mapContactToActivity == null)
                mapContactToActivity = WeworkEngine.Contact2Activity();

            for(Settings.MappedField field : mapContactToActivity.mappings.values()){
                setContactFields.add(field.fieldname.toLowerCase());
            }
            lstContactFields.addAll(setContactFields);

            //Get Values for lead field mappings
            set<String> setLeadFields = new set<String>();

            list<String> lstLeadFields = new list<String>();

            mapLeadToActivity = Settings.getFieldMappings('LeadToActivity');

            if(mapLeadToActivity == null)
                mapLeadToActivity = WeworkEngine.Contact2Activity();

            for(Settings.MappedField field : mapLeadToActivity.mappings.values()){
                setLeadFields.add(field.fieldname.toLowerCase());
            }

            lstLeadFields.addAll(setLeadFields);

            List<Journey__c> lstJourneys = new List<Journey__c>();

            lstJourneys = [SELECT Id, Name, Primary_Lead__c, Primary_Contact__c, NMD_Next_Contact_Date__c,Status__c ,Outreach_Stage__c , CreatedDate FROM Journey__c WHERE Id IN : setIds AND (Primary_Lead__c != null OR Primary_Contact__c != null)];
            debug.log('lstJourneys :: '+lstJourneys);
            for(Journey__c currentJourney : lstJourneys)
            {
                if(currentJourney.Primary_Lead__c !=null)
                    setLeadIds.add(currentJourney.Primary_Lead__c);
                else if(currentJourney.Primary_Contact__c !=null)
                    setContactIds.add(currentJourney.Primary_Contact__c);
            }

            list<contact> lstContact = Database.Query('Select ' + String.join(lstContactFields, ',') + ' From Contact Where Id IN : setContactIds');

            list<lead> lstLead =   Database.Query('Select ' + String.join(lstLeadFields, ',') + ' From Lead Where Id IN : setLeadIds');

            map<Id,Contact> mapJourneyContacts = new map<Id,Contact>();

            for(Contact currentContact : lstContact)
            {
                mapJourneyContacts.put(currentContact.Id,currentContact);
            }

            map<Id,Lead> mapJourneyLeads = new map<Id,Lead>();

            for(Lead currentLead : lstLead)
            {
                mapJourneyLeads.put(currentLead.Id,currentLead);
            }

            for(Journey__c currentJourney : lstJourneys)
            {
                objTask = new Task();
                objTask.Type = 'Call';
                objTask.Subject = 'Follow-Up';
                objTask.Status = 'Not Started';
                objTask.WhoId = currentJourney.Primary_Contact__c;
                objTask.WhatId = currentJourney.Id;
                objTask.ActivityDate =nmdNextContactDate.Date();

                if(currentJourney.Primary_Contact__c != null)
                {
                    Contact objContact = mapJourneyContacts.get(currentJourney.Primary_Contact__c);
                    for(String field : mapContactToActivity.mappings.keySet()){
                        Settings.MappedField mappedField = mapContactToActivity.mappings.get(field);
                        if(mappedField.isvalue == true)
                            objTask.put(field, mappedField.value);
                        else
                            objTask.put(field, objContact.get(mappedField.fieldname));
                    }
                }
                else if(currentJourney.Primary_Lead__c != null)
                {
                    Lead objLead = mapJourneyLeads.get(currentJourney.Primary_Lead__c);
                    for(String field : mapLeadToActivity.mappings.keySet()){
                        Settings.MappedField mappedField = mapLeadToActivity.mappings.get(field);
                        if(mappedField.isvalue == true)
                            objTask.put(field, mappedField.value);
                        else
                            objTask.put(field, objLead.get(mappedField.fieldname));
                    }
                }
                if(objTask.OwnerId != null && (String.valueOf(objTask.OwnerId)).startsWith('00G')){
                    objTask.OwnerId = UserInfo.getUserId();
                }
                objTask.Description__c = description;
                lstTasks.add(objTask);

                if(Math.round(WeworkEngine.dateDiff(currentJourney.CreatedDate,nmdNextContactDate)) > 48)
                {
                    if(!setJourneyCloseStages.contains(currentJourney.Status__c)){// for ST-3084 Previously only for Started Journey we use to update and now for open stages of Journey.
                        currentJourney.Outreach_Stage__c ='Manual Outreach';
                    }
                }
                currentJourney.NMD_Next_Contact_Date__c = nmdNextContactDate.Date();
            }

            update lstJourneys;
            insert lstTasks;
            Set<Id> setNewTasks = new Set<Id>();
            for(Task t : lstTasks) {
                setNewTasks.add(t.Id);
            }
            List<Task> taskToUpdate = new List<Task>();
            for(Task t : [SELECT Id, Status FROM Task WHERE Id NOT IN :setNewTasks AND WhatId IN :setIds AND Status != 'Completed']) {
                t.Status = 'Completed';
                taskToUpdate.add(t);
            }
            update taskToUpdate;
            Debug.log('updated task::'+taskToUpdate);
            return new DatabaseResult(true);
        }
        catch(Exception pEx){
            LightningComponentController.rollbackTransaction(sp);
            ApexDebugLog.logException(pEx,'description==>'+description, 'LightningComponentController', 'bulkJourneyUpdates');
            return (new DatabaseResult(pEx));
        }
    }

/************************************************************************************************************************************
    Author      :   Shobhit Gahlot
    Description :   This Method returns External Sytem Endpoint data.
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE         Issue No.    AUTHOR                DETAIL
    1           3 Feb 2019   STL-127      Shobhit Gahlot        Initial Developement
**************************************************************************************************************************************/
    public static Map<String, Integration_Data__mdt> getExternalSystemEndPoints(set<String> setEndPointNames){
        String environmentName = getEnvironmentName();
        Debug.log('getExternalSystemEndPoints environmentName==>'+environmentName);
        Debug.log('getExternalSystemEndPoints setEndPointNames==>'+setEndPointNames);
        Map<String, Integration_Data__mdt> mapEndpointData = new Map<String, Integration_Data__mdt>();
        for(Integration_Data__mdt endPoint : [SELECT Label, DeveloperName, ApiKey__c, EndPoint__c, Headers__c, Method__c FROM Integration_Data__mdt where Label In : setEndPointNames AND Evironment__c =: environmentName]){
            mapEndpointData.put(endPoint.Label.toLowerCase(), endPoint);
        }
        return mapEndpointData;
    }

/************************************************************************************************************************************
    Author      :   Shobhit Gahlot
    Description :   This Method returns Environment name.
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE         Issue No.     AUTHOR                DETAIL
    1           3 Feb 2019   STL-127      Shobhit Gahlot        Initial Developement
**************************************************************************************************************************************/
    private static string getEnvironmentName(){
        String environmentName = URL.getSalesforceBaseUrl().getHost().SubStringBefore('.').toLowerCase().substringAfter('--');
        debug.log('getEnvironmentName environmentName==>'+environmentName);
        Boolean isSandBox = runningInASandbox();
        if(!isSandBox){
            return 'wework';
        }else if(environmentName.containsIgnoreCase('staging') && isSandBox){
            return 'staging';
        }else if(environmentName.containsIgnoreCase('venus') && isSandBox){
            return 'venus';
        }else{
            return 'staging';
        }
    }

    public static Boolean runningInASandbox() {
            return [SELECT IsSandbox FROM Organization].IsSandbox;
    }

    global class WebServiceWrapper{
        webservice Boolean success;
        webservice String message;
        webservice String data;
        public WebServiceWrapper(Boolean success, String data, String message){
            this.success = success;
            this.data 	 = data;
            this.message = message;
        }
    }
}