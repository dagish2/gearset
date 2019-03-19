({
	getData : function(component, helper) {
        var action = component.get("c.getOppData");
        var param = {"oppId":component.get("v.recordId")};
        action.setParams(param);
        action.setCallback(this, function(response){
            var state = response.getState();            
            if (component.isValid() && state === "SUCCESS"){
                var result = response.getReturnValue();                
                component.set("v.contractUUID", result.Contract_UUID__c);
                component.set("v.stageName", result.stageName);
                component.set("v.contractStage", result.Contract_Stage__c);
                if(result.StageName == 'Closing' && result.Contract_Stage__c =='Contract Voided'){
                    if(result.Contract_UUID__c != null && result.Contract_UUID__c != ""){
                        helper.resendPaperwork(component, helper);
                    }
                    else{
                        helper.showMessage(component, event,'Error','Contract UUID should not empty.');
                        if($A.get("e.force:closeQuickAction").getSource().isValid()) {
                            $A.get("e.force:closeQuickAction").fire();
                        }
                    }
                }else{
                    helper.showMessage(component, event,'Error','Opportunity Stage should be Closing and Contract Stage Should be Contract Voided for Resend Paperwork.');
                    if($A.get("e.force:closeQuickAction").getSource().isValid()) {
                        $A.get("e.force:closeQuickAction").fire();
                    }
                }
            }                       
            else if(response.getState()=="ERROR"){
                var errors = response.getError();
                helper.showMessage(component, event,'Error',errors.message);
                if($A.get("e.force:closeQuickAction").getSource().isValid()) {
                    $A.get("e.force:closeQuickAction").fire();
                }
            }
        });
        $A.enqueueAction(action);                                             
    },
    resendPaperwork : function(component, helper) {
        var action = component.get("c.resendPaperworkLightning");
        action.setParams({
            "contractUUID":component.get("v.contractUUID"),
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS"){
                var contractResult = JSON.parse(response.getReturnValue());
                
                if(contractResult.hasOwnProperty('error')){
                    helper.showMessage(component, event,'Error',contractResult.error);
                    if($A.get("e.force:closeQuickAction").getSource().isValid()) {
                        $A.get("e.force:closeQuickAction").fire();
                    }
                }else if(contractResult.meta.success){
                    helper.showMessage(component, event,'Success','Contract Resend successfully!!');                 
                    if($A.get("e.force:closeQuickAction").getSource().isValid()) {
                        $A.get("e.force:closeQuickAction").fire();
                    }
                }else{
                    var errors = contractResult.result.error;
                    helper.showMessage(component, event,'Error',contractResult.result.error);
                    if($A.get("e.force:closeQuickAction").getSource().isValid()) {
                        $A.get("e.force:closeQuickAction").fire();
                    }
                }
            }else{
                
                var errors = response.getError();
                helper.showMessage(component, event,'Error',errors.message);              
            }
        });
        $A.enqueueAction(action);                                             
    },
    showMessage : function(component, event, title, message) {       
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message
        });
        toastEvent.fire();
	}
})