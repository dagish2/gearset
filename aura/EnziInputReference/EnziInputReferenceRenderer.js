({
	afterRender:function(component, helper){
        this.superAfterRender();
       	var ele = component.find("lookupField").getElements()[0];
        ele.addEventListener("blur",function(evt){
            setTimeout(function(){
                /*var mapResult = {};
                var lst = component.get("v.searchResult");
                for(var i=0; i<lst.length; i++){
                    mapResult[lst[i].label] = lst[i];
                }
                component.set("v.searchResultMap", mapResult);
                var keyword = component.get("v.keyword");
                (mapResult[keyword] != undefined) ? component.set("v.keyword",mapResult[keyword].label) : component.set("v.keyword",'');
                (mapResult[keyword] != undefined) ? component.set("v.value",mapResult[keyword].value) : component.set("v.value",'');*/
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
                                    helper.search(component,evt.target.value);
                                }}),
                            1000);                                                
                    }
                    break;
            }
        });
    }
})