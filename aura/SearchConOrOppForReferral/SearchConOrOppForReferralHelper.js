({
    metaContactColumn : function(component){
        var contactColumns = [];
        contactColumns.push({"label": "Name", "fieldName": "Id", "sortable": true, type: "url", typeAttributes: {label: {fieldName: "Name"}}});
        contactColumns.push({"label": "Email", "fieldName": "Email", "type": "text"});
        contactColumns.push({"label": "Account", "fieldName": "AccountId", "sortable": true, type: "url", typeAttributes: {label: {fieldName: "Account.Name"}}});
        contactColumns.push({"label": "Owner", "fieldName": "OwnerId", "sortable": true, type: "url", typeAttributes: {label: {fieldName: "Owner.Name"}}});
        component.set("v.contactColumns",contactColumns);
    },
    metaOppColumns : function(component){
        var opportunityColumns = [];
        opportunityColumns.push({"label": "Name", "fieldName": "Id", "sortable": true, "type": "url", "typeAttributes": {"label": { "fieldName": "Name"}}});
        opportunityColumns.push({"label": "Stage", "fieldName": "StageName", "type": "text"});
        opportunityColumns.push({"label": "Deal Type", "fieldName":"Deal_Type__c", "type": "text"});
        opportunityColumns.push({"label": "Account", "fieldName": "Account", "sortable": true, "type": "url", "typeAttributes": {"label": { "fieldName": "Account.Name"}}});
        opportunityColumns.push({"label": "Primary Member", "fieldName": "Primary_Member__c", "sortable": true, "type": "url", "typeAttributes": {"label": { "fieldName": "Primary_Member__r.Name"}}});
        opportunityColumns.push({"label": "Owner", "fieldName": "OwnerId", "sortable": true, "type": "url", "typeAttributes": {"label": { "fieldName": "Owner.Name"}}});
        component.set("v.opportunityColumns",opportunityColumns);
    },
    search : function(component, helper, condition) {
        var query;
        var keyword = helper.addSlashes(component.get("v.keyword"))
        if(component.get("v.value").toLowerCase() == 'opportunity'){
            query = "SELECT Id, Name, Deal_Type__c, CloseDate, StageName, AccountId, Account.Name, Primary_Member__c, Primary_Member__r.Name,  OwnerId, Owner.Name FROM Opportunity WHERE "+ (component.get("v.retrictedStages") ? "StageName NOT IN ('" + component.get("v.retrictedStages").join("','")+"') AND " : "")+" " + (condition && condition.opportunity ? condition.opportunity: "Name LIKE '"+keyword+"%' LIMIT 100");
        }else if(component.get("v.value").toLowerCase() == 'contact'){
            query = "SELECT Id, Name, Email, AccountId, Account.Name, OwnerId, Owner.Name FROM Contact WHERE " + (condition && condition.opportunity ? condition.contact: "Name LIKE '"+keyword+"%' OR Email LIKE '"+keyword+"%'  LIMIT 100");
        }
        component.get("v.utils").execute("c.getQueryData",{"query":query},function(response){
            if(component.get("v.value").toLowerCase() == 'opportunity'){
                if(response && response.length){
                  component.set("v.opportunities", response);
                }else{
                  component.set("v.opportunities", []);
                }
                component.set("v.contacts", []);
            }else if(component.get("v.value").toLowerCase() == 'contact'){
                component.set("v.contacts", response);
                component.set("v.opportunities", []);
            }
        },function(error){
            component.get("v.utils").hideProcessing();
            component.get("v.utils").showError(error);
        });
        
    },
    addSlashes: function(str){
        str = str.split("'").join("\\'");
        return str.trim();
    },
    resetSeletedRows : function(component){
        component.get("v.selectedContactRows", []);
        component.get("v.selectedOpportunityRows", []);
        component.set("v.contactRec",null);
        component.set("v.opportunityRec",null);
    }
})