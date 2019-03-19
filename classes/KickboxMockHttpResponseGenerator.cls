/**test
* @Created By   	: Mayuresh Ghodke
* @Created Date 	: 11 Dec'16
* @Issue No.		: ST-684
* @Comment			: Provide API Http mockout result to KickboxVerificationApiHandlerTest apex classes in test method.
Changed By			: Shobhit Gahlot
@Comment			: Changes were made to clean test data and and remove seeAllData=true test
*					: 25-07-2017
*/

@isTest
global class KickboxMockHttpResponseGenerator implements HttpCalloutMock  {
	// Implement this interface method from HttpCalloutMock Apex Class
    global HTTPResponse respond(HTTPRequest req) {
        Setting__c RecordJSONKickboxAPI = Settings.get('KickboxAPI');
        CheckEmailQuality.JsonKickboxAPI objJSONKickboxAPI = new CheckEmailQuality.JsonKickboxAPI();
        Debug.log('In KickboxMockHttpResponseGenerator RecordJSONKickboxAPI :: '+RecordJSONKickboxAPI);
        objJSONKickboxAPI = (CheckEmailQuality.JsonKickboxAPI)JSON.deserialize(RecordJSONKickboxAPI.Data__c, CheckEmailQuality.JsonKickboxAPI.Class);
        Debug.log('In KickboxMockHttpResponseGenerator objJSONKickboxAPI :: '+objJSONKickboxAPI);
        Debug.log('In test method ::');
        Debug.log('In req.getEndpoint() :: '+req.getEndpoint());
        HttpResponse res = new HttpResponse();
        
        //Used in 1991 jobid
        String ContactIdValid = KickboxVerificationTest.ContactIdValid;
        String ContactIdInvalid = KickboxVerificationTest.ContactIdInvalid;
        String LeadIdValid =  KickboxVerificationTest.LeadIdValid;
        String LeadIdInvalid=  KickboxVerificationTest.LeadIdInvalid;

        //For KickboxVerificationApiHandlerForBatch class 1st API request
         if('https://api.kickbox.io/v2/verify-batch/1991?apikey=08322eb22f04597a8dc4fefb0fe5fec1b3e0fd6247b202a6540da75a86f7f54a' == req.getEndpoint()){
            // Create a fake response for step 1
            Debug.log('HttpResponse step 1 ::');
            res.setHeader('Content-Type','text/csv');
            res.setBody('{"id":1991,"name":"Batch API Process - 12-27-2016-02-48-04","created_at":"2016-12-27T14:48:09.000Z","status":"completed","error":null,"download_url":"https://files.kickbox.io/finalBatchRply","stats":{"deliverable":3,"undeliverable":5,"risky":0,"unknown":0,"sendex":0.306,"addresses":8},"duration":7000,"success":true,"message":null}');
            res.setStatusCode(200);
        }
        
        //For KickboxVerificationApiHandlerForBatch class 2nd API request
        if( 'https://files.kickbox.io/finalBatchRply' == req.getEndpoint()){
            Debug.log('HttpResponse step 2 ::');
            // Create a fake response for step 2
            res.setHeader('Content-Type','text/csv');
			//res.setBody('"------WebKitFormBoundaryZOOA0Px9JLybDk9m","column_1","result","reason","role","free","disposable","accept_all","did_you_mean","sendex","email","user","domain"\n"Content-Disposition: form-data; name=""""; filename=""Batch Kickbox Request.csv""","","undeliverable","invalid_email","false","false","false","false","","0","","",""\n"Content-Type: application/octet-stream","","undeliverable","invalid_email","false","false","false","false","","0","","",""\n"Id","Email","undeliverable","invalid_email","false","false","false","false","","0","email","",""\n"00Q8A000001W834UAC","ravi_4@example.com","undeliverable","no_connect","false","false","false","false","","0","ravi_4@example.com","ravi_4","example.com"\n"00Q8A000001kpOsUAI","john.smith1997@example.com","undeliverable","no_connect","false","false","false","false","","0","john.smith1997@example.com","john.smith1997","example.com"\n"0038A000004AUhkQAG","dipak@gmail.com","undeliverable","rejected_email","false","true","false","false","","0","dipak@gmail.com","dipak","gmail.com"\n"0038A000003wbAKQAY","miteshkumar.shevale112@enzigma.com","risky","low_deliverability","false","false","false","true","","0.676","miteshkumar.shevale112@enzigma.com","miteshkumar.shevale112","enzigma.com"\n"------WebKitFormBoundaryZOOA0Px9JLybDk9m--","","undeliverable","invalid_email","false","false","false","false","","0","","",""');
            res.setBody('"------WebKitFormBoundaryk1wmHlThb6ojvNiU","column_1","column_2","result","reason","role","free","disposable","accept_all","did_you_mean","sendex","email","user","domain"\n"Content-Disposition: form-data","name=""""","filename=""Test Data- Batch.csv""","undeliverable","invalid_email","false","false","false","false","","0","name=""""","",""\n"Content-Type: application/octet-stream","","","undeliverable","invalid_email","false","false","false","false","","0","","",""\n"Id","Email","","undeliverable","invalid_email","false","false","false","false","","0","email","",""\n"'+ContactIdValid+'","testContactKickbx1@enzigma.com","","risky","low_deliverability","false","false","false","true","","0.659","testcontactkickbx1@enzigma.com","testcontactkickbx1","enzigma.com"\n"'+ContactIdInvalid+'","testContactKickbx2@example.com","","undeliverable","no_connect","false","false","false","false","","0","testcontactkickbx2@example.com","testcontactkickbx2","example.com"\n"'+LeadIdValid+'","testlead1@enzigma.com","","risky","low_deliverability","false","false","false","true","","0.693","testlead1@enzigma.com","testlead1","enzigma.com"\n"'+LeadIdInvalid+'","testlead2@example.com","","undeliverable","no_connect","false","false","false","false","","0","testlead2@example.com","testlead2","example.com"\n"------WebKitFormBoundaryk1wmHlThb6ojvNiU--","","","undeliverable","invalid_email","false","false","false","false","","0","","",""');
            res.setStatusCode(200);
        }
        
        //For CheckEmailQuality all scenarios class 1st API request
        if('https://api.kickbox.io/v2/verify-batch?apikey=08322eb22f04597a8dc4fefb0fe5fec1b3e0fd6247b202a6540da75a86f7f54a' == req.getEndpoint()){
            // Create a fake response for step 1
            Debug.log('HttpResponse step 1 test for CheckEmailQuality::');
            res.setHeader('Content-Type','text/csv');
            res.setBody('{"id":1990,"name":"Batch API Process - 12-27-2016-02-48-04","created_at":"2016-12-27T14:48:09.000Z","status":"completed","error":null,"download_url":"https://files.kickbox.io/finalRply","stats":{"deliverable":3,"undeliverable":5,"risky":0,"unknown":0,"sendex":0.306,"addresses":8},"duration":7000,"success":true,"message":null}');
            res.setStatusCode(200);
        }
        
        //1. For KickboxVerificationApiHandler class 1st API request contains data for queueKickBoxApiRequest used in verifyQueueKickNoxApiRequestClassSendKickboxApiRequestQueueMethod of KickboxVerificationTest  
        if('https://api.kickbox.io/v2/verify-batch/1994?apikey=08322eb22f04597a8dc4fefb0fe5fec1b3e0fd6247b202a6540da75a86f7f54a' == req.getEndpoint()){
            // Create a fake response for step 1
            Debug.log('HttpResponse step 1 ::');
            res.setHeader('Content-Type','text/csv');
            res.setBody('{"id":1994,"name":"Batch API Process - 12-27-2016-02-48-04","created_at":"2016-12-27T14:48:09.000Z","status":"completed","error":null,"download_url":"https://files.kickbox.io/finalRply","stats":{"deliverable":3,"undeliverable":5,"risky":0,"unknown":0,"sendex":0.306,"addresses":8},"duration":7000,"success":true,"message":null}');
            res.setStatusCode(200);
        }
        //For KickboxVerificationApiHandler class 2nd API request
        if( 'https://files.kickbox.io/finalRply' == req.getEndpoint()){
            Debug.log('HttpResponse step 2 ::');
            // Create a fake response for step 2
            res.setHeader('Content-Type','text/csv');
            String userId = KickboxVerificationTest.userId;
            String buildingId = KickboxVerificationTest.buildingId;
            if(userId.length() == 18){
                userId = userId.substring(0,userId.length()-3);
            }
            if(buildingId.length() == 18){
                buildingId = buildingId.substring(0,buildingId.length()-3);
            }
            //debug.log('buildingId in generator buildingId ::'+buildingId);
            //debug.log('user in generator userId::'+userId);
            res.setBody('"------WebKitFormBoundaryaTu4kM3wyEwTxbWP","column_1","column_2","column_3","column_4","column_5","column_6","column_7","column_8","column_9","column_10","column_11","column_12","column_13","column_14","column_15","result","reason","role","free","disposable","accept_all","did_you_mean","sendex","email","user","domain"\n"Content-Disposition: form-data","name=""""","filename=""Test Data- Kickbox Staging.csv""","","","","","","","","","","","","","","undeliverable","invalid_email","false","false","false","false","","0","filename=""test data- kickbox staging.csv""","",""\n"Content-Type: application/vnd.ms-excel","","","","","","","","","","","","","","","","undeliverable","invalid_email","false","false","false","false","","0","","",""\n"First Name","Last Name","EMAIL","Company","Phone","Locations Interested","Lead Source","Lead Source Detail","Generate Journey","Status","Number of Desks 2016","Last Engage Email Sent","CallRail Answered","Event Date Needed","Lead Owner","Building Interested In","undeliverable","invalid_email","false","false","false","false","","0","email","",""\n"Wework","Kickbox1","Test1@enzigma.com","Enzigma","5658565555","LA-Gas Tower","wework.com","Book A Tour Form","TRUE","Open","6","10/14/2011 11:46 AM","TRUE","12/27/2009","'+userId+'","'+buildingId+'","risky","low_deliverability","false","false","false","true","","0.73","test1@enzigma.com","test1","enzigma.com"\n"Wework","Kickbox2","Test2@enzigma.com","Enzigma","5658565555","LA-Gas Tower","wework.com","Book A Tour Form","TRUE","Open","6","10/14/2011 11:46 AM","TRUE","hjghfj","'+userId+'","'+buildingId+'","risky","low_deliverability","false","false","false","true","","0.655","test2@enzigma.com","test2","enzigma.com"\n"Wework","Kickbox3","Test3@enzigma.com","Enzigma","5658565555","LA-Gas Tower","wework.com","Book A Tour Form","TRUE","Open","6","lhhl","TRUE","12/27/2009","'+userId+'","'+buildingId+'","risky","low_deliverability","false","false","false","true","","0.655","test3@enzigma.com","test3","enzigma.com"\n"Wework","Kickbox4","Test4@example.com","Enzigma","5658565555","LA-Gas Tower","wework.com","Book A Tour Form","TRUE","Open","6","10/14/2011 11:46 AM","TRUE","12/27/2009","'+userId+'","'+buildingId+'","undeliverable","no_connect","false","false","false","false","","0","test4@example.com","test4","example.com"\n"Wework","Kickbox5","Test5@enzigma.com","","5658565555","LA-Gas Tower","wework.com","Book A Tour Form","TRUE","Open","6","10/14/2011 11:46 AM","TRUE","12/27/2009","'+userId+'","'+buildingId+'","risky","low_deliverability","false","false","false","true","","0.655","test5@enzigma.com","test5","enzigma.com"\n"Wework","Kickbox6","Test6@enzigma.com","Enzigma","5658565555","LA-Gas Tower","","Book A Tour Form","TRUE","Open","6","10/14/2011 11:46 AM","TRUE","12/27/2009","'+userId+'","'+buildingId+'","risky","low_deliverability","false","false","false","true","","0.655","test6@enzigma.com","test6","enzigma.com"\n"Wework","Kickbox1","Test7@enzigma.com","Enzigma","5658565555","LA-Gas Tower","wework.com","","TRUE","Open","6","10/14/2011 11:46 AM","TRUE","12/27/2009","","'+buildingId+'","risky","low_deliverability","false","false","false","true","","0.655","test7@enzigma.com","test7","enzigma.com"\n"------WebKitFormBoundaryaTu4kM3wyEwTxbWP--","","","","","","","","","","","","","","","","undeliverable","invalid_email","false","false","false","false","","0","","",""');
           // debug.log('body of responese set ::'+res.getBody());
            res.setStatusCode(200);
        }
        
        
        //1. For KickboxVerificationApiHandler class 1st API request contains data for queueKickBoxApiRequest used in verifysendKickboxApiRequestQueue of KickboxVerificationTest  
        if('https://api.kickbox.io/v2/verify-batch/1995?apikey=08322eb22f04597a8dc4fefb0fe5fec1b3e0fd6247b202a6540da75a86f7f54a' == req.getEndpoint()){
            // Create a fake response for step 1
            Debug.log('HttpResponse step 1 ::');
            res.setHeader('Content-Type','text/csv');
            res.setBody('{"id":1995,"name":"Batch API Process - 12-27-2016-02-48-04","created_at":"2016-12-27T14:48:09.000Z","status":"completed","error":null,"download_url":"https://files.kickbox.io/finalRply1_3","stats":{"deliverable":3,"undeliverable":5,"risky":0,"unknown":0,"sendex":0.306,"addresses":8},"duration":7000,"success":true,"message":null}');
            res.setStatusCode(200);
        }
        //For KickboxVerificationApiHandler class 2nd API request
        if( 'https://files.kickbox.io/finalRply1_3' == req.getEndpoint()){
            Debug.log('HttpResponse step 2 ::');
            // Create a fake response for step 2
            res.setHeader('Content-Type','text/csv');
            String userId = KickboxVerificationTest.userId;
            String buildingId = KickboxVerificationTest.buildingId;
            if(userId.length() == 18){
                userId = userId.substring(0,userId.length()-3);
            }
            if(buildingId.length() == 18){
                buildingId = buildingId.substring(0,buildingId.length()-3);
            }
            res.setBody('"------WebKitFormBoundaryu1xjIoHwzYwA9uop","column_1","column_2","column_3","column_4","column_5","column_6","column_7","column_8","column_9","column_10","column_11","column_12","result","reason","role","free","disposable","accept_all","did_you_mean","sendex","email","user","domain"\n"Content-Disposition: form-data","name=""""","filename=""Test Data- Kickbox Staging.csv""","","","","","","","","","","","undeliverable","invalid_email","false","false","false","false","","0","filename=""test data- kickbox staging.csv""","",""\n"Content-Type: application/vnd.ms-excel","","","","","","","","","","","","","undeliverable","invalid_email","false","false","false","false","","0","","",""\n"First Name","Last Name","EMAIL","Company","Locations Interested","Lead Source","Lead Source Detail","Generate Journey","Status","Event Date Needed","Unomy Updated DateTime","Check Duplicates","Lead Owner","undeliverable","invalid_email","false","false","false","false","","0","email","",""\n"Wework","Kickbox1","Test1@enzigma.com","Enzigma","LA-Gas Tower","wework.com","Book A Tour Form","TRUE","Open","3794994","10/14/2011 11:46 AM","TRUE","'+userId+'","risky","low_deliverability","false","false","false","true","","0.73","test1@enzigma.com","test1","enzigma.com"\n"Wework","Kickbox1","Test2@enzigma.com","Enzigma","LA-Gas Tower","wework.com","Book A Tour Form","TRUE","Open","12/27/2009","93042","FALSE","'+userId+'","risky","low_deliverability","false","false","false","true","","0.655","test2@enzigma.com","test2","enzigma.com"\n"Wework","Kickbox1","Test3@enzigma.com","Enzigma","LA-Gas Tower","wework.com","Book A Tour Form","TRUE","Open","12/27/2009","10/14/2011 11:46 AM","dkmf885","'+userId+'","risky","low_deliverability","false","false","false","true","","0.655","test3@enzigma.com","test3","enzigma.com"\n"Wework","Kickbox1","Test4@enzigma.com","Enzigma","LA-Gas Tower","wework.com","Book A Tour Form","TRUE","Open","12/27/2009","10/14/2011 11:46 AM","FALSE","no65","risky","low_deliverability","false","false","false","true","","0.655","test4@enzigma.com","test4","enzigma.com"\n"Wework","Kickbox1","Test5@enzigma.com","Enzigma","LA-Gas Tower","wework.com","Book A Tour Form","TRUE","Open","12/27/2009","10/14/2011 11:46 AM","FALSE","","risky","low_deliverability","false","false","false","true","","0.655","test5@enzigma.com","test5","enzigma.com"\n"------WebKitFormBoundaryu1xjIoHwzYwA9uop--","","","","","","","","","","","","","undeliverable","invalid_email","false","false","false","false","","0","","",""');
            //debug.log('body of responese set ::'+res.getBody());
            res.setStatusCode(200);
        }
        return res;
    }
}