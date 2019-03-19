({
	doInit : function(component, event, helper) {
		var utils = component.find("utils");
        utils.showProcessing();
        utils.execute("c.getSetup", {}, function(response){
            if(response){
                var mapOfMarket = response.mapOfMarket;
                if(response.mapSelectedMarkets){
                    var lstSelectedMarkets =  Object.values(response.mapSelectedMarkets);
                    component.set("v.lstSelectedMarkets", lstSelectedMarkets);
                    component.set("v.mapSelectedMarkets", response.mapSelectedMarkets);
                    for(var index = 0; index < lstSelectedMarkets.length;++index){
                        let objMarket = mapOfMarket[lstSelectedMarkets[index].Id];
                        objMarket["selected"] = true;
                        mapOfMarket[lstSelectedMarkets[index].Id] = objMarket;
                    }
                }
                component.set("v.mapOfMarket", mapOfMarket);
                component.set("v.lstOfAllMarkets", Object.values(response.mapOfMarket));
                component.set("v.options", Object.values(response.mapOfMarket));
                
                var objSetting =  JSON.parse(response.objSetting.Data__c);
                component.set("v.objSetting", objSetting);
                component.set("v.settingId", response.objSetting.Id);
            }
            utils.hideProcessing();
        },function(error){
            utils.hideProcessing();
            utils.showError(error);
        }, component); 
        component.set("v.utils", utils);
	},
    getRelatedDetails : function(component, event, helper) {
        component.set("v.selectedUserId", "");
        component.set("v.keyword", "");
        var mapOfMarket = component.get("v.mapOfMarket");
        var selectedId = event.currentTarget.getAttribute("id");
        var objSetting = component.get("v.objSetting");
        component.set("v.selectedMarketId", selectedId);
        component.set("v.objMarket", mapOfMarket[selectedId]);
        var relatedUserId = objSetting[selectedId.slice(0, 15)] ? objSetting[selectedId.slice(0, 15)] : objSetting[selectedId];
        if(relatedUserId) {
            helper.getUserDetails(component, relatedUserId);
        }else {
            component.set("v.relatedUser", null);
        }
    },
    searchAndAddMarket : function(component, event, helper) {
        var marketId = component.get("v.marketId");
        if(marketId){
            component.set("v.selectedUserId", null);
            component.set("v.relatedUser", null);
            component.set("v.keyword", "");
            var mapSelectedMarkets = component.get("v.mapSelectedMarkets");
            if(mapSelectedMarkets && mapSelectedMarkets[marketId]) {
                component.set("v.objMarket", mapSelectedMarkets[marketId]);
                if(component.get("v.objSetting")[marketId]){
                    helper.getUserDetails(component, component.get("v.objSetting")[marketId]);
                }
            }else{
                let mapOfMarket = component.get("v.mapOfMarket");
                component.set("v.objMarket", mapOfMarket[marketId]);
                helper.pushToSelectedMarkets(component, mapOfMarket[marketId]);
            }
            component.set("v.selectedMarketId", marketId);
            helper.scrollIntoView(component);
        }
    },
    removeUser : function(component){
        component.set("v.relatedUser", "");
    },
    setUserId : function(component, event, helper) {
        var selectedUserId = component.get("v.selectedUserId");
        if(selectedUserId){
            component.set("v.object", (selectedUserId.slice(0,3)=="005" ? "User" : "Group"));
            helper.getUserDetails(component, selectedUserId);
            setTimeout(function(){
                component.set("v.keyword", "");
                component.set("v.selectedUserId", null);
            },100);
        }
    },
    saveSetting : function(component, event, helper) {
        var utils = component.get("v.utils");
        utils.showProcessing();
        var objSetting = component.get("v.objSetting");
        var mapSelectedMarkets = component.get("v.mapSelectedMarkets");
        var lstSelectedMarkets = component.get("v.lstSelectedMarkets");
        var relatedUser = component.get("v.relatedUser");
        var objMarket = component.get("v.objMarket");
        var settingId = component.get("v.settingId");
        var mapOfMarket = component.get("v.mapOfMarket");
                
        if(relatedUser){
            objSetting[objMarket.Id] = relatedUser.Id;
            helper.saveBuildingRecord(component, settingId, objSetting, function(){
                component.set("v.objSetting", objSetting);
                mapOfMarket[objMarket.Id]["selected"] = true;
                component.set("v.mapOfMarket", mapOfMarket);
                component.set("v.lstOfAllMarkets", Object.values(mapOfMarket));
                
                mapSelectedMarkets[objMarket.Id] = objMarket;
                component.set("v.mapSelectedMarkets", mapSelectedMarkets);
            }); 
        }else{
            component.set("v.selectedMarketId", "");
            if(mapSelectedMarkets[objMarket.Id]) {
                delete mapSelectedMarkets[objMarket.Id];
                mapOfMarket[objMarket.Id]["selected"] = false;
                component.set("v.mapOfMarket", mapOfMarket);
                component.set("v.lstOfAllMarkets", Object.values(mapOfMarket));
                component.set("v.mapSelectedMarkets", mapSelectedMarkets);
            }
            if(objSetting[objMarket.Id]){
                delete objSetting[objMarket.Id];
                helper.saveBuildingRecord(component, settingId, objSetting, function(){
                    component.set("v.objSetting", objSetting);
                });
            }else{
                utils.hideProcessing();
            }
        }
    },
    setHeaderFields : function(component) {
        var objMarket = component.get("v.objMarket");
        if(objMarket){
            component.set("v.lstDataFields", [{'label':'Region Name', 'value':objMarket.Region__c}, {'label':'Territory Name', 'value':objMarket.Territory__c}, {'label':'Email', 'value':objMarket.Email__c}]);
        }
    },
    cancel : function(component) {
        component.set("v.relatedUser", "");
        component.set("v.selectedMarketId", "");
    }
})