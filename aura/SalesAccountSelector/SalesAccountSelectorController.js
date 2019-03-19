({
    getSalesAccounts : function(component, event, helper) {
        var metaFields = [];
        component.find("utils").showProcessing();
        var metaFields = [];
        metaFields.push({"name":"Id","apiName":"Id","label":"Action","type":"component","sort":"false","component":{"name":"c:EnziInputRadio","attributes":{"value":component.getReference("v.selectedSalesAccountId"),"text":"{{Id}}"}}});
        metaFields.push({"name":"Name","apiName":"Name","label":"Account","type":"component","component":{"name":"ui:outputURL","attributes":{"label":"{{Name}}","value":"/{{Id}}","target":"_blank"}},'showtooltip':'true','tooltiptext':'Name of the sales account'});
        metaFields.push({"name":"OwnerId","apiName":"OwnerId","label":"Account Owner","type":"component","component":{"name":"ui:outputUrl","attributes":{"label":"{{Owner.Name}}","value":"/{{OwnerId}}","target":"_blank"}},'showtooltip':'true','tooltiptext':'Name of the sales account owner'});
        metaFields.push({"name":"RecordType.Name","apiName":"RecordType.Name","label":"Segment",'showtooltip':'true','tooltiptext':'Shows the record type of sales account'});
        metaFields.push({"name":"PrimaryMember","apiName":"PrimaryMember","label":"Main Contact","type":"component","component":{"name":"ui:outputURL","attributes":{"label":"{{Primary_Member__r.Name}}","value":"/{{Primary_Member__r}}","target":"_blank"}},'showtooltip':'true','tooltiptext':'Primary member of the sales account'});
        metaFields.push({"name":"Email","apiName":"Email","label":"Main Contact Email","type":"component","component":{"name":"ui:outputURL","attributes":{"label":"{{Primary_Member__r.Email}}","value":"mailTo:{{Primary_Member__r.Email}}","target":"_blank"}},'showtooltip':'true','tooltiptext':'Primary member email of the sales account'});
        metaFields.push({"name":"CreatedDate","apiName":"CreatedDate","label":"Created Date","type":"date",'showtooltip':'true','tooltiptext':'Shows the created date of sales account'});
        
        
        component.set("v.searchOrgMetaFields", metaFields);
        component.set("v.orgRelatedSalesAccounts", []);
        if(component.get("v.orgAccountId")){
            var strQuery;
            if(component.get("v.accountTypesToShow")){
                strQuery = "SELECT Id, Name,Account_Type__c, RecordTypeId,RecordType.Name ,Primary_Member__r.Email,Primary_Member__r.Name, CreatedDate, Primary_Member__c,   OwnerId, Owner.Name, Website  FROM Account WHERE Parent_Org_Id__c = '"+ component.get("v.orgAccountId").substr(0, 15) +"' AND ("+component.get("v.accountTypesToShow")+") AND Id != '"+component.get("v.orgAccountId").substr(0, 15)+"'";
            }
            else{
                strQuery = "SELECT Id, Name, RecordTypeId, RecordType.Name ,Primary_Member__r.Email, Primary_Member__r.Name, CreatedDate, Primary_Member__c,   OwnerId, Owner.Name, Website  FROM Account WHERE Parent_Org__c = '"+ component.get("v.orgAccountId").substr(0, 15) +"' AND Account_Type__c = 'Sales'";
            } 
            component.find("utils").execute("c.getQueryData",{"query": strQuery}, function(response){
                if(response && response.length > 0){
                    if(component.get("v.accountTypesToShow")){
                        var orgList = [];
                        var salesList = [];
                        response.forEach(function(element) {
                            if(element.Account_Type__c == 'Org'){
                                orgList.push(element);
                            }
                            else{
                                salesList.push(element);
                            }
                        }); 
                        component.set("v.orgRelatedSalesAccounts", orgList.concat(salesList));
                    }else{
                        component.set("v.orgRelatedSalesAccounts", response);
                    }
                    component.set("v.noSalesAccountFound",false);                    
                    component.find("utils").hideProcessing();
                }else{
                    component.set("v.noSalesAccountFound", true);
                    component.set("v.orgRelatedSalesAccounts", []);                    
                    component.find("utils").hideProcessing();
                }
            },function(error){
                component.find("utils").showError(error);
                component.find("utils").hideProcessing();
            });
        }
        component.find("utils").hideProcessing();        
    }
})