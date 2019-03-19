({
    addComponent : function(component,cmpnt,attr) {
        var body = component.get("v.body");
        $A.createComponent(
            cmpnt,
            attr,
            function(cmp, status, errorMessage){
                body.push(cmp)
                component.set("v.body", body);
            }
        );
    },
    execute: function(component,method,params,onSuccess,onError){
        var action = component.get(method);
        action.setParams(params);
        action.setCallback(this,function(response){
            if(response.getState()=="SUCCESS"){
                var response = response.getReturnValue();
                if(response){
                    if(response.success){
                        onSuccess(response.data);
                    }else{
                        onError(response.message);
                    }
                }else{
                    onSuccess(response);
                }
            }else if(response.getState()=="ERROR"){
                var errors = response.getError();
                onError(errors[0].message);
            }
        });
        $A.enqueueAction(action);
    },
    getSessionId:function(component,onsuccess){
        var helper = this;
        if(component.get("v.sessionId")==undefined){
            helper.execute(component,"c.getSessionId",{},function(sessionId){
                component.set("v.sessionId",sessionId);
                onsuccess(sessionId);
            },function(error){
                console.log(error);
            })
        }else{
            onsuccess(component.get("v.sessionId"));
        }
    },
    createJob:function(component,operation,sObjectName,onsuccess){
        var helper = this;
        helper.getSessionId(component,function(sessionId){
            var client = new forcetk.Client();
            client.setSessionToken(sessionId);
            client.createJob('{"operation":"'+operation+'","object":"'+sObjectName+'","contentType":"JSON"}', function(response){
                onsuccess(response.id);
            });
        })
    },
    addBatch:function(component,jobId,data,onsuccess){
        var helper = this;
        helper.getSessionId(component,function(sessionId){
            var client = new forcetk.Client();
            client.setSessionToken(sessionId);
            client.addBatch(jobId,'application/json',data, function(response){
                onsuccess(response);
            });
        })
    },
    getJobResult:function(component,jobId,onsuccess){
        var helper = this;
    	helper.getSessionId(component,function(sessionId){
            var client = new forcetk.Client();
            client.setSessionToken(sessionId);
            client.getJobDetails(jobId, function(response){
                var operation = response.operation;
                if(response.numberBatchesQueued==0 && response.numberBatchesTotal==(response.numberBatchesCompleted+response.numberBatchesFailed)){
                    client.getJobBatchDetails(jobId,function(response){
                        var batchResult = [];
                        if(operation=="query"){
                            helper.getJobBatchQueryResult(component,response.batchInfo,0,batchResult,function(){
                                onsuccess(batchResult);
                            });
                        }else{
                            helper.getJobBatchResult(component,response.batchInfo,0,batchResult,function(){
                                onsuccess(batchResult);
                            });
                        }
                    })
                }else{
                    setTimeout(function(){
                        helper.getJobResult(component,jobId,onsuccess);
                    },5000)
                }
            });
        })
	},
    getJobBatchQueryResult:function(component,batches,index,batchData,onsuccess){
        var helper = this;
        if(index<batches.length){
            helper.getSessionId(component,function(sessionId){
                var client = new forcetk.Client();
                client.setSessionToken(sessionId);
                client.getBatchResult(batches[index].jobId,batches[index].id,true,function(response){
                    helper.getJobBatchResultData(component,batches[index].jobId,batches[index].id,response,0,batchData,function(){
                        helper.getJobBatchQueryResult(component,batches,index+1,batchData,onsuccess);
                    })
                })
            })
        }else{
            onsuccess();
        }
    },
    getJobBatchResultData:function(component,jobId,batchId,results,index,batchData,onsuccess){
        var helper = this;
        if(index<results.length){
            helper.getSessionId(component,function(sessionId){
                var client = new forcetk.Client();
                client.setSessionToken(sessionId);
                client.getBulkQueryResult(jobId,batchId,results[index],function(response){
                    for(var r in response){
                        for(var c in response[r]){
                            if(c=='attributes' || response[r][c]==undefined){
                                delete response[r][c];
                            }
                        }
                        batchData.push(response[r]);
                    }
                    helper.getJobBatchResultData(component,jobId,batchId,results,index+1,batchData,onsuccess);
                })
            })
        }else{
            onsuccess();
        }
    },
    getJobBatchResult:function(component,batches,index,batchData,onsuccess){
        var helper = this;
        if(index<batches.length){
            helper.getSessionId(component,function(sessionId){
                var client = new forcetk.Client();
                client.setSessionToken(sessionId);
                client.getBatchResult(batches[index].jobId,batches[index].id,true,function(response){
                    for(var r in response){
                        batchData.push(response[r]);
                    }
                    helper.getJobBatchResult(component,batches,index+1,batchData,onsuccess);
                })
            })
        }else{
            onsuccess();
        }
    },
    closeJob:function(component,jobId,onsuccess){
        var helper = this;
        helper.getSessionId(component,function(sessionId){
            /*var client = new forcetk.Client();
            client.setSessionToken(sessionId);
            client.closeJob(jobId,function(response){
                onsuccess();
            })*/
            onsuccess();
        });
    },
    closeTab:function(component,event,helper){
        if($A.get("e.force:closeQuickAction")!=undefined && $A.get("e.force:closeQuickAction").getSource() && $A.get("e.force:closeQuickAction").getSource().isValid()){
            $A.get("e.force:closeQuickAction").fire();                    
        }
        else if(sforce && sforce.console && sforce.console.isInConsole()){
            sforce.console.getEnclosingTabId(function(result){
                if(result.id!="null"){
                    sforce.console.closeTab(result.id);
                }else{
                    sforce.console.isInCustomConsoleComponent(function(result){
                        if(result.inCustomConsoleComponent){
                            sforce.console.isCustomConsoleComponentPoppedOut(function(result){
                                if(result.poppedOut){
                                   parent.close();
                                }else{
                                    sforce.console.setCustomConsoleComponentVisible(false);
                                }
                            });
                        }
                    });
                }
                
            })
        }else{
            window.close();
        }
    }
})