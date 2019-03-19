({
    saveTourCloseHour : function(component, onsuccess, onerror) {
        let objTourClosedHour = component.get("v.record");
        
        if(component.get("v.isClone")){
            var objTourClone = new Object();            
            objTourClone["Tour_Schedule__c"] = objTourClosedHour.Tour_Schedule__c;
            objTourClone["Start_Time__c"] = objTourClosedHour.Start_Time__c;
            objTourClone["End_Time__c"] = objTourClosedHour.End_Time__c;
            objTourClone["Building__c"] = objTourClosedHour.Building__c;
            objTourClone["Tour_Schedule__c"] = objTourClosedHour.Tour_Schedule__c;
            objTourClone["Date__c"] = objTourClosedHour.Date__c;
            objTourClone["Weekday__c"] = objTourClosedHour.Weekday__c;
            component.set("v.record", objTourClone);
            objTourClosedHour = component.get("v.record");
        }
        if(!objTourClosedHour.Id){
            objTourClosedHour["sobjectType"] = "Tour_Closed_Hour__c";
        }  
        component.find("utils").execute("c.saveRecord", {"record": objTourClosedHour}, function(response){
            let saveResult = JSON.parse(response);
            component.set("v.recordId", saveResult["id"]);
            component.find("utils").showSuccess("Tour Closed Hours is saved succesfully.");
            if(component.get("v.isClone")){
                component.set("v.isClone",false);
            }                        
            component.find("utils").hideProcessing();
            onsuccess();
        },function(error){
            component.find("utils").hideProcessing();            
            component.find("utils").showError(error);
        });
        
    },
    getTourStartTimeMeata : function(component, helper, onsuccess){ 
        component.find("utils").execute("c.getFieldMetadata", {"sObjectName": "Tour_closed_hour__c", "fieldName": "Start_Time__c"}, function(fieldMetadata){
            let lstPicklistValues = JSON.parse(fieldMetadata).picklistValues;
            let picklistMetadata = [];
            lstPicklistValues.forEach(function(lstPicklistValue){
                if(lstPicklistValue.active && lstPicklistValue.value)
                    picklistMetadata.push(lstPicklistValue.value);
            });
            component.set("v.picklistMetadata", picklistMetadata);
            helper.checkUserPermission(component, function(isAllowed){
                component.set("v.isAllowed", isAllowed);
                onsuccess();
            });           
        },function(error){
            component.find("utils").hideProcessing();            
            component.find("utils").showError(error);
        });
    },
    validateEndTime : function(component){
        let record = component.get("v.record");
        let picklistMetadata = component.get("v.picklistMetadata");
        if(!record.Start_Time__c && !record.End_Time__c){
            return true;
        }else if(!record.Start_Time__c || !record.End_Time__c){
            return false;
        }else if(picklistMetadata.indexOf(record.Start_Time__c) < picklistMetadata.indexOf(record.End_Time__c)){
            return true;
        }
        return false;
    },
    checkUserPermission : function(component, onSuccess){        
        let isAllowed = false;
        let mode = component.get("v.mode");
        let userAccess = component.get("v.userAccess");
        if(userAccess.hasEditAccess && mode == "EDIT"){
            isAllowed = true;
        } else if(userAccess.hasReadAccess && mode == "VIEW"){
            isAllowed = true;
        } else if(userAccess.hasDeleteAccess && mode == "EDIT"){
            isAllowed = true;
        }
        onSuccess(isAllowed);
    },
    editTourHour : function(component, event){
        if(component.get("v.userAccess.hasEditAccess")){
            component.set("v.mode", "EDIT");
        } else {
         	component.set("v.isAllowed", false);
        } 
    }
})