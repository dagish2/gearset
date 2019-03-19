/************************************************************************************************************************************
    Author 		: Dipak Pawar
    Description : Handler class for OpportunityRole Triggers
    
    History		:
----------------------------------------------------------------------------------------------------------------------------------
    VERSION	  DATE	         AUTHOR        DETAIL
    1	      12,May 2017	 Dipak Pawar   Initial Developement
**************************************************************************************************************************************/

global class OpportunityRoleTriggerHandler extends ITriggerHandler{
	
	public OpportunityRoleTriggerHandler()
    {
        super('Opportunity_Role__c');
    }
	
    /************************************************************************************************************************************
	    Author 				:
	    Issue No 			:
	    Description 		: Method for Before Insert Trigger Event.
	    Created Date 		:
	    Last Modified Date	: 2 Feb, 2018
	    Last Modified By	: Shivprasad Patil
	**************************************************************************************************************************************/

	public override void BeforeInsert(List<SObject> listNewItems)
    {
		updateOpportunityRole(listNewItems, null, null, null);
	    //triggerSetting.OpportunityRole_UpdateOpportunityRole = false;
	}
    
 	/************************************************************************************************************************************
	    Author 				:
	    Issue No 			:
	    Description 		: Method for Before Update Trigger Event.
	    Created Date 		:
	    Last Modified Date	: 2 Feb, 2018
	    Last Modified By	: Shivprasad Patil
	**************************************************************************************************************************************/
	public override void BeforeUpdate(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems)
    {
	    	updateOpportunityRole(listNewItems, mapNewItems, listOldItems, mapOldItems);
	        //triggerSetting.OpportunityRole_UpdateOpportunityRole = false;
	}
    
 	/************************************************************************************************************************************
		Author 				:
		Issue No 			:
		Description 		: Method for After Insert Trigger Event.
		Created Date 		:
		Last Modified Date	: 2 Feb, 2018
		Last Modified By	: Shivprasad Patil
	**************************************************************************************************************************************/
	public override void AfterInsert(List<SObject> listNewItems, Map<Id, SObject> mapNewItems)
    {	
        	insertOrUpdateOpportunityContactRole(listNewItems, mapNewItems, null, null);     
	}
	
    /************************************************************************************************************************************
	    Author 				:
	    Issue No 			:
	    Description 		: Method for After Update Trigger Event.
	    Created Date 		:
	    Last Modified Date	: 2 Feb, 2018
	    Last Modified By	: Shivprasad Patil
	**************************************************************************************************************************************/

	public override void AfterUpdate(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems)
    {
	    	insertOrUpdateOpportunityContactRole(listNewItems, mapNewItems, listOldItems, mapOldItems);  
	}
    
    /************************************************************************************************************************************
	    Author 				:
	    Issue No 			:
	    Description 		: Method for After Delete Trigger Event.
	    Created Date 		:
	    Last Modified Date	: 2 Feb, 2018
	    Last Modified By	: Shivprasad Patil
	**************************************************************************************************************************************/

	public override void AfterDelete(List<SObject> listOldItems, Map<Id, SObject> mapOldItems)
	{
	    	insertOrUpdateOpportunityContactRole(listOldItems, mapOldItems, null, null);  
	}
	
    /************************************************************************************************************************************
	    Author 				:
	    Issue No 			:
	    Description 		: This Method for update Opportunity Role.
	    Created Date 		:
	    Last Modified Date	: 2 Feb, 2018
	    Last Modified By	: Shivprasad Patil
	**************************************************************************************************************************************/

	public static void updateOpportunityRole(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems){
        if(TriggerSettings.mappedField.OpportunityRole_UpdateOpportunityRole)
        {
            Set<Id> setOpportunityIds = new Set<Id>();
            Set<Id> setContactIds = new Set<Id>();    
            Map<String, Opportunity_Role__c> mapExistingOpportunityRoles = new Map<String, Opportunity_Role__c>();
            Map<Id,  List<Opportunity_Role__c>> mapOpportunityRoles = new Map<Id,  List<Opportunity_Role__c>>();
            Map<Id, Opportunity_Role__c> oppOldMap = new Map<Id, Opportunity_Role__c>();
            String errorMessage = 'Opportunity role with same opportunity and contact is already present';
            try{
                if(Trigger.isUpdate){ 
                    oppOldMap = (Map<Id, Opportunity_Role__c>)mapOldItems;
                }
                Debug.log('(List<Opportunity_Role__c>)trigger.new : '+(List<Opportunity_Role__c>)listNewItems);
                for(Opportunity_Role__c oppRoleRec : (List<Opportunity_Role__c>)listNewItems){
                    setOpportunityIds.add(oppRoleRec.Opportunity__c);
                    setContactIds.add(oppRoleRec.Contact__c);
                }
                Debug.log('setOpportunityIds :: '+setOpportunityIds);
                Debug.log('setContactIds :: '+setContactIds);
                if(!setOpportunityIds.isEmpty() && !setContactIds.isEmpty()){
                    List<Opportunity_Role__c> lst1 = [SELECT Id, Opportunity__c, Contact__c, Is_Primary_Member__c FROM Opportunity_Role__c WHERE Opportunity__c IN :setOpportunityIds];
                    Debug.log('lst1 :: '+lst1);
                    for(Opportunity_Role__c oppRoleRec : lst1){
                        if(mapOpportunityRoles.containsKey(oppRoleRec.Opportunity__c)){
                            List<Opportunity_Role__c> lstOppRoles = mapOpportunityRoles.get(oppRoleRec.Opportunity__c);
                            lstOppRoles.add(oppRoleRec);
                            mapOpportunityRoles.put(oppRoleRec.Opportunity__c, lstOppRoles);
                        } else {
                            List<Opportunity_Role__c> lstOppRoles = new List<Opportunity_Role__c>();
                            lstOppRoles.add(oppRoleRec);
                            mapOpportunityRoles.put(oppRoleRec.Opportunity__c, lstOppRoles);
                        }
                    }
                    List<Opportunity_Role__c> lst2 = [SELECT Id, Opportunity__c, Contact__c, Is_Primary_Member__c FROM Opportunity_Role__c WHERE Opportunity__c IN :setOpportunityIds AND Contact__c IN :setContactIds];
                    Debug.log('lst2 :: '+lst2);
                    for(Opportunity_Role__c oppRoleRec : lst2) {
                        mapExistingOpportunityRoles.put(oppRoleRec.Opportunity__c+'-'+oppRoleRec.Contact__c, oppRoleRec);                
                    }
                }        
                Debug.log('mapOpportunityRoles :: '+mapOpportunityRoles);
                Debug.log('mapExistingOpportunityRoles :: '+mapExistingOpportunityRoles);        
                for(Opportunity_Role__c oppRoleRec : (List<Opportunity_Role__c>)listNewItems){
                    Debug.log('oppRoleRec :: '+oppRoleRec);
                    if(Trigger.isInsert){
                        Debug.log('In Insert :: ');
                        if(mapExistingOpportunityRoles.containsKey(oppRoleRec.Opportunity__c+'-'+oppRoleRec.Contact__c)){
                            oppRoleRec.addError(errorMessage);
                        } else if(oppRoleRec.Is_Primary_Member__c){        
                            Debug.log('mapOpportunityRoles.get(oppRoleRec.Opportunity__c) :: '+mapOpportunityRoles.get(oppRoleRec.Opportunity__c));
                            if(mapOpportunityRoles.get(oppRoleRec.Opportunity__c) != null && mapOpportunityRoles.get(oppRoleRec.Opportunity__c).size() > 0){
                                updateOpportunityRelatedRoles(mapOpportunityRoles.get(oppRoleRec.Opportunity__c), oppRoleRec);
                            }
                        }
                    } else if(Trigger.isUpdate){
                        Debug.log('In Update :: ');
                        if((oppOldMap.get(oppRoleRec.Id).Opportunity__c != oppRoleRec.Opportunity__c || oppOldMap.get(oppRoleRec.Id).Contact__c != oppRoleRec.Contact__c) && mapExistingOpportunityRoles.containsKey(oppRoleRec.Opportunity__c+'-'+oppRoleRec.Contact__c)){
                            oppRoleRec.addError(errorMessage);
                        } else {
                            if(oppRoleRec.Is_Primary_Member__c){
                                oppRoleRec.Role__c = 'Primary Member';
                            }
                            if(mapOpportunityRoles.get(oppRoleRec.Opportunity__c) != null && mapOpportunityRoles.get(oppRoleRec.Opportunity__c).size() > 0){
                                updateOpportunityRelatedRoles(mapOpportunityRoles.get(oppRoleRec.Opportunity__c), oppRoleRec);
                            }
                        }
                    }
                }           
            } catch(Exception pEx) {
                List<Id> ids = New List<Id>();
                if(trigger.NewMap!=null)
                    ids.addAll(trigger.NewMap.keyset());
                new ApexDebugLog().createLog( 
                    new ApexDebugLog.Error('OpportunityRoleTriggerHandler','updateOpportunityRole',String.join(ids,','),pEx)
                );
                throw new OpportunityRoleTriggerHandlerException(pEx.getMessage());
            }    
        }
    }
    
    
    /************************************************************************************************************************************
	    Author 				:
	    Issue No 			:
	    Description 		: This Method for update Opportunity Related Roles.
	    Created Date 		:
	    Last Modified Date	: 2 Feb, 2018
	    Last Modified By	: Shivprasad Patil
	**************************************************************************************************************************************/
    public static void updateOpportunityRelatedRoles(List<Opportunity_Role__c> lstOppRoles, Opportunity_Role__c currentOppRoleRec){
        try{
            Map<Id, Opportunity_Role__c> oppRolesToUpdate = new Map<Id, Opportunity_Role__c>();
            for(Opportunity_Role__c oppRole : lstOppRoles){
                if(currentOppRoleRec.Id != oppRole.Id && currentOppRoleRec.Is_Primary_Member__c){
                    oppRole.Is_Primary_Member__c = false;
                    oppRole.Role__c = 'Influencer';
                    oppRolesToUpdate.put(oppRole.Id, oppRole);
                }
            }
            Debug.log('oppRolesToUpdate :: '+oppRolesToUpdate);
            if(!oppRolesToUpdate.isEmpty()) {                
                update oppRolesToUpdate.values();
            }  
        } catch(Exception pEx) {
            List<Id> ids = New List<Id>();
            if(trigger.NewMap!=null)
                ids.addAll(trigger.NewMap.keyset());
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('OpportunityRoleTriggerHandler','updateOpportunityRelatedRoles',String.join(ids,','),pEx)
            );
            throw new OpportunityRoleTriggerHandlerException(pEx.getMessage());
        }       
    }
    
    
    /************************************************************************************************************************************
	    Author 				:
	    Issue No 			:
	    Description 		: This Method for insert or update Opportunity Contact Role.
	    Created Date 		:
	    Last Modified Date	: 2 Feb, 2018
	    Last Modified By	: Shivprasad Patil
	**************************************************************************************************************************************/

    public static void insertOrUpdateOpportunityContactRole(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems) {
        if(TriggerSettings.mappedField.OpportunityRole_UpdateOpportunityContactRole)
		{
            try{
                if(Trigger.isInsert){
                    List<OpportunityContactRole> lstOppConRole = new List<OpportunityContactRole>();
                    for(Opportunity_Role__c opRole:(List<Opportunity_Role__c>)listNewItems){
                        lstOppConRole.add(new OpportunityContactRole(OpportunityId=opRole.Opportunity__c,ContactId=opRole.Contact__c,Role=opRole.Role__c,IsPrimary=opRole.Is_Primary_Member__c));
                    }
                    insert lstOppConRole;
                }else if(Trigger.isUpdate){
                    debug.log('Trigger.New'+listNewItems);
                    debug.log('Trigger.oldMap'+mapOldItems);
                    Set<Id> setOpConIds = new Set<Id>();
                    List<OpportunityContactRole> lstOppConRole = new List<OpportunityContactRole>();
                    for(Opportunity_Role__c opRole:(List<Opportunity_Role__c>)listNewItems){
                        if(opRole.Contact__c!=String.valueOf(mapOldItems.get(opRole.Id).get('Contact__c')) || opRole.Opportunity__c!=String.valueOf(mapOldItems.get(opRole.Id).get('Opportunity__c')) || opRole.Role__c!=String.valueOf(mapOldItems.get(opRole.Id).get('Role__c')) || opRole.Is_Primary_Member__c!=Boolean.valueOf(Trigger.oldMap.get(opRole.Id).get('Is_Primary_Member__c'))){
                            setOpConIds.add(String.valueOf(mapOldItems.get(opRole.Id).get('Opportunity__c')));
                            setOpConIds.add(String.valueOf(mapOldItems.get(opRole.Id).get('Contact__c')));
                        }
                    }   
                    if(!setOpConIds.isEmpty()){
                        List<OpportunityContactRole> lstOpConRole = [Select Id,OpportunityId,ContactId,Role,IsPrimary From OpportunityContactRole Where OpportunityId IN:setOpConIds OR ContactId IN:setOpConIds];
                        debug.log('lstOpConRole==>'+lstOpConRole);
                        Map<String,OpportunityContactRole> mapOpConRole = new Map<String,OpportunityContactRole>(); 
                        for(OpportunityContactRole opConRole:lstOpConRole){
                            mapOpConRole.put((opConRole.OpportunityId+':'+opConRole.ContactId),opConRole);
                        }
                        debug.log('mapOpConRole'+mapOpConRole);
                        List<OpportunityContactRole> lstOpConRolesToUpdate = new List<OpportunityContactRole>();
                        List<Id> lstOpConRoleToDeleteIds = new List<Id>();
                        if(!mapOpConRole.isEmpty()){
                            for(Opportunity_Role__c opRole:(List<Opportunity_Role__c>)Trigger.new){
                                OpportunityContactRole opConRole = new OpportunityContactRole();               
                                if(opRole.Opportunity__c!=String.valueOf(mapOldItems.get(opRole.Id).get('Opportunity__c'))){                   
                                    lstOpConRoleToDeleteIds.add(mapOpConRole.get(mapOldItems.get(opRole.Id).get('Opportunity__c')+':'+Trigger.oldMap.get(opRole.Id).get('Contact__c')).Id);
                                    opConRole.OpportunityId = opRole.Opportunity__c;
                                }else if(mapOpConRole.get(mapOldItems.get(opRole.Id).get('Opportunity__c')+':'+mapOldItems.get(opRole.Id).get('Contact__c')) != null ){                   
                                    opConRole.Id = mapOpConRole.get(mapOldItems.get(opRole.Id).get('Opportunity__c')+':'+mapOldItems.get(opRole.Id).get('Contact__c')).Id;
                                } 
                                else{
                                    opConRole.OpportunityId = opRole.Opportunity__c;   
                                }
                                opConRole.ContactId = opRole.Contact__c;
                                opConRole.Role = opRole.Role__c;
                                opConRole.IsPrimary = opRole.Is_Primary_Member__c;
                                lstOpConRolesToUpdate.add(opConRole);  
                            }                
                            debug.log('lstOpConRoleToDeleteIds'+lstOpConRoleToDeleteIds);
                            debug.log('lstOpConRolesToUpdate'+lstOpConRolesToUpdate);
                            Database.delete(lstOpConRoleToDeleteIds);
                            Database.upsert(lstOpConRolesToUpdate);  
                        }
                    }
                }else if(Trigger.isDelete){
                    Set<Id> setOpConIds = new Set<Id>();
                    for(Opportunity_Role__c opRole:(List<Opportunity_Role__c>)Trigger.old){
                        setOpConIds.add(opRole.Contact__c);
                        setOpConIds.add(opRole.Opportunity__c);
                    }
                    Map<Id,OpportunityContactRole> mapOpConRole = new Map<Id,OpportunityContactRole>([Select Id,OpportunityId,ContactId,Role,IsPrimary From OpportunityContactRole Where OpportunityId IN:setOpConIds AND ContactId IN:setOpConIds]);
                    Database.delete(new List<Id>(mapOpConRole.keySet()));
                }
            } catch(Exception pEx) {
                List<Id> ids = New List<Id>();
                if(trigger.NewMap!=null)
                    ids.addAll(trigger.NewMap.keyset());
                new ApexDebugLog().createLog( 
                    new ApexDebugLog.Error('OpportunityRoleTriggerHandler','insertOrUpdateOpportunityContactRole',ids != null ? String.join(ids,',') : '',pEx)
                );
                throw new OpportunityRoleTriggerHandlerException(pEx.getMessage());
            }
        }
    }
    
    public class OpportunityRoleTriggerHandlerException extends Exception{}
	
}