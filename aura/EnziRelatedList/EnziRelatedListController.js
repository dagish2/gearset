({
	doInit : function(component, event, helper) {
        component.find("utils").getIcons(function(icons){
            component.set("v.icon",icons[component.get("v.relatedList").sobject]?icons[component.get("v.relatedList").sobject]:'standard:default');
        })
        //component.find("utils").showProcessing();
        helper.getData(component,function(data){
           	component.set("v.records",data);
            //component.find("utils").hideProcessing();
        },function(error){
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        })
	},
    toggleAction : function(component, event, helper) {
        $A.util.toggleClass(event.currentTarget.parentElement,'slds-is-open')
	},
    manageListActions:function(component, event, helper){
        switch(event.currentTarget.id){
            case "New":
            case "AddRelation":
            case "AddCampaign":
                var defaultValues = {};
                defaultValues[component.get("v.relatedList.field")] = component.get("v.recordId");
                component.find("utils").addComponent("c:EnziForm",{"sObjectName":component.get("v.relatedList").sobject,"mode":"new","useLayout":true,"showModal":true,"defaultValues":defaultValues});
                break;
            default:
                component.find("utils").showAlert("Unsupported action.");
                break;
        }
    },
    manageRecordActions:function(component, event, helper){
        var action = event.currentTarget.id;
        switch(action.split(":")[0]){
            case "edit":
			
        }
        if(action.split(":")[0]=="delete"){
            component.find("utils").showConfirm("Do you want to delete this record?",function(){
                component.find("utils").showProcessing();
                component.find("utils").execute("c.deleteRecord",{"recordToDelete":action.split(":")[1]},function(){
                    helper.getData(component,function(data){
                        component.set("v.records",data);
                        component.find("utils").hideProcessing();
                        component.find("utils").showSuccess("Record deleted successfully.");
                    },function(error){
                        component.find("utils").hideProcessing();
                        component.find("utils").showError(error);
                    })
                },function(error){
                    component.find("utils").hideProcessing();
                    component.find("utils").showError(error);
                })
            })
        }else{
            component.find("utils").addComponent("c:EnziForm",{"recordId":action.split(":")[1],"mode":action.split(":")[0],"useLayout":true,"showModal":true});
        }  
    },
    formSaved:function(component,event,helper){
        if(event.getParam("sObjectName")==component.get("v.relatedList.sobject")){
            helper.getData(component,function(data){
                component.set("v.records",data);
                component.find("utils").hideProcessing();
            },function(error){
                component.find("utils").hideProcessing();
                component.find("utils").showError(error);
            })
        }
    }
})