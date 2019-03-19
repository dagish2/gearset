({
    getUserDetails : function(component, strUserId){
        var utils = component.get("v.utils");
        utils.showProcessing();
        component.set("v.relatedUser", "");
        utils.execute("c.getUserData", {"strUserOrGroupId" : strUserId}, function(response){
            if(response){
                component.set("v.relatedUser", response[0]);
            }
            utils.hideProcessing();
        },function(error){
            utils.hideProcessing();
            utils.showError(error);
        }, component); 
    },
    saveBuildingRecord : function(component, settingId, objSetting, onsuccess) {
        var objSetting = {"Id":settingId, "Data__c": JSON.stringify(objSetting), sobjectType:"Setting__c"};
        var utils = component.find("utils"); 
        utils.execute("c.saveRecord",{"record": objSetting},function(response) {
            utils.showSuccess("Assignments updated successfully.");
            utils.hideProcessing();
            onsuccess();
        },function(error){
            utils.hideProcessing();
            utils.showError(error);
        }); 
    },
    pushToSelectedMarkets : function(component, objRecord){
        if(objRecord){
            var mapSelectedMarkets = component.get("v.mapSelectedMarkets");
            var lstSelectedMarkets = component.get("v.lstSelectedMarkets");
            lstSelectedMarkets.push(objRecord);
            if(!mapSelectedMarkets){
                 mapSelectedMarkets = {};
            }
            mapSelectedMarkets[objRecord.Id] = objRecord;
            component.set("v.mapSelectedMarkets", mapSelectedMarkets);
            component.set("v.lstSelectedMarkets", lstSelectedMarkets);
        }
    },
    scrollIntoView : function(component) {
        if(component.get("v.selectedMarketId")){
            setTimeout(function(){
                var elmnt = document.getElementsByClassName("slds-color__background_gray-5");
                if(elmnt && elmnt.length > 0){ 
                    elmnt[0].scrollIntoView();
                }
            }, 100);
        }
    }
})