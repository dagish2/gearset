({
	saveSetting : function(component,onsuccess,onerror) {        
        var record = {};
        record["Id"] = component.get("v.settingId");
        record["Data__c"] = component.get("v.settingData");
        component.find("utils").execute("c.saveRecord",{"record":record},function(response){
            component.set("v.currentSetting",{"Id":component.get("v.settingId"),"Data__c":component.get("v.settingData")})
            onsuccess();
        },function(error){
            onerror(error);
        })
	},
    populateTriggerData:function(component,onsuccess){
        var triggersData = JSON.parse(component.get("v.settingData"));
        var triggers = [];
        this.filterTriggers(component);
        onsuccess();
    },
    sortObject:function(o){
        var sorted = {},
        key, a = [];
        for (key in o) {
            if (o.hasOwnProperty(key)) {
                a.push(key);
            }
        }
        a.sort();
        for (key = 0; key < a.length; key++) {
            sorted[a[key]] = o[a[key]];
        }
        return sorted;
    },
    filterTriggers:function(component){
        var status = component.get("v.filterCriteria");
        var keyword = component.get("v.searchKeyword");
        var triggersData = JSON.parse(component.get("v.settingData"));
        var triggers = [];
        for(var key in triggersData){
            if(!keyword || key.toLowerCase().includes(keyword.toLowerCase())){
                switch(status){
                    case "all":
                        triggers.push({"name":key,"status":triggersData[key]});
                        break;
                    case "active":
                        if(triggersData[key]){
                            triggers.push({"name":key,"status":triggersData[key]});
                        }
                        break;
                    case "inactive":
                        if(!triggersData[key]){
                            triggers.push({"name":key,"status":triggersData[key]});
                        }
                        break;
                }
            }            
        }
        component.set("v.triggers",triggers);
    }
})