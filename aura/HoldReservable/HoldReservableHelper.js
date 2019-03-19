({
    closeWindow:function(component,event,helper){
        //component.find("utils").closeTab();
        component.find("utils").redirectToUrl("/"+component.get("v.recordId"), "", false);
    },
    searchReservables: function(component, event, helper, moveInDate, lstLocationUUID, minCapacity, maxCapacity,onSuccess){
        component.find("utils").showProcessing();
        if(component.get("v.settingData")){
            if(lstLocationUUID != null && lstLocationUUID.length > 0){
                var requestPayload = {
                    "available_date": moveInDate,
                    "location_uuids": lstLocationUUID,
                    "include_pending_contracts": "No",
                    "show_unavailable": false,
                    "min_capacity": minCapacity,
                    "max_capacity": maxCapacity,
                    "show_pending_contracts": false,
                    "types": ["DedicatedDesk", "HotDesk", "HotDeskArea", "Office", "SharedOfficeDesk", "Bed", "ResidentialUnit"],
                    "per_page": 1000,
                    "summary": false
                };
                console.log('Pay load for reservables search ::'+JSON.stringify(requestPayload));
                var settings = JSON.parse(JSON.stringify(component.get("v.settingData")));
                var url = settings.ReservableAvailabilityAPI.url;
                var headers = {"Content-Type":"application/json","Authorization":settings.ReservableAvailabilityAPI.Headers.Authorization};
                component.find("utils").execute("c.executeRest", {"method": "POST","endPointUrl": url,"headers": headers,"body": JSON.stringify(requestPayload)}, function(response){
                    response = JSON.parse(response);
                    if(response && response.result && response.result.data && response.result.data.length > 0){
                        response.result.data.forEach(function(res){
                            res["label"] = res.location_name+"-"+res.office_num+"("+res.capacity+")";
                        });
                        onSuccess(response.result.data);
                    }else if(response.hasOwnProperty('error')){
                        component.find("utils").showError(response.error);
                        component.set("v.buildingsReservables",[]);
                        component.find("utils").hideProcessing();
                    }else{
                        component.find("utils").showError('No Reservables Found for the Selected Building.');
                        component.set("v.buildingsReservables",[]);
                        component.find("utils").hideProcessing();
                    }
                },function(error){
                    component.find("utils").hideProcessing();
                    component.find("utils").showError(error);
                });
            }else{
                component.find("utils").hideProcessing();
                component.find("utils").showError('UUID not found for the building.');
            }
        }    
    },
    getReservables:function(component,event,helper){
        component.find("utils").showProcessing();
        var lstLocationUUIDS = [];
        if(component.get("v.selectedBuilding") != null && component.get("v.selectedBuilding.UUID__c") != null && component.get("v.selectedBuilding.UUID__c") != ''){
            lstLocationUUIDS.push(component.get("v.selectedBuilding.UUID__c"));
        }
        var moveInDate = (component.get("v.objHoldReservable.startsDate") != null && component.get("v.objHoldReservable.startsDate") != undefined && component.get("v.objHoldReservable.startsDate") != "")?component.get("v.objHoldReservable.startsDate"):component.get("v.currentDate"); 
        helper.searchReservables(component, event, helper, moveInDate, lstLocationUUIDS, 1, 999, function(lstReservables){
            component.set("v.buildingsReservables",lstReservables);
            component.find("utils").hideProcessing();
        });
    },
    setHeadermeta:function(component){
        var lstMetaFields = [];
        lstMetaFields.push({"label":"Segment","apiName":"RecordType.Name","type":"phone","isNameField":false,"icon":"standard:omni_supervisor"});//type is phone to get same css as phone field
        lstMetaFields.push({"label":"Building Name","apiName":"Building__r.Name","isNameField":true,"icon":"standard:account"});
        lstMetaFields.push({"label":"Stage","apiName":"StageName","type":"phone","icon":"standard:sales_path"});//type is phone to get same css as phone field
        lstMetaFields.push({"label":"Contract Stage","apiName":"Contract_Stage__c","type":"phone","icon":"standard:sales_path"});//type is phone to get same css as phone field
        component.set("v.headerMeta",lstMetaFields);
    },
    validationForHoldReservable:function(component,onSuccess){
        if(component.get("v.objHoldReservable") != null && component.get("v.objHoldReservable.tillDate") != null && component.get("v.objHoldReservable.startsDate") != null){
            if(Date.parse(component.get("v.objHoldReservable.tillDate")) < Date.parse(component.get("v.objHoldReservable.startsDate"))){
                component.find("utils").showError('Hold Start Date should always be greater than the Hold Until Date.');
            	onSuccess(false);
            }else{
                onSuccess(true);
            }
        }else{
            onSuccess(true);
        }
    },
    resetHoldForm:function(component){
        component.set("v.objHoldReservable.startsDate",null);
        component.set("v.objHoldReservable.tillDate",null);
        component.set("v.buildingsReservables",[]);
        component.set("v.objHoldReservable.reservable",null);
    }
})