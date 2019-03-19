({
	doInit : function(component, event, helper) {
        if(location.hash.split("?").length>1){
            var arrParams = location.hash.split("?")[1].split("&");
            var entRecordType;
            arrParams.forEach(function(param){
                if(param.split("=")[0]=="recordTypeId"){
                    entRecordType = param.split("=")[1];
                }
            })
            if(entRecordType=="012F0000001cmY1"){
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": "/apex/CreateOpportunity"
                });
                urlEvent.fire();
            }else{
                var createOppEvent = $A.get("e.force:createRecord");
                createOppEvent.setParams({
                    "entityApiName": "Opportunity",
                    "recordTypeId": entRecordType
                });
                createOppEvent.fire();
            }
        }else{
            var createOppEvent = $A.get("e.force:createRecord");
            createOppEvent.setParams({
                "entityApiName": "Opportunity"
            });
            createOppEvent.fire();
        }       
    }
})