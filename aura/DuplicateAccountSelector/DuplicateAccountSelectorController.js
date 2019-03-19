({
	doInit: function (component, event, helper) {
        component.set("v.processingCompleted",false);
        if(component.get("v.leadId") || component.get("v.journeyId")){
            var metaFields = [];
            metaFields.push({"name":"Select","label":"Select","type":"component","sort":"false","component":{"name":"c:EnziInputRadio","attributes":{"value":component.getReference("v.selectedRecord"),"text":"{{Id}}"}}});
            metaFields.push({"name":"IdStatus","label":"Status"});
            metaFields.push({"name":"Segment","label":"Segment"});
            metaFields.push({"name":"AccountType","label":"Account Type"});
            metaFields.push({"name":"PrimaryMember","label":"Primary Member","type":"component","component":{"name":"ui:outputURL","attributes":{"label":"{{PrimaryMember}}","value":"/{{PrimaryMemberId}}","target":"_blank"}}});
            metaFields.push({"name":"Email","label":"Email","type":"component","component":{"name":"ui:outputURL","attributes":{"label":"{{Email}}","value":"mailTo:{{Email}}","target":"_blank"}}});
            metaFields.push({"name":"Account","label":"Account","type":"component","component":{"name":"ui:outputURL","attributes":{"label":"{{Account}}","value":"/{{AccountId}}","target":"_blank"}}});
            metaFields.push({"name":"Owner","label":"Account Owner","type":"component","component":{"name":"ui:outputURL","attributes":{"label":"{{Owner}}","value":"/{{OwnerId}}","target":"_blank"}}});
            //metaFields.push({"name":"Country","label":"Country"});
            //metaFields.push({"name":"State","label":"State"});
            //metaFields.push({"name":"City","label":"City"});
            metaFields.push({"name":"Source","label":"Source"});
            metaFields.push({"name":"CreatedDate","label":"Created Date","type":"date"});
            component.set("v.metaFields",metaFields);
            helper.getUserProfileInfo(component,helper,function(showAccountSelector){
                if(component.get("v.leadId")){
                    helper.getLeadInfo(component,function(){                      
                        helper.getAccounts(component,[component.get('v.entity.cleansedCompany')],component.get('v.entity.email'),component.get('v.entity.parentAccountId'),function(records){
                            component.set("v.records",records);
                            component.set("v.processingCompleted",true);
                        })
                    })
                }else if(component.get("v.journeyId")){
                    component.find("utils").execute("c.getQueryData",{"query":"Select Id,Primary_Lead__c,Primary_Lead__r.Account__c,Primary_Contact__c From Journey__c Where Id='"+component.get("v.journeyId")+"'"},function(response){
                        if(response[0].Primary_Lead__c){
                            component.set("v.leadId",response[0].Primary_Lead__c);
                            helper.getLeadInfo(component,function(){
                                helper.getAccounts(component,[component.get('v.entity.cleansedCompany')],component.get('v.entity.email'),component.get('v.entity.parentAccountId'),function(records){
                                    component.set("v.records",records);
                                    component.set("v.processingCompleted",true);
                                })
                            })
                        }
                    })
                }else{
                    component.set("v.processingCompleted",true);
                }
            });
        }
	},
	continue:function(component, event, helper){
		component.set("v.selectedAction","Use Selected");
	},
	createNew:function(component, event, helper){
		component.set("v.selectedAction","Create New");
	},
    createNewDontMerge:function(component, event, helper){
		component.set("v.selectedAction","Create New and Dont Merge");
	}
})