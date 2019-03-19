/**
* Name			:	ContractEventMoveOutsHandler	 
* Issue No.		: 	CSI-715 
* Purpose		:	This is used to update and create opportunity move outs in contract event for all events.
* History		
Version			Author				Date			Detail						Feature			IssueNumber
1.0				Shobhit Gahlot		22/03/2018		Initial Development
***********************************************************************************************************************************************************
*/ 
public class ContractEventMoveOutsHandler {

    public static void updateOpportunityMoveOuts(WWTypes.ContractEvent objContractEvent, ContractEventUtilities.UtilityWapper objUtilityWapper){
        //Fetch Opportunity_Move_Outs__c with reservable_uuids and current Opportunity Which need to keep in salesforce
        List<Opportunity_Move_Outs__c> lstOpportunityReservableMoveOut = [SELECT Id, Reservable__c, Move_Out_Date__c, CurrencyIsoCode,  Reservable__r.UUID__c FROM Opportunity_Move_Outs__c WHERE Opportunity__c =: objUtilityWapper.objOpp.Id AND Reservable__r.UUID__c IN : objUtilityWapper.setMoveOutPayloadReservableUuid];
        Set<String> setReservableUuidsMoveOutToUpdate = new Set<String>();
        Debug.log('ContractEvent :lstOpportunityReservableMoveOut :: '+lstOpportunityReservableMoveOut);
        if(lstOpportunityReservableMoveOut != null && lstOpportunityReservableMoveOut.size() > 0){
            Debug.log('ContractEvent :lstOpportunityReservableMoveOut :: '+lstOpportunityReservableMoveOut);
            for(Opportunity_Move_Outs__c objOppRes : lstOpportunityReservableMoveOut){
                setReservableUuidsMoveOutToUpdate.add(objOppRes.Reservable__r.UUID__c);
            }
        }
        Debug.log('ContractEvent :setReservableUuids :: '+setReservableUuidsMoveOutToUpdate);
        
        //Fetch Opportunity_Move_Outs__c for current Opportunity to separate unwanted Opportunity_Move_Outs__c 
        //and delete one which are extra from lstOpportunityReservableMoveOut
        List<Opportunity_Move_Outs__c> lstOppReservableMoveOut = [Select Id, Reservable__r.UUID__c, Move_Out_Date__c, CurrencyIsoCode From Opportunity_Move_Outs__c Where Opportunity__c =: objUtilityWapper.objOpp.Id];
        Debug.log('ContractEvent :lstOppReservableMoveOut :: '+lstOppReservableMoveOut);
        List<Opportunity_Move_Outs__c> lstOppReservableToDeleteMoveOuts = new List<Opportunity_Move_Outs__c>();
        List<Opportunity_Move_Outs__c> lstOppReservableToUpdateMoveOut = new List<Opportunity_Move_Outs__c>();
        //Check cuurent Opportunity_Move_Outs__c's Reservable UUIDs are in Payloads reservable_uuids if not then delete them.
        if(lstOppReservableMoveOut != null && lstOppReservableMoveOut.size()>0){
            for(Opportunity_Move_Outs__c objOppRes : lstOppReservableMoveOut){
                if(!objUtilityWapper.setMoveOutPayloadReservableUuid.contains(objOppRes.Reservable__r.UUID__c))
                    lstOppReservableToDeleteMoveOuts.add(objOppRes);
                else
                    lstOppReservableToUpdateMoveOut.add(objOppRes);
            }
        }
        Debug.log('ContractEvent :lstOppReservableToDeleteMoveOuts :: '+lstOppReservableToDeleteMoveOuts);
        //Delete Opportunity_Move_Outs__c as they are not in Payload
        if(lstOppReservableToDeleteMoveOuts != null && lstOppReservableToDeleteMoveOuts.size()>0)
            delete lstOppReservableToDeleteMoveOuts;
        //Update Currency of OppReservable
        if(lstOppReservableToUpdateMoveOut != null && lstOppReservableToUpdateMoveOut.size()>0){
            for(Opportunity_Move_Outs__c objOppRes : lstOppReservableToUpdateMoveOut){
                objOppRes.CurrencyIsoCode = objContractEvent.currencyVal;
                if(objUtilityWapper.mapPayloadReservableMoveOut.get(objOppRes.Reservable__r.UUID__c) != null){
                    objOppRes.Monthly_Price__c = Decimal.valueof(objUtilityWapper.mapPayloadReservableMoveOut.get(objOppRes.Reservable__r.UUID__c).price);
                    objOppRes.Move_Out_Date__c = Date.valueof(objUtilityWapper.mapPayloadReservableMoveOut.get(objOppRes.Reservable__r.UUID__c).move_out_date);
                    objOppRes.Pending_Desks__c = Decimal.valueof(objUtilityWapper.mapPayloadReservableMoveOut.get(objOppRes.Reservable__r.UUID__c).quantity);
                	objOppRes.Status__c = 'Active';//ST-2726
                }
            }
            update lstOppReservableToUpdateMoveOut;
        }
        Debug.log('ContractEvent :setReservableUuidsMoveOutToUpdate :: '+setReservableUuidsMoveOutToUpdate);
        Debug.log('ContractEvent :objUtilityWapper.setMoveOutPayloadReservableUuid :: '+objUtilityWapper.setMoveOutPayloadReservableUuid);
        
        createOpportunityMoveOuts(objContractEvent, objUtilityWapper, setReservableUuidsMoveOutToUpdate, null);
    } 
    
    public static void createOpportunityMoveOuts(WWTypes.ContractEvent objContractEvent, ContractEventUtilities.UtilityWapper objUtilityWapper, Set<String> setReservableUuidsMoveOutToUpdate, Id newOpportunityId){
        
        //Create Opportunity_Move_Outs__c with Reservable and Opportunity
        Debug.log('ContractEvent : objUtilityWapper.mapPayloadReservableMoveOut : '+objUtilityWapper.mapPayloadReservableMoveOut);
        List<Opportunity_Move_Outs__c> lstOpportunityReservableToCreateMoveOut = new List<Opportunity_Move_Outs__c>();
        for(String objResUUID : objUtilityWapper.setMoveOutPayloadReservableUuid){
            if((setReservableUuidsMoveOutToUpdate != null && !setReservableUuidsMoveOutToUpdate.contains(objResUUID)) || (newOpportunityId !=null)){
                Opportunity_Move_Outs__c objOpportunityReservableMoveOut = new Opportunity_Move_Outs__c();
                if(objUtilityWapper.mapReservablePresentInSystem.get(objResUUID) != null){ 
                    if(objUtilityWapper.mapPayloadReservableMoveOut.get(objResUUID) != null){
                        objOpportunityReservableMoveOut.Move_Out_Date__c = Date.valueof(objUtilityWapper.mapPayloadReservableMoveOut.get(objResUUID).move_out_date);
                        objOpportunityReservableMoveOut.Monthly_Price__c = Decimal.valueof(objUtilityWapper.mapPayloadReservableMoveOut.get(objResUUID).price);
                        objOpportunityReservableMoveOut.Pending_Desks__c = Decimal.valueof(objUtilityWapper.mapPayloadReservableMoveOut.get(objResUUID).quantity);
                        if(objContractEvent.event_name.toLowerCase() == 'cancel moveout'){
                            objOpportunityReservableMoveOut.Status__c =  'Cancel';
                        }
                    }
                    objOpportunityReservableMoveOut.Reservable__c = objUtilityWapper.mapReservablePresentInSystem.get(objResUUID).Id;
                    if(newOpportunityId != null)
                        objOpportunityReservableMoveOut.Opportunity__c = newOpportunityId;
					else if(objUtilityWapper.objOpp != null)
                    	objOpportunityReservableMoveOut.Opportunity__c = objUtilityWapper.objOpp.Id;
                    objOpportunityReservableMoveOut.CurrencyIsoCode = objContractEvent.currencyVal;
                    lstOpportunityReservableToCreateMoveOut.add(objOpportunityReservableMoveOut);
                }
            }
        }
        //Insert Opportunity_Move_Outs__c
        Debug.log('ContractEvent :lstOpportunityReservableToCreateMoveOut create ne move outs: '+lstOpportunityReservableToCreateMoveOut);
        if(lstOpportunityReservableToCreateMoveOut != null && lstOpportunityReservableToCreateMoveOut.size() > 0){
            insert lstOpportunityReservableToCreateMoveOut;
        }      
    }
	
    public static void utilityWrapperInitializerForMoveOuts(WWTypes.ContractEvent objContractEvent, ContractEventUtilities.UtilityWapper objUtilityWapper){
        //Move outs all reservable UUIDs
        if(objContractEvent.move_outs != null && objContractEvent.move_outs.size() > 0){
            for(WWTypes.move_outssVal obj : objContractEvent.move_outs){
                objUtilityWapper.setMoveOutPayloadReservableUuid.add(obj.reservable_uuid);
                objUtilityWapper.mapPayloadReservableMoveOut.put(obj.reservable_uuid,obj);
                objUtilityWapper.setPayloadBuildingUUID.add(obj.building_uuid);   
            }
            if(objUtilityWapper.flagConsiderMoveOutBuilding){
                objUtilityWapper.opportunityBuildingUUID = objContractEvent.move_outs[0].building_uuid;
            }
            objUtilityWapper.opportunityBuildingMoveOutUUID = objContractEvent.move_outs[0].building_uuid;
        } 
    }
}