({
	evaluateCriteria : function(record,criteria) {
        if(criteria=="default"){
            return true;
        }else{
            return false;
        }
	},
    getCriteriaData:function(component,onsuccess,onerror){
        var records = [];
        var criteriaFields = [];
        var criterias = component.get("v.criterias");
        for(var criteria in criterias){
            if(criterias[criteria].criteria!='default'){
                criteriaFields.push(criterias[criteria].field.name);
            }
        }
        if(criteriaFields.length>0){
            var query = "SELECT Id,"+criteriaFields.join(",")+" FROM "+component.get("v.sObjectName")+" WHERE Id IN ("+component.get("v.records").join(",")+")";
            component.find("utils").execute("c.getQueryData",{"query":query},function(response){
                onsuccess(response);
            },function(error){
                onerror(error);
            })
        }else{
            var rec = component.get("v.records");
            for(var r in rec){
                records.push({"Id":rec[r]});
            }
            onsuccess(records);
        }
    }
})