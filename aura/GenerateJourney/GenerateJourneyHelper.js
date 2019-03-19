({	/*created By : Shobhit Gahlot
    * Issue No : ST-1316 - improvement and conversion on page in angular to lightning
	*/
    sortObjectArray : function(json_object, key_to_sort_by,sortOrderAsc){
        if(sortOrderAsc){
            function sortByKey(a, b) {
                var x = a[key_to_sort_by];
                var y = b[key_to_sort_by];
                return ((x.toLowerCase() < y.toLowerCase()) ? -1 : ((x.toLowerCase() > y.toLowerCase()) ? 1 : 0));
            }
            json_object.sort(sortByKey);
        }else{
            function sortdesc(a, b) {
                var x = a[key_to_sort_by];
                var y = b[key_to_sort_by];
                return ((x.toLowerCase() > y.toLowerCase()) ? -1 : ((x.toLowerCase() < y.toLowerCase()) ? 1 : 0));
            }
            json_object.sort(sortdesc);
        }
        return json_object;
    },
    close : function(){
        self.location="/"+component.get("v.settingId").substring(0,3);
        
    },
    init : function(component, event, helper, settingId){
        
        if(settingId){
            component.find("utils").showProcessing();
            component.find("utils").execute("c.getJourneyUserQueue",{"settingId":settingId},function(response){
                component.find("utils").hideProcessing();
                //console.log(JSON.parse(response));
                var data = JSON.parse(response);
                if(data.settings != null){
                    var datasetting = JSON.parse(data.settings);
                    component.set("v.settings",data.settings);                    
                    component.set("v.settingsJSON",datasetting[0].Data__c);                                      
                }
                if(data.lstactiveUsers != null){
                    helper.listId(component, event, helper,data.lstactiveUsers,function(lstIds){
                        component.set("v.lstUserIds",lstIds);
                        data.lstactiveUsers.forEach(function(user){
                            user.generateJourney = true;
                        })
                    });
                    debugger;
                    component.set("v.lstSelectedUsers",data.lstactiveUsers);
                    component.set("v.lstSelectedUsersTemp",data.lstactiveUsers);
                }
                
                if(data.lstQueues != null){
                    helper.listId(component, event, helper,data.lstQueues,function(lstIds){
                        component.set("v.lstQueueIds",lstIds);
                        data.lstQueues.forEach(function(queue){
                            queue.generateJourney = true;
                        })
                    });
                    component.set("v.lstSelectedQueue",data.lstQueues);
                    component.set("v.lstSelectedQueueTemp",data.lstQueues);
                }                  
            },function(error){
                component.find("utils").showError('Setting Not Found.');
                component.find("utils").hideProcessing();
            })
        }
    },
    setMetaDataFields : function(component, event, helper){
        debugger;
        //Setting metaFields for Selected User
        var selectedUserTableColumns = [
            {"name":"generateJourney","label":"Generate Journey","type":"component","component":{"name":"c:EnziField","attributes":{"type":"boolean","hideLabel":true,"value":"{!generateJourney}","change":component.getReference("c.removeUser")}}},
            {"name":"Name","label":"Name","type":"string"},
            {"name":"Username","label":"Username","type":"email"},
            {"name":"Email","label":"Email","type":"email"}
        ];
        component.set("v.selectedUserTableColumns",selectedUserTableColumns);
        
        //Setting metaFields for unSelected User   ,"inlineStyle":"padding-left:60px;"
        var unSelectedUserTableColumns = [
            {"name":"generateJourney","label":"Generate Journey","type":"component","component":{"name":"c:EnziField","attributes":{"type":"boolean","hideLabel":true,"value":"{!generateJourney}","change":component.getReference("c.addUser")}}},
            {"name":"Name","label":"Name","type":"string"},
            {"name":"Username","label":"Username","type":"email"},
            {"name":"Email","label":"Email","type":"email"}
        ];
        component.set("v.unSelectedUserTableColumns",unSelectedUserTableColumns);
        
        //Setting metaFields for Selected Queue
        var selectedQueueTableColumns = [
            {"name":"generateJourney","label":"Generate Journey","type":"component","component":{"name":"c:EnziField","attributes":{"type":"boolean","hideLabel":true,"value":"{!generateJourney}","change":component.getReference("c.removeQueue")}}},
            {"name":"Name","label":"Queue Name","type":"string"}           						
        ];
        component.set("v.selectedQueueTableColumns",selectedQueueTableColumns);
        
        //Setting metaFields for unSelected Queue
        var unSelectedQueueTableColumns = [
            {"name":"generateJourney","label":"Generate Journey","type":"component","component":{"name":"c:EnziField","attributes":{"type":"boolean","hideLabel":true,"value":"{!generateJourney}","change":component.getReference("c.addQueue")}}},
            {"name":"Name","label":"Queue Name","type":"string"}           						
        ];
        component.set("v.unSelectedQueueTableColumns",unSelectedQueueTableColumns);
    },
    addUser: function(component, event, helper){
        component.find("utils").showProcessing();
        var lstSelectedUsers = JSON.parse(JSON.stringify(component.get("v.lstSelectedUsers")));
        var lstUnselectedUsers = JSON.parse(JSON.stringify(component.get("v.lstUnselectedUsers")));
        
        var lstSelectedUsersTemp = JSON.parse(JSON.stringify(component.get("v.lstSelectedUsersTemp")));
        var lstUnselectedUsersTemp = JSON.parse(JSON.stringify(component.get("v.lstUnselectedUsersTemp")));
        
        var obj = JSON.parse(event.currentTarget.getAttribute('data-value'));
        
        var index = lstUnselectedUsers.findIndex(item => item.Id==obj.Id);          
        //Getting the item from Unselected Users
        var objselectedUser = lstUnselectedUsers[index];
        objselectedUser.generateJourney = true;
        
        //removing the item from unselected users
        lstUnselectedUsers.splice(index,1);
        
        index = lstUnselectedUsersTemp.findIndex(item => item.Id==obj.Id);
        lstUnselectedUsersTemp.splice(index,1);
        //List after removing
        component.set("v.lstUnselectedUsers",helper.sortObjectArray(lstUnselectedUsers,'Name',true));
        component.set("v.lstUnselectedUsersTemp",helper.sortObjectArray(lstUnselectedUsersTemp,'Name',true));
        
        //Adding removed object to selected Users
        lstSelectedUsers.push(objselectedUser);
        lstSelectedUsersTemp.push(objselectedUser);
        component.set("v.lstSelectedUsers",helper.sortObjectArray(lstSelectedUsers,'Name',true));
        component.set("v.lstSelectedUsersTemp",helper.sortObjectArray(lstSelectedUsersTemp,'Name',true));
        helper.listId(component, event, helper,lstSelectedUsersTemp,function(lstUserIds){
            component.set("v.lstUserIds",lstUserIds);
        });
        component.find("utils").hideProcessing();
    },
    removeUser: function(component, event, helper){
        var lstSelectedUsers = JSON.parse(JSON.stringify(component.get("v.lstSelectedUsers")));
        var lstUnselectedUsers = JSON.parse(JSON.stringify(component.get("v.lstUnselectedUsers")));
        
        var lstSelectedUsersTemp = JSON.parse(JSON.stringify(component.get("v.lstSelectedUsersTemp")));
        var lstUnselectedUsersTemp = JSON.parse(JSON.stringify(component.get("v.lstUnselectedUsersTemp")));
        
        var obj = JSON.parse(event.currentTarget.getAttribute('data-value'));
        console.log('obj ::'+obj+'id ::'+obj.Id);
        var index = lstSelectedUsers.findIndex(item => item.Id==obj.Id);
        
        //Getting the item from selected User table
        var objUnselectedUser = lstSelectedUsers[index];
        
        objUnselectedUser.generateJourney = false;
        
        //removing the item from selected User table
        lstSelectedUsers.splice(index,1);
        
        index = lstSelectedUsersTemp.findIndex(item => item.Id==obj.Id);
        lstSelectedUsersTemp.splice(index,1);
        
        //List after removing
        component.set("v.lstSelectedUsers",helper.sortObjectArray(lstSelectedUsers,'Name',true));
        component.set("v.lstSelectedUsersTemp",helper.sortObjectArray(lstSelectedUsersTemp,'Name',true));
        
        //Adding removed object to unselected User table
        lstUnselectedUsers.push(objUnselectedUser);
        lstUnselectedUsersTemp.push(objUnselectedUser);
        helper.listId(component, event, helper,lstSelectedUsersTemp,function(lstUserIds){
            component.set("v.lstUserIds",lstUserIds);
        });
        component.set("v.lstUnselectedUsers",helper.sortObjectArray(lstUnselectedUsers,'Name',true));
        component.set("v.lstUnselectedUsersTemp",helper.sortObjectArray(lstUnselectedUsersTemp,'Name',true));
    },
    removeQueue: function(component, event, helper){
        var lstSelectedQueue = JSON.parse(JSON.stringify(component.get("v.lstSelectedQueue")));
        var lstUnSelectedQueue = JSON.parse(JSON.stringify(component.get("v.lstUnSelectedQueue")));
        
        var lstSelectedQueueTemp = JSON.parse(JSON.stringify(component.get("v.lstSelectedQueueTemp")));
        var lstUnSelectedQueueTemp = JSON.parse(JSON.stringify(component.get("v.lstUnSelectedQueueTemp")));
        
        var obj = JSON.parse(event.currentTarget.getAttribute('data-value'));
        console.log('obj ::'+obj+'id ::'+obj.Id);
        var index = lstSelectedQueue.findIndex(item => item.Id==obj.Id);
        
        //Getting the item from selected Queue table
        var objUnselectedQueue = lstSelectedQueue[index];
        
        objUnselectedQueue.generateJourney = false;
        
        //removing the item from selected Queue table
        lstSelectedQueue.splice(index,1);
        
        index = lstSelectedQueueTemp.findIndex(item => item.Id==obj.Id);
        lstSelectedQueueTemp.splice(index,1);
        
        //List after removing
        component.set("v.lstSelectedQueue",helper.sortObjectArray(lstSelectedQueue,'Name',true));
        component.set("v.lstSelectedQueueTemp",helper.sortObjectArray(lstSelectedQueueTemp,'Name',true));
        
        //Adding removed object to unselected Queue table
        lstUnSelectedQueue.push(objUnselectedQueue);
        lstUnSelectedQueueTemp.push(objUnselectedQueue);
        helper.listId(component, event, helper,lstSelectedQueueTemp,function(lstIds){
            component.set("v.lstQueueIds",lstIds);
        });       
        component.set("v.lstUnSelectedQueue",helper.sortObjectArray(lstUnSelectedQueue,'Name',true));
        component.set("v.lstUnSelectedQueueTemp",helper.sortObjectArray(lstUnSelectedQueueTemp,'Name',true));
    },
    addQueue: function(component, event, helper){
        component.find("utils").showProcessing();
        var lstSelectedQueue = JSON.parse(JSON.stringify(component.get("v.lstSelectedQueue")));
        var lstUnSelectedQueue = JSON.parse(JSON.stringify(component.get("v.lstUnSelectedQueue")));
        
        var lstSelectedQueueTemp = JSON.parse(JSON.stringify(component.get("v.lstSelectedQueueTemp")));
        var lstUnSelectedQueueTemp = JSON.parse(JSON.stringify(component.get("v.lstUnSelectedQueueTemp")));
        
        var obj = JSON.parse(event.currentTarget.getAttribute('data-value'));
        
        var index = lstUnSelectedQueue.findIndex(item => item.Id==obj.Id);          
        //Getting the item from Unselected Queue
        var objselectedQueue = lstUnSelectedQueue[index];
        objselectedQueue.generateJourney = true;
        
        //removing the item from unselected Queue
        lstUnSelectedQueue.splice(index,1);
        
        index = lstUnSelectedQueueTemp.findIndex(item => item.Id==obj.Id);
        lstUnSelectedQueueTemp.splice(index,1);
        //List after removing
        component.set("v.lstUnSelectedQueue",helper.sortObjectArray(lstUnSelectedQueue,'Name',true));
        component.set("v.lstUnSelectedQueueTemp",helper.sortObjectArray(lstUnSelectedQueueTemp,'Name',true));
        
        //Adding removed object to selected Queue
        lstSelectedQueue.push(objselectedQueue);
        lstSelectedQueueTemp.push(objselectedQueue);
        component.set("v.lstSelectedQueue",helper.sortObjectArray(lstSelectedQueue,'Name',true));
        component.set("v.lstSelectedQueueTemp",helper.sortObjectArray(lstSelectedQueueTemp,'Name',true));
        helper.listId(component, event, helper,lstSelectedQueueTemp,function(lstIds){
            component.set("v.lstQueueIds",lstIds);
        });
        component.find("utils").hideProcessing();
    },
    search : function(component, event, helper, onsuccess, onerror){
        this.filterData(component,component.get("v.lstSelectedUsersTemp"),component.get("v.selectedUserTableColumns"),component.get('v.keyword'),function(filteredRecords){
            component.set("v.lstSelectedUsers",filteredRecords);
            helper.filterData(component,component.get("v.lstSelectedQueueTemp"),component.get("v.selectedQueueTableColumns"),component.get('v.keyword'),function(filteredRecords){
                component.set("v.lstSelectedQueue",filteredRecords);
                var strQuery;
                var keyword = component.find("utils").addSlashes(component.get('v.keyword'));
                if (component.get("v.lstUserIds") != '')
                    strQuery = 'Select Name, Username from User where IsActive = true AND ( Name Like \'%' + keyword + '%\' Or Username Like \'%' + keyword + '%\' ) AND Id NOT IN (' + component.get("v.lstUserIds") + ') ORDER BY Name Asc NULLS LAST Limit 2000';
                else
                    strQuery = 'Select Name, Username from User where IsActive = true AND ( Name Like \'%' + keyword + '%\' Or Username Like \'%' + keyword + '%\' ) ORDER BY Name Asc NULLS LAST Limit 2000';
                if(keyword !=''){
                    component.find("utils").execute("c.getQueryData",{"query":strQuery},function(response){
                        component.set("v.lstUnselectedUsers",response);
                        var strQueueQuery;
                        if (component.get("v.lstQueueIds") != '')
                            strQueueQuery = 'Select Id, Name from Group where Type = \'Queue\' AND Name Like \'%' + keyword + '%\' AND Id NOT IN  (' + component.get("v.lstQueueIds") + ')ORDER BY Name Asc NULLS LAST Limit 2000';
                        else
                            strQueueQuery = 'Select Id, Name from Group where Type = \'Queue\' AND Name Like \'%' + keyword + '%\' ORDER BY Name Asc NULLS LAST Limit 2000';
                        component.find("utils").execute("c.getQueryData",{"query":strQueueQuery},function(response){
                            component.set("v.lstUnSelectedQueue",response);
                            if(component.get("v.lstSelectedUsers").length == 0 && component.get("v.lstUnselectedUsers").length == 0 && component.get("v.lstSelectedQueue").length == 0 && component.get("v.lstUnSelectedQueue").length == 0)
                                component.find("utils").showWarning('No Records Found.');
                            else{
                                if(component.get("v.lstSelectedUsers").length == 0 && component.get("v.lstUnselectedUsers").length == 0)
                                    component.find("utils").showWarning('No User Records Found.');
                                if(component.get("v.lstSelectedQueue").length == 0 && component.get("v.lstUnSelectedQueue").length == 0)
                                    component.find("utils").showWarning('No Queue Records Found.');
                            }
                            onsuccess();
                        },function(error){
                            onerror('Error In Processing Queue Records.')
                        });
                    },function(error){
                        onerror('Error In Processing User Records');
                    });
                }else{
                    component.set("v.lstUnselectedUsers",[]);
                    component.set("v.lstUnSelectedQueue",[]);
                    onsuccess();
                }
            });
        });
    },
    filterData : function(component,TempRecords,fields,keyword,onsuccess){
        this.getFilteredRecords(component,TempRecords,fields,keyword,onsuccess);      
    },
    getFilteredRecords : function(component,TempRecords,fieldsMeta,keyword,onsuccess){
        var filteredData = [];
        var data = TempRecords;
        var keyword = keyword;
        var fields = [];
        debugger;
        for(var i=0;i<fieldsMeta.length;i++){
            fields.push(fieldsMeta[i].name);
        }
        if( keyword && keyword!=''){
            filteredData = data.filter(function(record){
                for(var i=0;i<fields.length;i++){
                    if(record[fields[i]] && (record[fields[i]]+'').toLowerCase().includes(keyword.toLowerCase())){
                        return true;
                    }
                }
            })
        }else{
            filteredData = data;
        }
        debugger;
        onsuccess(filteredData);
    },
    generateSettingJSON : function(component, event, helper){
        
        var setting =  { "allowedUsers" : [], "allowedQueues":[] };
        var lstSelectedUsers = JSON.parse(JSON.stringify(component.get("v.lstSelectedUsersTemp")));
        var lstSelectedQueue = JSON.parse(JSON.stringify(component.get("v.lstSelectedQueueTemp")));
        var lstKeysToRemoveSelectedUsers = ["generateJourney","Name","Email","attributes"];
        var lstKeysToRemoveSelectedQueues = ["generateJourney","attributes"];
        this.removeKeysfromObjects(lstSelectedUsers,lstKeysToRemoveSelectedUsers,"Username","userName",function(users){
            setting.allowedUsers = helper.sortObjectArray(users,'userName',true);
        })
        this.removeKeysfromObjects(lstSelectedQueue,lstKeysToRemoveSelectedQueues,"Name","queueName",function(queues){
            setting.allowedQueues = helper.sortObjectArray(queues,'queueName',true);
        })
        console.log(JSON.stringify(setting));
        return setting;
    },
    listId : function(component, event, helper, list, onSuccess){
        
        var lstIds = '';
        var count = 0;
        list.forEach(function(record){
            count++;
            lstIds += ',\'' + record.Id + '\'';
        })
        console.log('list of ids count ids::'+count);
        if (lstIds != '')
            lstIds = lstIds.substr(1);
        onSuccess(lstIds);
    },
    removeKeysfromObjects:function(lstrecords,lstKeysToDelete,replaceKey,fromkey,onSuccess){
        
        if(lstrecords.length > 0){
            if(replaceKey != '' && fromkey != ''){
                lstrecords.forEach(function(record){
                    lstKeysToDelete.forEach(function(key){
                        if(record.hasOwnProperty(key)){
                            if(record.hasOwnProperty(replaceKey)){
                                record[fromkey] =record[replaceKey];
                                delete record[replaceKey];
                            }
                            delete record[key];
                        } 
                    })
                })
            }else{
                lstrecords.forEach(function(record){
                    lstKeysToDelete.forEach(function(key){
                        if(record.hasOwnProperty(key))
                            delete record[key];
                    })
                })
            } 
        }
        onSuccess(lstrecords) 
    }
})