/**
* Name			:	ContractEventTestingUtility	 
* Issue No.		: 	
* Purpose		:	This class contains testing utility methods for Creationg payloads and data for Contract events.
* History		
	Version			Author				Date			Detail						Feature			IssueNumber
	1.0				Shobhit Gahlot		6/11/2018		Initial Development		
***********************************************************************************************************************************************************
*/

@isTest 
public class ContractEventTestingUtility {
    
    public static Map<String, String> mapDiscountFieldWithPayload = new Map<String, String>{'start_date'=>'Start_Date__c', 'end_date'=>'End_Date__c', 'amount'=>'Amount__c', 'building_uuid'=>'Building_UUID__c'};
    public static Map<String, String> mapOppReservableWithPayloadField =new Map<String, String>{'reservable_uuid'=>'Reservable_r.UUID__c','building_uuid'=>'Reservable__r.Building__r.uuid__c','move_out_date'=>'Move_Out_Date__c','quantity'=>'Pending_Desks__c','price'=>'Monthly_Price__c'};
    public static List<String> lstPayloadKeys = new List<String>{'event_name','opportunity_id','company_uuid','contract_pdf','community_manager_uuid','primary_member_email','currencyVal','move_ins','products','original_contract_uuid','membership_agreement_uuid','community_user','move_outs','downgrade_reason','downgrade_notes','transfer_type','reservation_uuid','from_opportunity','contract_date','discounts','commitments','contract_expires_at'};
    public static List<String> lstOpportunityFieldsForAssert = new List<String>{'Id','Original_Contract_UUID__c','Contract_Canceled_On_Date__c','Billing_Account__c','StageName','CurrencyIsoCode',' Contract_Expiration__c',' Commitment_Term_in_months__c',' Paperwork_Sent_On_Date__c',' Contract_Type__c','Send_Paperwork_By__c',' Community_Manager_UUID__c',' Community_User__c',' Contract_UUID__c','Primary_Member__c',' Contract_Stage__c',' Actual_Start_Date__c',' Type__c','Old_Opportunity__c',' Building__c',' Move_Out_Building__c','Contract_Voided_Discarded_On_Date__c','Reservation_UUID__c','LeadSource','Lead_Source_Detail__c', 'Primary_Member__r.LeadSource', 'Primary_Member__r.Lead_Source_Detail__c', 'Account.Lead_Source__c'};
    public static List<String> lstLineItemFieldsForAssert = new List<String>{'Id','Quantity','UnitPrice','Building_UUID__c','Building__c','CurrencyIsoCode','Product2Id','ProductCode'};        
    public static List<String> lstMoveInsFieldsForAssert = new List<String>{'Id', 'Start_Date__c', 'Monthly_Price__c', 'Pending_Desks__c', 'Commitment_Term__c', 'Reservable__c', 'Reservable__r.UUID__c', 'Reservable__r.Id', 'Building__c','Reservable__r.Building__r.UUID__c'};
    public static List<String> lstMoveOutsFieldsForAssert = new List<String>{'Id', 'Move_Out_Date__c', 'Monthly_Price__c', 'Pending_Desks__c', 'Status__c','Reservable__c','Reservable__r.UUID__c'};
    public static List<String> lstCommitmentFieldsForAssert = new List<String>{'Id','Commitment_Start_Date__c','Commitment_Term_in_Months__c','Commitment_End_Date__c','Building__c','Building_UUID__c'};
    public static List<String> lstDiscountsFieldsForAssert = new List<String>{'Id','End_Date__c','Start_Date__c','Discount_Type__c','Building__c','Amount__c', 'Building_UUID__c'};
    public static List<String> lstSellableFieldsForAssert = new List<String>{'Id','Building__c','Building_UUID__c','Unit_Price__c','Start_Date__c','Total_Price__c','Quantity__c'};
  
        
        public static void getContractDataForAllEvents(){
            SalesConsoleSettings.createSettings();
            Map<String, Object> mapData = new Map<String, Object>();
            mapData.put('objName', 'Contact');
            mapData.put('numberOfRecords', 4);
            List<Contact> lstContacts = (List<Contact>) TestingUtility.getRecords(mapData);
            Map<String, List<Object>> mapFieldForBillingAccount = createBillingAccount(lstContacts);
            
            mapData.put('objName', 'Billing_Account__c');
            mapData.put('doInsert', false);
            mapData.put('mapFieldValues', mapFieldForBillingAccount);
            List<Billing_Account__c> lstBillingAccount = TestingUtility.getRecords(mapData);
            for(Billing_Account__c objbillAccount : lstBillingAccount){
                objbillAccount.Parent_Account__c = null;
            }
            TestingUtility.insertListWithAssert(lstBillingAccount);
            //TriggerSettings.mappedField.Billing_Account_mapParentAccount = true;
            mapData.clear();
            mapData.put('objName', 'reservable');
            mapData.put('numberOfRecords', 4);
            List<Reservable__c> lstReservables = TestingUtility.getRecords(mapData);          
            
            mapData.clear();
            mapData.put('objName', 'product2');
            mapData.put('doInsert', true);        
            List<Product2> lstproducts = TestingUtility.getRecords(mapData);
            
            Map<String, List<Object>> mapFieldForOpportunity = new Map<String, List<Object>>();
            createMapFieldValuesFromsObject(lstContacts, new Map<String, String>{'Primary_Member__c'=>'Id'}, mapFieldForOpportunity);  
            createMapFieldValuesFromsObject(lstBillingAccount, new Map<String, String>{'Billing_Account__c'=>'Id'}, mapFieldForOpportunity);
            createMapFieldValuesFromsObject([SELECT AccountId FROM Contact WHERE Id In : lstContacts], new Map<String, String>{'AccountId'=>'AccountId'}, mapFieldForOpportunity);
            mapFieldForOpportunity.put('CurrencyIsoCode', new List<Object>{'INR','USD','AUD', 'EUR'});           
            mapFieldForOpportunity.put('Contract_Stage__c', new List<Object>{null, null, null, 'Contract Signed'});
            mapFieldForOpportunity.put('Reservation_UUID__c', new List<Object>{null, null, null, 'reservationuuid'});//for hot desk
                
            mapData.put('objName', 'Opportunity');
            mapData.put('numberOfRecords', 4);
            mapData.put('mapFieldValues', mapFieldForOpportunity);
            List<Opportunity> lstOpportunities = TestingUtility.getRecords(mapData);           
            
            mapFieldForOpportunity.clear();
            mapFieldForOpportunity.put('UnitPrice', new List<Object>{10,20,30});
            mapFieldForOpportunity.put('Quantity', new List<Object>{5,15,25});
            mapFieldForOpportunity.put('Start_Date__c', new List<Object>{Date.valueOf('2018-10-15'),Date.valueOf('2018-10-14'),Date.valueOf('2018-10-16')});
            Map<String, Map<String, List<Object>>> mapFieldValuesForOppId = new Map<String, Map<String, List<Object>>>();
            mapFieldValuesForOppId.put(lstOpportunities[0].Id,mapFieldForOpportunity);
            mapFieldValuesForOppId.put(lstOpportunities[1].Id,mapFieldForOpportunity);            
            
            List<OpportunityLineItem> lstLineItems = TestingUtility.getOpportunityLineItem(mapFieldValuesForOppId, new Map<String, Integer>{lstOpportunities[0].Id=>3, lstOpportunities[1].Id=>3}, new Set<String>{'PRDE-000200','PRHD-000400','PRDL-000001'}, true);
            mapFieldForOpportunity.clear();
            mapFieldForOpportunity.put('Start_Date__c', new List<Object>{Date.valueOf('2018-10-15'), Date.valueOf('2018-10-14'), Date.valueOf('2018-10-16')});
            mapFieldForOpportunity.put('Monthly_Price__c', new List<Object>{20, 30, 40});
            mapFieldForOpportunity.put('Pending_Desks__c', new List<Object>{100, 200, 300});
            createMapFieldValuesFromsObject(lstReservables, new Map<String, String>{'Reservable__c'=>'Id'}, mapFieldForOpportunity);
            createMapFieldValuesFromsObject(lstOpportunities, new Map<String, String>{'Opportunity__c' => 'Id'}, mapFieldForOpportunity);
            
            List<Opportunity_Reservable__c> lstOpportunityReservables = TestingUtility.createRecordsWithFields(Opportunity_Reservable__c.sObjectType, mapFieldForOpportunity, null, 3, null);
            TestingUtility.insertListWithAssert(lstOpportunityReservables);
            mapFieldForOpportunity.put('Move_Out_Date__c', new List<Object>{Date.valueOf('2018-10-15'), Date.valueOf('2018-10-14'), Date.valueOf('2018-10-16')});
            mapFieldForOpportunity.remove('Start_Date__c');
            List<Opportunity_Move_Outs__c> lstMoveOuts = TestingUtility.createRecordsWithFields(Opportunity_Move_Outs__c.sObjectType, mapFieldForOpportunity, null, 3, null);
            TestingUtility.insertListWithAssert(lstMoveOuts);           
        } 
    
    public static Map<String, List<Object>> createBillingAccount(List<Contact> lstContacts){
        Map<String, List<Object>> mapFieldForBillingAccount = new Map<String, List<Object>>();
        List<String> lstFieldApiName = new List<String>{'Name', 'Primary_Member__c', 'Parent_Account__c', 'UUID__c'};
            List<Object> lstFieldvalues;
        for(Integer indexContact = 0; indexContact < lstContacts.size(); indexContact++){
            for(Integer Index = 0; Index < lstFieldApiName.size(); Index++){
                if(mapFieldForBillingAccount.get(lstFieldApiName[Index]) != null){
                    lstFieldvalues = mapFieldForBillingAccount.get(lstFieldApiName[Index]);
                    String value = createBillAccountWithIndex(lstContacts, Index, indexContact);
                    lstFieldvalues.add(value);
                    mapFieldForBillingAccount.put(lstFieldApiName[Index], lstFieldvalues);
                }else{
                    String value = createBillAccountWithIndex(lstContacts, Index, indexContact);
                    mapFieldForBillingAccount.put(lstFieldApiName[Index], new List<Object>{value});
                }
            }
        }
        return mapFieldForBillingAccount;
    }
    public static string createBillAccountWithIndex(List<Contact> lstContacts, Integer fieldIndex, Integer ContactIndex){
        String value;
        if(fieldIndex == 0){
            value = 'Billing Account:' + lstContacts[ContactIndex].LastName;
        }else if(fieldIndex == 1){
            value = lstContacts[ContactIndex].Id;
        }else if(fieldIndex == 2){
            value = lstContacts[ContactIndex].AccountId;
        }else if(fieldIndex == 3){
            value = 'billaccountuuid' + lstContacts[ContactIndex].LastName + fieldIndex+ContactIndex;
        }
        return value;
    }
    
    public static void createMapFieldValuesFromsObject(List<sobject> lstDataForMap, Map<String, String> mapDataKeyObjectKey, Map<String, List<Object>> mapfieldsForData){
        for(sObject objSobject : lstDataForMap){
            for(String keyNameInDataMap : mapDataKeyObjectKey.keyset()){
                getsObjectType(objSobject, keyNameInDataMap, mapfieldsForData, mapDataKeyObjectKey.get(keyNameInDataMap));
            }
        }
    }
    
    public static void getsObjectType(sObject objSobject, string keyNameInDataMap, Map<String, List<Object>> mapFieldForOpportunity, String sobjectKey){
        switch on objSobject { 
            when Account objAccount{	
                createMapFromSobjectfield(objAccount, keyNameInDataMap, mapFieldForOpportunity, sobjectKey);
            }	
            when Contact objContact{
                createMapFromSobjectfield(objContact, keyNameInDataMap, mapFieldForOpportunity, sobjectKey);
            }
            when Billing_Account__c objBillingAccount{
                createMapFromSobjectfield(objBillingAccount, keyNameInDataMap, mapFieldForOpportunity, sobjectKey);
            }
            when Reservable__c objReservable{
                createMapFromSobjectfield(objReservable, keyNameInDataMap, mapFieldForOpportunity, sobjectKey);
            }
            when Opportunity objOpportunity{
                createMapFromSobjectfield(objOpportunity, keyNameInDataMap, mapFieldForOpportunity, sobjectKey);
            }
        }
    }
    public static void createMapFromSobjectfield(sObject objsobject, String keyNameInDataMap, Map<String, List<Object>> mapFieldForOpportunity, String sobjectKey){
        if(mapFieldForOpportunity.get(keyNameInDataMap) != null){
            mapFieldForOpportunity.get(keyNameInDataMap).add(objsobject.get(sobjectKey));
        }else{
            mapFieldForOpportunity.put(keyNameInDataMap, new List<Object>{objsobject.get(sobjectKey)});
        }
    }
    public static List<WWTypes.products> getProductsforPayload(List<Building__c> lstBuilding, List<Reservable__c> lstReservable){
        Map<String, List<Object>> mapArrayForPayloadProducts = new Map<String, List<Object>>();
        mapArrayForPayloadProducts.put('product_code', new List<Object>{'PRDE-000200','PRES-000300','PRHD-000400'});
        mapArrayForPayloadProducts.put('start_date', new List<Object>{Date.valueOf('2016-10-14'), Date.valueOf('2016-10-15'), Date.valueOf('2016-10-16')});
        mapArrayForPayloadProducts.put('quantity', new List<Object>{10, 20, 30, 40});
        mapArrayForPayloadProducts.put('unit_price', new List<Object>{10, 20, 30, 40});
        mapArrayForPayloadProducts.put('reservable_uuid', new List<Object>{lstReservable[0].UUID__c, lstReservable[1].UUID__c, lstReservable[2].UUID__c});
        mapArrayForPayloadProducts.put('building_uuid', new List<Object>{lstBuilding[0].UUID__c, lstBuilding[0].UUID__c, lstBuilding[0].UUID__c});
        List<Map<String, Object>> lstmapPayloadMapProducts = new List<Map<String, Object>>();
        TestingUtility.createRecordsWithFields(null, mapArrayForPayloadProducts, new Map<String, Object>{'createMap'=>true}, 3,lstmapPayloadMapProducts);
        List<WWTypes.products> lstproductss = (List<WWTypes.products>)JSON.deserialize(JSON.serialize(lstmapPayloadMapProducts), List<WWTypes.products>.class);
        return lstproductss;
    }
    
    public static List<WWTypes.move_outssVal> getMoveOutsforPayload(List<Building__c> lstBuilding, List<Reservable__c> lstReservable){
        Map<String, List<Object>> mapArrayForPayloadMoveOut = new Map<String, List<Object>>();
        mapArrayForPayloadMoveOut.put('move_out_date', new List<Object>{Date.valueOf('2016-10-14'), Date.valueOf('2016-10-15'), Date.valueOf('2016-10-16')});
        mapArrayForPayloadMoveOut.put('quantity', new List<Object>{10, 20, 30});
        mapArrayForPayloadMoveOut.put('price', new List<Object>{10, 20, 30});
        mapArrayForPayloadMoveOut.put('reservable_uuid', new List<Object>{lstReservable[0].UUID__c, lstReservable[1].UUID__c, lstReservable[2].UUID__c});
        mapArrayForPayloadMoveOut.put('building_uuid', new List<Object>{lstBuilding[0].UUID__c, lstBuilding[0].UUID__c, lstBuilding[0].UUID__c});
        List<Map<String, Object>> lstmapPayloadMapMoveOut = new List<Map<String, Object>>();
        TestingUtility.createRecordsWithFields(null, mapArrayForPayloadMoveOut, new Map<String, Object>{'createMap'=>true}, 3,lstmapPayloadMapMoveOut);
        List<WWTypes.move_outssVal> lstmove_outssVal = (List<WWTypes.move_outssVal>)JSON.deserialize(JSON.serialize(lstmapPayloadMapMoveOut), List<WWTypes.move_outssVal>.class);
        return lstmove_outssVal;
    }
    
    public static List<WWTypes.move_insVal> getMoveInsForPayload(List<Building__c> lstBuilding, List<Reservable__c> lstReservable){
        Map<String, List<Object>> mapArrayForPayloadMoveIn = new Map<String, List<Object>>();
        mapArrayForPayloadMoveIn.put('start_date', new List<Object>{Date.valueOf('2016-10-14'), Date.valueOf('2016-10-15'), Date.valueOf('2016-10-16')});
        mapArrayForPayloadMoveIn.put('quantity', new List<Object>{10, 20, 30});
        mapArrayForPayloadMoveIn.put('price', new List<Object>{10, 20, 30});
        mapArrayForPayloadMoveIn.put('reservable_uuid', new List<Object>{lstReservable[0].UUID__c, lstReservable[1].UUID__c, lstReservable[2].UUID__c});
        mapArrayForPayloadMoveIn.put('building_uuid', new List<Object>{lstBuilding[0].UUID__c, lstBuilding[1].UUID__c, lstBuilding[2].UUID__c});
        List<Map<String, Object>> lstmapPayloadMapMoveins = new List<Map<String, Object>>();
        TestingUtility.createRecordsWithFields(null, mapArrayForPayloadMoveIn, new Map<String, Object>{'createMap'=>true}, 3,lstmapPayloadMapMoveins);
        List<WWTypes.move_insVal> lstmove_insVal = (List<WWTypes.move_insVal>)JSON.deserialize(JSON.serialize(lstmapPayloadMapMoveins), List<WWTypes.move_insVal>.class);
        return lstmove_insVal;
    }
    
    public static List<WWTypes.Discounts> getDiscountsForPayload(List<Building__c> lstBuilding){
        Map<String, List<Object>> mapArrayForPayloadDiscount = new Map<String, List<Object>>();
        mapArrayForPayloadDiscount.put('start_date', new List<Object>{Date.valueOf('2016-10-14'), Date.valueOf('2016-10-15'), Date.valueOf('2016-10-16')});
        mapArrayForPayloadDiscount.put('end_date', new List<Object>{Date.valueOf('2016-10-14'), Date.valueOf('2016-10-15'), Date.valueOf('2016-10-16')});
        mapArrayForPayloadDiscount.put('amount', new List<Object>{10, 20, 30});
        mapArrayForPayloadDiscount.put('building_uuid', new List<Object>{lstBuilding[0].UUID__c, lstBuilding[0].UUID__c, lstBuilding[0].UUID__c});
        List<Map<String, Object>> lstmapPayloadMapDiscounts = new List<Map<String, Object>>();
        TestingUtility.createRecordsWithFields(null, mapArrayForPayloadDiscount, new Map<String, Object>{'createMap'=>true}, 3,lstmapPayloadMapDiscounts);
        List<WWTypes.Discounts> lstDiscounts = (List<WWTypes.Discounts>)JSON.deserialize(JSON.serialize(lstmapPayloadMapDiscounts), List<WWTypes.Discounts>.class);
        return lstDiscounts;
    }
    
    public static List<WWTypes.commitmentTerms> getCommitmentsForPayload(List<Building__c> lstBuilding){
        Map<String, List<Object>> mapArrayForPayloadCommitment = new Map<String, List<Object>>();
        mapArrayForPayloadCommitment.put('start_date', new List<Object>{Date.valueOf('2016-10-14'), Date.valueOf('2016-10-15'), Date.valueOf('2016-10-16')});
        mapArrayForPayloadCommitment.put('end_date', new List<Object>{Date.valueOf('2016-10-14'), Date.valueOf('2016-10-15'), Date.valueOf('2016-10-16')});
        mapArrayForPayloadCommitment.put('number_of_months', new List<Object>{12, 6, 12});
        mapArrayForPayloadCommitment.put('building_uuid', new List<Object>{lstBuilding[0].UUID__c, lstBuilding[1].UUID__c, lstBuilding[2].UUID__c});
        List<Map<String, Object>> lstmapPayloadMapcommitment = new List<Map<String, Object>>();
        TestingUtility.createRecordsWithFields(null, mapArrayForPayloadCommitment, new Map<String, Object>{'createMap'=>true}, 3,lstmapPayloadMapcommitment);
        List<WWTypes.commitmentTerms> lstcommitmentTerms  = (List<WWTypes.commitmentTerms>)JSON.deserialize(JSON.serialize(lstmapPayloadMapcommitment), List<WWTypes.commitmentTerms>.class);
        return lstcommitmentTerms;
    }
    
    public static WWTypes.ContractEvent getCompletePayloadForContract(String event_name, String company_uuid, String primary_member_email, String membership_agreement_uuid, String currencyVal, String contract_pdf, String contract_date, String transfer_type, String from_opportunity, String community_manager_uuid, String contract_expires_at, string opportunity_id, List<WWTypes.commitmentTerms> commitments, List<WWTypes.Discounts> discounts, List<WWTypes.products> products, List<WWTypes.move_insVal> move_ins, List<WWTypes.move_outssVal> move_outs){
        Map<String,Object> mapPayLoadValues = new Map<String,Object>();
        mapPayLoadValues.put('event_name', event_name);
        mapPayLoadValues.put('company_uuid', company_uuid);    
        mapPayLoadValues.put('primary_member_email', primary_member_email);    
        mapPayLoadValues.put('membership_agreement_uuid', membership_agreement_uuid);
        mapPayLoadValues.put('currencyVal', currencyVal);
        mapPayLoadValues.put('contract_pdf', contract_pdf);
        mapPayLoadValues.put('contract_date', contract_date);
        mapPayLoadValues.put('transfer_type', transfer_type);
        mapPayLoadValues.put('from_opportunity', from_opportunity);
        mapPayLoadValues.put('community_manager_uuid', community_manager_uuid);
        mapPayLoadValues.put('contract_expires_at',String.valueOf(contract_expires_at));
        mapPayLoadValues.put('commitments', commitments);
        mapPayLoadValues.put('discounts', discounts);
        mapPayLoadValues.put('products', products);
        mapPayLoadValues.put('move_ins', move_ins);
        mapPayLoadValues.put('move_outs', move_outs);
        mapPayLoadValues.put('opportunity_id', opportunity_id);        
        WWTypes.ContractEvent ObjContractEvent = (WWTypes.ContractEvent) JSON.Deserialize(JSON.serialize(mapPayLoadValues), WWTypes.ContractEvent.class);
       return ObjContractEvent;
    }
    
    public static WWTypes.ContractEvent getCompletePayloadForContract(String event_name, String company_uuid, String primary_member_email, String membership_agreement_uuid, String currencyVal, String contract_pdf, String contract_date, String transfer_type, String from_opportunity, String community_manager_uuid, String contract_expires_at, string opportunity_id, String reservation_uuid, List<WWTypes.commitmentTerms> commitments, List<WWTypes.Discounts> discounts, List<WWTypes.products> products, List<WWTypes.move_insVal> move_ins, List<WWTypes.move_outssVal> move_outs){
        Map<String,Object> mapPayLoadValues = new Map<String,Object>();
        mapPayLoadValues.put('event_name', event_name);
        mapPayLoadValues.put('company_uuid', company_uuid);    
        mapPayLoadValues.put('primary_member_email', primary_member_email);    
        mapPayLoadValues.put('membership_agreement_uuid', membership_agreement_uuid);
        mapPayLoadValues.put('currencyVal', currencyVal);
        mapPayLoadValues.put('contract_pdf', contract_pdf);
        mapPayLoadValues.put('contract_date', contract_date);
        mapPayLoadValues.put('transfer_type', transfer_type);
        mapPayLoadValues.put('from_opportunity', from_opportunity);
        mapPayLoadValues.put('community_manager_uuid', community_manager_uuid);
        mapPayLoadValues.put('contract_expires_at',String.valueOf(contract_expires_at));
        mapPayLoadValues.put('commitments', commitments);
        mapPayLoadValues.put('discounts', discounts);
        mapPayLoadValues.put('products', products);
        mapPayLoadValues.put('move_ins', move_ins);
        mapPayLoadValues.put('move_outs', move_outs);
        mapPayLoadValues.put('opportunity_id', opportunity_id);
        mapPayLoadValues.put('reservation_uuid', reservation_uuid);        
        WWTypes.ContractEvent ObjContractEvent = (WWTypes.ContractEvent) JSON.Deserialize(JSON.serialize(mapPayLoadValues), WWTypes.ContractEvent.class);
        return ObjContractEvent;
    }
    
    public static Opportunity getOpportunityAfterContractRequest(Id OpportunityId){            
        List<String> lstInnerQueries = new List<String>();
        lstInnerQueries.add('(SELECT '+String.join(lstLineItemFieldsForAssert, ',')+' FROM OpportunityLineItems)');
        lstInnerQueries.add('(SELECT '+String.join(lstMoveInsFieldsForAssert, ',')+' FROM Opportunity_Offices__r)');
        lstInnerQueries.add('(SELECT '+String.join(lstMoveOutsFieldsForAssert, ',')+' FROM Opportunity_Move_Outs__r)');
        lstInnerQueries.add('(SELECT '+String.join(lstCommitmentFieldsForAssert, ',')+' FROM commitment_Terms__r)');
        lstInnerQueries.add('(SELECT '+String.join(lstDiscountsFieldsForAssert, ',')+' FROM Discounts__r)');
        lstInnerQueries.add('(SELECT '+String.join(lstSellableFieldsForAssert, ',')+' FROM Sellable_Opportunity_Products__r)');
        List<Opportunity> lstOpportunity = Database.query('SELECT '+ String.join(lstOpportunityFieldsForAssert, ',')+ ','+ String.join(lstInnerQueries, ',') + ' FROM Opportunity WHERE Id =: OpportunityId');
        System.assert(lstOpportunity.size() > 0);
        return lstOpportunity[0];
    }
    
    public static void payloadAssertion(WWTypes.ContractEvent objContractEvent, Opportunity objOpportunity, String changedCurrency){
        String event_name = objContractEvent.event_name.toLowerCase();
        System.assertEquals(objContractEvent.transfer_type, objOpportunity.Contract_Type__c);
        
        if(String.isBlank(objContractEvent.reservation_uuid)){//For hot desk from_opp is not passed in payload.
           System.assertEquals((String.isNotBlank(objContractEvent.from_opportunity)) ? Id.valueOf(objContractEvent.from_opportunity) : null, objOpportunity.Old_Opportunity__c); 
        }
        switch on event_name { 
            when 'contract sent' {	
                System.assertEquals(objContractEvent.event_name, objOpportunity.Contract_Stage__c);
                System.assertEquals('Closing', objOpportunity.StageName);
                System.assertEquals(String.isNotBlank(objContractEvent.contract_date) ? Date.ValueOf(objContractEvent.contract_date) : null, objOpportunity.Paperwork_Sent_On_Date__c);
                System.assertEquals(String.isNotBlank(objContractEvent.contract_expires_at) ? DateTime.valueOfGmt(objContractEvent.contract_expires_at) : null, objOpportunity.Contract_Expiration__c);
                System.assertEquals(objContractEvent.membership_agreement_uuid, objOpportunity.Contract_UUID__c);
            }	
            when 'contract signed' {
                System.assertEquals('Closed Won', objOpportunity.StageName); 
                if(String.isNotBlank(objContractEvent.reservation_uuid)){
                    System.assertEquals(objContractEvent.reservation_uuid, objOpportunity.Reservation_UUID__c);
                    System.assertEquals(objContractEvent.lead_source, objOpportunity.LeadSource);
                    System.assertEquals(objContractEvent.lead_source_detail, objOpportunity.lead_source_detail__c);
                    System.assertEquals(objContractEvent.lead_source, objOpportunity.Primary_Member__r.LeadSource);
                    System.assertEquals(objContractEvent.lead_source_detail, objOpportunity.Primary_Member__r.Lead_Source_Detail__c);
                }else{
                    System.assertEquals(objContractEvent.membership_agreement_uuid, objOpportunity.Contract_UUID__c);
                    System.assertEquals(objContractEvent.event_name, objOpportunity.Contract_Stage__c);  
                }
            }
            when 'contract canceled'{
                System.assertEquals(objContractEvent.event_name, objOpportunity.Contract_Stage__c);
                System.assertEquals(String.isNotBlank(objContractEvent.contract_date) ? Date.ValueOf(objContractEvent.contract_date) : null, objOpportunity.Contract_Canceled_On_Date__c);
                if(String.isNotBlank(objContractEvent.reservation_uuid)){
                    if((objContractEvent.move_ins == null || objContractEvent.move_ins.size() == 0) && (objContractEvent.move_outs != null && objContractEvent.move_outs.size() > 0)){
                        System.assertEquals('Closed Lost', objOpportunity.StageName);
                    }
                    System.assertEquals(objContractEvent.lead_source, objOpportunity.LeadSource);
                    System.assertEquals(objContractEvent.lead_source_detail, objOpportunity.lead_source_detail__c);
                }else{
                    System.assertEquals(null, objOpportunity.Contract_UUID__c);
                    System.assertEquals('Closing', objOpportunity.StageName);
                    System.assertEquals(objContractEvent.membership_agreement_uuid, objOpportunity.Original_Contract_UUID__c); 
                }
            }
            when 'contract voided'{
                System.assertEquals('Closing', objOpportunity.StageName);
                System.assertEquals(Date.valueOf(objContractEvent.contract_date), objOpportunity.Contract_Voided_Discarded_On_Date__c); 
            }
        }       
        if(String.isNotBlank(objContractEvent.opportunity_id)){
            if(objContractEvent.move_ins != null && objContractEvent.move_ins.size() > 0 && event_name != 'cancel moveout' && event_name != 'contract canceled' && event_name != 'contract voided' && event_name != 'contract discarded'){
                payloadAssertionMoveins(objContractEvent, objOpportunity);
            } 
            if(objContractEvent.products != null && objContractEvent.products.size() > 0 && event_name != 'cancel moveout' && event_name != 'contract canceled' && event_name != 'contract voided' && event_name != 'contract discarded'){
                payloadAssertionProducts(objContractEvent, objOpportunity, changedCurrency);
            }
            if(objContractEvent.move_outs != null && objContractEvent.move_outs.size() > 0 && event_name != 'contract canceled' && event_name != 'contract voided' && event_name != 'contract discarded'){
                payloadAssertionMoveOuts(objContractEvent, objOpportunity);
            }
            if(objContractEvent.discounts != null && objContractEvent.discounts.size() > 0 && event_name != 'cancel moveout' && event_name != 'contract canceled' && event_name != 'contract voided' && event_name != 'contract discarded'){
                payloadAssertionDiscounts(objContractEvent, objOpportunity);
            }
            if(objContractEvent.commitments != null && objContractEvent.commitments.size() > 0 && event_name != 'cancel moveout' && event_name != 'contract canceled' && event_name != 'contract voided' && event_name != 'contract discarded'){
                payloadAssertionCommitments(objContractEvent, objOpportunity);
            }
        }else{
            if(objContractEvent.move_ins != null && objContractEvent.move_ins.size() > 0){
                payloadAssertionMoveins(objContractEvent, objOpportunity);
            } 
            if(objContractEvent.products != null && objContractEvent.products.size() > 0){
                payloadAssertionProducts(objContractEvent, objOpportunity, changedCurrency);
            }
            if(objContractEvent.move_outs != null && objContractEvent.move_outs.size() > 0){
                payloadAssertionMoveOuts(objContractEvent, objOpportunity);
            }
            if(objContractEvent.discounts != null && objContractEvent.discounts.size() > 0){
                payloadAssertionDiscounts(objContractEvent, objOpportunity);
            }
            if(objContractEvent.commitments != null && objContractEvent.commitments.size() > 0){
                payloadAssertionCommitments(objContractEvent, objOpportunity);
            }
        }
    }
    
    public static void payloadAssertionMoveins(WWTypes.ContractEvent objContractEvent, Opportunity objOpportunity){
        Map<String, WWtypes.move_insVal> mapReservableUUIDFromPayload = new Map<String, WWtypes.move_insVal>();
        Set<String> setBuildingUUIDs = new Set<String>();
        
        System.assert(objContractEvent.move_ins.size() == objOpportunity.Opportunity_Offices__r.size(), 'Some Move Ins not inserted from payload');   
        
        for(WWtypes.move_insVal objmoveIn : objContractEvent.move_ins){
            mapReservableUUIDFromPayload.put(objmoveIn.reservable_uuid, objmoveIn);
            setBuildingUUIDs.add(objmoveIn.building_uuid);
        }
        Map<String, Building__c> mapBuildingsInPayload = new Map<String, Building__c>();
        for(Building__c building : [SELECT Id, UUID__c FROM Building__c WHERE UUID__c IN: setBuildingUUIDs]){
            mapBuildingsInPayload.put(building.UUID__c, building);
        }
        Map<String, Commitment_Term__c> mapCommitmentTermsInSystem = new Map<String, Commitment_Term__c>();
        Map<String, WWTypes.commitmentTerms> mapCommitmentTermsInPayload = new Map<String, WWTypes.commitmentTerms>();
        if(objContractEvent.commitments != null && objContractEvent.commitments.size() > 0){
            for(Commitment_Term__c commitment : [SELECT Id, Building_UUID__c FROM Commitment_Term__c WHERE Opportunity__c =: objOpportunity.Id]){
                mapCommitmentTermsInSystem.put(commitment.Building_UUID__c, commitment);
            }
            for(WWTypes.commitmentTerms objCommit : objContractEvent.commitments){
                mapCommitmentTermsInPayload.put(objCommit.building_uuid, objCommit);
            }
        }
        Map<String, Reservable__c> mapReservablesInSystem = new Map<String, Reservable__c>();
        for(Reservable__c reservable : [SELECT Id, UUID__c FROM Reservable__c WHERE UUID__c IN: mapReservableUUIDFromPayload.keySet()]){
            mapReservablesInSystem.put(reservable.UUID__c, reservable);
        }
        WWtypes.move_insVal objMoveIn;
        for(Opportunity_Reservable__c objOppReservable : objOpportunity.Opportunity_Offices__r){
            objMoveIn = mapReservableUUIDFromPayload.get(objOppReservable.Reservable__r.UUID__c);
            system.assertNotEquals(null, objMoveIn, 'Opportunity Reservable Not Inserted with UUID '+objMoveIn.reservable_uuid);
            system.assertEquals(Decimal.valueOf(objMoveIn.price), objOppReservable.Monthly_Price__c);
            system.assertEquals(Decimal.valueOf(objMoveIn.quantity), objOppReservable.Pending_Desks__c);
            system.assertEquals(mapReservablesInSystem.get(objMoveIn.reservable_uuid).Id, objOppReservable.Reservable__c);
            system.assertEquals(Date.valueOf(objMoveIn.start_date), objOppReservable.Start_Date__c);
            if(objContractEvent.commitments != null && objContractEvent.commitments.size() > 0 &&  mapCommitmentTermsInPayload.get(objOppReservable.Reservable__r.Building__r.UUID__c).building_uuid == mapCommitmentTermsInSystem.get(objOppReservable.Reservable__r.Building__r.UUID__c).Building_UUID__c){
                system.assertEquals(objOppReservable.Commitment_Term__c, mapCommitmentTermsInSystem.get(objOppReservable.Reservable__r.Building__r.UUID__c).Id);
            }
        }
    }
    public static void payloadAssertionProducts(WWTypes.ContractEvent objContractEvent, Opportunity objOpportunity, String oldCurrency){
        ContractEventUtilities.ContractEventUtilitySetting objContractEventUtility = (ContractEventUtilities.ContractEventUtilitySetting)JSON.deserialize(Settings.get('ContractEventUtility').Data__c, ContractEventUtilities.ContractEventUtilitySetting.class);
        Set<String> setConsidered = new Set<String>();
        for(String productCode : objContractEventUtility.ConsideredProductCodes){
            setConsidered.add(productCode.toLowerCase());
        }
        List<OpportunityLineItem> lstOpportunityLineItemUnConsidered = new List<OpportunityLineItem>();
        List<OpportunityLineItem> lstOpportunityLineItemConsidered = new List<OpportunityLineItem>();
        for(OpportunityLineItem objLineItem : objOpportunity.OpportunityLineItems){
            if(!setConsidered.contains(objLineItem.ProductCode.toLowerCase())){
                lstOpportunityLineItemUnConsidered.add(objLineItem);
            }else{
                lstOpportunityLineItemConsidered.add(objLineItem);
            }
        }
        Boolean ConsiderSeparation = false;
        for(WWTypes.products objProduct : objContractEvent.products){
            if(objProduct.product_code.tolowerCase() == objContractEventUtility.DealProductCode.tolowerCase()){
                ConsiderSeparation = true;
                break;
            }
        }
         List<WWTypes.products> lstSellableProducts;
        if(ConsiderSeparation){
            lstSellableProducts = new List<WWTypes.products>();
            List<WWTypes.products> lstDealProducts = new List<WWTypes.products>();
            for(WWTypes.products objProduct : objContractEvent.products){
                if(objProduct.product_code.tolowerCase() == objContractEventUtility.DealProductCode.tolowerCase()){
                   lstDealProducts.add(objProduct); 
                }else{
                    lstSellableProducts.add(objProduct);
                }
            } 
            objContractEvent.products.clear();
            objContractEvent.products.addAll(lstDealProducts);
        }
        
        if(lstOpportunityLineItemUnConsidered.size() > 0){
            System.assert(objContractEvent.products.size() < objOpportunity.OpportunityLineItems.size()); 
        }else if(!ConsiderSeparation){
            System.assert(objContractEvent.products.size() == objOpportunity.OpportunityLineItems.size(), 'Some Products not inserted from payload');
        }
        if(lstOpportunityLineItemUnConsidered.size() > 0){
            for(OpportunityLineItem objLineItem : lstOpportunityLineItemUnConsidered){
                system.assertEquals(0.78, objLineItem.UnitPrice.setScale(2, RoundingMode.HALF_UP));
            }
        }
        Map<String, Building__c> mapUUIDBuildingInSystem = new Map<String, Building__c>();
        Set<String> setbuildingUUIDS = new set<String>();
        for(WWTypes.products objProducts : objContractEvent.products){
            setbuildingUUIDS.add(objProducts.building_uuid);
        }
        for(Building__c objBuilding : [SELECT Id, UUID__c FROM Building__c WHERE UUID__c In : setbuildingUUIDS]){
            mapUUIDBuildingInSystem.put(objBuilding.UUID__c, objBuilding); 
        }
        if(lstSellableProducts != null && lstSellableProducts.Size() > 0){
            payloadAssertionSellable(lstSellableProducts, objContractEvent, mapUUIDBuildingInSystem, objOpportunity);
        }
        List<WWTypes.products> tempLstProducts = new List<WWTypes.products>();
        tempLstProducts.addall(objContractEvent.products);       
        for(OpportunityLineItem objLineItem : lstOpportunityLineItemConsidered){
            Debug.Log('objLineItem---'+objLineItem);
            for(Integer Index = 0; index < tempLstProducts.size(); Index++){
                Debug.Log('tempLstProducts---'+tempLstProducts[Index]);
                System.assertEquals(Decimal.valueOf(tempLstProducts[Index].quantity),objLineItem.Quantity);
                System.assertEquals(Decimal.valueOf(tempLstProducts[Index].unit_price), objLineItem.UnitPrice);
                System.assertEquals(tempLstProducts[Index].building_uuid, objLineItem.Building_UUID__c);
                System.assertEquals(mapUUIDBuildingInSystem.get(tempLstProducts[Index].building_uuid).Id, objLineItem.Building__c);
                tempLstProducts.remove(Index);
                break;
            }
        }
    }
    
    public static void payloadAssertionSellable(List<WWTypes.products> lstSellableProducts, WWTypes.ContractEvent objContractEvent, Map<String, Building__c> mapUUIDBuildingInSystem, Opportunity objOpportunity){
        List<WWTypes.products> tempLstProducts = new List<WWTypes.products>();
        tempLstProducts.addall(lstSellableProducts);
        for(Sellable_Opportunity_Product__c objSellable : objOpportunity.Sellable_Opportunity_Products__r){
            for(Integer Index = 0; index < tempLstProducts.size(); Index++){
                System.assertEquals(Decimal.valueOf(tempLstProducts[Index].quantity),objSellable.Quantity__c);
                System.assertEquals(Decimal.valueOf(tempLstProducts[Index].unit_price), objSellable.Unit_Price__c);
                System.assertEquals(tempLstProducts[Index].building_uuid, objSellable.Building_UUID__c);
                System.assertEquals(mapUUIDBuildingInSystem.get(tempLstProducts[Index].building_uuid).Id, objSellable.Building__c);
                System.assertEquals(Decimal.valueOf(tempLstProducts[Index].unit_price) * Decimal.valueOf(tempLstProducts[Index].quantity), objSellable.Total_Price__c);
                tempLstProducts.remove(Index);
                break;
            }
        }
    }
    
    public static void payloadAssertionMoveOuts(WWTypes.ContractEvent objContractEvent, Opportunity objOpportunity){
        Map<String, WWtypes.move_outssVal> mapReservableUUIDFromPayload = new Map<String, WWtypes.move_outssVal>();
        if(objContractEvent.event_name.toLowerCase() != 'cancel moveout'){
            System.assert(objContractEvent.move_outs.size() == objOpportunity.Opportunity_Move_Outs__r.size(), 'Some Move Outs not inserted from payload');
        }
        for(WWtypes.move_outssVal objmoveOut : objContractEvent.move_outs){
            mapReservableUUIDFromPayload.put(objmoveOut.reservable_uuid, objmoveOut);
        }
        Map<String, Reservable__c> mapReservablesInSystem = new Map<String, Reservable__c>();
        for(Reservable__c reservable : [SELECT Id, UUID__c FROM Reservable__c WHERE UUID__c IN: mapReservableUUIDFromPayload.keySet()]){
            mapReservablesInSystem.put(reservable.UUID__c, reservable);
        } 
        WWtypes.move_outssVal objmoveOut;
        for(Opportunity_Move_Outs__c objOppMoveOut : objOpportunity.Opportunity_Move_Outs__r){
            if(objContractEvent.event_name.toLowerCase() != 'cancel moveout'){
                objmoveOut = mapReservableUUIDFromPayload.get(objOppMoveOut.Reservable__r.UUID__c);
                system.assertNotEquals(null, objmoveOut, 'Opportunity Reservable Not Inserted with UUID '+objmoveOut.reservable_uuid);
                system.assertEquals(Decimal.valueOf(objmoveOut.price), objOppMoveOut.Monthly_Price__c);
                system.assertEquals(Decimal.valueOf(objmoveOut.quantity), objOppMoveOut.Pending_Desks__c);
                system.assertEquals(Date.valueOf(objmoveOut.move_out_date), objOppMoveOut.Move_Out_Date__c);
                system.assertEquals(mapReservablesInSystem.get(objmoveOut.reservable_uuid).Id, objOppMoveOut.Reservable__c); 
            }
            if(objContractEvent.event_name.toLowerCase() == 'cancel moveout'){
                system.assertEquals('Cancel', objOppMoveOut.Status__c);
            }else{
                system.assertEquals('Active', objOppMoveOut.Status__c);
            }
        }
    }
    public static void payloadAssertionDiscounts(WWTypes.ContractEvent objContractEvent, Opportunity objOpportunity){
        
        System.assert(objContractEvent.discounts.size() == objOpportunity.Discounts__r.size(), 'Some discounts not inserted from payload');
        Map<String, Building__c> mapUUIDBuildingInSystem = new Map<String, Building__c>();
        Set<String> setbuildingUUIDS = new set<String>();
        for(WWTypes.Discounts objDiscount : objContractEvent.discounts){
            setbuildingUUIDS.add(objDiscount.building_uuid);
        }
        for(Building__c objBuilding : [SELECT Id, UUID__c FROM Building__c WHERE UUID__c In : setbuildingUUIDS]){
            mapUUIDBuildingInSystem.put(objBuilding.UUID__c, objBuilding); 
        }
        List<WWTypes.Discounts> tempLstDiscounts = new List<WWTypes.Discounts>();
        tempLstDiscounts.addall(objContractEvent.discounts);
        for(Discount__c objOppDiscount : objOpportunity.Discounts__r){
            for(Integer Index = 0; index < tempLstDiscounts.size(); Index++){
                System.assertEquals('Commitment Term', objOppDiscount.Discount_Type__c);
                System.assertEquals(Decimal.valueOf(tempLstDiscounts[Index].amount), objOppDiscount.Amount__c);
                System.assertEquals(Date.valueOf(tempLstDiscounts[Index].start_date),objOppDiscount.Start_Date__c);
                System.assertEquals(Date.valueOf(tempLstDiscounts[Index].end_date), objOppDiscount.End_Date__c);
                System.assertEquals(tempLstDiscounts[Index].building_uuid, objOppDiscount.Building_UUID__c);
                System.assertEquals(mapUUIDBuildingInSystem.get(tempLstDiscounts[Index].building_uuid).Id, objOppDiscount.Building__c);
                tempLstDiscounts.remove(Index);
                break;
            }
        }
    }
    public static void payloadAssertionCommitments(WWTypes.ContractEvent objContractEvent, Opportunity objOpportunity){
        System.assert(objContractEvent.discounts.size() == objOpportunity.Discounts__r.size(), 'Some commitments not inserted from payload');
        Map<String, Building__c> mapUUIDBuildingInSystem = new Map<String, Building__c>();
        Set<String> setbuildingUUIDS = new set<String>();
        for(WWTypes.commitmentTerms objCommitment : objContractEvent.commitments){
            setbuildingUUIDS.add(objCommitment.building_uuid);
        }
        for(Building__c objBuilding : [SELECT Id, UUID__c FROM Building__c WHERE UUID__c In : setbuildingUUIDS]){
            mapUUIDBuildingInSystem.put(objBuilding.UUID__c, objBuilding); 
        }
        List<WWTypes.commitmentTerms> tempLstCommitmentTerms = new List<WWTypes.commitmentTerms>();
        tempLstCommitmentTerms.addall(objContractEvent.commitments);
        for(commitment_Term__c objcommitmentTerm : objOpportunity.commitment_Terms__r){
            for(Integer Index = 0; index < tempLstCommitmentTerms.size(); Index++){
                System.assertEquals(Decimal.valueOf(tempLstCommitmentTerms[Index].number_of_months), objcommitmentTerm.Commitment_Term_in_Months__c);
                System.assertEquals(Date.valueOf(tempLstCommitmentTerms[Index].start_date),objcommitmentTerm.Commitment_Start_Date__c);
                System.assertEquals(Date.valueOf(tempLstCommitmentTerms[Index].end_date), objcommitmentTerm.Commitment_End_Date__c);
                System.assertEquals(tempLstCommitmentTerms[Index].building_uuid, objcommitmentTerm.Building_UUID__c);
                System.assertEquals(mapUUIDBuildingInSystem.get(tempLstCommitmentTerms[Index].building_uuid).Id, objcommitmentTerm.Building__c);
                tempLstCommitmentTerms.remove(Index);
                break;
            }
        }
    }
    
    public static String extractIdFromResultInContractEvent(String contractEventResult){
        String [] arrStr = contractEventResult.split(':');       
        arrStr[1] = arrStr[1].removeEnd('"');
        String OpportunityId = arrStr[1].Trim();        
        return OpportunityId;
    }
    
    public static RESTContractEvent.Response callOutToContractEventEndPoint(WWTypes.ContractEvent objContractEvent){        
        Test.startTest();
        RestRequest req     = new RestRequest(); 
        RestResponse res    = new RestResponse();        
        req.requestURI = '/services/apexrest/contractEvent';  
        req.httpMethod = 'POST';       
        RestContext.request     = req;
        RestContext.response    = res;
        RESTContractEvent.Response response = RESTContractEvent.doPost(objContractEvent);       
        Test.StopTest();
        return response;
    }

}