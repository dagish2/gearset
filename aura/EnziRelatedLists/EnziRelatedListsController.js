({
	doInit : function(component, event, helper) {
		//component.find("utils").showProcessing();
        component.find("utils").execute("c.getLayout",{"recordId":component.get("v.recordId")},function(response){
            var data = JSON.parse(response);
            var layout;
            if(data.lstRecordTypes.length>0)
                layout = JSON.parse(data.layout);
            else
                layout = JSON.parse(data.layout).layouts[0];
            var relatedListsToExclude = component.get("v.exclude");
            var relatedLists = [];
            for(var list in layout.relatedLists){
                for(var btn in layout.relatedLists[list].buttons){
                    if(relatedLists.indexOf(layout.relatedLists[list])==-1 && relatedListsToExclude.indexOf(layout.relatedLists[list].name)==-1){
                        relatedLists.push(layout.relatedLists[list]);
                    }
                }
            }
            layout.relatedLists = relatedLists;
            component.set("v.layout",layout);
            //component.find("utils").hideProcessing();
        })
	}
})