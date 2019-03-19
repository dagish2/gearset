({
	getAllFields : function(sObjectName,component,onsuccess) {
        component.find("utils").execute("c.getAllFields",{"sObjectName":sObjectName},function(response){
            onsuccess(JSON.parse(response));
        },function(error){
            component.find("utils").showError(error);
        })
	},
    getFieldName:function(component,event){
        var id = event.currentTarget.id.split(":");
        var levels = component.get("v.levels");
        var fieldName = "";
        for(var i=0;i<=parseInt(id[1]);i++){
            if(i==parseInt(id[1])){
                fieldName += levels[i].selectedField.name;
            }else{
                fieldName += levels[i].selectedField.relationshipName+".";
            }
        }
        return fieldName;
    }
})