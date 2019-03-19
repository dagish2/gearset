({
	showProcessing : function(component, event, helper) {
		component.find("spinner").showProcessing();
	},
    hideProcessing : function(component, event, helper) { 
		component.find("spinner").hideProcessing();
	},
    showSuccess : function(component, event, helper) {
        var params = event.getParam('arguments');
		component.find("toaster").showSuccess(params.message);
	},
    showError : function(component, event, helper) {
        var params = event.getParam('arguments');
        if(params.setTimeout == undefined){
            params["setTimeout"] = true;
            params["timeout"] = 5000;
        }
        component.find("toaster").showError(params.message ,params.setTimeout ,params.timeout);
	},
    showWarning : function(component, event, helper) {
        var params = event.getParam('arguments');
        if(params.setTimeout == undefined){
            params["setTimeout"] = true;
            params["timeout"] = 5000;
        }
		component.find("toaster").showWarning(params.message ,params.setTimeout ,params.timeout);
	},
    showAlert:function(component, event, helper){
        var params = event.getParam('arguments');
        helper.addComponent(component,"c:EnziAlert",{"message":params.message});
    },
    showConfirm:function(component, event, helper){
        var params = event.getParam('arguments');
        var attributes = {"message":params.message,"confirm":params.confirm,"decline":params.decline}
        if(params.button){
            attributes["button"] = params.button;
        }
        if(params.name){
            attributes["name"] = params.name;
        }
        helper.addComponent(component,"c:EnziConfirm",attributes);
    },
    execute:function(component, event, helper){
        var params = event.getParam('arguments');
        helper.execute((params.component ? params.component : component),params.method,params.params,params.success,params.error);
    },
    addComponent:function(component, event, helper){
        var params = event.getParam('arguments');
        var body = component.get("v.body");
        helper.addComponent(component,params.component,params.attributes);
    },
    getIcons:function(component, event, helper){
        var params = event.getParam('arguments');
    	var icons = {"Account":"standard:account",
                     "Building__c":"custom:custom50",
                     "Building_Market__c":"custom:custom24",
                     "Building_Interest__c":"custom:custom61",
                     "Contact":"standard:contact",
                     "Contract":"standard:contract",
                     "Company":"standard:company",
                     "Case":"standard:case",
                     "Dashboard":"standard:dashboard",
                     "Document":"standard:document",
                     "Event":"standard:event",
                     "Journey__c":"custom:custom20",
                     "Kickbox_Verification__c":"custom:custom62",
                     "Lead":"standard:lead",
                     "Market__c":"custom:custom93",
                     "Note":"standard:note",
                     "Opportunity":"standard:opportunity",
                     "Opportunity_Reservable__c":"custom:custom76",
                     "Product":"standard:product",
                     "Pricebook":"standard:pricebook",
                     "Report":"standard:report",
                     "Reservable__c":"custom:custom87",
                     "Referral__c":"custom:custom15",
                     "Reservable_View__c":"custom:custom37",
                     "RecordType":"standard:quotes",
                     "Setting__c":"custom:custom67",
                     "Tour_Outcome__c":"custom:custom84",
                     "Task":"standard:task",
                     "Task__c":"standard:task",
                     "User":"standard:user",
                     "CombinedAttachment":"standard:file",
                     "CampaignMember":"standard:campaign_members",
                     "Product_Interested__c":"standard:product",
                     "AttachedContentNote":"standard:note",
                     "Product":"standard:product"};
        params.success(icons)
	},
    getCustomAction:function(component,event,helper){
        var params = event.getParam('arguments');
        var action = component.get("c.test");
       	window.open("/apex/LightningEval?recordId="+params.recordId+"&actionId="+params.actionId);
	},
    getBulkQuery:function(component,event,helper){
        var params = event.getParam('arguments');
        helper.createJob(component, 'query', params.sObjectName, function(jobId){
            helper.addBatch(component,jobId, params.query, function(batchId){
                helper.getJobResult(component, jobId, function(jobData){
                    helper.closeJob(component, jobId, function(){
                        params.success(jobData);
                    })
                })
            })
        })
    },
    insertBulkData:function(component, event, helper){
        var params = event.getParam('arguments');
        helper.createJob(component,'insert',params.sObjectName,function(jobId){
            helper.addBatch(component,jobId,JSON.stringify(params.records),function(batchId){
                helper.getJobResult(component,jobId,function(jobData){
                    helper.closeJob(component,jobId,function(){
                        params.success(jobData);
                    })
                })
            })
        })
    },
    updateBulkData:function(component,event,helper){
        var params = event.getParam('arguments');
        helper.createJob(component,'update',params.sObjectName,function(jobId){
            helper.addBatch(component,jobId,JSON.stringify(params.records),function(batchId){
                helper.getJobResult(component,jobId,function(jobData){
                    helper.closeJob(component,jobId,function(){
                        params.success(jobData);
                    })
                })
            })
        })
    },
    geturlParamByName : function(component,event,helper){
      var params = event.getParam('arguments');
      var name = params.name;
      var url = window.location.href;
      name = name.replace(/[\[\]]/g, "\\$&");
      var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
      results = regex.exec(url);
      if (!results) return null;
      if (!results[2]) return '';
      return decodeURIComponent(results[2].replace(/\+/g, " "));
    },
    redirectToUrl:function(component,event,helper){
        var params = event.getParam('arguments');
        var isBack = false;
        var openInNewTab;
        if(params.url == 'back'){
            params.url = document.referrer;
            isBack = true;
        }
        if(sforce){
            if(sforce.console && sforce.console.isInConsole()){
                openInNewTab = params.openInNewTabConsole!=undefined ? params.openInNewTabConsole :  params.openInNewTab;
                if(openInNewTab){
                    sforce.console.openPrimaryTab(null ,params.url,true,params.title,function(result){
                        if(!result.success){
                            helper.closeTab();
                            sforce.console.openPrimaryTab(null ,params.url,true,params.title);
                        }
                    });
                }else{
                    sforce.console.getFocusedPrimaryTabId(function(result){
                        if(!isBack){
                            if(result.id != "null"){
                                sforce.console.openPrimaryTab(result.id ,params.url,true,params.title,function(result){
                                    if(!result.success){
                                        helper.closeTab();
                                        sforce.console.openPrimaryTab(null ,params.url,true,params.title);
                                    }
                                });
                            }
                        }
                    })
                }
            }else if(sforce && sforce.one){
                if(isBack){
                    history.back();
                }else{
                    sforce.one.navigateToURL(params.url);
                }
            } else {
                if(isBack){
                    history.back();
                }else{
                    openInNewTab = params.openInNewTabClassic!=undefined ? params.openInNewTabClassic : params.openInNewTab;
                    if(openInNewTab)
                        window.open(params.url, '_blank');
                    else
                        location.assign(params.url);
                }
            }
        }else{
            location.assign(params.url);
        }
    },
    closeTab:function(component,event,helper){
        helper.closeTab(component, event, helper);
    },
    openTabByUrl:function(component,event,helper){
        var params = event.getParam('arguments');
        if(sforce && sforce.console){
            sforce.console.openPrimaryTab(null,params.url,true);
        }
    },
    openTabById:function(component,event,helper){
        var params = event.getParam('arguments');
        if(sforce && sforce.console){
            sforce.console.openPrimaryTab(params.id,null,true);
        }
    },
    setTitle:function(component,event,helper){     
        var params = event.getParam('arguments');
        if(params && params.title){
            component.set("v.tabTitle",params.title);
        }
        if(typeof(sforce) != "undefined" && sforce && sforce.console && sforce.console.isInConsole() && component.get("v.tabTitle")){
            sforce.console.setTabTitle(component.get("v.tabTitle"));
        }
    },
    closeConsoleTab:function(component,event,helper){
        component.find("spinner").showProcessing();
        var params = event.getParam('arguments');
        var consoleHelper = {};
        consoleHelper.Tab_Url__c = params.url;
        consoleHelper.Random_Text__c = helper.generateRandomText();
        helper.execute(component,"c.CreateConsoleHelper",{"helper":consoleHelper},function(response){
            component.find("spinner").hideProcessing();
        },function(error){
            component.find("spinner").hideProcessing();
        });
    },
    removeSpecialCharacters:function(component,event,helper){
        var params = event.getParam('arguments');
        var data = params.data;
        var response = data.replace(/\r?\n|\r/g,"");
        return response;
    },
    addSlashes:function(component, event, helper){
        var params = event.getParam('arguments');
        var keyword = params.keyword;
        if(keyword){
            keyword = keyword.split("\\").join("\\\\");
            keyword = keyword.split("'").join("\\'"); 
            return keyword.trim();
        }
        return keyword;        
    }
})