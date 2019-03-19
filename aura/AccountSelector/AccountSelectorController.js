({
	getLeadRecord : function(component, event, helper) { 
        component.set("v.leadRec", new Map());
        component.set("v.previous", {
            "label": "Back",
            "click": component.getReference("c.searchOtherAccounts")
        });
        
        var accountColumns = [];      
        accountColumns.push({"name": "Id", "label": "Action", "type": "component", "sort":"false","component":{"name":"c:EnziInputRadio","attributes":{"value":component.getReference("v.selectedOrgId"),"text":"{{Id}}"}}}); 
        //accountColumns.push({"name": "Id", "label": "View Hierarchy", "type": "component","sort":"false","component":{"name":"c:EnziButton","attributes":{"label":"View Hierarchy","id":"{{Id}}","disabled":"'{{childAccounts.size()}}' == 0","click":component.getReference("c.viewHierarchy")}}});
        accountColumns.push({"name": "Name", "label":"Account Name", "type": "component", "component":{"name":"ui:outputUrl", "attributes":{"label":"{{Name}}", "value":"/{{Id}}", "target":"_new"}}});
        accountColumns.push({"name": "Account_Type__c","label":"Account Type"});
        accountColumns.push({"name": "Parent.Name", "label":"Parent Account", "type": "component", "component":{"name":"ui:outputUrl", "attributes":{"label":"{{Parent.Name}}", "value":"/{{Parent.Id}}"}}});
        accountColumns.push({"name": "Main Contact", "label":"Main Contact", "type": "component", "component":{"name":"ui:outputUrl", "attributes":{"label":"{{Primary_Member__r.Name}}", "value":"/{{Primary_Member__c}}", "target":"_new"}}});
        accountColumns.push({"name": "Main Contact Email", "label":"Main Contact Email", "type":"component", "component":{"name":"ui:outputUrl", "attributes":{"label":"{{Primary_Member__r.Email}}", "value":"mailto:{{Primary_Member__r.Email}}", "target":"_new"}}});
        accountColumns.push({"name": "OwnerId", "label":"Account Owner", "type":"component", "component":{"name":"ui:outputUrl", "attributes":{"label":"{{Owner.Name}}", "value":"/{{Owner.Id}}", "target":"_new"}}});  
       
		var salesAccountColumns = [];  
        salesAccountColumns.push({"name": "Id","label":"Action","type":"component","sort":"false","component":[{"name":"c:EnziInputRadio","attributes":{"value":component.getReference("v.selectedOrgId"),"text":"{{Id}}"}}]});
        salesAccountColumns.push({"name": "Name","label":"Account Name","type":"component","component":{"name":"ui:outputUrl","attributes":{"label":"{{Name}}","value":"/{{Id}}","target":"_new"}}});            
        salesAccountColumns.push({"name": "Account_Type__c","label":"Account Type"});
        salesAccountColumns.push({"name": "Parent.Name","label":"Parent Account","type":"component","component":{"name":"ui:outputUrl","attributes":{"label":"{{Parent.Name}}","value":"/{{Parent.Id}}"}}});
        salesAccountColumns.push({"name": "Main Contact","label":"Main Contact","type":"component","component":{"name":"ui:outputUrl","attributes":{"label":"{{Primary_Member__r.Name}}","value":"/{{Primary_Member__c}}","target":"_new"}}});
        salesAccountColumns.push({"name": "Main Contact Email","label":"Main Contact Email","type":"component","component":{"name":"ui:outputUrl","attributes":{"label":"{{Primary_Member__r.Email}}","value":"mailto:{{Primary_Member__r.Email}}","target":"_new"}}});
        salesAccountColumns.push({"name": "OwnerId","label":"Account Owner","type":"component","component":{"name":"ui:outputUrl","attributes":{"label":"{{Owner.Name}}","value":"/{{Owner.Id}}","target":"_new"}}});  
        component.set("v.salesAccountColumns", salesAccountColumns);
		        
        component.find("utils").execute("c.getQueryData", {"query": "SELECT Id, Title , FirstName, Name, Interested_in_Number_of_Desks_Min__c,Interested_in_Number_of_Desks__c,LastName,Product_Line__c,OwnerId,Email_Domain__c,Company,Account__c,Account__r.Name,Account__r.Account_Type__c,Referrer__c,Cleansed_Unomy_Company_Name__c,Cleansed_Company_Name__c,Email,Unomy_Company_ID__c,Unomy_Company_Name__c,LeadSource,Lead_Source_Detail__c,Generate_Journey__c,By_Pass_Journey_Creation_Criteria__c,Campaign_Id__c,Building_Interested_In__c,Building_Interested_In__r.City__c,Locations_Interested__c,Number_of_Full_Time_Employees__c, Unomy_Company_Size__c, Company_Size__c, Markets_Interested__c,Phone From Lead WHERE Id = '" + component.get("v.leadId") + "'"}, function(leadRecords){
            var leadRec = leadRecords[0];
            component.set("v.leadRec", leadRec);
            if(leadRec != undefined){
                component.set("v.contactRec", {
                    "FirstName": leadRec["FirstName"],
                    "LastName": leadRec["LastName"],
                    "Email": leadRec["Email"],
                    "Phone": leadRec["Phone"],
                    "Company":leadRec["Company"]                    
                });
            }
            component.set("v.mapDisabled", {
                "FirstName": component.get("v.contactRec.FirstName") ? true : false,
                "LastName": component.get("v.contactRec.LastName") ? true : false,
                "Email": component.get("v.contactRec.Email") ? true : false,
                "Phone": component.get("v.contactRec.Phone") ? true : false
            });
            component.set("v.selectedOrgId", component.get("v.leadRec.Account__c"));
            var headerMetaFields = [];
            headerMetaFields.push({"label": "Title", "apiName": "Title"});
            headerMetaFields.push({"label": "Email", "apiName": "Email", "isNameField": false});
            headerMetaFields.push({"label": "Company", "apiName": "Company", "isNameField": false});
            if(leadRec != undefined && leadRec.Unomy_Company_Size__c != undefined){
                headerMetaFields.push({"label": "Unomy Company Size", "apiName": "Unomy_Company_Size__c"});
            } else {
                headerMetaFields.push({"label": "Number of Full Time Employees", "apiName": "Number_of_Full_Time_Employees__c"});
            }
            component.set("v.headerMetaFields", headerMetaFields);
            var headerFieldsSearchAccount = [].concat(headerMetaFields);
            headerFieldsSearchAccount.splice(0, 1, {"label": "Lead Name", "apiName": "Name", "isNameField": true});
            component.set("v.headerFieldsSearchAccount", headerFieldsSearchAccount);
            helper.getMatchedOrgAccounts(component, function(matchedOrgRecords){
                if( matchedOrgRecords.length > 0 ){
                    if(!matchedOrgRecords[0].Parent)
                        accountColumns.splice(3, 1);
                    helper.searchSalesAccounts(component, event, helper, matchedOrgRecords[0].Id , false, function(records){
                        component.set("v.salesAccounts", records);
                        accountColumns.splice(1, 0, {"name": "Id", "label": "View Hierarchy", "type": "component","sort":"false","component":{"name":"c:EnziButton","attributes":{"label":"View Hierarchy","id":"{{Id}}","disabled":!(records && records.length > 1),"click":component.getReference("c.viewHierarchy")}}});
                        component.set("v.accountColumns", accountColumns);
                        component.set("v.matchedOrgRecords", matchedOrgRecords);
                    }, function(error){
                        component.find("utils").showError(error);
                        component.find("utils").hideProcessing();
                    }); 
                }else{
                    accountColumns.splice(1, 0, {"name": "Id", "label": "View Hierarchy", "type": "component","sort":"false","component":{"name":"c:EnziButton","attributes":{"label":"View Hierarchy","id":"{{Id}}","disabled":false,"click":component.getReference("c.viewHierarchy")}}});
                    component.set("v.accountColumns", accountColumns);
                    component.set("v.matchedOrgRecords", matchedOrgRecords);
                }
                
            });
        }, function(error){
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        });
	},
    viewSales : function(component, event, helper){
        component.set("v.selectedOrgId", "");
        var accountId = event.currentTarget.id;
        helper.searchSalesAccounts(component, event, helper, accountId, true); 
    },
    viewHierarchy:function(component,event,helper){
        component.set("v.selectedOrgId", "");
        component.set("v.selector", 5);
    },
    useSelectedOrg : function(component, event, helper){
        var objAccount = {};
        objAccount.Id = component.get("v.selectedOrgId");
        objAccount.sobjectType = "Account";
        component.set("v.selectedOrg", objAccount);
        var useSelectedAccount = component.get("v.useSelectedAccount");
        if(useSelectedAccount){
            $A.enqueueAction(useSelectedAccount);
        }
        component.set("v.selector", 0);		      
    },
   selectMatchedAccounts : function(component, event, helper) {
    	component.set("v.selector", 1);
        component.set("v.selectedOrgId", null);
    },
    searchOtherAccounts : function(component, event, helper) {
    	component.set("v.selector", 2);        
        component.set("v.selectedOrgId", null);
    },
    createNewAccount : function(component, event, helper) {
    	component.set("v.selector", 3);
        component.set("v.selectedOrgId", null);
    },
    closeSalesAccountModal:function(component,event,helper){
        component.set("v.selectedOrgId", null);
        component.find('salesAccountModal').close();
        component.set("v.selector", 1);
    }
})