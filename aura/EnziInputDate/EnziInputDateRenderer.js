({
    afterRender:function(component,event,helper){
        this.superAfterRender();
        document.addEventListener("click",function(evt){
            if(component.getElement() && component.getElement().parentElement && component.getElement().parentElement.parentElement){
                if(!component.getElement().parentElement.parentElement.contains(evt.target)){
                    component.set("v.show",false);
                }
            }
        })
    }
})