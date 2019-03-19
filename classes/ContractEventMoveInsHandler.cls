/**
* Name			:	ContractEventMoveInsHandler	 
* Issue No.		: 	CSI-715 
* Purpose		:	This is used to update and create oppotunity reservables in contract event for all events.
* History		
Version			Author				Date			Detail						Feature			IssueNumber
1.0				Shobhit Gahlot		21/03/2018		Initial Development
***********************************************************************************************************************************************************
*/ 
public class ContractEventMoveInsHandler {
    
    public static void updateOpportunityReservables(WWTypes.ContractEvent objContractEvent, ContractEventUtilities.UtilityWapper objUtilityWapper){
        //Fetch Opportunity_Reservable__c with reservable_uuids and current Opportunity Which need to keep in salesforce
        
       	List<Opportunity_Reservable__c> lstAllOppReservableRelatedToOpportunity = [Select Id, Reservable__r.UUID__c, Start_Date__c, Monthly_Price__c, CurrencyIsoCode, Reservable__r.Building__r.UUID__c From Opportunity_Reservable__c Where Opportunity__c =: objUtilityWapper.objOpp.Id FOR UPDATE]; 
        List<Opportunity_Reservable__c> lstOpportunityReservable = [SELECT Id, Reservable__c, Start_Date__c, Monthly_Price__c, CurrencyIsoCode,  Reservable__r.UUID__c FROM Opportunity_Reservable__c WHERE Opportunity__c =: objUtilityWapper.objOpp.Id AND Reservable__r.UUID__c IN : objUtilityWapper.setPayloadReservableUuid];
        Set<String> setReservableUuidsToUpdate = new Set<String>();
        Debug.log('ContractEvent :lstOpportunityReservable :: '+lstOpportunityReservable);
        if(lstOpportunityReservable != null && lstOpportunityReservable.size() > 0){
            Debug.log('ContractEvent :lstOpportunityReservable :: '+lstOpportunityReservable);
            for(Opportunity_Reservable__c objOppRes : lstOpportunityReservable){
                Debug.log('ContractEvent :objOppRes.Reservable__r.UUID__c :: '+objOppRes.Reservable__r.UUID__c);
                if(objOppRes.Reservable__r != null && objOppRes.Reservable__r.UUID__c != null)
                    setReservableUuidsToUpdate.add(objOppRes.Reservable__r.UUID__c);
            }
        }
        Debug.log('ContractEvent :setReservableUuidsToUpdate for objUtilityWapper.objOpp.Id in ContractEventUpdateOppUtility and uuid in setReservableUuidsToUpdate:: '+setReservableUuidsToUpdate);
        
        //Fetch Opportunity_Reservable__c for current Opportunity to separate unwanted Opportunity_Reservable__c 
        //and delete one which are extra from lstOpportunityReservable
        
        Debug.log('ContractEvent :lstAllOppReservableRelatedToOpportunity :: '+lstAllOppReservableRelatedToOpportunity);
        List<Opportunity_Reservable__c> lstOppReservableToDelete = new List<Opportunity_Reservable__c>();
        List<Opportunity_Reservable__c> lstOppReservableToUpdate = new List<Opportunity_Reservable__c>();
        //Check cuurent Opportunity_Reservable__c's Reservable UUIDs are in Payloads reservable_uuids if not then delete them.
        if(lstAllOppReservableRelatedToOpportunity.size() > 0){
            for(Opportunity_Reservable__c objOppRes : lstAllOppReservableRelatedToOpportunity){
                if(objUtilityWapper.setPayloadReservableUuid != null && !objUtilityWapper.setPayloadReservableUuid.contains(objOppRes.Reservable__r.UUID__c))
                    lstOppReservableToDelete.add(objOppRes);
                else
                    lstOppReservableToUpdate.add(objOppRes);
            }
        }
        Debug.log('ContractEvent :lstOppReservableToDelete :: '+lstOppReservableToDelete);
        //Delete Opportunity_Reservable__c as they are not in Payload
        if(lstOppReservableToDelete != null && lstOppReservableToDelete.size()>0)
            delete lstOppReservableToDelete;
        //Update Currency of OppReservable
        debug.log('lstOppReservableToUpdate opp reservables::'+lstOppReservableToUpdate);
        debug.log('objUtilityWapper.mapBuildingUUIDWithCommitmentId ::'+objUtilityWapper.mapBuildingUUIDWithCommitmentId);
        if(lstOppReservableToUpdate != null && lstOppReservableToUpdate.size()>0){
            for(Opportunity_Reservable__c objOppRes : lstOppReservableToUpdate){
                objOppRes.CurrencyIsoCode = objContractEvent.currencyVal;
                objOppRes.Monthly_Price__c = Decimal.valueof(objUtilityWapper.mapPayloadReservable.get(objOppRes.Reservable__r.UUID__c).price);
                objOppRes.Start_Date__c = Date.valueof(objUtilityWapper.mapPayloadReservable.get(objOppRes.Reservable__r.UUID__c).start_date);
                objOppRes.Pending_Desks__c = Decimal.valueof(objUtilityWapper.mapPayloadReservable.get(objOppRes.Reservable__r.UUID__c).quantity);
                //CSI-692 
                if(objOppRes.Reservable__r.Building__r.UUID__c != null && objUtilityWapper.mapBuildingUUIDWithCommitmentId.size() > 0 && objUtilityWapper.mapBuildingUUIDWithCommitmentId.get(objOppRes.Reservable__r.Building__r.UUID__c) != null)
                	objOppRes.Commitment_Term__c = objUtilityWapper.mapBuildingUUIDWithCommitmentId.get(objOppRes.Reservable__r.Building__r.UUID__c);
                Debug.log('objUtilityWapper.mapBuildingUUIDWithCommitmentId.get(objOppRes.Reservable__r.Building__r.UUID__c)'+objUtilityWapper.mapBuildingUUIDWithCommitmentId.get(objOppRes.Reservable__r.Building__r.UUID__c));
                //CSI-378 changes made shobhit
                //objOppRes.Commitment_Terms_End_Date__c = (objUtilityWapper.mapPayloadReservable.get(objOppRes.Reservable__r.UUID__c).commitment_end_date != null && objUtilityWapper.mapPayloadReservable.get(objOppRes.Reservable__r.UUID__c).commitment_end_date != '')? Date.valueof(objUtilityWapper.mapPayloadReservable.get(objOppRes.Reservable__r.UUID__c).commitment_end_date) : null;
            }
            update lstOppReservableToUpdate;
        }
        
        Debug.log('ContractEvent :setReservableUuidsToUpdate :: '+setReservableUuidsToUpdate);
        Debug.log('ContractEvent :objUtilityWapper.setPayloadReservableUuid :: '+objUtilityWapper.setPayloadReservableUuid);
        
        createOpportunityReservables(objContractEvent, objUtilityWapper, setReservableUuidsToUpdate, null);
        
    }
    
    public static void createOpportunityReservables(WWTypes.ContractEvent objContractEvent, ContractEventUtilities.UtilityWapper objUtilityWapper, Set<String> setReservableUuidsToUpdate, Id newOpportunityId){
        
        //Create Opportunity_Reservable__c with Reservable and Opportunity
        List<Opportunity_Reservable__c> lstOpportunityReservableToCreate = new List<Opportunity_Reservable__c>();
        for(String objResUUID : objUtilityWapper.setPayloadReservableUuid){
            if((setReservableUuidsToUpdate != null && !setReservableUuidsToUpdate.contains(objResUUID)) || (newOpportunityId !=null)){
                Opportunity_Reservable__c objOpportunityReservable = new Opportunity_Reservable__c();
                if(objUtilityWapper.mapReservablePresentInSystem.get(objResUUID) != null){
                    if(objUtilityWapper.mapPayloadReservable.get(objResUUID) != null){
                        objOpportunityReservable.Start_Date__c = Date.valueof(objUtilityWapper.mapPayloadReservable.get(objResUUID).start_date);
                        objOpportunityReservable.Monthly_Price__c = Decimal.valueof(objUtilityWapper.mapPayloadReservable.get(objResUUID).price);
                        objOpportunityReservable.Pending_Desks__c = Decimal.valueof(objUtilityWapper.mapPayloadReservable.get(objResUUID).quantity);
                        //CSI-692
                        if(objUtilityWapper.mapPayloadReservable.get(objResUUID).building_uuid != null && objUtilityWapper.mapBuildingUUIDWithCommitmentId.get(objUtilityWapper.mapPayloadReservable.get(objResUUID).building_uuid) != null)
                        	objOpportunityReservable.Commitment_Term__c = objUtilityWapper.mapBuildingUUIDWithCommitmentId.get(objUtilityWapper.mapPayloadReservable.get(objResUUID).building_uuid);
                        //CSI-378 changes made shobhit removed Commitment_Terms_End_Date__c in csi-525
                    }
                    objOpportunityReservable.Reservable__c = objUtilityWapper.mapReservablePresentInSystem.get(objResUUID).Id;
                    if(newOpportunityId != null)
                        objOpportunityReservable.Opportunity__c = newOpportunityId;
					else if(objUtilityWapper.objOpp != null)
                    	objOpportunityReservable.Opportunity__c = objUtilityWapper.objOpp.Id;
                    objOpportunityReservable.CurrencyIsoCode = objContractEvent.currencyVal;
                    lstOpportunityReservableToCreate.add(objOpportunityReservable);
                }
            }
        }
        Debug.log('ContractEvent : Insert lstOpportunityReservableToCreate :'+lstOpportunityReservableToCreate);
        if(lstOpportunityReservableToCreate != null && lstOpportunityReservableToCreate.size() > 0){
            insert lstOpportunityReservableToCreate; 
        }
        Debug.log('Limits.getQueries() in createOpportunityReservables 02.0::'+Limits.getQueries());
    }
    
    public static void utilityWrapperInitializerForMoveIns(WWTypes.ContractEvent objContractEvent, ContractEventUtilities.UtilityWapper objUtilityWapper){
        //Move ins total price and all reservable UUIDs
        if(objContractEvent.move_ins != null){
            for(WWTypes.move_insVal obj : objContractEvent.move_ins){
                Debug.log('ContractEvent : obj : '+obj);
                if(obj.reservable_uuid != null && obj.reservable_uuid != ''){
                    if(objUtilityWapper.latestDate == null && obj.start_date != ''){
                        objUtilityWapper.latestDate = Date.valueOf(obj.start_date);
                    }else if(obj.reservable_uuid != ''){
                        Integer numberDaysDiff = objUtilityWapper.latestDate.daysBetween(Date.valueOf(obj.start_date));
                        if(numberDaysDiff > 0){
                            objUtilityWapper.latestDate = Date.valueOf(obj.start_date);
                        }
                    }                    
                    Debug.log('ContractEvent : Decimal.valueof(obj.price) : '+Decimal.valueof(obj.price));                    
                }
                objUtilityWapper.setPayloadReservableUuid.add(obj.reservable_uuid);
                objUtilityWapper.mapPayloadReservable.put(obj.reservable_uuid,obj);
                objUtilityWapper.setPayloadBuildingUUID.add(obj.building_uuid);
            }
            if(objContractEvent.move_ins.size() > 0)
            	objUtilityWapper.opportunityBuildingUUID =objContractEvent.move_ins[0].building_uuid;
            objUtilityWapper.flagConsiderMoveOutBuilding = false;
        }
    }
}