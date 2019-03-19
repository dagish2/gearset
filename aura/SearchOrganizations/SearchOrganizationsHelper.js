({
	searchOrgAccounts : function(component, event, helper){        
        if(component.get("v.accountName") != undefined && component.get("v.accountName").length > 2){   
            component.get("v.utils").showProcessing();
            component.set("v.hasSearched", true);
            var params = {};
            params["accountName"] = component.get("v.utils").addSlashes(component.get("v.accountName"));
            params["accountType"] = component.get("v.accountType");
            params["searchAllOrg"] = component.get("v.searchAllOrg");
            
            component.get("v.utils").execute("c.getQueryData", {"label": "searchOrgAccounts", "params" : params}, function(response){
                component.set("v.orgRecords", ((response && response.length) ? response : []));
                component.get("v.utils").hideProcessing();
            },function(error){
                component.get("v.utils").showError(error);
                component.get("v.utils").hideProcessing();
            }, component);
        }else{
            setTimeout(function(){ component.set("v.orgRecords", []); }, 1000);
        }
    },
    searchSalesAccounts : function(component, event, helper, accountId){
        component.get("v.utils").showProcessing();   
        component.get("v.utils").execute("c.getRelatedViewHierarchy",{"accountId": accountId}, function(response){
            var salesAccountMeta = [];  
            salesAccountMeta.push({"name":"Id","label":"Action","type":"component","sort":"false","component":[{"name":"c:EnziInputRadio","attributes":{"value":component.getReference("v.selectedOrgId"),"text":"{{Id}}"}}]});
            salesAccountMeta.push({"name":"Name","label":"Account Name","type":"component","component":{"name":"ui:outputUrl","attributes":{"label":"{{Name}}","value":"/{{Id}}","target":"_new"}}});
            salesAccountMeta.push({"name":"Account_Type__c","label":"Account Type"});
            salesAccountMeta.push({"name":"Parent.Name","label":"Parent Account","type":"component","component":{"name":"ui:outputUrl","attributes":{"label":"{{Parent.Name}}","value":"/{{Parent.Id}}"}}});
            salesAccountMeta.push({"name":"Main Contact","label":"Main Contact","type":"component","component":{"name":"ui:outputUrl","attributes":{"label":"{{Primary_Member__r.Name}}","value":"/{{Primary_Member__c}}","target":"_new"}}});
            salesAccountMeta.push({"name":"Main Contact Email","label":"Main Contact Email","type":"component","component":{"name":"ui:outputUrl","attributes":{"label":"{{Primary_Member__r.Email}}","value":"mailto:{{Primary_Member__r.Email}}","target":"_new"}}});
            salesAccountMeta.push({"name":"Owner","label":"Account Owner","sort":"false","type":"component","component":{"name":"ui:outputUrl","attributes":{"label":"{{Owner.Name}}","value":"/{{Owner.Id}}","target":"_new"}}});  
            component.set("v.salesAccounts", response);
            component.set("v.salesAccountMeta", salesAccountMeta);
            component.set("v.openSalesAccountModal", true);
            component.get("v.utils").hideProcessing();
        },function(error){
            component.get("v.utils").showError(error);
            component.get("v.utils").hideProcessing();
        },component); 
    }
})