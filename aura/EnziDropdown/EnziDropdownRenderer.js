({
    afterRender:function(component){
        this.superAfterRender();
        document.addEventListener("click",function(evt){
            if(component.isValid() && component.getElement() && component.getElement().querySelectorAll('.dropDownTrigger') && component.getElement().querySelectorAll('.dropDownTrigger').length>0 && !component.getElement().querySelectorAll('.dropDownTrigger')[0].contains(evt.target)){
                component.set("v.show",false);
            }
        })
    }
})