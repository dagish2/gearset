({
	doInit : function(component, event, helper) {
		component.find("utils").showProcessing();
        component.find("utils").execute("c.getAllRecordTypesById",{"recordId":component.get("v.recordId")},function(response){
            component.set("v.recordTypes",response);
            component.find("utils").hideProcessing();
        },function(error){
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        })
	},
    save:function(component, event, helper){
        component.find("utils").showProcessing();
        component.find("utils").execute("c.saveRecord",{"record":{"Id":component.get("v.recordId"),"RecordTypeId":component.get("v.recordTypeId")}},function(response){
            component.find("utils").hideProcessing();
            component.find("utils").showSuccess("Record type changed successfully.");
            component.find("enziRecordTypeModal").close();
        },function(error){
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        })
    },
    cancel:function(component, event, helper){
        component.find("enziRecordTypeModal").close();
    }
})