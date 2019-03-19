({
    doInit : function(component, event, helper) {

    },
	makeContenteditable : function(component, event, helper) {
        var name = 'text_' + component.get("v.name");
        document.getElementById(name).setAttribute("contenteditable", "true");
		helper.appliedStyle(component,helper);
	},
    doBold : function(component, event, helper) {
    	document.execCommand('bold', true,'');
        helper.appliedStyle(component,helper);
        var name = component.get('v.name');
        component.set("v.value",document.getElementById('text_'+name).innerHTML);
    },
    doItalic : function(component, event, helper) {
    	document.execCommand('italic', true,'');
        helper.appliedStyle(component,helper);
        var name = component.get('v.name');
        component.set("v.value",document.getElementById('text_'+name).innerHTML);
    },
    doUnderline : function(component, event, helper) {
    	document.execCommand('underline', true,'');
        helper.appliedStyle(component,helper);
        var name = component.get('v.name');
        component.set("v.value",document.getElementById('text_'+name).innerHTML);
    },
    doUnorderedList : function(component, event, helper) {
    	document.execCommand('insertUnorderedList', true,'');
        helper.appliedStyle(component,helper);
        var name = component.get('v.name');
        component.set("v.value",document.getElementById('text_'+name).innerHTML);
    },
    doOrderedList : function(component, event, helper) {
    	document.execCommand('insertOrderedList', true,'');
        helper.appliedStyle(component,helper);
        var name = component.get('v.name');
        component.set("v.value",document.getElementById('text_'+name).innerHTML);
    },
    doIndent : function(component, event, helper) {
    	document.execCommand('indent', true,'');
        helper.appliedStyle(component,helper);
        var name = component.get('v.name');
        component.set("v.value",document.getElementById('text_'+name).innerHTML);
    },
    doOutdent : function(component, event, helper) {
    	document.execCommand('outdent', true,'');
        helper.appliedStyle(component,helper);
        var name = component.get('v.name');
        component.set("v.value",document.getElementById('text_'+name).innerHTML);
    },
    doLeftAlign : function(component, event, helper) {
    	document.execCommand('justifyLeft', true,'');
        helper.appliedStyle(component,helper);
        var name = component.get('v.name');
        component.set("v.value",document.getElementById('text_'+name).innerHTML);
    },
    doCenterAlign : function(component, event, helper) {
    	document.execCommand('justifyCenter', true,'');
        helper.appliedStyle(component,helper);
        var name = component.get('v.name');
        component.set("v.value",document.getElementById('text_'+name).innerHTML);
    },
    doRightAlign : function(component, event, helper) {
    	document.execCommand('justifyRight', true,'');
        helper.appliedStyle(component,helper);
        var name = component.get('v.name');
        component.set("v.value",document.getElementById('text_'+name).innerHTML);
    },
    doAddLink : function(component, event, helper) {
       	var cmd = prompt('Value for Add Link ?', 'http://');
        document.execCommand('createLink', false, cmd || '');
        var name = component.get('v.name');
        component.set("v.value",document.getElementById('text_'+name).innerHTML);
    },
    doAddImage : function(component, event, helper) {
       	var cmd = prompt('Value for Add Image ?', 'http://');
        document.execCommand('insertImage', false, cmd || '');
        var name = component.get('v.name');
        component.set("v.value",document.getElementById('text_'+name).innerHTML);
    },
    getFieldSelector : function(component, event, helper) {
        $A.createComponent(
            "c:EnziFieldSelector",
            {
                "sObjectName": component.get("v.sObjectName"),
                "util":component
            },
            function(cmp, status, errorMessage){
                if (status === "SUCCESS") {
                    var body = component.get("v.body");
                    body.push(cmp);
                    component.set("v.body", body);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                }
                else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            }
        );
	},
    change : function(component, event, helper) {
        component.set("v.value",event.target.innerHTML);
        var tmp = document.createElement("DIV");
        tmp.innerHTML = event.target.innerHTML;
        var parsedText = tmp.textContent || tmp.innerText || "";
        component.set("v.displayText",parsedText);
	},
    onFieldSelect:function(component, event, helper){
        var fieldName = '{!' + event.getParam('field') + '}';
        var input = document.createElement('textarea');
        document.body.appendChild(input);
        input.value = fieldName;
        input.focus();
        input.select();
        document.execCommand('Copy');
        input.remove();
        component.find("toaster").showSuccess('Merge field copied..! You can paste it in email body.');
    }
})