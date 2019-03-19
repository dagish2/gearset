({
    doInit : function(component, event, helper) {
        helper.setLayout(component, event, helper);
    },
    saveRecord : function(component, event, helper) {
        var params = event.getParam('arguments');
        helper.saveRecord(component,params.success,params.error); 
    },
    deleteRecord : function(component, event, helper) {
        var params = event.getParam('arguments');
        helper.deleteRecord(component,params.success,params.error); 
    },
    reloadRecord : function(component, event, helper) {
        component.set("v.mode","");
        setTimeout(function(){
            component.set("v.mode","VIEW");
        },50);
    },
    navigateToRecord:function(component, event, helper){
        component.find('utils').redirectToUrl('/' + event.getParam('recordId'),'',true);
    },
    doneRendering:function(component, event, helper){
        if(component.get("v.mode") == 'VIEW' && component.get("v.record") && document.getElementsByClassName('uiOutputPhone') && document.getElementsByClassName('uiOutputPhone').length > 0){
            var listSpan = document.getElementsByClassName('uiOutputPhone');
            for(var index = 0;index < listSpan.length;++index){
                var parentNode = listSpan[index].parentElement;
                if(parentNode){
                    parentNode.innerHTML = '<a href='+helper.getPhoneHref(listSpan[index].innerHTML,component.get("v.record").Id,component.get("v.sObjectName"),component.get("v.record").Name)+' id="weFormPhoneOutput">'+listSpan[index].innerHTML+'</a>';
                }
            }
        }
    }
})