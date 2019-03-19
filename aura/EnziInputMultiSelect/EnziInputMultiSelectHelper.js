({
    sortData : function (data, key) {
        return data.sort(function(a, b) {
            var x = a[key]; var y = b[key];
            return ((x < y) ? -1 : ((x > y) ? 1 : 0));
        });
    },
    getFilteredOptions : function(component,keyword){
        component.set("v.searchKeyword", keyword);
        var options = JSON.parse(JSON.stringify(component.get("v.options")));
        var filteredOptions = [];
        var helper = this;
        if(keyword.length>0){
            filteredOptions = options.filter(function(option){
                //return option.label.toLowerCase().includes(keyword.toLowerCase());
                if(typeof(option.label)==="string"){
                    return option.label.toLowerCase().includes(keyword.toLowerCase());
                } else if(typeof(option.label)==="number"){
                    return (option.label==keyword)?true:false;
                }
            });
            for(var i=0;i<component.get("v.result").length;i++){
                if(filteredOptions.findIndex(function(obj){return obj.value==component.get("v.result")[i].value})>=0)
                    filteredOptions.splice(filteredOptions.findIndex(function(obj){return obj.value==component.get("v.result")[i].value}),1);
            }
        }else{
            filteredOptions = options;
            for(var i=0;i<component.get("v.result").length;i++){
                if(filteredOptions.findIndex(function(obj){return obj.value==component.get("v.result")[i].value})>=0)
                    filteredOptions.splice(filteredOptions.findIndex(function(obj){return obj.value==component.get("v.result")[i].value}),1);
            }
        }
        if(!component.get("v.showAll") && filteredOptions.length>10)
       		return helper.sortRecords(filteredOptions.slice(0,10),"label","asc");
        else
            return helper.sortRecords(filteredOptions,"label","asc");
    },
    generatePills : function(component){
        var result = [];
        if(component.get("v.value") && component.get("v.value")!=""){
            for(var p in component.get("v.value").split(";")){
                if(component.get("v.mapOptionsValue")[component.get("v.value").split(";")[p]]){
                    result.push(component.get("v.mapOptionsValue")[component.get("v.value").split(";")[p]]);
                }
            }
        }
        component.set("v.result",result);
        component.set("v.filteredOptions",this.getFilteredOptions(component,component.get("v.searchKeyword")));
    },
    initOptionsMap:function(component){
        var mapOptionsValue = {};
        var options = component.get("v.options");
        for(var i=0;i<options.length;i++){
            mapOptionsValue[options[i].value] = options[i];
        }
        component.set("v.mapOptionsValue",mapOptionsValue);
    },
    sortRecords:function(records,sortBy,sortOrder){
        records.sort(function(a,b){
            var dataA,dataB;
            if(sortBy.includes(".")){
                dataA = a;
                dataB = b;
                sortBy.split(".").forEach(function(f){
                    if(dataA){
                        dataA = dataA[f];
                    }
                    if(dataB){
                        dataB = dataB[f];
                    }
                })
            }else{
                dataA = a[sortBy];
                dataB = b[sortBy];
            }
            var t1 = dataA == dataB, t2 = dataA < dataB;
            return t1? 0: (sortOrder=="asc"?-1:1)*(t2?1:-1);
        })
        return records;
    }
})