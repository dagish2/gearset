/**
* Name			:	contractCanceled	 
* Issue No.		: 	CSI-492 
* Purpose		:	This is contains the logic for contract Canceled.
* History		
	Version			Author				Date			Detail						Feature			IssueNumber
	1.0				Mayuresh Ghodke		1/1/2018		Initial Development
	2.0				Shobhit Gahlot		9/1/2018		Payload structure Change	Sellable		CSI-441
***********************************************************************************************************************************************************
*/ 
public class ContractEventCancel {
  
    //Name: Mayuresh Ghodke Date: 20th Sept'17 Issue No.: ST-1428  Comment : When we get event_name = 'Contract Canceled' then we need to find out the opportunity with given contract uuid or Opportunity id and will cancel that opportunity.
    //Modified By: Shobhit Gahlot, Date: 30/1/2018   Issue: CSI-545        comment	: The logic was changed now opportunity_id is given higher priority than Contract_UUID__c
    public static String contractCanceled(WWTypes.ContractEvent objContractEvent, ContractEventUtilities.UtilityWapper objUtilityWapper){
        Debug.log('ContractEvent : In Else Contract Canceled : '+objContractEvent.event_name);
        //CSI-545 During hotdesk cancellation event opportunity id is not checked
        if(String.isNotBlank(objContractEvent.reservation_uuid)){
            return ContractEventHotDesk.hotDeskCancellation(objContractEvent, objUtilityWapper);
        }else{
            //Contract Canceled for Contract Event if we get Contract UUID in the payload or Opportunity Id
            if(objUtilityWapper.oppToUse != null){
                objUtilityWapper.udpateOpp = true;
                Billing_Account__c objBillingAccount;
                if(objUtilityWapper.oppToUse.Billing_Account__c == null){
                    objBillingAccount = ContractEventAccountHandler.createOrReuseBillingAccount(objContractEvent.company_uuid, objContractEvent.primary_member_email, objUtilityWapper.mapContactsMembers);
                }
                if(objBillingAccount != null){
                    objUtilityWapper.objOpp.Billing_Account__c = objBillingAccount.Id;
                    if(objBillingAccount.Parent_Account__c != null){
                        objUtilityWapper.objOpp.AccountId = objBillingAccount.Parent_Account__c;
                    }
                }
                objUtilityWapper.objOpp.Id = objUtilityWapper.oppToUse.Id;
                mapContractCancelFieldsToOpportunity(objUtilityWapper.objOpp, objContractEvent);
                if(String.isNotBlank(objContractEvent.lead_source)){
                    objUtilityWapper.objOpp.LeadSource = objContractEvent.lead_source;
                }
                if(String.isNotBlank(objContractEvent.lead_source_detail)){
                    objUtilityWapper.objOpp.Lead_Source_Detail__c = objContractEvent.lead_source_detail;
                }
                update objUtilityWapper.objOpp;
                return ContractEventUtilities.getResult(objUtilityWapper.objOpp.Id, false);
            }else {
                //we do not have to send an error as per the SS team's requirement. ST-1428
                //Create New Opportunity CSI-1312
                String result = ContractEventCreateOppUtility.createNewOpportunity(objContractEvent,objUtilityWapper);                       
                return ContractEventUtilities.getResult(result, true);
            }
        } 
    }
    
    public static Opportunity mapContractCancelFieldsToOpportunity(Opportunity canceledOpp, WWTypes.ContractEvent objContractEvent){
        canceledOpp.StageName = 'Closing';
        canceledOpp.Contract_Stage__c = 'Contract Canceled';
        canceledOpp.Original_Contract_UUID__c = objContractEvent.membership_agreement_uuid;
        canceledOpp.Contract_UUID__c = null;
        //CSI-411 changes made by shobhit
        canceledOpp.Contract_Canceled_On_Date__c = (String.isNotBlank(objContractEvent.contract_date)) ? Date.valueOf(objContractEvent.contract_date): date.today();
    	return canceledOpp;
    }
    
    // Name    : Mayuresh Ghodke
    // Issue No. : CSI-302
    // Date    : 2nd Nov'17
    // Comment : When we get event_name = "Cancel Moveout" then we need to find out the opportunity with given contract uuid or Opportunity id and will search Opportunity move out for them and cancel them.
    //Modified By  : Shobhit Gahlot
    //Date		: 30/1/2018
    //Issue		: CSI-545
    //comment	: The logic was changed now opportunity_id is given higher priority than Contract_UUID__c
    public static String cancelMoveout(WWTypes.ContractEvent objContractEvent, ContractEventUtilities.UtilityWapper objUtilityWapper){
        Debug.log('ContractEvent : In Else Cancel Moveout : '+objContractEvent.event_name);
        //ST-2993 Give specific error messages on cancel moveout commented on CSI-1312
        /*if(objUtilityWapper.oppToUse != null && !objUtilityWapper.setCloseStage.contains(objUtilityWapper.oppToUse.StageName)){
            return 'An opportunity with this Opportunity Id or Contract UUID is not in Closed Won or Closed Lost stage';
        }*/
        DEbug.log('ContractEvent : In Else :=='+objUtilityWapper.oppToUse);
        if(objUtilityWapper.oppToUse != null){
            if(objUtilityWapper.oppToUse.Opportunity_Move_Outs__r.size() > 0){
                Billing_Account__c objBillingAccount;
                if(objUtilityWapper.oppToUse.Billing_Account__c == null){
                    objBillingAccount = ContractEventAccountHandler.createOrReuseBillingAccount(objContractEvent.company_uuid, objContractEvent.primary_member_email, objUtilityWapper.mapContactsMembers);
                }
                if(objBillingAccount != null){
                    objUtilityWapper.objOpp.Billing_Account__c = objBillingAccount.Id;
                    if(objBillingAccount.Parent_Account__c != null){
                        objUtilityWapper.objOpp.AccountId = objBillingAccount.Parent_Account__c;
                    }
                }
                List<Opportunity_Move_Outs__c> lstOpportunityMoveOutsToCancel = new List<Opportunity_Move_Outs__c>();
                for(WWTypes.move_outssVal obj : objContractEvent.move_outs){
                    for(Opportunity_Move_Outs__c objOppMoveOut : objUtilityWapper.oppToUse.Opportunity_Move_Outs__r){
                        if(objOppMoveOut.Reservable__r.UUID__c == obj.reservable_uuid){
                            Opportunity_Move_Outs__c objOppMove = new Opportunity_Move_Outs__c();
                            objOppMove.Id = objOppMoveOut.Id;
                            objOppMove.Status__c = 'Cancel';
                            lstOpportunityMoveOutsToCancel.add(objOppMove);
                        }
                        
                    }
                }
                if(lstOpportunityMoveOutsToCancel.size() > 0){
                    update lstOpportunityMoveOutsToCancel;
                }else{
                    return 'Provided Opportunity Move Outs are not matching with current Opportunity Move Outs in Salesforce.';
                }
                return ContractEventUtilities.getResult(objUtilityWapper.oppToUse.Id, false);
            }else{
                return 'Provided Opportunity not having Opportunity Move Outs.';
            }
        }else{
            //Create New Opportunity CSI-1312
            String result = ContractEventCreateOppUtility.createNewOpportunity(objContractEvent,objUtilityWapper);                       
            return ContractEventUtilities.getResult(result, true);
            //return 'Appropriate Opportunity not found for provided Contract UUID or Opportunity Id.';
        }
    }
}