@isTest
global class ContractEventMockHttpResponseGenerator implements HttpCalloutMock  {
    global HTTPResponse respond(HTTPRequest req) {
        Debug.log('req :: '+req);
        HttpResponse res = new HttpResponse();
        Debug.log('req.getEndpoint() ::'+req.getEndpoint());
        if('https://sales-api-venus.wework.com/v2/abcContractPass/contractUUID/discard' == req.getEndpoint()){
            // Contract Pass
            Debug.log('HttpResponse step 1 ::');
            res.setHeader('Content-Type','text/csv');
            res.setBody('{"meta":{"success":true,"version":"2","httpStatus":200},"result":"064ebdf0-73b5-4b3c-8d66-1d34cf8fff77","params":{"membership_agreement_id":"064ebdf0-73b5-4b3c-8d66-1d34cf8fff77"}}');
            res.setStatusCode(200);
        }
        List<Opportunity> lstOpportunities = [SELECT Id, Name, Billing_Account__r.UUID__c, Primary_Member__r.Email, contract_UUId__c, (SELECT Id, Status__c, Reservable__r.UUID__c FROM Opportunity_Move_Outs__r), (Select Id, Reservable__c, Start_Date__c, Opportunity__c, Monthly_Price__c From Opportunity_Offices__r) FROM Opportunity order by createdDate];
        if('https://sales-api-venus.wework.com/v2/membership_agreements/'+lstOpportunities[2].contract_UUId__c+'/resend' == req.getEndpoint()){
            // Contract Pass
            Debug.log('HttpResponse step 1 ::');
            res.setHeader('Content-Type','text/csv');
            res.setBody('{"meta":{"success":true,"version":"2","httpStatus":200},"result":"064ebdf0-73b5-4b3c-8d66-1d34cf8fff77","params":{"membership_agreement_id":"064ebdf0-73b5-4b3c-8d66-1d34cf8fff77"}}');
            res.setStatusCode(200);
        }
        return res;
    }
}