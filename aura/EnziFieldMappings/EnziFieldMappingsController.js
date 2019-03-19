({
    doInit : function(component, event, helper) {
        helper.initialiseComponent(component,event,helper);
    },
    save : function(component, event, helper){
         component.find("utils").showConfirm("Are you sure ?",function(){
        component.find("utils").showProcessing();
        var mappedData = component.get("v.mappedData");
        var unmappedData = component.get("v.unmappedData");
        // var lstUnmappedFields = component.get("v.lstUnmappedFields");
        var Data = {};//data field of setting object.
        var setting= {};
        var map={};
        for(var data in mappedData)
        {
            if(mappedData[data]['fieldname'] && mappedData[data]['fieldname']!=""){
                map[mappedData[data]['field']] = mappedData[data]; 
                delete map[mappedData[data]['field']]['field'];
            }else{
                delete map[mappedData[data]['field']];
            }
        }
        for(var data in unmappedData)
        {
            if(unmappedData[data]['fieldname'] && unmappedData[data]['fieldname']!=""){
                map[unmappedData[data]['field']] = unmappedData[data]; 
                delete map[unmappedData[data]['field']]['field'];
            }
        }
        if(component.get("v.settingData") !=undefined || component.get("v.settingData") !=null ){
            Data['version'] = component.get("v.settingData")["version"];//for version
            Data['mappings'] = map;
            setting.Data__c = JSON.stringify(Data) ;
            setting.Id = component.get("v.settingId");
            component.find("utils").execute("c.saveRecord",{"record": setting},function(result){
                component.set("v.settingData",JSON.parse(setting.Data__c));
                helper.generateMappedData(component);
                helper.generateUnmappedData(component);
                component.find("utils").hideProcessing();
                component.find("utils").showSuccess("Record saved successfuly");
                helper.initialiseComponent(component,event,helper);
                
            },function(error){
                component.find("utils").showError(error);
                component.find("utils").hideProcessing();
            })   
           
        }
        else{
            component.find("utils").hideProcessing(); 
        }
         });  
    },
    cancel : function(component, event, helper){ 
        self.location="/"+component.get("v.settingId").substring(0,3);
    }
})