({
    doInit: function (component, event, helper) {
       if(component.get("v.leadId") || component.get("v.journeyId")){
        component.set("v.processingCompleted",false); 
        var lstInstructions = [];
        lstInstructions.push('If you want to book a tour for a sales account then you need to select one sales account and click on Use Selected Account button.');
        lstInstructions.push('If you want to book a tour for a org account then simple click on convert to org button.');
        lstInstructions.push('If org don\'t have sales accounts then the lead will directly convert to org account.');        
        var instructions = {};
        instructions["instructions"] = lstInstructions;
        instructions["listType"] = "Unordered";
        instructions["color"] = "default";
        instructions["fontSize"] = "default";
        instructions["listStyleType"] = "square";
        component.set("v.instructions",instructions);     
            var metaFields = [];
            metaFields.push({"name":"Select","label":"Select","type":"component","sort":"false","component":{"name":"c:EnziInputRadio","attributes":{"value":component.getReference("v.selectedRecord"),"text":"{{Id}}"}}});
            metaFields.push({"name":"Account","label":"Account","type":"component","component":{"name":"ui:outputURL","attributes":{"label":"{{Account}}","value":"/{{AccountId}}","target":"_blank"}},'showtooltip':'true','tooltiptext':'Name of the sales account'});
            metaFields.push({"name":"Owner","label":"Account Owner","type":"component","component":{"name":"ui:outputURL","attributes":{"label":"{{Owner}}","value":"/{{OwnerId}}","target":"_blank"}},'showtooltip':'true','tooltiptext':'Name of the sales account Owner'});
            // metaFields.push({"name":"IdStatus","label":"Status",'showtooltip':'true','tooltiptext':'hey there'});
            metaFields.push({"name":"Segment","label":"Segment",'showtooltip':'true','tooltiptext':'Shows the record type of sales account'});
            metaFields.push({"name":"AccountType","label":"Account Type",'showtooltip':'true','tooltiptext':'Shows the Type of Account'});
            metaFields.push({"name":"PrimaryMember","label":"Primary Member","type":"component","component":{"name":"ui:outputURL","attributes":{"label":"{{PrimaryMember}}","value":"/{{PrimaryMemberId}}","target":"_blank"}},'showtooltip':'true','tooltiptext':'Primary member of the sales account'});
            metaFields.push({"name":"Email","label":"Main Contact Email","type":"component","component":{"name":"ui:outputURL","attributes":{"label":"{{Email}}","value":"mailTo:{{Email}}","target":"_blank"}},'showtooltip':'true','tooltiptext':'Primary member email of the sales account'});
            metaFields.push({"name":"CreatedDate","label":"Created Date","type":"date",'showtooltip':'true','tooltiptext':'Shows the created date of Sales account'});
            component.set("v.metaFields",metaFields);           
            helper.isValisUserToShowAccountSelector(component,helper,function(showAccountSelector){                
                if(showAccountSelector){
                    if(component.get("v.leadId")){
                        helper.setTableRecords(component,helper,event);
                    }else if(component.get("v.journeyId")){
                        component.find("utils").execute("c.getQueryData",{"query":"Select Id,Primary_Lead__c,Primary_Lead__r.Account__c,Primary_Contact__c From Journey__c Where Id='"+component.get("v.journeyId")+"'"},function(response){
                            if(response[0].Primary_Lead__c){
                                component.set("v.leadId",response[0].Primary_Lead__c);
                                helper.setTableRecords(component,helper,event);                          
                            }
                        })
                    }else{
                        component.set("v.processingCompleted",true);
                        component.set("v.selectedAction","Convert to Org");
                    } 
                }else{
                    component.set("v.processingCompleted",true); 
                    component.set("v.selectedAction","Convert to Org");                    
                }
            });
        }
    },
    useSelected : function(component, event, helper){
        component.set("v.selectedAction","Use Selected to Convert");
    },
    convertToOrg : function(component, event, helper){
        component.set("v.selectedAction","Convert to Org");
    }
})