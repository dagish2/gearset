({
    doInit : function(component, event, helper){
        component.set("v.utils", component.find("utils"))
        component.get("v.utils").setTitle("Update Market");
        helper.getMarket(component, helper);
    },
    updateMarket : function(component, event, helper){
        helper.showModal(component, helper, true, "Update Market on "+component.get("v.mapResult.sObjectName")+" is in process. Please wait...");
        component.set("v.showUpdateBtn", false);
        helper.updateMarket(component, helper);
    },
    close : function(component, event, helper){
        component.find("utils").closeTab();
    }
})