({
    doInit : function(component, event, helper) {        
        component.find("utils").setTitle("Redirect To Unomy");
        component.find("utils").showProcessing();
        component.find("utils").execute("c.getQueryData", {"query": "SELECT Id, Unomy_Company_Website__c FROM " + component.get("v.sObjectName") + " WHERE Id = '" + component.get("v.recordId") + "'"}, function(records){
            if(records && records.length){
                component.find("utils").execute("c.getQueryData", {"query": "SELECT Id, Data__c FROM Setting__c WHERE Name = 'RedirectToUnomy'"}, function(response){
                    var setting = JSON.parse(response[0].Data__c);
                    component.find("utils").hideProcessing();
                    if(records[0].Unomy_Company_Website__c){
                        helper.toastMessage(component, setting.RedirectMessage, "info");
                        setTimeout(function(){
                            if($A.get("e.force:closeQuickAction") != undefined && $A.get("e.force:closeQuickAction").getSource() && $A.get("e.force:closeQuickAction").getSource().isValid()){
                                window.open(setting.URL + '/'+ records[0].Unomy_Company_Website__c+'/', "_blank");
                                $A.get("e.force:closeQuickAction").fire();
                            }else {
                                window.open(setting.URL + '/'+ records[0].Unomy_Company_Website__c+'/', "_self");
                            } 
                        },1500);
                    }else{
                        helper.toastMessage(component, setting.ErrorMessage, "warning");                        
                    }
                },function(error){
                    component.find("utils").hideProcessing();
                    component.find("utils").showError(error); 
                });
            }
        },function(error){
            component.find("utils").hideProcessing();
            component.find("utils").showError(error); 
        });
                
    },
    close : function(component, event, helper){
        component.find("utils").closeTab();
    }    
})