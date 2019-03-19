({
	doInit : function(component, event, helper) {
		component.set("v.searchCriterias",["contains","equals","starts with","ends with"]);
	},
    save : function(component, event, helper) {
		component.set("v.filterValue",component.set("v.filters"));
        component.find("advancedSearchModal").close();
	},
    cancel : function(component, event, helper) {
		component.find("advancedSearchModal").close();
	},
    filterFieldsChange : function(component, event, helper) {
        var arrFilters = []
        if(!(component.get("v.filterValueTemp")=="" || component.get("v.filterValueTemp")==undefined)){
            for(var filter in component.get("v.filterValueTemp").split(";")){
                arrFilters.push({"fieldName":component.get("v.filterValueTemp").split(";")[filter],"searchCriteria":"contains"});
            }
        }
        component.set("v.filters",arrFilters);
	}
})