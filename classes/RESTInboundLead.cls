@RestResource(urlMapping='/InboundLeadOld/*')
global class RESTInboundLead {
    public Static String leadId;
    public Static String contactId;
    public static WWTypes.InboundLead inboundPayLoad;
    public static List<Id> lstIds ;
    public static Savepoint sp {get;set;}

   /****************************************************************************************************************************
        Author 				: Amol Darekar
        Description  		: This method has all inbound lead business logi it accepts body as a payload from external system through REST api request.
        Last Modified By 	: Krishana Tupe
        Last Modified Date  : 02 May 2018
    *****************************************************************************************************************************/
    @HttpPost
    global static Response doPost(WWTypes.InboundLead body) {
        Debug.log('Limits.getQueries() in InboundLead Transaction Start==>'+Limits.getQueries());
        boolean isInvoker = ApexDebugLog.registerRootInvoker(ApexDebugLog.InvokerType.API, 'RESTInboundLead' + '.doPost()', ApexDebugLog.InvokerType.API);
        Debug.log('Initial isInvoker ==>'+isInvoker);
        Debug.log('ApexDebugLog.isRootInvoker==>'+ApexDebugLog.isRootInvoker(ApexDebugLog.InvokerType.API));
        RESTInboundLead.Response response = new RESTInboundLead.Response();
        try {
            sp = Database.setSavepoint();
            Debug.log('RESTInboundLead body==>' + body);
            inboundPayLoad = body;
            LeadServices objLeadSevice = new LeadServices();
            body.generate_journeys = false;
            set<Id> leadIds = new set<Id>();

            leadIds.add(objLeadSevice.call_insert_lead_by_web(body));
            lstIds = new List<Id>();
            lstIds.addAll(leadIds);
            Debug.log('Inserted leadIds ==>' + leadIds);
            //Call to lead converter second parameter is passed to populate activety type and Status when lead is created from website.
            list<LeadConvertor.LeadResult> lstLeadResult = LeadConvertor.ConvertLeadsToJourneys(leadIds,true);

            if(lstLeadResult != null)
                response.setSuccess('Lead processed!');
            else
                response.setFailure('unable to process the Lead!');
        }catch(Exception pEx) {
            Debug.Log('pEx message---'+pEx.getMessage());
            Debug.Log('pEx stacktrace---'+pEx.getStackTraceString());
            response.setFailure('unable to process: ' + pEx.getMessage() );
            if(sp != null){
                Database.rollback(sp);
            }
            if(ApexDebugLog.isRootInvoker(ApexDebugLog.InvokerType.API)){
                ApexDebugLog.logException(pEx,JSON.serialize(body), 'RESTInboundLead', 'doPost()');
            }

        }
        return response;
    }

    /****************************************************************************************************************************
        Author 				: Sunil Bhosale
        Description  		: This method is used to insert CampaignMember when payload contains campaign_sfid.
        Last Modified By 	: Krishana Tupe
        Last Modified Date  : 02 May 2018
    *****************************************************************************************************************************/
   /* public static void insertCampaignMember(){
        try{
            Debug.log('RESTInboundLead insertCampaignMember inboundPayLoad'+inboundPayLoad);
            CampaignServices objCampaignServices = new CampaignServices();
            if( inboundPayLoad!= null && inboundPayLoad.campaign_sfid != null && inboundPayLoad.campaign_sfid != '' && !inboundPayLoad.campaign_sfid.equalsIgnoreCase('null'))
                objCampaignServices.insertCampaignMember(inboundPayLoad,lstIds);
        }catch(Exception pEx){
            Debug.Log('pEx message---'+pEx.getMessage());
            Debug.Log('pEx stacktrace---'+pEx.getStackTraceString());
            ApexDebugLog.logException(pEx,'', 'RESTInboundLead', 'insertCampaignMember()');
            throw new RESTInboundLeadException('Exception thrown from  of RESTInboundLead.insertCampaignMember()'+pEx);
        }
    }*/


    global class Response {
        public Boolean success;
        public String message;
        public String result;
        public String lead_sfid;
        public String contact_sfid;

        public void setSuccess(Object pResult) {
            this.success = true;
            this.lead_sfid = RESTInboundLead.leadId;
            this.contact_sfid = RESTInboundLead.contactId;
            this.result = pResult != null ? JSON.serializePretty(pResult) : '';
        }

        public void setFailure(String pMessage) {
            this.success = false;
            this.message = pMessage;
        }
    }
    public class RESTInboundLeadException extends Exception{}
}