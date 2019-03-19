({
    doInit : function(component, event, helper) {
        component.set("v.utils", component.find("utils"));
        var metaFields = [];
        metaFields.push({"name":"Id","label":"Action","type":"component","sort":"false","component":{"name":"c:EnziInputRadio","attributes":{"value":component.getReference("v.selectedOrgId"),"text":"{{Id}}"}}});
        component.get("v.showHierarchy") ? metaFields.push({"name":"Id","label":"View Hierarchy","type":"component","sort":"false","component":{"name":"c:EnziButton","attributes":{"label":"View Hierarchy","id":"{{Id}}","click":component.getReference("c.viewHierarchy")}}}) : '';
        metaFields.push({"name": "Name", "label":"Account Name", "showtooltip":component.get("v.showTooltips"), "tooltiptext":"Name of the Account", "type":"component", "component": {"name": "ui:outputUrl", "attributes":{"label": "{{Name}}", "value": "/{{Id}}","target":"_blank"}}});
        metaFields.push({"name": "Primary_Member__c", "label":"Main Contact", "showtooltip": component.get("v.showTooltips"), "tooltiptext": "Main Contact of the Account ", "type": "component", "component":{"name":"ui:outputUrl", "attributes": {"label": "{{Primary_Member__r.Name}}", "value": "/{{Primary_Member__c}}","target":"_blank"}}});
       	metaFields.push({"name": "Account_Type__c", "label":"Account Type", "showtooltip": component.get("v.showTooltips"), "tooltiptext": "Type of the Account "});
        metaFields.push({"name": "Account_SubType__c", "label":"Sub Type"});
        metaFields.push({"name": "OwnerId", "label":"Account Owner", "showtooltip": component.get("v.showTooltips"), "tooltiptext": "Name of the Account Owner", "type":"component", "component": {"name": "ui:outputUrl", "attributes": {"label": "{{Owner.Name}}", "value": "/{{OwnerId}}","target":"_blank"}}});
        metaFields.push({"name": "Website", "label":"Website", "showtooltip": component.get("v.showTooltips"), "tooltiptext": "Website of the Organization", "type": "component", "component":{"name":"ui:outputUrl", "attributes": {"label": "{{Website}}", "value": "{{Website}}","target":"_blank"}}});
        component.set("v.searchOrgMetaFields", metaFields);
	},
    viewHierarchy : function(component, event, helper) {        
        component.set("v.selectedOrgId", "");                
        var accountId = event.currentTarget.id;
        helper.searchSalesAccounts(component, event, helper, accountId);
    },
    searchOrgAccounts : function(component, event, helper) {        
		helper.searchOrgAccounts(component, event, helper);
	},
    close : function(component,event,helper){
        component.get("v.utils").redirectToUrl('back');
    },    
    clearOrgRecords:function(component,event,helper){
        if(!event.currentTarget.value.trim().length){
            setTimeout(function(){ component.set("v.orgRecords", []); }, 1000);
        }
    },
    changeAccountType : function(component, event, helper) {
        component.set("v.accountType", event.getSource().get("v.name"));
    },
    closeSalesAccountModal:function(component,event,helper){
        component.set("v.selectedOrgId",null);
        component.set("v.openSalesAccountModal",false);
    },
    useSelectedOrg : function(component,event,helper){
        var objAccount = {};
        objAccount.Id = component.get("v.selectedOrgId");
        objAccount.sobjectType = "Account";
        component.set("v.selectedOrg", objAccount);
        component.set("v.openSalesAccountModal", false);
        var useSelectedAccount = component.get("v.useSelectedAccount");
        if(useSelectedAccount){
            $A.enqueueAction(useSelectedAccount);
        }        
    }
})