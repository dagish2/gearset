({
	getBillingAccountUUID: function(component, uuid, isExistingContact, onsuccess, onerror) {
		var helper = this;
        component.find("utils").execute("c.getQueryData",{"query":"Select Data__c From Setting__c Where Name='TourReservableAPI'"},function(setting) {
            if(setting && setting.length) {
                var api = JSON.parse(setting[0].Data__c).CreateAccountAPI;
                if(api) { 
                    var entity = component.get("v.newEntity");
                    helper.getApiBody(component,uuid,isExistingContact,function(payload) {
                        component.find("utils").execute("c.executeRestQuery",{"setUrl":!(api.url.includes("https:") || api.url.includes("http:")),"method":"POST","endPointUrl":api.url,"headers":api.headers,"body":payload},function(response) {
                            if(response) {
                                response = JSON.parse(response);
                                if(response.hasOwnProperty('account_uuid') && response.hasOwnProperty('user_uuid')) {
                                    onsuccess(response);
                                }else {
                                    onerror(response.error);
                                }
                            }else {
                                onerror('Unable to connect spacestation');
                            }    
                        },function(error) {
                            onerror(error);
                        })
                        
                    });
                    
                }else {
                    onerror('Create Sales API setting not found.');
                }
            }else {
                onerror('Tour reservable setting not found.');
            }
        },function(error) {
            onerror(error);
        })
	},
    updateParentAccountOnOpportunity: function(component, billingAccountId, onsuccess, onerror) {
        if(component.get("v.parentRecordTypeId")==undefined && component.get("v.parentId")) {
            component.find("utils").execute("c.getQueryData",{"query":"SELECT Id From Billing_Account__c WHERE Parent_Account__c='"+component.get("v.parentId")+"'"},function(response) { 
                var account = {"Id":billingAccountId,"Parent_Account__c":component.get("v.parentId")}   
                component.find("utils").execute("c.saveRecords",{"records":[{"Id":component.get("v.recordId"),"Billing_Account__c":billingAccountId},account]},function(response) {
                    onsuccess();
                },function(error) {
                    onerror(error);
                })                 
            },function(error) {
                onerror(error);
            })  
        }else {
             if(component.get("v.parentRecordTypeId")) {
              var account = {"Id":billingAccountId,"RecordTypeId":component.get("v.parentRecordTypeId"),"ParentId":component.get("v.parentId")}  
                }
             else {
            var account = {"Id":billingAccountId,"ParentId":component.get("v.parentId")}   
                 } 
            component.find("utils").execute("c.saveRecords",{"records":[{"Id":component.get("v.recordId"),"Billing_Account__c":billingAccountId},account]},function(response) {
                onsuccess();
            },function(error) {
                onerror(error);
            }) 
        }
    },
    getApiBody: function(component, uuid, isExisitingContact, onsuccess) {
        var entity = component.get("v.newEntity");
        var payLoad = {"account_name":entity.AccountName,"primary_member":{"name":entity.ContactName,"email":entity.Email,"phone":entity.Phone}};
        if(isExisitingContact && uuid)
        {
            payLoad["primary_member"]["uuid"] = uuid; 
        }
        onsuccess(JSON.stringify(payLoad));
    },
    setMetaFields: function(component, event, helper) {
        var metaFields = [];
        metaFields.push({"name":"Id","label":"Action","type":"component","sort":"false","component":{"name":"c:EnziInputRadio","attributes":{"value":component.getReference("v.selectedRecord"),"text":"{{UUID__c}}"}}});
        metaFields.push({"name":"Owner.Name","label":"Owner","type":"component","component":{"name":"ui:outputUrl","attributes":{"label":"{{Owner.Name}}","value":"/{{OwnerId}}"}}});
        metaFields.push({"name":"Name","label":"Name","type":"component","component":{"name":"ui:outputUrl","attributes":{"label":"{{Name}}","value":"/{{Id}}"}}});
        metaFields.push({"name":"Primary_Member__r.Name","label":"Primary Member","type":"component","component":{"name":"ui:outputUrl","attributes":{"label":"{{Primary_Member__r.Name}}","value":"/{{Primary_Member__c}}"}}});
        metaFields.push({"name":"Parent.Name","label":"Parent Account","type":"component","component":{"name":"ui:outputUrl","attributes":{"label":"{{Parent.Name}}","value":"/{{ParentId}}"}}});
        metaFields.push({"name":"Number_Of_Open_Opportunities__c","label":"Open Opportunities"});
        component.set("v.metaFields",metaFields); 
    },
    checkPrimaryMember: function(component, contact, onSuccess) {
        if(contact != undefined) {
            component.find("utils").execute("c.getQueryData",{"query":"Select Id From contact where Id = '"+contact.Id+"'"},function(response) {
                if(response && response.length) {
                        var query ="SELECT Id, Name , Primary_member__r.Name FROM Billing_Account__c WHERE Primary_Member__c = '"+contact.Id+"'"; 
                        component.find("utils").execute("c.getQueryData",{"query":query},function(response) {
                            if(response && response.length) {
                                component.find("utils").showError(response[0].Primary_Member__r.Name+" is already a primary member on "+response[0].Name+". Please select another contact or contact your support team.");
                                component.find("utils").hideProcessing();
                                onSuccess(false);
                            }else if(contact.hasOwnProperty('AccountId') && contact.AccountId != undefined && contact.AccountId !="" ) {
                                component.find("utils").execute("c.getOrg",{"accountId":contact.AccountId},function(response) {
                                    var org = component.get("v.ultimateParentOrgId")
                                    if(org != response) { 
                                        component.find("utils").showError(contact.Name+" is a member of a different Organization. You can only select a member of your Organization. Please contact your support team.");
                                        onSuccess(false);
                                        component.find("utils").hideProcessing();
                                    }else {
                                        onSuccess(true);
                                        component.find("utils").hideProcessing();
                                    }
                                    
                                }, function(error) {
                                    helper.showError(component, error);
                                });
                            }else {
                                onSuccess(true);
                                component.find("utils").hideProcessing();
                            }
                        }, function(error) {
                            helper.showError(component, error);
                        });  
                }else {
                    helper.showError(component, error);
                } 
            },function(error) {
                helper.showError(component, error);
            });
        }
    },
    updateAccountOnContact: function(component, contactId, helper) {
       
        if(component.get("v.parentId")) {
            component.find("utils").execute("c.saveRecord",{"record":{"Id":contactId,"AccountId":component.get("v.parentId")}},function(response) {
                
            },function(error) {
                onerror(error);
            }) 
        }
    },
    showError : function(component, error){
        component.find("utils").showError(error);
        component.find("utils").hideProcessing();
    },   
    ValidateEmail: function(component, event, helper) 
    {
        if (/^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/.test(component.get("v.newEntity.Email")))
        {
            return (true);
        }
        return (false);
    }
})