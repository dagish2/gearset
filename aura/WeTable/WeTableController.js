({
	doInit : function(component, event, helper) {
        if(component.get("v.query") || (component.get("v.sObjectName") && component.get("v.fields"))){
            component.set("v.isDynamicLoading",true);
            component.set("v.enableInfiniteLoading",true);
            helper.setData(component,helper);
        }
        helper.filterMetaData(component);
        if(component.get("v.data") && component.get("v.data").length>0){
            helper.setData(component,helper);
        }else if(component.get("v.data") && component.get("v.data").length == 0){
            component.set("v.records", component.get("v.data"));
        }
        helper.checkForSelectedRows(component);
    },
    loadMore:function(component, event, helper){
        component.set("v.offset", (component.get("v.offset")+component.get("v.limit")));
        helper.setData(component, helper);
        
    },
    sort:function(component, event, helper){
        component.set("v.sortedBy", event.getParam("fieldName"));
        component.set("v.sortedDirection", event.getParam("sortDirection"));
        helper.setData(component,helper);
    },
    search:function(component, event, helper){
        component.set("v.offset", 10);
        helper.setData(component, helper);
    },
    getSelectedName:function(component, event, helper){
        var selectedRowsData = event.getParam("selectedRows") ? event.getParam("selectedRows") : component.get("v.selectedRows");
        component.set("v.selectedRows", selectedRowsData);
    }, 
    onRowAction:function(component, event, helper){
        var evt = component.getEvent("rowActionEvent");
        var action = event.getParam('action');
        if(action && action.name){
            switch(action.name){
                case 'urlHandler':
                    let value = event.getParam('row')[event.getParam('action').field];
                    if(value){
                        component.find("utils").redirectToUrl(location.href.split('.com')[0]+'.com/'+value,'',true);
                    }
                    break;
                default:
                    evt.setParams({"action":event.getParam('action'),"record":event.getParam('row')});
                    evt.fire();
            }
        }
    },
    selectRow:function(component, event, helper){
        var index = parseInt(event.currentTarget.id.split(":")[1]);
        var key = component.get("v.filteredRecords")[index][component.get("v.keyField")];
        var selectedRecords = component.get("v.selectedRecords");
        if(event.currentTarget.checked){
            selectedRecords.push(key);
        }else{
            selectedRecords.splice(selectedRecords.indexOf(key),1);  
        }
        component.set("v.selectedRecords",JSON.parse(JSON.stringify(selectedRecords)));
    },
    save:function(component, event, helper){
        var evt = component.getEvent("save");
        evt.setParams({"records":event.getParam('draftValues')});
        evt.fire();
        
        var refreshEvent = $A.get("e.force:refreshView");
        if(refreshEvent){
            refreshEvent.fire();
        }
    },
    saveDraft:function(component, event, helper){
        helper.saveDraft(component);
    },
    cancelDraft:function(component, event, helper){
        component.find("datatable").set("v.draftValues",undefined);
    }
})