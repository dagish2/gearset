({
    doInit: function(component, event, helper){
        component.set("v.utils", component.find("utils"));
    },
    search: function(component, event, helper){ 
        let params = event.getParam('arguments');
        if(params && params.keyword && params.keyword.length > 2){
            component.set("v.keyword", component.get("v.utils").addSlashes(params.keyword));
            component.get("v.utils").execute("c.getRecordsWithSOSLSearch",{"keywordToSearch":component.get("v.keyword"), "objWithFields":component.get("v.sObjectWithFields"), "strLimit":component.get("v.recordLimit"), "whereClause":component.get("v.whereClause")},function(response){      
                let data = [];
                let recordIcon = component.get("v.recordIcon");
                for(let row in response){
                    for(let column in response[row]){
                        response[row][column]["type"] = recordIcon[row];
                        data.push(response[row][column]);
                    }
                }                
                component.set("v.searchData", data);
                var listdiv = document.getElementById("listbox-unique-id");        
                $A.util.removeClass(listdiv, "slds-hide");
            },function(error){
                component.get("v.utils").showError(error);
                component.get("v.utils").hideProcessing();
            }, component)
        }
    },
    selectRecordFromList : function(component, event, helper) {
        let params = event.getParam('arguments');
        let searchData = component.get("v.sortedDataForList");
        let index = searchData.findIndex(p => p.Id == params.idToSearch);
        document.getElementById("searchLeadorContact").value = "";
        let a = document.getElementById("listbox-unique-id");        
        $A.util.addClass(a, "slds-hide");
        return 	searchData[index];
    }
})