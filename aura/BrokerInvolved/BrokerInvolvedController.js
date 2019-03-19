({
    doInit : function(component, event, helper){
        helper.execute(component, "c.updateBrokerInvolved",{"opportunityId":component.get("v.recordId")},
                       function(result){
                           if(result===true){
                               $A.createComponent(
                                   "ui:message",{
                                       "title": "Opportunity updated successfully.",
                                       "severity": "warning"
                                   },
                                   function(components,status){
                                       var div1 = component.find("div1");
                                       div1.set("v.body", components);
                                   }
                               );  
                           }
                           helper.refresh(component, event); 
                       },
                       function(error){
                           "ui:message",{
                               "title":result.errorMsg,
                               "severity": "warning"
                           }
                       });
    }
})