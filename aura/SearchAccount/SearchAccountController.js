({
    doInit : function(component, event, helper) { 
        component.find("utils").setTitle("Search Account");
        var entity = component.get("v.entity");
        helper.setMetaFields(component, event, helper,entity);
        helper.getData(component,helper,entity);
    },
    change : function(component, event, helper) {        
       var entity = component.get("v.entity");
       component.find("utils").showProcessing(); 
        if(entity.isOrg && entity.isSales && entity.isBill){
            entity.isAll = true;
        }else{
            entity.isAll = false;
        }
        component.set("v.entity",entity);
        if(entity.isOrg || entity.isSales || entity.isBill || entity.isAll)
            helper.getData(component,helper,entity);  
        else{
            component.set("v.relatedAccounts",[]);
            component.find("utils").hideProcessing();
        }  
    },
    changeAll : function(component, event, helper){        
        var entity = component.get("v.entity");
        component.find("utils").showProcessing();
        if(!entity.isAll){
            var mapEntity = {'isAll':false,'isOrg':false,'isSales':false,'isBill':false};
            component.set("v.relatedAccounts",[]);
            component.find("utils").hideProcessing();
            component.set("v.entity",mapEntity);
        }else{
            var mapEntity = {'isAll':true,'isOrg':true,'isSales':true,'isBill':true};
			component.set("v.entity",mapEntity);
			helper.getData(component,helper,component.get("v.entity"));            
        }  
    },
    search : function(component, event, helper){
        var keyword = component.get("v.keyword"); 
        var entity = component.get("v.entity");
        if(keyword && keyword.length > 0){
            window.setTimeout(
                $A.getCallback(function() {
                    if (component.isValid()){ 
                        if(keyword.length > 2){
                            component.find("utils").showProcessing();
                            helper.resetTable(component);
                            helper.getData(component,helper,entity);
                        }
                    }}),
                2000);
        }else{
            component.find("utils").showProcessing();
            helper.getData(component,helper,entity);
        }
    },
    close:function(component,event,helper){
        component.find("utils").closeTab();
        component.find("utils").redirectToUrl('back');
    }
})