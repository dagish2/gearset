/************************************************************************************************************************************
	Author		: 	Samadhan Kadam
	Description : 	QueueReservableHold

	History:
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE	        	AUTHOR                       DETAIL
	1	    	1 December 2017	  	Samadhan Kadam               Initial Developement
**************************************************************************************************************************************/
public class QueueReservableHold implements Queueable, Database.AllowsCallouts{   
    List<Reservable_Hold__c> lstHoldsToBeReleased = new List<Reservable_Hold__c>();
    public QueueReservableHold(List<Reservable_Hold__c> lstHoldsToBeReleased){
        this.lstHoldsToBeReleased = lstHoldsToBeReleased;
    }
    /************************************************************************************************************************************
        Author				:	Samadhan Kadam 
        Description			:	This method executes business logic for QueueReservableHold class. 
        Last Modified Date	: 	1 January 2018
        Last Modified By	:	Samadhan Kadam 
    **************************************************************************************************************************************/
    public void execute(QueueableContext context) {
        try{
            for(Reservable_Hold__c newHoldRecord : lstHoldsToBeReleased){                
                debug.Log('newHoldRecord::'+newHoldRecord);
                //Modified by Samadhan kadam for CSI-512 as we have only 2 Status Hold and Released
                Setting__c HoldReservable = Settings.get('HoldReservableSettings'); 
                debug.log('HoldReservableSetting'+HoldReservable);     
                HoldReservableController.HoldReservableSettings settingData = new HoldReservableController.HoldReservableSettings();
                settingData = (HoldReservableController.HoldReservableSettings)JSON.deserialize(HoldReservable.Data__c, HoldReservableController.HoldReservableSettings.class);
                String endPointUrl;
                String userId = UserInfo.getUserId();
                endPointUrl = settingData.HoldoffAPI.url.replace('HOLD_UUID',newHoldRecord.UUID__c);
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(endPointUrl);
                request.setMethod('POST');
                request.setHeader('Content-Type','application/json');
                request.setHeader('Authorization',settingData.HoldoffAPI.Headers.get('Authorization'));
                request.setHeader('CONTEXT_SALESFORCE_ID',userId);
                HTTPResponse response = http.send(request);
            }
        }catch(Exception exc){
            Debug.log('exc ::'+exc);
        }
        
    }
}