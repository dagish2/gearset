({
	doInit : function(component, event, helper) {
        component.find("utils").setTitle("Availability");
        var nextMonthDate;
        component.find("utils").showProcessing();
        component.find("utils").execute("c.getTodaysDate",{},function(today){
            component.find("utils").hideProcessing();
            component.set("v.availableFromPastBound",today);
            if(new Date(today).getMonth()==11){
                nextMonthDate = (new Date(today).getFullYear()+1)+"-01-01";
            }else{
                nextMonthDate = new Date(today).getFullYear()+"-"+(new Date().getMonth()+2)+"-01"
            }
            component.set("v.view",{"Include_Pending_Contract__c":"No","Show_Records__c":"Available","Available_From__c":nextMonthDate});
            
            /*var headers = {};
        headers['Content-Type'] = 'application/json; charset=UTF-8';
        headers['Accept'] = 'application/json';
        headers['Authorization'] = 'Standard';
        component.find("utils").execute("c.executeRestQuery",{"method":"GET","endPointUrl":"/services/data/v31.0/tooling/query/?q=Select+Id,+DeveloperName+From+CustomObject+Where+DeveloperName='Suggested_Discounts'","headers":headers,"setUrl":true},function(response){
            var sObjectId = JSON.parse(response).records[0].Id;
            console.log(sObjectId);
            component.find("utils").execute("c.executeRestQuery",{"method":"GET","endPointUrl":"/services/data/v31.0/tooling/query/?q=Select+Id,+DeveloperName,+TableEnumOrId+From+CustomField+Where+TableEnumOrId='"+sObjectId+"'+AND+DeveloperName='Location'","headers":headers,"setUrl":true},function(response){
                var fieldId = JSON.parse(response).records[0].Id.substring(0,15);*/
            var fieldId = "00N1D000000NrH1";
            var reservablesColumns = [
                {"apiName":"office_num","label":"Unit"},
                {"apiName":"location_name","label":"Building Name","type":"component","component":{"name":"ui:outputURL","attributes":{"label":"{{location_name}}","value":"/{{id}}#{{id}}_"+fieldId+"_target"}}},
                {"apiName":"floor","label":"Floor"},
                {"apiName":"capacity","label":"Capacity"},
                {"apiName":"price","label":"Price","type":"component","sort":"false","component":{"name":"c:DiscountPriceField","attributes":{"price":"{{price}}","uuid":"{{location_uuid}}","capacity":"{{capacity}}"}}},
                {"apiName":"type","label":"Unit Type"},
                {"apiName":"status","label":"Status"},
                {"apiName":"contract_status","label":"Contract"},
                {"apiName":"next_available_date","label":"Available From","type":"date"},
                {"apiName":"on_hold","label":"On Hold?"},
                {"apiName":"hold_expires","label":"Hold Expires On","type":"date"},
                {"apiName":"notes","label":"Notes"}
            ];
            component.set("v.reservablesColumns",reservablesColumns);
            /*},function(error){
                component.find("utils").showError(error);
            })
            },function(error){
                component.find("utils").showError(error);
            })*/
            component.find("utils").getIcons(function(mapIcons){
                component.set("v.icon",mapIcons['Reservable__c']);
            });
            component.find("utils").execute("c.getUserInfo",{},function(response){
                helper.getSavedPresets(component,JSON.parse(response)[0],function(views){
                    var mapViews = {};
                    views.forEach(function(view){
                        mapViews[view.Id] = view;
                    })
                    component.set("v.lstViews",views);
                    component.set("v.mapViews",mapViews);
                })
            },function(error){
                component.find("utils").showError(error);
            })
            helper.getSavedBuildings(component,function(buildings){
                var lstCities = [];
                var mapBuildings = {};
                var allBuildings = [];
                
                buildings.forEach(function(building){
                    if(building.City__c && lstCities.indexOf(building.City__c)==-1){
                        lstCities.push(building.City__c);
                    }
                    if(mapBuildings.hasOwnProperty(building.City__c)){
                        mapBuildings[building.City__c].push(building);
                    }else{
                        mapBuildings[building.City__c] = [building];
                    }
                    allBuildings.push(building);
                })
                component.set("v.lstCities",lstCities);
                component.set("v.mapBuildings",mapBuildings);
                component.set("v.allBuildings",allBuildings);
            })
            component.find("utils").execute("c.getFieldMetadata",{"sObjectName":"Reservable__c","fieldName":"Office_Work_Station_Type__c"},function(units){
                component.set("v.lstUnits",JSON.parse(units).picklistValues);
            },function(error){
                component.find("utils").showError(error);
            })
            component.find("utils").execute("c.getQueryData",{"query":"SELECT Id, Data__c FROM Setting__c WHERE Name='TourReservableAPI'"},function(api){
                component.set("v.reservableApiData",JSON.parse(api[0].Data__c));
            },function(error){
                component.find("utils").showError(error);
            })
        },function(error){
            
            component.find("utils").showError(error);
        })
        
	},
    cityChanged:function(component, event, helper){
        if(component.get("v.mapBuildings") && component.get("v.mapBuildings")[component.get("v.view.City__c")]){
            var lstBuildings = component.get("v.mapBuildings")[component.get("v.view.City__c")];
            if(component.get("v.view.Buildings__c")){
                component.get("v.view.Buildings__c").split(";").forEach(function(building){
                    if(lstBuildings.findIndex(function(b){return b.Name==building})==-1){
                        if(component.get("v.allBuildings")[component.get("v.allBuildings").findIndex(function(ab){return ab.Name==building})] !=undefined){
                            lstBuildings.push(component.get("v.allBuildings")[component.get("v.allBuildings").findIndex(function(ab){
                                return ab.Name==building
                            })])   
                        }
                        
                    }
                })
            }
            component.set("v.lstBuildings",lstBuildings);   
        }else{
             component.set("v.lstBuildings",[]); 
        }
    },
    viewChanged:function(component, event, helper){
        if(component.get("v.currentViewId") && component.get("v.mapViews")[component.get("v.currentViewId")]){
            component.set("v.view",component.get("v.mapViews")[component.get("v.currentViewId")]);
        }else{
            component.set("v.view",{});
        }
    },
    save:function(component, event, helper){
        component.find("utils").showProcessing();
        component.find("utils").execute("c.saveRecord",{"record":JSON.parse(JSON.stringify(component.get("v.view")))},function(response){
            component.find("utils").hideProcessing();
            component.find("utils").showSuccess('View saved successfully.');
            var views = JSON.parse(localStorage.getItem("presets"));
            for(var i=0;i<views.length;i++){
                if(views[i].Id==component.get("v.view.Id")){
                    views[i] = JSON.parse(JSON.stringify(component.get("v.view")));
                }
            }
            localStorage.setItem("presets",JSON.stringify(views));
        },function(error){
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        })
    },
    saveAs:function(component, event, helper){
        component.set("v.saveAsOnlyForMe",true);
		component.find("saveAsModal").showModal();        
    },
    saveAsView:function(component, event, helper){      
        var view = JSON.parse(JSON.stringify(component.get("v.view")));
        delete view['Id'];
        var  mydate = new Date(view.Available_From__c);
        view['Available_From__c'] = mydate;
        view['Name'] = component.get("v.saveAsViewName");
        view['Only_for_me__c'] = component.get("v.saveAsOnlyForMe");
        view['sobjectType'] = "Reservable_View__c";       
        component.find("utils").execute("c.saveRecord",{"record":view},function(response){
            component.find("utils").hideProcessing();
            component.find("utils").showSuccess('View saved successfully.');
            view['Id'] = JSON.parse(response).id;
            var lstViews = component.get("v.lstViews");
            var mapViews = component.get("v.mapViews");
            lstViews.push(view);
            mapViews[view.Id] = view;
            component.set("v.lstViews",lstViews);
            component.set("v.mapViews",mapViews);
            component.set("v.currentViewId",view.Id);
            component.set("v.saveAsViewName","");
            component.find("saveAsModal").close();
            var views = JSON.parse(localStorage.getItem("presets"));
            views.push(component.get("v.view"));
            localStorage.setItem("presets",JSON.stringify(views));
        },function(error){
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        })
    },
    closeModal:function(component, event, helper){
		component.find("saveAsModal").close();        
    },
    getReservables:function(component, event, helper){
        component.set("v.currentPage",1);
        helper.getReservables(component);
    },
    getReservablesPagination:function(component, event, helper){
        helper.getReservables(component);
    },
    exportReservables:function(component){
        localStorage.setItem("selectedReservable", JSON.stringify(component.get("v.selectedReservables")));        
        var url = '/apex/exportReservable';
        var journeyWindow = window.open(url, url);
        journeyWindow.focus();
    },
    updateCache:function(component,event,helper){
        component.find("utils").showProcessing();
        component.find("utils").execute("c.getUserInfo",{},function(response){
            component.find("utils").execute("c.getQueryData",{"query":"Select Id,Name,Available_From__c,Buildings__c,City__c,Maximum_Capacity__c,Maximum_Price_Range__c,Minimum_Capacity__c,Minimum_Price_Range__c,Show_Records__c,Unit_Type__c,Include_Pending_Contract__c from Reservable_View__c where Only_for_me__c=false OR (Only_for_me__c=true AND CreatedById='"+(JSON.parse(response)[0].Id)+"')"},function(views){
                localStorage.setItem("presets",JSON.stringify(views));
                component.find("utils").execute("c.getQueryData",{"query":"Select Id,Name,City__c,UUID__c from Building__c"},function(buildings){
                    localStorage.setItem("buildings",JSON.stringify(buildings));
                    helper.getSavedPresets(component,JSON.parse(response)[0],function(views){
                        var mapViews = {};
                        views.forEach(function(view){
                            mapViews[view.Id] = view;
                        })
                        component.set("v.lstViews",views);
                        component.set("v.mapViews",mapViews);
                    })
                    helper.getSavedBuildings(component,function(buildings){
                        var lstCities = [];
                        var mapBuildings = {};
                        var allBuildings = [];
                        buildings.forEach(function(building){
                            if(building.City__c && lstCities.indexOf(building.City__c)==-1){
                                lstCities.push(building.City__c);
                            }
                            if(mapBuildings.hasOwnProperty(building.City__c)){
                                mapBuildings[building.City__c].push(building);
                            }else{
                                mapBuildings[building.City__c] = [building];
                            }
                            allBuildings.push(building);
                        })
                        component.set("v.lstCities",lstCities);
                        component.set("v.mapBuildings",mapBuildings);
                        component.set("v.allBuildings",allBuildings);
                    })
                    component.find("utils").hideProcessing();
                },function(error){
                    component.find("utils").showError(error);
                    component.find("utils").hideProcessing();
                })
            },function(error){
                component.find("utils").showError(error);
                component.find("utils").hideProcessing();
            })
        },function(error){
            component.find("utils").showError(error);
            component.find("utils").hideProcessing();
        })
    },
    cancel:function(component){
        component.find("utils").closeTab();
        component.find("utils").redirectToUrl('back');
    }
})