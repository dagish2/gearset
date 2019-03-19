@isTest
public class FieldMappingsHelperTest {  
    @testSetup
    public static void initData(){
        SalesConsoleSettings.createSettings();
        WeWorkValidatorHelper.createTerritoryStructure();
    }
    
   /****************************************************************************************************************************
        Author 				: Ashish Mishra
        Description  		: This test method used to create dynamic mapping When both object Present means already inserted .  
        Created Date		: 12,June 2018
        Last Modified By 	: -
        Last Modified Date  : -
   *****************************************************************************************************************************/
    @isTest
    public static void verifyMappingWhenBothObjectPresent(){
        //Lead
        Lead objLead = new Lead();        
        objLead.LastName = 'lastName';       
        objLead.Email = 'email@enazigma.com'; 
        objLead.Phone = '1234567891';
        objLead.Company = 'Test Company';
        objLead.Locations_Interested__c='Test Building Tour';
        objLead.LeadSource= 'Broker';
        objLead.Lead_Source_Detail__c = 'Broker1';
        Test.startTest();
        insert objLead;
        System.debug('objLead==>'+objLead);
        System.assert(objLead.id!= null);
        
        //Contact
        Contact objContact = new Contact(LastName = 'test', Email = 'test@example.com');
        insert objContact;
        System.assert(objContact.Id != null);
        //Overrite Problem Check it.
        sObject mappedObj = FieldMappingsHelper.getMappings(objLead.id , objContact.Id ,'FieldMappings:LeadToContact');
        System.debug('sobject == '+mappedObj);
        upsert mappedObj;        
        Test.stopTest();
        
        //for assert check
        Lead checkLead = [SELECT LastName,Company,Phone,Email From Lead WHERE LastName='lastName'];
        System.debug('CheckLead==>'+CheckLead);
        Contact checkContact = [SELECT LastName, Company__c,Phone,Email FROM Contact WHERE LastName='test'];
        System.debug('checkContact==>'+checkContact);
        System.assert(objLead.Company==checkContact.Company__c);
        System.debug(checkLead.Company == checkContact.Company__c);		       
    }
    
    
    /****************************************************************************************************************************
        Author 				: Ashish Mishra
        Description  		: This test method used to verify Mapping When Source Object id is passed as argument for mapping and 
							  new destination object is created at the time of mapping.
        Created Date		: 12,June 2018
        Last Modified By 	: -
        Last Modified Date  : -
   *****************************************************************************************************************************/
    @isTest
    public static void verifyMappingWhenSourceIDPresent(){
        //Lead
        Lead objLead = new Lead();        
        objLead.LastName = 'lastName';       
        objLead.Email = 'email125@enazigma.com'; 
        objLead.Phone = '1234567891';
        objLead.Company = 'Test Company';
        objLead.Locations_Interested__c='Test Building Tour';
        Test.startTest();
        insert objLead;
        
        System.debug('objLead==>'+objLead);
        System.assert(objLead!= null);
        
        sObject mappedObj = FieldMappingsHelper.getMappings(objLead.id,'FieldMappings:LeadToContact'); 
        Debug.log('Return obj::==>'+mappedObj);
        upsert mappedObj;
        Test.stopTest();
        
        //for assert check
        Lead checkLead = [SELECT LastName,Company,Phone,Email From Lead WHERE LastName='lastName'];
        System.debug('CheckLead==>'+CheckLead);
        Contact checkContact = [SELECT LastName, Company__c,Phone,Email FROM Contact WHERE LastName='lastName'];
        System.debug('checkContact==>'+checkContact);
        System.assert(objLead.Company==checkContact.Company__c);
        System.debug(checkLead.Company == checkContact.Company__c);
    }
    
   	
   	/****************************************************************************************************************************
        Author 				: Ashish Mishra
        Description  		: This test method used to create dynamic mapping When list of Source Object id pass as argument.
        Created Date		: 12,June 2018
        Last Modified By 	: -
        Last Modified Date  : -
   *****************************************************************************************************************************/
    @isTest
    public static void verifyMappingWhenListOfSourceObjectPresent(){
        //Lead Record List
        List<Lead> lstLead = new List<Lead>();
        Lead objLead1 = new Lead();        
        objLead1.LastName = 'lastName1';       
        objLead1.Email = 'email1@enazigma.com'; 
        objLead1.Phone = '1234567891';
        objLead1.Company = 'Test Company1';
        objLead1.Locations_Interested__c='Test Building Tour';
        objLead1.LeadSource= 'Broker';
        objLead1.Lead_Source_Detail__c = 'Broker1';
        lstLead.add(objLead1);
        
        Lead objLead2 = new Lead();        
        objLead2.LastName = 'lastName2';       
        objLead2.Email = 'email2@enazigma.com'; 
        objLead2.Phone = '8956237415';
        objLead2.Company = 'Test Company2';
        objLead2.Locations_Interested__c='Test Building Tour';
        objLead2.LeadSource= 'Broker';
        objLead2.Lead_Source_Detail__c = 'Broker1';
        lstLead.add(objLead2);
        
        Lead objLead3 = new Lead();        
        objLead3.LastName = 'lastName3';       
        objLead3.Email = 'email3@enazigma.com'; 
        objLead3.Phone = '9856237235';
        objLead3.Company = 'Test Company3';
        objLead3.Locations_Interested__c='Test Building Tour';
        objLead3.LeadSource= 'Broker';
        objLead3.Lead_Source_Detail__c = 'Broker1';
        lstLead.add(objLead3);
        
        Test.startTest();
        insert lstLead;
        
        System.debug('lstLead==>'+lstLead);
        System.assert(lstLead[0].id!= null);
        System.assert(lstLead[1].id!= null);
        System.assert(lstLead[2].id!= null);
        
        //Create List of lead id's 
        List<id> lstLeadIDs = new List<id>();
        for(Lead obj : lstLead)
        {
            lstLeadIDs.add(obj.id);
        }
        System.debug('lstLeadIDs==>'+lstLeadIDs);
        
        Map<Id,sObject> mappedObject = FieldMappingsHelper.getMappings(lstLeadIDs,'FieldMappings:LeadToContact'); 
        System.debug('mappedObject'+mappedObject);
        insert mappedObject.values();
        Test.stopTest();
        
        //for assert check 
        for(Lead CheckLead :[SELECT LastName,Company,Phone,Email From Lead]){
            System.debug('CheckLead==>'+CheckLead);
            Contact checkContact = [SELECT LastName, Company__c,Phone,Email FROM Contact WHERE LastName=:CheckLead.LastName];            
            System.assert(checkLead.Company == checkContact.Company__c);
        }
               
    }
    
   /****************************************************************************************************************************
        Author 				: Ashish Mishra
        Description  		: This test method used to create dynamic mapping When Set of Source Object id pass as argument.
        Created Date		: 12,June 2018
        Last Modified By 	: -
        Last Modified Date  : -
   *****************************************************************************************************************************/
    @isTest
    public static void verifyMappingWhenSetOfSourceObjectPresent(){
        //Lead Record List
        List<Lead> lstLead = new List<Lead>();
        Lead objLead1 = new Lead();        
        objLead1.LastName = 'lastName1';       
        objLead1.Email = 'email1@enazigma.com'; 
        objLead1.Phone = '1234567891';
        objLead1.Company = 'Test Company1';
        objLead1.Locations_Interested__c='Test Building Tour';
        objLead1.LeadSource= 'Broker';
        objLead1.Lead_Source_Detail__c = 'Broker1';
        lstLead.add(objLead1);
        
        Lead objLead2 = new Lead();        
        objLead2.LastName = 'lastName2';       
        objLead2.Email = 'email2@enazigma.com'; 
        objLead2.Phone = '8956237415';
        objLead2.Company = 'Test Company2';
        objLead2.Locations_Interested__c='Test Building Tour';
        objLead2.LeadSource= 'Broker';
        objLead2.Lead_Source_Detail__c = 'Broker1';
        lstLead.add(objLead2);
        
        Lead objLead3 = new Lead();        
        objLead3.LastName = 'lastName3';       
        objLead3.Email = 'email3@enazigma.com'; 
        objLead3.Phone = '9856237235';
        objLead3.Company = 'Test Company3';
        objLead3.Locations_Interested__c='Test Building Tour';
        objLead3.LeadSource= 'Broker';
        objLead3.Lead_Source_Detail__c = 'Broker1';
        lstLead.add(objLead3);
        Test.startTest();
        insert lstLead;
        
        System.debug('lstLead==>'+lstLead);
        System.assert(lstLead[0].id!= null);
        System.assert(lstLead[1].id!= null);
        System.assert(lstLead[2].id!= null);
        
        //Create Set of lead id's 
        Set<id> setLeadIDs = new Set<id>();
        for(Lead obj : lstLead)
        {
            setLeadIDs.add(obj.id);
        }
        System.debug('setLeadIDs==>'+setLeadIDs);
        Map<Id,sObject> mappedObject = FieldMappingsHelper.getMappings(setLeadIDs,'FieldMappings:LeadToContact');
        System.debug('mappedObject::==>'+mappedObject);
        Insert mappedObject.values();       
        Test.stopTest();
        
        //for assert check 
        for(Lead CheckLead :[SELECT LastName,Company,Phone,Email From Lead]){
            System.debug('CheckLead==>'+CheckLead);
            Contact checkContact = [SELECT LastName, Company__c,Phone,Email FROM Contact WHERE LastName=:CheckLead.LastName];            
            System.assert(checkLead.Company == checkContact.Company__c);
        }     
    }    
    
   /****************************************************************************************************************************
        Author 				: Ashish Mishra
        Description  		: This test method used to create dynamic mapping When Source Object id pass as argument and Destination object.
        Created Date		: 12,June 2018
        Last Modified By 	: -
        Last Modified Date  : -
   *****************************************************************************************************************************/
    @isTest
    public static void verifyMappingWhenSourceandDestinationPresent(){
        //Lead
        Lead objLead = new Lead();        
        objLead.LastName = 'lastName5';       
        objLead.Email = 'email5@enazigma.com'; 
        objLead.Phone = '2234567891';
        objLead.Company = 'Test Company5';
        objLead.Locations_Interested__c='Test Building Tour';
        Test.startTest();
        insert objLead;
        
        System.debug('objLead==>'+objLead);
        System.assert(objLead!= null);
        
        Contact objContact = new Contact();
        
        sObject mappedObject = FieldMappingsHelper.getMappings(objLead.id,objContact,'FieldMappings:LeadToContact'); 
        Debug.log('Return obj::==>'+mappedObject);
        Insert mappedObject;
        Test.stopTest();
        
        //for assert check
        Lead checkLead = [SELECT LastName,Company,Phone,Email From Lead WHERE LastName='lastName5'];
        System.debug('CheckLead==>'+CheckLead);
        Contact checkContact = [SELECT LastName, Company__c,Phone,Email FROM Contact WHERE LastName='lastName5'];
        System.debug('checkContact==>'+checkContact);
        System.assert(objLead.Company==checkContact.Company__c);
        System.debug(checkLead.Company == checkContact.Company__c);
        
    }
    
    /*@isTest
    public static void verifyGetMappings6(){
        //Lead Record List
        List<Lead> lstLead = new List<Lead>();
        Lead objLead1 = new Lead();        
        objLead1.LastName = 'lastName1';       
        objLead1.Email = 'email1@enazigma.com'; 
        objLead1.Phone = '1234567891';
        objLead1.Company = 'Test Company1';
        objLead1.LeadSource= 'Broker';
        objLead1.Lead_Source_Detail__c = 'Broker1';
        lstLead.add(objLead1);
        
        Lead objLead2 = new Lead();        
        objLead2.LastName = 'lastName2';       
        objLead2.Email = 'email2@enazigma.com'; 
        objLead2.Phone = '8956237415';
        objLead2.Company = 'Test Company2';
        objLead2.LeadSource= 'Broker';
        objLead2.Lead_Source_Detail__c = 'Broker1';
        lstLead.add(objLead2);
        
        Lead objLead3 = new Lead();        
        objLead3.LastName = 'lastName3';       
        objLead3.Email = 'email3@enazigma.com'; 
        objLead3.Phone = '9856237235';
        objLead3.Company = 'Test Company3';
        objLead3.LeadSource= 'Broker';
        objLead3.Lead_Source_Detail__c = 'Broker1';
        lstLead.add(objLead3);
        
        insert lstLead;
        System.debug('lstLead==>'+lstLead);
        System.assert(lstLead[0].id!= null);
        System.assert(lstLead[1].id!= null);
        System.assert(lstLead[2].id!= null);
        
        
        List<Contact> lstContact = new List<Contact>();
        Contact objContact1 = new Contact();
        objContact1.LastName='testLastName1';
        lstContact.add(objContact1);
        
        Contact objContact2 = new Contact();
        objContact2.LastName='tastLastName2';
        lstContact.add(objContact2);
        
        Contact objContact3 = new Contact();
        objContact3.LastName='tastLastName3';
        lstContact.add(objContact3);
        
        insert lstContact;
        System.debug('lstContact==>'+lstContact);
        System.assert(lstContact[0].id!= null);
        System.assert(lstContact[1].id!= null);
        System.assert(lstContact[2].id!= null);

        sObject obj = FieldMappingsHelper.getMappings(objLead.id,objContact.id,'FieldMappings:LeadToContact'); 
        Debug.log('Return obj::==>'+obj);
		Map<id,id> =
    }
    */
    
}