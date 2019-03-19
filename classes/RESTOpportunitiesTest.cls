@isTest
public class RESTOpportunitiesTest {
    //Dissused with Deepak sir, it's deprecated.
    /*@TestSetup
    public static void setupData(){
        SalesConsoleSettings.createSettings();
    }
    
    public static testmethod void getAccountUUID(){       
        Account acc1 = new Account(
            name = 'Test Account',
            UUID__c = '2807-2018-uuid',
            WW_Synced__c = true,
            WW_Sync_Request__c = false,
            ID_Creation_Status_Code__c = '200'
        );
        insert acc1;
        System.assert(acc1.id != null);
        
        List<Contact> lstContacts = new List<Contact>(); 
        Contact con1 = new Contact(firstname = 'John',lastname = 'Rambo',email = 'johnrambo@rambo.com',accountID = acc1.Id,Status__c = 'active');
        Contact con2 = new Contact(firstname = 'Paul',lastname = 'Rambo',email = 'paulrambo@rambo.com',accountID = acc1.Id,Status__c = 'active');
        lstContacts.add(con1);
        lstContacts.add(con2);
        TestingUtility.insertListWithAssert(lstContacts);
       
        //add contact as primary member
        acc1.Primary_Member__c = con1.Id;
        update acc1;  
        
        List<Building__c> lstBuildings = new List<Building__c>();
        Building__c building1 = new Building__c( Name='b1', uuid__c = 'building1-uuid-28072018');             
        Building__c building2 = new Building__c(Name='b2',uuid__c = 'building2-uuid-28072018');
        lstBuildings.add(building1);  
        lstBuildings.add(building2);
        TestingUtility.insertListWithAssert(lstBuildings);
        
        List<Opportunity> lstOpp = new List<Opportunity>();
        Opportunity opp1 = new Opportunity(
            AccountID 						= acc1.Id,
            CloseDate 						= system.today(),
            Actual_Start_Date__c 	        = system.today(),
            StageName 						= 'Prospect',
            Name 							= 'test Opoortunity',
            Building__c						= building1.Id,
            Primary_Member__c 				= con2.Id,
            Encoded_ID__c					= '10'
        );           
        Opportunity opp2 = new Opportunity(
            AccountID 						= acc1.Id,
            CloseDate 						= system.today(),
            Actual_Start_Date__c 	        = system.today(),
            StageName 						= 'Prospect',
            Name 							= 'test Opoortunity 2',
            Building__c						= building2.Id,
            Primary_Member__c 				= con2.Id
        );
        lstOpp.add(opp1);    
        lstOpp.add(opp2);        
        TestingUtility.insertListWithAssert(lstOpp);
        
        List<Reservable__c> lstreservables = new List<Reservable__c>();        
        Reservable__c res1 = new Reservable__c(Name='r1',Building__c=building1.Id);
        Reservable__c res2 = new Reservable__c(Name='r2',Building__c=building2.Id);
        lstreservables.add(res1);
        lstreservables.add(res2);
        TestingUtility.insertListWithAssert(lstreservables);
        
        List<Opportunity_Reservable__c> lstOppReservables = new List<Opportunity_Reservable__c>(); 
        Opportunity_Reservable__c oppReservable1 = new Opportunity_Reservable__c(Reservable__c=res1.Id, Opportunity__c=opp1.Id);
        Opportunity_Reservable__c oppReservable2 = new Opportunity_Reservable__c(Reservable__c=res2.Id, Opportunity__c=opp2.Id);
        lstOppReservables.add(oppReservable1);
        lstOppReservables.add(oppReservable2);
        
        lstOpp[0].StageName = 'Closing';
        lstOpp[1].StageName = 'Closing';     
        
        Test.startTest(); 
        Database.update(lstOpp,false);
        
        RestRequest req 	= new RestRequest(); 
        RestResponse res 	= new RestResponse();
        req.requestURI = System.URL.getSalesforceBaseURL().getHost() + '/' + acc1.UUID__c;
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        RESTOpportunities.Response response = RESTOpportunities.doGet();
        Debug.log('response==>'+response);   
        //as trigger method for get merged account uuid is commented 
        system.assertEquals(false, response.success);
        system.assert(String.valueOf(response.message).equalsIgnoreCase('unable to process: Could not find account with UUID 2807-2018-uuid'));
        Test.stopTest();
    } 
    
    public static testmethod void getAccoutUUIDNotFound(){       
        Test.startTest();
        RestRequest req 	= new RestRequest(); 
        RestResponse res 	= new RestResponse();        
        req.requestURI = System.URL.getSalesforceBaseURL().getHost();
        req.httpMethod = 'GET';        
        RestContext.request 	=	req;
        RestContext.response 	= res;
        RESTOpportunities.Response response = RESTOpportunities.doGet();
        Debug.log('response==>'+response);
        system.assert(String.valueOf(response.message).contains('unable to process: Could not find account with UUID'));
        system.assertEquals(false, response.success);
        Test.stopTest();
    }*/
}