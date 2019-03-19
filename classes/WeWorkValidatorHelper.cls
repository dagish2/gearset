/************************************************************************************************************************************
    Author 		: 	Ajaysinh Chauhan
    Description : 	

    History:
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE				AUTHOR					DETAIL											Issue No.
    1			08 Feb 2018			Ajaysinh Chauhan		Initial Developement.							-
**************************************************************************************************************************************/
public class WeWorkValidatorHelper {
    public static void createTerritoryStructure(){
        Profile weworkSystemAdmin = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        Map<String,Object> mapRegionSalesManager = new Map<String,Object>();
        mapRegionSalesManager.put('LastName','TestRegionSalesManager');
        mapRegionSalesManager.put('Username','TestRegionSalesManager@weworkexample.com');
        mapRegionSalesManager.put('Email','testregionsalesmanager@weworkexample.com');
        User RegionSalesManager = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, mapRegionSalesManager, true);
        
        Map<String,Object> mapTerritorySalesManager = new Map<String,Object>();
        mapTerritorySalesManager.put('LastName','TestTerritorySalesManager');
        mapTerritorySalesManager.put('Username','TestTerritorySalesManager@weworkexample.com');
        mapTerritorySalesManager.put('Email','testterritorysalesmanager@weworkexample.com');
        User TerritorySalesManager = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, mapTerritorySalesManager, true);
        
        Map<String,Object> mapPortfolioSalesManager = new Map<String,Object>();
        mapPortfolioSalesManager.put('LastName','TestPortfolioSalesManager');
        mapPortfolioSalesManager.put('Username','TestPortfolioSalesManager@weworkexample.com');
        mapPortfolioSalesManager.put('Email','testportfoliosalesmanager@weworkexample.com');
        User PortfolioSalesManager = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, mapPortfolioSalesManager, true);
        
        Map<String,Object> mapConsumerQueueOwner = new Map<String,Object>();
        mapConsumerQueueOwner.put('LastName','TestConsumerQueueOwner');
        mapConsumerQueueOwner.put('Username','TestConsumerQueueOwner@weworkexample.com');
        mapConsumerQueueOwner.put('Email','testconsumerqueueowner@weworkexample.com');
        User ConsumerQueueOwner = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, mapConsumerQueueOwner, true);
        
        Map<String,Object> mapMidmarketQueueOwner = new Map<String,Object>();
        mapMidmarketQueueOwner.put('LastName','TestMidmarketQueueOwner');
        mapMidmarketQueueOwner.put('Username','TestMidmarketQueueOwner@weworkexample.com');
        mapMidmarketQueueOwner.put('Email','testmidmarketqueueowner@weworkexample.com');
        User MidmarketQueueOwner = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, mapMidmarketQueueOwner, true);
        
        Map<String,Object> mapEnterpriseQueueOwner = new Map<String,Object>();
        mapEnterpriseQueueOwner.put('LastName','TestEnterpriseQueueOwner');
        mapEnterpriseQueueOwner.put('Username','TestEnterpriseQueueOwner@weworkexample.com');
        mapEnterpriseQueueOwner.put('Email','testenterprisequeueowner@weworkexample.com');
        User EnterpriseQueueOwner = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, mapEnterpriseQueueOwner, true);
        
        Map<String,Object> mapClusterSalesManager = new Map<String,Object>();
        mapClusterSalesManager.put('LastName','TestClusterSalesManager');
        mapClusterSalesManager.put('Username','TestClusterSalesManager@weworkexample.com');
        mapClusterSalesManager.put('Email','testclustersalesmanager@weworkexample.com');
        User ClusterSalesManager = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, mapClusterSalesManager, true);
        
        Map<String,Object> mapClusterSalesLead = new Map<String,Object>();
        mapClusterSalesLead.put('LastName','TestClusterSalesLead');
        mapClusterSalesLead.put('Username','TestClusterSalesLead@weworkexample.com');
        mapClusterSalesLead.put('Email','testclustersaleslead@weworkexample.com');
        User ClusterSalesLead = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, mapClusterSalesLead, true);
        
        Map<String,Object> mapCommunitySalesLead = new Map<String,Object>();
        mapCommunitySalesLead.put('LastName','TestCommunitySalesLead');
        mapCommunitySalesLead.put('Username','TestCommunitySalesLead@weworkexample.com');
        mapCommunitySalesLead.put('Email','testcommunitysaleslead@weworkexample.com');
        User CommunitySalesLead = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, mapCommunitySalesLead, true);
        
        Region__c regn = new Region__c(Name='Test Region',Region__c='Test Region',Regional_Sales_Manager__c=RegionSalesManager.Id);
        insert regn;
        System.assert(regn.Id!=null, 'Region not inserted');
        
        Territory__c tertry = new Territory__c(Name='Test Territory',Territory__c='Test Territory',RegionID__c=regn.Id,Territory_Sales_Manager__c=TerritorySalesManager.Id);
        insert tertry;
        System.assert(tertry.Id!=null, 'Territory not inserted');
        
        Market__c mrkt = new Market__c(Name='Delhi',Portfolio__c='Delhi',TerritoryId__c=tertry.Id,Portfolio_Sales_Manager__c=PortfolioSalesManager.Id);
        insert mrkt;
        System.assert(mrkt.Id!=null, 'Portfolio not inserted');
        
        Account_Queue__c consumerQueue = new Account_Queue__c(Account_Record_Type__c='Consumer',Market__c='Delhi',Is_Queue_Active__c=true,Portfolio__c=mrkt.Id,Member__c=ConsumerQueueOwner.Id);
        insert consumerQueue;
        System.assert(consumerQueue.Id!=null, 'Consumer queue not inserted');
        
        Account_Queue__c midmarketQueue = new Account_Queue__c(Account_Record_Type__c='Mid Market',Market__c='Delhi',Is_Queue_Active__c=true,Portfolio__c=mrkt.Id,Member__c=MidmarketQueueOwner.Id);
        insert midmarketQueue;
        System.assert(midmarketQueue.Id!=null, 'Midmarket queue not inserted');
        
        Account_Queue__c enterpriseQueue = new Account_Queue__c(Account_Record_Type__c='Enterprise Solutions',Market__c='Delhi',Is_Queue_Active__c=true,Portfolio__c=mrkt.Id,Member__c=EnterpriseQueueOwner.Id);
        insert enterpriseQueue;
        System.assert(enterpriseQueue.Id!=null, 'Enterprise queue not inserted');
        
        Cluster__c clstr = new Cluster__c(Name='Test Cluster',Cluster_Sales_Manager__c=ClusterSalesManager.Id,Sales_Lead__c=ClusterSalesLead.Id);
        insert clstr;
        System.assert(clstr.Id!=null, 'Cluster not inserted');
        
        Building__c bldng = new Building__c(Name='Test Building Tour',Community_Lead__c = CommunitySalesLead.Id, Cluster__c=clstr.Id,Market__c=mrkt.Id,UUID__c=UUIDHandler.generateVersion4());
        insert bldng;
        Debug.Log('Inserted Building'+[Select Id,Name,Cluster__c,Cluster__r.Name from Building__c]);
        System.assert(bldng.Id!=null, 'Building not inserted');
        
        Tour_Schedule__c tour_Schedule = new Tour_Schedule__c(
            Building__c = bldng.Id,
            Simultaneous_Tours__c = '2',
            Tour_Spacing__c = 'Hour',
            Maximum_Tour_Days__c = 1
        );
        insert tour_Schedule;
        System.assert(tour_Schedule.Id!=null, 'Tour schedule not inserted');
        
        insert new Tour_Open_Hour__c[]{
            new Tour_Open_Hour__c(
                weekday__c = 'Monday',
                start_time__c = '8:00AM',
                end_time__c = '8:00PM',
                Tour_Schedule__c = tour_Schedule.id,
                Building__c = bldng.Id
            ),
            new Tour_Open_Hour__c(
                weekday__c = 'Tuesday',
                start_time__c = '8:00AM',
                end_time__c = '8:00PM',
                Tour_Schedule__c = tour_Schedule.id,
                Building__c = bldng.Id
            ),
            new Tour_Open_Hour__c(
                weekday__c = 'Wednesday',
                start_time__c = '8:00AM',
                end_time__c = '8:00PM',
                Tour_Schedule__c = tour_Schedule.id,
                Building__c = bldng.Id
            ),
            new Tour_Open_Hour__c(
                weekday__c = 'Thursday',
                start_time__c = '8:00AM',
                end_time__c = '8:00PM',
                Tour_Schedule__c = tour_Schedule.id,
                Building__c = bldng.Id
            ),
            new Tour_Open_Hour__c(
                weekday__c = 'Friday',
                start_time__c = '8:00AM',
                end_time__c = '8:00PM',
                Tour_Schedule__c = tour_Schedule.id,
                Building__c = bldng.Id
            ),
            new Tour_Open_Hour__c(
                weekday__c = 'Saturday',
                start_time__c = '8:00AM',
                end_time__c = '8:00PM',
                Tour_Schedule__c = tour_Schedule.id,
                Building__c = bldng.Id
            ),
            new Tour_Open_Hour__c(
                weekday__c = 'Sunday',
                start_time__c = '8:00AM',
                end_time__c = '8:00PM',
                Tour_Schedule__c = tour_Schedule.id,
                Building__c = bldng.Id
            )
        };
    }
    public static Database.SaveResult insertWithAssert(sObject record){
        Database.SaveResult result = Database.insert(record);
        return result;
    }
    public static Database.SaveResult updateWithAssert(sObject record){
		Database.SaveResult result = Database.update(record);
        return result;
    }
    public static Database.SaveResult[] insertListWithAssert( List<sObject> sObjectsList)
    {
        Database.SaveResult[] arrSaveResult = Database.insert( sObjectsList);
        for(Database.SaveResult saveResult : arrSaveResult)
            System.assert( saveResult.isSuccess(),'Object Not Inserted : '+saveResult.getErrors());
        return arrSaveResult;
    }
    public static Database.SaveResult[] updateListWithAssert( List<sObject> sObjectsList)
    {
        Database.SaveResult[] arrUpdateResult = Database.update( sObjectsList);
        for(Database.SaveResult saveResult : arrUpdateResult)
            System.assert( saveResult.isSuccess(),'Object Not Updated : '+ saveResult.getErrors());
        return arrUpdateResult;
    }
    public static Map<String,Object> fillDefaultInboundLeadPayload(Map<String,Object> mapData){
        mapData.put('product_interests',new List<String>{'Office Space'});
        mapData.put('product_line','WeWork');
        mapData.put('locale','US');
        mapData.put('country_code','US');
        mapData.put('tour_date',system.today().addDays(1));
        mapData.put('tour_time','09:00AM');
        mapData.put('account_uuid','cvdsvcds');
        mapData.put('contact_uuid','vcdfsvdfs');
        return mapData;
    }
    
    public static RESTInboundLeadAPI.Response insertInboundLead(Map<String,Object> mapData){
        mapData = WeWorkValidatorHelper.fillDefaultInboundLeadPayload(mapData);
        WWTypes.InboundLead pInboundLead = (WWTypes.InboundLead)JSON.deserializeStrict(JSON.serialize(mapData), WWTypes.InboundLead.class);
        RESTInboundLeadAPI.Response response = RESTInboundLeadAPI.doPost(pInboundLead);
        return response;
    }
    /*public static RESTInboundLead.Response insertInboundLead(Map<String,Object> mapData){
        mapData = WeWorkValidatorHelper.fillDefaultInboundLeadPayload(mapData);
        WWTypes.InboundLead pInboundLead = (WWTypes.InboundLead)JSON.deserializeStrict(JSON.serialize(mapData), WWTypes.InboundLead.class);
        RESTInboundLead.Response response = RESTInboundLead.doPost(pInboundLead);
        return response;
    }*/
    public static RESTAPITourModelsV2.Response bookTour(Map<String,Object> mapData){
       	mapData = WeWorkValidatorHelper.fillDefaultInboundLeadPayload(mapData);
        //RESTAPITourModelsV2.Input pInboundLead = (RESTAPITourModelsV2.Input)JSON.deserializeStrict(JSON.serialize(mapData), RESTAPITourModelsV2.Input.class);
        RestRequest req     = new RestRequest(); 
        RestResponse res    = new RestResponse();        
        req.requestURI = '/api/2/Tour';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(mapData));
        RestContext.request     = req;
        RestContext.response    = res;
        RESTAPI.doPost();
        Debug.log('RestContext.response.responseBody.toString()=>'+RestContext.response.responseBody.toString());
        Map<String, Object> tourResponse = (Map<String, Object>)JSON.deserializeUntyped(RestContext.response.responseBody.toString());
        Debug.log('tourResponse ::'+tourResponse);
        return (RESTAPITourModelsV2.Response)(JSON.deserialize(JSON.serialize(tourResponse.get('result')), RESTAPITourModelsV2.Response.class));
    }
   	/*public static Id getTour(){
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
        mapData.put('tour_building_uuid',objBuilding.UUID__c);
        mapData.put('buildings_interested_uuids',new List<Object>{objBuilding.UUID__c});
        RESTInboundLeadAPI.Response leadResponse = WeWorkValidatorHelper.insertInboundLead(mapData);
        RESTAPIResult tourResponse = WeWorkValidatorHelper.bookTour(mapData);
        Debug.log('tourResponse'+tourResponse);
        Debug.log('tourResponse.result'+tourResponse.result);
        RESTAPITourModelsV2.Response tour_Response = (RESTAPITourModelsV2.Response) tourResponse.result;
        return tour_Response.tour_sfid;
    }*/
    public static void fillTourOutcomeform(Id tourId){
        List<Tour_Outcome__C> lstTour = [select id,status__c from Tour_Outcome__C where id =: tourId];
        lstTour[0].status__c = 'Cancelled';
        update lstTour;
        
    }
}