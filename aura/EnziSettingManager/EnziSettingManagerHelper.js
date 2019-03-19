({
    init:function(component, event, helper){
        var actions = [];
        actions.push({"name":"SyncSetting","label":"Sync Setting","action":component.getReference("c.syncData"),"leftIcon":"utility:sync","type":"brand"});
        component.set("v.actions",actions);
        helper.setshowActions(component);
        
        component.find("utils").showProcessing();
        component.find("utils").execute("c.getQueryData",{"query":"Select Id,Type__c,Name,Data__c,Description__c,Source_Object__c,Destination_Object__c,CreatedBy.Name,LastModifiedBy.Name,CreatedDate,LastModifiedDate from Setting__c Where Id='"+component.get("v.settingId")+"'"},function(result){
            component.set("v.currentSetting",result[0]);
            var oldsettingdata=result[0];
            component.set("v.oldSetting",JSON.parse(JSON.stringify(oldsettingdata)));
        	component.set("v.data",JSON.parse(component.get("v.currentSetting.Data__c")));
            component.set("v.oldData",JSON.parse(component.get("v.currentSetting.Data__c")));
            helper.getSettingHistories(component,function(){
                component.find("utils").hideProcessing();
            });
        },function(error){
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        })
    },
    getSettingHistories : function(component,onsuccess) {
        var helper = this;
        component.find("utils").execute("c.getQueryData",{"query":"Select Id,User__c,User__r.SmallPhotoUrl,User__r.Name,Setting__c,Setting__r.Name,New_Data__c,Old_Data__c,CreatedDate from Setting_History__c Where Setting__c='"+component.get("v.currentSetting.Id")+"' AND CreatedDate = LAST_N_DAYS:90 Order By CreatedDate desc"},function(result){
            var mapHistory = {};
            for(var r in result){
                result[r].activities = helper.getActivitiesFromHistory(component,result[r].Old_Data__c?JSON.parse(result[r].Old_Data__c):result[r].Old_Data__c,result[r].New_Data__c?JSON.parse(result[r].New_Data__c):result[r].New_Data__c,result[r].Setting__r.Name);
            }
            component.set("v.currentHistory",result);
            onsuccess();
        },function(error){
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        })
	},
    getActivitiesFromHistory:function(component, oldData, newData, settingName){
        var activities = [];
        var path = settingName;
        if(component.get("v.currentSetting.Type__c")=="Field Mappings"){
            this.getFieldMappingsActivities(component,oldData.mappings,newData.mappings,activities);
        }else{
            switch(settingName){
                case "TriggerSettings":
                    this.getTriggerSettingsActivities(oldData,newData,activities);
                    break;
               	case "User/Queue Journey Creation":
                    this.getJourneyCreationActivities(oldData,newData,activities);
                    break;
                case "Lead:Lead and Lead Source Details":
                    this.getLeadSourceDetailsActivities(oldData,newData,activities);
                    break;
                default:
                    this.getDiffrence(oldData,newData,activities, path);
            }
        }
        return activities;
    },
    getDiffrence:function(oldData,newData,activities,path){
        if(oldData!=undefined && newData!=undefined){
            if(typeof oldData==="object" && typeof newData==="object"){
                if(Array.isArray(oldData)){
                    if(oldData.length==newData.length){
                        for(var d in oldData){
                            this.getDiffrence(oldData[d],newData[d],activities,path+' => '+d);
                        }
                    }
                    else if(oldData.length>newData.length){
                        for(var d in oldData){
                            if(this.containsValue(newData,oldData[d])){
                                if(!this.containsValue(oldData,newData[d])){
                                    this.getDiffrence(oldData[d],newData[d],activities,path+' => '+d);
                                }
                            }else{
                                activities.push({"path":path+' => '+d,"msg":"Deleted value","data":oldData[d],"type":(typeof oldData[d])});
                            }
                        }
                    }
                    else if(oldData.length<newData.length){
                        for(var d in newData){
                            if(this.containsValue(oldData,newData[d])){
                                if(!this.containsValue(newData,oldData[d])){
                                    this.getDiffrence(oldData[d],newData[d],activities,path+' => '+d);
                                }
                            }else{
                                activities.push({"path":path+' => '+d,"msg":"Added value","data":newData[d],"type":(typeof newData[d])});
                            }
                        }
                    }
                }else{
                    if(Object.keys(oldData).length==Object.keys(newData).length){
                        for(var d in newData){
                            this.getDiffrence(oldData[d],newData[d],activities,path+' => '+d);
                        }
                    }
                    else if(Object.keys(oldData).length>Object.keys(newData).length){
                        for(var d in oldData){
                            if(newData.hasOwnProperty(d)){
                                this.getDiffrence(oldData[d],newData[d],activities,path+' => '+d);
                            }else{
                                activities.push({"path":path+' => '+d,"msg":("Deleted key "+d),"data":oldData[d]});
                            }
                        }
                    }
                    else if(Object.keys(oldData).length<Object.keys(newData).length){
                        for(var d in newData){
                            if(oldData.hasOwnProperty(d)){
                                this.getDiffrence(oldData[d],newData[d],activities,path+' => '+d);
                            }else{
                                activities.push({"path":path+' => '+d,"msg":("Added key "+d),"data":newData[d]});
                            }
                        }
                    }
                }
            }else{
                if(oldData!=newData){
                    activities.push({"path":path,"msg":"Changed value from "+oldData+" to "+newData});
                }
            }
        }else{
            if(oldData==undefined){
                if(path.split(" => ").length>1){
                    activities.push({"path":path,"msg":"Changed key from "+newData+" to "+path.split(" => ")[path.split(" => ").length-1]});
                }else{
                    activities.push({"path":path,"msg":"Created this setting."});
                }
            } 
            if(newData==undefined){
                activities.push({"path":path,"msg":"Deleted this setting."});
            }
        }
    },
    containsValue:function(list,value){
        if(value){
            for(var v in list){
                if(JSON.stringify(list[v])===JSON.stringify(value)){
                    return true;
                    break;
                }
            }
        }  
    },
    getAccessToken:function(component,onSuccess,onError){
        //var objRequestPost='grant_type=password&client_id=3MVG9AzPSkglhtpvenc1ubvIHNqdSv2B8w9bFU2hNfvAOfxt5ri2SCQo_M.lflR7dukJ5s9LtXu.eZ3KzbmRO&client_secret=8952510748675479529&username=parag.vyas@wework.com.staging&password=9K$U!iU4B(aUMBd5&redirect_uri=https://login.salesforce.com/services/oauth2/callback';
        var objRequestPost='grant_type=password&client_id=3MVG9AzPSkglhtpvenc1ubvIHNqdSv2B8w9bFU2hNfvAOfxt5ri2SCQo_M.lflR7dukJ5s9LtXu.eZ3KzbmRO&client_secret=8952510748675479529&'+atob("dXNlcm5hbWU9cGFyYWcudnlhc0B3ZXdvcmsuY29tLnN0YWdpbmcmcGFzc3dvcmQ9OUskVSFpVTRCKGFVTUJkNSZyZWRpcmVjdF91cmk9aHR0cHM6Ly9sb2dpbi5zYWxlc2ZvcmNlLmNvbS9zZXJ2aWNlcy9vYXV0aDIvY2FsbGJhY2s=");
        var url = "https://test.salesforce.com/services/oauth2/token";
        var headers = {"content-type":"application/x-www-form-urlencoded"};
        component.find("utils").execute("c.executeRest",{"method":"POST","endPointUrl":url,"headers":headers,"body":objRequestPost},function(response){
            onSuccess(response);
        },function(error){
            onError(error)
        });  
    },
    getSettingData:function(component,helper,isAll,onSuccess,onError){
        helper.getAccessToken(component,function(response){
            var data = JSON.parse(response);
            var reqHeader = {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer ' + data.access_token
            }
            var instance_url = data.instance_url.toLowerCase()+'/services/data/v40.0/query/?q=Select+Name,Type__c,Description__c,Data__c+from+Setting__c';
            if(!isAll)
                instance_url=instance_url+ '+Where+Name=\''+component.get("v.currentSetting.Name")+'\'';
            component.find("utils").execute("c.executeRest",{"method":"GET","endPointUrl":instance_url,"headers":reqHeader,"body":''},function(settingData){
                onSuccess(settingData);
            },function(error){
                onError(error);
            }); 
        },function(error){
            onError(error)
        })
    },
    updateSettingData:function(component,records,onSuccess,onError){
        component.find("utils").execute("c.saveRecords",{"records":records},function(response){
            onSuccess(response);
        },function(error){
            onError(error);      
        }) 
    },
    getSettingObject:function(component,data,onSuccess){
        var settingObj = {};
        settingObj.Id = component.get("v.settingId");
        settingObj.Data__c = JSON.parse(data).records[0].Data__c;
        settingObj.Type__c = JSON.parse(data).records[0].Type__c;
        settingObj.Description__c = JSON.parse(data).records[0].Description__c;
        var records = [];
        records.push(settingObj);
        onSuccess(records);
    },
    getAllSettingData:function(component,helper,data,onSuccess,onError){
        if(data && JSON.parse(data).records && JSON.parse(data).records.length){
            var mapPreProdSetting = {};
            var mapCurrentInstanceSetting = {};
            var lstSettingRecords = [];
            var lstPreprodSetting = JSON.parse(data).records;
            lstPreprodSetting.forEach(function(setting) {
                mapPreProdSetting[setting.Name] = setting;
            });
            component.find("utils").execute("c.getQueryData",{"query":"Select Id,Type__c,Name,Data__c,Description__c from Setting__c"},function(result){
                if(result && result.length){
                   /* component.find("utils").execute("c.SendMail",{"csvSettingBackUp":helper.testCSV(result,["Id","Name","Type__c","Data__c","Description__c"])},function(result){
                        console.log("Sent Mail :"+result.toUpperCase());
                    },function(error){
                       console.log(error) 
                    })*/
                    result.forEach(function(setting){
                        mapCurrentInstanceSetting[setting.Name] = setting;
                    });
                    lstPreprodSetting.forEach(function(setting) {
                        if(mapCurrentInstanceSetting && mapCurrentInstanceSetting.hasOwnProperty(setting.Name)){
                            var newSetting = {};
                            newSetting.Id = mapCurrentInstanceSetting[setting.Name].Id;
                            newSetting.Data__c = mapPreProdSetting[setting.Name].Data__c;
                            newSetting.Type__c = mapPreProdSetting[setting.Name].Type__c;
                            newSetting.Description__c = mapPreProdSetting[setting.Name].Description__c;
                            lstSettingRecords.push(newSetting);
                        }else{
                            var newSetting = {};
                            newSetting.sobjectType='Setting__c';
                            newSetting.Name = mapPreProdSetting[setting.Name].Name;
                            newSetting.Data__c = mapPreProdSetting[setting.Name].Data__c;
                            newSetting.Type__c = mapPreProdSetting[setting.Name].Type__c;
                            newSetting.Description__c = mapPreProdSetting[setting.Name].Description__c;
                            lstSettingRecords.push(newSetting);
                        } 
                    });
                }
                else{
                    lstPreprodSetting.forEach(function(setting) {
                        var newSetting = {};
                        newSetting.sobjectType='Setting__c';
                        newSetting.Name = mapPreProdSetting[setting.Name].Name;
                        newSetting.Data__c = mapPreProdSetting[setting.Name].Data__c;
                        newSetting.Type__c = mapPreProdSetting[setting.Name].Type__c;
                        newSetting.Description__c = mapPreProdSetting[setting.Name].Description__c;
                        lstSettingRecords.push(newSetting);
                    })
                }
                   
                onSuccess(lstSettingRecords);
            },function(error){
                onError(error);
            })
        }
    },
    createCSV :function (clearedRecord, keys, str) {
        var data = [];
        clearedRecord.forEach(function(record){
            record.Data__c = JSON.stringify(JSON.parse(record.Data__c))
            data.push(record);
        })
        var firstInvertedcomma = '"';
        var comma = ',';
        if (str == '') {
            keys.forEach(function (rec, index) {// creating header columns
                if (index == (keys.length) - 1) {
                    str += firstInvertedcomma + rec + firstInvertedcomma + '\n';
                    return false;
                }
                str += firstInvertedcomma + rec + firstInvertedcomma + comma;
            })
        }        
        data.forEach(function (rec, index2) {
            keys.forEach(function (key, index) {
                if (index == (keys.length) - 1) {
                    if (rec[key] == undefined)
                        str += firstInvertedcomma + firstInvertedcomma + '\n'
                        else
                            str += firstInvertedcomma + rec[key].trim() + firstInvertedcomma + '\n';
                    return false;
                }
                if (rec[key] == undefined)
                    str += firstInvertedcomma + firstInvertedcomma + comma;
                else
                    str += firstInvertedcomma + rec[key].trim() + firstInvertedcomma + comma;
            })
        })
        return str;
        console.log('\nstr ::\t' + str);
    },
    testCSV : function(records,fields){
        var filterRecords = [];
        var str = "";
        records.forEach(function(rec){
            rec.Data__c = JSON.stringify(JSON.parse(rec.Data__c));
            filterRecords.push(rec);
        })
        fields.forEach(function(header){
            if(str!="")
            {
                str=str+'"'+header+'",';
            }else{
                str = '"'+header+'",'
            }
        })
        str=str.slice(0,-1);
        str=str+'\n';
        
        filterRecords.forEach(function(record){
            fields.forEach(function(header){
                str = str+'"'+record[header]+'",'
            })
            str=str.slice(0,-1);
            str=str+'\n';
        })
        return str;
    },
    setshowActions:function(component){
        if(!(location.origin.includes('preprod') || location.origin.includes('qa') || location.origin.includes('wework.my.salesforce')||location.origin.includes('wework.lightning'))){
            component.set("v.showActions",true);
        }
    },
    getTriggerSettingsActivities:function(oldData,newData,activities){
        for(var oldTrigger in oldData){
            if(!newData.hasOwnProperty(oldTrigger)){
                activities.push({"path":"TriggerSettings => "+oldTrigger,"msg":"Deleted Trigger "+oldTrigger});
            }
        }
        for(var newTrigger in newData){
            if(oldData.hasOwnProperty(newTrigger)){
                if(oldData[newTrigger]!=newData[newTrigger]){
                    if(newData[newTrigger]){
                        activities.push({"path":"TriggerSettings => "+newTrigger,"msg":"Activated Trigger "+newTrigger});
                    }else{
                        activities.push({"path":"TriggerSettings => "+newTrigger,"msg":"Deactivated Trigger "+newTrigger});
                    }
                }
            }else{
                activities.push({"path":"TriggerSettings => "+newTrigger,"msg":"Added Trigger "+newTrigger});
            }
        }
    },
    getFieldMappingsActivities:function(component,oldData,newData,activities){
        for(var oldField in oldData){
            if(!newData.hasOwnProperty(oldField)){
                activities.push({"path":component.get("v.currentSetting.Name").split(":")[1]+" => "+oldField,"msg":"Unmapped Field "+oldField});
            }
        }
        for(var newField in newData){
            if(oldData.hasOwnProperty(newField)){
                if(oldData[newField].fieldname!=newData[newField].fieldname){
                    activities.push({"path":component.get("v.currentSetting.Name").split(":")[1]+" => "+newField,"msg":"Mapping Changed From "+oldData[newField].fieldname+" to "+newData[newField].fieldname});
                }
                if(oldData[newField].isvalue!=newData[newField].isvalue){
                    activities.push({"path":component.get("v.currentSetting.Name").split(":")[1]+" => "+newField,"msg":"Isvalue Changed From "+oldData[newField].isvalue+" to "+newData[newField].isvalue});
                }
                if(oldData[newField].overwrite!=newData[newField].overwrite){
                    activities.push({"path":component.get("v.currentSetting.Name").split(":")[1]+" => "+newField,"msg":"Overwrite Changed From "+oldData[newField].overwrite+" to "+newData[newField].overwrite});
                }
            }else{
                activities.push({"path":component.get("v.currentSetting.Name").split(":")[1]+" => "+newField,"msg":"Mapped Field "+newField});
            }
        }
    },
    getJourneyCreationActivities:function(oldData,newData,activities){
        var oldMap = {"allowedUsers":{},"allowedQueues":{}};
        var newMap = {"allowedUsers":{},"allowedQueues":{}};  
        for(var o in oldData.allowedUsers){
            oldMap.allowedUsers[oldData.allowedUsers[o].Id] = oldData.allowedUsers[o];
        }
        for(var n in newData.allowedUsers){
            newMap.allowedUsers[newData.allowedUsers[n].Id] = newData.allowedUsers[n];
        }
        for(var o in oldData.allowedQueues){
            oldMap.allowedQueues[oldData.allowedQueues[o].Id] = oldData.allowedQueues[o];
        }
        for(var n in newData.allowedQueues){
            newMap.allowedQueues[newData.allowedQueues[n].Id] = newData.allowedQueues[n];
        }
        for(var o in oldMap.allowedUsers){
            if(!newMap.allowedUsers.hasOwnProperty(o)){
                activities.push({"path":"JorneyCreation => AllowedUsers => "+oldMap.allowedUsers[o].userName,"msg":"Deleted User "+oldMap.allowedUsers[o].userName});
            }
        }
        for(var o in oldMap.allowedQueues){
            if(!newMap.allowedQueues.hasOwnProperty(o)){
                activities.push({"path":"JorneyCreation => AllowedQueues => "+oldMap.allowedQueues[o].queueName,"msg":"Deleted Queue "+oldMap.allowedQueues[o].queueName});
            }
        }
        for(var n in newMap.allowedUsers){
            if(!oldMap.allowedUsers.hasOwnProperty(n)){
                activities.push({"path":"GenerateJourney => AllowedUsers => "+newMap.allowedUsers[n].userName,"msg":"Added User "+newMap.allowedUsers[n].userName});
            }
        }
        for(var n in newMap.allowedQueues){
            if(!oldMap.allowedQueues.hasOwnProperty(n)){
                activities.push({"path":"GenerateJourney => AllowedQueues => "+newMap.allowedQueues[n].queueName,"msg":"Added Queue "+newMap.allowedQueues[n].queueName});
            }
        }
    },
    getLeadSourceDetailsActivities:function(oldData,newData,activities){
        var oldMap = {"LeadSource":{},"LeadSourceDetails":{}};
        var newMap = {"LeadSource":{},"LeadSourceDetails":{}};  
        for(var o in oldData.LeadSource){
            oldMap.LeadSource[oldData.LeadSource[o].name] = oldData.LeadSource[o];
        }
        for(var n in newData.LeadSource){
            newMap.LeadSource[newData.LeadSource[n].name] = newData.LeadSource[n];
        }
        for(var o in oldData.LeadSourceDetails){
            oldMap.LeadSourceDetails[oldData.LeadSourceDetails[o]] = oldData.LeadSourceDetails[o];
        }
        for(var n in newData.LeadSourceDetails){
            newMap.LeadSourceDetails[newData.LeadSourceDetails[n]] = newData.LeadSourceDetails[n];
        }
        for(var o in oldMap.LeadSource){
            if(!newMap.LeadSource.hasOwnProperty(o)){
                activities.push({"path":"LeadSource => "+o,"msg":"Deleted LeadSource "+o});
            }
        }
        for(var o in oldMap.LeadSourceDetails){
            if(!newMap.LeadSourceDetails.hasOwnProperty(o)){
                activities.push({"path":"LeadSourceDetails => "+o,"msg":"Deleted LeadSource Details "+o});
            }
        }
        for(var n in newMap.LeadSource){
            if(oldMap.LeadSource.hasOwnProperty(n)){
                if(oldMap.LeadSource[n].OverrideLeadSoruce!=newMap.LeadSource[n].OverrideLeadSoruce){
                    activities.push({"path":"LeadSource => "+n,"msg":"Override LeadSource Changed From "+oldMap.LeadSource[n].OverrideLeadSoruce+" to "+newMap.LeadSource[n].OverrideLeadSoruce});
                }
            }else{
                activities.push({"path":"LeadSource => "+n,"msg":"Added LeadSource "+n});
            }
        }
        for(var n in newMap.LeadSourceDetails){
            if(!oldMap.LeadSourceDetails.hasOwnProperty(n)){
                activities.push({"path":"LeadSourceDetails => "+n,"msg":"Added LeadSource Details "+n});
            }
        }
    }
})