({
    getFilteredData:function(component,helper){
        var filteredData = [];
        var data = component.get("v.records");
        var fields = []; 
        if(component.get("v.isStatic")){
            component.get("v.describedFields").forEach(function(field){
                fields.push(field.apiName);
            })
        }else{
            fields = component.get("v.displayFields");
        }
        var keyword = component.get("v.keyword");
        if(keyword && keyword!=''){
            filteredData = data.filter(function(record){
                for(var i=0;i<fields.length;i++){
                    if(record[fields[i]] && (record[fields[i]]+'').toLowerCase().includes(keyword.toLowerCase())){
                        return true;
                    }
                }
            })
        }else{
            filteredData = data;
        }
        if(component.get("v.sortBy")){
            return helper.sortRecords(filteredData,component.get("v.sortBy"),component.get("v.sortOrder")?component.get("v.sortOrder"):"asc");
        }else{
            return filteredData;
        }
        
    },
    setPageData:function(component,helper,onsuccess){
        var searchFilteredData = helper.getFilteredData(component,helper);
        var currentPage = component.get("v.currentPage");
        var pageSize = component.get("v.pageSize");
        var offset,filteredData;
        if(component.get("v.isStatic")){
            filteredData = searchFilteredData;
        }else{
            component.set("v.totalRecords",searchFilteredData.length);
            component.set("v.totalPages",Math.ceil(searchFilteredData.length/pageSize));
            offset = ((currentPage * pageSize) - pageSize);
            filteredData = searchFilteredData.slice(offset,(offset+pageSize));
        }
        component.set("v.filteredRecords",filteredData);
        if(onsuccess)
            onsuccess();
    },
    generateQuery:function(component,helper){
        var query = 'Select Id,';
        var fields = [];
        if(component.get("v.displayFields")){
            for(var i=0;i<component.get("v.displayFields").length;i++){
                if(fields.indexOf(component.get("v.displayFields")[i])==-1){
                    fields.push(component.get("v.displayFields")[i])
                }
            }
        }
        query += fields.join(",")+" From "+component.get("v.sObjectName");
        return query;
    },
    getTableData:function(component,helper,onsuccess){
        if(component.get("v.isStatic")){
            helper.setPageData(component,helper,function(){
                onsuccess();
            });
        }else{
            var query;
            if(component.get("v.query"))
                query = component.get("v.query");
            else
                query = helper.generateQuery(component,helper);
            component.find("utils").execute("c.getTableData",{"query":query},function(response){
                component.set("v.records",response.records);
                helper.setPageData(component,helper,function(){
                    onsuccess();
                });
            },function(error){
                component.find("utils").showError(error);
            })
        }
    },
    getData:function(component,helper,onsuccess){
        helper.getTableData(component,helper,function(){
            component.find("utils").hideProcessing();
            onsuccess();
        })    
    },
    setSelectedRecords:function(component){
        var selectedRecords = component.get("v.selectedRecords");
        selectedRecords.forEach(function(record){
            component.set("v.filteredRecords["+component.get("v.filteredRecords").findIndex(x => x.Id==record.Id)+"].selected",true);
            component.set("v.records["+component.get("v.records").findIndex(x => x.Id==record.Id)+"].selected",true);
        })
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