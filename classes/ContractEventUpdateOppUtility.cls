/**
* Name			:	ContractEventUpdateOppUtility	 
* Issue No.		: 	CSI-492 
* Purpose		:	This is used to update oppotunity in contract event for all events.
* History		
	Version			Author				Date			Detail						Feature			IssueNumber
	1.0				Mayuresh Ghodke		1/1/2018		Initial Development
	2.0				Shobhit Gahlot		9/1/2018		Payload structure Change	Sellable		CSI-441
***********************************************************************************************************************************************************
*/ 
public class ContractEventUpdateOppUtility {

    //Update Opportunity Product, Update Opportunity Reservables, Update Opportunity MoveOuts
    public static String updateOpportunityRelatedObjects(WWTypes.ContractEvent objContractEvent, ContractEventUtilities.UtilityWapper objUtilityWapper){
         
        //update lineitems according to currency of opportunity
        ContractEventProductsHandler.handleProducts(objContractEvent, objUtilityWapper);
        
        Debug.log(' objUtilityWapper.objOpp update Opportunity :: '+objUtilityWapper.objOpp);
        //CSI-525 commitment
        ContractEventCommitmentHandler.addCommitmentTermsOnOpportunity(objContractEvent, objUtilityWapper, null);
        ContractEventMoveInsHandler.updateOpportunityReservables(objContractEvent, objUtilityWapper);
        //Update Actual Start Date, Stage, CurrencyIsoCode, Location Intrested of Opportunity
        //CSI-525
        ContractEventDiscountsHandler.updateDiscounts(objContractEvent, objUtilityWapper);
        debug.log('objUtilityWapper ::'+objUtilityWapper.objOpp );
        
        update objUtilityWapper.objOpp;
        
        if(objUtilityWapper.deleteOpportunityLineItem){
			ContractEventProductsHandler.unconsideredLineItemWithCurrencyChange(objContractEvent, objUtilityWapper);
        }
        
        ContractEventProductsHandler.createNewProducts(objContractEvent, objUtilityWapper, null);
        
        /*Start Move Outs Schync */
        ContractEventMoveOutsHandler.updateOpportunityMoveOuts(objContractEvent, objUtilityWapper);
        
        return objUtilityWapper.objOpp.Id;
    }
    public class ContractEventUpdateOppUtilityException extends Exception{}
}