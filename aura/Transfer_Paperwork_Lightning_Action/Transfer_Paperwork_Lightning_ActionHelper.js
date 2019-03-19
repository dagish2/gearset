({
	showMessage : function(component, event, title, message){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message
        });
        toastEvent.fire();
	},
    refresh : function(component, event) {
        if($A.get("e.force:refreshView") && $A.get("e.force:refreshView").getSource().isValid()) {
       		$A.get('e.force:refreshView').fire();
        }
    },
    getBillingAccountSelector:function(component,event){
        var helper = this;
        if(component.get("v.result").objOpportunity && component.get("v.result").objOpportunity.Billing_Account__c){
            helper.redirectToSpacestation(component,event);
        }else{
            $A.createComponent(
                "c:BillingAccountSelector",{
                    "recordId": component.get("v.recordId"),
                    "parentId": component.get("v.result").objOpportunity.AccountId,
                    "billingAccountUUID": component.getReference("v.billingAccountUUID"),
                    "transferpaperwork":component.get("v.transferpaperwork")
                },
                function(components,status,statusMessagesList){
                    if (status === "SUCCESS") {
                        var div1 = component.find("div1");
                        div1.set("v.body", components);
                    }else if (status === "INCOMPLETE") {
                        console.log("No response from server or client is offline.");
                        helper.showMessage(component, event,'Success','No response from server or client is offline.');
                    }else if (status === "ERROR") {
                        console.log("Error: " + statusMessagesList);
                    }
                }
            );
        }
    },
    redirectToSpacestation:function(component,event){
        var helper = this;
        var result = component.get("v.result");
        console.log('result::'+ component.get("v.result"));
        var urlEvent = $A.get("e.force:navigateToURL");
        if(result && result.settingData){
            if(JSON.parse(result.settingData).length){
                var url = JSON.parse(result.settingData)[0];
                url= url.replace('opportunity.account.uuid__c',result.objOpportunity.Billing_Account__r.UUID__c);
                url= url.replace('opportunity.encoded_id__c',result.objOpportunity.Encoded_ID__c);
                if(urlEvent){
                    urlEvent.setParams({"url": url});
                    urlEvent.fire();
                }else{
                    window.location = url;
                }
                if($A.get("e.force:closeQuickAction") && $A.get("e.force:closeQuickAction").getSource().isValid()) {
                    $A.get("e.force:closeQuickAction").fire();
                }
                helper.refresh(component, event);
            }else{
                component.find("utils").showError('Send Paperwork Setting not found.');
            }
        }else{
            component.find("utils").showError('Send Paperwork Setting not found.');
        }
    }
})