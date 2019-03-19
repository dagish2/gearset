({
    afterRender: function (component, helper) {
        this.superAfterRender();
        var ele = document.getElementById("searchInput");
        if(ele){
            ele.addEventListener("focus",function(evt){
                var a = document.getElementById("listbox-unique-id");        
                $A.util.removeClass(a, "slds-hide");
            })
            ele.addEventListener("blur",function(evt){
                setTimeout(function(){
                    var a = document.getElementById("listbox-unique-id");        
                    $A.util.addClass(a, "slds-hide");
                },500)
            })
        }
    }
})