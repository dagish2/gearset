/**
* Name			:	ContractEventSent	 
* Issue No.		: 	ST-2525
* Purpose		:	This contains the reuse logic to fetch opportunites according to the event.
* History		
	Version			Author				Date			Detail						Feature			IssueNumber
	1.0				Shobhit Gahlot		1/1/2018		Initial Development
Modified By: Mayuresh Ghodke, Date: 5-Jul-2017, Issue: ST-1378, The logic was changed now Contract_UUID__c is given higher priority than opportunity_id
Modified By: Shobhit Gahlot, Date: 30/1/2018, Issue: CSI-545, comment: The logic was changed now opportunity_id is given higher priority than Contract_UUID__c
Modified By: Shobhit Gahlot, Issue: CSI-534, Date:29/02/2018, Comment: Now we will allow Closed Won opportunity found by opportunity_id to be updated
Modified By  : Shobhit Gahlot Issue: CSI-545 on 30/1/2018 The logic was changed now opportunity_id is given higher priority than Contract_UUID__c
Modified By  : Mayuresh Ghodke Issue No. : CSI-366 on 15th Nov'17 Allow Enterprise Opportunity to reuse Opp of Account for Contract Signed process as they are following manual process.
Modified By  : Shobhit Gahlot Issue: CSI-545 on Date: 30/1/2018 The logic was changed now opportunity_id is given higher priority than Contract_UUID__c
***********************************************************************************************************************************************************
*/ 
public class ContractEventFetchOpportunity {
    

    public static Opportunity getOpportunityWithLock(Map<String,Object> mapData){
        WWTypes.ContractEvent objContractEvent = (WWTypes.ContractEvent) mapData.get('payload');
        Map<String, List<String>> mapFieldsAndQueries = opportunityFieldsEvents(objContractEvent);
        String opportunityId = objContractEvent.opportunity_id;
        String opportunityQuery = 'SELECT Id, ';
        opportunityQuery += String.join(mapFieldsAndQueries.get('lstFields'), ',');
        if(mapFieldsAndQueries.get('lstInnerQueries') != null){
            opportunityQuery += ','+ String.join(mapFieldsAndQueries.get('lstInnerQueries'), ',');
        }
        opportunityQuery += ' FROM Opportunity WHERE Id =: opportunityId FOR UPDATE';
        Debug.log('lockOpportunity query ::'+opportunityQuery);
        List<Opportunity> lstOpportunity = (List<Opportunity>)Database.query(opportunityQuery);
        if(lstOpportunity.size() == 0){
            throw new ContractEventFetchOpportunityException('Opportunity not found with SFID '+opportunityId+' in '+ objContractEvent.event_name + ' Event');
        }
        return lstOpportunity[0];
    }
    
    public static Map<String, List<String>> opportunityFieldsEvents(WWTypes.ContractEvent objContractEvent){
        List<String> lstCommonFields = new List<String>{'Contract_Pdf__c', 'CurrencyIsoCode', 'Downgrade_Notes__c',
        'Original_Contract_UUID__c', 'Billing_Account__c', 'AccountId', 'Locations_Interested__c', 'Contract_UUID__c',
        'StageName','Primary_Member__c', 'Account.Lead_Source__c','Primary_Member__r.LeadSource','Primary_Member__r.Lead_Source_Detail__c', 'Primary_Member__r.Id', 'Billing_Account__r.Parent_Account__r.Lead_Source__c'};
        Map<String, List<String>> mapFieldsAndQueries = new Map<String, List<String>>();
        String contractEvent = objContractEvent.event_name.replaceAll( '\\s+', '').toLowerCase();
        Debug.log('contractEvent==>'+contractEvent);
        switch on contractEvent {
            when 'contractsigned' {
                if(String.isNotBlank(objContractEvent.reservation_uuid)){
                   lstCommonFields.add('OwnerId'); 
                }
            }
            when 'cancelmoveout' {
                mapFieldsAndQueries.put('lstInnerQueries', new List<String>{'(SELECT Id, Status__c,Reservable__r.UUID__c FROM Opportunity_Move_Outs__r)'});
            }
            when 'contractcanceled' {
                if(String.isNotBlank(objContractEvent.reservation_uuid)){
                    lstCommonFields.add('OwnerId'); 
                    mapFieldsAndQueries.put('lstInnerQueries', new List<String>{'(Select Id, Reservable__c, Start_Date__c, Opportunity__c, Monthly_Price__c From Opportunity_Offices__r)'});
                }
            }
        }
        mapFieldsAndQueries.put('lstFields', lstCommonFields);
        return mapFieldsAndQueries;
    }
    
    public class ContractEventFetchOpportunityException extends Exception {}
}