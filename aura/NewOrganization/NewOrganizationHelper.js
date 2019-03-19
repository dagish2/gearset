({
    changeHeaderAndInstructions : function( component, header){
        var mapInstructions = component.get("v.mapInstructions");
        component.set("v.header",header);
        if(mapInstructions[header.charAt(0).toLowerCase()+header.trim().replace(/ /g,"").substring(1)] != undefined && mapInstructions[header.charAt(0).toLowerCase()+header.trim().replace(/ /g,"").substring(1)].length > 0){
            component.set("v.instructions",mapInstructions[header.charAt(0).toLowerCase()+header.trim().replace(/ /g,"").substring(1)]);
            this.removeHideClass( component, "accountinstructions");
        }else{
            this.addHideClass( component, "accountinstructions");
        }
    },
    removeHideClass : function( component, componentName){
        var remove=document.getElementById(componentName);        
        $A.util.removeClass(remove, "slds-hide");
    },
    addHideClass : function( component, componentName){
        var add=document.getElementById(componentName);        
        $A.util.addClass(add, "slds-hide");
    }
})