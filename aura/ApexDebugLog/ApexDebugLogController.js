({
    doInit : function(component, event, helper) {
        var describedFields = [];
        describedFields.push({"fieldName": "Id", "label" : "LOG Name", "type" : "text","sortable": true ,type:"url",typeAttributes:{ label: { fieldName : 'Name'}}});
        describedFields.push({"fieldName": "Status__c", "label" : "Status", "type" : "text","sortable": true});
        describedFields.push({"fieldName": "Estimated_Fix__c", "label" : "Estimated Fix", "type" : "text","sortable": true});
        describedFields.push({"fieldName": "Exception_Category__c", "label" : "Exception Category", "type" : "text","sortable": true});
        describedFields.push({"fieldName": "Apex_Class__c", "label" : "Class", "type" : "text","sortable": true});
        describedFields.push({"fieldName": "Method__c", "label" : "Method", "type" : "text","sortable": true});
        describedFields.push({"fieldName": "Message__c", "label" : "Message", "type" : "text","sortable": true});
        describedFields.push({"fieldName": "Stack_Trace__c", "label" : "Stack Trace", "type" : "text","sortable": true});
        describedFields.push({"fieldName": "Owner.Name", "label" : "Owner", "type" : "text","sortable": true});
        component.set("v.describedFields",describedFields);
        var endDate = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        component.set('v.endDate', endDate);
        var result = new Date();
        result.setDate(result.getDate() - 15);  
        var startDate = $A.localizationService.formatDate(result, "YYYY-MM-DD");
        component.set('v.startDate', startDate);
        component.set('v.startTime','00:00:00.000');
        component.set('v.endTime','00:15:00.000');
        var lstFeildName = ["Estimated_Fix__c","Exception_Category__c","Status__c"];
        component.find("utils").execute("c.getFieldsMetadata",{"sObjectName":"Apex_Debug_Log__c","fields":lstFeildName},function(response){
            var values = JSON.parse(response);
            component.set('v.estimatedfix',values.Estimated_Fix__c.picklistValues);
            component.set('v.exceptioncategory',values.Exception_Category__c.picklistValues);
            component.set('v.status',values.Status__c.picklistValues);
        },function(error){
            component.find("utils").showError(error);
        })
    },
    getLogs:function(component, event, helper){
        component.find("utils").showProcessing();
        component.set("v.recordsErrorMessage",'');
        var obj = component.get('v.objLog');
        var startTime = component.get('v.startTime');
        var endTime = component.get('v.endTime');
        var startDate = component.get('v.startDate');
        var endDate = component.get('v.endDate');
        helper.getLogData(component, obj, startDate, endDate , startTime, endTime, event, helper);
    },
    doneRendering : function(component, event, helper) {
        var table = document.getElementById("dataTable");
        if(table){
            table.scrollIntoView({ block: 'start',  behavior: 'smooth' });
        }
    },
    UpdateRecord: function(component, event, helper) {
        var record= component.get('v.selectedRecord')[0];
        if(record){
            component.set("v.objupdate.estimatedfix",record.Estimated_Fix__c);
            component.set("v.objupdate.exceptioncategory",record.Exception_Category__c);
            component.set("v.objupdate.status",record.Status__c);
            component.set("v.objupdate.resolutionstepsanddetails",record.Resolution_Steps_and_Details__c);
            component.set("v.objupdate.findingsandobservations",record.Notes_and_Comments__c);
            component.find("UpdateRecordModel").showModal();
        }
    },
    closeupdateModal:function(component, event, helper){
        helper.clearLogFields(component, event, helper);
        component.find("UpdateRecordModel").close();
    },
    UpdateNewRecord:function(component, event, helper){
        component.find("utils").showProcessing();
        var objupdate = component.get('v.objupdate');
        var record= component.get('v.selectedRecord');
        var lstOfSelectedRecord = [];
        for(var rec in record){
            lstOfSelectedRecord.push(record[rec].Id);
        }
        helper.updateNewRecord(component, objupdate, lstOfSelectedRecord, event, helper); 
        component.find("UpdateRecordModel").close();
        helper.advancesSearchFeilds(component, event, helper);
    }
   
})