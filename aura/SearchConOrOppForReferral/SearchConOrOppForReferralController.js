({
    doInit: function(component, event, helper) {
        component.set("v.utils",component.find("utils"));
        helper.metaContactColumn(component);
        helper.metaOppColumns(component);
    },
    search: function(component, event, helper) {
        component.set("v.showTable", true);
        helper.search(component, helper, null);
    },
    contactRowchange : function(component, event, helper){
        var selectedRows = component.get("v.selectedContactRows");
        selectedRows && selectedRows.length > 0 ? component.set("v.contactRec", JSON.parse(JSON.stringify(selectedRows[0]))) : '' ;
    },
    opportunityRowchange : function(component, event, helper){
        var selectedRows = component.get("v.selectedOpportunityRows");
        selectedRows && selectedRows.length > 0 ? component.set("v.opportunityRec", JSON.parse(JSON.stringify(selectedRows[0]))) : '' ;
    },
    useOpportunity : function(component, event, helper){
       if(component.get("v.opportunityRec") && component.get("v.opportunityRec.Id")){
          component.set("v.oppRecordId", component.get("v.opportunityRec.Id"));
        }
    },
    close : function(component, event, helper){
        component.get("v.utils").showConfirm("Are you sure want to close this page ?",function(){
            component.get("v.utils").closeTab();
            component.get("v.utils").redirectToUrl('back');
        });
    },
    selectOpportunity : function(component, event, helper){
        if(component.get("v.contactRec") && component.get("v.contactRec.Id")){
            component.set("v.value", "Opportunity");
            component.get("v.selectedContactRows", []);
            component.get("v.selectedOpportunityRows", []);
            component.set("v.opportunityRec",null);
            helper.search(component, helper, {"opportunity":"Primary_Member__c = '"+component.get("v.contactRec.Id")+"'"});
        }else{
             component.get("v.utils").showWarning("Something went wrong, Please select the contact again.", false);
        }
    },
     onchange : function(component, event, helper){
        if(component.get("v.value").toLowerCase() == 'opportunity'){
            component.set("v.opportunities", []);
        }else if(component.get("v.value").toLowerCase() == 'contact'){
            component.set("v.contacts", []);
        }
        helper.resetSeletedRows(component);
    }
})