({
    getMarket : function(component, helper){
        component.get("v.utils").execute("c.getMarketForLightning", {"recordId": component.get("v.recordId")}, function(response){
            var mapResult = response;
            if(mapResult.isValid){
                component.set("v.mapResult", mapResult);
                helper.showModal(component, helper, true, 'The ‘HQ Market’ field corresponds to the WeWork market closest to the company’s HQ. Unomy address information will be used as the company’s HQ location, if present, otherwise, the HQ Address fields on the Account layout will be used. If neither are present, then the HQ Address fields on the Account layout must be populated.<br/><br/>Are you sure you want to populate the HQ Market as '+(mapResult.marketName ? ' "' + mapResult.marketName + '" ' : ' ')+' ?');
                component.set("v.showUpdateBtn", true);
            }else if(mapResult.errorMessage){
                helper.showModal(component, helper, true, (mapResult.errorMessage ? mapResult.errorMessage : "Something went wrong Contact your System Administrator."));
                component.set("v.showUpdateBtn", false);
            }
        },function(error){
            helper.showModal(component, helper, true, (error ? error : "The ‘HQ Market’ field corresponds to the WeWork market closest to the company’s HQ. Unomy address information will be used as the company’s HQ location, if present, otherwise, the HQ Address fields on the Account layout will be used. If neither are present, then the HQ Address fields on the Account layout must be populated."));
            component.set("v.showUpdateBtn", false);
        }, component);
    },
    updateMarket : function(component, helper) {
        component.get("v.utils").execute("c.updateMarketForLightning", {"recordId": component.get("v.recordId"), "mapResult": component.get("v.mapResult")}, function(response){
            var mapResult = response;
            if(mapResult.isValid){
                helper.refresh();
            }
        },function(error){
            helper.showModal(component, helper, true, (error ? error : "We can not find the Market, please update the Billing Address."));
            component.set("v.showUpdateBtn", false);
        }, component);
    },
    showModal : function(component, helper, show, message){
        show ? helper.removeHideClass('errorMessage') : helper.addHideClass('errorMessage');
        component.set("v.message", message);
    },
    removeHideClass : function(componentName){
        var remove=document.getElementById(componentName);        
        $A.util.removeClass(remove, "slds-hide");
    },
    addHideClass : function(componentName){
        var add=document.getElementById(componentName);        
        $A.util.addClass(add, "slds-hide");
    },
    refresh :  function(){
        if($A.get('e.force:refreshView')){
            $A.get('e.force:refreshView').fire();    
        }
    }
})