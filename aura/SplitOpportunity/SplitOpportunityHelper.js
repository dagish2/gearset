({
    openSFRecord : function(component, helper, recordId){
        component.get("v.utility").redirectToUrl("/"+recordId);
        component.get("v.utility").closeTab();
     } 
})