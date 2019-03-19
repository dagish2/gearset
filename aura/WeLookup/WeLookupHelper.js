({
    getName : function(component) {       
        if(component.get("v.options") && component.get("v.options").length>0){
            var data = [];
            var options = component.get("v.options");
            for(var o in options){
                if(options[o].value==component.get("v.value")){
                    component.set("v.keyword",options[o].label);
                    break;
                }
            }
        }else{
            var query = "Select Id,Name From ";     
            var helper = this;
            if(component.get("v.value").startsWith("00G")){  
                query += "Group WHERE id='"+component.get("v.value")+"'";
                component.set("v.reference","Group");
            }else if(component.get("v.value").startsWith("005")){
                query += "USER WHERE id='"+component.get("v.value")+"'"+(component.get("v.showOnlyActiveUsers") ? ' AND isActive=true':'');
                component.set("v.reference","User"); 
            }else{
                query += component.get("v.reference")+" WHERE id='"+component.get("v.value")+"'"; 
            }
            component.find("utils").execute("c.getQueryData",{"query":query},function(response){
                if(response && response[0]){
                    component.set("v.keyword",response[0].Name);
                    component.set("v.searchResults",[{"label":response[0].Name,"value":response[0].Id}]); 
                }            
            },function(error){
                component.find("utils").hideProcessing();
                component.find("utils").showError(error);
            })
        }
    },
    getResults : function(component, helper) {
        if(component.get("v.keyword").length > 1){
            if(component.get("v.options") && component.get("v.options").length > 0 ){
                let data = [];
                let options = component.get("v.options");
                let keyword = component.get("v.keyword");
                data = options.filter(function(option){
                    if(option.label && option.label.toLowerCase().includes(keyword.toLowerCase())){
                        return true;
                    }
                });
                component.set("v.searchResults",data);
                component.set("v.isSearching",false);
            }else{
                component.find("utils").execute("c.getQueryData",{"query":("Select Id,Name From "+component.get("v.reference")+" Where Name LIKE '%"+ component.find("utils").addSlashes(component.get("v.keyword")) +"%' LIMIT 10")},function(response){            
                    let options = [];
                    response.forEach(function(option){
                        options.push({"label":option.Name,"value":option.Id});
                    })
                    component.set("v.searchResults",options);
                    component.set("v.isSearching",false);
                },function(error){
                    component.find("utils").showError(error);
                    component.set("v.isSearching",false);
                })
            }
        }else{
            component.set("v.searchResults",[]);
            component.set("v.value",undefined);
            component.set("v.isSearching",false);
        }
    },
    validate : function(component) {
        if(component.get("v.validate")){
            var errors = component.get("v.errors");
            errors[component.get("v.index")] = component.get("v.required") ? (component.get("v.value") ? true : false) : true;
            component.set("v.errors",errors); 
        }
    }
})