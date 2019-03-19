({
	generateQuery : function(component,onsuccess,onerror) {
        var query;
        if(component.get("v.query")){
            query = component.get("v.query");
        }else{
            query = "Select "+component.get("v.fields").join(",")+" From "+component.get("v.sObjectName");
        }
        
        if(component.get("v.searchKeyword") && component.get("v.searchFields") && component.get("v.searchFields").length>0){
            var helper = this;
            var criterias = [];
            criterias = helper.getSearchCriteria(component);
            var strJoinedCriteria = criterias.join(' OR ');
            if(component.get("v.query")){
                query = helper.joinLikeCriteria(query,strJoinedCriteria);
            }else if(criterias.length > 0){
                query += (" WHERE "+strJoinedCriteria);
            }
        }
        if(component.get("v.sortedBy")){
            query += (" Order By "+(component.get("v.mapOfFieldName")[component.get("v.sortedBy")] ? component.get("v.mapOfFieldName")[component.get("v.sortedBy")] : component.get("v.sortedBy"))+" "+component.get("v.sortedDirection")+" NULLS LAST");
        }
		
        query += " LIMIT "+component.get("v.offset");
        component.find("utils").execute("c.getQueryData",{"query":query},function(records){
            onsuccess(records);
        },function(error){
            onerror(error);
        });
	},
    setData:function(component, helper){
        component.find("datatable").set("v.isLoading", true);
        if(component.get("v.isDynamicLoading")){
            helper.generateQuery(component, function(records){
                helper.processRecords(component, helper, records);
                component.set("v.enableInfiniteLoading",!(component.get("v.searchKeyword") || records.length < component.get("v.offset")));
                //component.set("v.isLimitExceed", component.get("v.searchKeyword") ? true : (records.length < component.get("v.offset")));
                component.find("datatable").set("v.isLoading", false);
            },function(error){
                component.find("utils").showError(error);
                component.find("datatable").set("v.isLoading", false);
            });
        }else{
            var data = component.get("v.data");
            data = helper.filterData(component, data);
            data = helper.sortData(component, data);
            helper.processRecords(component, helper, data);
            component.find("datatable").set("v.isLoading", false);
        }
    },
    filterData:function(component,data){
        if(component.get("v.searchKeyword")){
            let searchFields = component.get("v.searchFields");
            let keyword = component.get("v.searchKeyword").toLowerCase();
            
            if(!(searchFields && searchFields.length > 0)){
                searchFields = new Set();
                component.get("v.meta").forEach(function(metadata){
                    searchFields.add((metadata.typeAttributes && metadata.typeAttributes.label) ? (metadata.typeAttributes.label.fieldName ? metadata.typeAttributes.label.fieldName : metadata.typeAttributes.label) : (metadata.name ? metadata.name : metadata.fieldName));
                });
                searchFields = Array.from(searchFields);
                component.set("v.searchFields",searchFields);
            }
            var filteredData = data.filter(function(record){
                return searchFields.some(function(field){
                    return (record[field] && record[field].toLowerCase().includes(keyword));
                });
            });
            return filteredData;
        }else{
            return data;
        }
    },
    sortData:function(component,data){
        var reverse = component.get("v.sortedDirection") !== 'asc';
        data.sort(this.sortBy(component.get("v.sortedBy"), reverse))
        return data;
    },
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
            function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },
    processRecords:function(component,helper,records){
        var mapRecords = {};
        var key = component.get("v.key");
        var conditions = component.get("v.highlightRowsOn");
        var relationshipMeta = component.get("v.relationshipMeta");
        var selectedRows = component.get("v.selectedRows");
        var relationshipMetaFlag = relationshipMeta && relationshipMeta.length > 0;
        
       records.forEach(function(record,index){
            mapRecords[record[key]] = index;
            
            /* highlight row logic */
            if(conditions && helper.executeCondition(conditions.condition,conditions.key,record)){
                record["ClassName"] = "highlightRow"; 
            }
            
            /* replace relationship field */
            if(relationshipMetaFlag){
                relationshipMeta.forEach(function(meta){
                    record[meta.replaceWith] = helper.resolve(meta.apiName,record);
                });
            }
        });
        
        if(selectedRows && !selectedRows.includes('[]')){
            let lastIndex =  records.length;
            for(let index = 0; index < selectedRows.length; ++index){
                if(!mapRecords[selectedRows[index][key]]){
                    mapRecords[selectedRows[index][key]] = lastIndex;
                    records.push(selectedRows[index]);
                    ++lastIndex;
                }
            }
        }
        
        component.set("v.mapRecords",mapRecords);
        component.set("v.records",records);
    },
    resolve:function(path, obj){
        return path.split('.').reduce(function(prev, curr) {
            return prev ? prev[curr] : null
        }, obj || self);
    },
    saveDraft:function(component){
        var draft = component.find("datatable").get("v.draftValues");
        var mapRecords = component.get("v.mapRecords");
        draft.forEach(function(record){
            for(var field in record){
                if(field!=component.get("v.key")){
                    component.set(("v.records["+mapRecords[record[component.get("v.key")]]+"]."+field),record[field]);
                }
            }
        });
        component.find("datatable").set("v.draftValues",undefined);
    },
    executeCondition:function(condition,key,record){
        if(condition.includes(">")){
            return (record[key] > condition.split(">")[1]);
        }else if(condition.includes("<")){
            return (record[key] < condition.split("<")[1]);
        }else if(condition.includes(">=")){
            return (record[key] >= condition.split(">=")[1]);
        }else if(condition.includes("<=")){
            return (record[key] <= condition.split("<=")[1]);
        }else if(condition.includes("!=")){
            return (record[key] != condition.split("!=")[1]);
        }else if(condition.includes("==")){
            return (record[key] == condition.split("==")[1]);
        }
    },
    checkForSelectedRows:function(component){
        if(component.get("v.checkSelectedRows") && component.get("v.selectedRows") && component.get("v.selectedRows").length > 0 ){
            var selectedRows = [];
            var preSelectedRows = [];
            if(component.get("v.mapRecords") && Object.keys(component.get("v.mapRecords")).length > 0){
                var mapRecords = component.get("v.mapRecords");
                component.get("v.selectedRows").forEach(function(keyfield){
                    if(mapRecords[keyfield] != undefined){
                        preSelectedRows.push(keyfield);
                        selectedRows.push(component.get("v.records")[mapRecords[keyfield]]);
                    }
                });
            }
            if(selectedRows.length > 0){
                component.set("v.selectedRows",selectedRows);
                component.set("v.preSelectedRows",preSelectedRows);
            }
        }else{
            component.set("v.selectedRows",[]);
            component.set("v.preSelectedRows",[]);
        }
        component.set("v.checkSelectedRows",false);
    },
    getSearchCriteria:function(component){
        var criterias = [];
        component.get("v.searchFields").forEach(function(field){
            criterias.push(field+" LIKE '%"+ component.find("utils").addSlashes(component.get("v.searchKeyword")) +"%'");
        });
        return criterias;
    },
    joinLikeCriteria:function(query,strJoinedCriteria){
        if(query.toLowerCase().includes("where"))
            return query += " AND ("+strJoinedCriteria+") ";
        return query += " WHERE ("+strJoinedCriteria+") ";
    },
    filterMetaData:function(component){
        if(component.get("v.meta")){
            var meta = component.get("v.meta");
            if(component.get("v.rowActions") && component.get("v.rowActions").length > 0){
                meta.push({"type":"action","typeAttributes":{"rowActions":component.get("v.rowActions")}});
                component.set("v.meta",meta);
            }
            if(component.get("v.data") && !(component.get("v.query") || (component.get("v.sObjectName") && component.get("v.fields")))){
                component.set("v.isDynamicLoading", false);
            }
            if(component.get("v.meta").length > 0){
                component.set("v.sortedBy",meta[0].fieldName);
                var relationshipMeta = [];
                var listOfFields = [];
                var mapOfFieldName = {}; 
                
                meta.forEach(function(metadata){
                    let newFieldNameValue;
                    
                    if(metadata.isMeataModified && !listOfFields.includes(metadata.originalFieldName.toLowerCase())){
                        relationshipMeta.push({"apiName": metadata.originalFieldName, "replaceWith": metadata.fieldName});
                        listOfFields.push(metadata.originalFieldName.toLowerCase());
                    }else if(metadata.fieldName && metadata.fieldName.includes(".")){
                        if(!listOfFields.includes(metadata.fieldName.toLowerCase())){
                            relationshipMeta.push({"apiName":metadata.fieldName,"replaceWith":metadata.fieldName.replace(/\./g,"")});
                            listOfFields.push(metadata.fieldName.toLowerCase());
                        }
                        metadata.originalFieldName = metadata.fieldName;
                        metadata.fieldName = metadata.fieldName.replace(/\./g,"");
                        metadata.isMeataModified = true;
                        newFieldNameValue = metadata.originalFieldName;
                    }
                    if(metadata.typeAttributes && metadata.typeAttributes.label){
                        let type = typeof(metadata.typeAttributes.label) == "object" ? ((metadata.typeAttributes.label.fieldName && metadata.typeAttributes.label.fieldName.includes(".")) ? "object" : "") : ((typeof(metadata.typeAttributes.label) == "string" && metadata.typeAttributes.label.includes(".") ) ? "string" : ""); 
                        if(type){
                            let apiName;
                            switch(type) {
                                case "object":
                                    apiName = metadata.typeAttributes.label.fieldName;
                                    metadata.typeAttributes.label.fieldName = apiName.replace(/\./g,"");
                                    newFieldNameValue = apiName;
                                    break;
                                case "string":
                                    apiName =  metadata.typeAttributes.label;
                                    metadata.typeAttributes.label = apiName.replace(/\./g,"");
                                    newFieldNameValue = apiName;
                                    break;
                            }
                            metadata.name = apiName.replace(/\./g,"");
                            if(apiName && !listOfFields.includes(apiName.toLowerCase())){
                                relationshipMeta.push({"apiName":apiName,"replaceWith":apiName.replace(/\./g,"")});
                                listOfFields.push(apiName.toLowerCase());
                            }
                        }else{
                            newFieldNameValue = typeof(metadata.typeAttributes.label) == "object" ? metadata.typeAttributes.label.fieldName : metadata.typeAttributes.label;
                        }
                    }
                    
                    if(metadata.type == 'url'){
                        metadata.type = 'button';
                        metadata.typeAttributes = Object.assign({variant:'base',name:'urlHandler',field:metadata.fieldName}, metadata.typeAttributes);
                    }
                    
                    if(component.get("v.highlightRowsOn") && Object.keys(component.get("v.highlightRowsOn")).length == 2){
                        metadata["cellAttributes"] = {"class":{"fieldName":"ClassName"}};
                    } 
                    if(newFieldNameValue)
                        mapOfFieldName[metadata.fieldName] = newFieldNameValue;
                });
                component.set("v.mapOfFieldName",mapOfFieldName);
                component.set("v.meta",meta);
                if(relationshipMeta.length > 0){
                    component.set("v.relationshipMeta",relationshipMeta);
                }
            }
        }
    }
})