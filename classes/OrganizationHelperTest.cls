@isTest
public class OrganizationHelperTest {
    
    @testSetup
    public static void initData(){
        SalesConsoleSettings.createSettings();
        WeWorkValidatorHelper.createTerritoryStructure();
    }
    
    public static testMethod void verifyGetRelatedOrgWhenPassListOfRecordOfLead(){
        
        Account orgAccount1 = TestingUtility.createAccount('strAccountName', false);
        orgAccount1.Account_Type__c = 'Org'; 
        orgAccount1.Unomy_Company_ID__c = 1234 ;
        orgAccount1.Unomy_Company_Name__c = 'test company1';
        orgAccount1.Cleansed_Account_Name__c = 'test company cleansed';
        Database.insert(orgAccount1, false);
        System.assert(orgAccount1.id != null);
        System.debug('orgAccount1');
        
        List<Lead> lstLead = new List<Lead>();
        Lead objLead = new Lead();        
        objLead.LastName = 'lastName';       
        objLead.Email = 'email@enazigma.com'; 
        objLead.Phone = '1234567891';
        objLead.Company = 'Test Company';
        objLead.Locations_Interested__c='Test Building Tour';
        objLead.Unomy_Company_ID__c = 1234 ;
        objLead.LeadSource= 'Broker';        
        objLead.Lead_Source_Detail__c = 'Broker1';
        lstLead.add(objLead);
        
        Lead objLead2 = new Lead();        
        objLead2.LastName = 'lastName2';       
        objLead2.Email = 'email2@enazigma.com'; 
        objLead2.Phone = '1234567891';
        objLead2.Company = 'Test Company2';
        objLead2.Unomy_Company_ID__c = 1234 ;
        objLead2.Locations_Interested__c='Test Building Tour';
        objLead2.LeadSource= 'Broker';
        objLead2.Lead_Source_Detail__c = 'Broker1';
        lstLead.add(objLead2);  
        
        Lead objLead3 = new Lead();        
        objLead3.LastName = 'lastName3';       
        objLead3.Email = 'email3@enazigma.com'; 
        objLead3.Phone = '1234567891';
        objLead3.Company = 'Test Company3';
        objLead3.Unomy_Company_ID__c = 1234 ;
        objLead3.Locations_Interested__c='Test Building Tour';
        objLead3.LeadSource= 'Broker';
        objLead3.Lead_Source_Detail__c = 'Broker1';
        lstLead.add(objLead3);
        
        insert lstLead;
        for(integer i=0;i<lstLead.size();i++){
            system.assert(lstLead[i]!=null,'Lead Insertion Error on '+lstLead[i]);
        }
        
        Map<Id,Id> mapOrgIds = OrganizationHelper.findRelatedOrg(lstLead); 
        System.debug('findorg Result==>'+OrganizationHelper.findRelatedOrg(lstLead));
        
        System.assert(mapOrgIds.values()[0]==orgAccount1.Id,'Org is not mapped properly');
        System.assert(mapOrgIds.values()[1]==orgAccount1.Id, 'Org is not mapped properly');
        System.assert(mapOrgIds.values()[2]==orgAccount1.Id, 'Org is not mapped properly'); 
    }
    
    public static testMethod void verifyGetRelatedOrgWhenPassSingleRecordOfLead(){
        
        Account orgAccount1 = TestingUtility.createAccount('strAccountName', false);
        orgAccount1.Account_Type__c = 'Org'; 
        orgAccount1.Unomy_Company_ID__c = 1234 ;
        orgAccount1.Unomy_Company_Name__c = 'test company1';
        orgAccount1.Cleansed_Account_Name__c = 'test company cleansed';
        Database.insert(orgAccount1, false);
        System.assert(orgAccount1.id != null);
        System.debug('orgAccount1');        
        
        Lead objLead = new Lead();        
        objLead.LastName = 'lastName';       
        objLead.Email = 'email@enazigma.com'; 
        objLead.Phone = '1234567891';
        objLead.Company = 'Test Company';
        objLead.Locations_Interested__c='Test Building Tour';
        objLead.Unomy_Company_ID__c = 1234 ;
        objLead.LeadSource= 'Broker';        
        objLead.Lead_Source_Detail__c = 'Broker1';
        insert objLead;
        
        
        Id orgID = OrganizationHelper.findRelatedOrg(objLead); 
        System.debug('find org ID: Result==>'+orgID);
        
        System.assert(orgID==orgAccount1.Id,'Org is not mapped properly');        
    }    
    public static testMethod void verifyGetRelatedOrgWhenPassSingleRecordOfContact(){
        Account orgAccount1 = TestingUtility.createAccount('strAccountName', false);
        orgAccount1.Account_Type__c = 'Org'; 
        orgAccount1.Unomy_Company_ID__c = 1234 ;
        orgAccount1.Unomy_Company_Name__c = 'test company1';
        orgAccount1.Cleansed_Account_Name__c = 'test company cleansed';
        Database.insert(orgAccount1, false);
        System.assert(orgAccount1.id != null);
        System.debug('orgAccount1==>'+orgAccount1.id);
        
        Contact objContact = new Contact();
        objContact.LastName='Krishana';
        objContact.Email = 'Krishna@example.com';        
        objContact.Company__c = 'Test Company';
        objContact.Unomy_Company_ID__c = 1234 ;
        objContact.Unomy_Company_Name__c = 'Test Company' ;
        insert objContact;
        System.assert(objContact.id != null);
        System.debug('objContact==>'+objContact);
        
        Id orgID = OrganizationHelper.findOrCreateRelatedOrg(objContact); 
        System.debug('find org ID: Result==>'+orgID);        
        
        System.assert(orgID==orgAccount1.Id,'Org is not mapped properly');        
    }
    
    public static List<Contact> createContactsWithOrgFinderCriteria(Map<String,Object> mapCriteria,Map<String,Integer> mapNumberOfRecords){
        List<String> lstFieldsOfContactForOrfind = new OrganizationHelper().getListFields('Contact');
        Set<String> setaccessableFields = new set<String>();
        for(string field : lstFieldsOfContactForOrfind){
            setaccessableFields.add(field.toLowerCase());
        }
        setaccessableFields = TestingUtility.getEditableFields(setaccessableFields, 'contact');
        List<Contact> lstContacts = new List<Contact>();
        for(String field : setaccessableFields){
            if(mapCriteria.get(field) != null){
                if(mapNumberOfRecords != null && mapNumberOfRecords.get(field) != null && checkValidList(field, mapCriteria)){
                    List<Object> lstObject = (List<Object>) mapCriteria.get(field);
                    for(Integer index = 0; index < mapNumberOfRecords.get(field); index++){
                        Contact objContact = new Contact();
                        objContact.put(field, lstObject[index]);
                        lstContacts.add(objContact);
                    }
                }else{
                    Contact objContact = new Contact();
                    objContact.put(field, mapCriteria.get(field));
                    lstContacts.add(objContact);
                }
            }
        }
        Debug.log('lstContacts==>'+lstContacts);
        return lstContacts;
    }
    
    public static Boolean checkValidList(String field, Map<String,Object> mapCriteria){
        try{
            List<Object> lstObjects = (List<Object>)mapCriteria.get(field);
            return true;
        }catch(Exception ex){
            debug.log('Exception========'+ex.getMessage());
        }
        return false;
    }
}