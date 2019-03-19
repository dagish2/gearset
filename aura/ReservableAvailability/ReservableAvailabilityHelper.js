({
	getSavedPresets : function(component,user,onsuccess) {
        if(localStorage.getItem("presets")){
          onsuccess(JSON.parse(localStorage.getItem("presets")));
        }else{
            component.find("utils").execute("c.getQueryData",{"query":"Select Id,Name,Available_From__c,Buildings__c,City__c,Maximum_Capacity__c,Maximum_Price_Range__c,Minimum_Capacity__c,Minimum_Price_Range__c,Show_Records__c,Unit_Type__c,Include_Pending_Contract__c from Reservable_View__c where Only_for_me__c=false OR (Only_for_me__c=true AND CreatedById='"+(user.Id)+"')"},function(views){
                localStorage.setItem("presets",JSON.stringify(views));
                onsuccess(views);
            },function(error){
                component.find("utils").showError(error);
            })
        }
        
	},
    getSavedBuildings : function(component,onsuccess) {
        if(localStorage.getItem("buildings")){
           onsuccess(JSON.parse(localStorage.getItem("buildings")));
        }else{
            component.find("utils").execute("c.getQueryData",{"query":"Select Id,Name,City__c,UUID__c from Building__c"},function(buildings){
                localStorage.setItem("buildings",JSON.stringify(buildings));
                onsuccess(buildings);
            },function(error){
                component.find("utils").showError(error);
            })
        }
        
	},
    getReservables:function(component){
        component.find("utils").showProcessing();
        var requestData = {};
        var locationUUID = [];
        if(component.get("v.view.Buildings__c")){
            component.get("v.view.Buildings__c").split(";").forEach(function(building){
                if(component.get("v.allBuildings").findIndex(function(b){return b.Name==building})!=-1){
                    locationUUID.push(component.get("v.allBuildings")[component.get("v.allBuildings").findIndex(function(ab){return ab.Name==building})].UUID__c)
                }
            })
        }
        if (locationUUID.length > 0){
            requestData.location_uuids = locationUUID;
        } 
        else{
            requestData.city =  component.get("v.view.City__c")
        }
        if (component.get("v.view.Include_Pending_Contract__c") == 'Yes'){
            requestData.show_pending_contracts = true;
        }
        else{
            requestData.show_pending_contracts = false;
        }
        if (component.get("v.view.Show_Records__c") == 'Available'){
            requestData.show_unavailable = false;
        }
        else{
            requestData.show_unavailable = true;
        }
        if(component.get("v.view.Show_Records__c"))
        	requestData.include_pending_contracts = component.get("v.view.Show_Records__c");
        if(component.get("v.view.Unit_Type__c")){
            requestData.types = component.get("v.view.Unit_Type__c").split(";");
        }
        if(component.get("v.view.Minimum_Capacity__c") && component.get("v.view.Minimum_Capacity__c")!='')
        	requestData.min_capacity = component.get("v.view.Minimum_Capacity__c");
        if(component.get("v.view.Maximum_Capacity__c") && component.get("v.view.Maximum_Capacity__c")!='')
        	requestData.max_capacity = component.get("v.view.Maximum_Capacity__c");
        if(component.get("v.view.Minimum_Price_Range__c") && component.get("v.view.Minimum_Price_Range__c")!='')
        	requestData.min_price = component.get("v.view.Minimum_Price_Range__c");
        if(component.get("v.view.Maximum_Price_Range__c") && component.get("v.view.Maximum_Price_Range__c")!='')
        	requestData.max_price = component.get("v.view.Maximum_Price_Range__c");
        if(component.get("v.view.Available_From__c") && component.get("v.view.Available_From__c")!='')
        	requestData.available_date = component.get("v.view.Available_From__c");
        requestData.per_page = component.get("v.pageSize");
        requestData.page = component.get("v.currentPage")-1;
        requestData.summary = false;
        console.log(requestData);
        var url = JSON.parse(JSON.stringify(component.get("v.reservableApiData"))).ReservableAvailabilityAPI.url;
        var headers = {"Content-Type":"application/json","Authorization":component.get("v.reservableApiData").ReservableAvailabilityAPI.headers.Authorization};
        component.find("utils").execute("c.executeRest",{"method":"POST","endPointUrl":url,"headers":headers,"body":JSON.stringify(requestData)},function(response){
            var records = [];
            var allBuildings = component.get("v.allBuildings");
            var mapBuildings = {};
            for(var b in allBuildings){
                mapBuildings[allBuildings[b].UUID__c] = allBuildings[b];
            }
            JSON.parse(response).result.data.forEach(function(record){
                if(record.next_available_date>0){
                    var next_available_date = new Date(record.next_available_date * 1000);
                    record.next_available_date = next_available_date.getFullYear()+"-"+(next_available_date.getMonth()+1)+"-"+next_available_date.getDate();
                }else{
                    record.next_available_date = undefined;
                }
                if(record.hold_expires>0){
                    var hold_expires = new Date(record.hold_expires * 1000);
                    record.hold_expires = hold_expires.getFullYear()+"-"+(hold_expires.getMonth()+1)+"-"+hold_expires.getDate();
                }else{
                    record.hold_expires = undefined;
                }
                if(record.hold_expires!=undefined && new Date(record.hold_expires).getTime()<new Date(new Date().getFullYear()+"-"+(new Date().getMonth()+1)+"-"+new Date().getDate()).getTime()){
                     record.on_hold = "Yes";
                }else{
                     record.on_hold = "No";
                }
                if(mapBuildings.hasOwnProperty(record.location_uuid)){
                    record.id = mapBuildings[record.location_uuid].Id.substring(0,15);
                }
               	records.push(JSON.parse(JSON.stringify(record)));
            })
            component.set("v.reservables",records);
            component.set("v.totalRecords",JSON.parse(response).result.count);
            component.set("v.totalPages",JSON.parse(response).result.total_pages);
            component.find("utils").hideProcessing();
        },function(error){
            console.log(error);
            component.find("utils").hideProcessing();
        })
    }
})