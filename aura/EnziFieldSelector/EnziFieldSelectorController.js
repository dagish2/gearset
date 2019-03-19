({
	doInit : function(component, event, helper) {
        component.find("utils").showProcessing();
        var sObjectName = component.get("v.sObjectName");
        helper.getAllFields(sObjectName,component,function(fields){
            var levels = component.get("v.levels");
            levels.push(fields);
            component.set("v.levels",levels);
            component.find("utils").hideProcessing();
        })
	},
    select:function(component, event, helper){
        var id = event.currentTarget.id.split(":");
        var levels = component.get("v.levels");
        levels[id[1]]['selectedField'] = levels[parseInt(id[1])].fields[parseInt(id[2])];
        component.set("v.levels",levels);
        for(var cmp in event.currentTarget.parentElement.children) {
            $A.util.removeClass(event.currentTarget.parentElement.children[cmp], "selected");
        }
        $A.util.addClass(event.currentTarget,"selected");
        var fieldName = helper.getFieldName(component,event);
        component.set("v.selectedField",fieldName);
    },
    getRelatedFields:function(component, event, helper){
       component.find("utils").showProcessing();
        var id = event.currentTarget.id.split(":");
        var levels = component.get("v.levels");
        var sObjectName = levels[id[1]].fields[id[2]].referenceTo[0];
        helper.getAllFields(sObjectName,component,function(fields){
            var levels = component.get("v.levels");
            levels = levels.slice(0,parseInt(id[1])+1);
            levels.push(fields);
            component.set("v.levels",levels);
            component.find("utils").hideProcessing();
        })
    },
    selectField:function(component, event, helper){
        var evt = component.getEvent("fieldSelector");
        evt.setParams({"field" : component.get("v.selectedField") });
        evt.fire();
        component.find('enziFieldSelectorModal').close();
    }
})