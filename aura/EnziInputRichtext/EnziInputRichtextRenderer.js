({
	afterRender : function(component, helper) {
        this.superAfterRender();
        var name = component.get('v.name');
        var tmp = document.createElement("DIV");
        tmp.innerHTML = (!$A.util.isUndefined(component.get("v.value"))?component.get("v.value"):'');
        /*$A.util.getElement('text_'+name).innerHTML = tmp.innerHTML;*/
		document.getElementById('text_'+name).innerHTML = tmp.innerHTML;      
        var parsedText = tmp.textContent || tmp.innerText || "";
        component.set("v.displayText",parsedText);
        
	}
})