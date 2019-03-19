({
    doInit : function(component, event, helper) {
        helper.init(component, event, helper); 
    },
    showLeadModal:function(component, event, helper){
        component.set("v.leadFormData",{"Phone":component.get("v.phone"),"sobjectType":"Lead","LeadSource":"Cold Call"});
        component.find("NewLeadModal").showModal();
    },
    closeLeadModal:function(component, event, helper){
        component.find("NewLeadModal").close();
    },
    createNewLead:function(component, event, helper){
        var lstRecords = [];
        lstRecords.push(JSON.parse(JSON.stringify(component.get("v.leadFormData")))); 
        component.find("utils").showProcessing();
        component.find("utils").execute("c.saveRecords",{"records":lstRecords},function(response){ 
            component.find("utils").showProcessing();
            component.set("v.showMessage",false);
            component.find("NewLeadModal").close();
            location.href = location.href.replace(/(phone=).*?(&)/,'$1' + lstRecords[0].Phone + '$2');  
            component.find("utils").hideProcessing();
        },function(error){
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        });
    },
    close:function(){
        window.close();
    },
    selectSubject:function(component, event, helper){
        var option = event.currentTarget.value;
        var index = component.get("v.settingData.dispositions").findIndex(x => x.Value.toLowerCase()==option.toLowerCase());
        if(component.get("v.settingData.dispositions")[index].hasOwnProperty("showFollowUp") && component.get("v.settingData.dispositions")[index].showFollowUp==false){
            component.set("v.showNFD",false);
        }else{
            component.set("v.showNFD",true);
        }
        if(component.get("v.settingData.dispositions")[index].hasOwnProperty("nextFT")){
            var minutesToAdd = parseFloat(component.get("v.settingData.dispositions")[index]["nextFT"])*60;
            component.set("v.showNFT",true);
            var dateNFT = new Date();
            dateNFT.setMinutes(dateNFT.getMinutes()+minutesToAdd);
            var nextFollowUpTime = (dateNFT.getHours()<12 ?("0"+dateNFT.getHours()+":"+(dateNFT.getMinutes() < 10 ? "0"+dateNFT.getMinutes() : dateNFT.getMinutes())):(dateNFT.getHours()+":"+(dateNFT.getMinutes() < 10 ? "0"+dateNFT.getMinutes() : dateNFT.getMinutes())));
            component.set("v.objActivity.Next_Followup_Time__c",nextFollowUpTime);
        }else{
            component.set("v.showNFT",false);
        }
        
        if(option && option.toLowerCase()=="tour booked"){
            var dt = new Date();
            if(component.get("v.lead"))
                window.open("/apex/BookTours?leadId="+component.get("v.lead.Id"),"_Blank");
            else if(component.get("v.contact"))
                window.open("/apex/BookTours?contactId="+component.get("v.contact.Id"),"_Blank");
        }  
    },
    createActivity:function(component, event, helper){
        var isPause = component.get("v.objActivity.showPauseReason");
        helper.saveActivity(component, event, helper,false,isPause);
    },
    saveAndClose:function(component, event, helper){
        //component.find("utils").showConfirm("Are you sure you want to close the page immediately after activity creation ?",function(){
        var isPause = component.get("v.objActivity.showPauseReason");   
        helper.saveActivity(component, event, helper,true,isPause);
        //});
        //helper.disposeCall(component,event,helper,true);
    },
    disposeCall:function(component,event,helper){
        //component.find("utils").showConfirm("Are you sure you want to close ?",function(){
        	var isPause = component.get("v.objActivity.showPauseReason");  
         	if(isPause && (component.get("v.objActivity.PauseReason")==undefined || component.get("v.objActivity.PauseReason")=="")){
                component.find("utils").showError("Please choose the reason to pause the call.");
            }else{
                helper.disposeCall(component,event,helper,isPause);
            }
           
        //});
       
    },
    showDispositionForm:function(component,event,helper){
        component.find("DisposeCallModal").showModal();
    }
})