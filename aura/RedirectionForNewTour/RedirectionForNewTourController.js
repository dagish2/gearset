({
    doInit : function(component, event, helper) {     
        var query = "Select Id,Data__c FROM Setting__c WHERE Name='NewTourButtonErrorMessage'";
        component.find("utils").showProcessing();
        component.find("utils").execute("c.getQueryData",{"query":query},function(response){
            if(response.length > 0){
                var elemHead = document.getElementById('modal-heading-01');
                elemHead.innerHTML = JSON.parse(response[0].Data__c).message.title;
                var elemError = document.getElementById('display_error');
                elemError.innerHTML = JSON.parse(response[0].Data__c).message.html;
                component.find("utils").hideProcessing();
            }else{
                component.find("utils").showError('Settings not found.');
                component.find("utils").hideProcessing();
            }
            
        },function(error){
            component.find("utils").showError(error);
            component.find("utils").hideProcessing();
        })
    },
    getJourneyPrefix : function(component, event, helper) {
        component.find("utils").execute("c.getsObjectPrefix",{"objName":"Journey__c"},function(preFix){
            if($A.get("e.force:navigateToURL") != undefined){
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": "/"+preFix+"/o",
                    "isredirect": true
                });
                urlEvent.fire();
            }else{
                window.location.href = location.origin +'/'+preFix+'/o';
            }
            
        },function(error){
            
        })
    },
    close : function(component, event, helper){
        component.find("utils").execute("c.getsObjectPrefix",{"objName":"Tour_Outcome__c"},function(preFix){
            if($A.get("e.force:navigateToURL") != undefined){
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": "/"+preFix+"/o",
                    "isredirect": true
                });
                urlEvent.fire();
            }else{
                window.location.href = location.origin +'/'+preFix+'/o';
            }
        },function(error){
            
        })
    }
})