({
	getOpportunityDetails : function(component) {
		component.set("v.opportunityRec", new Map());
        component.find("utils").execute("c.getQueryData", {"query": "SELECT Id, Name, Lost_Reason__c, StageName, Competitor_Solution__c, Competitor_Solution_Detail__c FROM Opportunity WHERE Id= '" + component.get("v.recordId") + "'"}, function(result){
            var opportunityRec = result[0];
            component.set("v.opportunityStage", opportunityRec.StageName);
            if(opportunityRec.StageName != "Closed Won" || opportunityRec.StageName != "Closed Lost"){
                component.set("v.hideUpdateButton", true);
            }
            opportunityRec["StageName"] = null;
            component.set("v.opportunityRec", opportunityRec);
            component.find("utils").hideProcessing();            
        },function(error){
            component.find("utils").hideProcessing();            
            component.find("utils").showError(error);
        });
	},
    refresh :  function(){
        if($A.get('e.force:refreshView')){
            $A.get('e.force:refreshView').fire();    
        }
    }
})