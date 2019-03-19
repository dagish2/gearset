({
    doInit : function(component, event, helper) {
        var describedFields = [
            {"name":"term","label":"Term"},
            {"name":"conservative","label":"Conservative"},
            {"name":"agressive","label":"Agressive"},
            {"name":"super_aggresive","label":"Super Agressive"}
        ]; 
        component.set("v.describedFields",describedFields);
        helper.setData(component,function(){
            component.set("v.isDiscount",true);
            component.set("v.isLoading",false);
        },function(){
            component.set("v.isDiscount",false);
            component.set("v.isLoading",false);
        })
    },
    getDiscount:function(component, event, helper){
        if(component.get("v.isDiscount")){
            component.find("discountModal").showModal();
        }
    }
})