({
    doInit : function(component, event, helper) {
        component.set('v.record',{});
        component.find("utils").showProcessing();
        setTimeout(function(){
            component.find("utils").hideProcessing();
        },4000);
        helper.execute(component,"c.getQueryData",{"query":"SELECT Id, Name, Data__c FROM Setting__c WHERE Name='Campaign Wizard Settings'"},function(record){
            if(record != null && record.length > 0){
                var types = JSON.parse(record[0].Data__c).journeydefaultid.types;
                component.set('v.types', types);
            }
        })
        component.set('v.record.Campaign_Target__c', 'Persona');
        if(component.get("v.campaignId") && component.get("v.campaignId")!=""){
            component.set('v.campIdFound', true);
            component.set('v.makeSaveActive', false);
            helper.execute(component,"c.getCampaign",{"campaignId":component.get("v.campaignId")},function(response){
                component.set("v.record",response.campaign);
                if(response.campaign.Building__c != null)
                    component.set("v.existingCampaign",true);
                component.set("v.emails",JSON.parse(JSON.stringify(response.emails)));
                var cadence = parseInt(component.get("v.record.Campaign_Cadence__c").split(' ')[0]); 
                var existingCampEmailContentCount = response.emails.length > 0 ? response.emails.length : 0;
                var emails = response.emails;
                if(existingCampEmailContentCount < cadence){
                    var needToAddNewTemplate = parseInt(component.get("v.record.Campaign_Cadence__c").split(' ')[0]) - existingCampEmailContentCount;
                    for(var iCount = 0; iCount < needToAddNewTemplate; iCount++){
                        emails.push({'allowDelete':false});
                    }
                }
                //var emails = component.get("v.emails");
                for(var email in emails){
                    emails[email].sequence = [];
                    for(var j=1;j<=parseInt(component.get("v.record.Campaign_Cadence__c").split(" ")[0]);j++){
                        emails[email].sequence.push(j+"");
                    }
                }
                emails = helper.filterSequence(emails,component);
                component.set("v.emails",JSON.parse(JSON.stringify(emails)));
            })   
        }
    },
    enableSaveButton:function(component, event, helper){
        if(!component.get("v.record.Name") != null && component.get("v.record.Campaign_Cadence__c") != null && component.get("v.record.Type") != null && component.get("v.record.Campaign_Target__c") != null && component.get("v.record.Campaign_Audience__c") != null){
            component.set('v.makeSaveActive', false);
        }
    },
    cadenceChange:function(component,event,helper){
        var emails = [];
        for(var email in component.get("v.emails")){
            var obj = {};
            var diffFound = false;
            for(var key in component.get("v.emails")[email]){
                if(component.get("v.existingCampaign") && component.get("v.emails")[email][key] != component.get("v.emailsToCompaire")[email][key])
                    diffFound = true;
                if(key!='sequence' && key!='allowDelete'){
                    obj[key] = component.get("v.emails")[email][key];
                }
            }
            obj.sobjectType = "Campaign_Email_Content__c";
            if(diffFound)
            	emails.push(obj);
        }
        if(emails.length > 0){
            component.find("utils").showConfirm("You have unsaved changes, Do you want to save?",function(){
                
            })
        }
        else{
            component.set("v.emails", []);
            if(component.get("v.record.Campaign_Cadence__c") && component.get("v.record.Type") && component.get("v.record.Campaign_Target__c") && component.get("v.record.Campaign_Audience__c")){
                if(component.get("v.emails") && component.get("v.emails").length>0){
                    if(parseInt(component.get("v.record.Campaign_Cadence__c").split(" ")[0])<component.get("v.emails").length){
                        var emailCount = [];
                        for(var i=0;i<component.get("v.emails").length;i++){
                            var obj = JSON.parse(JSON.stringify(component.get("v.emails")[i]));
                            obj.allowDelete = true;
                            emailCount.push(obj);
                        }
                        component.set("v.emails",JSON.parse(JSON.stringify(emailCount)));
                    }else{
                        var emailCount = [];
                        for(var i=0;i<parseInt(component.get("v.record.Campaign_Cadence__c").split(" ")[0]);i++){
                            var obj = {};
                            if(i<component.get("v.emails").length){
                                obj = JSON.parse(JSON.stringify(component.get("v.emails")[i]));
                            }
                            obj.sequence = [];
                            for(var j=1;j<=parseInt(component.get("v.record.Campaign_Cadence__c").split(" ")[0]);j++){
                                obj.sequence.push(j+"");
                            }
                            obj.allowDelete = false;
                            emailCount.push(obj);
                        }
                        emailCount = helper.filterSequence(emailCount,component);
                        component.set("v.emails",JSON.parse(JSON.stringify(emailCount)));
                    }
                }else{
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
            }
        }
    },
    buildingChange:function(component,event,helper){
        if(component.get("v.record.Building__c")){
            helper.execute(component,"c.getQueryData",{"query":"Select Email__c,City__c,State__c from Building__c where Id='"+component.get("v.record.Building__c")+"'"},function(record){
                component.set("v.record.Email_Address__c",record[0].Email__c);
                component.set("v.record.City__c",record[0].City__c);
               	component.set("v.record.State__c",record[0].State__c);
            })
        }
    },
    sequenceChange:function(component,event,helper){
        setTimeout(function(){
            var emails = component.get("v.emails");
            emails = helper.filterSequence(emails,component);
            component.set("v.emails",emails);
        },100)
    },
    saveForm:function(component,event,helper){
        
    	helper.saveForm(component, helper);
       //This code is commented by amol,because we need not close campaign on save and also 
       //need not to show timetick count
       /* component.set("v.show",false);
        component.set("v.counter",10);
        var ticks = setInterval(function(){
            helper.increamentTicks(component,ticks);
        },1000);*/
    },
    deleteEmail:function(component,event,helper){
        var index = event.currentTarget.id.split(":")[1];
        var cadence = parseInt(component.get("v.record.Campaign_Cadence__c").split(" ")[0]);
        var emails = [];
        for(var email in component.get("v.emails")){
            var obj = component.get("v.emails")[email];
            if(component.get("v.emails").length==(cadence+1)){
                obj.allowDelete = false;
            }
            if(email==(index)){
                var emailsToDelete = component.get("v.emailsToDelete");
                if(obj.hasOwnProperty('Id')){
                    emailsToDelete.push(obj.Id);
                    component.set("v.emailsToDelete",emailsToDelete);
                }
            }else{
                emails.push(obj);      
            }
        }
        component.set("v.emails",JSON.parse(JSON.stringify(emails)));
        var filteredErrors = {};
        filteredErrors.mapValidations = {};
        filteredErrors.mapComponents = {};
        for(var err in component.get("v.errors").mapValidations){
            if(err.split(":").length==1 || parseInt(err.split(":")[1])<component.get("v.emails").length){
                filteredErrors.mapValidations[err] = component.get("v.errors").mapValidations[err];
                filteredErrors.mapComponents[err] = component.get("v.errors").mapComponents[err];
            }
        }
        component.set("v.errors",filteredErrors);
    },
    cancel:function(component,event,helper){
        component.find("utils").showConfirm("It will discard all your changes, Do you want to continue?",function(){
            /*component.set("v.show",false);
            component.set("v.counter",10);
            var ticks = setInterval(function(){
                helper.increamentTicks(component,ticks);
            },1000);*/
            window.close();
        })
    },
    close:function(component,event,helper){
        window.close();
    },
    change:function(component,event,helper){
        var params = event.getParam();
        console.log(params.fieldName);
    },
    fetchExsistingRecord:function(component,event,helper){
        if((component.get("v.campaignId") == "" || component.get("v.campaignId") == undefined) && component.get("v.isRevertToOldValue") == false && component.get("v.record.Campaign_Cadence__c") != null && component.get("v.record.Type") != null && component.get("v.record.Campaign_Target__c") != null && component.get("v.record.Campaign_Audience__c") != null){
            if(component.get('v.record.Name') != undefined && component.get('v.record.Name') != null)
                component.set('v.makeSaveActive', false);
            var emails = [];
            for(var email in component.get("v.emails")){
                var obj = {};
                var diffFound = false;
                for(var key in component.get("v.emails")[email]){
                    if(component.get("v.emailsToCompaire") == undefined || component.get("v.emailsToCompaire").length == 0)
                        diffFound = true;
                    if(key != 'sequence' && component.get("v.existingCampaign") && component.get("v.emails")[email][key] != component.get("v.emailsToCompaire")[email][key])
                        diffFound = true;
                    if(key!='sequence' && key!='allowDelete'){
                        obj[key] = component.get("v.emails")[email][key];
                    }
                }
                obj.sobjectType = "Campaign_Email_Content__c";
                
                if(diffFound)
                    emails.push(obj);
            }
            if(emails.length > 0){
                component.find("utils").showConfirm("It will discard all your unsaved changes. Do you want to continue?",function(){
                    helper.fetchExistingCampaign(component, helper);
                }, function(){
                    component.set("v.isRevertToOldValue", true);
                    component.set(event.getParam('expression'), event.getParam('oldValue'));
                })
            }
            else{
                helper.fetchExistingCampaign(component, helper);
            }
        }
        else{
            component.set("v.isRevertToOldValue", false);
        }
        
    },
    copyPreviousData:function(component, event, helper){
        component.set("v.previousSelected.Campaign_Cadence__c",component.get("v.record.Campaign_Cadence__c"));
        component.set("v.previousSelected.Type",component.get("v.record.Campaign_Cadence__c"));
        component.set("v.previousSelected.Campaign_Target__c",component.get("v.record.Campaign_Cadence__c"));
        component.set("v.previousSelected.Campaign_Audience__c",component.get("v.record.Campaign_Cadence__c"));
        //component.set("v.previousSelected",JSON.parse(JSON.stringify(component.get("v.record"))));
    }
})