/*********************************************************************************************
Name   : KickboxProcessLeadsBatch
Purpose: This class is written to Optimize the Kickbox email verification process. Here we have
Add priviously written code in Batch apex.
Add functionality to relate journey with campaign and add inserted leads and if contact
exist then contact as a campaign members.
Change email structure and add table in email for more specific details.
History:
VERSION      DATE      	AUTHOR                 DETAIL
1.0      21 Dec 2016   Mayuresh Ghodke	 Initial Developement.
2.0          _     	 Shobhit Ghalot	 	 Bug Fixses.
3.0	   11 Jan 2018	 Amol Darekar		 Add code in batch and optimization,Email and Campaign
related changes.

*********************************************************************************************/

global class KickboxProcessLeadsBatch implements Database.Batchable<sObject>,Database.stateful{
    /*String csvFile;
    string generateJourney;
    Id kickBoxVerificationRecordId;
    String filePart;
    Id campaignId;
    map<string,string> mapCSV = new map<string,string>();
    map<string,integer> mapOfSummaryCounts = new map<string,integer>();
    map<string,list<sObject>> mapSobjectRecords = new map<string,list<sObject>>();   
    List<Lead> lstLeadCreate = new List<Lead>();
    List<sObject> lstLeadCreateNew = new List<sObject>();
    Map<String, String> mapEmailWithErrors = new Map<String, String>();
    boolean sendInsertFailRecords = false; */
    
    global KickboxProcessLeadsBatch(string csvFile, string generateJourney, Id kickBoxVerificationRecordId, String filePart, Id campaignId){
       /* try{
            this.csvFile = csvFile;
            this.generateJourney = generateJourney;
            this.kickBoxVerificationRecordId = kickBoxVerificationRecordId;
            this.filePart = filePart;
            this.campaignId = campaignId;
        }catch(Exception pEx) {            
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('KickboxProcessLeadsBatch','KickboxProcessLeadsBatch','campaignId==>'+csvFile+'campaignId==> '+campaignId,pEx)
            );
            throw new KickboxProcessLeadsBatchException(pEx.getMessage());
        } */      
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
       /* try{
            csvFile = csvFile.replace('""','.....');
            Debug.log('csvFile after replace -------- '+csvFile);
            List<List<string>> lstResult = CSVReader.Parse(csvFile,'');
            List<List<string>> fieldNames = new List<List<string>>();//Select default record type.
            Id defaultRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Consumer').getRecordTypeId();
            return Database.getQuerylocator([SELECT Id,Name FROM Lead limit 10]); 
        }catch(Exception pEx) {            
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('KickboxProcessLeadsBatch','start','Line Number==>'+pEx.getLineNumber(),pEx)
            );
            throw new KickboxProcessLeadsBatchException(pEx.getMessage());
        } 
	*/
        return null;
    }
    
    global void execute(Database.BatchableContext bc,List<lead> lstLeads){      
        /*
		set<Id> setInsertedLeads = new set<Id>();
        set<string> setInsertedLeadEmails = new set<string>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get('Lead');
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        Boolean generateJourneyFlag;
        //Parse records of csv file. 
        List<List<string>> lstResult = CSVReader.Parse(csvFile,'');
        List<List<string>> fieldNames = new List<List<string>>();
        Id defaultRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Consumer').getRecordTypeId();
        
        try{
            //Fetch Colum names from CSV file
            for(List<string> objList : lstResult){
                fieldNames.add(objList);
            }
            
            //Debug.log('fieldNames -------- '+fieldNames);
            Integer intEmail = 0; 
            //Convert all colum labels to Lead field API
            Map<String, String> mapFieldDataType = new Map<String, String>();
            Map<String, Schema.SObjectField> mapLeadFieldSchema = Schema.SObjectType.Lead.fields.getMap();
            for(String key : mapLeadFieldSchema.KeySet()){
                for(integer col=0; fieldNames[0].size() >col ; col++){
                    if(fieldNames[0][col] == mapLeadFieldSchema.get(key).getDescribe().getLabel()){
                        fieldNames[0][col] = key;
                        //Get column number of email field need to add in error csv file
                        if(Key.toLowerCase() == 'email')
                            intEmail = col;
                        String fieldType =String.valueOf(mapLeadFieldSchema.get(key).getDescribe().getType());
                        mapFieldDataType.put(fieldNames[0][col],fieldType);
                    }
                }
            }
            
            
            //Check lead information uploaded in csv file is correct and if not then add it to the error map to be recorded in csv file.
            for(integer row=1; fieldNames.size() >row ; row++){
                generateJourneyFlag = Boolean.valueOf(generateJourney);
                SObject record = Lead.getSObjectType().newSObject(null, true);
                for(integer col=0; fieldNames[0].size() >col ; col++){
                    if(fieldNames[row][col] == '.....'){
                        fieldNames[row][col] = '';
                    }
                    
                    if(fieldNames[row][col].indexOf('"') != -1 || fieldNames[row][col].indexOf(',') != -1){
                        fieldNames[row][col] = fieldNames[row][col].replace('"',''); //skip unwanted char
                        fieldNames[row][col] = fieldNames[row][col].replace(',',''); //skip unwanted char                  
                    }
                    
                    if(fieldNames[0][col].toLowerCase() == 'lead owner' || fieldNames[0][col].toLowerCase() == 'owner')
                        fieldNames[0][col] = 'ownerId';
                    
                    if(Lead.getSobjectType().getDescribe().fields.getMap().keySet().contains(fieldNames[0][col].toLowerCase()) || fieldNames[0][col] == 'undeliverable' || fieldNames[0][col] == 'result'){
                        if(Lead.getSobjectType().getDescribe().fields.getMap().keySet().contains(fieldNames[0][col].toLowerCase())){
                            if(fieldNames[0][col] != 'generate_journey__c'){
                                //get data types for each fields
                                Schema.DisplayType fielddataType = fieldMap.get(fieldNames[0][col]).getDescribe().getType();
                                
                                //Date Validation
                                if(string.valueOf(fielddataType).toLowerCase()=='date' && fieldNames[row][col] != '' && fieldNames[row][col] != null){
                                    if(!fieldNames[row][col].isAlpha()){
                                        try {
                                            record.put(fieldNames[0][col], date.parse(fieldNames[row][col]));
                                        }
                                        Catch (exception e) {
                                            mapEmailWithErrors.put(fieldNames[row][intEmail],'Invalid '+fieldNames[row][col]+' value for '+string.valueOf(fielddataType).toLowerCase());
                                            break;
                                        }
                                    }
                                    else{
                                        mapEmailWithErrors.put(fieldNames[row][intEmail],'Invalid '+fieldNames[row][col]+' value for '+string.valueOf(fielddataType).toLowerCase());
                                        break;
                                    }
                                }
                                //DateTime Validation
                                if(string.valueOf(fielddataType).toLowerCase()=='datetime' && fieldNames[row][col] != '' && fieldNames[row][col] != null){
                                    if(!fieldNames[row][col].isAlpha()){
                                        try {
                                            record.put(fieldNames[0][col], DateTime.parse(fieldNames[row][col]));
                                        }
                                        Catch (exception e) {
                                            mapEmailWithErrors.put(fieldNames[row][intEmail],'Invalid '+fieldNames[row][col]+' value for '+string.valueOf(fielddataType).toLowerCase());
                                            break;
                                        }
                                    }
                                    else{
                                        mapEmailWithErrors.put(fieldNames[row][intEmail],'Invalid '+fieldNames[row][col]+' value for '+string.valueOf(fielddataType).toLowerCase());
                                        break;
                                    }
                                }
                                //Boolean Validation
                                else if(string.valueOf(fielddataType).toLowerCase()=='boolean' && fieldNames[row][col] != '' && fieldNames[row][col] != null){
                                    if(fieldNames[row][col].toLowerCase()=='true' || fieldNames[row][col].toLowerCase()=='false'){
                                        record.put(fieldNames[0][col], boolean.valueOf(fieldNames[row][col]));
                                    }
                                    else{
                                        mapEmailWithErrors.put(fieldNames[row][intEmail],'Invalid '+fieldNames[row][col]+' value for '+string.valueOf(fielddataType).toLowerCase());
                                        break;
                                    }
                                }
                                //Double Validation
                                else if(string.valueOf(fielddataType).toLowerCase()=='double' && fieldNames[row][col] != '' && fieldNames[row][col] != null){
                                    if(!fieldNames[row][col].isAlpha() || !fieldNames[row][col].isAlphanumeric()){
                                        record.put(fieldNames[0][col], decimal.valueOf(fieldNames[row][col]));
                                    }
                                    else{
                                        mapEmailWithErrors.put(fieldNames[row][intEmail],'Invalid '+fieldNames[row][col]+' value for '+string.valueOf(fielddataType).toLowerCase());
                                        break;
                                    }
                                }
                                else if(string.valueOf(fielddataType).toLowerCase() =='reference'){
                                    if(fieldNames[0][col] == 'ownerId')
                                    {
                                        if(fieldNames[row][col] != '' && fieldNames[row][col] != null){
                                            if(fieldNames[row][col].length() == 18 || fieldNames[row][col].length() == 15){
                                                record.put(fieldNames[0][col], fieldNames[row][col]);
                                            }
                                            else{
                                                mapEmailWithErrors.put(fieldNames[row][intEmail],'Invalid '+fieldNames[row][col]+' value for '+string.valueOf(fielddataType).toLowerCase());
                                                break;
                                            }
                                        }
                                        else{
                                            record.put(fieldNames[0][col], UserInfo.getUserId());
                                        }
                                    }
                                    
                                    if(fieldNames[row][col].length() == 18 || fieldNames[row][col].length() == 15 || fieldNames[row][col] == null || fieldNames[row][col] == ''){
                                        if(fieldNames[row][col] != null && fieldNames[row][col] != ''){
                                            record.put(fieldNames[0][col], String.valueOf(fieldNames[row][col]).substring(0, 15));
                                        }
                                    }
                                    else{
                                        mapEmailWithErrors.put(fieldNames[row][intEmail],'Invalid '+fieldNames[row][col]+' value for '+string.valueOf(fielddataType).toLowerCase());
                                        break;
                                    }
                                }
                                //Other Validation
                                else if(fieldNames[0][col] != 'email' && string.valueOf(fielddataType).toLowerCase()!='datetime' && string.valueOf(fielddataType).toLowerCase()!='boolean' && string.valueOf(fielddataType).toLowerCase()!='date' && string.valueOf(fielddataType).toLowerCase()!='double'){
                                    record.put(fieldNames[0][col], fieldNames[row][col]);
                                }
                                else{
                                    if(record.get('email') == null && record.get('Email') == null){
                                        record.put(fieldNames[0][col], fieldNames[row][col]);
                                    }
                                }                           
                            }
                            //If Generate_Journey__c then check Kickbox record value
                            else{
                                if(!generateJourneyFlag){
                                    if(String.isNotBlank(fieldNames[row][col])){
                                        generateJourneyFlag = Boolean.valueOf(fieldNames[row][col]);
                                    }
                                }                               
                            }
                        }
                    }
                    else
                        continue;
                }
                
                record.put('Generate_Journey__c',generateJourneyFlag);
                if(boolean.valueOf(generateJourney))
                    record.put('Generate_Journey__c',true);                
                record.put('Check_Duplicates__c',true);
                record.put('RecordTypeId',defaultRecordTypeId);
                record.put('By_Pass_Journey_Creation_Criteria__c',true);
                if(campaignId != null)
                    record.put('Kickbox_CampaignId__c',campaignId);
                
                Id ownerIdVal = null;
                String strId = null;
                if(record.get('OwnerId')!= null){
                    strId = String.valueOf(record.get('OwnerId'));
                    ownerIdVal = Id.valueOf(strId);
                }
                
                if(record.get('OwnerId')!= null && !Settings.getUserActive(ownerIdVal)){
                    record.put('OwnerId', UserInfo.getUserId());
                }
                lstLeadCreateNew.add(record);            
            }
            
            if(lstLeadCreateNew!=null && !lstLeadCreateNew.isEmpty()){
                List<Lead> lstLeadCreateNewDup = lstLeadCreateNew.clone();
                lstLeadCreateNew.clear();
                for(Lead objLead : lstLeadCreateNewDup){
                    if( String.isNotBlank(objLead.Email) && objLead.LastName != null && objLead.LastName != '' && objLead.Company != null && objLead.Company != '' && objLead.LeadSource != null && objLead.LeadSource != '' && mapEmailWithErrors.get(objLead.Email) == null){
                        lstLeadCreateNew.add(objLead);
                    }else{
                        //lstLeadNotCreated.add(objLead);
                        if(!mapEmailWithErrors.containsKey(objLead.Email))
                            mapEmailWithErrors.put(objLead.Email,'Required Fields "Email" or "LastName or Company or LeadSource" Missing.');
                        sendInsertFailRecords = true;
                    }
                }
            }
            
            Debug.log('lstLeadCreateNew : '+lstLeadCreateNew != null ? JSON.serialize(lstLeadCreateNew): '');
            Debug.log('mapEmailWithErrors : '+mapEmailWithErrors);
            
            //This date time is use to fetch joureny created or update between 2 min.
            DateTime dt1 = DateTime.now();
            DateTime dt2 = dt1.addSeconds(-60);
            dt1 = dt1.addSeconds(60);
            Debug.log('dt2==>'+dt2);
            Debug.log('dt1==>'+dt1);
            
            //Insert the leads data
            Database.SaveResult[] resultLstLeadCreateNew = Database.insert(lstLeadCreateNew, false);
            Debug.log('KickBox Lead Insert  Database.SaveResult ==>'+resultLstLeadCreateNew);
            
            //Insert Failed Leads Create CSV
           // Id userId = UserInfo.getUserId();
           // User objUser = [Select Id,Email, FirstName From user Where id =: userId];
            string headerFailRecord = 'Lead Email, Error\n';
            string finalstrFailRecord = headerFailRecord;
            Integer successCount = 0;
            
            //Count the success and error of the lead after leads insert.
            for(Integer count=0;count<resultLstLeadCreateNew.size();count++){
                if(!resultLstLeadCreateNew[count].isSuccess()){//only look at failures, or NOT Successes
                    List<Database.Error> err = resultLstLeadCreateNew[count].getErrors();
                    sendInsertFailRecords = true;
                    string checkEmailContains = String.valueOf(lstLeadCreateNew[count].get('Email'));
                    if(!mapEmailWithErrors.containsKey(checkEmailContains)){
                        mapEmailWithErrors.put(checkEmailContains,err[0].getMessage());
                    }
                }else{
                    Database.SaveResult sr = resultLstLeadCreateNew[count];
                    successCount++;
                    setInsertedLeadEmails.add(String.valueOf(lstLeadCreateNew[count].get('Email')).toLowerCase());
                    setInsertedLeads.add(sr.getId());
                }
            }
           Debug.log('mapEmailWithErrors===>'+mapEmailWithErrors); 
            List<Contact> lstExistingContactEmails = [SELECT Id,Email FROM Contact WHERE Email IN : setInsertedLeadEmails];
            Debug.log('lstExistingContactEmails ==>'+lstExistingContactEmails);
            set<string> setContactEmails = new set<string>();
            for(Contact currentContact : lstExistingContactEmails){
                if(String.isNotBlank(currentContact.Email)){
                    setContactEmails.add(currentContact.Email.toLowerCase());  
                }               
            }
             Debug.log('setContactEmails ==>'+setContactEmails);
            //SOQL to get list of Leads,Journey and Contact records show as a table in email.
            List<Lead> lstExistingLeadEmails = [SELECT Id,Email FROM Lead WHERE Email IN : setInsertedLeadEmails AND isConverted = FALSE AND Id NOT IN : setInsertedLeads];
            Debug.log('lstExistingLeadEmails==>'+lstExistingLeadEmails);
            List<Lead> lstNewLeads = [SELECT Id,Email FROM Lead WHERE Email IN : setInsertedLeadEmails AND Email NOT IN : setContactEmails AND Id NOT IN : lstExistingLeadEmails AND isConverted = FALSE];
            Debug.log('lstNewLeads==>'+lstNewLeads);
            List<Journey__c> lstJourenys = [SELECT Id,Primary_Email__c,createdDate,LastModifiedDate from Journey__c WHERE Primary_Email__c IN : setInsertedLeadEmails AND CreatedDate >: dt2 AND CreatedBy.Id =: UserInfo.getUserId()];
            Debug.log('lstJourenys==>'+lstJourenys);
            List<Journey__c> lstExistingJourenys = [SELECT Id,Primary_Email__c,createdDate,LastModifiedDate from Journey__c WHERE Primary_Email__c IN : setInsertedLeadEmails AND LastModifiedDate >: dt2  AND LastModifiedBy.Id =: UserInfo.getUserId() AND Id NOT IN:lstJourenys];//AND LastModifiedDate <: dt1
            Debug.log('lstExistingJourenys==>'+lstExistingJourenys);
            
            //Put Leads and journeys created and upladed into the map.
            mapSobjectRecords.put('Existing Leads',lstExistingLeadEmails);
            mapSobjectRecords.put('Existing Contacts',lstExistingContactEmails);
            mapSobjectRecords.put('Existing Journeys',lstExistingJourenys);
            mapSobjectRecords.put('New Leads',lstNewLeads);
            mapSobjectRecords.put('New Journeys',lstJourenys);
            
            //Put summery of uploaded records into map to be pass to send email function
            mapOfSummaryCounts.put('Total Number of Leads Uploaded',lstLeadCreateNew.size());
            mapOfSummaryCounts.put('New Leads Inserted in SF',lstNewLeads.size());
            mapOfSummaryCounts.put('Existing Lead Updated',lstExistingLeadEmails.size());
            mapOfSummaryCounts.put('Existing Contact Updated',lstExistingContactEmails.size());
            mapOfSummaryCounts.put('New Journeys Inserted in SF',lstJourenys.size());
            mapOfSummaryCounts.put('Existing Journeys Updated',lstExistingJourenys.size());
            
            if(mapEmailWithErrors!=null && !mapEmailWithErrors.isEmpty()){//
                for(String error : mapEmailWithErrors.keySet()){
                   // if(mapEmailWithErrors.containsKey(error)){//if csv doesn't contain the email only then add to csv
                        string recordString = error+','+mapEmailWithErrors.get(error)+'\n';
                        finalstrFailRecord = finalstrFailRecord +recordString;
                        sendInsertFailRecords = true;
                    //}
                }
                Debug.log('finalstrFailRecord ==>>'+finalstrFailRecord);
                //Insert Failed Leads Attachment save to Salesforce
                Attachment objAttachmentFailedInsert = new Attachment();
                objAttachmentFailedInsert.Name = 'Kickbox Lead Insert Failed : File Part : '+filePart;
                objAttachmentFailedInsert.IsPrivate = false;
                objAttachmentFailedInsert.ContentType = 'text/csv';
                objAttachmentFailedInsert.Body =  Blob.valueof(finalstrFailRecord);
                objAttachmentFailedInsert.OwnerId = UserInfo.getUserId();
                objAttachmentFailedInsert.ParentId = kickBoxVerificationRecordId;
                Debug.log('objAttachmentFailedInsert==>'+objAttachmentFailedInsert);
                insert objAttachmentFailedInsert;
            }//End
            
            //Add all leads  before remove it from setInsertedLeadEmails
            //setInsertedLeadEmails shows the journey not created emails
            set<string> setLeadEmails = new set<string>();
            setLeadEmails.addAll(setInsertedLeadEmails);
            //Remove records from set to find id journey not created/updated for lead or contact
            for(Journey__c currentJourney : lstJourenys){
                if(setInsertedLeadEmails.contains(currentJourney.Primary_Email__c.toLowerCase()))
                    setInsertedLeadEmails.remove(currentJourney.Primary_Email__c.toLowerCase());
            }
            
            for(Journey__c currentJourney : lstExistingJourenys){
                if(setInsertedLeadEmails.contains(currentJourney.Primary_Email__c.toLowerCase()))
                    setInsertedLeadEmails.remove(currentJourney.Primary_Email__c.toLowerCase());
            }
            //Map Campaign which is pass from Campaign Email page.
            //ST-1501 Added by shobhit for allowing creation of campaign members in kickbox journey importer
            Debug.log('Kickbox campaignId==>'+campaignId);
            Debug.log('Kickbox setInsertedLeads==>'+setInsertedLeads);
            if(campaignId != null && setInsertedLeads != null && setInsertedLeads.size() > 0){
                List<CampaignMember> lstCampaignMember = new List<CampaignMember>();
                if(campaignId !=null){
                    //Fetch lead to be added into campaign
                    if(setLeadEmails != null && setLeadEmails.size() > 0){
                        for(Lead obj : [SELECT Id FROM Lead WHERE Email IN : setLeadEmails AND IsConverted = false]){
                            CampaignMember campMem = new CampaignMember (campaignid=campaignId, leadid=obj.Id);
                            lstCampaignMember.add(campMem);
                        }
                        
                        if(lstExistingContactEmails != null && lstExistingContactEmails.size()>0){
                            for(Contact obj : lstExistingContactEmails){
                                if(mapEmailWithErrors != null && !mapEmailWithErrors.containsKey(obj.Email)){
                                    CampaignMember campMem = new CampaignMember (campaignid=campaignId, contactId=obj.Id);
                                    lstCampaignMember.add(campMem);
                                }
                            }
                        }
                    }
                    
                    Debug.log('lstCampaignMember 386==>'+lstCampaignMember.size());
                    if(lstCampaignMember != null && lstCampaignMember.size() > 0){
                        Database.SaveResult[] lstCampMemberResult = database.insert (lstCampaignMember,false); //need to handle error for campaign member for all emails and send in csv
                        //use mapEmailWithErrors variable to add email and respective error
                        Debug.Log('lstCampMemberResult==> '+lstCampMemberResult);
                        Integer campaignMemebrCount = 0;
                        for (Database.SaveResult currentResult : lstCampMemberResult) {
                            if (currentResult.isSuccess()) {
                                campaignMemebrCount++;
                            }
                        }
                        mapOfSummaryCounts.put('Number of Campaign members added',campaignMemebrCount);
                    }
                    
                }
            }
            
            Setting__c RecordJSONKickboxLeadImporterUtility = Settings.get('KickboxLeadImporterUtility');
            KickboxVerificationController.KickboxLeadImporterUtility objKickboxLeadImporterUtility = new KickboxVerificationController.KickboxLeadImporterUtility();            
            objKickboxLeadImporterUtility = (KickboxVerificationController.KickboxLeadImporterUtility)JSON.deserialize(RecordJSONKickboxLeadImporterUtility.Data__c, KickboxVerificationController.KickboxLeadImporterUtility.Class);
            
            KickboxVerificationApiHandler.successWrapper objsuccessWrapper = new KickboxVerificationApiHandler.successWrapper();
            objsuccessWrapper.kickboxId = kickBoxVerificationRecordId;
            List<Map<string,string>> lstsuccessLeads = new List<Map<string,string>>();
            List<String> lstleadApiNames = new List<String>();
            Set<String> setHeadersSuccessCsv = new Set<String>();
            lstleadApiNames = objKickboxLeadImporterUtility.CsvAPINames;
            //debug.log('lstleadApiNames :: '+lstleadApiNames);
            boolean sendPassRecords = false;
            boolean sendFailedRecords = false;
            //Success Full Leads
            string header = 'Lead Id, Name , Email \n';
            string finalstr = header ;
            
            //Add data into map and set to generate csv file.
            for(sObject objLead: lstLeadCreateNew){            
                if(setInsertedLeads.contains(objLead.Id)){
                    Map<string,string> mapsuccessLead = new Map<string,string>();
                    
                    for(string apiName : lstleadApiNames){                    
                        if(String.valueOf(objLead.get(apiName)) != null){
                            if(apiName == 'Id'){
                                mapsuccessLead.put('Lead Id',String.valueOf(objLead.get('Id')));
                                if(setHeadersSuccessCsv.contains('Lead Id') == false)   
                                    setHeadersSuccessCsv.add('Lead Id');                               
                            }else{
                                mapsuccessLead.put(fieldMap.get(apiName).getDescribe().getLabel(),String.valueOf(objLead.get(apiName)));
                                if(setHeadersSuccessCsv.contains(fieldMap.get(apiName).getDescribe().getLabel()) == false)
                                    setHeadersSuccessCsv.add(fieldMap.get(apiName).getDescribe().getLabel());
                            }
                        }
                    }
                    if(setInsertedLeadEmails.contains(String.valueOf(objLead.get('Email')).toLowerCase())){
                        mapsuccessLead.put('Journey Status','Journey not created as Generate Journey is False OR Activity is present with in 60 days');
                        setHeadersSuccessCsv.add('Journey Status');
                    }else{
                        mapsuccessLead.put('Journey Status','');
                        setHeadersSuccessCsv.add('Journey Status');
                    }
                    
                    lstsuccessLeads.add(mapsuccessLead);
                    string recordString = String.valueOf(objLead.get('Id'))+','+String.valueOf(objLead.get('FirstName'))+','+String.valueOf(objLead.get('Email'))+'\n';
                    finalstr = finalstr +recordString;
                    sendPassRecords = true;
                }
            }
            
            if(lstSuccessLeads.size() > 0 && lstSuccessLeads != null && sendPassRecords){
                objsuccessWrapper.lstsuccessLeads = lstSuccessLeads;
                objsuccessWrapper.setHeadersSuccessCsv = setHeadersSuccessCsv;
            }
            
            if(mapEmailWithErrors != null && !mapEmailWithErrors.isEmpty() && sendInsertFailRecords){
                objsuccessWrapper.mapErrors = mapEmailWithErrors;
            }
            List<Messaging.Emailfileattachment> lstAttachments = new List<Messaging.Emailfileattachment>();
            Attachment objAttachment = new Attachment();
            objAttachment.Name = 'Kickbox Response : Success : File Part : '+filePart;
            objAttachment.IsPrivate = false;
            objAttachment.ContentType = 'text/csv';
            objAttachment.Body =  Blob.valueof(finalstr);
            objAttachment.OwnerId = UserInfo.getUserId();
            objAttachment.ParentId = kickBoxVerificationRecordId;
            insert objAttachment;
            Debug.log('mapSobjectRecords====>'+mapSobjectRecords); 
            Debug.log('objsuccessWrapper==>'+objsuccessWrapper);
            mapCSV = KickboxVerificationApiHandler.createCSV(objsuccessWrapper); 
        }catch(Exception pEx) {            
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('KickboxProcessLeadsBatch','execute','Line Number==>'+pEx.getLineNumber()+'lstLeads==>'+lstLeads !=null ? JSON.serialize(lstLeads) : '',pEx)
            );
            throw new KickboxProcessLeadsBatchException(pEx.getMessage());
        }  
        */
    }  
    
    global void finish(Database.BatchableContext bc){
      /*  try{
            KickboxVerificationController.kickboxVerificationSendMail(mapCSV.get('csvFailure'),mapCSV.get('csvSuccess'),kickBoxVerificationRecordId,mapSobjectRecords,mapOfSummaryCounts);    
        }catch(Exception pEx) {            
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('KickboxProcessLeadsBatch','finish','Line Number==>'+pEx.getLineNumber(),pEx)
            );
            throw new KickboxProcessLeadsBatchException(pEx.getMessage());
        }  
    */    
    } 
    public class KickboxProcessLeadsBatchException extends Exception {}
	
}