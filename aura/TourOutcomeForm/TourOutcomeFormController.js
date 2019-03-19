({
    doInit : function(component, event, helper) {
        component.set("v.utils", component.find("utils"));
        helper.getFormData(component, event, helper);
    },
    changeOutcome : function(component, event, helper) {
        helper.changeOutcome(component, event, helper);        
    },
    changeIsDecisionMaker: function(component, event, helper) {
        helper.changeIsDecisionMaker(component, event, helper);
    },   
    getOfficeDetails : function(component, event, helper) {
        helper.getOfficeDetails(component, event, helper);
    },
    save : function(component, event, helper) { 
    	helper.save(component, event, helper);
    },
    saveAndsendPaperwork : function(component, event, helper) {
        if(component.get("v.opportunityId")){
            let oldTourOutcomeData = component.get("v.oldTourRecord");
            let newTourOutcomeData = component.get("v.tourOutcome");  
            let oldTour = component.get("v.oldTourData");
            let newOffices = component.get("v.officesShown");
            let refName = component.get("v.referrer_Name");
            let refEmail = component.get("v.referrer_Email");
            window.open("/apex/sendPaperWork?Id="+component.get("v.opportunityId"),"SendPaperwork","height="+(screen.height/1.5)+",width="+(screen.width/1.2)+",left="+(screen.width/16)+",top="+(screen.height/10)+",scrollbars=yes");
            if(!(newTourOutcomeData.Unit_Type__c == oldTourOutcomeData.Unit_Type__c && newTourOutcomeData.Urgency__c == oldTourOutcomeData.Urgency__c && newTourOutcomeData.Interested_Buildings__c == oldTourOutcomeData.Interested_Buildings__c && newTourOutcomeData.Interested_in_Number_of_Desks__c == oldTourOutcomeData.Interested_in_Number_of_Desks__c && newTourOutcomeData.Move_In_Date__c == oldTourOutcomeData.Move_In_Date__c && newTourOutcomeData.Is_Decision_Maker__c == oldTourOutcomeData.Is_Decision_Maker__c 
                 && newTourOutcomeData.How_Did_You_Hear_About_Us__c == oldTourOutcomeData.How_Did_You_Hear_About_Us__c && newTourOutcomeData.Current_Budget__c == oldTourOutcomeData.Current_Budget__c && newTourOutcomeData.Desired_Budget__c == oldTourOutcomeData.Desired_Budget__c && newTourOutcomeData.Tour_Outcome_Notes__c == oldTourOutcomeData.Tour_Outcome_Notes__c && newTourOutcomeData.Lease_Expiration__c == oldTourOutcomeData.Lease_Expiration__c
                 && newOffices == oldTour.oldOfficesShown && refName == oldTour.referrer_Name && refEmail == oldTour.referrer_Email)){
                helper.save(component, event, helper);
            }else{
                component.get("v.utils").showSuccess("Tour outcome successfully saved.");
                helper.close(component, event, helper);
            }
        }
    },
    saveNoShow : function(component, event, helper) {        
    	helper.saveNoShow(component, event, helper, false);
    },
    bookTours : function(component, event, helper) {        
    	helper.saveNoShow(component, event, helper, true);
    },
    cancel : function(component, event, helper) {
        helper.cancel(component, event, helper);        
    },
    saveContact : function(component, event, helper) {
        helper.saveContact(component, event, helper);        
    },
	showNewContactModal: function (component, event, helper) {        
		helper.showNewContactModal(component, event, helper);
	},
	closeNewContactModal: function (component, event, helper) {
		helper.closeNewContactModal(component, event, helper);
	},
    getAPICallout : function (component, event, helper) {
		helper.getAPICallout(component, event, helper);
	},
    saveReschedule : function(component, event, helper){
        helper.rescheduleTour(component, event, helper);
    },
    setEndTime : function(component, event, helper){
        if(event.currentTarget.value)
          component.set("v.rescheduleTour.endTime",helper.getEndTime(component,event.currentTarget.value));
    },
    getTimeSlots : function(component,event,helper){
        var tour = JSON.parse(JSON.stringify(component.get("v.tour")));
        if(component.get("v.tourInterest") && component.get("v.tourInterest") == 'Tour Reschedule'){
            if(component.get("v.rescheduleTour.tourDate")){
                component.find("utils").showProcessing();
                helper.loadTimeSlots(component,tour,component.get("v.rescheduleTour.tourDate"),function(){
                    component.find("utils").hideProcessing();
                    component.set("v.originalTour",tour);
                    
                },function(error){
                    component.find("utils").hideProcessing();
                    component.find("utils").showError(error);
                }); 
            }
        }else{
            
        }
    }
})