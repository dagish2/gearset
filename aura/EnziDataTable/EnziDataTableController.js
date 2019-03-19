({
    doInit : function(component, event, helper) {
        if(component.get("v.sObjectName") && component.get("v.sObjectName")!=''){
            helper.getDesribedFields(component,function(describedFields){
                component.set("v.describedFields",describedFields);
                helper.filterData(component,function(filteredRecords){
                    helper.setSelectedRecords(component,filteredRecords);
                })
            })
        }else{
            helper.filterData(component,function(filteredRecords){
				helper.setSelectedRecords(component,filteredRecords);
            })
        }
    },
    search:function(component, event, helper){        
        component.set("v.keyword",event.currentTarget.value?event.currentTarget.value.trim():"");      
        component.set("v.currentPage",1);
        if(!component.get("v.isCustomSearch")){
            helper.filterData(component,function(filteredRecords){
                helper.setSelectedRecords(component,filteredRecords);
            }); 
        }       
    },
    first:function(component, event, helper){
        component.set("v.currentPage",1);
        helper.filterData(component,function(filteredRecords){
            helper.setSelectedRecords(component,filteredRecords);
        })
    },
    prev:function(component, event, helper){
        component.set("v.currentPage",component.get("v.currentPage")-1);
        helper.filterData(component,function(filteredRecords){
            helper.setSelectedRecords(component,filteredRecords);
        })
    },
    next:function(component, event, helper){
        component.set("v.currentPage",component.get("v.currentPage")+1);
        helper.filterData(component,function(filteredRecords){
            helper.setSelectedRecords(component,filteredRecords);
        })
    },
    last:function(component, event, helper){
        component.set("v.currentPage",component.get("v.pages").length);
        helper.filterData(component,function(filteredRecords){
            helper.setSelectedRecords(component,filteredRecords);
        })
    },
    pageSizeChanges:function(component, event, helper){
        component.set("v.currentPage",1);
        component.set("v.pageSize",parseInt(event.currentTarget.value));
        helper.filterData(component,function(filteredRecords){
            helper.setSelectedRecords(component,filteredRecords);
        })
    },
    pageChanged:function(component, event, helper){
        component.set("v.currentPage",parseInt(event.currentTarget.value));
        helper.filterData(component,function(filteredRecords){
            helper.setSelectedRecords(component,filteredRecords);
        })
    },
    sortByName:function(component,event,helper){
        if(event.currentTarget.getAttribute("data-sort")!="false"){
            var fieldName = event.currentTarget.getAttribute("data-field");
            if(component.get("v.sortBy")==fieldName){
                if(component.get("v.sortOrder")=="asc"){
                    component.set("v.sortOrder","desc");
                }else{
                    component.set("v.sortOrder","asc");
                }
            }else{
                component.set("v.sortOrder","asc");
            }
            component.set("v.sortBy",fieldName);
            helper.filterData(component,function(filteredRecords){
                helper.setSelectedRecords(component,filteredRecords);
            })
        }
    },
    selectRow:function(component, event, helper){
        var index = parseInt(event.currentTarget.id.split(":")[1]);
        var key = component.get("v.filteredRecords")[index][component.get("v.keyField")];
        var selectedRecords = component.get("v.selectedRecords");
        if(event.currentTarget.checked){
            selectedRecords.push(key);
        }else{
            selectedRecords.splice(selectedRecords.indexOf(key),1);  
        }
        component.set("v.selectedRecords",JSON.parse(JSON.stringify(selectedRecords)));
    },
    selectAll:function(component,event,helper){
        var selectedRecords = component.get("v.selectedRecords");
        var filteredRecords = component.get("v.filteredRecords");
        if(event.currentTarget.checked){
            for(var f in filteredRecords){
                if(!selectedRecords.includes(filteredRecords[f][component.get("v.keyField")])){
                    selectedRecords.push(filteredRecords[f][component.get("v.keyField")]);
                }
                component.get("v.filteredRecords")[f].selected=true;
            }
        } 
        else{
           for(var f in filteredRecords){
                if(selectedRecords.includes(filteredRecords[f][component.get("v.keyField")])){
                    selectedRecords.splice(selectedRecords.indexOf(filteredRecords[f][component.get("v.keyField")]),1);
                }
                component.get("v.filteredRecords")[f].selected=false;
            }
        }
        component.set("v.filteredRecords",filteredRecords);
	},
    dataChangHandler:function(component, event, helper){
        component.set("v.currentPage",1);
        helper.dataChanged(component, event, helper);
    },
    dataChanged:function(component, event, helper){
        helper.dataChanged(component, event, helper);
    },
    startRendering:function(component,event,helper){
        component.find("utils").showProcessing();
    },
    doneRendering:function(component,event,helper){
        component.find("utils").hideProcessing();
    },
    highlightRow:function(component,event,helper){
        var exp = component.get("v.highlight");
        if(exp){
            let lstOfKeys = Object.keys(exp)
            let records = component.get("v.filteredRecords");
            if(records && records.length){
                setTimeout(function(){
                    for(var index in records){
                        lstOfKeys.forEach(function(key,count) {
                            if(helper.parseExpression(records[index], key.trim())){
                                var row = document.querySelector('tr[data-index="'+index+'"]');
                                if(row){
                                    document.querySelector('tr[data-index="'+index+'"]').classList.add(exp[key].trim());
                                }
                            }else{
                                var row = document.querySelector('tr[data-index="'+index+'"]');
                                if(row){
                                    document.querySelector('tr[data-index="'+index+'"]').classList.remove(exp[key].trim());
                                }
                            }
                        });
                    }  
                },1000);
            }
        }
    }
})