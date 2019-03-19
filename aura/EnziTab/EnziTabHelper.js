({
	notifyParent : function(component) {
		var evt = $A.get("e.c:EnziTabsChangeEvent");
        evt.setParams({"tab" : {"id":component.get("v.tabId"),"label":component.get("v.label"),"allowDelete":component.get("v.allowDelete"),"delete":component.getReference("v.delete")} });
        setTimeout(function(){
            evt.fire();
        },0)
	}
})