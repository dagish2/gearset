({
	getDesribedFields : function(component,onsuccess) {
        component.find("utils").execute("c.describeTable",{"sObjectName":component.get("v.sObjectName"),"fields":component.get("v.fields")},function(response){
           	var arrDescribedFields = component.get("v.describedFields");
            var mapFields = JSON.parse(response);
            if(arrDescribedFields && arrDescribedFields.length>0){
                for(var d in arrDescribedFields){
                    if(arrDescribedFields[d] && arrDescribedFields[d].name && mapFields.hasOwnProperty(arrDescribedFields[d].name)){
                        if(arrDescribedFields[d].label){
                            mapFields[arrDescribedFields[d].name].label = arrDescribedFields[d].label;
                        }
                    }
                }
            }
            var fields = component.get("v.fields");
            var describedFields = [];
            fields.forEach(function(field){
                if(mapFields[field]){
                    var f = mapFields[field];
                    f.apiName = field;
                    describedFields.push(f);
                }
            })
            /*Code for Popover Component on any field*/
            arrDescribedFields.forEach(function(record){
                if(record.hasOwnProperty("showPopover")){
                    var index = describedFields.findIndex(x => x.apiName==record.name);
                    var obj = describedFields[index];
                    obj.showPopover = record.showPopover;
                    obj.popoverIcon = record.popoverIcon;
                    if(record.hasOwnProperty("isDynamicTitle")){
                        obj.isDynamicTitle = record.isDynamicTitle;
                    }
                    if(record.hasOwnProperty("sObjectName")){
                        obj.sObjectName = record.sObjectName;
                    }
                    if(record.hasOwnProperty("fields")){
                        obj.fields = record.fields;
                    }
                    if(record.hasOwnProperty("fieldsMeta")){
                        obj.fieldsMeta = record.fieldsMeta;
                    }
                    if(record.hasOwnProperty("idField")){
                        obj.idField = record.idField;
                    }
                    describedFields[index]=obj;
                }
            })
            /*End of Popover code*/
            onsuccess(describedFields);
        },function(error){
            console.log(error);
        })
	},
    filterData:function(component,onsuccess){
        if(component.get("v.sObjectName") && component.get("v.sObjectName")!=''){
             this.getQueryFilteredRecords(component,onsuccess);
        }else{
            this.getFilteredRecords(component,onsuccess);
        }
    },
    getFilteredRecords:function(component,onsuccess){
        var filteredData = [];
        var pagedData = [];
        var data = component.get("v.records");
        var keyword = component.get("v.keyword");
        var fields = [];
        if(component.get("v.searchFields") && component.get("v.searchFields").length>0){
            fields = JSON.parse(JSON.stringify(component.get("v.searchFields")));
        }else{
            for(var i=0;i<component.get("v.describedFields").length;i++){
                fields.push(component.get("v.describedFields")[i].name);
            }
        }
        if(component.get("v.showSearch") && keyword && keyword!=''){
            filteredData = data.filter(function(record){
                for(var i=0;i<fields.length;i++){
                    var val = record;
                    var arrFields = fields[i].split(".");
                    for(var f in arrFields){
                        if(val){
                            val = val[arrFields[f]];   
                        }              
                    }
                    if(val && (val+'').toLowerCase().includes(keyword.toLowerCase())){
                        return true;
                    }
                }
            })
        }else{
            filteredData = data;
        }
        if(component.get("v.sortBy")){
            filteredData = this.sortRecords(filteredData, component.get("v.sortBy"), component.get("v.sortOrder") ? component.get("v.sortOrder") : "asc", component.get("v.tourDatetimeSort"), this);
        }
        if(component.get("v.showPagination")){
            var offset = ((component.get("v.currentPage") * component.get("v.pageSize")) - component.get("v.pageSize"));
            pagedData = filteredData.slice(offset,offset+component.get("v.pageSize"));            
            var pages = [];
            for(var i=1;i<=Math.ceil(filteredData.length/component.get("v.pageSize"));i++){
                pages.push(i);
            }
            component.set("v.pages",pages);
        }else{
            pagedData = filteredData;
        }
        component.set("v.totalRecords",filteredData.length);
        onsuccess(pagedData);
    },
    getQueryFilteredRecords:function(component,onsuccess){
        component.find("utils").showProcessing();
        var query;
        if(component.get("v.query")){
            query = component.get("v.query");
        }else{
             query = 'Select '+component.get("v.fields").join(",")+' From '+component.get("v.sObjectName");
        }
        var fields;
        if(component.get("v.searchFields") && component.get("v.searchFields").length>0){
            fields = JSON.parse(JSON.stringify(component.get("v.searchFields")));
        }else{
            fields = JSON.parse(JSON.stringify(component.get("v.fields")));
        }
        if(component.get("v.showSearch") && component.get("v.keyword") && component.get("v.keyword")!=''){
            var setParanthesis = false;
            if(!query.toLowerCase().includes("where"))
            	query += ' Where ';
            else{
                query += ' AND (';
                setParanthesis = true;
            }   
            for(var f in fields){
                if(fields[f].toLowerCase()!='id'){
                    var helper = this;
                    var keyword = component.find("utils").addSlashes(component.get("v.keyword"));
                    query += fields[f]+' LIKE \'%'+keyword+'%\' '
                    if(parseInt(f)<fields.length-1){
                        query += ' OR '
                    }
                }
            }
            if(setParanthesis){
                query += ' ) ';
            }
        }
        if(component.get("v.sortBy") && (!query.toLowerCase().includes('limit 0'))){
            query += ' Order By '+component.get("v.sortBy")+' '+(component.get("v.sortOrder")?component.get("v.sortOrder"):"asc");
        }
        if(component.get("v.showPagination")){
            if(!query.toLowerCase().includes('limit')){
                query += ' LIMIT '+component.get("v.pageSize");
            }
            var offset = ((component.get("v.currentPage") * component.get("v.pageSize")) - component.get("v.pageSize"));
            query += ' Offset '+offset;
        }       
        console.log('Query==>'+query);
            component.find("utils").execute("c.getTableData",{"query":query},function(response){
                component.set("v.totalRecords",response.totalRecords);
                if(component.get("v.showPagination")){
                    var pages = [];
                    if(response.records.length>0){
                        for(var i=1;i<=Math.ceil(response.totalRecords/component.get("v.pageSize"));i++){
                            pages.push(i);
                        }
                    }
                    component.set("v.pages",pages);
                }
                component.find("utils").hideProcessing();
                onsuccess(response.records);
            },function(error){
                component.find("utils").showError(error);            
            })         
    },
    sortRecords:function(records, sortBy, sortOrder, tourDatetimeSort, currentExecutionContext){
        var columnsToSort = tourDatetimeSort ? tourDatetimeSort.split(';') : null;
        records.sort(function(a,b){
            var dataA,dataB;
            dataA = a;
            dataB = b;
            if(sortBy.includes(";")){
                var dataAFound = false;
                var dataBFound = false;
                sortBy.split(";").forEach(function(fieldName){
                    if(!dataA && !dataAFound){
                       dataA = a; 
                    }
                    if(!dataB && !dataBFound){
                        dataB = b;
                    }
                    if(dataA && !dataAFound){
                    	dataA = dataA[fieldName]?dataA[fieldName]:sortBy.includes(".")?currentExecutionContext.getValuesFromFieldName(fieldName,dataA):undefined;
                        dataAFound = (typeof(dataA) != 'object' && typeof(dataA) != 'undefined')?true:false;
                    }
                    if(dataB && !dataBFound){
                        dataB = dataB[fieldName]?dataB[fieldName]:sortBy.includes(".")?currentExecutionContext.getValuesFromFieldName(fieldName,dataB):undefined;
                        dataBFound = (typeof(dataB) != 'object' && typeof(dataB) != 'undefined')?true:false;
                    }
                })             
            }else if(sortBy.includes(".")){
                if(dataA){
                    dataA = currentExecutionContext.getValuesFromFieldName(sortBy,dataA);
                }
                if(dataB){
                    dataB = currentExecutionContext.getValuesFromFieldName(sortBy,dataB);
                }
            }else if(columnsToSort && columnsToSort.length && columnsToSort.indexOf(sortBy) > -1){
                var Date_To_Format1 = currentExecutionContext.convertTime12to24(a[columnsToSort[1]]);
                var Date_To_Format2 = currentExecutionContext.convertTime12to24(b[columnsToSort[1]]);
                dataA = Date.parse(a[columnsToSort[0]]+' '+Date_To_Format1);
                dataB = Date.parse(b[columnsToSort[0]]+' '+Date_To_Format2);
            }else{
                dataA = a[sortBy];
                dataB = b[sortBy];
            }
            if(dataA != null && dataA != undefined && dataB != null && dataB != undefined){
                if(typeof(dataA) == "number" && typeof(dataB) == "number"){
                    var t1 = (dataA?dataA:dataA) == (dataB?dataB:dataB), t2 = (dataA?dataA:dataA) < (dataB?dataB:dataB);
                    return t1? 0: (sortOrder=="asc"?-1:1)*(t2?1:-1);
                }
                else{
                    var t1 = (dataA?dataA.toLowerCase():dataA) == (dataB?dataB.toLowerCase():dataB), t2 = (dataA?dataA.toLowerCase():dataA) < (dataB?dataB.toLowerCase():dataB);
                    return t1? 0: (sortOrder=="asc"?-1:1)*(t2?1:-1);
                }   
            }else{
                if(!dataA && !dataB){
                    return 0;
                }else if(!dataA){
                    return (sortOrder=="asc"?-1:1);
                }else{
                    return (sortOrder=="asc"?1:-1);
                }
            }
        })
        return records;
    },
    setSelectedRecords:function(component,records){
      if(component.get("v.showMultiselect") || (component.get("v.selectedRecords") && Array.isArray(component.get("v.selectedRecords")) && component.get("v.selectedRecords").length > 0)){
            var selectedRecords = component.get("v.selectedRecords");
            var selectAll = true;
            records.forEach(function(record){
                selectedRecords.forEach(function(selected){
                    if(selected==record[component.get("v.keyField")]){
                        record.selected = true;
                    }
                })
            })
            for(var r in records){
                if(!records[r].selected){
                    selectAll = false;
                    break;
                }
            }
            if(component.getElements().length>=3){
                component.getElements()[3].querySelector("#selectAll").checked = selectAll;
            }
        }
        if(records.length>0 && records[0]!=undefined){
            component.set("v.filteredRecords",records);       
        }else{
            component.set("v.filteredRecords",[]);       
        }
        setTimeout(function(){
            var data = [];
            for(var r in records){
                if(records[r]!=undefined){
                    data.push(records[r]);
                }
            }
            if(data.length>0){
                component.set("v.filteredRecords",data);       
            }else{
                component.set("v.filteredRecords",[]);       
            }
        },100)
        
    },
    dataChanged:function(component,event,helper){
        helper.filterData(component,function(filteredRecords){
            helper.setSelectedRecords(component,filteredRecords);
        })
    },
    parseExpression:function(record,exp){
        var arrExpressions = this.getDynamicExpression(exp);
        if(record){
            for(var ex in arrExpressions){
                if(arrExpressions[ex].includes(".")){
                    if(arrExpressions[ex].split(".").length==2){
                        var subExp = arrExpressions[ex].split(".");
                        if(record[subExp[0]] && record[subExp[0]][subExp[1]]){
                            exp = exp.replace('{{'+arrExpressions[ex]+'}}',"'"+record[subExp[0]][subExp[1]]+"'");
                            return eval(exp);
                        }else{
                            return false;
                        }
                    }
                }else{
                    let expToReplace = new RegExp('{{'+arrExpressions[ex]+'}}','g');
                    exp = exp.replace(expToReplace,"'"+record[arrExpressions[ex]]+"'");
                    return eval(exp);
                }
            } 
        }
    },
    getDynamicExpression:function(exp){
        var re = new RegExp('[^{\}]+(?=})','g');
        var expressions = exp.match(re);
        return expressions;
    },
    convertTime12to24:function(time12h){
        var [hours, minutes] = time12h.split(':');
        if (hours === '12') {
            hours = '00';
        }
        minutes = minutes.replace(/\s/g, '');
        if (minutes.substring(4,2).toLowerCase() === 'pm') {
            hours = parseInt(hours, 10) + 12;
        }
        return hours + ':' + minutes.substring(0,2) + ':00';
    },
    getValuesFromFieldName:function(fieldName,record){
        var data = record;
        fieldName.split(".").forEach(function(f){
            if(data){
                data = data[f];
            }
        })
        return data;
    }
})