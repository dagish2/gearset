({
    doInit : function(component, event, helper){
        component.set("v.utils", component.find("utils"));
        component.find("utils").setTitle("Merge Accounts");
        component.find("utils").showProcessing();
        component.find("utils").execute("c.getUserInfo",{},function(response){ 
            component.set("v.currentUserInfo",JSON.parse(response)[0]);
            component.find("utils").execute("c.getQueryData",{"query":"SELECT Id,Data__c FROM Setting__c WHERE Name = 'MergeOrganizationsSetting'"},function(response){           
                if(response && response.length){
                    var result = JSON.parse(response[0].Data__c);
                    var ownershipProfile = [];
                    component.set("v.setting",{"profiles":result.OwnershipProfiles});
                    component.set("v.settingData",JSON.parse(JSON.stringify(result)));
                    component.get("v.utils").hideProcessing();
                    component.find("instructionModel").showModal();    
                    component.set("v.selectedValue","Org Account");
                }
            },function(error){
                component.get("v.utils").hideProcessing();
                component.get("v.utils").showError(error); 
            });
        },function(error){
            component.get("v.utils").hideProcessing();
            component.get("v.utils").showError(error);   
        });
    },
    searchOrgAccounts : function(component, event, helper){
        helper.clearFilters(component,helper); 
        window.setTimeout(
            $A.getCallback(function() {
                if (component.isValid()){                                    
                    component.set("v.records",[]);   
                }}),
            100);  
        if(event.currentTarget.value !="" && event.currentTarget.value.length>2){
            document.getElementById('tableDiv').className = 'slds-hidden';
            component.get("v.utils").showProcessing();
            var keyword = event.currentTarget.value;
            component.set("v.keyword",keyword);   
            var SOSLquery = "FIND '"+ component.get("v.utils").addSlashes(keyword) +"' IN Name FIELDS RETURNING Account(Id,Name,Primary_Member__r.Name,Phone ,Account_Type__c WHERE Account_Type__c='Org') LIMIT 10";
            component.find("utils").execute("c.getListQueryDataBySOSL",{"arrQuery":SOSLquery},function(response){     
                component.set("v.orgAccounts", response[0]);
                var a=document.getElementById("listbox-unique-id");
                component.find("utils").hideProcessing();
                $A.util.removeClass(a, "slds-hide");
            },function(error){
                component.get("v.utils").hideProcessing();
                component.get("v.utils").showError(error);
            })
        }else if(event.currentTarget.value==""){
            document.getElementById('tableDiv').className = 'slds-hidden';
            component.set("v.isQueryDataTable",true);          
            component.set("v.query", "SELECT Id FROM Account WHERE Id = ''");
            component.set("v.stage", "1");
            component.set("v.keyword","");
            component.set("v.selectedO","");
        }
    }, 
    selectEntity : function(component, event, helper){
        component.get("v.utils").showProcessing();  
        document.getElementById('tableDiv').className = 'slds-visible';
        helper.clearFilters(component,helper);
        var orgAccountId = event.currentTarget.id;
        var orgAccounts = component.get("v.orgAccounts");
        component.set("v.selectedOrg", orgAccounts[orgAccounts.findIndex(r=>r.Id==orgAccountId)]);
        component.set("v.keyword", "");
        var arrQueries = [];
        var WhereClauseAccountTeamMember = ' WHERE';
        var WhereClauseAccount = ' WHERE';    
        if(component.get("v.setting.profiles").includes(component.get("v.currentUserInfo").Profile['Name'])){
            WhereClauseAccount += ' Account_Type__c = \'Sales\' AND  Parent_Org__c = \''+ orgAccountId.substr(0, 15)+'\' AND HierarchyLevel__c != null order by lastModifiedDate desc LIMIT 500';
            WhereClauseAccountTeamMember += ' Id IN (SELECT AccountId FROM AccountTeamMember WHERE UserId = \''+$A.get("$SObjectType.CurrentUser.Id")+ '\') AND Account_Type__c = \'Sales\'AND Parent_Org__c = \''+ orgAccountId.substr(0, 15) +'\' order by lastModifiedDate desc LIMIT 500';
        }else{
            WhereClauseAccount += '  OwnerId = \''+$A.get("$SObjectType.CurrentUser.Id")+'\' AND  Parent_Org__c = \''+ orgAccountId.substr(0, 15)+'\' AND Account_Type__c = \'Sales\' order by lastModifiedDate desc  LIMIT 500';
            WhereClauseAccountTeamMember += ' Id IN (SELECT AccountId FROM AccountTeamMember WHERE UserId = \''+$A.get("$SObjectType.CurrentUser.Id")+ '\') AND Account_Type__c = \'Sales\'AND Parent_Org__c = \''+ orgAccountId.substr(0, 15) +'\' order by lastModifiedDate desc LIMIT 500';
        }
        arrQueries.push("SELECT Id, "+ component.get("v.settingData.queryFields") +" FROM Account"+WhereClauseAccount);
        arrQueries.push("SELECT Id, " + component.get("v.settingData.queryFields") +" FROM Account"+WhereClauseAccountTeamMember);        
        component.find("utils").execute("c.getAccountsToDisplay",{"arrQuery":arrQueries},function(response){
            if(response.length > 0 ){
               component.set("v.records",response); 
               component.get("v.utils").hideProcessing();     
            }else{ 
                component.set("v.query", "SELECT Id FROM Account WHERE Id = '' LIMIT 1");
                component.set("v.isQueryDataTable",true);
                component.get("v.utils").hideProcessing();    
                component.get("v.utils").showWarning("You don't own any Sales Account under this Org.");
            }
        },function(error){
            component.get("v.utils").hideProcessing();
            component.get("v.utils").showError(error);    
        },component);
        component.set("v.selectedRecordIds", {
            "masterAccountId": [],
            "selectedAccountIds": []
        });      
        component.set("v.isQueryDataTable",false);              
    },
    selectedValue : function(component,event,helper){
        component.set("v.stage", "1");
        component.set("v.selectedOrg", {"Id":"","Name": ""});
        helper.clearFilters(component,helper);
        if(component.get("v.selectedValue")=='Sales Account' || component.get("v.selectedValue")=='Org Account'){
            component.get("v.utils").showProcessing();
            component.set("v.selectedAccountsToMergeData",[]);
            helper.getAccounts(component, helper);         
        }
        else{
         document.getElementById('tableDiv').className = 'slds-hidden';   
         component.get("v.utils").showWarning('Please select Sales OR Org Type Account');
        }
            
    },
    nextStage : function(component, event, helper){
        if(component.get("v.selectedValue") != 'Sales Account'){
            component.set("v.isCustomSearch", false);
        } 
        helper.nextStage(component, helper);
    },
    prevStage : function(component, event, helper){
        document.getElementById("tableDiv").style["height"] = "";
        document.getElementById("inerTableDiv").style["height"] = "";
        document.getElementById("tableDiv").style["margin-top"] = "0px";
        if(component.get("v.selectedValue")!='Sales Account'){
            component.set("v.isCustomSearch",true);
        }  
        var stage = component.get("v.stage");
        component.set("v.stage","1");
        component.set("v.selectedAccounts","[]");
        helper.getAccounts(component, helper);
    },
    mergeAccounts : function(component, event, helper){
        component.find("utils").showProcessing();
        if( component.get("v.selectedMasterAccount").length > 0){
            if(component.get("v.selectedMasterAccount").length == 1){               
                var masterAccountId = component.get("v.selectedMasterAccount")[0].Id;
                var recIds = [];
                component.get("v.selectedAccountsToMergeData").forEach(function(record){
                    recIds.push(record.Id);
                }
                                                                      );
                component.find("utils").execute("c.validateMergeAccounts",{"masterAccountId": masterAccountId.substr(0, 15), "selectedAccounts": recIds}, function(response){                                   
                    if(response && response["masterRecord"]){                        
                        component.get("v.utils").hideProcessing();
                        helper.mergeAccountRecords(component,helper, response["masterRecord"][0],response["lstMergedAccount"]); 
                    }else{
                        component.get("v.utils").hideProcessing();
                        component.get("v.utils").showError(response["message"]);  
                    }                    
                },function(error){
                    component.get("v.utils").hideProcessing();
                    component.get("v.utils").showError(error);
                } , component);
            }else{
                component.get("v.utils").hideProcessing();
                component.get("v.utils").showError("You can select only one account as a Primary Account.");   
            }
        }else{
            component.get("v.utils").hideProcessing();
            component.get("v.utils").showError("Please select a Primary "+component.get("v.selectedValue")+" to merge.");
        } 
    },
    close:function(component,event,helper){
        component.find("utils").showConfirm("Are you sure you want to close the page ?",function(){
            if(sforce && sforce.console && sforce.console.isInConsole())
                component.get("v.utils").closeTab();
            history.go(-1);
        });
    }, 
    search :function(component,event,helper){     
      
     if(component.get("v.stage") =="1" && component.get("v.selectedValue")!='Sales Account'){  
            var keyword = event.getParam("value");
            component.set("v.isQueryDataTable",false);
            if(keyword !="" && keyword.length>2){
                component.set("v.keyword", keyword);
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
                            WhereClauseAccount  += ' AND '+searchCriteria+' order by lastModifiedDate desc LIMIT 500'; 
                            WhereClauseAccountTeamMember  += ' AND '+searchCriteria+' order by lastModifiedDate desc LIMIT 500';                         
                            
                        }else{
                            WhereClauseAccount  += ' AND Name Like \''+keyword+ '\' order by lastModifiedDate desc LIMIT 500';
                            WhereClauseAccountTeamMember  += ' AND Name Like \''+keyword+ '\' order by lastModifiedDate desc LIMIT 500';
                        } 
                    }else{
                        WhereClauseAccount += ' OwnerId = \''+$A.get("$SObjectType.CurrentUser.Id")+ '\' AND Account_Type__c = \'Org\'';
                        WhereClauseAccountTeamMember += ' Id IN (SELECT AccountId FROM AccountTeamMember WHERE UserId = \''+$A.get("$SObjectType.CurrentUser.Id")+ '\') AND Account_Type__c = \'Org\'';
                        if(component.get("v.attributes.searchFields") && component.get("v.attributes.searchFields").length >0){
                            WhereClauseAccount  += ' AND '+searchCriteria+' order by lastModifiedDate desc LIMIT 500'; 
                            WhereClauseAccountTeamMember  += ' AND '+searchCriteria+' order by lastModifiedDate desc LIMIT 500';
                        }else{
                            WhereClauseAccount  += ' AND Name Like \''+keyword+ '\' order by lastModifiedDate desc LIMIT 500';
                            WhereClauseAccountTeamMember  += ' AND Name Like \''+keyword+ '\' order by lastModifiedDate desc LIMIT 500';
                        }                                                           
                    }
                    queryArr.push("SELECT Id," + component.get("v.attributes.fieldsOrg") + " FROM Account"+WhereClauseAccount);
                    queryArr.push("SELECT Id," + component.get("v.attributes.fieldsOrg") + " FROM Account"+WhereClauseAccountTeamMember);
                    component.find("utils").execute("c.getAccountsToDisplay",{"arrQuery":queryArr},function(response){
                        component.find("utils").hideProcessing();    
                        if(response.length > 0 ){                 
                            component.set("v.records",response);
                        }else{ 
                            component.set("v.isQueryDataTable",true);
                            component.set("v.query", "SELECT Id FROM Account WHERE Id = ''");
                        }
                    },function(error){
                        component.get("v.utils").hideProcessing();
                        component.get("v.utils").showError(error);    
                    },component);
                }
            }else{
                if(keyword ==""){
                    helper.getListQueryData(component,helper,component.get("v.attributes.fieldsOrg"));
                }               
            }
        }
    },
    closeInstructionModel: function(component,event,helper){
	component.find("instructionModel").close();        
    },
    searchOrganizations : function(component,event,helper){
        var curentKey = event.currentTarget.value.trim();
        component.set("v.searchKeyword",curentKey);
        if(component.get("v.searchKeyword").length > 2){
            component.get("v.utils").showProcessing();
            helper.searchOrganizations(component,event,helper);
        }else if(component.get("v.settingData.ifFoundAccouns") && component.get("v.searchKeyword").length == 0){
            component.get("v.utils").showProcessing(); 
            helper.getListQueryData(component,helper,component.get("v.attributes.fieldsOrg"));
        }
    }
})