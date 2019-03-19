({
	afterRender:function(component, helper){
        this.superAfterRender();
       	var ele = component.find("lookupField").getElements()[0];
        ele.addEventListener("blur",function(evt){
            setTimeout(function(){                
                component.set("v.search", false);
            },500)
        });
        ele.addEventListener("keyup",function(evt){
            switch(evt.keyCode){
                case 38:
					helper.selectUp(component);
                    break;
                case 40:
                    helper.selectDown(component);
                    break;
                case 13:
                    helper.select(component);
                    break;
                default:
                    component.set("v.keyword",evt.target.value);
                    if(evt.target.value && evt.target.value!="" && evt.target.value.length>1){
                        window.setTimeout(
                            $A.getCallback(function() {
                                if (component.isValid()) {                                    
                                    helper.search(component);
                                }}),
                            1000);                                                
                    }
                    break;
            }
        });
    }
})