({
    save : function(component, event, helper) {
        component.find("utils").showProcessing();
        component.find("utils").execute("c.saveRecord",{"record":{"Id":component.get("v.recordId"),"OwnerId":component.get("v.ownerId")}},function(response){
            component.find("utils").hideProcessing();
            component.find("utils").showSuccess("Owner changed successfully.");
            component.find("enziOwnerModal").close();
            component.find("utils").redirectToUrl("/apex/RecordManager?id="+component.get("v.recordId"), '', false);           
        },function(error){
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        })
    },
    cancel : function(component, event, helper) {
		component.find("enziOwnerModal").close();
	},
    assignToMe : function(component, event, helper) {
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        component.find("utils").showProcessing();
        component.find("utils").execute("c.saveRecord",{"record":{"Id":component.get("v.recordId"),"OwnerId":userId}},function(response){
            component.find("utils").hideProcessing();
            component.find("utils").showSuccess("Owner changed successfully.");
            component.find("enziOwnerModal").close();
            component.find("utils").redirectToUrl("/apex/RecordManager?id="+component.get("v.recordId"), '', false);
        },function(error){
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        })    
    }
})