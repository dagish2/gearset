({
	execute : function(component,method,params,onsuccess) {
        component.find("utils").showProcessing();
        var action = component.get(method);
        action.setParams(params);
        action.setCallback(this,function(response){
            if(response.getState()=="SUCCESS"){
                onsuccess(response.getReturnValue());
                component.find("utils").hideProcessing();
            }else if(response.getState()=="ERROR"){
                var errors = response.errors;
                if(errors){
                    for(var i=0;i<errors.length;i++){
                        component.find('utils').showError(errors[i].message);
                    }
                }
                component.find("utils").hideProcessing();
            }
        });
        $A.enqueueAction(action);
	},
    filterSequence:function(emails,component){
        var usedValues = [];
        for(var e in emails){
            if(emails[e].Sequence__c){
                usedValues.push(emails[e].Sequence__c);
            }
        }
        for(var i=0;i<emails.length;i++){
            emails[i].sequence = [];
            for(var j=1;j<=parseInt(component.get("v.record.Campaign_Cadence__c").split(" ")[0]);j++){
                if(usedValues.indexOf(j+"")==-1){
                    emails[i].sequence.push(j+"");
                }else{
                    if(emails[i].Sequence__c==(j+"")){
                        emails[i].sequence.push(j+"");
                    }
                }
            }
        }
        return emails;
    },
    increamentTicks:function(component,ticks){
        component.set("v.counter",component.get("v.counter")-1);
        if(component.get("v.counter")==0){
            clearInterval(ticks);
            window.close();
        }
    },
    saveForm:function(component,helper){
        component.set("v.record.Default_Parent_Campaign__c",true);
        component.set("v.record.sobjectType","Campaign");
        var isValidEmailTemplates = true;
        var emails = [];
        for(var email in component.get("v.emails")){
            var obj = {};
            for(var key in component.get("v.emails")[email]){
                if(key!='sequence' && key!='allowDelete'){
                    obj[key] = component.get("v.emails")[email][key];
                }
            }
            obj.sobjectType = "Campaign_Email_Content__c";
            if(obj.Default_Email_Template__c != undefined && obj.Sequence__c != undefined && obj.Subject_Line__c != undefined && obj.Dynamic_Email_Content__c  != undefined)
	            emails.push(obj);
            else if(obj.Default_Email_Template__c == undefined && obj.Sequence__c == undefined && obj.Subject_Line__c == undefined && obj.Dynamic_Email_Content__c  == undefined){
                
            }else{
                isValidEmailTemplates = false;
            }
        }
        if(isValidEmailTemplates){
            if(emails.length == 0){
                component.find('utils').showError("You must have to save at least one email template to save the campaign.");
            }else{
                //Changes made by Amol, to make campaign inactive if email template is not equals to campaign cadence
                if(emails.length == parseInt(component.get("v.record.Campaign_Cadence__c").split(" ")[0]))
                    component.set("v.record.IsActive",true);
                else
                    component.set("v.record.IsActive",false);
                var temp = this;
                component.set("v.emailsToCompaire", emails);
                helper.execute(component,"c.saveCampaign",{"campaign":component.get("v.record"),"emails":emails,"emailsToDelete":component.get("v.emailsToDelete")},function(response){
                    //if(component.get("v.record.Id") == undefined)
                            //component.set("v.record.Id",response);
                    temp.fetchExistingCampaign(component, helper);
                    component.set("v.firstRefresh",false);
                    component.find('utils').showSuccess("Campaign saved successfully!");
                })
            }
        }
        else{
            component.find('utils').showError("Fields marked with * are mandatory fields.");
        }
    },
    fetchExistingCampaign:function(component, helper){
    	if(component.get("v.record.Campaign_Cadence__c") != null && component.get("v.record.Type") != null && component.get("v.record.Campaign_Target__c") != null && component.get("v.record.Campaign_Audience__c") != null){
            helper.execute(component,"c.getQueryData",{"query":"SELECT Id, Name, Email_Address__c, Building__c, City__c, State__c, Email_Sendout_Start_Date__c, Email_Sendout_End_Date__c, Description, Campaign_Cadence__c, Type, Campaign_Target__c, Campaign_Audience__c, (SELECT Id, Name, Default_Email_Template__c, Sequence__c, Subject_Line__c, Dynamic_Email_Content__c FROM Campaign_Email_Contents__r) FROM Campaign WHERE Default_Parent_Campaign__c = true AND Campaign_Cadence__c = '"+component.get("v.record.Campaign_Cadence__c ")+"' AND Type = '"+component.get("v.record.Type ")+"' AND Campaign_Target__c = '"+component.get("v.record.Campaign_Target__c ")+"' AND Campaign_Audience__c = '"+component.get("v.record.Campaign_Audience__c ")+"'"},function(record){
                if(record != null && record.length > 0){
                    if(component.get("v.firstRefresh"))
                         component.find('utils').showAlert("You have an existing campaign. You can update it.");
                    if(record[0].Building__c != null)
                    	component.set("v.existingCampaign",true);
                    else
                        component.set("v.existingCampaign",false);
                    component.set('v.makeSaveActive', false);
                    //component.set("v.record",record[0]);
                    component.set("v.record.Id",record[0].Id);
                    component.set("v.record.Name",record[0].Name);
                    component.set("v.record.Email_Address__c",record[0].Email_Address__c);
                    component.set("v.record.City__c",record[0].City__c);
                    component.set("v.record.State__c",record[0].State__c);
                    component.set("v.record.Building__c",record[0].Building__c);
                    component.set("v.record.Email_Sendout_Start_Date__c",record[0].Email_Sendout_Start_Date__c);
                    component.set("v.record.Email_Sendout_End_Date__c",record[0].Email_Sendout_End_Date__c);
                   
                    var cadence = parseInt(component.get("v.record.Campaign_Cadence__c").split(' ')[0]); 
                    var emails = record[0].Campaign_Email_Contents__r != undefined ? record[0].Campaign_Email_Contents__r : [];
                    var existingCampEmailContentCount = record[0].Campaign_Email_Contents__r != undefined ? record[0].Campaign_Email_Contents__r.length : 0;
                    if(existingCampEmailContentCount < cadence){
                        var needToAddNewTemplate = parseInt(component.get("v.record.Campaign_Cadence__c").split(' ')[0]) - existingCampEmailContentCount;
                        for(var iCount = 0; iCount < needToAddNewTemplate; iCount++){
                            emails.push({'allowDelete':false});
                        }
                    }
                    for(var iCount = 0; iCount < emails.length; iCount++){
                        emails[iCount].sequence = [];
                        for(var j=1;j<=parseInt(component.get("v.record.Campaign_Cadence__c").split(" ")[0]);j++){
                            emails[iCount].sequence.push(j+"");
                        }
                    }
                    emails = helper.filterSequence(emails,component);
                    component.set("v.emails", JSON.parse(JSON.stringify(emails)));
                    component.set("v.emailsToCompaire", JSON.parse(JSON.stringify(emails)));
                   
                }
                else{
                    component.set("v.existingCampaign",false);
                    component.get("v.emailsToCompaire", []);
                    var emailCount = [];
                    for(var i=0;i<parseInt(component.get("v.record.Campaign_Cadence__c").split(" ")[0]);i++){
                        var obj = {};
                        obj.allowDelete = false;
                        obj.sequence = [];
                        for(var j=1;j<=parseInt(component.get("v.record.Campaign_Cadence__c").split(" ")[0]);j++){
                            obj.sequence.push(j+"");
                        }
                        emailCount.push(obj);
                    }
                    component.set("v.emails",JSON.parse(JSON.stringify(emailCount)));
                }
            })    
        }
	}
})