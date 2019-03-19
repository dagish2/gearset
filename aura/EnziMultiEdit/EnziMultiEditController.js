({
	doInit : function(component, event, helper) {
        component.find("utils").showProcessing();
        component.find("utils").execute("c.getAllFields",{"sObjectName":component.get("v.sObjectName")},function(response){
            var fields = JSON.parse(response);
            var mapFields = {};
            var lstFields = [];
            for(var f in fields.fields){
                mapFields[fields.fields[f].name] = fields.fields[f];
                lstFields.push(fields.fields[f]);
            }
            component.set("v.lstFields",lstFields);
            component.set("v.mapFields",mapFields);
            component.set("v.criterias",[{"criteria":"default","label":"Default"}]);
            component.find("utils").hideProcessing();
        },function(error){
            component.find("utils").showError(error);
            component.find("utils").hideProcessing();
        })
	},
    criteriaFieldChange:function(component, event, helper){
        var mapOperators = {"string":["equals","not equals","contains"],
                            "textarea":["equals","not equals","contains"],
                            "email":["equals","not equals","contains"],
                            "boolean":["equals","not equals"],
                            "integer":["equals","not equals","greater than","less than","greater than equal to","less than equal to","in between"],
                           	"decimal":["equals","not equals","greater than","less than","greater than equal to","less than equal to","in between"],
                           	"date":["equals","not equals","greater than","less than","greater than equal to","less than equal to","in between"],
                           	"datetime":["equals","not equals","greater than","less than","greater than equal to","less than equal to","in between"],
                           	"picklist":["equals","not equals"],
                           	"reference":["equals","not equals"]};
        component.set("v.criteriaOperators",mapOperators[component.get("v.mapFields")[event.currentTarget.value].type]);        
    },
    addCriteria:function(component, event, helper){
        var criteria = {};
        criteria.criteria = component.get("v.selectedCriteriaField")+":"+component.get("v.selectedCriteriaOperator")+":"+component.get("v.selectedCriteriaValue1")+":"+component.get("v.selectedCriteriaValue2");
        criteria.label = component.get("v.mapFields")[component.get("v.selectedCriteriaField")].label+(component.get("v.selectedCriteriaOperator")=="contains"?"":" is")+" "+component.get("v.selectedCriteriaOperator")+" "+component.get("v.selectedCriteriaValue1")+" "+(component.get("v.selectedCriteriaOperator")=="in between"?(" and "+component.get("v.selectedCriteriaValue2")):"");
        var lstCriterias = component.get("v.criterias");
        lstCriterias.push(criteria);
        component.set("v.criterias",lstCriterias);
    },
    deleteCriteria:function(component, event, helper){
        id = parseInt(event.currentTarget.id.split(":")[1]);
        var lstCriterias = component.get("v.criterias");
        lstCriterias.splice(id,1);
        component.set("v.criterias",lstCriterias);
    },
    addMappings:function(component, event, helper){
        var id = parseInt(event.currentTarget.id.split(":")[1]);
        var value = event.currentTarget.value;
        var lstCriterias = component.get("v.criterias");
        var criteria = lstCriterias[id];
        if(criteria.mappings==undefined){
       		criteria.mappings = [];
        }
        criteria.mappings.push({"field":component.get("v.mapFields")[value]});
        lstCriterias[id] = criteria;
        component.set("v.criterias",lstCriterias);
    },
    removeMappings:function(component, event, helper){
        var criteriaid = parseInt(event.currentTarget.id.split(":")[1]);
        var mappingid = parseInt(event.currentTarget.id.split(":")[2]);
        var lstCriterias = component.get("v.criterias");
       	lstCriterias[criteriaid].mappings.splice(mappingid,1);
        component.set("v.criterias",lstCriterias);
    },
    save:function(component, event, helper){
        component.find("utils").showProcessing();
        helper.getCriteriaData(component,function(records){
            var criterias = component.get("v.criterias");
            for(var record in records){
                for(var criteria in criterias){
                    if(helper.evaluateCriteria(records[record]),criterias[criteria].criteria){
                        for(var mapping in criterias[criteria].mappings){
                            records[record][criterias[criteria].mappings[mapping].field.name] = criterias[criteria].mappings[mapping].value;
                        }
                    }
                }
            }
            console.log(records);
            component.find("utils").execute("c.saveRecords",{"records":records},function(response){
            	component.find("utils").hideProcessing();
                component.find("utils").showSuccess("Records updated successfully.");
                setTimeout(function(){
                	component.find("multiEditModal").close();                              
                },3000)
            },function(error){
           		component.find("utils").hideProcessing();
                component.find("utils").showError(error);
            })           
        },function(error){
            component.find("utils").showError(error);
            component.find("utils").hideProcessing();
        })
    },
    cancel:function(component, event, helper){
        component.find("multiEditModal").close();
    }
})