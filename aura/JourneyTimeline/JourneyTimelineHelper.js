({
    init : function(component, event, helper){
        component.find("utils").showProcessing();
        component.find("utils").execute("c.getUserInfo",{},function(userInfo){
           component.set("v.userInfo",JSON.parse(userInfo)[0]);
            if(component.get("v.journeyId")){
                component.find("utils").execute("c.getQueryData",{"query":"Select Id,Primary_Lead__c,Primary_Contact__c From Journey__c Where Id='"+component.get("v.journeyId")+"'"},function(result){
                    if(result[0].Primary_Lead__c){
                        component.set("v.memberId",result[0].Primary_Lead__c);
                    }else if(result[0].Primary_Contact__c){
                        component.set("v.memberId",result[0].Primary_Contact__c);
                    }
                    component.find("utils").hideProcessing();
                },function(error){
                    component.find("utils").hideProcessing();
                    component.find("utils").showError(error);
                })
            }else if(component.get("v.phone")){
                var mathingPhone = helper.getMatchingPhone(component);
                console.log("Matching Phone >> "+mathingPhone);
                component.find("utils").execute("c.getTodaysDate",{},function(dt){
                    component.set("v.currentDate",dt);
                    var callSubject = component.find("utils").geturlParamByName("type");
                    //component.set("v.currentDate",dt.setDate(dt.getDate()-1));
                    helper.setSettingData(component,function(data){
                        component.set("v.lstCallDisposition",data['dispositions']);
                        component.set("v.lstPauseReasons",data['pauseReason']);
                        component.set("v.settingData",data);
                        component.find("utils").execute("c.getQueryData",{"query":"Select Id,Owner.Name,Owner.Id,CreatedDate,Name,Email,Phone,Company_Name__c,(Select Id,Name,Status__c,Owner.Name,Owner.Id,Full_Time_Employees__c,Email__c,Lead_Source__c from Journeys__r where Status__c = 'Started'),(Select Id,Subject,OwnerId,WhatId,WhoId from OpenActivities where Subject ='"+callSubject+"')  From Contact Where "+mathingPhone+" ORDER BY LastModifiedDate desc limit 1"},function(result){
                            if(result.length>0){
                                component.set("v.memberId",result[0].Id);
                                component.set("v.contact",result[0]);
                                helper.setJourneyMetaFields(component);
                                if(result[0].hasOwnProperty("Journeys__r")){
                                    component.set("v.journeys",result[0].Journeys__r);
                                }else{
                                    component.set("v.journeys",[]);
                                }
                                helper.checkUpdateOpenActivities(component,helper,result,function(task){
                                    if(task && Object.keys(task).length){
                                        component.find("utils").execute("c.saveRecord",{"record":task},function(response){
                                            component.find("utils").hideProcessing();
                                            component.find("utils").showSuccess("Activity Created Successfully");
                                            task.Id = JSON.parse(response).id;
                                            component.set("v.recentActivity",task);
                                            component.set("v.objActivity.Subject",task.Subject);
                                            component.find("activityComponent").refreshComponent();
                                        },function(error){
                                            component.find("utils").hideProcessing();
                                            component.find("utils").showError(error);     
                                        }) 
                                    }
                                });
                            }else{
                                component.find("utils").execute("c.getQueryData",{"query":"Select Id,Name,Email,Phone,Owner.Id,Owner.Name,LeadSource,CreatedDate,CreatedBy.Id,CreatedBy.Name,isConverted,(Select Id,Name,Status__c,Email__c,Owner.Name,Owner.Id,Full_Time_Employees__c,Lead_Source__c from Journeys__r where Status__c = 'Started'),(Select Id,Subject,OwnerId,WhatId,WhoId from OpenActivities where Subject ='"+callSubject+"') From Lead Where ("+mathingPhone+") AND isConverted=false ORDER BY LastModifiedDate desc limit 1"},function(result){
                                    if(result.length>0){
                                        component.set("v.memberId",result[0].Id);
                                        component.set("v.lead",result[0]);
                                        helper.setJourneyMetaFields(component);
                                        if(result[0].hasOwnProperty("Journeys__r")){
                                            component.set("v.journeys",result[0].Journeys__r);
                                        }else{
                                            component.set("v.journeys",[]);
                                        }
                                        //Block to create/update recent activity on call
                                       /* helper.checkUpdateOpenActivities(component,helper,result,function(task){
                                            if(task && Object.keys(task).length){
                                                if(task.OwnerId!=component.get("v.userInfo.Id")){
                                                    component.find("utils").execute("c.saveRecord",{"record":task},function(response){
                                                        component.find("utils").hideProcessing();
                                                        component.find("utils").showSuccess("Activity Created Successfully");
                                                        task.Id = JSON.parse(response).id;
                                                        component.set("v.recentActivity",task);
                                                        component.set("v.objActivity.Subject",task.Subject);
                                                    },function(error){
                                                        component.find("utils").hideProcessing();
                                                        component.find("utils").showError(error);     
                                                    }) 
                                                }
                                                else{
                                                    component.set("v.recentActivity",task);
                                                    component.set("v.objActivity.Subject",task.Subject);
                                                    component.find("utils").hideProcessing();
                                                }
                                                
                                            }else{
                                                component.find("utils").hideProcessing();
                                            }
                                        })*/
                                        helper.checkUpdateOpenActivities(component,helper,result,function(task){
                                            if(task && Object.keys(task).length){
                                                component.find("utils").execute("c.saveRecord",{"record":task},function(response){
                                                    component.find("utils").hideProcessing();
                                                    component.find("utils").showSuccess("Activity Created Successfully");
                                                    task.Id = JSON.parse(response).id;
                                                    component.set("v.recentActivity",task);
                                                    component.set("v.objActivity.Subject",task.Subject);
                                                    component.find("activityComponent").refreshComponent();
                                                },function(error){
                                                    component.find("utils").hideProcessing();
                                                    component.find("utils").showError(error);     
                                                }) 
                                            }
                                        });
                                    }else{
                                        component.find("utils").hideProcessing();
                                        component.set("v.showMessage",true);
                                    }
                                },function(error){
                                    component.find("utils").hideProcessing();
                                    component.find("utils").showError(error);
                                })
                            }
                        },function(error){
                            component.find("utils").hideProcessing();
                            component.find("utils").showError(error);
                        })
                    },function(error){
                        component.find("utils").hideProcessing();
                        component.find("utils").showError(error);
                    });
                },function(error){
                    component.find("utils").hideProcessing();
                    component.find("utils").showError(error);
                })
            }else{
                component.find("utils").hideProcessing();
                component.find("utils").showError('Please specify phone number!');
            }
            
        },function(error){
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        });
    },
    setJourneyMetaFields : function(component) {
        var metaFields = [];
        metaFields.push({"name":"Name","label":"Name","type":"component","component":{"name":"ui:outputURL","attributes":{"label":"{{Name}}","value":"/{{Id}}","target":"_blank"}}});
        metaFields.push({"name":"Email__c","label":"Email","type":"component","component":{"name":"ui:outputURL","attributes":{"label":"{{Email__c}}","value":"mailTo:{{Email__c}}","target":"_blank"}}});
        metaFields.push({"name":"Full_Time_Employees__c","label":"FTE"});
        metaFields.push({"name":"Lead_Source__c","label":"Lead Source"});
        metaFields.push({"name":"Owner","label":"Owner","type":"component","component":{"name":"ui:outputURL","attributes":{"label":"{{Owner.Name}}","value":"/{{Owner.Id}}","target":"_blank"}}});
        metaFields.push({"name":"Status__c","label":"Journey Status"});
        component.set("v.journeyMeta",metaFields);
    },
    getLatestJourney:function(component,query,onsuccess,onerror){
        component.find("utils").execute("c.getQueryData",{"query":query},function(result){
            onsuccess(result)
        },function(error){
            onerror(error)
        })
    },
    saveActivity:function(component, event, helper,disposeCall,isPause){
        var lstRecords = [];
        var objJourney = {};
        var task = {};
        task.Type = "Call";
        task.TaskSubtype = "Call";
        task.Status = "Completed";
        if(component.get("v.lead")){
            var query = "Select Id,Name,LastModifiedDate from Journey__c where Status__c='Started' AND Primary_Lead__c ='"+component.get("v.lead.Id")+"' ORDER BY LastModifiedDate desc limit 1";
            component.find("utils").showProcessing();
            helper.getLatestJourney(component,query,function(result){
                if(result && result.length){
                    objJourney.Id=result[0].Id;
                    objJourney.NMD_Next_Contact_Date__c = component.get("v.objActivity.NextActivityDate");
                    if(component.get("v.objActivity").hasOwnProperty("Next_Followup_Time__c") && component.get("v.objActivity.Next_Followup_Time__c")!=""){
                        objJourney.Next_Followup_Time__c = component.get("v.objActivity.Next_Followup_Time__c");
                    }  
                    lstRecords.push(objJourney);
                }
                if(component.get("v.recentActivity") && component.get("v.recentActivity").hasOwnProperty("Id")){
                    task.Id=component.get("v.recentActivity.Id");
                    task.Subject = component.get("v.recentActivity.Subject");
                }else{
                    task.Subject = component.get("v.objActivity.Subject");
                }
                if(component.get("v.objActivity").hasOwnProperty("Next_Followup_Time__c") && component.get("v.objActivity.Next_Followup_Time__c")!=""){
                    task.Next_Followup_Time__c = component.get("v.objActivity.Next_Followup_Time__c");
                }
                task.ActivityDate = component.get("v.objActivity.NextActivityDate");
                task.CallDisposition = component.get("v.objActivity.CallDisposition");
                task.Description = component.get("v.objActivity.Description");
                
                task.WhoId = component.get("v.lead.Id");
                task.sobjectType = 'Task';                
                lstRecords.push(task);
                var tempObj = {};
                tempObj = task;
                tempObj.PauseReason = component.get("v.objActivity.PauseReason");
                tempObj.Description=component.get("v.objActivity.Description");
                tempObj.CallDisposition=component.get("v.objActivity.CallDisposition");
                component.set("v.TempobjActivity",tempObj);
                component.find("utils").execute("c.saveRecords",{"records":lstRecords},function(response){
                    component.find("utils").hideProcessing();
                    component.set("v.objActivity",{});
                    component.set("v.recentActivity",undefined);
                    component.find("utils").showSuccess("Activity Created Successfully");
                    component.find("activityComponent").refreshComponent();
                    if(disposeCall){
                        helper.disposeCall(component,event,helper,isPause);
                    }
                },function(error){
                    component.find("utils").hideProcessing();
                    component.find("utils").showError(error);     
                }) 
            },function(error){
                component.find("utils").hideProcessing();
                component.find("utils").showError(error); 
            })
        }
        else if(component.get("v.contact")){
            var query = "Select Id,Name,LastModifiedDate  from Journey__c where Status__c='Started' AND Primary_Contact__c ='"+component.get("v.contact.Id")+"' ORDER BY LastModifiedDate desc limit 1";
            component.find("utils").showProcessing();
            helper.getLatestJourney(component,query,function(result){
                if(result && result.length){
                    objJourney.Id=result[0].Id;
                    objJourney.NMD_Next_Contact_Date__c = component.get("v.objActivity.NextActivityDate");
                    lstRecords.push(objJourney);
                }
                //v.objActivity.CallDisposition,v.objActivity.Subject
                if(objJourney && objJourney.hasOwnProperty("Id")){
                    task.WhatId = objJourney.Id;
                }
                if(component.get("v.recentActivity") && component.get("v.recentActivity").hasOwnProperty("Id")){
                    task.Id=component.get("v.recentActivity.Id");
                    task.Subject = component.get("v.recentActivity.Subject");
                }else{
                    task.Subject = component.get("v.objActivity.Subject");
                }
                
                task.ActivityDate = component.get("v.objActivity.NextActivityDate");
                task.Subject = component.get("v.objActivity.Subject");
                task.CallDisposition = component.get("v.objActivity.CallDisposition");
                task.Description = component.get("v.objActivity.Description");

                task.WhoId = component.get("v.contact.Id");
                task.sobjectType = 'Task';                
                lstRecords.push(task);
                var tempObj = {};
                tempObj = task;
                tempObj.PauseReason = component.get("v.objActivity.PauseReason");
                tempObj.Description=component.get("v.objActivity.Description");
                tempObj.CallDisposition=component.get("v.objActivity.CallDisposition");
                component.set("v.TempobjActivity",tempObj);
                component.find("utils").execute("c.saveRecords",{"records":lstRecords},function(response){
                    component.find("utils").hideProcessing();
                    component.set("v.objActivity",{});
                    component.set("v.recentActivity",undefined);
                    component.find("utils").showSuccess("Activity Created Successfully");
                    component.find("activityComponent").refreshComponent();
                    if(disposeCall){
                        helper.disposeCall(component,event,helper,isPause);
                    }
                },function(error){
                    component.find("utils").hideProcessing();
                    component.find("utils").showError(error);     
                }) 
            },function(error){
                component.find("utils").hideProcessing();
                component.find("utils").showError(error);  
            })
        }
    },
    checkUpdateOpenActivities:function(component,helper,lstRecords,onSuccess){
        if(lstRecords && lstRecords.length){
            var lstActivities = lstRecords[0].hasOwnProperty("OpenActivities")?lstRecords[0].OpenActivities:[];
            var objTaskToCreate = {};
            if(lstActivities && lstActivities.length){
                objTaskToCreate = lstActivities[0];
                if(objTaskToCreate.OwnerId!=component.get("v.userInfo.Id")){
                    objTaskToCreate.OwnerId=component.get("v.userInfo.Id");
                }
                objTaskToCreate.FastCall__Call_Id__c = component.find("utils").geturlParamByName("monitorUcid");
            }else{
                helper.createTaskObjFromUrl(component,helper,function(taskToCreate){
                    objTaskToCreate = taskToCreate;
                });
            }
            onSuccess(objTaskToCreate);
        }
    },
    createTaskObjFromUrl:function(component,helper,onSuccess){
        var objActivity = {};
        var task = {};
        var lstParameters = location.href.split("?")[1].split("&");
        if(lstParameters.length>1){
            for(var r in lstParameters){
                objActivity[lstParameters[r].split("=")[0]]=lstParameters[r].split("=")[1];
            }
            if(objActivity && objActivity!={}){
                task.Type = "Call";
                task.TaskSubtype = "Call";
                task.Status = "Open";
                task.Subject = objActivity.type;
                task.FastCall__Call_Id__c = objActivity.monitorUcid;
                task.WhoId = component.get("v.contact")?component.get("v.contact.Id"):component.get("v.lead.Id");
                task.sobjectType = 'Task';
                if(component.get("v.contact")){
                    if(component.get("v.journeys") && component.get("v.journeys").length > 0)
                    	task.WhatId = component.get("v.journeys")[0].Id;
                }
            }
        }
        onSuccess(task);
    },
    getMatchingPhone:function(component){
        //Method to get matching phone numbers
        var phoneNumber = component.get("v.phone");
        var str = "Phone like '%"+phoneNumber+"%' ";
        if(phoneNumber && phoneNumber!=""){
            //str +="OR Phone like '%"++"%'";
            if((phoneNumber.startsWith("+") || phoneNumber.startsWith(" ")) && phoneNumber.length == 13){
                var phone = "(" +phoneNumber.slice(3,6)+")"+" "+phoneNumber.slice(6,10)+"-"+phoneNumber.slice(10,13);
                str +="OR Phone like '%"+phone+"%' ";
                if(phoneNumber.startsWith("+")){
                    str +="OR Phone like '%"+phoneNumber.slice(1,13)+"%' ";
                    str +="OR Phone like '%"+phoneNumber.slice(3,13)+"%' ";
                }else if(phoneNumber.startsWith(" ")){
                    str +="OR Phone like '%"+"+"+phoneNumber.slice(1,13)+"%' ";
                    str +="OR Phone like '%"+phoneNumber.slice(3,13)+"%' ";
                }
            }
            if(phoneNumber.startsWith("91") && phoneNumber.length == 12){
                var phone = "(" +phoneNumber.slice(2,5)+")"+" "+phoneNumber.slice(5,8)+"-"+phoneNumber.slice(8,12);
                str +="OR Phone like '%"+"+"+phoneNumber+"%' "; //+919999999999
                str +="OR Phone like '%"+phoneNumber.slice(2,12)+"%' ";//9999999999
            }
            if(phoneNumber.length==10){
                var phone = "(" +phoneNumber.slice(0,3)+")"+" "+phoneNumber.slice(3,6)+"-"+phoneNumber.slice(6,10);
                str +="OR Phone like '%"+phone+"%' "; //(999) 99-99999
                str +="OR Phone like '%"+"+91"+phoneNumber+"%' "; //+919999999999
                str +="OR Phone like '%"+"91"+phoneNumber+"%' ";//9999999999
            }
            if(phoneNumber.startsWith("0") && phoneNumber.length==11){
                var phone = "(" +phoneNumber.slice(1,4)+")"+" "+phoneNumber.slice(4,7)+"-"+phoneNumber.slice(7,11);
                str +="OR Phone like '%"+phone+"%' "; //(999) 99-99999
                str +="OR Phone like '%"+"+91"+phoneNumber.slice(1,11)+"%' "; //+919999999999
                str +="OR Phone like '%"+"91"+phoneNumber.slice(1,11)+"%' ";//9999999999
                str +="OR Phone like '%"+phoneNumber.slice(1,11)+"%' ";
            }
        }
        return str;
    },
    setSettingData:function(component,onSuccess,onError){
        component.find("utils").execute("c.getQueryData",{"query":"Select Id,Data__c from Setting__c where Name='OzonetelDispositionSetting'"},function(result){
            if(result && result.length && result[0].Data__c!=""){
                onSuccess(JSON.parse(result[0].Data__c));
            }else{
                onError("No Dispositions are in the Setting, Please Check Setting Data");
            }
            
        },function(error){
            onError(error)
        })
        
    },
    disposeCall:function(component,event,helper,isPause){
        if(component.get("v.settingData").hasOwnProperty("apiInfo")){
            var mapApiInfo =  component.get("v.settingData")["apiInfo"];
            var url = mapApiInfo["disposeUrl"];
            var params = "";
            if(mapApiInfo && mapApiInfo.hasOwnProperty("params") && mapApiInfo["params"].length){
                for(var p in mapApiInfo["params"]){
                    if(params==""){
                        params =mapApiInfo["params"][p]+"="+component.find("utils").geturlParamByName(mapApiInfo["params"][p]);    
                    }else{
                        params +="&"+mapApiInfo["params"][p]+"="+component.find("utils").geturlParamByName(mapApiInfo["params"][p]);
                    }
                }
            } 
            if(isPause){
                params +='&pauseReason='+encodeURIComponent(component.get("v.TempobjActivity.PauseReason"));
                //params +='&pauseReason=Test';
                params += '&pauseAfterDispose=true';
            }
            params +='&comments='+encodeURIComponent((component.get("v.TempobjActivity.Description")?component.get("v.TempobjActivity.Description"):"Invalid Inquiry"));
            params +='&disposition='+encodeURIComponent((component.get("v.TempobjActivity.CallDisposition")?component.get("v.TempobjActivity.CallDisposition"):"Invalid Inquiry"));
            //params +='&comments=TestComments';
            //params +='&disposition=TestDisposition';
            params += mapApiInfo["additionalParams"];
            url +="?"+params;
            url += "&apiKey="+atob(mapApiInfo["apiKey"]);
            url = url.replace(/ /g,"%20");
            console.log("DISPOSE URL ----> "+url);
            component.find("utils").showProcessing();
            component.find("utils").execute("c.executeRest",{"method":"GET","endPointUrl":url,"headers":{},"body":""},function(response){
                if(response && JSON.parse(response).hasOwnProperty("status") && JSON.parse(response)["status"].toLowerCase() == "fail"){
                    component.find("utils").showError(JSON.parse(response)["details"]);
                    console.log("Error Response ----> "+response);
                }else{
                    console.log("Success Response ----> "+response);
                    component.find("utils").showSuccess(JSON.parse(response)["details"]);
                }
                component.find("utils").hideProcessing();
                
            },function(error){
                component.find("utils").hideProcessing();
                component.find("utils").showError(error);
            }); 
        }else{
            component.find("utils").hideProcessing();
            component.find("utils").showError("Unable to find Api-key to auto dispose call, Please dispose manually.");
        }
    },
    pauseCall:function(){
      // var url = https://cloudagent.in/OCCDV2/dispositionapi.html?customer=enzigma&agentID=Milan&pauseReason=TableTennisBreak&pauseAfterDispose=true&apiKey=KKc8c2cbd132a6d6d8d411671acca7a897&did=912067264763&comments=Testingcomments&ucid=39797222549062944&action=set&disposition=Test
    }
})