({
    afterRender: function (component, helper) {
        this.superAfterRender();
        var isTrue;
        var containerId = component.get("v.containerId");
        if(containerId){
            var ele = document.getElementById(containerId);
            if(ele){
                ele.addEventListener("click",function(event){
                    isTrue = false;
                });
            }   
        }
        document.addEventListener('click',function(event){
            if(isTrue && !component.get("v.showData")){
                component.set("v.show", !isTrue);
                component.set("v.icon","utility:chevronright");
            }
            component.set("v.showData", false);
            isTrue = true;
        });
    }
})