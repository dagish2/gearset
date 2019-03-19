({ 
    doInit : function(component, event, helper) {
        var query = "SELECT Id, Name, Data__c FROM Setting__c WHERE Name = 'Google Geolocation API'";
        component.find("utils").execute("c.getQueryData",{"query":query},function(response){
            var result = response[0];
            component.set("v.settings", JSON.parse(result.Data__c));
            helper.setGeocodeValue(component);
        },function(error){
            component.find("utils").showError(error);
        });
	},
    keywordChanged: function(component, event, helper){
        if(component.get("v.keyword")==undefined || component.get("v.keyword")==null || component.get("v.keyword")==""){
            component.set("v.value", null);
        }
    },
    selectOption: function(component, event, helper){
        component.set("v.selectedIndex",event.target.getAttribute('data-index'));
        helper.select(component);
    },
    openMap: function(component, event, helper){
        component.find("utils").addComponent("c:EnziFrame",{"url":component.get("v.settings")["GeolocationMap"]["url"],"header":"Select Location","isLarge":true});
    },
    showTooltip: function(component, event, helper){
        component.find("utils").addComponent("c:EnziFrame",{"url":component.get("v.settings")["GeolocationMap"]["url"],"header":"Select Location","isLarge":true});
    },
    setGeoValue:function(component, event, helper){
        helper.setGeocodeValue(component);
    }
})