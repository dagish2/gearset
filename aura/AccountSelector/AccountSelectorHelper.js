({
	getMatchedOrgAccounts : function(component, onSuccess) {
        component.find("utils").execute("c.getMatchedAccounts", {"objLead": component.get("v.leadRec")}, function(matchedOrgRecords){
            if(matchedOrgRecords.length > 0){
                component.set("v.selectedOrgId", matchedOrgRecords[0].Id);
                component.find("utils").showSuccess(matchedOrgRecords[0].Name + " Account Is Selected");
            }
            onSuccess(matchedOrgRecords);
        }, function(error){
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        }, component);		
	},
    searchSalesAccounts : function(component, event, helper, accountId, searchOnlySales, onsuccess, onerror){
        component.find("utils").showProcessing();   
        var matchedOrgRecords = component.get("v.matchedOrgRecords");
        var strQuery;
        if(searchOnlySales){
            component.find("utils").execute("c.getRelatedSalesAccounts", {"accountId": accountId}, function(salesAccounts){
                component.set("v.salesAccounts", salesAccounts);
                component.set("v.selector", 5);
                component.find("utils").hideProcessing();
            },function(error){
                component.find("utils").showError(error);
                component.find("utils").hideProcessing();
            }, component); 
        }else{
            component.find("utils").execute("c.getRelatedViewHierarchy",{"accountId": accountId}, function(records){
                onsuccess(records);
                component.find("utils").hideProcessing();
            },function(error){
                onerror(error);
            }, component);    
        }
    },
    showConfirmation : function(component, event, helper, selectedAccount){
        var matchedOrgRecords = component.get("v.matchedOrgRecords");
        for(var index = 0; index <= matchedOrgRecords.length; index++){
            if(matchedOrgRecords[index].Id.substring(0, 15) == selectedAccount){
                component.find("utils").showSuccess(matchedOrgRecords[index].Name + ' Account Is Selected');
                break;
            }
        }
    }
})