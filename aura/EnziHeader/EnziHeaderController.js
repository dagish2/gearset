({
	doInit : function(component, event, helper) {
		//component.find("utils").showProcessing();
        component.find("utils").execute("c.getUserInfo",{},function(response){
            component.find("utils").hideProcessing();
            var user = JSON.parse(response)[0];
            component.set("v.userInfo",user);
        },function(error){
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        })
	},
    getUserCard:function(component){
        $A.util.toggleClass(document.getElementById('usercard'),'slds-is-open');
    }
})