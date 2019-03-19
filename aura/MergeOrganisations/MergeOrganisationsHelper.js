({
    getAccounts : function(component, helper){
        component.find("utils").showProcessing();
        if(component.get("v.selectedValue")=='Sales Account' && component.get("v.selectedOrg") && component.get("v.selectedOrg")["Id"] != ""){
            var orgAccountId = component.get("v.selectedOrg")["Id"];
            component.set("v.isQueryDataTable",false);
            component.set("v.selectedAccountsToMergeData",[]);
            component.find("utils").hideProcessing();
        }else if(component.get("v.selectedValue")!='Sales Account'){   
            document.getElementById('tableDiv').className = 'slds-visible';
            helper.getListQueryData(component,helper,component.get("v.attributes.fieldsOrg"));
            component.set("v.selectedAccountsToMergeData",[]);
        }else{
            document.getElementById('tableDiv').className = 'slds-hidden';
            component.find("utils").hideProcessing();
            component.set("v.attributes.keyword","");            
            component.set("v.isQueryDataTable",true);
            component.set("v.query", "SELECT Id FROM Account WHERE Id = ''");
        }
    },
    nextStage : function(component, helper){
        component.find("utils").showProcessing();
        var stage = component.get("v.stage");
        switch(component.get("v.stage")){
            case '1':
                if(component.get("v.selectedAccounts").length > 3){
                    component.find("utils").hideProcessing();
                    component.find("utils").showError("Only three records can be merged at a single time");        
                } else if(component.get("v.selectedAccounts").length > 1){
                    var listRec= [];
                    var listRecIds= []; 
                    listRec = component.get("v.selectedAccounts");
                    listRec.forEach(function(record){
                        listRecIds.push(record.Id);
                    }); 
                    component.set("v.stage", "2");
                    if(component.get("v.selectedValue") == 'Sales Account'){
                        document.getElementById("tableDiv").style["margin-top"] = "-36px";
                        component.set("v.query", "SELECT Id, " + component.get("v.settingData.queryFields") +" FROM Account WHERE Id IN ('" + listRecIds.join("', '") + "')");    
                    }else{
                        document.getElementById("tableDiv").style["margin-top"] = "-38px";
                        component.set("v.query", "SELECT Id, " + component.get("v.settingData.queryFields") +" FROM Account WHERE Id IN ('" + listRecIds.join("', '") + "')");
                    }
                    
                    component.find("utils").execute("c.getQueryData",{"query":component.get("v.query")},function(response){
                        if(response){
                            
                            component.set("v.isQueryDataTable",true)
                            component.set("v.selectedAccountsToMergeData", response);
                            component.find("utils").hideProcessing(); 
                        }else{
                            component.find("utils").hideProcessing();
                            component.find("utils").showError('Someting went wrong please contact your system admin.');    
                        }
                    },function(error){
                        component.find("utils").hideProcessing();
                        component.find("utils").showError(error);    
                    });   
                }else{
                    component.find("utils").hideProcessing();
                    component.find("utils").showError("Select atleast two Accounts to merge.");
                }
                break;
            case '2':                
                helper.getAccounts(component, helper);                
                break;
            default: 
                component.set("v.stage", "1");
        }  
    },   
    getListQueryData : function(component, helper,queryFields){        
        var currentUserInfo = component.get("v.currentUserInfo");            
        if(currentUserInfo){
                var queryArr = [];           
                var settingProfiles = component.get("v.setting.profiles");
                var WhereClauseAccountTeamMember = ' WHERE';
                var WhereClauseAccount = ' WHERE';
                if(settingProfiles.includes(currentUserInfo.Profile['Name'])){
                    WhereClauseAccount += ' Account_Type__c = \'Org\' order by lastModifiedDate desc LIMIT 500';
                    WhereClauseAccountTeamMember += ' Id IN (SELECT AccountId FROM AccountTeamMember WHERE UserId = \''+$A.get("$SObjectType.CurrentUser.Id")+ '\') AND Account_Type__c = \'Org\' order by lastModifiedDate desc LIMIT 500';
                }else{
                    WhereClauseAccount += ' OwnerId = \''+$A.get("$SObjectType.CurrentUser.Id")+ '\' AND Account_Type__c = \'Org\' order by lastModifiedDate desc LIMIT 500';
                    WhereClauseAccountTeamMember += ' Id IN (SELECT AccountId FROM AccountTeamMember WHERE UserId = \''+$A.get("$SObjectType.CurrentUser.Id")+ '\') AND Account_Type__c = \'Org\' order by lastModifiedDate desc LIMIT 500';
                }
                queryArr.push("SELECT " + component.get("v.settingData.queryFields") + " FROM Account"+WhereClauseAccount);
                queryArr.push("SELECT " + component.get("v.settingData.queryFields") + " FROM Account"+WhereClauseAccountTeamMember);
                component.find("utils").execute("c.getAccountsToDisplay",{"arrQuery":queryArr},function(response){
                    component.find("utils").hideProcessing();    
                    if(response.length > 0){  
                        component.set("v.isQueryDataTable",false); 
                        component.set("v.records",response);
                    }else{
                        component.find("utils").hideProcessing();
                        component.find("utils").showWarning("No Records Found.");
                    }
                },function(error){
                    component.find("utils").hideProcessing();
                    component.find("utils").showError(error);    
                },component);
        }        
    },    
    clearFilters:function(component,helper){
        component.set("v.attributes.currentPage",1);
        component.set("v.attributes.keyword","");
    },
    removeDuplicateAccounts : function(response){
        for(var d in response[1]){
            if(response[0].findIndex(r => r.Id==response[1][d].Id)<0){
                response[0].push(response[1][d]);
            }
        }
        return response[0];
    },
    mergeAccountRecords : function(component,helper,masterRecord,lstMergedAccount){
        component.find("utils").showConfirm("You are about to merge all the Secondary Account(s) into Primary Account, these changes can not be undone.Are you sure you want to continue?",function(){                             
            component.find("utils").showProcessing();
            component.find("utils").execute("c.mergeAccountsToMaster",{"masterRecord": masterRecord, "lstMergedAccount": lstMergedAccount},function(mergeResult){
                var mergeResult = JSON.parse(mergeResult);
                if(mergeResult && mergeResult.isSuccess){
                    component.find("utils").hideProcessing();
                    component.find("utils").showSuccess(mergeResult.message); 
                    window.setTimeout(
                        $A.getCallback(function() {
                            if (component.isValid()) {
                                if(sforce && sforce.console && sforce.console.isInConsole()){
                                     component.get("v.utils").closeTab();
                                    history.go(-1);
                                    sforce.console.openPrimaryTab(null, "/"+masterRecord.Id, true, "");
                                }else{
                                    component.find("utils").redirectToUrl("/"+masterRecord.Id,'',false);     
                                }
                            }}),
                        2000);
                }else{
                    component.find("utils").hideProcessing();
                    component.find("utils").showError(mergeResult["message"]);  
                }         
            },function(error){
                component.find("utils").hideProcessing();
                component.find("utils").showError(error);
            }, component); 
        }); 
    },
    searchOrganizations :function(component,event,helper){     
     if(component.get("v.stage") =="1" && component.get("v.selectedValue")!='Sales Account'){  
            var keyword = component.get("v.searchKeyword").toLowerCase();
            component.set("v.isQueryDataTable",false);
            if(keyword !="" && keyword.length>2){ 
                component.set("v.settingData.ifFoundAccouns",true);
                component.set("v.keyword",keyword);
                keyword = component.find("utils").addSlashes(keyword);
                var currentUserInfo = component.get("v.currentUserInfo");            
                if(currentUserInfo){
                    var queryArr = [];           
                    var settingProfiles = component.get("v.setting.profiles");     
                    var searchCriteria = '';
                    if(component.get("v.attributes.searchFields")){
                        for(var field in component.get("v.attributes.searchFields")){
                            searchCriteria+= component.get("v.attributes.searchFields")[field] +' LIKE \'%'+keyword+ '%\'';
                        }
                    }
                    var WhereClauseAccountTeamMember = ' WHERE';
                    var WhereClauseAccount = ' WHERE';
                    if(settingProfiles.includes(currentUserInfo.Profile['Name'])){
                        WhereClauseAccount += ' Account_Type__c = \'Org\'';
                        WhereClauseAccountTeamMember += ' Id IN (SELECT AccountId FROM AccountTeamMember WHERE UserId = \''+$A.get("$SObjectType.CurrentUser.Id")+ '\') AND Account_Type__c = \'Org\'';
                        if(component.get("v.attributes.searchFields") && component.get("v.attributes.searchFields").length >0){
                            WhereClauseAccount  += ' AND '+searchCriteria+' order by lastModifiedDate desc LIMIT 50'; 
                            WhereClauseAccountTeamMember  += ' AND '+searchCriteria+' order by lastModifiedDate desc LIMIT 50';                         
                            
                        }else{
                            WhereClauseAccount  += ' AND Name Like \'%'+keyword+ '%\' order by lastModifiedDate desc LIMIT 50';
                            WhereClauseAccountTeamMember  += ' AND Name Like \'%'+keyword+ '%\' order by lastModifiedDate desc LIMIT 50';
                        } 
                    }else{
                        WhereClauseAccount += ' OwnerId = \''+$A.get("$SObjectType.CurrentUser.Id")+ '\' AND Account_Type__c = \'Org\'';
                        WhereClauseAccountTeamMember += ' Id IN (SELECT AccountId FROM AccountTeamMember WHERE UserId = \''+$A.get("$SObjectType.CurrentUser.Id")+ '\') AND Account_Type__c = \'Org\'';
                        if(component.get("v.attributes.searchFields") && component.get("v.attributes.searchFields").length >0){
                            WhereClauseAccount  += ' AND '+searchCriteria+' order by lastModifiedDate desc LIMIT 50'; 
                            WhereClauseAccountTeamMember  += ' AND '+searchCriteria+' order by lastModifiedDate desc LIMIT 50';
                        }else{
                            WhereClauseAccount  += ' AND Name Like \'%'+keyword+ '%\' order by lastModifiedDate desc LIMIT 50';
                            WhereClauseAccountTeamMember  += ' AND Name Like \'%'+keyword+ '%\' order by lastModifiedDate desc LIMIT 50';
                        }                                                           
                    }
                     var settingData = component.get("v.settingData");
                    queryArr.push("SELECT Id," + settingData.queryFields + " FROM Account"+WhereClauseAccount);
                    queryArr.push("SELECT Id," + settingData.queryFields + " FROM Account"+WhereClauseAccountTeamMember);
                    component.find("utils").execute("c.getAccountsToDisplay",{"arrQuery":queryArr},function(response){
                        component.find("utils").hideProcessing();    
                        if(response.length > 0 ){
                            component.set("v.records",response);
                        }else{
                            component.get("v.utils").hideProcessing();
                            component.find("utils").showWarning("No Records Found."); 
                        }
                    },function(error){
                        component.get("v.utils").hideProcessing();
                        component.get("v.utils").showError(error);    
                    },component);
                }
            }
        }
    }
})