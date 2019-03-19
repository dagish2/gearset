({
    convertAccountType : function(component, helper, record) {
        component.find("utils").execute("c.changeAccountType", {"objAccount": record}, function(response){
            component.find("utils").hideProcessing();
            component.find("utils").showSuccess('Account Type Updated successfully.');            
            helper.close(component, helper);
        },function(error){
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);            
        }, component);
    },
    close : function(component, helper) {
        setTimeout(function () {
            if($A.get("e.force:closeQuickAction")){
                $A.get('e.force:refreshView').fire();
                $A.get("e.force:closeQuickAction").fire();
            } else {
                window.close();
                parent.postMessage('close', opener.location.href="/" + component.get("v.recordId"));
            }
        }, 2000);            
    },
    showError : function(component, message) {
        $A.createComponent(
            "ui:message",{
                "title": message,
                "severity": "warning"
            },
            function(components, status, statusMessagesList){
                var accountTypeConversionErrorMessage = component.find("AccountTypeConversionErrorMessage");
                accountTypeConversionErrorMessage.set("v.body", components);
            }
        );
    }
})