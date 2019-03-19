({
    doInit : function(component, event, helper) {
        var accountId = component.get("v.recordId");
        component.find("utils").setTitle("Account Type Conversion");
        component.find("utils").showProcessing();
        component.find("utils").execute("c.getQueryData", {"query": "SELECT Id, Name, OwnerId, Nickname__c, Account_Type__c, Parent.Account_Type__c, Primary_Member__c, Parent_Org_Id__c, Parent_Org__c FROM Account WHERE Id = '" + accountId + "'"}, function(response){
            var objAccount = response[0];
            component.set("v.pageName",  objAccount.Name);
            component.set("v.isParentAccount", objAccount.ParentId == null);
            if(objAccount.Account_Type__c == null || objAccount.Account_Type__c == 'Bill'){
                component.set("v.isAllowedToConverion", false);
                helper.showError(component, "Account Type can be changed only for Org/Sales Accounts");
            }
            //Commented by Krishana Date : 19-09-2018 : Allow user to change ultimate org to Sales.
            /*else if(objAccount.ParentId == null){                
                //component.set("v.isAllowedToConverion", false);
                //helper.showError(component, "You cannot change Account Type for Ultimate Organization");
            }*/
            if(objAccount.Account_Type__c != null && objAccount.Account_Type__c.toLowerCase() == "sales"){
                objAccount.Name = "";
            }
            if(objAccount.ParentId != null && objAccount.Parent.Account_Type__c != null && objAccount.Parent.Account_Type__c.toLowerCase() == 'sales' && objAccount.Parent_Org__c != null){
                objAccount.ParentId = objAccount.Parent_Org__c;
            }            
            component.set("v.account", objAccount);            
            component.find("utils").hideProcessing();
        }, function(error) {
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        });
    },
    convertAccountType : function(component, event, helper) {
        component.find("utils").showProcessing();
        var objAccount = component.get("v.account");
        if(objAccount.Account_Type__c == 'Org'){            
            var query = "SELECT Id, Name FROM Account WHERE Id= '" + objAccount.ParentId + "'";
            component.find("utils").execute("c.getQueryData", {"query": query}, function(response){
                component.find("utils").hideProcessing();
                if(response && response.length){
                    component.find("utils").showConfirm("<p style='font-size:14px;text-align: justify;'>You will be converting an Org account to a Sales account under the <b>"+response[0].Name+"</b> Org account. Are you sure that you want to continue?</b>", function(){ 
                        helper.convertAccountType(component, helper, {"Id": objAccount.Id, "Account_Type__c": "Sales", "ParentId": objAccount.ParentId, "OwnerId": objAccount.OwnerId, "Nickname__c": objAccount.Nickname__c});
                    });                    
                }
            },function(error){
                component.find("utils").hideProcessing();
                component.find("utils").showError(error);
            });
        }else if(objAccount.Account_Type__c == 'Sales'){
            component.find("utils").hideProcessing();
            component.find("utils").showConfirm("Are you sure you want to convert Sales Type Account to a Org Type Account ?", function(){                 
                helper.convertAccountType(component, helper, {"Id": objAccount.Id, "Name": objAccount.Name, "Account_Type__c": "Org", "ParentId": objAccount.ParentId, "OwnerId": objAccount.OwnerId});
            });            
        }
    },
    close : function(component, event, helper) {
        component.find("utils").showConfirm("Are you sure you want to cancel?", function(){ 
            helper.close(component, helper);
        });
    },    
})