/************************************************************************************************************************************
    Author      :   Milanjeet Singh 
    Description :   This class contain methods to update activity in salesforce from ozonetel(External System).

    History:
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1           23 March 2018        ---                    Initial Developement
**************************************************************************************************************************************/
@RestResource(urlMapping='/Ozonetel/*')
global class RESTOzonetel {
    @HttpPost
    global static RESTOzonetel.Response doPost() {
        Debug.Log('Inside Post Ozonetel Api');
        RestRequest req = RestContext.request;
        RESTOzonetel.Ozonetel data = (RESTOzonetel.Ozonetel)System.JSON.deserialize(req.requestBody.toString(), RESTOzonetel.Ozonetel.class);
        Debug.Log('Inside Post Ozonetel Api ::'+data);
        RESTOzonetel.Response response = new RESTOzonetel.Response();
        response.setSuccess(new OzonetelHelper().updateActivityFromOzonetel(data));
        return response;
    }
    global class Response {
        public Boolean success;
        public String message;
        public String result;
       	
        public void setSuccess(Object pResult) {
            debug.log('pResult==>'+pResult);
            if(pResult!=null && ((DatabaseResult)pResult).success == true){
                this.success = true;
                this.result = pResult != null ? JSON.serializePretty(pResult) : '';
                this.message = 'Activity Updated on SF';
            }else{
                this.result = pResult != null ? JSON.serializePretty(pResult) : '';
                setFailure(pResult != null ? JSON.serializePretty(pResult) : 'Not Record found to update');
            }
        }
        
        public void setFailure(String pMessage) {
            this.success = false; 
            this.message = pMessage;
        }
    }
    
    //Ozonetell Api 
    global class Ozonetel {
        global String AgentPhoneNumber;
        global String Disposition;
        global String CallerConfAudioFile;
        global String TransferredTo;
        global String Apikey;
        global String Did;
        global String StartTime;
        global String CallDuration;
        global String EndTime;
        global String ConfDuration;
        global String CustomerStatus;
        global String TimeToAnswer;
        global String monitorUCID;
        global String AgentID;
        global String AgentStatus;
        global String Location;
        global String FallBackRule;
        global String CampaignStatus;
        global String CallerID;
        global String Duration;
        global String Status;
        global String AgentUniqueID;
        global String UserName;
        global String HangupBy;
        global String AudioFile;
        global String PhoneName;
        global String TransferType;
        global String DialStatus;
        global String CampaignName;
        global String UUI;
        global String AgentName;
        global String Skill;
        global String DialedNumber;
        global String Type;
        global String Comments;
    }
}