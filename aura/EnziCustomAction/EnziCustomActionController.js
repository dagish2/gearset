({ 
    followUpCall : function(component, event, helper){ 
     component.find("utils").addComponent("c:EnziFrame",{"url":'apex/JourneyFollowUp?Id='+component.get("v.recordId"),"header":"Follow Up Call","isLarge":false});
    },
    logCall : function(component, event, helper) {
        component.find("utils").showProcessing();
        component.find("utils").execute("c.getQueryData",{"query":"SELECT Id, Outreach_Stage__c, Status__c FROM Journey__c WHERE Id = '" + component.get("v.recordId") + "'"}, function(response){
            component.find("utils").hideProcessing();
            if(response){
                component.find("utils").execute("c.getQueryData",{"query":"SELECT Id, Data__c FROM Setting__c WHERE Name = 'JourneyCloseStages'"},function(settingData){
                    if(settingData && JSON.parse(settingData[0].Data__c).includes(response[0].Status__c)){
                        component.find("utils").showError("No further actions possible as the journey status is other than open.");
                    } else {
                        component.find("utils").addComponent("c:LogACall", {"recordId": component.get("v.recordId"), "logACall": component.getReference("c.refresh")});
                    }
                });
            }
        },function(error){
            component.find("utils").showError(error);
            component.find("utils").hideProcessing();
        })
    },
    addToCampaign : function(component, event, helper) {
        component.find("utils").showProcessing();
        component.find("utils").execute("c.getQueryData",{"query":"Select Id,Outreach_Stage__c,Status__c from Journey__c where Id='"+component.get("v.recordId")+"'"},function(response){
            component.find("utils").hideProcessing();
            if(!(response[0].Outreach_Stage__c != 'NMD Drip' && response[0].Status__c=='Started')){
                component.find("utils").showError('No further actions possible as the member is not eligible for Marketing drip.');
            }else{
                component.find("utils").addComponent("c:EnziFrame",{"url":'/apex/AddMembersToCampaign?lstJourney='+component.get("v.recordId"),"header":"Add to Campaign","isLarge":false	});
            }
        },function(error){
            component.find("utils").showError(error);
            component.find("utils").hideProcessing();
        })
    },
    sendToEnterprize : function(component, event, helper) {
        component.find("utils").addComponent("c:EnziFrame",{"url":'/apex/JourneyAction?journeyId='+component.get("v.recordId")+"&action=sendtomarketing","header":"Send to Enterprise","isLarge":false});
    },
    sendToEnterprise : function(component, event, helper) {
        helper.validateReferrer(component, component.get("v.recordId"),function(){
            component.find("utils").hideProcessing();
            component.find("utils").redirectToUrl("/apex/CreateOpportunity?id="+component.get("v.recordId"));
        },function(error){
            component.find("utils").showError(error);
            component.find("utils").hideProcessing();
        });
    },
    sendToEnterpriseFromLead : function(component, event, helper) {
        var params = event.getParam("arguments");
        helper.validateReferrer(component, params.recordId, function(){
            component.find("utils").hideProcessing();
            component.find("utils").redirectToUrl(params.redirectToUrl);
        },function(error){
            component.find("utils").showError(error);
            component.find("utils").hideProcessing();
        });
    },
    unqualify : function(component, event, helper) {
        component.find("utils").addComponent("c:JourneyUnqualifyAction", {"recordId": component.get("v.recordId"), "isFromJourneyDetails": true});        
        //component.find("utils").addComponent("c:EnziFrame", {"url": "/apex/JourneyUnqualify?journeyId=" + component.get("v.recordId"), "header": "Unqualify", "isLarge": false});
    },
    manageTours : function(component, event, helper) {
        component.find("utils").showProcessing();
        component.find("utils").execute("c.getQueryData",{"query":"Select Id,Status__c,Primary_Lead__c, Primary_Contact__c, Primary_Contact__r.LeadSource, Primary_Contact__r.Referrer__c , Primary_Lead__r.LeadSource, Primary_Lead__r.Referrer__c from Journey__c where Id='"+component.get("v.recordId")+"'"},function(response){
            if( response[0].Status__c == "Unqualified"){
                component.find("utils").hideProcessing();
                component.find("utils").showError('No further actions possible as the Journey is unqualified.');
            }else{
                helper.validateReferrer(component, component.get("v.recordId"), function(){
                    component.find("utils").redirectToUrl(event.getParam('arguments').redirectToUrl);
                },function(error){
                    component.find("utils").showError(error);
                    component.find("utils").hideProcessing();
                });
            }
        },function(error){
            component.find("utils").showError(error);
            component.find("utils").hideProcessing();
        })
    },
    manageToursFromLead : function(component, event, helper) {
        var params = event.getParam("arguments");
        helper.validateReferrer(component, params.recordId, function(){
            component.find("utils").redirectToUrl(params.redirectToUrl);
        },function(error){
            component.find("utils").showError(error);
            component.find("utils").hideProcessing();
        });
    },
    availiblity : function(component, event, helper) {
        component.find("utils").hideProcessing();
        component.find("utils").redirectToUrl("/apex/Availability?journeyId=" + component.get("v.recordId"));
    },
    addOpportunity : function(component, event, helper) {
        component.find("utils").showProcessing();
        component.find("utils").execute("c.getQueryData",{"query":"SELECT Id, Status__c,Primary_Lead__c, Primary_Contact__c, Primary_Lead__r.LeadSource, Primary_Lead__r.Referrer__c, Primary_Contact__r.LeadSource, Primary_Contact__r.Referrer__c FROM Journey__c WHERE Id='"+component.get("v.recordId")+"'"},function(response){
            component.find("utils").hideProcessing();
            if( response[0].Status__c == "Unqualified"){
                component.find("utils").showError("No further actions possible as the Journey is unqualified.");
            }else{
                component.find("utils").execute("c.validateLead", {"recordId": component.get("v.recordId")}, function(result){    
                    component.find("utils").redirectToUrl("/apex/AddOpportunity?journeyId=" + component.get("v.recordId"));
                }, function(error){
                    component.find("utils").showError(error);
                    component.find("utils").hideProcessing();
                });    
            }
        },function(error){
            component.find("utils").showError(error);
            component.find("utils").hideProcessing();
        });        
    },
    restartJourney : function(component, event, helper){
        component.find("utils").hideProcessing();
        component.find("utils").addComponent("c:EnziFrame", {"url":'/apex/RestartJourney', "header":"Restart Journey","isLarge":true});
    },
    convertBrokerLead : function(component, event, helper){
        var params = event.getParam('arguments');
        component.find("utils").execute("c.verifyBrokerLead", {"leadId": params.record.Id,"convertLead" : true, "objlead": params.record, "journeyId": params.journeyId, "isNewAccountCreated": params.isNewAccountCreated ? params.isNewAccountCreated : false}, function(result){
            var contactId = JSON.parse(result).contactId;
            if(result && contactId){
                params.success(contactId);
            }else{
                component.find("utils").showSuccess("Lead Converted Successfully.");
            }
        }, function(error){
            params.error(error);
        }, params.component);
    },
    verifyBrokerLead : function(component, event, helper){
        var params = event.getParam('arguments');
        var lead = new sforce.SObject("Lead"); 
        component.find("utils").execute("c.verifyBrokerLead", {"leadId":  params.recordId, "convertLead":false, "objlead":lead, "journeyId": "", "isNewAccountCreated": false}, function(result){
            for(var key in result){
                lead[key] = result[key]; 
            }
            delete lead.attributes;
            params.success(lead);
        },function(error){
            params.error(error);
        },params.component);
    },
    refresh : function(){
        location.reload();
    }
})