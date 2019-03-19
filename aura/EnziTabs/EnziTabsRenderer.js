({
    afterRender:function(component){
        this.superAfterRender();
        var leftSlider = component.getElement().querySelectorAll('.leftSlider')[0];
        var rightSlider = component.getElement().querySelectorAll('.rightSlider')[0];
        var interval;
        leftSlider.addEventListener('click',function(){
            component.getElement().querySelectorAll("ul .slds-tabs--"+component.get("v.type")+"__nav")[0].scrollLeft += -20;
        })
        rightSlider.addEventListener('click',function(){
            component.getElement().querySelectorAll("ul .slds-tabs--"+component.get("v.type")+"__nav")[0].scrollLeft += 20;
        })
        component.set("v.showScroll",true);
    }
})