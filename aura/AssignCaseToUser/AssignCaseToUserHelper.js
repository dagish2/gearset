({
    showSelectUserModal: function (component, event, helper) {
        component.find("SelectUserModal").showModal();
    },
    closeSelectUserModal: function (component, event, helper) {
        component.find("SelectUserModal").close();
    },
    showMessage : function(component, type, message) {
        component.get("v.utility").hideProcessing();
        switch(type) {
            case "success":
                component.find("utils").showSuccess(message);
                break;
            case "error":
                component.get("v.utility").showError(message);
                break;
            default:
        }
    },
    refresh : function(component, event, helper) {
        component.set("v.relatedUsers", []);
        component.set("v.selectedUserId", null);
        $A.get("e.force:refreshView").fire();
    } 
})