/************************************************************************************************************************************
    Author 		: 	Krishana Tupe	
    Description : 	This class verifies the functionality of person endpoint.
    
    History		:
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION		DATE				AUTHOR					DETAIL
    1			19 June 2018		Priyanka Ambre			Initial Developement
    2			23 June 2018		Krishana Tupe			Update test methods for API versioning
  	3			31 July 2018		Krishana Tupe			Update the test method for Implementation of Person endpoint version 4
**************************************************************************************************************************************/
@isTest
public class RESTAPIPersonV2Tests {
    @testSetup 
    public static void setup() {
        SalesConsoleSettings.createSettings();
    }
    
   /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is verifies the person endpoind functionality when contact sfid is present.
        Created Date        :   31 July 2018     
   **************************************************************************************************************************************/     
    @isTest
    public static void verifyPersonEndpointWhenEmailIsBlank(){
        RESTAPIPersonModelsV2.Input objPerson = new RESTAPIPersonModelsV2.Input();  
        objPerson.email='testemail@example.com';
        objPerson.first_name='test';
        objPerson.last_name='lastName';
        objPerson.lead_source='WeWork.com';
        objPerson.lead_source_detail='Book a Tour Form';
        objPerson.phone='1234567891';        
        RESTAPIResult response = new RESTAPIResult();  
        try{
            RESTAPIPersonV2.managePerson(objPerson);
        }catch(Exception Exp){
            System.debug('Exception ==>'+Exp.getMessage());
            System.assertEquals(Exp.getMessage(),'Email is required.');
        }
    }
           
   /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is verifies the person endpoind functionality when new payload.
        Created Date        :   31 July 2018     
   **************************************************************************************************************************************/  
    @isTest
    public static void verifyPersonEndpointNewPayload(){ 
        RESTAPIPersonModelsV2.Input objPerson = new RESTAPIPersonModelsV2.Input();
        objPerson.company_name='testConpany';
        objPerson.email='testemail31072018@example.com';
        objPerson.first_name='test';
        objPerson.last_name='email31072018';
        objPerson.lead_source='WeWork.com';
        objPerson.lead_source_detail='Book a Tour Form';
        objPerson.phone='1234567891';       
        RESTAPIPersonModelsV2.Response response = new RESTAPIPersonModelsV2.Response();
        response = RESTAPIPersonV2.managePerson(objPerson);
        Debug.log('Response==>'+response);       
        checkAssert(response, false);
    }
    public static void checkAssert(RESTAPIPersonModelsV2.Response response, Boolean isBillingAccount){
        Debug.log('checkAssert response =='+response);
        System.assert(response != null);
        System.assert(response.account_sfid != null);
        System.assert(response.contact_sfid != null);
        if(isBillingAccount){
            System.assert(response.billing_account_sfid != null);
        }else{
            System.assert(response.billing_account_sfid == null);
        }
    }
    
   /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is verifies the person endpoind functionality when new payload bu contact exist with email.
        Created Date        :   31 July 2018     
   **************************************************************************************************************************************/  
    @isTest
    public static void verifyPersonEndpointContactExistWithEmail(){
        Contact conRecord = new Contact(
            firstname  = 'Test',
            lastname   = 'Email31072018',
            email     = 'testemail31072018@example.com',           
            Status__c  = 'active'
        );
        insert conRecord;        
        RESTAPIPersonModelsV2.Input objPerson = new RESTAPIPersonModelsV2.Input();
        objPerson.company_name='testConpany';
        objPerson.email='testemail31072018@example.com';
        objPerson.first_name='test';
        objPerson.last_name='email31072018';
        objPerson.lead_source='WeWork.com';
        objPerson.lead_source_detail='Book a Tour Form';
        objPerson.phone='1234567891';  
        objPerson.type='Employee';
        RESTAPIPersonModelsV2.Response response = new RESTAPIPersonModelsV2.Response();
        response = RESTAPIPersonV2.managePerson(objPerson);
        Debug.log('Response==>'+response);       
        checkAssert(response, false);
    }
    
   /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is verifies the person endpoind functionality when new payload bu contact exist with email.
        Created Date        :   31 July 2018     
   **************************************************************************************************************************************/  
    @isTest
    public static void verifyPersonEndpointLeadExistWithEmail(){        
        Lead leadRecord = new Lead(
            firstname  = 'Test',
            lastname   = 'Email31072018',
            email     = 'testemail31072018@example.com',
            company = 'TestCompany'
        );
        insert leadRecord;  
        
        RESTAPIPersonModelsV2.Input objPerson = new RESTAPIPersonModelsV2.Input();
        objPerson.company_name='testConpany';
        objPerson.email='testemail31072018@example.com';
        objPerson.first_name='test';
        objPerson.last_name='email31072018';
        objPerson.lead_source='WeWork.com';
        objPerson.lead_source_detail='Book a Tour Form';
        objPerson.phone='1234567891';  
        objPerson.type='Employee';
        RESTAPIPersonModelsV2.Response response = new RESTAPIPersonModelsV2.Response();
        response = RESTAPIPersonV2.managePerson(objPerson);
        Debug.log('Response==>'+response);       
        checkAssert(response, false);     
        Lead leadRec = [Select Id,Name,Isconverted,convertedContactId,convertedAccountId From Lead Where Id =:leadRecord.Id LIMIT 1];
        System.assert(leadRec.IsConverted);
        System.assertEquals(response.account_sfid,leadRec.ConvertedAccountId);
        System.assertEquals(response.contact_sfid,leadRec.convertedContactId);
    }
    
     /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is verifies the person endpoind functionality when new payload bu contact exist with email and bill null.
        Created Date        :   31 July 2018     
   **************************************************************************************************************************************/  
    @isTest
    public static void verifyPersonEndpointContactExistWithBillNull(){
        RESTAPIPersonModelsV2.Input objPerson = new RESTAPIPersonModelsV2.Input();
        objPerson.company_name='testConpany';
        objPerson.email='testemail31072018@example.com';
        objPerson.first_name='test';
        objPerson.last_name='email31072018';
        objPerson.lead_source='WeWork.com';
        objPerson.lead_source_detail='Book a Tour Form';
        objPerson.phone='1234567891';  
        objPerson.type='Employee';
        RESTAPIPersonModelsV2.Response response = new RESTAPIPersonModelsV2.Response();
        response = RESTAPIPersonV2.managePerson(objPerson);
        Debug.log('Response==>'+response);       
        checkAssert(response, false); 
        
        Contact con = [Select Id,Name,Billing_Account__c From Contact Where Id=:response.contact_sfid LIMIT 1];
        con.Billing_Account__c = null;
        update con;
        
        RESTAPIPersonModelsV2.Input objPerson1 = new RESTAPIPersonModelsV2.Input();
        objPerson1.company_name='testConpany';
        objPerson1.email='testemail31072018@example.com';
        objPerson1.first_name='test';
        objPerson1.last_name='email31072018';
        objPerson1.lead_source='WeWork.com';
        objPerson1.lead_source_detail='Book a Tour Form';
        objPerson1.phone='1234567891';  
        objPerson1.type='Employee';
        RESTAPIPersonModelsV2.Response response1 = new RESTAPIPersonModelsV2.Response();
        try{
            response1 = RESTAPIPersonV2.managePerson(objPerson);
            Debug.log('Response1==>'+response1);   
        }catch(Exception pExp){
            System.debug('Exception ==>'+pExp.getMessage());
            System.assert(pExp.getMessage().contains('is Primary Member on another billing accounts : '));
        } 
    }
    
    /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is verifies the person endpoind functionality when new payload but contact exist with email and billAccount parent null.
        Created Date        :   31 July 2018     
   **************************************************************************************************************************************/  
    @isTest
    public static void verifyPersonEndpointContactExistWithBillParentNull(){
        RESTAPIPersonModelsV2.Input objPerson = new RESTAPIPersonModelsV2.Input();
        objPerson.company_name='testConpany';
        objPerson.email='testemail31072018@example.com';
        objPerson.first_name='test';
        objPerson.last_name='email31072018';
        objPerson.lead_source='WeWork.com';
        objPerson.lead_source_detail='Book a Tour Form';
        objPerson.phone='1234567891';  
        objPerson.type='Employee';
        objPerson.market = 'test Market';
        RESTAPIPersonModelsV2.Response response = new RESTAPIPersonModelsV2.Response();
        response = RESTAPIPersonV2.managePerson(objPerson);     
        checkAssert(response, false);
        
        Billing_Account__c billAccRec = new Billing_Account__c(Name='Test Bill Account');
        TestingUtility.insertWithAssert(billAccRec);
        billAccRec.Parent_Account__c = null;
        update billAccRec;
        
        Contact objContact = new Contact(Id = response.contact_sfid, Billing_Account__c=billAccRec.Id);
        update objContact;
        
        RESTAPIPersonModelsV2.Input objPerson1 = new RESTAPIPersonModelsV2.Input();
        objPerson1.company_name='testConpany';
        objPerson1.email='testemail31072018@example.com';
        objPerson1.first_name='test';
        objPerson1.last_name='email31072018';
        objPerson1.lead_source='WeWork.com';
        objPerson1.lead_source_detail='Book a Tour Form';
        objPerson1.phone='1234567891';  
        objPerson1.type='Employee';
        RESTAPIPersonModelsV2.Response response1 = new RESTAPIPersonModelsV2.Response();        
        response1 = RESTAPIPersonV2.managePerson(objPerson);
        Debug.log('Response1==>'+response1); 
        checkAssert(response1, true);
        System.assertEquals(response1.account_sfid,[Select Id,Name,Parent_Account__c From Billing_Account__c Where Id=:billAccRec.Id LIMIT 1][0].Parent_Account__c);  
        RESTAPI.PayloadDetails payload = new RESTAPI.PayloadDetails();       
        payload.Input = objPerson1 ;
        new RESTAPIPersonV2().executePost(payload); 
        payload.Body='{"company_name":"John Smith Company","email":"john.smith@example.com","first_name":"John","last_name":"Smith","phone":"9146185355","type":"Employee"}';
        Object result = new RESTAPIPersonModelsV2().getMockModel(payload);
        System.assert(result != null);
    }
    
	/************************************************************************************************************************************
        Author              :   Rohit Nimase
        Description         :   This method verifies the person endpoint functionality when new payload comes with type broker
        Created Date        :   2 Jan 2019   
		Issue No.           :   ST-3254
   **************************************************************************************************************************************/  
    @isTest
    public static void verifyPersonEndpointWithTypeBroker(){
        Contact conRecord = new Contact(
            firstname  = 'Test',
            lastname   = 'Email31072018',
            email     = 'testemail31072018@example.com',           
            Status__c  = 'active'
        );
        insert conRecord;        
        RESTAPIPersonModelsV2.Input objPerson = new RESTAPIPersonModelsV2.Input();
        objPerson.company_name = 'testConpany';
        objPerson.email = 'testemail31072018@example.com';
        objPerson.first_name = 'test';
        objPerson.last_name = 'email31072018';
        objPerson.lead_source = 'WeWork.com';
        objPerson.lead_source_detail = 'Book a Tour Form';
        objPerson.phone = '1234567891';  
        objPerson.type = 'Broker';
        objPerson.marketing_consent = 'true';
        objPerson.email_opt_out = 'true';
        RESTAPIPersonModelsV2.Response response = new RESTAPIPersonModelsV2.Response();
        response = RESTAPIPersonV2.managePerson(objPerson);
        Debug.log('Response==>'+response);       
        checkAssert(response, false);
        List<Account> lstAccount = [SELECT Id, Name, Account_SubType__c FROM Account WHERE Id =: response.account_sfid];
        System.assertEquals(True, lstAccount[0].Account_SubType__c.equalsIgnoreCase('broker'));
        
        RESTAPIPersonModelsV2.Input objPerson1 = new RESTAPIPersonModelsV2.Input();
        objPerson1.company_name = 'testCompany2118';
        objPerson1.email = 'testemail2118@example.com';
        objPerson1.first_name = 'test';
        objPerson1.last_name = 'email2118';
        objPerson1.lead_source = 'WeWork.com';
        objPerson1.lead_source_detail = 'Book a Tour Form';
        objPerson1.phone = '9734567891';  
        objPerson1.type = 'Broker';
        objPerson1.marketing_consent = 'true';
        objPerson1.email_opt_out = 'true';
        RESTAPIPersonModelsV2.Response response1 = new RESTAPIPersonModelsV2.Response();
        response1 = RESTAPIPersonV2.managePerson(objPerson1);
        Debug.log('Response==>'+response1);       
        checkAssert(response1, false);
        lstAccount = [SELECT Id, Name, Account_SubType__c FROM Account WHERE Id =: response1.account_sfid];
        System.assertEquals(True, lstAccount[0].Account_SubType__c.equalsIgnoreCase('broker'));
    }   
}