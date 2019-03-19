({
    //Generate Journey for Lead Source and Details Helper
    //Takes query as a input and return the query which can be pass in url
    makeQuery: function(strQuery){
        var query="";
        var queryService = "/services/data/v37.0/query/?q=";
        var tempQuery = strQuery.split(' ');
        for(var i=0;i<tempQuery.length;i++)
        {
            if(i<tempQuery.length-1)
                query += tempQuery[i] + "+";
            else if(i==tempQuery.length-1)
                query += tempQuery[i];
        }
        return queryService+query;
    },
    initialiseComponent:function(component,event,helper){
        component.find("utils").showProcessing();
        var strQuery = "SELECT Name,Data__c FROM Setting__c WHERE Id='"+component.get("v.settingId")+"'";
        component.find("utils").execute("c.getQueryData",{"query":strQuery},function(response){
            component.find("utils").hideProcessing();
            if(response && response.length >0){               
                var setting = response[0].Data__c;
                if(setting != '')
                {
                    var jsonSetting = JSON.parse(response[0].Data__c);   
                    component.set('v.settingJSON',jsonSetting);
                    component.set("v.mapLeadSource",helper.createdMapLeadSource(jsonSetting.LeadSource));
                    component.set("v.mapLeadSourceDetails",helper.createdMapLeadSourceDetails(jsonSetting.LeadSourceDetails));
                    helper.setAllData(component,event,helper);
                    // mapGenerateJourneyLeadSourceDetailsInfohelper.createMapLeadSourceDetails(component,event,helper);
                }
            }
        },function(error){
            console.log(error);
        })
    },
    setAllData:function(component,event,helper){
        //getting JSON Setting Map data for matching the selected and unselected lead source
        var mapLeadSource = component.get("v.mapLeadSource");
        var mapLeadSourceDetails = component.get("v.mapLeadSourceDetails");
        if(mapLeadSource !=undefined || mapLeadSource != {})
        {
            //Setting Query string and Setting Header to consume query service
            var strQueryLeadSource = 'Select LeadSource, Count(Lead_Source_Detail__c) From lead Where Lead_Source_Detail__c != null AND LeadSource!=null Group By LeadSource ORDER BY Count(Lead_Source_Detail__c) Desc NULLS LAST Limit 2000';
            var headers = {'Authorization':'Standard','Content-Type':'application/json;charset=UTF-8','Accept':'application/json'};
            
            //Query for Lead Source Information from salesforce
            component.find("utils").showProcessing();  
            component.find("utils").execute("c.executeRestQuery",{"setUrl":true,"method":"GET","endPointUrl":helper.makeQuery(strQueryLeadSource),"headers":headers,"body":''},
                                            function(response){                                               
                                                helper.filterLeadSourceData(JSON.parse(response).records,component,helper);
                                                // helper.filterLeadSourceDetailsData(JSON.parse(response).records,component,helper);
                                                component.find("utils").hideProcessing();
                                            }
                                            ,function(error){
                                                console.log(error);
                                            }) 
        }
        if(mapLeadSourceDetails !=undefined || mapLeadSourceDetails != {})
        {
            //Setting Query string and Setting Header to consume query service
            var strQueryLeadSourceDetails = 'Select Lead_Source_Detail__c, Count(LeadSource) from lead Where Lead_Source_Detail__c != null group by Lead_Source_Detail__c ORDER BY Count(LeadSource) Desc NULLS LAST Limit 2000';
            var headers = {'Authorization':'Standard','Content-Type':'application/json;charset=UTF-8','Accept':'application/json'};
            
            //Query for Lead Source Information from salesforce
            component.find("utils").showProcessing();  
            component.find("utils").execute("c.executeRestQuery",{"setUrl":true,"method":"GET","endPointUrl":helper.makeQuery(strQueryLeadSourceDetails),"headers":headers,"body":''},
                                            function(response){
                                                helper.filterLeadSourceDetailsData(JSON.parse(response).records,component,helper);
                                                component.find("utils").hideProcessing();
                                            }
                                            ,function(error){
                                                console.log(error);
                                            }) 
        }
    },
    createdMapLeadSource:function(leadSource){
        var mapLeadSource = {};
        for (var index=0; index<leadSource.length; index++){
            mapLeadSource[leadSource[index].name] = leadSource[index].OverrideLeadSoruce;
        }
        return mapLeadSource;
    },
    createdMapLeadSourceDetails:function(leadSourceDetails){      
        var mapLeadSourceDetails = {};
        for (var index=0; index<leadSourceDetails.length; index++){
            mapLeadSourceDetails[leadSourceDetails[index]] = true;
        }
        return mapLeadSourceDetails;
    },
    filterLeadSourceData:function(lstLeadSource,component,helper){
        component.find("utils").showProcessing();
        var JsonLeadSourceRecords = component.get('v.settingJSON')[0].LeadSource;
        var lstselectedLeadSource = [];
        var lstUnSelectedLeadSource = [];
        var mapPresentLeadSource = component.get("v.mapLeadSource");
        var mapCountLeadSource = helper.createdCountMapLeadSource(lstLeadSource);
        
        //Collecting JSON for Selected Lead Source
        //else part need to be changed to seperate records which have count 0
        for(var index = 0 ; index < JsonLeadSourceRecords.length ; index ++){
            if(mapCountLeadSource.hasOwnProperty(JsonLeadSourceRecords[index].name))
            {
                var leadSource = JsonLeadSourceRecords[index];
                leadSource.generateJourney = true;
                leadSource.expr0 = mapCountLeadSource[JsonLeadSourceRecords[index].name];
                lstselectedLeadSource.push(leadSource);
            }
            else{
                var leadSource = JsonLeadSourceRecords[index];
                leadSource.generateJourney = true;
                leadSource.expr0 = 0;
                lstselectedLeadSource.push(leadSource);
            }
        }
        
        for(var index = 0 ; index < lstLeadSource.length ; index++)
        {
            if(!mapPresentLeadSource.hasOwnProperty(lstLeadSource[index].LeadSource))
            {
                var leadsource = {};
                leadsource.name = lstLeadSource[index].LeadSource;
                leadsource.generateJourney = false;
                leadsource.OverrideLeadSoruce = false;
                leadsource.expr0 = lstLeadSource[index].expr0;
                lstUnSelectedLeadSource.push(leadsource);
            }   
        }
        component.set("v.lstselectedLeadSource",helper.sortObjectArray(lstselectedLeadSource,'name',true));
        component.set("v.lstUnSelectedLeadSource",helper.sortObjectArray(lstUnSelectedLeadSource,'name',true));
        component.set("v.lstTempSelectedLeadSource",helper.sortObjectArray(lstselectedLeadSource,'name',true));
        component.set("v.lstTempUnSelectedLeadSource",helper.sortObjectArray(lstUnSelectedLeadSource,'name',true));
        component.find("utils").hideProcessing();
    },
    filterLeadSourceDetailsData:function(lstLeadSourceDetails,component,helper){
        
        var JsonLeadSourceDetailsRecords = helper.removeDuplicates(component.get('v.settingJSON')[0].LeadSourceDetails);
        var mapPresentLeadSourceDetails = component.get("v.mapLeadSourceDetails");
        var mapCountLeadSourceDetails=helper.createdCountMapLeadSourceDetails(lstLeadSourceDetails);
        
        var lstselectedLeadSourceDetails = [];
        var lstUnSelectedLeadSourceDetails = [];
        
        
        JsonLeadSourceDetailsRecords.forEach(function(record){
            if(mapCountLeadSourceDetails.hasOwnProperty(record)){
                var leadDetails = {};
                leadDetails.generateJourney = true;
                leadDetails.Lead_Source_Detail__c = record;
                leadDetails.expr0 = mapCountLeadSourceDetails[record];
            }
            else{
                var leadDetails = {};
                leadDetails.generateJourney = true;
                leadDetails.Lead_Source_Detail__c = record;
                leadDetails.expr0 = 0;
            }
            lstselectedLeadSourceDetails.push(leadDetails);
        })
        
        //In Completed functionality, remaining is creating list of selected and un selected lead source details.
        lstLeadSourceDetails.forEach(function(record){
            if(!mapPresentLeadSourceDetails.hasOwnProperty(record.Lead_Source_Detail__c)){
                var leadDetails = {};
                leadDetails.generateJourney = false;
                leadDetails.Lead_Source_Detail__c = record.Lead_Source_Detail__c;
                leadDetails.expr0 = record.expr0;
                lstUnSelectedLeadSourceDetails.push(leadDetails);
            }
        })
        component.set("v.lstselectedLeadSourceDetails",helper.sortObjectArray(lstselectedLeadSourceDetails,'Lead_Source_Detail__c',true));
        component.set("v.lstUnSelectedLeadSourceDetails",helper.sortObjectArray(lstUnSelectedLeadSourceDetails,'Lead_Source_Detail__c',true));
        
        component.set("v.lstTempSelectedLeadSourceDetails",helper.sortObjectArray(lstselectedLeadSourceDetails,'Lead_Source_Detail__c',true));
        component.set("v.lstTempUnSelectedLeadSourceDetails",helper.sortObjectArray(lstUnSelectedLeadSourceDetails,'Lead_Source_Detail__c',true));
        
    },
    createdCountMapLeadSource :function(lstLeadSource){
        var mapCountLeadSource = {};
        lstLeadSource.forEach(function(leadSource){
            mapCountLeadSource[leadSource.LeadSource] = leadSource.expr0;
        })
        return mapCountLeadSource;
    },
    createdCountMapLeadSourceDetails :function(lstLeadSourceDetails){
        var mapCountLeadSourceDetails = {};
        lstLeadSourceDetails.forEach(function(record){
            mapCountLeadSourceDetails[record.Lead_Source_Detail__c] = record.expr0;
        })
        return mapCountLeadSourceDetails;
    },
    sortObjectArray : function(json_object, key_to_sort_by,sortOrderAsc){      
        if(sortOrderAsc){
            function sortByKey(a, b) {
                var x = a[key_to_sort_by];
                var y = b[key_to_sort_by];
                if(typeof(x) == "number" && typeof(y) == "number")
                    return ((x < y) ? -1 : ((x > y) ? 1 : 0));
                else
                    return ((x.toLowerCase() < y.toLowerCase()) ? -1 : ((x.toLowerCase() > y.toLowerCase()) ? 1 : 0));
            }
            json_object.sort(sortByKey);
        }else{
            function sortdesc(a, b) {
                var x = a[key_to_sort_by];
                var y = b[key_to_sort_by];
                if(typeof(x) == "number" && typeof(y) == "number")
                    return ((x > y) ? -1 : ((x < y) ? 1 : 0));
                else
                	return ((x.toLowerCase() > y.toLowerCase()) ? -1 : ((x.toLowerCase() < y.toLowerCase()) ? 1 : 0));
            }
            json_object.sort(sortdesc);
        }
        return json_object;
    },
    removeDuplicates : function (listOfString){
        if(listOfString.length > 0){
            var lstItems = [];
            listOfString.forEach(function(record){
                if(lstItems.length == 0)
                    lstItems.push(record);
                else
                    if(lstItems.indexOf(record) == -1)
                        lstItems.push(record);
            })
            return lstItems;
        }
    },
    getLeadSourceDetailsByLeadSource:function(leadSource,lstSelected,lstUnSelected,generateJourney,component,helper,onSuccess){
      var strQueryLeadSourceDetails = "Select Lead_Source_Detail__c, Count(LeadSource) from lead Where LeadSource ='"+leadSource+"' group by Lead_Source_Detail__c ORDER BY Count(LeadSource) Desc NULLS LAST Limit 2000";
        var headers = {'Authorization':'Standard','Content-Type':'application/json;charset=UTF-8','Accept':'application/json'};
        //Query for Lead Source Information from salesforce
        component.find("utils").showProcessing();  
        component.find("utils").execute("c.executeRestQuery",{"setUrl":true,"method":"GET","endPointUrl":helper.makeQuery(strQueryLeadSourceDetails),"headers":headers,"body":''},
                                        function(response){
                                            //console.log(response);
                                            component.find("utils").hideProcessing();
                                            helper.addToSelectOrUnselectLeadSourceDetails(JSON.parse(response).records,lstSelected,lstUnSelected,generateJourney,component,helper,function(lstSelectedLeadSourceDetails,lstUnSelectedLeadSourceDetails){
                                                onSuccess(lstSelectedLeadSourceDetails,lstUnSelectedLeadSourceDetails)  
                                            })
                                        }
                                        ,function(error){
                                            console.log(error);
                                        }) 
    },
    setMetafields:function(component,event,helper){
        //Setting metaFields for Selected LeadSources
        //"change":component.getReference("c.test") "varient":"toggle",
        var selectedLeadSourcefields = [
            {"name":"generateJourney","label":"Generate Journey","type":"component","sort":"false","component":{"name":"c:EnziField","attributes":{"type":"boolean","hideLabel":true,"value":"{!generateJourney}","change":component.getReference("c.removeLeadSource")}}},
            {"name":"name","label":"Lead Source","type":"string"},
            {"name":"expr0","label":"Count","type":"string"},
            {"name":"OverrideLeadSoruce","label":"Override Leadsource","type":"component","sort":"false","component":{"name":"c:EnziField","attributes":{"type":"boolean","hideLabel":true,"varient":"toggle","value":"{!OverrideLeadSoruce}"}}}
        ];
        component.set("v.selectedLeadSourcefields",selectedLeadSourcefields);
        
        //Setting metaFields for Un-Selected LeadSources
        var unSelectedLeadSourcefields = [
            {"name":"generateJourney","label":"Generate Journey","type":"component","sort":"false","component":{"name":"c:EnziField","attributes":{"type":"boolean","hideLabel":true,"value":"{!generateJourney}","change":component.getReference("c.addLeadSource")}}},
            {"name":"name","label":"Lead Source","type":"string"},
            {"name":"expr0","label":"Count","type":"string"}
        ];
        component.set("v.unSelectedLeadSourcefields",unSelectedLeadSourcefields);
        //{"generateJourney":true,"Lead_Source_Detail__c":"Book a tour form","expr0":0}
        var selectedLeadSourceDetailsfields = [
            {"name":"generateJourney","label":"Generate Journey","type":"component","sort":"false","component":{"name":"c:EnziField","attributes":{"type":"boolean","hideLabel":true,"value":"{!generateJourney}","change":component.getReference("c.removeLeadSourceDetail")}}},
            {"name":"Lead_Source_Detail__c","label":"Lead Source Details","type":"string"},
            {"name":"expr0","label":"Count","type":"string"}
        ];
        
        component.set("v.selectedLeadSourceDetailsfields",selectedLeadSourceDetailsfields);
        
        var unSelectedLeadSourceDetailsfields = [
            {"name":"generateJourney","label":"Generate Journey","type":"component","sort":"false","component":{"name":"c:EnziField","attributes":{"type":"boolean","hideLabel":true,"value":"{!generateJourney}","change":component.getReference("c.addLeadSourceDetail")}}},
            {"name":"Lead_Source_Detail__c","label":"Lead Source Details","type":"string"},
            {"name":"expr0","label":"Count","type":"string"}
        ];
        
        component.set("v.unSelectedLeadSourceDetailsfields",unSelectedLeadSourceDetailsfields);
    },
    filterData:function(component,TempRecords,fields,keyword,onsuccess){
        this.getFilteredRecords(component,TempRecords,fields,keyword,onsuccess);
    },
    getFilteredRecords:function(component,TempRecords,fieldsMeta,keyword,onsuccess){
        var filteredData = [];
        var data = TempRecords;
        var keyword = keyword;
        var fields = [];
        
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
        onsuccess(filteredData);
    },
    addLeadSource:function(component,event,helper){
        component.find("utils").showProcessing();
        var lstSelectedleadSource = JSON.parse(JSON.stringify(component.get("v.lstselectedLeadSource")));
        var lstUnSelectedLeadSource = JSON.parse(JSON.stringify(component.get("v.lstUnSelectedLeadSource")));
        var lstTempSelectedLeadSource = JSON.parse(JSON.stringify(component.get("v.lstTempSelectedLeadSource")));
        var lstTempUnSelectedLeadSource = JSON.parse(JSON.stringify(component.get("v.lstTempUnSelectedLeadSource")));
        var obj = JSON.parse(event.currentTarget.getAttribute('data-value'));
        helper.getLeadSourceDetailsByLeadSource(obj.name,component.get("v.lstTempUnSelectedLeadSourceDetails"),component.get("v.lstTempSelectedLeadSourceDetails"),true,component,helper,function(lstUnSelectedLeadSourceDetails,lstSelectedLeadSourceDetails){
            var index = lstUnSelectedLeadSource.findIndex(item => item.name==obj.name);          
            //Getting the item from selected lead source
            var objselectedLeadSource = lstUnSelectedLeadSource[index];
            objselectedLeadSource.generateJourney = true;
            objselectedLeadSource.OverrideLeadSoruce = false;
            //removing the item from selected lead source
            lstUnSelectedLeadSource.splice(index,1);
            
            index = lstTempUnSelectedLeadSource.findIndex(item => item.name==obj.name);
            lstTempUnSelectedLeadSource.splice(index,1);
            //List after removing
            component.set("v.lstUnSelectedLeadSource",helper.sortObjectArray(lstUnSelectedLeadSource,'name',true));
            component.set("v.lstTempUnSelectedLeadSource",helper.sortObjectArray(lstTempUnSelectedLeadSource,'name',true));
            
            //Adding removed object to unselected leadsource
            lstSelectedleadSource.push(objselectedLeadSource);
            lstTempSelectedLeadSource.push(objselectedLeadSource);
            component.set("v.lstselectedLeadSource",helper.sortObjectArray(lstSelectedleadSource,'name',true));
            component.set("v.lstTempSelectedLeadSource",helper.sortObjectArray(lstTempSelectedLeadSource,'name',true));
            component.set("v.lstTempSelectedLeadSourceDetails",helper.sortObjectArray(lstSelectedLeadSourceDetails,'Lead_Source_Detail__c',true));
            component.set("v.lstTempUnSelectedLeadSourceDetails",helper.sortObjectArray(lstUnSelectedLeadSourceDetails,'Lead_Source_Detail__c',true));
            component.set("v.lstselectedLeadSourceDetails",helper.sortObjectArray(lstSelectedLeadSourceDetails,'Lead_Source_Detail__c',true));
            component.set("v.lstUnSelectedLeadSourceDetails",helper.sortObjectArray(lstUnSelectedLeadSourceDetails,'Lead_Source_Detail__c',true));
            component.find("utils").hideProcessing();
            
            
        })
        
    },
    removeLeadSource:function(component,event,helper){      
        console.log('Remove Lead Source');
        var lstSelectedleadSource= JSON.parse(JSON.stringify(component.get("v.lstselectedLeadSource")));
        var lstUnSelectedLeadSource = JSON.parse(JSON.stringify(component.get("v.lstUnSelectedLeadSource")));
        
        var lstTempSelectedLeadSource = JSON.parse(JSON.stringify(component.get("v.lstTempSelectedLeadSource")));
        var lstTempUnSelectedLeadSource = JSON.parse(JSON.stringify(component.get("v.lstTempUnSelectedLeadSource")));
        
        var obj = JSON.parse(event.currentTarget.getAttribute('data-value'));
        //helper.getLeadSourceDetailsByLeadSource(obj.name,component,helper,function(lstSelectedLeadSourceDetails,lstUnSelectedLeadSourceDetails){
        helper.getLeadSourceDetailsByLeadSource(obj.name,component.get("v.lstTempSelectedLeadSourceDetails"),component.get("v.lstTempUnSelectedLeadSourceDetails"),false,component,helper,function(lstSelectedLeadSourceDetails,lstUnSelectedLeadSourceDetails){
            var index = lstSelectedleadSource.findIndex(item => item.name==obj.name);
            
            //Getting the item from selected lead source
            var objUnselectLeadSource = lstSelectedleadSource[index];
            
            objUnselectLeadSource.generateJourney = false;
            objUnselectLeadSource.OverrideLeadSoruce = false;
            
            //removing the item from selected lead source
            lstSelectedleadSource.splice(index,1);
            
            index = lstTempSelectedLeadSource.findIndex(item => item.name==obj.name);
            lstTempSelectedLeadSource.splice(index,1);
            
            //List after removing
            component.set("v.lstselectedLeadSource",helper.sortObjectArray(lstSelectedleadSource,'name',true));
            component.set("v.lstTempSelectedLeadSource",helper.sortObjectArray(lstTempSelectedLeadSource,'name',true));
            
            //Adding removed object to unselected leadsource
            lstUnSelectedLeadSource.push(objUnselectLeadSource);
            lstTempUnSelectedLeadSource.push(objUnselectLeadSource);
            
            component.set("v.lstUnSelectedLeadSource",helper.sortObjectArray(lstUnSelectedLeadSource,'name',true));
            component.set("v.lstTempUnSelectedLeadSource",helper.sortObjectArray(lstTempUnSelectedLeadSource,'name',true));
            component.set("v.lstTempSelectedLeadSourceDetails",helper.sortObjectArray(lstSelectedLeadSourceDetails,'Lead_Source_Detail__c',true));
            component.set("v.lstTempUnSelectedLeadSourceDetails",helper.sortObjectArray(lstUnSelectedLeadSourceDetails,'Lead_Source_Detail__c',true));
            component.set("v.lstselectedLeadSourceDetails",helper.sortObjectArray(lstSelectedLeadSourceDetails,'Lead_Source_Detail__c',true));
            component.set("v.lstUnSelectedLeadSourceDetails",helper.sortObjectArray(lstUnSelectedLeadSourceDetails,'Lead_Source_Detail__c',true));
        })
    },
    addLeadSourceDetails:function(component,event,helper){
        component.find("utils").showProcessing();
        var lstselectedLeadSourceDetails = JSON.parse(JSON.stringify(component.get("v.lstselectedLeadSourceDetails")));
        var lstUnSelectedLeadSourceDetails = JSON.parse(JSON.stringify(component.get("v.lstUnSelectedLeadSourceDetails")));
        var lstTempSelectedLeadSourceDetails = JSON.parse(JSON.stringify(component.get("v.lstTempSelectedLeadSourceDetails")));
        var lstTempUnSelectedLeadSourceDetails = JSON.parse(JSON.stringify(component.get("v.lstTempUnSelectedLeadSourceDetails")));
        var obj = JSON.parse(event.currentTarget.getAttribute('data-value'));
        var index = lstUnSelectedLeadSourceDetails.findIndex(item => item.Lead_Source_Detail__c==obj.Lead_Source_Detail__c);          
        //Getting the item from selected lead source
        var objselectedLeadSourceDetail = lstUnSelectedLeadSourceDetails[index];
        objselectedLeadSourceDetail.generateJourney = true;
        objselectedLeadSourceDetail.OverrideLeadSoruce = false;
        //removing the item from selected lead source
        lstUnSelectedLeadSourceDetails.splice(index,1);
        
        index = lstTempUnSelectedLeadSourceDetails.findIndex(item => item.Lead_Source_Detail__c==obj.Lead_Source_Detail__c);
        lstTempUnSelectedLeadSourceDetails.splice(index,1);
        //List after removing
        component.set("v.lstUnSelectedLeadSourceDetails",helper.sortObjectArray(lstUnSelectedLeadSourceDetails,'Lead_Source_Detail__c',true));
        component.set("v.lstTempUnSelectedLeadSourceDetails",helper.sortObjectArray(lstTempUnSelectedLeadSourceDetails,'Lead_Source_Detail__c',true));
        
        //Adding removed object to unselected leadsource Details
        lstselectedLeadSourceDetails.push(objselectedLeadSourceDetail);
        lstTempSelectedLeadSourceDetails.push(objselectedLeadSourceDetail);
        component.set("v.lstselectedLeadSourceDetails",helper.sortObjectArray(lstselectedLeadSourceDetails,'Lead_Source_Detail__c',true));
        component.set("v.lstTempSelectedLeadSourceDetails",helper.sortObjectArray(lstTempSelectedLeadSourceDetails,'Lead_Source_Detail__c',true));
        component.find("utils").hideProcessing();
    },
    removeLeadSourceSourceDetails:function(component,event,helper){        
        var lstselectedLeadSourceDetails= JSON.parse(JSON.stringify(component.get("v.lstselectedLeadSourceDetails")));
        var lstUnSelectedLeadSourceDetails = JSON.parse(JSON.stringify(component.get("v.lstUnSelectedLeadSourceDetails")));
        
        var lstTempSelectedLeadSourceDetails = JSON.parse(JSON.stringify(component.get("v.lstTempSelectedLeadSourceDetails")));
        var lstTempUnSelectedLeadSourceDetails = JSON.parse(JSON.stringify(component.get("v.lstTempUnSelectedLeadSourceDetails")));
        
        var obj = JSON.parse(event.currentTarget.getAttribute('data-value'));
        var index = lstselectedLeadSourceDetails.findIndex(item => item.Lead_Source_Detail__c==obj.Lead_Source_Detail__c);
        
        //Getting the item from selected lead source
        var objUnselectLeadSourceDetail = lstselectedLeadSourceDetails[index];
        
        objUnselectLeadSourceDetail.generateJourney = false;
        objUnselectLeadSourceDetail.OverrideLeadSoruce = false;
        
        //removing the item from selected lead source
        lstselectedLeadSourceDetails.splice(index,1);
        
        index = lstTempSelectedLeadSourceDetails.findIndex(item => item.Lead_Source_Detail__c==obj.Lead_Source_Detail__c);
        lstTempSelectedLeadSourceDetails.splice(index,1);
        
        //List after removing
        component.set("v.lstselectedLeadSourceDetails",helper.sortObjectArray(lstselectedLeadSourceDetails,'Lead_Source_Detail__c',true));
        component.set("v.lstTempSelectedLeadSourceDetails",helper.sortObjectArray(lstTempSelectedLeadSourceDetails,'Lead_Source_Detail__c',true));
        
        //Adding removed object to unselected leadsource
        lstUnSelectedLeadSourceDetails.push(objUnselectLeadSourceDetail);
        lstTempUnSelectedLeadSourceDetails.push(objUnselectLeadSourceDetail);
        
        component.set("v.lstUnSelectedLeadSourceDetails",helper.sortObjectArray(lstUnSelectedLeadSourceDetails,'Lead_Source_Detail__c',true));
        component.set("v.lstTempUnSelectedLeadSourceDetails",helper.sortObjectArray(lstTempUnSelectedLeadSourceDetails,'Lead_Source_Detail__c',true));
    },
    searchLeadSourceData:function(component){
        this.filterData(component,
                        component.get("v.lstTempSelectedLeadSource"),
                        component.get("v.selectedLeadSourcefields"),
                        component.get('v.keywordLeadSource'),
                        function(filteredRecords){
                            component.set("v.lstselectedLeadSource",filteredRecords);
                        })
        this.filterData(component,
                        component.get("v.lstTempUnSelectedLeadSource"),
                        component.get("v.selectedLeadSourcefields"),
                        component.get('v.keywordLeadSource'),
                        function(filteredRecords){
                            component.set("v.lstUnSelectedLeadSource",filteredRecords);
                        })
    },
    searchLeadSourceDetailsData:function(component){
        this.filterData(component,
                        component.get("v.lstTempSelectedLeadSourceDetails"),
                        component.get("v.selectedLeadSourceDetailsfields"),
                        component.get('v.keywordLeadSourceDetail'),
                        function(filteredRecords){
                            component.set("v.lstselectedLeadSourceDetails",filteredRecords);
                        })
        this.filterData(component,
                        component.get("v.lstTempUnSelectedLeadSourceDetails"),
                        component.get("v.unSelectedLeadSourceDetailsfields"),
                        component.get('v.keywordLeadSourceDetail'),
                        function(filteredRecords){
                            component.set("v.lstUnSelectedLeadSourceDetails",filteredRecords);
                        })
    },
    generateSettingJSON:function(component,event,helper){       
        var setting =  { "LeadSource" : [], "LeadSourceDetails":[] };
        var selectedLeadSources = JSON.parse(JSON.stringify(component.get("v.lstTempSelectedLeadSource")));
        var selectedLeadSourcesDetails = JSON.parse(JSON.stringify(component.get("v.lstTempSelectedLeadSourceDetails")));
        var lstKeysToRemove = ["generateJourney","expr0"];  
        this.removeKeysfromObjects(selectedLeadSources,lstKeysToRemove,function(leadSources){
            setting.LeadSource = helper.sortObjectArray(leadSources,'name',true);
        })
        this.createListForKey(selectedLeadSourcesDetails,"Lead_Source_Detail__c",function(leadSourceDetails){
            setting.LeadSourceDetails = leadSourceDetails.sort();
        })
        return setting;
        
    },
    removeKeysfromObjects:function(lstrecords,lstKeysToDelete,onSuccess){      
        if(lstrecords.length > 0){
            lstrecords.forEach(function(record){
                lstKeysToDelete.forEach(function(key){
                    if(record.hasOwnProperty(key))
                        delete record[key];
                })
            })
            onSuccess(lstrecords) 
        }
        
    },
    createListForKey:function(records,key,onSuccess){       
        var list = [];
        if(records.length>0){
            records.forEach(function(record){
                list.push(record[key]);
            })
            onSuccess(list);
        }   
    },
    closeWindow:function(component,event,helper){
        parent.postMessage('close',location.origin);    
        window.close();
    },
    save:function(component,event,helper){
        component.find("utils").showConfirm("Are you sure ?",function(){
            var setting = {};
            setting.Id = component.get("v.settingId");
            setting.Data__c = JSON.stringify(helper.generateSettingJSON(component,event,helper));
            //var settingData = this.generateSettingJSON(component,event,helper);
            if(setting){
                component.find("utils").showProcessing();
                component.find("utils").execute("c.saveRecord",{"record":setting},function(response){
                    component.set("v.settingRecord",setting);
                    component.find("utils").hideProcessing();
                    component.find("utils").showSuccess('Saved successfully.');
                },function(error){
                    component.find("utils").showError(error); 
                });
            }
        }); 
    },
    addToSelectOrUnselectLeadSourceDetails:function(lstLeadSourcesDetail,lstSelected,lstUnSelected,generateJourney,component,helper,onSuccess){
        //[{"attributes":{"type":"AggregateResult"},"Lead_Source_Detail__c":"FALSE","expr0":1}]
        var lstTempSelectedLeadSourceDetails = JSON.parse(JSON.stringify(lstSelected));
        var lstTempUnSelectedLeadSourceDetails = JSON.parse(JSON.stringify(lstUnSelected));
        if(lstLeadSourcesDetail.length >0){
            // var lstselectedLeadSourceDetails= JSON.parse(JSON.stringify(component.get("v.lstselectedLeadSourceDetails")));
            // var lstUnSelectedLeadSourceDetails = JSON.parse(JSON.stringify(component.get("v.lstUnSelectedLeadSourceDetails")));
            lstLeadSourcesDetail.forEach(function(leadSourceDetail){
                var index = lstTempSelectedLeadSourceDetails.findIndex(item => item.Lead_Source_Detail__c==leadSourceDetail.Lead_Source_Detail__c);
                if(index > -1){
                    var objLeadSourceDetail = lstTempSelectedLeadSourceDetails[index];
                    objLeadSourceDetail.generateJourney = generateJourney;
                    lstTempUnSelectedLeadSourceDetails.push(objLeadSourceDetail);
                    lstTempSelectedLeadSourceDetails.splice(index,1);
                }
            })
        }
        onSuccess(lstTempSelectedLeadSourceDetails,lstTempUnSelectedLeadSourceDetails);
    }
})