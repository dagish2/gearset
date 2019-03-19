({
	afterRender:function(component, helper){
        this.superAfterRender();
       	var ele = component.find("multipicklistOptions").getElements()[0];
        document.addEventListener("click",function(evt){
            if(component.getElements().length>0 && !component.getElements()[0].contains(evt.target)){
                component.set("v.showOptions", false);
                component.set("v.searchKeyword", "");
                //component.set("v.filteredOptions",helper.getFilteredOptions(component,""));
            }
        });
    }
})