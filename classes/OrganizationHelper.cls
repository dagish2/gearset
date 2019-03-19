public class OrganizationHelper {
    public List<String> getListFields(String sObjectName){
        List<String> lstFields = new List<String>{'Email_Domain__c','Unomy_Company_ID__c','Cleansed_Unomy_Company_Name__c','Unomy_Company_Name__c','Cleansed_Company_Name__c','Name','Email'};
        if(sObjectName.toLowerCase() == 'lead'){
            lstFields.addAll(new List<String>{'Company'});
            return lstFields;
        }else if(sObjectName.toLowerCase() == 'Contact'){
            lstFields.addAll(new List<String>{'Account_Name__c','Company__c'});
            return lstFields;
        }
        return null;
    }
    public static Id findRelatedOrg(sObject objRecord){
        Map<Id,Id> mapOrgByIds = findRelatedOrg(new List<sObject>{objRecord});
        return mapOrgByIds.get(String.valueOf(objRecord.get('Id')));
    }
    public static Id findOrCreateRelatedOrg(sObject objRecord){
        Map<Id,Id> mapOrgByIds = findOrCreateRelatedOrg(new List<sObject>{objRecord});
        return mapOrgByIds.get(String.valueOf(objRecord.get('Id')));
    }
    public static Map<Id,Id> findRelatedOrg(List<sObject> lstRecords){
        return findOrg(lstRecords);
    }
    public static Map<Id,Id> findOrCreateRelatedOrg(List<sObject> lstRecords){
        Map<Id,Id> mapOrgByIds = findOrg(lstRecords);
        List<Contact> lstContactsToCreateOrg = new List<Contact>();
        debug.log('findOrCreateRelatedOrg:mapOrgByIds'+mapOrgByIds);
        Set<Id> setContactIds = new Set<Id>();
        for(Id sourceId:mapOrgByIds.keySet()){
            if(String.valueOf(sourceId).startsWith('003') && mapOrgByIds.get(sourceId)==null){
                setContactIds.add(sourceId);
            }
        }
        debug.log('findOrCreateRelatedOrg:setContactIds'+setContactIds);
        if(setContactIds.size()>0){
            Map<Id,sObject> mapFieldMappings = FieldMappingsHelper.getMappings(setContactIds, 'FieldMappings:ContactToAccount');
            for(Id sourceId:mapFieldMappings.keySet()){
                if(String.isBlank(String.valueOf(mapFieldMappings.get(sourceId).get('Primary_Member__c')))){
                    mapFieldMappings.get(sourceId).put('Primary_Member__c',sourceId);
                }
                if(PersonEndpointHelper.personContactId == sourceId){
                    mapFieldMappings.get(sourceId).put('Account_SubType__c', 'Broker');
                }
                if(String.isBlank(String.valueOf(mapFieldMappings.get(sourceId).get('Name')))){
                    for(sObject record:lstRecords){
                        if(record.get('Id')==sourceId){
                            Contact objContact = (Contact)record;
                            if(objContact.Account_Name__c!=null){
                                mapFieldMappings.get(sourceId).put('Name',objContact.Account_Name__c);
                            }else if(objContact.Unomy_Company_Name__c!=null){
                                mapFieldMappings.get(sourceId).put('Name',objContact.Unomy_Company_Name__c);
                            }else if(objContact.Company__c!=null){
                                mapFieldMappings.get(sourceId).put('Name',objContact.Company__c);
                            }else if(objContact.Name!=null){
                                mapFieldMappings.get(sourceId).put('Name',objContact.Name);
                            }else if(objContact.FirstName!=null && objContact.LastName!=null){
                                mapFieldMappings.get(sourceId).put('Name',(objContact.FirstName+' '+objContact.LastName));
                            }else if(objContact.LastName!=null){
                                mapFieldMappings.get(sourceId).put('Name',objContact.LastName);
                            }
                        }
                    }
                }
                mapFieldMappings.get(sourceId).put('Account_Type__c','Org');
            }
            debug.log('mapFieldMappings.values()'+mapFieldMappings.values());
            List<Database.SaveResult> lstSaveResult = Database.insert(mapFieldMappings.values());
            for(Id sourceId : mapFieldMappings.keySet()){
                if(!String.isBlank(String.valueOf(mapFieldMappings.get(sourceId).get('Id')))){
                    mapOrgByIds.put(String.valueOf(mapFieldMappings.get(sourceId).get('Primary_Member__c')),String.valueOf(mapFieldMappings.get(sourceId).get('Id')));
                }else{
                    mapOrgByIds.put(sourceId,null);
                }
            }
        }
        return mapOrgByIds;
    }
    public static Map<Id,Id> findOrg(List<sObject> lstRecords){
        Map<Id,Id> mapOrgIds = new Map<Id,Id>();
        List<sObject> lstEntitiesWithNoOrg = new List<sObject>();
        Debug.Log('findOrg lstRecords---'+lstRecords);
        Set<Id> setSalesIds = new Set<Id>();
        for(sObject objRecord:lstRecords){
            if(objRecord != null){
                String strOrgField = String.valueOf(objRecord.get('Id')).toLowerCase().startsWith('00q')?'Account__c':'AccountId';
                if(String.isNotBlank(String.valueOf(objRecord.get(strOrgField))) && objRecord.getSObject(strOrgField=='Account__c'?'Account__r':'Account').get('Account_Type__c')=='Org'){
                    mapOrgIds.put(String.valueOf(objRecord.get('Id')),String.valueOf(objRecord.get(strOrgField)));
                }else if(String.isNotBlank(String.valueOf(objRecord.get(strOrgField))) && objRecord.getSObject(strOrgField=='Account__c'?'Account__r':'Account').get('Account_Type__c')=='Sales'){
                    mapOrgIds.put(String.valueOf(objRecord.get('Id')),String.valueOf(objRecord.get(strOrgField)));
                }else{
                    lstEntitiesWithNoOrg.add(objRecord);
                }
            }            
        }
        if(setSalesIds.size()>0){
            Map<Id,Id> mapUltimateParents = getUltimateParents(setSalesIds);
            for(Id accountId:mapOrgIds.keySet()){
                if(mapUltimateParents.containsKey(mapOrgIds.get(accountId))){
                    mapOrgIds.put(accountId,mapUltimateParents.get(mapOrgIds.get(accountId)));
                }
            }
        }
        if(lstEntitiesWithNoOrg.size()>0){
            return getOrgsByAllCriterias(lstEntitiesWithNoOrg,mapOrgIds);
        }else{
            return mapOrgIds;
        }
    }
    public static Map<Id,Id> getOrgsByAllCriterias(List<sObject> lstRecords,Map<Id,Id> mapOrgIds){
        Set<Integer> setUnomyCompanyIds = new Set<Integer>();
        Set<String> setUnomyCompanyNames = new Set<String>();
        Set<String> setCompanyNames = new Set<String>();
        Set<String> setCleansedCompanyNames = new Set<String>();
        Set<String> setEmailDomains = new Set<String>();
        Set<String> setPublicDomains = getPublicDomains();
        for(sObject objRecord:lstRecords){
            if(objRecord.get('Unomy_Company_ID__c')!=null && String.isNotBlank(String.valueOf(objRecord.get('Unomy_Company_ID__c')))){
                setUnomyCompanyIds.add(Integer.valueOf(objRecord.get('Unomy_Company_ID__c')));                
            }
            if(objRecord.get('Cleansed_Unomy_Company_Name__c')!=null && String.isNotBlank(String.valueOf(objRecord.get('Cleansed_Unomy_Company_Name__c')))){
                setUnomyCompanyNames.add(String.valueOf(objRecord.get('Cleansed_Unomy_Company_Name__c')));                
            }else if(objRecord.get('Unomy_Company_Name__c')!=null && String.isNotBlank(String.valueOf(objRecord.get('Unomy_Company_Name__c')))){
                setCompanyNames.add(String.valueOf(objRecord.get('Unomy_Company_Name__c')));
                setUnomyCompanyNames.add(String.valueOf(objRecord.get('Unomy_Company_Name__c')));
            }
            if(objRecord.get('Cleansed_Company_Name__c')!=null && String.isNotBlank(String.valueOf(objRecord.get('Cleansed_Company_Name__c')))){
                setCleansedCompanyNames.add(String.valueOf(objRecord.get('Cleansed_Company_Name__c')));              
            }else if(objRecord.get('Id')!=null && String.valueOf(objRecord.get('Id')).startsWith('003') && objRecord.get('Company__c')!=null && String.isNotBlank(String.valueOf(objRecord.get('Company__c')))){
                setCompanyNames.add(String.valueOf(objRecord.get('Company__c')));
            }else if(objRecord.get('Id')!=null && String.valueOf(objRecord.get('Id')).toLowerCase().startsWith('00q') && objRecord.get('Company')!=null && String.isNotBlank(String.valueOf(objRecord.get('Company')))){
                setCompanyNames.add(String.valueOf(objRecord.get('Company')));
            }
            if(objRecord.get('Id')!=null && String.valueOf(objRecord.get('Id')).startsWith('003') && objRecord.get('Account_Name__c')!=null && String.isNotBlank(String.valueOf(objRecord.get('Account_Name__c')))){
                setCompanyNames.add(String.valueOf(objRecord.get('Account_Name__c')));
            }
            if(objRecord.get('Name')!=null && String.isNotBlank(String.valueOf(objRecord.get('Name')))){
                setCompanyNames.add(String.valueOf(objRecord.get('Name')));              
            }
            if(objRecord.get('Email')!=null && String.isNotBlank(String.valueOf(objRecord.get('Email')))){
                String strDomain = String.valueOf(objRecord.get('Email')).split('@')[1];
                if(!setPublicDomains.contains(strDomain)){
                    setEmailDomains.add(strDomain);
                }
            }
        }
        debug.log('setUnomyCompanyIds==>'+setUnomyCompanyIds);
        debug.log('setUnomyCompanyNames==>'+setUnomyCompanyNames);
        debug.log('setCompanyNames==>'+setCompanyNames);
        debug.log('setCleansedCompanyNames==>'+setCleansedCompanyNames);
        debug.log('setEmailDomains==>'+setEmailDomains);
        
        List<sObject> lstLeadContacts = new List<sObject>();
        lstLeadContacts.addAll([Select Id, Name, Unomy_Company_ID__c, Cleansed_Account_Name__c, Cleansed_Unomy_Company_Name__c, Unomy_Company_Name__c, Account_Type__c From Account Where (Unomy_Company_Id__c IN:setUnomyCompanyIds OR Cleansed_Account_Name__c IN:setUnomyCompanyNames OR Cleansed_Account_Name__c IN:setCleansedCompanyNames OR Cleansed_Unomy_Company_Name__c IN:setUnomyCompanyNames OR Cleansed_Unomy_Company_Name__c IN:setCleansedCompanyNames OR Name IN:setCompanyNames)]);
        if(setEmailDomains.size()>0){
            lstLeadContacts.addAll([Select Id, Account__c, Email_Domain__c From Lead Where (Account__r.Account_Type__c = 'Org' OR Account__r.Account_Type__c = 'Sales') AND Email_Domain__c IN:setEmailDomains]);
            lstLeadContacts.addAll([Select Id, AccountId, Email_Domain__c From Contact Where (Account.Account_Type__c = 'Org' OR Account.Account_Type__c = 'Sales') AND Email_Domain__c IN:setEmailDomains]);
        }
        debug.log('lstLeadContacts==>'+lstLeadContacts);
        Set<Id> setAccountIds = new Set<Id>();
        Set<String> setNewEmailDomains = new Set<String>();
        for(sObject record:lstLeadContacts){
            if(String.valueOf(record.get('Id')).startsWith('001') && String.isNotBlank(String.valueOf(record.get('Account_Type__c'))) && (String.valueOf(record.get('Account_Type__c')).equalsIgnoreCase('Org') || String.valueOf(record.get('Account_Type__c')).equalsIgnoreCase('Sales'))){
                setAccountIds.add(String.valueOf(record.get('Id')));
            }else if(String.valueOf(record.get('Id')).toLowerCase().startsWith('00q')){
                if(!setNewEmailDomains.contains(String.valueOf(record.get('Email_Domain__c')))){
                    setAccountIds.add(String.valueOf(record.get('Account__c')));
                    setNewEmailDomains.add(String.valueOf(record.get('Email_Domain__c')));
                }
            }else if(String.valueOf(record.get('Id')).startsWith('003')){
                if(!setNewEmailDomains.contains(String.valueOf(record.get('Email_Domain__c')))){
                    setAccountIds.add(String.valueOf(record.get('AccountId')));
                    setNewEmailDomains.add(String.valueOf(record.get('Email_Domain__c')));
                }    
            }
        }
        Debug.Log('setAccountIds---'+setAccountIds);
        Map<Id,Id> mapUltimateParents = getUltimateParents(setAccountIds);
        Map<Decimal,Id> mapOrgsByUnomyId = new Map<Decimal,Id>();
        Map<String,Id> mapOrgsByUnomyName = new Map<String,Id>();
        Map<String,Id> mapOrgsByName = new Map<String,Id>();
        Map<String,Id> mapOrgsByDomain = new Map<String,Id>();
        for(sObject record:lstLeadContacts){
            if(String.valueOf(record.get('Id')).startsWith('001')  && String.isNotBlank(String.valueOf(record.get('Account_Type__c'))) && (String.valueOf(record.get('Account_Type__c')).equalsIgnoreCase('Org') || String.valueOf(record.get('Account_Type__c')).equalsIgnoreCase('Sales'))){
                if(record.get('Unomy_Company_ID__c')!=null && String.isNotBlank(String.valueOf(record.get('Unomy_Company_ID__c')))){
                    mapOrgsByUnomyId.put(Decimal.valueOf(String.valueOf(record.get('Unomy_Company_ID__c'))),mapUltimateParents.get(String.valueOf(record.get('Id'))));
                }
                if(record.get('Cleansed_Unomy_Company_Name__c')!=null && String.isNotBlank(String.valueOf(record.get('Cleansed_Unomy_Company_Name__c')))){
                    mapOrgsByUnomyName.put(String.valueOf(record.get('Cleansed_Unomy_Company_Name__c')),mapUltimateParents.get(String.valueOf(record.get('Id'))));
                }
                if(record.get('Unomy_Company_Name__c')!=null && String.isNotBlank(String.valueOf(record.get('Unomy_Company_Name__c')))){
                    mapOrgsByUnomyName.put(String.valueOf(record.get('Unomy_Company_Name__c')),mapUltimateParents.get(String.valueOf(record.get('Id'))));
                }
                if(record.get('Cleansed_Account_Name__c')!=null && String.isNotBlank(String.valueOf(record.get('Cleansed_Account_Name__c')))){
                    mapOrgsByName.put(String.valueOf(record.get('Cleansed_Account_Name__c')),mapUltimateParents.get(String.valueOf(record.get('Id'))));
                }
                if(record.get('Name')!=null && String.isNotBlank(String.valueOf(record.get('Name')))){
                    mapOrgsByName.put(String.valueOf(record.get('Name')),mapUltimateParents.get(String.valueOf(record.get('Id'))));
                }
            }else if(String.valueOf(record.get('Id')).toLowerCase().startsWith('00q')){
                if(record.get('Email_Domain__c')!=null && String.isNotBlank(String.valueOf(record.get('Email_Domain__c'))) && !mapOrgsByDomain.containsKey(String.valueOf(record.get('Email_Domain__c')))){
                    mapOrgsByDomain.put(String.valueOf(record.get('Email_Domain__c')),mapUltimateParents.get(String.valueOf(record.get('Account__c'))));
                }
            }else if(String.valueOf(record.get('Id')).toLowerCase().startsWith('003')){
                if(record.get('Email_Domain__c')!=null && String.isNotBlank(String.valueOf(record.get('Email_Domain__c'))) && !mapOrgsByDomain.containsKey(String.valueOf(record.get('Email_Domain__c')))){
                    mapOrgsByDomain.put(String.valueOf(record.get('Email_Domain__c')),mapUltimateParents.get(String.valueOf(record.get('AccountId'))));
                }
            }
        }
        debug.log('mapOrgsByUnomyId==>'+mapOrgsByUnomyId);
        debug.log('mapOrgsByUnomyName==>'+mapOrgsByUnomyName);
        debug.log('mapOrgsByName==>'+mapOrgsByName);
        debug.log('mapOrgsByDomain==>'+mapOrgsByDomain);
        for(sObject objRecord:lstRecords){
            if(objRecord.get('Unomy_Company_ID__c')!=null && mapOrgsByUnomyId.containsKey(Decimal.valueOf(String.valueOf(objRecord.get('Unomy_Company_ID__c'))))){
                mapOrgIds.put(String.valueOf(objRecord.get('Id')),mapOrgsByUnomyId.get(Decimal.valueOf(String.valueOf(objRecord.get('Unomy_Company_ID__c')))));                
            }else if(objRecord.get('Cleansed_Unomy_Company_Name__c')!=null && mapOrgsByUnomyName.containsKey(String.valueOf(objRecord.get('Cleansed_Unomy_Company_Name__c')))){
                mapOrgIds.put(String.valueOf(objRecord.get('Id')),mapOrgsByUnomyName.get(String.valueOf(objRecord.get('Cleansed_Unomy_Company_Name__c'))));
            }else if(objRecord.get('Cleansed_Unomy_Company_Name__c')!=null && mapOrgsByName.containsKey(String.valueOf(objRecord.get('Cleansed_Unomy_Company_Name__c')))){
                mapOrgIds.put(String.valueOf(objRecord.get('Id')),mapOrgsByName.get(String.valueOf(objRecord.get('Cleansed_Unomy_Company_Name__c'))));
            }else if(objRecord.get('Cleansed_Company_Name__c')!=null && mapOrgsByUnomyName.containsKey(String.valueOf(objRecord.get('Cleansed_Company_Name__c')))){
                mapOrgIds.put(String.valueOf(objRecord.get('Id')),mapOrgsByUnomyName.get(String.valueOf(objRecord.get('Cleansed_Company_Name__c'))));
            }else if(objRecord.get('Cleansed_Company_Name__c')!=null && mapOrgsByName.containsKey(String.valueOf(objRecord.get('Cleansed_Company_Name__c')))){
                mapOrgIds.put(String.valueOf(objRecord.get('Id')),mapOrgsByName.get(String.valueOf(objRecord.get('Cleansed_Company_Name__c'))));
            }else if(objRecord.get('Unomy_Company_Name__c')!=null && mapOrgsByUnomyName.containsKey(String.valueOf(objRecord.get('Unomy_Company_Name__c')))){
                mapOrgIds.put(String.valueOf(objRecord.get('Id')),mapOrgsByUnomyName.get(String.valueOf(objRecord.get('Unomy_Company_Name__c'))));
            }else if(objRecord.get('Unomy_Company_Name__c')!=null && mapOrgsByName.containsKey(String.valueOf(objRecord.get('Unomy_Company_Name__c')))){
                mapOrgIds.put(String.valueOf(objRecord.get('Id')),mapOrgsByName.get(String.valueOf(objRecord.get('Unomy_Company_Name__c'))));
            }else if(objRecord.get('Id')!=null && String.valueOf(objRecord.get('Id')).startsWith('003') && objRecord.get('Account_Name__c')!=null && mapOrgsByName.containsKey(String.valueOf(objRecord.get('Account_Name__c')))){
                mapOrgIds.put(String.valueOf(objRecord.get('Id')),mapOrgsByName.get(String.valueOf(objRecord.get('Account_Name__c'))));
            }else if(objRecord.get('Id')!=null && String.valueOf(objRecord.get('Id')).startsWith('003') && objRecord.get('Company__c')!=null && mapOrgsByName.containsKey(String.valueOf(objRecord.get('Company__c')))){
                mapOrgIds.put(String.valueOf(objRecord.get('Id')),mapOrgsByName.get(String.valueOf(objRecord.get('Company__c'))));
            }else if(objRecord.get('Id')!=null && String.valueOf(objRecord.get('Id')).toLowerCase().startsWith('00q') && objRecord.get('Company')!=null && mapOrgsByName.containsKey(String.valueOf(objRecord.get('Company')))){
                mapOrgIds.put(String.valueOf(objRecord.get('Id')),mapOrgsByName.get(String.valueOf(objRecord.get('Company'))));
            }else if(objRecord.get('Email_Domain__c')!=null && mapOrgsByDomain.containsKey(String.valueOf(objRecord.get('Email_Domain__c')))){
                mapOrgIds.put(String.valueOf(objRecord.get('Id')),mapOrgsByDomain.get(String.valueOf(objRecord.get('Email_Domain__c'))));
            }else if(objRecord.get('Id')!=null && String.valueOf(objRecord.get('Id')).toLowerCase().startsWith('003') && mapOrgsByName.containsKey(String.valueOf(objRecord.get('Name')))){
                mapOrgIds.put(String.valueOf(objRecord.get('Id')),mapOrgsByName.get(String.valueOf(objRecord.get('Name'))));
            }else{
                mapOrgIds.put(String.valueOf(objRecord.get('Id')),null);
            }
        }
        debug.log('mapOrgIds==>'+mapOrgIds);
        return mapOrgIds;
    }
    public static Set<String> getPublicDomains(){
        Setting__c objPublicDomainSetting = Settings.get('PublicDomainSettings');
        Set<String> setPublicDomains = (Set<String>)JSON.deserialize(objPublicDomainSetting.Data__c, Set<String>.class);
        return setPublicDomains;
    }
    public static Map<Id,Id> getUltimateParents(set<Id> setAccountIds){
        Map<Id,Id> mapUltimateParentAccountId = new Map<Id,Id>();
        for(Id accId : setAccountIds){
            mapUltimateParentAccountId.put(accId,accId);
        }
        Set<Id> setNewAccounts;
        Map<Id,Id> mapNewParentAccountId;
        Boolean topLevelAccount = false;
        While(!topLevelAccount){
            if(setAccountIds.size()>0){
                setNewAccounts = new Set<Id>();
                setNewAccounts.addAll(setAccountIds);
                mapNewParentAccountId = new Map<Id,Id>();
                mapNewParentAccountId.putAll(mapUltimateParentAccountId);
                List<Account> lstAccounts = [ Select Id, Account_Type__c, Parent.Id, Parent.Account_Type__c, Parent.Parent.Id, Parent.Parent.Account_Type__c, Parent.Parent.Parent.Id, Parent.Parent.Parent.Account_Type__c, Parent.Parent.Parent.Parent.Id, Parent.Parent.Parent.Parent.Account_Type__c, Parent.Parent.Parent.Parent.Parent.Id, Parent.Parent.Parent.Parent.Parent.Account_Type__c From Account WHERE Id IN: setNewAccounts ];
                if(lstAccounts.size()>0){
                    for(Account accRec : lstAccounts){
                        Account objAccount;
                        Account objParentAccount;
                        if(accRec.Parent == null){
                            objAccount = accRec;
                            objParentAccount = null;
                        }else if(accRec.Parent != null && accRec.Parent.Parent == null){
                            objAccount = accRec.Parent;
                            objParentAccount = null;
                        }else if(accRec.Parent.Parent != null && accRec.Parent.Parent.Parent == null){
                            objAccount = accRec.Parent.Parent;
                            objParentAccount = null;
                        }else if(accRec.Parent.Parent.Parent != null && accRec.Parent.Parent.Parent.Parent == null){
                            objAccount = accRec.Parent.Parent.Parent;
                            objParentAccount = null;
                        }else if(accRec.Parent.Parent.Parent.Parent != null && accRec.Parent.Parent.Parent.Parent.Parent == null){
                            objAccount = accRec.Parent.Parent.Parent.Parent;
                            objParentAccount = null;
                        }else if(accRec.Parent.Parent.Parent.Parent.Parent != null){
                            objAccount = null;
                            objParentAccount = accRec.Parent.Parent.Parent.Parent.Parent;
                        }
                        if(objAccount != null){
                            if(objAccount.Account_Type__c == 'Org'){
                                for(Id accId : mapNewParentAccountId.keySet()){
                                    if(mapUltimateParentAccountId.containsKey(accId) && mapUltimateParentAccountId.get(accId) == Id.valueOf(accRec.Id)){
                                        mapUltimateParentAccountId.put(accId,objAccount.Id);
                                        break;
                                    }
                                }
                                setAccountIds.remove(Id.valueOf(accRec.Id));
                            }else{
                                for(Id accId : mapNewParentAccountId.keySet()){
                                    if(mapUltimateParentAccountId.containsKey(accId) && mapUltimateParentAccountId.get(accId) == Id.valueOf(accRec.Id)){
                                        mapUltimateParentAccountId.put(accId,null);
                                        break;
                                    }
                                }
                                setAccountIds.remove(Id.valueOf(accRec.Id));
                            }
                        }else if(objParentAccount!=null){
                            for(Id accId : mapNewParentAccountId.keySet()){
                                if(mapUltimateParentAccountId.containsKey(accId) && mapUltimateParentAccountId.get(accId) == Id.valueOf(accRec.Id)){
                                    mapUltimateParentAccountId.put(accId,objParentAccount.Id);
                                    break;
                                }
                            }
                            setAccountIds.remove(Id.valueOf(accRec.Id));
                            setAccountIds.add(Id.valueOf(objParentAccount.Id));
                        }
                    }
                }else{
                    topLevelAccount = true;
                }
            }else{
                topLevelAccount = true;
            }
            
        }
        return mapUltimateParentAccountId;
    }
    /*public static Map<Id,Id> getUltimateParentAccount(set<Id> setAccountIds){
        Map<Id,Id> mapUltimateParentAccountId = new Map<Id,Id>();
        List<Id> lstAccIds = new List<Id>();
        lstAccIds.addAll(setAccountIds);
        for(Id accId : lstAccIds){
            mapUltimateParentAccountId.put(accId,accId);
        }
        Set<Id> setNewAccounts;
        Map<Id,Id> mapNewParentAccountId;
        Boolean topLevelAccount = false;
        While(!topLevelAccount){
            if(setAccountIds.size()>0){
                setNewAccounts = new Set<Id>();
                setNewAccounts.addAll(setAccountIds);
                mapNewParentAccountId = new Map<Id,Id>();
                mapNewParentAccountId.putAll(mapUltimateParentAccountId);
                List<Account> lstAccounts = [ Select Id, ParentId, Account_Type__c, Parent_Org_Id__c From Account WHERE Id IN: setNewAccounts ];
                if(lstAccounts.size()>0){
                    for(Account accRec : lstAccounts){
                        if(accRec.Parent_Org_Id__c != null && accRec.Id != Id.valueOf(accRec.Parent_Org_Id__c)){
                            for(Id accId : mapNewParentAccountId.keySet()){
                                if(mapUltimateParentAccountId.containsKey(accId) && mapUltimateParentAccountId.get(accId) == Id.valueOf(accRec.Id)){
                                    mapUltimateParentAccountId.put(accId,accRec.Parent_Org_Id__c);
                                }
                            }
                            setAccountIds.remove(Id.valueOf(accRec.Id));
                            setAccountIds.add(Id.valueOf(accRec.Parent_Org_Id__c));
                        }else if(accRec.ParentId != null){
                            for(Id accId : mapNewParentAccountId.keySet()){
                                if(mapUltimateParentAccountId.containsKey(accId) && mapUltimateParentAccountId.get(accId) == Id.valueOf(accRec.Id)){
                                    mapUltimateParentAccountId.put(accId,accRec.ParentId);
                                    break;
                                }
                            }
                            setAccountIds.remove(Id.valueOf(accRec.Id));
                            setAccountIds.add(Id.valueOf(accRec.ParentId));
                        }else if(accRec.ParentId == null){
                            if(accRec.Account_Type__c == 'Org'){
                                for(Id accId : mapNewParentAccountId.keySet()){
                                    if(mapUltimateParentAccountId.containsKey(accId) && mapUltimateParentAccountId.get(accId) == Id.valueOf(accRec.Id)){
                                        mapUltimateParentAccountId.put(accId,accRec.Id);
                                        break;
                                    }
                                }
                            }
                            setAccountIds.remove(Id.valueOf(accRec.Id));
                        }else{
                            for(Id accId : mapNewParentAccountId.keySet()){
                                if(mapUltimateParentAccountId.containsKey(accId) && mapUltimateParentAccountId.get(accId) == Id.valueOf(accRec.Id)){
                                    mapUltimateParentAccountId.put(accId,null);
                                    break;
                                }
                            }
                            setAccountIds.remove(Id.valueOf(accRec.Id));
                        }
                    }
                }else{
                    topLevelAccount = true;
                }
            }else{
                topLevelAccount = true;
            }
        }
        return mapUltimateParentAccountId;
    }
    
    public static Map<Id,Account> getUltimateParentAccounts(set<Id> setAccountIds,List<String> accountFields){
        Map<Id,Account> mapUltimateAccounts = new Map<Id,Account>();
        Map<Id,Id> mapUltimateParentAccountId = new Map<Id,Id>();
        List<Id> lstAccIds = new List<Id>();
        lstAccIds.addAll(setAccountIds);
        for(Id accId : lstAccIds){
            mapUltimateParentAccountId.put(accId,accId);
        }
        Set<Id> setNewAccounts;
        Map<Id,Id> mapNewParentAccountId;
        Boolean topLevelAccount = false;
        While(!topLevelAccount){
            if(setAccountIds.size()>0){
                setNewAccounts = new Set<Id>();
                setNewAccounts.addAll(setAccountIds);
                mapNewParentAccountId = new Map<Id,Id>();
                mapNewParentAccountId.putAll(mapUltimateParentAccountId);
                //List<Account> lstAccounts = [ Select Id, ParentId, Account_Type__c, Parent_Org_Id__c, :String.join(accountFields,',') From Account WHERE Id IN: setNewAccounts ];
                String query = 'Select Id, ParentId, Account_Type__c, Parent_Org_Id__c, '+String.join(accountFields,',')+' From Account WHERE Id IN: setNewAccounts'; 
                Debug.log('OH Query::'+query);
                List<Account> lstAccounts =(List<Account>) Database.query(query) ;
                if(lstAccounts.size()>0){
                    for(Account accRec : lstAccounts){
                        if(accRec.Parent_Org_Id__c != null && accRec.Id != Id.valueOf(accRec.Parent_Org_Id__c)){
                            for(Id accId : mapNewParentAccountId.keySet()){
                                if(mapUltimateParentAccountId.containsKey(accId) && mapUltimateParentAccountId.get(accId) == Id.valueOf(accRec.Id)){
                                    mapUltimateParentAccountId.put(accId,accRec.Parent_Org_Id__c);
                                }
                            }
                            setAccountIds.remove(Id.valueOf(accRec.Id));
                            setAccountIds.add(Id.valueOf(accRec.Parent_Org_Id__c));
                        }else if(accRec.ParentId != null){
                            for(Id accId : mapNewParentAccountId.keySet()){
                                if(mapUltimateParentAccountId.containsKey(accId) && mapUltimateParentAccountId.get(accId) == Id.valueOf(accRec.Id)){
                                    mapUltimateParentAccountId.put(accId,accRec.ParentId);
                                    break;
                                }
                            }
                            setAccountIds.remove(Id.valueOf(accRec.Id));
                            setAccountIds.add(Id.valueOf(accRec.ParentId));
                        }else if(accRec.ParentId == null){
                            if(accRec.Account_Type__c == 'Org'){
                                for(Id accId : mapNewParentAccountId.keySet()){
                                    if(mapUltimateParentAccountId.containsKey(accId) && mapUltimateParentAccountId.get(accId) == Id.valueOf(accRec.Id)){
                                        mapUltimateParentAccountId.put(accId,accRec.Id);
                                        mapUltimateAccounts.put(accId,accRec);
                                        break;
                                    }
                                }
                            }
                            setAccountIds.remove(Id.valueOf(accRec.Id));
                        }else{
                            for(Id accId : mapNewParentAccountId.keySet()){
                                if(mapUltimateParentAccountId.containsKey(accId) && mapUltimateParentAccountId.get(accId) == Id.valueOf(accRec.Id)){
                                    mapUltimateParentAccountId.put(accId,null);
                                    mapUltimateAccounts.put(accId,null);
                                    break;
                                }
                            }
                            setAccountIds.remove(Id.valueOf(accRec.Id));
                        }
                    }
                }else{
                    topLevelAccount = true;
                }
            }else{
                topLevelAccount = true;
            }
        }
        return mapUltimateAccounts;
    }*/
    
    public static Map<Id,Account> getUltimateParents(set<Id> setAccountIds,List<String> accountFields){
        List<String> lstFields = new List<String>();
        accountFields.add('Id');
        accountFields.add('Account_Type__c');
        for(Integer iIndex=0; iIndex<5; iIndex++){
            String field='';
            for(Integer jIndex=iIndex; jIndex>=0; jIndex--){
                field += 'Parent.';
            }
            for(String fieldName :accountFields){
                lstFields.add(field+fieldName);
            }
        }
        Debug.Log('lstFields---'+lstFields);
        Map<Id,Account> mapUltimateAccounts = new Map<Id,Account>();
        Map<Id,Id> mapUltimateParentAccountId = new Map<Id,Id>();
        for(Id accId : setAccountIds){
            mapUltimateParentAccountId.put(accId,accId);
        }
        Set<Id> setNewAccounts;
        Map<Id,Id> mapNewParentAccountId;
        Boolean topLevelAccount = false;
        While(!topLevelAccount){
            if(setAccountIds.size()>0){
                setNewAccounts = new Set<Id>();
                setNewAccounts.addAll(setAccountIds);
                mapNewParentAccountId = new Map<Id,Id>();
                mapNewParentAccountId.putAll(mapUltimateParentAccountId);
                String query = 'Select '+String.join(accountFields,',')+', '+String.join(lstFields,',')+' From Account WHERE Id IN: setNewAccounts'; 
                List<Account> lstAccounts =(List<Account>) Database.query(query);
                if(lstAccounts.size()>0){
                    for(Account accRec : lstAccounts){
                        Account objAccount;
                        Account objParentAccount;
                        if(accRec.Parent == null){
                            objAccount = accRec;
                            objParentAccount = null;
                        }else if(accRec.Parent != null && accRec.Parent.Parent == null){
                            objAccount = accRec.Parent;
                            objParentAccount = null;
                        }else if(accRec.Parent.Parent != null && accRec.Parent.Parent.Parent == null){
                            objAccount = accRec.Parent.Parent;
                            objParentAccount = null;
                        }else if(accRec.Parent.Parent.Parent != null && accRec.Parent.Parent.Parent.Parent == null){
                            objAccount = accRec.Parent.Parent.Parent;
                            objParentAccount = null;
                        }else if(accRec.Parent.Parent.Parent.Parent != null && accRec.Parent.Parent.Parent.Parent.Parent == null){
                            objAccount = accRec.Parent.Parent.Parent.Parent;
                            objParentAccount = null;
                        }else if(accRec.Parent.Parent.Parent.Parent.Parent != null){
                            objAccount = null;
                            objParentAccount = accRec.Parent.Parent.Parent.Parent.Parent;
                        }
                        if(objAccount != null){
                            if(objAccount.Account_Type__c == 'Org'){
                                for(Id accId : mapNewParentAccountId.keySet()){
                                    if(mapUltimateParentAccountId.containsKey(accId) && mapUltimateParentAccountId.get(accId) == Id.valueOf(accRec.Id)){
                                        mapUltimateParentAccountId.put(accId,objAccount.Id);
                                        mapUltimateAccounts.put(accId,objAccount);
                                        break;
                                    }
                                }
                                setAccountIds.remove(Id.valueOf(accRec.Id));
                            }else{
                                for(Id accId : mapNewParentAccountId.keySet()){
                                    if(mapUltimateParentAccountId.containsKey(accId) && mapUltimateParentAccountId.get(accId) == Id.valueOf(accRec.Id)){
                                        mapUltimateParentAccountId.put(accId,null);
                                        break;
                                    }
                                }
                                setAccountIds.remove(Id.valueOf(accRec.Id));
                            }
                        }else if(objParentAccount != null){
                            for(Id accId : mapNewParentAccountId.keySet()){
                                if(mapUltimateParentAccountId.containsKey(accId) && mapUltimateParentAccountId.get(accId) == Id.valueOf(accRec.Id)){
                                    mapUltimateParentAccountId.put(accId,objParentAccount.Id);
                                    break;
                                }
                            }
                            setAccountIds.remove(Id.valueOf(accRec.Id));
                            setAccountIds.add(Id.valueOf(objParentAccount.Id));
                        }
                    }
                }else{
                    topLevelAccount = true;
                }
            }else{
                topLevelAccount = true;
            }
            
        }
        return mapUltimateAccounts;
    }
    public static String getCleansedName(String strName){
        if(String.isNotBlank(strName)){
            CleansedWrapper cleansedSetting = (CleansedWrapper)JSON.deserialize(Settings.get('AccountCleansingSetting').Data__c, CleansedWrapper.class);
            String cleansedName = strName.toLowerCase();          
            for(String specialChar:cleansedSetting.specialCharacters.split('|')){
                cleansedName = cleansedName.replace(specialChar,'');
            }            
            while(true){
                Boolean isStartsWith = false;
                for(String startsWith:cleansedSetting.starts_with){
                    startsWith = startsWith.toLowerCase();
                    cleansedName = cleansedName.trim(); 
                    if(cleansedName.startsWith(startsWith+' ')){
                        cleansedName = cleansedName.replace(startsWith,'');
                        isStartsWith = true;
                    }
                }
                if(!isStartsWith){
                    break;
                }
            }
            while(true){
                Boolean isEndsWith = false;
                for(String endsWith:cleansedSetting.ends_with){
                    endsWith = endsWith.toLowerCase();                
                    cleansedName = cleansedName.trim();               
                    if(cleansedName.endsWith(' '+endsWith)){
                        cleansedName = cleansedName.replace(endsWith,'');
                        isEndsWith = true;
                    }
                }
                if(!isEndsWith){
                    break;
                }
            }
            cleansedName = cleansedName.replaceAll(' ', '');
            return cleansedName; 
        }
        return null;        
    }
    class CleansedWrapper{
        Set<String> starts_with{get;set;}
        Set<String> ends_with{get;set;}
        String specialCharacters{get;set;}
    }
}