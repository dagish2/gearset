({
    handleSaveRecord: function(component, event, helper) {
        if (component.get("v.avgPrice") && component.get("v.numOfDesks") && component.get("v.deskMonths"))
        {	
        	component.find("utils").showProcessing();

			//Set the fields values.
            component.set("v.simpleRecord.Remaining_Price_TCV__c ", component.get("v.avgPrice"));
            component.set("v.simpleRecord.Remaining_Quantity_TCV__c ", component.get("v.numOfDesks"));
            component.set("v.simpleRecord.Remaining_Term_TCV__c ", component.get("v.deskMonths"));   
            
            //Perform update.
        	component.find("recordData").saveRecord($A.getCallback(function(saveResult) {
        		component.find("utils").hideProcessing();
        	}));
        }
    },
    
    recordUpdated : function(component, event, helper) {
    var changeType = event.getParams().changeType;
        
    //If the opportunity changed, reload the calculator data.
    if (changeType === "CHANGED") {
        component.find("recordData").reloadRecord();}
    }
})