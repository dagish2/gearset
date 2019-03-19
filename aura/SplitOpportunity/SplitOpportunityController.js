({
    doInit : function(component, event, helper) { 
        component.set("v.utility", component.find("utils"));
        component.get("v.utility").setTitle("Split Opportunity");
        component.get("v.utility").showProcessing();
        var recordId = component.get("v.recordId"); 
        component.get("v.utility").execute("c.getOppProductForSplit", {"oppId":recordId}, function(response){
            if(response != null && response != undefined){ 
                var oppProductResponse = JSON.parse(response);
                var header = component.get("v.header");
                if(component.get("v.header")==null || component.get("v.header")==undefined){                        
                    component.set("v.header", {
                        "iconName": "standard:"+'opportunity',
                        "recordName": "Opportunity"+" : "+oppProductResponse.oppRec.Name,
                        "objectName": 'Opportunity'
                    }); 
                } 
                if(oppProductResponse.isValidForSplit != null && oppProductResponse.isValidForSplit != undefined && oppProductResponse.isValidForSplit == false){
                    component.set("v.splitDisable", "true");
                    component.get("v.utility").hideProcessing();
                    component.set("v.message", "You need to be the Opportunity Owner to perform this action.");
                } else if (oppProductResponse.isValidForSplit != null && oppProductResponse.isValidForSplit != undefined && oppProductResponse.isValidForSplit == true) {
                    component.set("v.splitDisable", "false"); 
                    var oppLineItems = (oppProductResponse.oppRec.OpportunityLineItems != undefined && oppProductResponse.oppRec.OpportunityLineItems.records != undefined) ? oppProductResponse.oppRec.OpportunityLineItems.records : [];
                    if(oppLineItems == null || oppLineItems == 0)
                    {
                        component.set("v.splitDisable", "true");
                        component.get("v.utility").hideProcessing();
                        component.set("v.message", "You can not split opportunity as there are no products.");
                    } else {
                        if(oppLineItems.length == 1){
                            component.set("v.splitDisable", "true");
                            component.get("v.utility").hideProcessing();
                            component.set("v.message", "You should have more than 1 product to split the opportunity."); 
                        }  
                        var mapLineItems = {}; 
                        oppLineItems.forEach(function(lineItem){
                            mapLineItems[lineItem["Id"]] = lineItem;
                        });
                        component.set("v.opportunityLineItems", oppLineItems); 
                        component.set("v.mapOpportunityLineItems", mapLineItems);  
                        component.get("v.utility").hideProcessing();
                    }
                }
            }
        }, function(error){
            component.get("v.utility").showError(error);
        }, component);
        var opportunityColumns = [
            {"name":"Split", "label":"Action", "sort":"false", "type":"component", "component":{"name":"c:SplitOppAction", "attributes":{"isPrimaryProduct":"{{Is_Primary_Product__c}}", "click":component.getReference("c.splitOppProducts"), "productId":"{{Id}}"}}},
            {"name":"PricebookEntry.Name", "label":"Product", "type":"component", "component":{"name":"c:EnziOutputUrl", "attributes":{"value":"{{Id}}","label":"{{PricebookEntry.Name}}", "click": component.getReference("c.redirectToUrl")}}},
            {"name":"Geography__r.Name", "label":"Geography", "type":"component", "component":{"name":"c:EnziOutputUrl", "attributes":{"value":"{{Geography__c}}", "label":"{{Geography__r.Name}}", "click": component.getReference("c.redirectToUrl")}}},
            {"name":"Building__r.Name", "label":"Building/Nearest Building", "type":"component", "component":{"name":"c:EnziOutputUrl", "attributes":{"value":"{{Building__c}}", "label":"{{Building__r.Name}}", "click": component.getReference("c.redirectToUrl")}}},
            {"name":"Quantity", "label":"Quantity", "type":"number"},
            {"name":"UnitPrice", "label":"Sales Price", "type":"number"},
            {"name":"Description", "label":"Line Description", "type":"string"},
            {"name":"PricebookEntry.Product2.Family", "label":"Product Family", "type":"string"} 
        ];
        component.set("v.opportunityColumns", opportunityColumns);
    }, 
    splitOppProducts : function(component, event, helper) {   
        var recordId = component.get("v.recordId"); 
        if(component.get("v.mapOpportunityLineItems") == 1){
            component.get("v.utility").showError("You should have more than 1 product to split the opportunity."); 
        }else if(component.get("v.mapOpportunityLineItems") && component.get("v.opportunityLineItems").length>1){ 
            var productId = "";
            if(event){
                if(event && event.target && event.target.value){
                    productId = event.target.value;
                }else if(event["source"]["t"] != undefined || event["source"]["t"] != null){
                    productId = event["source"]["t"]["z"]["title"]["ih"];
                } else{
                    productId = event.$params$.domEvent.target.title;
                }
            }
            if(component.get("v.mapOpportunityLineItems")[productId] != null){ 
                var selectedRecord = component.get("v.mapOpportunityLineItems")[productId]; 
                if(selectedRecord.hasOwnProperty("attributes")){
                    delete selectedRecord["attributes"];
                }
                if(selectedRecord.PricebookEntry && selectedRecord.PricebookEntry.hasOwnProperty("attributes")){
                    delete selectedRecord.PricebookEntry["attributes"];
                }
                if(selectedRecord.PricebookEntry && selectedRecord.PricebookEntry.Product2 && selectedRecord.PricebookEntry.Product2.hasOwnProperty("attributes")){
                    delete selectedRecord.PricebookEntry.Product2["attributes"];
                }
                if(selectedRecord.Geography__r && selectedRecord.Geography__r.hasOwnProperty("attributes")){
                    delete selectedRecord.Geography__r["attributes"];
                }
                if(selectedRecord.Building__r && selectedRecord.Building__r.hasOwnProperty("attributes")){
                    delete selectedRecord.Building__r["attributes"];
                }
                component.get("v.utility").showProcessing();
                component.get("v.utility").execute("c.splitOpportunity", {"oppRecId": component.get("v.recordId"), "lineItemRec": selectedRecord }, function(splitOpportunityresponse){
                    component.get("v.utility").hideProcessing();
                    if(splitOpportunityresponse != null){
                        helper.openSFRecord(component, helper, splitOpportunityresponse); 
                    } else {
                        component.get("v.utility").showError("Something went wrong, please contact your system administrator.");
                    }
                }, function(error){
                    component.get("v.utility").hideProcessing();
                    component.get("v.utility").showError(error);
                }, component);
            } 
        } else{
            component.set("v.message", "You can not split opportunity as there are no products.");
        } 
    },
    cancel : function(component, event, helper){
        if(component.get("v.recordId")){
            helper.openSFRecord(component, helper, component.get("v.recordId"));
        }else{
            history.back();
            component.get("v.utility").closeTab();
        }
    },
    redirectToUrl:  function(component, event, helper){
        var productId = '';
        if(event && event.target && event.target.value){
            productId = event.target.value;
        }else if(event["source"]["t"] != undefined || event["source"]["t"] != null){
            productId = event["source"]["t"]["z"]["title"]["ih"];
        } else{
            productId = event.$params$.domEvent.target.title;
        }         
        if(sforce){
            if(sforce.console && sforce.console.isInConsole()){
                sforce.console.getEnclosingPrimaryTabId(function(result){
                    if(result.id != "null"){
                        sforce.console.openSubtab(result.id, "/"+productId, true);
                    }
                })
            }else if(sforce && sforce.one){
                sforce.one.navigateToURL(productId);
            } else {
                window.open("/"+productId, '_blank');
            }
        }else{
            window.open("/"+productId, '_blank');
        }        
    }    
})