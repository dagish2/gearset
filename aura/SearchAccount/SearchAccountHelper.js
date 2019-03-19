({
    getData : function(component,helper,entity) {
        var keyword = component.get("v.keyword"); 
        var query ="";
        var queryBill = "";
        var queryArray = [];
        var method = "";
        if(entity.isSales || entity.isOrg){
            if(keyword && keyword.length > 2){
                method += "c.getListQueryDataBySOSL";
                query += 'FIND \''+ component.find("utils").addSlashes(keyword) +'*\' IN Name FIELDS RETURNING Account(Id,Name,Primary_Member__r.Name,Account_Type__c,RecordType.Name,Owner.Name,Number_Of_Open_Opportunities__c,Parent.Name,ParentId,ID_Status2__c';
                var typeCriteria = '';
                if(entity.isSales){
                    typeCriteria += 'Account_Type__c=\'Sales\''; 
                }
                if(entity.isOrg){
                    if(entity.isSales){
                        typeCriteria += ' OR '; 
                    }
                    typeCriteria += 'Account_Type__c=\'Org\'';
                }
                query += ' WHERE ('+typeCriteria+') ORDER BY Name) Limit 2000';
            }else{
                method += "c.getListQueryData";
                query += "Select Id,Name,Primary_Member__r.Name,RecordType.Name,Owner.Name,Account_Type__c,Number_Of_Open_Opportunities__c,Parent.Name,ParentId,ID_Status2__c From Account";            
                
                var typeCriteria = '';
                if(entity.isSales){
                    typeCriteria += "Account_Type__c='Sales'";
                }
                if(entity.isOrg){
                    if(entity.isSales){                    
                        typeCriteria += ' OR ';
                    }                
                    typeCriteria += "Account_Type__c='Org'";
                }
                query += ' WHERE ('+typeCriteria+') ORDER BY Name Limit 2000';
            }
        }
        if(entity.isBill){
            if(keyword && keyword.length > 2){
                if(method == "" || method == 'undefined' || method == null)
                    method += 'c.getListQueryDataBySOSL';
                queryBill += 'FIND \''+ component.find("utils").addSlashes(keyword) +'*\' IN Name FIELDS RETURNING Billing_Account__c(Id,Name,Parent_Account__c,Parent_Account__r.Name,ID_Status__c,Owner.Name,Primary_Member__c,Primary_Member__r.Name,Number_Of_Open_Opportunities__c ORDER BY Name) Limit 2000';
            }else{
                 if(method == "" || method == 'undefined' || method == null)
                    method += 'c.getListQueryData';
                queryBill += "SELECT Id,Name,Parent_Account__c,Parent_Account__r.Name,ID_Status__c,Owner.Name,Primary_Member__c,Primary_Member__r.Name,Number_Of_Open_Opportunities__c FROM Billing_Account__c order by Name Limit 2000"; 
            }  
        }
        if(query){
           queryArray.push(query);
        }
        if(queryBill){
           queryArray.push(queryBill);
        }
        console.log('query:'+query);
        console.log('query:'+queryBill);
        if(queryArray != null && queryArray.length > 0){
            component.find("utils").execute(method,{"arrQuery": queryArray},function(response){ 
                if(response && response != 'undefined' && response.length > 0){
                    var records = [];
                    if(response[0] != null && response[0] != 'undefined'){
                        records = response[0];
                    }
                    if(response[1] != null && response[1] != 'undefined'){
                        records = response[0].concat(response[1]);
                    }
                    helper.setMetaFields(component, event, helper,entity);
                    component.set("v.relatedAccounts",records);
                    component.find("utils").hideProcessing();
                }else{
                    component.set("v.relatedAccounts",[]);
                    component.find("utils").hideProcessing();
                }
            },function(error){
                component.find("utils").showError(error);
                component.find("utils").hideProcessing();
            });
        }else{
           component.find("utils").hideProcessing(); 
        }
    },
    setMetaFields:function(component, event, helper,entity){
        var metaFields = [];      
        metaFields.push({"name":"Name","label":"Name","showtooltip":"true","tooltiptext":"Name of the Account","type":"component","component":{"name":"ui:outputUrl","attributes":{"label":"{{Name}}","value":"/{{Id}}","target":"_blank"}}});
        metaFields.push({"name":"Parent.Name;Parent_Account__r.Name","label":"Parent Account","showtooltip":"true","tooltiptext":"Primary Member of Account","type":"component","component":{"name":"ui:outputUrl","attributes":{"label":"{{Parent.Name}}{{Parent_Account__r.Name}}","value":"/{{ParentId}}{{Parent_Account__c}}","target":"_blank"}}});
        if(!entity.isBill || entity.isAll || entity.isSales || entity.isOrg){
            metaFields.push({"name":"RecordType.Name","label":"Segment","showtooltip":"true","tooltiptext":"Record Type of Account"});
            metaFields.push({"name":"Account_Type__c","label":"Type","showtooltip":"true","tooltiptext":"Type of Account"});
        }
        metaFields.push({"name":"ID_Status2__c;ID_Status__c","label":"Status","showtooltip":"true","tooltiptext":"Status of Account","type":"component","component":{"name":"ui:outputText","attributes":{"label":"{{ID_Status2__c}}{{ID_Status__c}}","value":"{{ID_Status2__c}}{{ID_Status__c}}","target":"_blank"}}});
        metaFields.push({"name":"Owner.Name","label":"Owner","showtooltip":"true","tooltiptext":"Name of the Owner of Account","type":"component","component":{"name":"ui:outputUrl","attributes":{"label":"{{Owner.Name}}","value":"/{{Owner.Id}}","target":"_blank"}}});  
        metaFields.push({"name":"Primary_Member__r.Name","label":"Primary Member","showtooltip":"true","tooltiptext":"Primary Member of Account","type":"component","component":{"name":"ui:outputUrl","attributes":{"label":"{{Primary_Member__r.Name}}","value":"/{{Primary_Member__c}}","target":"_blank"}}});
        metaFields.push({"name":"Number_Of_Open_Opportunities__c","label":"#open opps","showtooltip":"true","tooltiptext":"Count of open opportunities on Account"});
       
        component.set("v.metaFields",metaFields);
    },
     resetTable:function(component){
        component.set("v.defaultPageAttribute",{'currentPage':1,'pageSize':5});
    },
})