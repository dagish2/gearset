({
    disassociate : function(component, helper, disassociateBillAccFromOpp){
        if(component.get("v.opportunityRec")){
            component.find("utils").showProcessing();
            component.find("utils").execute("c.isValidForDisAssociationforLightning", {"oppRec" : component.get("v.opportunityRec"), "disassociateBillAccFromOpp" : disassociateBillAccFromOpp}, function(response){
                component.find("utils").hideProcessing();
                if(response && response.isValidForDisAssociation && !JSON.parse(response.isValidForDisAssociation)){
                    component.set("v.message",response.errorMessage);
                    component.set("v.showDisassociation",false);
                }else if(response && response.isValidForDisAssociation && JSON.parse(response.isValidForDisAssociation)){
                    disassociateBillAccFromOpp ? helper.refresh() : component.set("v.message", 'Are you sure you want to Disassociate Billing Account ?');
                }else{
                    component.set("v.message", 'Something went wrong, Please Contact your System Administrator.');
                }
            }, function(error){
                component.find("utils").showError(error);
            },component); 
        }else{
            component.set("v.message", 'Opportunity record is null');
        }
    },
    refresh :  function(){
        if($A.get('e.force:refreshView')){
            $A.get('e.force:refreshView').fire();    
        }
    }
})