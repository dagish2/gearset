({
    close : function(component) {
        if(component.get("v.isFromJourneyDetails")){
            component.find("EnziUnqualifyModal").close();
            component.find("utils").redirectToUrl("/apex/RecordManager?id=" + component.get("v.recordId"),'',false);
        } else {
            $A.get("e.force:refreshView").fire(); 
            $A.get("e.force:closeQuickAction").fire();
        }
    }
})