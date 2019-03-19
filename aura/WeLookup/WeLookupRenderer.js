({
	afterRender: function (component, helper) {
        this.superAfterRender();
        helper.validate(component);
    }
})