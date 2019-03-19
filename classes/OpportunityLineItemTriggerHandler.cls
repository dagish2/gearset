/************************************************************************************************************************************
    Author 		: 	Pragalbha Mahajan
    Description : 	This class contains the business logic of OpportunityLineItem Trigger.
    History		:
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE				AUTHOR					DETAIL
	1			08 March 2018		Pragalbha Mahajan     	Initial Development	 
**************************************************************************************************************************************/
public class OpportunityLineItemTriggerHandler extends ITriggerHandler{
    public OpportunityLineItemTriggerHandler(){
        super('OpportunityLineItem');
    }
    
    public override void BeforeInsert(List<SObject> listNewItems){
        if(TriggerSettings.mappedField.OpportunityLineItem_PopulateProductFieldsOnLineItems){            
            OpportunityLineItemTriggerHandler.populateProductFieldsOnLineItems(listNewItems, null, null, null);              
        }
        if(TriggerSettings.mappedField.OpportunityLineItem_UpdateBuildingFromGeography){             
            OpportunityLineItemTriggerHandler.updateBuildingFromGeography(listNewItems, null, null, null);            
        }
        if(TriggerSettings.mappedField.OpportunityLineItem_UpdateBuildingUUID){            
            OpportunityLineItemTriggerHandler.UpdateBuildingUUID((List<OpportunityLineItem>)listNewItems, null, null, null);             
        }
    }
    
    public override void BeforeUpdate(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems){
        if(TriggerSettings.mappedField.OpportunityLineItem_PopulateProductFieldsOnLineItems){            
            OpportunityLineItemTriggerHandler.populateProductFieldsOnLineItems(listNewItems, mapNewItems, listOldItems, mapOldItems);            
        }
        if(TriggerSettings.mappedField.OpportunityLineItem_UpdateBuildingFromGeography){            
            OpportunityLineItemTriggerHandler.updateBuildingFromGeography(listNewItems, mapNewItems, listOldItems, mapOldItems);            
        }
        if(TriggerSettings.mappedField.OpportunityLineItem_UpdateBuildingUUID){            
            OpportunityLineItemTriggerHandler.UpdateBuildingUUID((List<OpportunityLineItem>)listNewItems, (Map<Id,OpportunityLineItem>)mapNewItems, (List<OpportunityLineItem>)listOldItems, (Map<Id,OpportunityLineItem>)mapOldItems);            
        }
    }
    
    /************************************************************************************************************************************
        Author 				: 	Pragalbha Mahajan
        Description 		: 	This method overrides after insert method from ITriggerHander which will control the execution flow.
        Created Date		:	08 March 2018
	**************************************************************************************************************************************/
    public override void AfterInsert(List<SObject> listNewItems, Map<Id, SObject> mapNewItems){
        if(TriggerSettings.mappedField.OpportunityLineItem_UpdateOpportunityType){            
            OpportunityLineItemTriggerHandler.updateOpportunityType(listNewItems, mapNewItems, null, null);            
        }
    }
    
    /************************************************************************************************************************************
        Author 				: 	Pragalbha Mahajan
        Description 		: 	This method overrides after update method from ITriggerHander which will control the execution flow.
        Created Date		:	08 March 2018
	**************************************************************************************************************************************/
    public override void AfterUpdate(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems){        
        if(TriggerSettings.mappedField.OpportunityLineItem_UpdateOpportunityType){            
            OpportunityLineItemTriggerHandler.updateOpportunityType(listNewItems,mapNewItems,listOldItems,(Map<Id,OpportunityLineItem>)mapOldItems);            
        }
    } 
    /************************************************************************************************************************************
        Author 				: 	Pragalbha Mahajan
        Description 		: 	This method overrides after delete method from ITriggerHander which will control the execution flow.
        Created Date		:	08 March 2018
	**************************************************************************************************************************************/
    public override void AfterDelete(List<SObject> listOldItems, Map<Id, SObject> mapOldItems){
        if(TriggerSettings.mappedField.OpportunityLineItem_UpdateOpportunityType){            
            OpportunityLineItemTriggerHandler.updateOpportunityType(null,null,listOldItems,(Map<Id,OpportunityLineItem>)mapOldItems);            
        }
    }
    /************************************************************************************************************************************
    Author 				: 	Pragalbha Mahajan
    Description 		: 	This method is used to update Opportunity type according to Product Category. 
    Issue No.			:	ST-2041
	Created Date		:	08 March 2018
    **************************************************************************************************************************************/ 
    public static void updateOpportunityType(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, OpportunityLineItem> mapOldItems){
        set<Id> setOpportunityId = new set<Id>();
        for(OpportunityLineItem objOppLineItem: listNewItems != null ? (List<OpportunityLineItem>)listNewItems : (List<OpportunityLineItem>)listOldItems ){
            if(Trigger.isInsert || Trigger.isDelete || (Trigger.isUpdate && objOppLineItem.Family__c != mapOldItems.get(objOppLineItem.Id).Family__c)){
                setOpportunityId.add(objOppLineItem.OpportunityId);
            }
        }
        Debug.Log('setOpportunityId---'+setOpportunityId);
        List<Opportunity> lstOpportunityToUpdate = new List<Opportunity>();
        if(setOpportunityId.size()>0){
            set<string> setOppLineItemFamily;
            for(Opportunity oppRec :[SELECT Id,Type__c,(SELECT OpportunityId,Quantity,Name,ProductCode,Family__c,Product_Category__c from OpportunityLineItems) FROM Opportunity WHERE Id IN: setOpportunityId]){
                setOppLineItemFamily = new set<string>();
                for(OpportunityLineItem oppLineItemRec : oppRec.OpportunityLineItems){
                     Debug.Log('setOppLineItemFamily---'+setOppLineItemFamily);
                    if(oppLineItemRec.Family__c != null){
                        setOppLineItemFamily.add(oppLineItemRec.Family__c);
                    }
                }
                if(setOppLineItemFamily.size()>1){
                    if(oppRec.Type__c != 'Mixed'){
                        lstOpportunityToUpdate.add(new Opportunity(Id=oppRec.Id,Type__c = 'Mixed'));
                    }
                }else if(setOppLineItemFamily.size()==1){
                    String type = (new list<string>(setOppLineItemFamily))[0];
                    if(oppRec.Type__c != type){
                        lstOpportunityToUpdate.add(new Opportunity(Id=oppRec.Id,Type__c = type));   
                    }
                }else if(setOppLineItemFamily.size()==0){
                    lstOpportunityToUpdate.add(new Opportunity(Id=oppRec.Id,Type__c = null));
                } 
            }
        }
        if(lstOpportunityToUpdate.size() > 0){
            update lstOpportunityToUpdate;
        }
       
    }
	
    /************************************************************************************************************************************
    Author 				: 	Samadhan kadam
    Description 		: 	This method is used to map the field from product object to opportunity line Item at the time of Opportunity Line Item 
							create and update.we map only those field which are present in the FieldMappings:Product2ToOpportunityLineItem salses console setting.
    Issue No.			:	ST-1718
    **************************************************************************************************************************************/ 
    
    public static Settings.FieldMappings ProductToOpportunityLineItem() {
        Settings.FieldMappings product2ToOpportunityLineItemMappings = new Settings.FieldMappings();
        product2ToOpportunityLineItemMappings.version = 1;
        product2ToOpportunityLineItemMappings.mappings = new Map<String, Settings.MappedField>();
        product2ToOpportunityLineItemMappings.mappings.put('ProductCode__c', new Settings.MappedField('ProductCode'));
        return product2ToOpportunityLineItemMappings;
    }
    
    public static void populateProductFieldsOnLineItems(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems){
      
        List<Product2> lstproduct = new List<Product2>();
        Set<Id> setProductIds = new Set<Id>();
        Settings.FieldMappings mapProduct2ToOpportunityLineItem = Settings.getFieldMappings('Product2ToOpportunityLineItem');
        Debug.log('mapProduct2ToOpportunityLineItem ::'+mapProduct2ToOpportunityLineItem);
        if( mapProduct2ToOpportunityLineItem == null) mapProduct2ToOpportunityLineItem = ProductToOpportunityLineItem();
        Set<String> setProductFields = new Set<String>();
        for(Settings.MappedField field : mapProduct2ToOpportunityLineItem.mappings.values()){
            setProductFields.add(field.fieldname);
        }
        debug.Log('setProductFields: '+setProductFields);
        Map<Id,OpportunityLineItem> mapOldLineItems;
        Map<Id,OpportunityLineItem> mapNewLineItems;
        if(Trigger.isUpdate){
            mapOldLineItems = (Map<Id,OpportunityLineItem>) mapOldItems;
            mapNewLineItems = (Map<Id,OpportunityLineItem>) mapNewItems;
        }
        
        for(OpportunityLineItem objOppLineItem: (List<OpportunityLineItem>)listNewItems){
            for(String field : mapProduct2ToOpportunityLineItem.mappings.keySet()){
                if((Trigger.isInsert && objOppLineItem.get(field) == null) ||(Trigger.isUpdate  && mapOldLineItems.get(objOppLineItem.Id).get(field) != mapNewLineItems.get(objOppLineItem.Id).get(field))){
                    setProductIds.add(objOppLineItem.Product2Id);
                }
            }   
        }
        debug.Log('setProductIds: '+setProductIds);
        if(setProductIds.size() > 0){
            List<String> lstProductFields = new List<String>();
            setProductFields.remove(null);
            lstProductFields.addAll(setProductFields);                 
            lstproduct =(List<Product2>) Database.Query('Select Id, ' + String.join(lstProductFields, ',') + ' From Product2 Where Id In : setProductIds');
           
            Map<Id,Product2> mapIdProduct = new Map<Id,Product2>(lstproduct);
            for(OpportunityLineItem objOppLineItem: (List<OpportunityLineItem>)listNewItems){
                for(String field : mapProduct2ToOpportunityLineItem.mappings.keySet()){
                    Settings.MappedField mappedField = mapProduct2ToOpportunityLineItem.mappings.get(field);
                    if(objOppLineItem.get(field) == null || Trigger.isUpdate){
                        if(mappedField.isvalue == true)
                            objOppLineItem.put(field, mappedField.value);
                        else if(objOppLineItem.Product2Id != null && mapIdProduct.containsKey(objOppLineItem.Product2Id) && mapIdProduct.get(objOppLineItem.Product2Id).get(mappedField.fieldname) != null){
                            objOppLineItem.put(field, mapIdProduct.get(objOppLineItem.Product2Id).get(mappedField.fieldname));   
                        }                        
                    }
                }
            }  
        }     
    }
	/************************************************************************************************************************************
    Author 				: 	Priyanka Ambre
    Description 		: 	This method will store Nearest Building to that Geography on Opportunity Product after entering Geography and 
							if no Building is present on Opportunity. 
    Issue No.			:	ST-2317
	Created Date        :   04 April 2018
    **************************************************************************************************************************************/ 
    public static void updateBuildingFromGeography(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems){
        try{
            Debug.log('listNewItems---'+listNewItems);
            Set<Id> setGeographyIds = new Set<Id>();
            Map<Id, Id> mapGeographyRelatedBuildingIds = new Map<Id, Id>();            
            Map<Id, OpportunityLineItem> mapOldOppLineItems;
            if(mapOldItems != null){
                mapOldOppLineItems = (Map<Id, OpportunityLineItem>) mapOldItems;
                Debug.log('mapOldOppLineItems---'+mapOldOppLineItems);
            }            
            
            for(OpportunityLineItem oppLineItemRec : (List<OpportunityLineItem>)listNewItems){
                if(oppLineItemRec.Geography__c != null && oppLineItemRec.Building__c == null){                    
                    if(mapOldOppLineItems != null && mapOldOppLineItems.get(oppLineItemRec.Id) != null && (oppLineItemRec.Geography__c != mapOldOppLineItems.get(oppLineItemRec.Id).Geography__c ) ){
                        setGeographyIds.add(oppLineItemRec.Geography__c);
                    } else {
                        setGeographyIds.add(oppLineItemRec.Geography__c);
                    }                        
                }                
            }
            Debug.log('setGeographyIds---'+setGeographyIds);
            if(setGeographyIds.size() > 0){
                Map<Id,Geography__c> mapGeographys = new Map<Id,Geography__c>([SELECT Id, Nearest_Building__c, Nearest_Building__r.UUID__c  FROM Geography__c WHERE Id IN : setGeographyIds]);
                if(mapGeographys.size()>0){
                    for(OpportunityLineItem oppLineItemRec : (List<OpportunityLineItem>)listNewItems){
                        if(oppLineItemRec.Geography__c != null && oppLineItemRec.Building__c == null && mapGeographys.containsKey(oppLineItemRec.Geography__c) && mapGeographys.get(oppLineItemRec.Geography__c) != null){ 
                            //oppLineItemRec.Building__c = mapGeographyRelatedBuildingIds.get(oppLineItemRec.Geography__c);
                            oppLineItemRec.Building__c = mapGeographys.get(oppLineItemRec.Geography__c).Nearest_Building__c != null ? mapGeographys.get(oppLineItemRec.Geography__c).Nearest_Building__c : null ;
                            oppLineItemRec.Building_UUID__c = mapGeographys.get(oppLineItemRec.Geography__c).Nearest_Building__r.UUID__c != null ? mapGeographys.get(oppLineItemRec.Geography__c).Nearest_Building__r.UUID__c : null ;
                        }
                    }
                }
            }
        } catch(Exception pEx) { 
                List<Id> ids = New List<Id>();
                if(mapNewItems.keyset()!=null)
                    ids.addAll(mapNewItems.keyset());
                new ApexDebugLog().createLog( 
                    new ApexDebugLog.Error('OpportunityLineItemTriggerHandler','updateBuildingFromGeography',String.join(ids,','),pEx)
                );
            } 
    }
    /************************************************************************************************************************************
    Author 				: 	Nikhil Mehta
    Description 		: 	This method will update the building UUID OpportunityLineItem  if the Building UUID not exist. 
    Issue No.			:	ST-2348
	Created Date        :   04 April 2018
    **************************************************************************************************************************************/ 
    public static void UpdateBuildingUUID(List<OpportunityLineItem> listNewOpportunityLineItems, Map<Id, OpportunityLineItem> mapNewOpportunityLineItems, List<OpportunityLineItem> listOldOpportunityLineItems, Map<Id, OpportunityLineItem> mapOldOpportunityLineItems){
        try{
            Set<Id> setBuildingIds = new Set<Id>();
            for(OpportunityLineItem opportunityLineItemRec : listNewOpportunityLineItems){
                if(opportunityLineItemRec.Building__c != null){
                    if(mapOldOpportunityLineItems != null && mapOldOpportunityLineItems.containsKey(opportunityLineItemRec.Id) && mapOldOpportunityLineItems.get(opportunityLineItemRec.Id)!=null){
                        if(opportunityLineItemRec.Building_UUID__c == null || opportunityLineItemRec.Building__c != mapOldOpportunityLineItems.get(opportunityLineItemRec.Id).Building__c){
                            setBuildingIds.add(opportunityLineItemRec.Building__c);
                        }
                    }else{
                        setBuildingIds.add(opportunityLineItemRec.Building__c);
                    }
                }
            }
            if(setBuildingIds.size()>0){
                Map<Id,Building__c> mapBuildings = new Map<Id,Building__c>([SELECT Id,UUID__c FROM Building__c WHERE Id IN : setBuildingIds]);
                for(OpportunityLineItem oppLineItemRec : listNewOpportunityLineItems){
                    if(oppLineItemRec.Building__c != null && mapBuildings.containsKey(oppLineItemRec.Building__c) && mapBuildings.get(oppLineItemRec.Building__c) != null){ 
                        oppLineItemRec.Building_UUID__c = mapBuildings.get(oppLineItemRec.Building__c).UUID__c != null ? mapBuildings.get(oppLineItemRec.Building__c).UUID__c : null ;
                    }
                }
            }
        }catch(Exception pEx) { 
            List<Id> ids = New List<Id>();
            if(mapNewOpportunityLineItems.keyset()!=null)
                ids.addAll(mapNewOpportunityLineItems.keyset());
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('OpportunityLineItemTriggerHandler','UpdateBuildingUUID',String.join(ids,','),pEx)
            );
        }
    }
}