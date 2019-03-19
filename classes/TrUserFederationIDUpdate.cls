/************************************************************************************************************************************
    Author      :   Ashish Mishra	
    Description :   This class will contain buisness logic of User trigger.
	Issue No    : 	ST-3149
    History		:
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1           24 November 2018    Ashish Mishra           Initial Developement
**************************************************************************************************************************************/
public class TrUserFederationIDUpdate implements IProcessHandler{ 
    
    public void handle(List<sObject> triggerNew, Map<Id, sObject> triggerOldMap) {
        updateUserFederationID((List<User>)triggerNew, triggerOldMap);
    }
    
	/************************************************************************************************************************************
    	Author         : Ashish Mishra
    	Description    : This method is used to populate user federationID when we enter email of user at the time of user insertion.
						 On Insert
    	Created Date   : 24 Nov 2018 
    	Issue No       : ST-3149
	**************************************************************************************************************************************/
    public void updateUserFederationID(List<User> triggerNew, Map<Id, sObject> triggerOldMap){
        for(User objUser : triggerNew){
            if(objUser.Username != objUser.FederationIdentifier){
                objUser.FederationIdentifier = objUser.Username.toLowerCase();                
            } 
        } 
    }
}