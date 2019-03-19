/**
* Name			:	ContractEventUtilities	 
* Issue No.		: 	CSI-492 
* Purpose		:	This is used to parse payload of contract event and create necessary data for further processing
* History		
	Version			Author				Date			Detail						Feature			IssueNumber
	1.0				Mayuresh Ghodke		1/1/2018		Initial Development
	2.0				Shobhit Gahlot		9/1/2018		Payload structure Change	Sellable		CSI-441
***********************************************************************************************************************************************************
*/ 
global class ContractEventUtilities {
    Static String emailDomain;
    Static Set<String> setDomains;
    public static ContractEventUtilitiesVal utilityWrapperInitialize (WWTypes.ContractEvent objContractEvent){
        setDomains = new set<String>();
        UtilityWapper objUtilityWapper = new UtilityWapper();
        if(objContractEvent.from_opportunity != null && objContractEvent.from_opportunity != ''){
            if(objContractEvent.from_opportunity.length() == 15 || objContractEvent.from_opportunity.length() == 18){
                objUtilityWapper.lstOppFromOpp = [Select Id, Contract_UUID__c From Opportunity Where Id =: objContractEvent.from_opportunity];
                if(objUtilityWapper.lstOppFromOpp != null && objUtilityWapper.lstOppFromOpp.size()>0)
                    objUtilityWapper.fromOpp = objUtilityWapper.lstOppFromOpp[0].Id;
            }
            else{
                objUtilityWapper.lstOppFromOpp = [Select Id, Contract_UUID__c From Opportunity Where Contract_UUID__c =: objContractEvent.from_opportunity];
                if(objUtilityWapper.lstOppFromOpp != null && objUtilityWapper.lstOppFromOpp.size()>0)
                    objUtilityWapper.fromOpp = objUtilityWapper.lstOppFromOpp[0].Id;
            }
        }

        if(objContractEvent.currencyVal == '' || objContractEvent.currencyVal == null){
            objContractEvent.currencyVal = 'USD';
        }else{
            objContractEvent.currencyVal = objContractEvent.currencyVal.toUpperCase();
        }
        if(Settings.get('ContractEndpointOpportunityStages') != null){
            objUtilityWapper.lstOppStages = (List<String>)JSON.deserialize(Settings.get('ContractEndpointOpportunityStages').Data__c,List<String>.class);
        }else{
            objUtilityWapper.lstOppStages = new List<String>{'Closed Won','Closed Lost','Merged'};
        }       
        objUtilityWapper.setCloseStage.addAll(objUtilityWapper.lstOppStages);
        
        if(settings.get('ContractEventUtility') != null){
            objUtilityWapper.objContractEventUtilitySetting = (ContractEventUtilitySetting)JSON.deserialize(Settings.get('ContractEventUtility').Data__c,ContractEventUtilitySetting.class);
        } 
        Debug.log('objUtilityWapper.objContractEventUtilitySetting '+objUtilityWapper.objContractEventUtilitySetting);
        if(objUtilityWapper.objContractEventUtilitySetting != null && !objUtilityWapper.objContractEventUtilitySetting.LostReason.isEmpty()){
            for(Map<String,String> mapSetting : objUtilityWapper.objContractEventUtilitySetting.LostReason){
                objUtilityWapper.mapCloseLostReason.put(mapSetting.get('Event').toLowerCase(),mapSetting.get('Reason'));
            }
        }
        Debug.log('objUtilityWapper.mapCloseLostReason :: '+objUtilityWapper.mapCloseLostReason);
        if(objUtilityWapper.objContractEventUtilitySetting != null && objUtilityWapper.objContractEventUtilitySetting.ConsideredDiscounts != null){
            Set<String> setLowerCase = new Set<String>();
            for(String consideredDiscount : objUtilityWapper.objContractEventUtilitySetting.ConsideredDiscounts){
                setLowerCase.add(consideredDiscount.toLowerCase());
            }
            objUtilityWapper.objContractEventUtilitySetting.ConsideredDiscounts.addAll(setLowerCase);
        }
        Setting__c objSetting = Settings.get('PublicDomainSettings');
        if(objSetting != null){
            setDomains = (Set<String>)JSON.deserialize(objSetting.Data__c.toLowerCase(),Set<String>.class); 
        }
		ContractEventDiscountsHandler.buildingUUIDExtractorFromPayload(objContractEvent, objUtilityWapper);
        
        Debug.log('objUtilityWapper.setPayloadBuildingUUID after Discounts :: '+objUtilityWapper.setPayloadBuildingUUID);

        ContractEventMoveInsHandler.utilityWrapperInitializerForMoveIns(objContractEvent, objUtilityWapper);
            
        Debug.log('after Move Ins :: '+'setPayloadBuildingUUID ::'+objUtilityWapper.setPayloadBuildingUUID+'latestDate ::'+objUtilityWapper.latestDate+'setPayloadReservableUuid::'+objUtilityWapper.setPayloadReservableUuid+'mapPayloadReservable::'+objUtilityWapper.mapPayloadReservable+'opportunityBuildingUUID ::'+objUtilityWapper.opportunityBuildingUUID);
        
        ContractEventMoveOutsHandler.utilityWrapperInitializerForMoveOuts(objContractEvent, objUtilityWapper);
        Debug.log('after Move Outs  :: '+'setPayloadBuildingUUID ::'+objUtilityWapper.setPayloadBuildingUUID+'setMoveOutPayloadReservableUuid::'+objUtilityWapper.setMoveOutPayloadReservableUuid+'mapPayloadReservableMoveOut::'+objUtilityWapper.mapPayloadReservableMoveOut+'opportunityBuildingUUID ::'+objUtilityWapper.opportunityBuildingUUID+'opportunityBuildingMoveOutUUID::'+objUtilityWapper.opportunityBuildingMoveOutUUID);      
        
        validateReservables(objUtilityWapper);
        
        Map<String,List<WWTypes.products>>  mapProducsWithBuilding = new Map<String,List<WWTypes.products>>();
        Set<String> setProductCodes = new Set<String>();
        debug.log('objContractEvent.products ContractEventUtilities ::'+objContractEvent.products);
        
        if(objContractEvent.products != null && objContractEvent.products.size() > 0){
            for(WWTypes.products product : objContractEvent.products){
                if(String.isNotBlank(product.building_uuid)){
                    objUtilityWapper.setPayloadBuildingUUID.add(product.building_uuid);
                    if(objContractEvent.commitments != null && objContractEvent.commitments.size() > 0){
                        if(mapProducsWithBuilding.containsKey(product.building_uuid)){
                            mapProducsWithBuilding.get(product.building_uuid).add(product);
                        }else{
                            mapProducsWithBuilding.put(product.building_uuid, new List<WWTypes.products> {product});        
                        }
                    }
                }
                if(string.isNotBlank(product.product_code) && product.product_code == objUtilityWapper.objContractEventUtilitySetting.DealProductCode){
                    objUtilityWapper.considerSellableProductSeparation = true;
                }
                if(string.isNotBlank(product.quantity)){
                    objUtilityWapper.totalProduct += Decimal.valueOf(product.quantity);
                }  
            }
            if(objUtilityWapper.opportunityBuildingUUID == null){
                objUtilityWapper.opportunityBuildingUUID =  objContractEvent.products[0].building_uuid;
            } 
        }
        Debug.log('mapProducsWithBuilding for commitment calculation::'+mapProducsWithBuilding);
        
        ContractEventUtilitiesVal objForSellable;
        if(objUtilityWapper.considerSellableProductSeparation){
           objForSellable = ContractEventSellableHandler.separateProductsForSellable(objUtilityWapper,objContractEvent);
        }else{
            objUtilityWapper.lstALLProducts = objContractEvent.products;
        }

        if(objForSellable != null){
           objContractEvent = objForSellable.objContractEvent;
           objUtilityWapper = objForSellable.objUtilityWapper;
        }
        
        debug.log('objUtilityWapper.setPayloadBuildingUUID after products array ::'+objUtilityWapper.setPayloadBuildingUUID);
        
        ContractEventCommitmentHandler.utilityWrapperInitializerCommitment(objContractEvent, objUtilityWapper, mapProducsWithBuilding);
            
        debug.log('objUtilityWapper.setPayloadBuildingUUID after commitments array ::'+objUtilityWapper.setPayloadBuildingUUID);
        Debug.log('objUtilityWapper.CommitmentTermInMonthsForopp ::'+objUtilityWapper.CommitmentTermInMonthsForopp);
        if(objUtilityWapper.setPayloadBuildingUUID != null && objUtilityWapper.setPayloadBuildingUUID.size() > 0){
            for(Building__c objBuiding : [SELECT Id, Name, UUID__c,Responsible_CM__c FROM Building__c WHERE UUID__c IN : objUtilityWapper.setPayloadBuildingUUID]){
                objUtilityWapper.mapAllPayloadBuildings.put(objBuiding.UUID__c, objBuiding);
            }
        }
        debug.log('objUtilityWapper.mapAllPayloadBuildings ::'+objUtilityWapper.mapAllPayloadBuildings);
        
        if(objContractEvent.move_ins != null){
            for(WWTypes.move_insVal obj : objContractEvent.move_ins){
                if(obj.building_uuid != null && objUtilityWapper.mapAllPayloadBuildings.containsKey(obj.building_uuid)){
                   objUtilityWapper.lstBuilding.add(objUtilityWapper.mapAllPayloadBuildings.get(obj.building_uuid)); 
                   objUtilityWapper.setBuildingUuid.add(obj.building_uuid);
                }     
            }
        }
        Debug.log('objUtilityWapper.setBuildingUuid ::'+objUtilityWapper.setBuildingUuid);
        if(String.isNotBlank(objContractEvent.community_manager_uuid) || String.isNotBlank(objContractEvent.primary_member_email)){
            String communityManager = (String.isNotBlank(objContractEvent.community_manager_uuid))? objContractEvent.community_manager_uuid : null;
            string emailDomain = (objContractEvent.primary_member_email.split('@').size() == 2)? objContractEvent.primary_member_email.split('@')[1] : null;
            
            List<sObject> lstContactAndMembers;
            lstContactAndMembers = getContactAndMemberQuery(new List<String>{'Email','Email_Domain__c','UUID__c','Account_Name__c','AccountId','FirstName','LastName','Name','Account.Parent_Org_Id__c','Account.ParentId','Company__c','Unomy_Company_ID__c','Unomy_Company_Name__c','Cleansed_Unomy_Company_Name__c','Account.Account_Type__c','Cleansed_Company_Name__c','LeadSource','Lead_Source_Detail__c'}, 'Contact', objContractEvent.community_manager_uuid,objContractEvent.primary_member_email);

            Debug.log('lstContactAndMembers data==>'+lstContactAndMembers);
            objUtilityWapper.mapContactsMembers = new Map<String, Map<String,Contact>>();
            Boolean contactFoundWithDomain = true;
            for(sObject record : lstContactAndMembers){
                if(record.get('UUID__c') == objContractEvent.community_manager_uuid){
                    if(String.valueOf(record.get('Id')).toLowerCase().startsWith('003')){
                        if(objUtilityWapper.mapContactsMembers.get('Contact') != null){
                            objUtilityWapper.mapContactsMembers.get('Contact').put('CommunityManagerUUIDInContact',(Contact)record);
                        }else{
                          objUtilityWapper.mapContactsMembers.put('Contact',new Map<String,Contact>{'CommunityManagerUUIDInContact'=>(Contact)record});  
                        }
                    }
                }
                if(record.get('Email') == objContractEvent.primary_member_email){
                    if(String.valueOf(record.get('Id')).toLowerCase().startsWith('003')){
                        if(objUtilityWapper.mapContactsMembers.get('Contact') != null){
                            objUtilityWapper.mapContactsMembers.get('Contact').put('PrimaryMemberEmailInContact',(Contact)record);
                        }else{
                          objUtilityWapper.mapContactsMembers.put('Contact',new Map<String,Contact>{'PrimaryMemberEmailInContact'=>(Contact)record});  
                        }
                    }
                }
                if(contactFoundWithDomain && record.get('Email_Domain__c') == emailDomain && record.get('AccountId') != null && !setDomains.contains(emailDomain.toLowerCase())){
                    if(String.valueOf(record.get('Id')).toLowerCase().startsWith('003')){
                        if(objUtilityWapper.mapContactsMembers.get('Contact') != null){
                            objUtilityWapper.mapContactsMembers.get('Contact').put('PrimaryMemberDomainInContact',(Contact)record);
                        }else{
                          objUtilityWapper.mapContactsMembers.put('Contact',new Map<String,Contact>{'PrimaryMemberDomainInContact'=>(Contact)record});  
                        }
                        contactFoundWithDomain = false;
                    }
                }
            }
        }
        Debug.log('objUtilityWapper.mapContactsMembers ::'+objUtilityWapper.mapContactsMembers);
        ContractEventUtilitiesVal objContractEventUtilitiesVal = new ContractEventUtilitiesVal();
        objContractEventUtilitiesVal.objContractEvent = objContractEvent;
        objContractEventUtilitiesVal.objUtilityWapper = objUtilityWapper;
        
        return objContractEventUtilitiesVal;
    }
    global Class ContractEventUtilitiesVal{
        public WWTypes.ContractEvent objContractEvent;
        public UtilityWapper objUtilityWapper;
    }
    
    public Static List<sObject> getContactAndMemberQuery(List<String> lstFields, String objectName,  String communityManager, String primaryMemberEmail){
        String emailDomainQuery;
        List<sObject> lstContactAndMembers = new List<sObject>();
        if(primaryMemberEmail.split('@').size() == 2){
           emailDomain = primaryMemberEmail.split('@')[1]; 
        }
        String query = 'SELECT Id ';
        if(lstFields != null){
            query += ',' +string.join(lstFields, ',');
        }
        query += ' FROM '+ objectName +' WHERE ';
        emailDomainQuery = query;
        emailDomainQuery += 'Email_Domain__c =: emailDomain LIMIT 1';
        if(String.isNotBlank(communityManager)){
            query += 'UUID__c =: communityManager';
        }
        if(String.isNotBlank(communityManager)){
            query += ' OR Email =: primaryMemberEmail';
        }else if(String.isBlank(communityManager)){
            query += 'Email =: primaryMemberEmail';
        }
        Debug.log('query==>'+query);
        lstContactAndMembers.addall(DataBase.query(query));
        if(lstContactAndMembers.size() < 2 && String.isNotBlank(emailDomain)){
            if(setDomains.size() > 0 && !setDomains.contains(emailDomain.toLowerCase())){
                Debug.log('lstContactAndMembers query for domain==>'+emailDomainQuery);
                lstContactAndMembers.addAll(Database.query(emailDomainQuery));
            }  
        }
        return lstContactAndMembers;
    }
    
    //CSI-1220 validate reservables 
    public static void validateReservables(UtilityWapper objUtilityWapper){
        Set<String> setAllReservables = new set<String>();
        setAllReservables.addAll(objUtilityWapper.setPayloadReservableUuid);
        setAllReservables.addAll(objUtilityWapper.setMoveOutPayloadReservableUuid);
        for(Reservable__c resevableRecord : [SELECT Id, UUID__c FROM Reservable__c WHERE UUID__c In : setAllReservables]){
            objUtilityWapper.mapReservablePresentInSystem.put(resevableRecord.UUId__c, resevableRecord);
        }
        String reservableNotFoundErrorMsg = 'Reservables not found with uuids ';
        for(String reservableUUID: setAllReservables){
            if(!objUtilityWapper.mapReservablePresentInSystem.containsKey(reservableUUID)){
                reservableNotFoundErrorMsg += reservableUUID + ', ';
            }
        }
        
        if(reservableNotFoundErrorMsg.containsAny(',')){
            reservableNotFoundErrorMsg.removeEnd(',');
            throw new ContractEventUtilitiesException(reservableNotFoundErrorMsg);
        }
    }
    public Static List<String> getEditableFields(String selectedObject, Set <String> setFieldsToIgnore){
        List<String> lstFields = new List<String>();
        Map<String, Schema.SObjectType> gdMap = Schema.getGlobalDescribe();
        Schema.Describesobjectresult dsr = gdMap.get(selectedObject).getDescribe();
        Map<String, Schema.SObjectField> fieldMap = dsr.fields.getMap();
        for(String fieldName : fieldMap.keySet()) {
            if(fieldMap.get(fieldName).getDescribe().isUpdateable()) {
                if(setFieldsToIgnore != null && !setFieldsToIgnore.contains(fieldName))
                  lstFields.add(fieldName);
                
            }
        }
        Debug.log('lstFields getEditableFields::'+lstFields);
        return lstFields;
    }
    
    public static String getResult(String result, Boolean newOpportunity){
        try{
            Id OpportunityId = Id.valueOf(result);
            if(newOpportunity){
                return 'New Opportunity : '+OpportunityId;  
            }else{
                return 'Update Opportunity : '+OpportunityId;  
            }
        }catch(Exception ex){
            return result;
        }
    }
    //Wrapper classes defined here
    global class UtilityWapper{
        Public Boolean udpateOpp = false;
        Public Boolean createOpp = false;
        Public Boolean considerSellableProductSeparation = false;
        Public String fromOpp;
        Public Set<String> setOpenStage  = new Set<String>();
        Public Set<String> setCloseStage  = new Set<String>();
        Public Set<String> setBuildingUuid = new Set<String>();
        Public List<String> lstOppStages;
        public Map<String, Reservable__c> mapReservablePresentInSystem = new Map<String, Reservable__c>();
        //Flag to delete opportunity prodycts
        Public boolean deleteOpportunityLineItem = false;
        //To searched update Opportunity
        Public Opportunity objOpp = new Opportunity();
        //Set of ReservableUuid from payload move ins
        Public Set<String> setPayloadReservableUuid  = new Set<String>();
        //Map of move ins 
        Public Map<String,WWTypes.move_insVal> mapPayloadReservable = new  Map<String,WWTypes.move_insVal>();
        Public Map<String,WWTypes.move_outssVal> mapPayloadReservableMoveOut = new  Map<String,WWTypes.move_outssVal>();
        //Set of ReservableUuid from payload move outs
        Public Set<String> setMoveOutPayloadReservableUuid  = new Set<String>();
        Public Boolean flagConsiderMoveOutBuilding = true;
        Public Date latestDate;
        //separated products from deal
        Public List<WWTypes.products> lstSellableProductsInUpdate = new List<WWTypes.products>();
        //separated products from deal
        Public List<WWTypes.products> lstALLProducts = new List<WWTypes.products>();
        Public Opportunity oppToUse;
        Public Map<String,Map<String,sObject>> mapContactsMembers;
        //List of building in moveins for locations interested
        Public List<Building__c> lstBuilding = new List<Building__c>();
        Public List<Opportunity> lstOppFromOpp = new List<Opportunity>();
        Public Map<String,String> mapCloseLostReason  = new Map<String,String>();
        Public ContractEventUtilitySetting objContractEventUtilitySetting = new ContractEventUtilitySetting();
        Public Map<String,Building__c> mapAllPayloadBuildings = new Map<String,Building__c>();
        Public Map<String,WWTypes.products> mapProducsWithBuilding = new Map<String,WWTypes.products>();
        Public String opportunityBuildingUUID;
        Public String opportunityBuildingMoveOutUUID;
        Public Decimal CommitmentTermInMonthsForopp;
        Public Map<String,Id> mapBuildingUUIDWithCommitmentId = new Map<String,Id>();
        Public Set<String> setPayloadBuildingUUID = new Set<String>();
        public Decimal totalProduct = 0.0;
        public List<OpportunityLineItem> lstOpportunityLineItemOtherProductsWillUpsert = new List<OpportunityLineItem>();
    }
    
    public class ContractEventUtilitySetting{
        public String ActiveOwnerId;
        public Set<String> ConsideredProductCodes;
        public List<Map<String,String>> LostReason;
        public Set<String> ConsideredDiscounts;
        public String DealProductCode;
        public Set<String> RetainProductFields;
    }
    
    public class ContractEventUtilitiesException extends Exception {}
}