({
    getLeadInfo:function(component,onsuccess){
        component.find("utils").execute("c.getQueryData",{"query":"Select Id,Name,Salutation,Company,Email,Phone,Cleansed_Company_Name__c,Account__c From Lead Where Id='"+component.get("v.leadId")+"' AND IsConverted=false"},function(response){  
            if(response && response[0]){
                component.set("v.entity",{"name":response[0].Name,"email":response[0].Email,"company":response[0].Company,"phone":response[0].Phone,"cleansedCompany":response[0].Cleansed_Company_Name__c,"parentAccountId":response[0].Account__c});
                if(response[0].Account__c){
                    onsuccess(true);   
                }else{
                    onsuccess(false);      
                }   
            }else{
                onsuccess(null);  
            }                      
        },function(error){
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        })
    },
    getUltimateOrg : function(component,leadRecord,onsuccess){
        component.find("utils").execute("c.getUltimateOrg",{"leadId":leadRecord},function(response){
            if(response){                
                onsuccess(response);    
            }else{
                onsuccess(null);    
            }           
        }) 
    },
    getRelatedAccounts : function(component,leadId,parentId,onsuccess){
        var helper = this;
        component.find("utils").execute("c.getRelatedAccounts",{"leadId":leadId,"parentId":parentId},function(response){
            if(response){  
                component.set("v.OrgRecord",response["OrgAccount"][0]);
                if(response["SalesAccounts"] && response["SalesAccounts"].length>0){
                    onsuccess(helper.formatRecords(component,response["SalesAccounts"]));   
                }else{
                    component.set("v.processingCompleted",true);
                    component.set("v.selectedAction","Convert to Org"); 
                    onsuccess(response["SalesAccounts"]);                     
                }                  
            }else{
                onsuccess(null);    
            }           
        },function(error){
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        }); 
    },
    formatRecords : function(component,records){        
        var lstOrgAccounts =[];
        var lstSalesAccounts =[];
        for(var r in records){
            var record = {};
            record.Id = records[r].Id;
            if(records[r].RecordType){
                record.Segment = records[r].RecordType.Name;
            }
            record.Account = records[r].Name;
            record.AccountType = records[r].Account_Type__c;
            record.AccountId = records[r].Id;
            record.Owner = records[r].Owner.Name;
            record.OwnerId = records[r].Owner.Id;
            record.IdStatus = records[r].ID_Status2__c;
            record.CreatedDate = records[r].CreatedDate;
            if(records[r].Primary_Member__c){
                record.PrimaryMemberId = records[r].Primary_Member__c;
                record.PrimaryMember = records[r].Primary_Member__r.Name;                
                record.Email = records[r].Primary_Member__r.Email;
            }else{
                record.PrimaryMember = '';
                record.PrimaryMemberId = '';
                record.Email = '';
            }          
            if(record.AccountType == 'Org'){
                lstOrgAccounts.push(record);
            }else{
                lstSalesAccounts.push(record);
            }            
        }         
        return lstOrgAccounts.concat(lstSalesAccounts);
    },      
    isValisUserToShowAccountSelector : function(component,helper,onsuccess){      
        component.find("utils").execute("c.isValisUserToShowAccountSelector",{},function(response){                       
            console.log('isValisUserToShowAccountSelector==>'+response);
            onsuccess(response);                          
        },function(error){
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        }); 
    },  
    setTableRecords : function(component,helper,event){       
        helper.getLeadInfo(component,function(isParent){
            if(isParent != null){
                var parentId = null;
                if(isParent){
                    parentId = component.get("v.entity.parentAccountId");
                }
                helper.getRelatedAccounts(component,component.get("v.leadId"),parentId,function(records){
                    if(records && records.length>0){
                        component.set("v.records",records);
                        component.set("v.processingCompleted",true);    
                    }else{
                        component.set("v.processingCompleted",true);  
                        component.set("v.selectedAction","Convert to Org");  
                    }                   
                },function(error){
                    component.find("utils").hideProcessing();
                    component.find("utils").showError(error);
                });   
            }else{
                component.set("v.processingCompleted",true);  
                component.set("v.selectedAction","Convert to Org");    
            }
        }) 
    },    
})