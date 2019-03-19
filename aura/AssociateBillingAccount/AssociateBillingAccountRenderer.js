({
    afterRender: function (component, helper) {
        this.superAfterRender();
        var searchInput = document.getElementById("searchInput");
        if(searchInput){
            searchInput.addEventListener("focus",function(evt){
                var division = document.getElementById("listbox-unique-id");        
                $A.util.removeClass(division, "slds-hide");
            })
            searchInput.addEventListener("blur",function(evt){
                setTimeout(function(){
                    var division = document.getElementById("listbox-unique-id");        
                    $A.util.addClass(division, "slds-hide");
                },500)
            })
        }
    }
})