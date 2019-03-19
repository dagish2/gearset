({
	getData : function(component, helper) {
        var action = component.get("c.getOppData");
        action.setParams({
            "oppId":component.get("v.recordId"),
        });
        action.setCallback(this, function(response){
            var state = response.getState();
         
            if (component.isValid() && state === "SUCCESS"){
                var result = response.getReturnValue();
                component.set("v.contractUUID", result.Contract_UUID__c);
                if(result.Contract_UUID__c != null && result.Contract_UUID__c != "")
                	helper.discardContract(component, helper);
                else{
                    helper.showMessage(component, event,'Error','Contract UUID should not empty.');
                    if($A.get("e.force:closeQuickAction").getSource().isValid()) {
                        $A.get("e.force:closeQuickAction").fire();
                    }
                }
            }else if(response.getState()=="ERROR"){
                var errors = response.getError();
                helper.showMessage(component, event,'Error',errors.message);
                //component.find("utils").hideProcessing();
                //component.find("utils").showError(errors.message);
                if($A.get("e.force:closeQuickAction").getSource().isValid()) {
                    $A.get("e.force:closeQuickAction").fire();
                }
            }
        });
        $A.enqueueAction(action);                                             
    },
    discardContract : function(component, helper) {
        var action = component.get("c.discardContractEvent");
       
        action.setParams({
            "contractUUID":component.get("v.contractUUID"),
        });
        action.setCallback(this, function(response){
            
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS"){
                var contractResult = JSON.parse(response.getReturnValue());
                if(contractResult.meta.success){
                    helper.showMessage(component, event,'Success','Contract discard successfully!!');                 
                    if($A.get("e.force:closeQuickAction").getSource().isValid()) {
                        $A.get("e.force:closeQuickAction").fire();
                    }
                }else{
                    var errors = contractResult.result.error;
                    helper.showMessage(component, event,'Error',contractResult.result.error);
                    //component.find("utils").hideProcessing();
                    //component.find("utils").showError(errors);
                    if($A.get("e.force:closeQuickAction").getSource().isValid()) {
                        $A.get("e.force:closeQuickAction").fire();
                    }
                }
               
            }else{
                
                var errors = response.getError();
                helper.showMessage(component, event,'Error',errors.message);
                //component.find("utils").hideProcessing();
                //component.find("utils").showError(errors);
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