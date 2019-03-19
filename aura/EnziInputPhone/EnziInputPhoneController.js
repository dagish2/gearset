({
    change : function(component, event, helper) {
        component.set("v.value",event.target.value);
	},
    changeNumber:function(component){
        if(component.get("v.allowFastCall")){
            component.find("utils").execute("c.getUITheme",{},function(response){
                if(response=="Theme4t"){
                    component.set("v.phoneUrl","tel:"+component.get("v.value"));
                }else{
                    component.set("v.phoneUrl","javascript:sendCTIMessage('/CLICK_TO_DIAL?DN='+encodeURIComponent('"+component.get("v.value")+"')+'&ID="+component.get("v.fastCallRecordId")+"&ENTITY_NAME="+component.get("v.fastCallObjectName")+"&OBJECT_NAME='+encodeURIComponent('"+component.get("v.fastCallRecordName")+"')+'&DISPLAY_NAME='+encodeURIComponent('"+component.get("v.fastCallObjectName")+"'))");
                }
            })
        }else{
            component.set("v.phoneUrl","tel:"+component.get("v.value"));
        }
    }
})