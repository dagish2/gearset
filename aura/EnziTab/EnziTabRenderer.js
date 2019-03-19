({
    afterRender:function(component,helper){
        this.superAfterRender();
        helper.notifyParent(component);
    }
})