({
	 lazyLoadTabs: function (component, helper, event) {
        var tab = event.getSource();
        switch (tab.get('v.id')) {
            case 'relatedDetails':
                helper.injectComponent("c:WeForm", {"recordId":component.get("v.releatedRecordId"), "aura:id": "weform1", "record": component.getReference("v.relatedRecord"), "valid": component.getReference("v.valid1"), "sObjectName": component.set("v.relatedSobjectName"), "layout": component.getReference("v.relatedLayout") , "mode": component.getReference("v.relatedMode")}, tab);
                break;
            case 'relatedLists':
                helper.changePhase(component, helper, event);
                this.injectComponent('c:EnziRelatedLists', {"sObjectName": component.get("v.sObjectName"), "recordId": component.get("v.recordId"), "exclude": ["OpenActivities","ActivityHistories","Activities__r"]}, tab);
                break;
            case 'activity':
                helper.changePhase(component, helper, event);
                this.injectComponent('c:EnziActivityTimeline', {"recordId": component.get("v.recordId")}, tab);
                break;    
            case 'relatedRecordLists':
                var record = component.get("v.record");
                var sObjectName = (record.Primary_Lead__c) ? 'Lead' : 'Contact';
                var recordId = (record.Primary_Lead__c) ? record.Primary_Lead__c : record.Primary_Contact__c;
                this.injectComponent('c:EnziRelatedLists', {"sObjectName": sObjectName, "recordId": recordId, "exclude":["OpenActivities", "ActivityHistories", "Activities__r"]}, tab);
                break;
            case 'releatedActivity':
                var record = component.get("v.record");
                this.injectComponent('c:EnziActivityTimeline', {"recordId": ((record.Primary_Lead__c) ? record.Primary_Lead__c : record.Primary_Contact__c)}, tab);
                break;
        }
    },
    injectComponent: function (name, attributes, target) {
        if(target.get("v.body").length==0){
            $A.createComponent(name, attributes, function (contentComponent, status, error) {
                if (status === "SUCCESS") {
                    target.set('v.body', contentComponent);
                }
            });
        }
    },
    setActions: function (component, detailButtons, predefinedStandardActions, predefinedTopActions,data) {
        var standardActions = [];
        var customActions = [];
        var topActions = [];
        for(var sa in detailButtons){
            if(detailButtons[sa].custom){
                if(predefinedTopActions.indexOf(detailButtons[sa].name)==-1){
                    customActions.push(detailButtons[sa]);
                }else{
                    topActions.push(detailButtons[sa]);
                }
            }else{
                if(predefinedStandardActions.indexOf(detailButtons[sa].name)==-1 || (detailButtons[sa].name=="ChangeRecordType" && data.lstRecordTypes.length==0)){
                    continue;
                }
                standardActions.push(detailButtons[sa]);
            }
        }
        
        component.set("v.standardActions",standardActions);
        component.set("v.customActions",customActions);
        component.set("v.topActionsObj",topActions);
    },
    getLayout: function (component, recordId, onsuccess){
         component.get("v.utils").execute("c.getLayout", {"recordId":recordId}, function(response){
            var data = JSON.parse(response);
            var layout;
            if(data.lstRecordTypes.length>0)
                onsuccess([data, JSON.parse(data.layout)]);
            else
                onsuccess([data, JSON.parse(data.layout).layouts[0]]);
         },function(error){
            component.get("v.utils").showError(error);
            component.get("v.utils").hideProcessing();
        });
    },
    getClosedStages: function (component, helper, event){
        component.get("v.utils").execute("c.getJourneyClosedStages",{}, function(response){
            var closedStages = JSON.parse(response.toLowerCase());
            component.set("v.closedJourneyStages", closedStages);
         },function(error){
            component.get("v.utils").showError(error);
            component.get("v.utils").hideProcessing();
        },component);
    },
    changePhase: function (component, helper, event){
        var tab = event.getSource();
        var activePhase = (tab.get('v.id') == "phase2") ? "phase2" : "phase1";
        if(activePhase != component.get("v.phase")){
            component.set("v.phase", activePhase);
            if(activePhase == "phase2"){
                if(!component.get("v.releatedRecordId"))
                    component.set("v.releatedRecordId", (component.get("v.record.Primary_Lead__c") ? component.get("v.record.Primary_Lead__c") : component.get("v.record.Primary_Contact__c")));
                
                if(!component.get("v.relatedLayout")){
                    helper.getLayout(component, component.get("v.releatedRecordId"),function(result){
                        var data = result[0];
                        var layout = result[1];
                        component.set("v.relatedLayoutDetails",data);
                        component.set("v.relatedSobjectName",data.sObjectName);
                        helper.setActions(component, layout.buttonLayoutSection.detailButtons ,component.get("v.predefinedStandardActions"), [],data);
                        component.set("v.relatedLayout",layout);
                    });
                }else{
                    helper.setActions(component, component.get("v.relatedLayout").buttonLayoutSection.detailButtons, component.get("v.predefinedStandardActions"),[], component.get("v.relatedLayoutDetails"));
                }
            }else{
                helper.setActions(component, component.get("v.journeyLayout").buttonLayoutSection.detailButtons, component.get("v.predefinedStandardActions"),component.get("v.topActions"), component.set("v.journeyLayoutDetails"));
            }
        }
    },
    switchToViewMode: function (component){
        if(component.get("v.phase") == "phase1"){
            component.set('v.mode', 'VIEW');
        }
        else{
            component.set("v.relatedMode", "VIEW");
        }
    }
})