/************************************************************************************************************************************
    Author 		: 	Ajaysinh Chauhan
    Description : 	Generic class to validate all the business scenarios.

    History:
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE				AUTHOR					DETAIL											Issue No.
    1			08 Feb 2018			Ajaysinh Chauhan		Initial Developement.							-
	2			15 Feb 2018			Milanjeet Singh		    Post Developement.							    -
**************************************************************************************************************************************/
@isTest
public class WeWorkValidator {
    @testSetup
    public static void initData(){
        SalesConsoleSettings.createSettings();
        WeWorkValidatorHelper.createTerritoryStructure();
    }
    public static testMethod void bookTourConsumerTransactional(){
        Map<String,Object> mapData = new Map<String,Object>();
        mapData.put('first_name','John');
        mapData.put('last_name','Smith');
        mapData.put('email','john.smith200192@example.com');
        mapData.put('phone','9168200192');
        mapData.put('company_name','Test Company');
        mapData.put('company_size','5-10 desks');
        mapData.put('lead_source','WeWork.com');
        mapData.put('lead_source_detail','Book a Tour Form');
        Building__c objBuilding = [Select Id,Community_Lead__c,Cluster__r.Sales_Lead__c,UUID__c,Community_Sales_Lead__c From Building__c Where Name='Test Building Tour'][0];
        Debug.Log('RnnobjBuilding'+objBuilding);
        mapData.put('tour_building_uuid',objBuilding.UUID__c);
        mapData.put('buildings_interested_uuids',new List<Object>{objBuilding.UUID__c});
        RESTInboundLeadAPI.Response leadResponse = WeWorkValidatorHelper.insertInboundLead(mapData);
        Debug.Log('RnnleadResponse'+leadResponse);
        WeWorkValidatorAssertions.verifyLeadCreation(mapData);
        System.assertEquals(true,leadResponse.success,'Failed to create inbound lead, Error: '+leadResponse.message);
        Test.startTest();
        RESTAPITourModelsV2.Response tourResponse = WeWorkValidatorHelper.bookTour(mapData);
        Debug.Log('RnntourResponse'+tourResponse);
        Test.stopTest();
        //Debug.log('tourResponse :: '+tourResponse.tour_sfid);
        System.assertNotEquals(null,tourResponse.tour_sfid,'Failed to book a tour, Error: '+leadResponse.message);
        List<Lead> lstLeads = [Select Id,FirstName,OwnerId,LastName,Email,IsConverted,Company,Number_of_Desks_2016__c,Market__c,LeadSource,	Lead_Source_Detail__c,
                               Locations_Interested__c,Interested_in_Number_of_Desks__c,Number_of_Full_Time_Employees__c,Building_Interested_In__c 
                               From Lead Where Email=:String.valueOf(mapData.get('email'))];
        WeWorkValidatorAssertions.verifyLeadConversion(lstLeads);
        Contact objContact = [Select Id,FirstName,LastName,Email,AccountId,OwnerId,RecordType.Name From Contact][0];
        Account objAccount = [Select Id,Name,OwnerId,RecordType.Name From Account Where Name != 'Dummy Lead Conversion Account'][0];
        Opportunity objOpportunity = [Select Id,Name,OwnerId,RecordType.Name,AccountId,Primary_Member__c,Building__c,Building__r.Community_Lead__c,Building__r.Cluster__r.Sales_Lead__c From Opportunity][0];
        Journey__c[] objJourney = [select id,Name,OwnerId,Primary_Email__c,Number_of_Desks_2016__c,Market__c,Locations_Interested__c,Interested_in_Number_of_Desks__c,
                                   Number_of_Full_Time_Employees__c,Building_Interested_In__c,Lead_Source__c,Lead_Source_Detail__c from Journey__c ];
        Task[] lstTask = [Select id,OwnerId,Status,Subject,WhoId,Number_of_Full_Time_Employees__c,Market__c,
                          Product_Line__c,Locations_Interested__c,Lead_Source__c,Lead_Source_Detail__c from task where Email__c =:String.valueOf(mapData.get('email'))]; 
        WeWorkValidatorAssertions.verifyAccountStructure(lstLeads[0],objAccount,objContact,objOpportunity,objBuilding);
        WeWorkValidatorAssertions.verifyAccountAssignments(objAccount,objContact,objOpportunity,objBuilding,'Consumer','Transactional');
        WeWorkValidatorAssertions.verifyChangeChildsRecordType(objAccount,objContact,objOpportunity);
    }	
}