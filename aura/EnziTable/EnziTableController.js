({
    doInit : function(component, event, helper){
        component.set("v.currentPage",1);
        if(!component.get("v.isStatic")){
            component.find("utils").execute("c.describeTable",{"sObjectName":component.get("v.sObjectName"),"fields":component.get("v.displayFields")},function(response){
                var mapFields = JSON.parse(response);
                var fields = component.get("v.displayFields");
                var describedFields = [];
                fields.forEach(function(field){
                    if(mapFields[field]){
                        var f = mapFields[field];
                        f.apiName = field;
                        describedFields.push(f);
                    }
                })
                component.set("v.describedFields",describedFields);
                helper.getData(component,helper,function(){
                    helper.setSelectedRecords(component);
                    component.find("utils").hideProcessing();
                });
            },function(error){
                console.log(error);
            })
        }else{
            if(component.get("v.describedFields")){
                helper.getData(component,helper,function(){
                    helper.setSelectedRecords(component);
                    component.find("utils").hideProcessing();
                });
            }
        }
	},
    selectRow:function(component, event, helper){
        var id = parseInt(event.currentTarget.id.split(":")[1]);
        component.set("v.filteredRecords["+id+"].selected",event.currentTarget.checked);
        component.set("v.records["+id+"].selected",event.currentTarget.checked);
        var selectedRecords = component.get("v.selectedRecords");
        if(!selectedRecords)
            selectedRecords = [];
        if(event.currentTarget.checked)
        	selectedRecords.push(component.get('v.filteredRecords')[id]);
        else
			selectedRecords.splice(selectedRecords.indexOf(selectedRecords[id]),1);  
        component.set("v.selectedRecords",JSON.parse(JSON.stringify(selectedRecords)));
    },
    selectAll:function(component,event,helper){
    	var filteredRecords = component.get("v.filteredRecords");
        for(var i=0;i<filteredRecords.length;i++){
            component.set("v.filteredRecords["+i+"].selected",event.currentTarget.checked);
        }
        if(event.currentTarget.checked)
            component.set("v.selectedRecords",JSON.parse(JSON.stringify(filteredRecords)));
        else
            component.set("v.selectedRecords",[]);
	},
    first:function(component, event, helper){
        component.find("utils").showProcessing();
        var currentPage = component.get("v.currentPage");
        currentPage = 1;
        component.set("v.currentPage",currentPage);
        helper.setPageData(component,helper,function(){
			component.find("utils").hideProcessing();            
        });
    },
    prev:function(component, event, helper){
        component.find("utils").showProcessing();
        var currentPage = component.get("v.currentPage");
        currentPage -= 1;
        component.set("v.currentPage",currentPage);
        helper.setPageData(component,helper,function(){
			component.find("utils").hideProcessing();            
        });
    },
    next:function(component, event, helper){
        component.find("utils").showProcessing();
        var currentPage = component.get("v.currentPage");
        currentPage += 1;
        component.set("v.currentPage",currentPage);
        helper.setPageData(component,helper,function(){
			component.find("utils").hideProcessing();            
        });
    },
    last:function(component, event, helper){
        component.find("utils").showProcessing();
        var currentPage = component.get("v.currentPage");
        currentPage = component.get('v.totalPages');
        component.set("v.currentPage",currentPage);
        helper.setPageData(component,helper,function(){
			component.find("utils").hideProcessing();            
        });
    },
    pageChange:function(component, event, helper){
        component.find("utils").showProcessing();
        component.set("v.pageSize",parseInt(event.target.value));
        component.set("v.currentPage",1);
        helper.setPageData(component,helper,function(){
			component.find("utils").hideProcessing();            
        });
    },
    search:function(component, event, helper){
        component.find("utils").showProcessing();
        component.set("v.keyword",event.target.value);
        component.set("v.currentPage",1);
        helper.setPageData(component,helper,function(){
			component.find("utils").hideProcessing();            
        });
    },
    sortByName:function(component,event,helper){
        component.find("utils").showProcessing();
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
        helper.setPageData(component,helper,function(){
			component.find("utils").hideProcessing();            
        });
    },
    setPageData:function(component,event,helper){
    	if(component.get("v.isStatic") && component.get("v.describedFields") && component.get("v.records")){
            helper.getData(component,helper,function(){
                helper.setSelectedRecords(component);
                component.find("utils").hideProcessing();
            });
        }
	},
    pageChanged:function(component,event,helper){
        component.set("v.currentPage",parseInt(event.currentTarget.value));
        helper.setPageData(component,helper,function(){
			component.find("utils").hideProcessing();            
        });
    },
    setPages:function(component,event,helper){
        if(component.get("v.totalPages")){
            var pages = [];
            for(var i=1;i<=component.get("v.totalPages");i++){
                pages.push(i);
            }
            component.set("v.pages",pages);
        }
    }
})