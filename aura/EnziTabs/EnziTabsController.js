({
    getTab:function(component, event, helper){
        var id = event.currentTarget.id.split("$!!$")[0];
        for(var tab in component.get("v.tabHeaders")){
            $A.util.removeClass(document.getElementById(component.get("v.tabHeaders")[tab].id+"$!!$container"),'slds-show');
            $A.util.addClass(document.getElementById(component.get("v.tabHeaders")[tab].id+"$!!$container"),'slds-hide');
            $A.util.removeClass(document.getElementById(component.get("v.tabHeaders ")[tab].id+"$!!$header"),'slds-active');
        }
        $A.util.removeClass(document.getElementById(id+"$!!$container"),'slds-hide');
        $A.util.addClass(document.getElementById(id+"$!!$container"),'slds-show');
        $A.util.addClass(document.getElementById(id+"$!!$header"),'slds-active');
        component.set("v.activeTab",id);
    },
    rerenderTabs:function(component, event, helper){
        debugger;
        var tab =  event.getParam('tab');
        var ele = document.getElementById(tab.id+"$!!$container").parentElement;
        if(component.getElement().innerHTML===ele.innerHTML){
            var oldTab = -1;
            var tabsToDelete=[];
            for(var t in component.get("v.tabHeaders")){
                if(component.get("v.tabHeaders")[t].id==tab.id){
                    oldTab = parseInt(t);
                }
            }
            var tabHeaders = component.get("v.tabHeaders");
            if(oldTab == -1){
                tabHeaders.push(tab);
            }else{
                tabHeaders[oldTab] = tab;
            }
            var filteredTabs = [];
            for(var t in tabHeaders){
                if(document.getElementById(tabHeaders[t].id+"$!!$"+"container")){
                    filteredTabs.push(tabHeaders[t]);
                }
            }
            if(component.get("v.activeTab")==undefined){
                component.set("v.activeTab",filteredTabs[0].id);
            }
            if(document.getElementById(component.get("v.activeTab")+'$!!$container')==null){
                var deletedTabIndex;
                for(var t in component.get("v.tabHeaders")){
                    if(component.get("v.activeTab")==component.get("v.tabHeaders")[t].id){
                        deletedTabIndex = parseInt(t);
                    }
                }
                if(deletedTabIndex<filteredTabs.length-1){
                    component.set("v.activeTab",filteredTabs[deletedTabIndex+1].id);
                }else{
                    component.set("v.activeTab",filteredTabs[deletedTabIndex-1].id);
                }
            }
            var orderedTabs = [];
            for(var t in component.getElement().querySelectorAll('.slds-tabs--default__content')){
                for(var f in filteredTabs){
                    if(component.getElement().querySelectorAll('.slds-tabs--default__content')[t].id.split("$!!$")[0]==filteredTabs[f].id){
                        orderedTabs.push(filteredTabs[f]);
                    }
                }
            }
            component.set("v.tabHeaders",orderedTabs);
            if(component.get("v.tabHeaders").length>0){
                setTimeout(function(){
                    $A.util.removeClass(document.getElementById(component.get("v.activeTab")+"$!!$container"),'slds-hide');
                    $A.util.addClass(document.getElementById(component.get("v.activeTab")+"$!!$container"),'slds-show');
                    $A.util.addClass(document.getElementById(component.get("v.activeTab")+"$!!$header"),'slds-active');
                    var ul = component.getElement().querySelectorAll("ul")[0];
                    if(ul.clientWidth<ul.scrollWidth){
                        component.set("v.showScroll",true);  
                    }else{
                        component.set("v.showScroll",true);
                    }
                },100);
            }
        }
    },
    doneRendering:function(component){
        /*for(var t in component.get("v.tabHeaders")){
            var tab = component.get("v.tabHeaders")[t];
            document.getElementById(tab.id+"$!!$container").style.maxHeight  = (window.innerHeight-document.getElementById(tab.id+"$!!$container").getBoundingClientRect().top)+"px";
        }*/
    }
})