/**
* Different logic related to Opportunities
*
* @author  Antonio Grassi
* @date    09/25/2013
*/
public with sharing class OpportunityServices {
    public static Opportunity newOpp = new Opportunity();
    public static void closeOpportunities(Set<Id> opportunityIds) {
        try{
            Opportunity[] ops = [select Id, StageName from Opportunity where Id in :opportunityIds];
            
            for (Opportunity o:ops) {
                o.StageName = 'Closing';
            }
            
            if (!ops.isEmpty()) {
                update ops;
            }
        } catch(Exception pEx) {
            List<Id> ids = new List<Id>();
            ids.addAll(opportunityIds);
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('OpportunityServices','closeOpportunities',String.join(ids, ','), pEx)
            );
            throw new OpportunityServicesException(pEx.getMessage());
        }
    }
    
    @future
    public static void update_closedwon_accounts(Id[] pOpportunityIDs) {      
        try{
            Id[] container = new Id[]{};
                //validation because method was called in the past
                for (Opportunity o : [SELECT AccountId 
                                      FROM Opportunity 
                                      WHERE 
                                      isClosed = true AND 
                                      isWon = true AND
                                      id IN :pOpportunityIDs
                                     ])
                container.add(o.AccountId);
            
            ////////////////////////// CLOSED WON STUFF /////////////////////////////////
            //select closed won Accounts
            Account[] ClosedWonAAs = [  SELECT WW_Sync_Request__c, Type 
                                      FROM Account 
                                      WHERE 
                                      Id IN :container 
                                      LIMIT 1000
                                     ];
            
            //set sync request for each account
            for (Account a : ClosedWonAAs) {
                //a.WW_Sync_Request__c = true;
                a.Type = 'Member';
                a.ID_Status2__c = 'active';
            }
            
            //dml
            update ClosedWonAAs; 
            //select tagged closed won contacts and re send them to ID api (the opportunity was won)
            Contact[] ClosedWonCs = [ SELECT WW_Sync_Request__c, Status__c, Account.Primary_Member__c, Id
                                     FROM Contact
                                     WHERE
                                     AccountID IN :container 
                                     LIMIT 1000
                                    ];
            
            //set sync request for each contact
            for (Contact c : ClosedWonCs) {
                //c.WW_Sync_Request__c = true;
                //if primary member set as active
                if (c.Account.Primary_Member__c == c.Id)
                    c.Status__c = 'active';
            }
            //dml
            update ClosedWonCs;
        } catch(Exception pEx) {
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('OpportunityServices','update_closedwon_accounts',String.join(pOpportunityIDs, ','), pEx)
            );
            throw new OpportunityServicesException(pEx.getMessage());
        }
    }
    
    public static  Opportunity get_latest_open_opportunity_by_primary_member(Id pAccountId, Id pContactId, String pBuildingName){
        try{
            //select latest open opportunity
            Set<String> location_Interested = new Set<String>();
            Opportunity[] Os = [  SELECT Id, Count_of_Desk__c,locations_interested__c,createdDate,Building__c
                                FROM Opportunity WHERE AccountId = : pAccountId AND
                                stageName IN ('Qualifying', 
                                              'Negotiating', 
                                              'Selling'
                                             )
                                ORDER BY createdDate DESC
                               ];
            Debug.log('List of Os : '+ Os);
            if(Os.isEmpty()){
                Os = [ SELECT Id, Count_of_Desk__c,locations_interested__c,createdDate,Building__c
                      FROM Opportunity WHERE Primary_Member__c = : pContactId AND
                      stageName IN ('Qualifying', 
                                    'Negotiating', 
                                    'Selling'
                                   )
                      ORDER BY createdDate DESC
                     ];
            }
            for(Opportunity objOpp : Os){
                if(objOpp.locations_interested__c != null){
                    location_Interested = new Set<String>(objOpp.locations_interested__c.split(';'));
                    if(location_Interested.contains(pBuildingName)){
                        Debug.log('Opportunity Service returned objOpp ==>'+objOpp);
                        return objOpp;
                    }
                    
                }
            }
            return Os.isEmpty() ? null : Os[0];
        } catch(Exception pEx) {
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('OpportunityServices','get_latest_open_opportunity_by_primary_member', pAccountId + ','+ pContactId+ ','+ pBuildingName, pEx)
            );
            throw new OpportunityServicesException(pEx.getMessage());
        }
    }
    
    public static Opportunity create_opportunity(Id pAccountId, String pBuildingName, String pStageName) {
        try{
            //get primary member
            Account a = [SELECT Primary_member__c, RecordType.Name, OwnerId,Interested_in_Number_of_Desks__c FROM Account WHERE id = :pAccountId LIMIT 1];
            Debug.log('Account queried Primary_member__c '+a);	
            
            //create opportunity
            Opportunity o = new Opportunity(
                stageName               = pStageName, //Selling
                AccountId               = pAccountId,
                closeDate               = system.today(),
                name                    = 'New Opportunity',
                Primary_Member__c       = a.Primary_Member__c,
                Interested_in_Number_of_Desks__c = a.Interested_in_Number_of_Desks__c,
                RecordTypeId            = (a.RecordType.Name != 'Referral') ? Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(a.RecordType.Name).getRecordTypeId() : Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Consumer').getRecordTypeId()
                
            );
            if(a.RecordType.Name == 'Mid Market' || a.RecordType.Name == 'Enterprise Solutions')
                o.stageName = 'Qualifying';
            
            return o;
        } catch(Exception pEx) {
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('OpportunityServices','create_opportunity', pAccountId + ','+ pBuildingName+ ','+ pStageName , pEx)
            );
            throw new OpportunityServicesException(pEx.getMessage());
        }
    }
    
    public static Id getMostRecentOpportunityId(Id pAccountId) {
        Id result;
        try {
            Account[] AAs = [ SELECT id, name, 
                             (SELECT id FROM Opportunities ORDER BY createddate DESC LIMIT 1)
                             FROM Account
                             WHERE id = :pAccountId                              
                             LIMIT 1
                            ];
            debug.log('AAs[0]-------'+AAs[0]);
            debug.Log('AAs[0].Opportunities--------'+AAs[0].Opportunities);
            result = AAs[0].Opportunities[0].id;
        } catch (Exception pEx) {
            result = null;
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('OpportunityServices','getMostRecentOpportunityId', pAccountId , pEx)
            );
            throw new OpportunityServicesException(pEx.getMessage());
        }
        return result;
    }
    
    public static boolean hasSObjectField(String fieldName, WWTypes.Discount so){
        String s = JSON.serialize(so);
        Map<String,Object> obj = (Map<String,Object>) JSON.deserializeUntyped(s);
        Set<String> fieldsPresent = obj.keyset().clone();
        return fieldsPresent.contains(fieldName);
    }
    
    public static void updateOpportunity(WWTypes.OpportunityUpdate pOpportunityUpdate) {
        try{
            //get encoded id
            Id opportunity_id = EncodingHandler.decode(pOpportunityUpdate.encoded_opportunity_id);
            
            //get opportunity
            Opportunity[] Os = [  SELECT id
                                FROM Opportunity
                                WHERE id = :opportunity_id
                                LIMIT 1
                               ];
            if (Os.size() == 0) throw new OpportunityServicesException('Can\'t locate opportunity with provided encoded_id.');
            //get opportunity
            Opportunity o = Os[0];
            //opportunity binding
            o.Type__c                         = pOpportunityUpdate.opportunity_type;
            o.Actual_Start_Date__c            = pOpportunityUpdate.actual_start_date;
            o.Parking_Fees__c                 = pOpportunityUpdate.parking_fee;
            o.Number_of_phones__c             = pOpportunityUpdate.number_of_phones;
            o.Phone_Setup_Fee__c              = pOpportunityUpdate.phone_setup_fee;
            o.Setup_Fee__c                    = pOpportunityUpdate.setup_fee;
            o.International_Calling__c        = pOpportunityUpdate.international_calling;
            o.Membership_Agreement_Notes__c   = pOpportunityUpdate.membership_agreement_notes;
            o.Internal_Transfer_Encoded_ID__c = pOpportunityUpdate.internal_transfer_encoded_id;
            o.LeadSource                      = pOpportunityUpdate.lead_source;
            o.Lead_Source_Detail__c           = pOpportunityUpdate.lead_source_details;
            //o.Building__c                     = BuildingHandler.getBuildingIdByUUID(pOpportunityUpdate.building_uuid);
            o.Locations_Interested__c         = BuildingHandler.getMultipicklistValuesFromUUID(pOpportunityUpdate.locations_interested_uuids);   
            //o.Send_Paperwork_By__c            = pOpportunityUpdate.send_paperwork_by;
            
            //Send_Paperwork_By__c change from String to Lookup
            
            Contact[] con = [ SELECT ID,Name FROM Contact WHERE UUID__c = : pOpportunityUpdate.send_paperwork_by  LIMIT 1 ];
            if(con.size() > 0 && con[0].Id != null)
                o.Send_Paperwork_By__c  = con[0].Id;
            //dml
            update o;
            
            //Discounts: Let's remove all existing discounts and replace with 
            //the ones (if any) that are given. Even if there's a discount in
            //Salesforce and we send paperwork from Spacestation with no discount, 
            //this should overwrite the discount that was previously indicated. 
            //create discounts records        
            if (pOpportunityUpdate.discounts != null) {
                //create discounts
                Discount__c[] Ds = new Discount__c[]{};
                    
                    //delete existing discounts
                    delete [SELECT id FROM Discount__c WHERE Opportunity__c = :o.id];
                
                //collect discounts
                for (WWTypes.Discount d : pOpportunityUpdate.discounts) {
                    Discount__c newDiscount = new Discount__c();
                    newDiscount.Opportunity__c    = o.id;
                    newDiscount.Amount__c         = d.amount;
                    newDiscount.Start_date__c     = d.start_date;
                    newDiscount.End_Date__c       = d.end_date;
                    newDiscount.Discount_Type__c  = d.discount_type;
                    if(hasSObjectField('promotion_code', d)){
                        if(d.promotion_code == null)
                            newDiscount.Promotion_Code__c = '';
                        else
                            newDiscount.Promotion_Code__c = d.promotion_code;
                    }
                    if(hasSObjectField('promotion_override', d)){
                        if(d.promotion_override == null)
                            newDiscount.Promotion_Override__c = false;
                        else
                            newDiscount.Promotion_Override__c = d.promotion_override;
                    }
                    Ds.add(newDiscount);
                }
                insert Ds;
            }
            
            //Reservables: All reservables on the Opportunity whose uuid is not present 
            //in the reservable_uuids provided should be removed from the Opportunity.
            if (pOpportunityUpdate.reservable_uuids != null) {
                //get reservables
                Reservable__c[] Rs = [SELECT id
                                      FROM Reservable__c
                                      WHERE uuid__c IN :pOpportunityUpdate.reservable_uuids
                                     ];
                if (Rs.size() == 0) throw new OpportunityServicesException('Can\'t locate reservables');
                
                //delete existing reservables
                delete [SELECT id FROM Opportunity_Reservable__c WHERE Opportunity__c = :o.id];
                
                //create opportunity reservables
                Opportunity_Reservable__c[] ORs = new Opportunity_Reservable__c[]{};
                    for (Reservable__c r : Rs) {
                        ORs.add(
                            new Opportunity_Reservable__c(
                                Opportunity__c  = o.id,
                                Reservable__c   = r.id
                            )
                        );    
                    }      
                insert ORs;
            }
            
        } catch(Exception pEx) {
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('OpportunityServices','updateOpportunity',JSON.serializePretty(pOpportunityUpdate), pEx)
            );
            throw new OpportunityServicesException(pEx.getMessage());
        }
    }
    
    public static void insertOpportunity(WWTypes.OpportunityInsert pOpportunityInsert) {
        
        //get account
        debug.Log('companyUUID-- :' + pOpportunityInsert.company_uuid );
        debug.Log('primary_member_email-- :' + pOpportunityInsert.primary_member_email);
             
        //ST-1156
        //Changes made by Amol Darekar to get UUID from Merge Account Object records call to method WeworkEngine.getMasterAccountUUID().
        String masterAccountUUID = WeworkEngine.getMasterAccountUUID(pOpportunityInsert.company_uuid);
        String useAccUUID = null;
        if(masterAccountUUID == null)
            useAccUUID = pOpportunityInsert.company_uuid;
        else
            useAccUUID = masterAccountUUID;
        Account[] a = [ SELECT id, primary_member__c,Account_Type__c,Org_Identification_Status__c,ParentId 
                       FROM Account 
                       WHERE uuid__c = :useAccUUID
                       LIMIT 1
                      ];
        debug.Log('Account a --- :' + a);
        if (a.size() == 0) throw new OpportunityServicesException('Can\'t locate account with provided uuid.');
        List<Contact> conToMap = null;
        if( !String.isBlank(pOpportunityInsert.primary_member_email) ) {
            conToMap = [ Select Id From Contact Where Email = :pOpportunityInsert.primary_member_email LIMIT 1 ];
        }
        debug.Log('conToMap --- :' + conToMap);
        if (a[0].primary_member__c == null) throw new OpportunityServicesException('The account has no primary member');
        Reservable__c[] Rs = null;
        
        if(pOpportunityInsert.reservable_uuids != null)
            Rs = [SELECT id
                  FROM Reservable__c
                  WHERE uuid__c IN :pOpportunityInsert.reservable_uuids
                 ];
        Debug.Log('From opportunityServices :: pOpportunityInsert.reservable_uuid :: '+ pOpportunityInsert.reservable_uuids);
        Debug.Log('From opportunityServices :: Rs :: '+ Rs);
        Building__c[] b;
        if(pOpportunityInsert.building_uuid != null){
             b = [ SELECT id
                               FROM Building__c
                               WHERE uuid__c = :pOpportunityInsert.building_uuid
                               LIMIT 1
                              ];
            if (b.size() == 0) throw new OpportunityServicesException('Can\'t locate building');
        }
        /*if(a[0].Account_Type__c == null || a[0].ParentId == null || (a[0].ParentId != null && a[0].Org_Identification_Status__c != 'Processed')){
            Map<String,String> mapFieldAndValue = new Map<String, String>();
            mapFieldAndValue.put('Account_Type__c', 'Bill');
            mapFieldAndValue.put('Org_Identification_Status__c', 'Pending');
            ContractEventUtilities.updateAccount(null,a[0],mapFieldAndValue);
        }*/
        //create opportunity
        Opportunity o = new Opportunity(
            CloseDate                         =  system.today(),
            Name                              = 'Inbound cloned opportunity',
            AccountID                         = a[0].id,
            Primary_member__c                 = (conToMap != null && conToMap.size()>0)? conToMap[0].id : a[0].primary_member__c,
            //number_of_desks_2016__c                = pOpportunityInsert.desk_number,
            Type__c                           = pOpportunityInsert.opportunity_type,
            Actual_Start_Date__c              = pOpportunityInsert.actual_start_date,
            Building__c                       = (b != null && b.size() > 0)? b[0].Id : null,
            StageName                         = 'Negotiating',
            Parking_Fees__c                   = pOpportunityInsert.parking_fee,
            Number_of_Phones__c               = pOpportunityInsert.number_of_phones,
            International_Calling__c          = pOpportunityInsert.international_calling,
            Membership_Agreement_Notes__c     = pOpportunityInsert.membership_agreement_notes,
            Phone_Setup_Fee__c                = pOpportunityInsert.phone_setup_fee,
            Setup_Fee__c                      = pOpportunityInsert.setup_fee,
            LeadSource                        = pOpportunityInsert.lead_source,
            Lead_Source_Detail__c             = pOpportunityInsert.lead_source_details,
            Internal_Transfer_Encoded_Id__c   = pOpportunityInsert.internal_transfer_encoded_id,
            Locations_Interested__c           = BuildingHandler.getMultipicklistValuesFromUUID(pOpportunityInsert.locations_interested_uuids),
            contract_uuid__c          = pOpportunityInsert.contract_uuid,
            primary_member_email__c      = pOpportunityInsert.primary_member_email,
            CurrencyIsoCode          =pOpportunityInsert.CurrencyIsoCode,
            Contract_Stage__c          =pOpportunityInsert.Contract_Stage,
            Owner_Auto_Assign__c        =true   
        );
        if(pOpportunityInsert.contract_pdf != null)
            o.contract_pdf__c = pOpportunityInsert.contract_pdf;
        if(pOpportunityInsert.from_opportunity != null)
            o.Old_Opportunity__c = pOpportunityInsert.from_opportunity;
        if(pOpportunityInsert.contract_uuid != null)
            o.contract_uuid__c = pOpportunityInsert.contract_uuid;
        else
            o.Reservation_UUID__c = pOpportunityInsert.reservation_uuid;
        if(pOpportunityInsert.stageName != null && pOpportunityInsert.stageName != '')
            o.stageName = pOpportunityInsert.stageName;
        if(pOpportunityInsert.community_manager_uuid != null){
            o.community_manager_uuid__c = pOpportunityInsert.community_manager_uuid;
            o.community_user__c = pOpportunityInsert.community_user;
            o.Send_Paperwork_By__c = pOpportunityInsert.community_user;
            //CSI-411 Changes made by shobhit
            if(pOpportunityInsert.Paperwork_Sent_On_Date != null && pOpportunityInsert.Paperwork_Sent_On_Date != '')
            	o.Paperwork_Sent_On_Date__c =  Date.ValueOf(pOpportunityInsert.Paperwork_Sent_On_Date);
        }
        if(pOpportunityInsert.contract_type != null && pOpportunityInsert.contract_type != '')
            o.contract_Type__c = pOpportunityInsert.contract_type;
        if(pOpportunityInsert.type != null && pOpportunityInsert.type != '')
            o.Type__c = pOpportunityInsert.type;
        if(pOpportunityInsert.downgrade_reason != null && pOpportunityInsert.downgrade_reason != '')
            o.downgrade_reason__c = pOpportunityInsert.downgrade_reason;
        if(pOpportunityInsert.downgrade_notes != null && pOpportunityInsert.downgrade_notes != '')
            o.downgrade_notes__c = pOpportunityInsert.downgrade_notes;
        if(pOpportunityInsert.Commitment_Term_In_Months != null)
           o.Commitment_Term_in_months__c = pOpportunityInsert.Commitment_Term_In_Months;
        //if(pOpportunityInsert.Commitment_Start_Date != null)
        //   o.Commitment_Start_Date__c = pOpportunityInsert.Commitment_Start_Date;
        if(pOpportunityInsert.Contract_Expiration != null)
           o.Contract_Expiration__c = pOpportunityInsert.Contract_Expiration;
        if(String.isBlank(pOpportunityInsert.Lost_Reason))
           o.Lost_Reason__c = pOpportunityInsert.Lost_Reason;
        if(pOpportunityInsert.Move_outs_Closed_Lost != null)
           o.Move_outs_Closed_Lost__c = pOpportunityInsert.Move_outs_Closed_Lost;
        if(pOpportunityInsert.Contract_Signed_On_Date != null)
           o.Contract_Signed_On_Date__c = pOpportunityInsert.Contract_Signed_On_Date;
        if(pOpportunityInsert.OwnerId != null)
           o.OwnerId = pOpportunityInsert.OwnerId;
        if(pOpportunityInsert.Contract_Canceled_On_Date != null)
           o.Contract_Canceled_On_Date__c = pOpportunityInsert.Contract_Canceled_On_Date;
        if(pOpportunityInsert.Contract_Voided_Discarded_On_Date != null)
           o.Contract_Voided_Discarded_On_Date__c = pOpportunityInsert.Contract_Voided_Discarded_On_Date;
        if(pOpportunityInsert.Move_Out_Building != null)
           o.Move_Out_Building__c = pOpportunityInsert.Move_Out_Building;
        insert o;
        Debug.log('insert opportunity : '+o);
        newOpp = o;
        //create opportunity reservables
        Opportunity_Reservable__c[] ORs = new Opportunity_Reservable__c[]{};
            
            if (Rs != null && Rs.size() > 0){
                for (Reservable__c r : Rs) {
                    ORs.add(
                        new Opportunity_Reservable__c(
                            Opportunity__c  = o.id,
                            Reservable__c   = r.id,
                            CurrencyIsoCode = (pOpportunityInsert.CurrencyIsoCode !=null && pOpportunityInsert.CurrencyIsoCode != '') ? pOpportunityInsert.CurrencyIsoCode : 'USD'
                        )
                    );    
                }   
                Debug.log('From opportunityServices :: ORs :: '+ORs);
                insert ORs;
            }
      
        
        //create discounts records
        Discount__c[] Ds = new Discount__c[]{};
            if (pOpportunityInsert.discounts != null)
            for (WWTypes.Discount d : pOpportunityInsert.discounts) {
                Discount__c newDiscount = new Discount__c();
                newDiscount.Opportunity__c    = o.id;
                newDiscount.Amount__c         = d.amount;
                newDiscount.Start_date__c     = d.start_date;
                newDiscount.End_Date__c       = d.end_date;
                newDiscount.Discount_Type__c  = d.discount_type;                    
                if(hasSObjectField('promotion_code', d)){
                    if(d.promotion_code == null)
                        newDiscount.Promotion_Code__c = '';
                    else
                        newDiscount.Promotion_Code__c = d.promotion_code;
                }
                if(hasSObjectField('promotion_override', d)){
                    if(d.promotion_override == null)
                        newDiscount.Promotion_Override__c = false;
                    else
                        newDiscount.Promotion_Override__c = d.promotion_override;
                }
                //CSI-525
                if(String.isNotBlank(d.building_uuid)){
                    newDiscount.Building_UUID__c  = d.building_uuid;
                }
                //CSI-525
                if(String.isNotBlank(d.building_id)){
                    newDiscount.Building__c  = d.building_id;
                }
                Ds.add(newDiscount);
            }
        insert Ds;
        
        //update stage to Contract Sent
        try {
            OpportunityServices.sendContract(o.Id);
        } catch (Exception e) {
            delete o;
            throw e;
        }
    }
    
    public static void sendContract(Id pOpportunityID) {
        //try{
        if (pOpportunityID == null) throw new OpportunityServicesException('The Opportunity ID is undefined');
        
        Opportunity o = [ SELECT StageName 
                         FROM Opportunity 
                         WHERE Id = :pOpportunityID 
                         LIMIT 1 
                        ];
        Debug.log('Test : Opportunity ::: ' + o);
        //set send contract button used
        o.Send_Contract_Button_Used__c = true;
        
        //set stage
        o.StageName = 'Closing';
        
        //dml
        update o;
        /*} catch(Exception pEx) {
new ApexDebugLog().createLog( 
new ApexDebugLog.Error('OpportunityServices','sendContract','pOpportunityID  : '+pOpportunityID, pEx)
);
throw new OpportunityServicesException(pEx.getMessage());
}*/
    }
    
    public static Boolean areAllReservablesMoveOutDateBeforeStartDate(Id pOpportunityID) {
        Boolean result = true; //pass
        try {
            //select reservables from all opportunity reservables
            for (Opportunity_Reservable__c r : [  SELECT Reservable__r.Status__c, 
                                                Reservable__r.Status_Right_Now__c, 
                                                Reservable__r.Last_Move_Out__c,
                                                Reservable__r.Open_Date__c,
                                                Opportunity__r.Actual_Start_Date__c 
                                                FROM Opportunity_Reservable__c
                                                WHERE Opportunity__c = :pOpportunityID
                                               ]) {
                                                   
                                                   String right_now = r.Reservable__r.Status_Right_Now__c != null ? 
                                                       r.Reservable__r.Status_Right_Now__c : 
                                                   '';
                                                   
                                                   Date move_out_date      = r.Reservable__r.Last_Move_Out__c;
                                                   Date open_date          = r.Reservable__r.Open_Date__c;
                                                   Date actual_start_date  = r.Opportunity__r.Actual_Start_Date__c;
                                                   
                                                   //available
                                                   if ( r.Reservable__r.Status__c == 'Available') {
                                                       if ( right_now.equalsIgnoreCase('Occupied') || right_now.equalsIgnoreCase('Unoccupied') ) {
                                                           if ( move_out_date != null) {
                                                               result = result &&
                                                                   move_out_date < actual_start_date;                        
                                                           }
                                                           else { // move_out_date = null
                                                               result = result &&
                                                                   open_date <= actual_start_date;
                                                           }            
                                                       }          
                                                   }
                                                   
                                                   //status = unavailable
                                                   if (r.Reservable__r.Status__c == 'Unavailable') result = result && false;
                                                   
                                               }
        } catch(Exception pEx) {
            result = false; //default value
            /*new ApexDebugLog().createLog( 
new ApexDebugLog.Error('OpportunityServices','areAllReservablesMoveOutDateBeforeStartDate',pOpportunityID, pEx)
);*/
        }
        return result;
    }
    
    public static Boolean areReservablesUsedInOtherOpportunity(Id pOpportunityID) {
        //container
        Set<Id> SReservablesID = new Set<Id>();
        Boolean result = false;
        try {
            //collect reservables from opportunity reservables
            for (Opportunity_Reservable__c r : [  SELECT Reservable__c
                                                FROM Opportunity_Reservable__c
                                                WHERE Opportunity__c = :pOpportunityID
                                               ]) 
                SReservablesID.add(r.Reservable__c);
            
            //select target reservables with contract sent
            Opportunity_Reservable__c[] ORs = [ SELECT id 
                                               FROM Opportunity_Reservable__c
                                               WHERE 
                                               Opportunity__r.StageName = 'Closing' AND
                                               Reservable__r.Office_Work_Station_Type__c <> 'HotDeskArea' AND
                                               Reservable__c IN :SReservablesID
                                              ];
            
            //check if there are reservables in a Contract sent opportunity
            result = ORs.size() > 0;
        }
        catch(Exception pEx) {
            result = false; //default value
            /*new ApexDebugLog().createLog( 
new ApexDebugLog.Error('OpportunityServices','areReservablesUsedInOtherOpportunity',pOpportunityID, pEx)
); */           
        }
        return result;
    }
    
    public static Boolean areAllReservablesAvailable(Id pOpportunityID) {
        Boolean result = true;
        try {
            //select reservables from all opportunity reservables
            for (Opportunity_Reservable__c r : [  SELECT Reservable__r.Status__c, 
                                                Reservable__r.Archived_On__c 
                                                FROM Opportunity_Reservable__c
                                                WHERE Opportunity__c = :pOpportunityID
                                               ]) {
                                                   //check availability
                                                   result =  result && 
                                                       r.Reservable__r.Status__c == 'Available' && 
                                                       r.Reservable__r.Archived_On__c == null;
                                               }
        } catch(Exception pEx) {
            result = false; //default value
            /*new ApexDebugLog().createLog( 
new ApexDebugLog.Error('OpportunityServices','areAllReservablesAvailable',pOpportunityID, pEx)
); */
        }
        return result;
    }
    
    public static Boolean areAllReservablesOpenAtActualStartDate(Id pOpportunityID) {
        Boolean result = true;
        try {
            //select reservables from all opportunity reservables
            for (Opportunity_Reservable__c r : [  SELECT Reservable__r.Open_Date__c,
                                                Opportunity__r.Actual_Start_Date__c 
                                                FROM Opportunity_Reservable__c
                                                WHERE Opportunity__c = :pOpportunityID
                                               ]) {
                                                   //check availability
                                                   result =  result && 
                                                       r.Opportunity__r.Actual_Start_Date__c != null &&
                                                       r.Reservable__r.Open_Date__c != null &&
                                                       r.Reservable__r.Open_Date__c <= r.Opportunity__r.Actual_Start_Date__c;
                                               }
        } catch(Exception pEx) {
            result = false; //default value
            /*new ApexDebugLog().createLog( 
new ApexDebugLog.Error('OpportunityServices','areAllReservablesOpenAtActualStartDate',pOpportunityID, pEx)
);*/ 
        }
        return result;
    }
    
    public static Boolean areAllReservablesBuildingMatching(Id pOpportunityID) {
        Boolean result = true;
        try {
            //select reservables from all opportunity reservables
            for (Opportunity_Reservable__c r : [  SELECT Reservable__r.Building__c,
                                                Opportunity__r.Building__c
                                                FROM Opportunity_Reservable__c
                                                WHERE Opportunity__c = :pOpportunityID
                                               ]) {
                                                   //check availability
                                                   result =  result && 
                                                       r.Opportunity__r.Building__c == r.Reservable__r.Building__c;
                                               }
        } catch(Exception pEx) {
            result = false; //default value
            /*new ApexDebugLog().createLog( 
new ApexDebugLog.Error('OpportunityServices','areAllReservablesBuildingMatching',pOpportunityID, pEx)
); 
*/
        }
        return result;
    }
    
    public static WWTypes.OpportunityDetails getOpportunityDetails(Id pOpportunityID) {
        try{
            WWTypes.OpportunityDetails result = new WWTypes.OpportunityDetails();
            
            //select the opportunity
            Opportunity o = [ SELECT id, name, accountID, StageName, Type__c,
                             Building__r.UUID__c, Building__r.Responsible_CM__r.Name, Building__r.email__c, Building__r.Community_Manager__r.Name,
                             actual_start_date__c, 
                             office_type__c,
                             Encoded_ID__c, 
                             Setup_Fee__c, 
                             Total_Desks_Reserved__c, Office_Conference_Room_Credits__c,
                             Monthly_Prints_Color_Total__c, Parking_Fees__c, International_calling__c,
                             Monthly_Payment_Method__c, Membership_Agreement_Notes__c, Monthly_Prints_B_W_Total__c, 
                             Number_of_Phones__c,
                             Network_Set_Up_Fee__c, 
                             Network_Monthly_Membership_Fee__c,
                             Network_Monthly_Conference_Room_Credits__c,
                             Mail_and_Package_Handling__c,
                             Phone_Setup_Fee__c,
                             LeadSource,
                             Lead_Source_Detail__c,
                             Locations_Interested__c,
                             Send_Paperwork_By__c
                             FROM Opportunity 
                             WHERE id = :pOpportunityID 
                             LIMIT 1
                            ];
            
            //company
            Account a = [ SELECT id, name, legal_name__c, industry, company_size__c, funding_status__c, 
                         primary_member__c, uuid__c, has_non_wework_space__c, authorized_signatory__c
                         FROM Account
                         WHERE id = :o.accountID
                         LIMIT 1
                        ];
            //binding           
            result.company                      = new WWTypes.Company();
            result.company.name                 = a.name;
            result.company.legal_name           = a.legal_name__c;
            result.company.industry             = a.industry;
            result.company.size                 = a.company_size__c;
            result.company.funding              = a.funding_status__c;
            result.company.salesforce_id        = a.id;
            result.company.uuid                 = a.UUID__c;
            result.company.has_non_wework_space = a.has_non_wework_space__c;
            
            //primary member
            Contact pm = [  SELECT id, uuid__c, name, firstname, lastname, createddate,
                          email, phone, birthdate, gender__c, status__c,
                          mailingstreet, mailingcity, mailingstate, mailingpostalcode, mailingcountry
                          FROM Contact
                          WHERE id = :a.primary_member__c
                          LIMIT 1
                         ];
            //binding
            result.primary_member                 = new WWTypes.Member();
            result.primary_member.name            = pm.name;
            result.primary_member.first_name      = pm.firstname;
            result.primary_member.last_name       = pm.lastname;
            result.primary_member.uuid            = pm.uuid__c;
            result.primary_member.email           = pm.email;
            result.primary_member.gender          = pm.gender__c;
            result.primary_member.phone           = pm.phone;
            result.primary_member.salesforce_id   = pm.id;
            result.primary_member.date_of_birth   = pm.birthdate;
            result.primary_member.status          = pm.status__c;
            result.primary_member.address         = new WWTypes.Address();
            result.primary_member.address.street  = pm.mailingstreet;
            result.primary_member.address.city    = pm.mailingcity;
            result.primary_member.address.state   = pm.mailingstate;
            result.primary_member.address.zip     = pm.mailingpostalcode;
            result.primary_member.address.country = pm.mailingcountry;
            result.primary_member.created_at      = pm.createddate;
            
            //authorized signatory
            if (a.Authorized_Signatory__c != null) {
                Contact aus = [ SELECT name, email, createddate, uuid__c 
                               FROM Contact 
                               WHERE id = :a.Authorized_Signatory__c 
                               LIMIT 1
                              ];  
                //binding
                result.authorized_signatory             = new WWTypes.Member();
                result.authorized_signatory.name        = aus.name;
                result.authorized_signatory.email       = aus.email;
                result.authorized_signatory.uuid        = aus.uuid__c;
                result.authorized_signatory.created_at  = aus.createddate;
            }
            
            //reservables
            //collect
            for (Opportunity_Reservable__c opr : [ SELECT Reservable__r.name, 
                                                  Reservable__r.office_work_station_type__c,
                                                  Reservable__r.office_work_station_number__c,
                                                  Reservable__r.uuid__c,
                                                  Reservable__r.office_capacity__c,
                                                  conference_room_credits__c,
                                                  monthly_Prints_Copies_B_W__c, 
                                                  monthly_Prints_Copies_Color__c,
                                                  monthly_Price__c
                                                  FROM Opportunity_Reservable__c
                                                  WHERE Opportunity__c = :pOpportunityID                                    
                                                 ]) {
                                                     //binding
                                                     WWTypes.Reservable r      = new WWTypes.Reservable();
                                                     r.name                    = opr.Reservable__r.name;
                                                     r.type                    = opr.Reservable__r.office_work_station_type__c;
                                                     r.station_number          = opr.Reservable__r.office_work_station_number__c;
                                                     r.reservable_uuid         = opr.Reservable__r.uuid__c;
                                                     r.prints_black_white      = opr.Monthly_Prints_Copies_B_W__c;
                                                     r.prints_color            = opr.Monthly_Prints_Copies_Color__c;
                                                     r.monthly_price           = opr.Monthly_Price__c;
                                                     r.capacity                = opr.Reservable__r.office_capacity__c;
                                                     r.conference_room_credits = opr.Conference_Room_Credits__c;
                                                     result.reservables.add(r);
                                                 }
            
            //members
            //collect
            for (Contact c : [  SELECT name, firstname, lastname, email, phone, createddate, 
                              birthdate, gender__c, status__c, id, uuid__c
                              FROM Contact
                              WHERE 
                              AccountID = :a.id AND
                              Id <> :a.primary_member__c
                             ]) {
                                 WWTypes.Member m  = new WWTypes.Member();
                                 m.name            = c.name;
                                 m.first_name      = c.firstname;
                                 m.last_name       = c.lastname;
                                 m.email           = c.email;
                                 m.phone           = c.phone;
                                 m.uuid            = c.UUID__c;
                                 m.date_of_birth   = c.birthdate;
                                 m.gender          = c.Gender__c;
                                 m.status          = c.Status__c;
                                 m.salesforce_id   = c.id;
                                 m.created_at      = c.createddate;
                                 result.members.add(m);
                             }
            
            //discounts
            //collect
            for (Discount__c s : [  SELECT amount__c, discount_type__c, start_date__c, end_date__c,promotion_code__c,promotion_override__c
                                  FROM Discount__c
                                  WHERE Opportunity__c = :o.Id
                                 ]) {
                                     WWTypes.Discount d = new WWTypes.Discount();
                                     d.amount        = s.amount__c;
                                     d.discount_type = s.discount_type__c;
                                     d.start_date    = s.start_date__c;
                                     d.end_date      = s.end_date__c;
                                     d.promotion_code = s.promotion_code__c;
                                     d.promotion_override = s.promotion_override__c;
                                     result.discounts.add(d);
                                 }
            
            //root level fields
            result.salesforce_id                  = o.Id;
            result.opportunity_stage              = o.StageName;
            result.opportunity_type               = o.Type__c;
            result.encoded_opportunity_id         = o.Encoded_ID__c;
            result.location_uuid                  = o.Building__r.UUID__c;
            result.actual_start_date              = o.Actual_Start_Date__c;
            result.setup_fee                      = o.Setup_Fee__c;
            result.total_desks_reserved           = o.Total_Desks_Reserved__c;
            result.office_conference_room_credits = o.Office_Conference_Room_Credits__c;
            result.prints_color                   = o.Monthly_Prints_Color_Total__c;
            result.prints_black_white             = o.Monthly_Prints_B_W_Total__c;
            result.parking_fee                    = o.Parking_Fees__c;
            result.international_calling          = o.International_Calling__c;
            result.payment_method                 = o.Monthly_Payment_Method__c;
            result.notes                          = o.Membership_Agreement_Notes__c;
            result.number_of_phones               = o.Number_of_Phones__c;
            //result.number_of_desks                = o.number_of_desks_2016__c;
            if(o.Building__r != null && o.Building__r.Community_Manager__r != null)
                result.responsible_community_manager  = o.Building__r.Community_Manager__r.Name;
            else
                result.responsible_community_manager = o.Building__r.Responsible_CM__r.Name;
            result.building_email                 = o.Building__r.email__c;
            result.phone_setup_fee                = o.Phone_Setup_Fee__c;
            result.lead_source                    = o.LeadSource;
            result.lead_source_details            = o.Lead_Source_Detail__c;
            result.locations_interested_uuids     = BuildingHandler.getUUIDsFromMultipicklistValues(o.Locations_Interested__c);
            result.office_types_interested        = Common.splitStringToList(o.Office_Type__c, ';');
            
            //Network Membership Details
            result.network_membership_details                           = new WWTypes.Network_Membership_Details();
            result.network_membership_details.setup_fee                 = o.Network_Set_Up_Fee__c;
            result.network_membership_details.fee                       = o.Network_Monthly_Membership_Fee__c;
            result.network_membership_details.conference_room_credits   = o.Network_Monthly_Conference_Room_Credits__c;
            result.network_membership_details.mail_and_package_handling = o.Mail_and_Package_Handling__c;
            result.send_paperwork_by                                    = o.Send_Paperwork_By__c;
            
            return result;
        } catch(Exception pEx) {
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('OpportunityServices','getOpportunityDetails',pOpportunityID, pEx)
            ); 
            throw new OpportunityServicesException(pEx.getMessage());
        }
    }
    
    //optimistic coding: if error detected, the caller will catch the exceptions
    public static void serializeOpportunityDetails(WWTypes.OpportunityDetails pOpportunityDetails) {
        try{
            //parse opportunityID
            Id opportunityID = Id.valueOf(pOpportunityDetails.salesforce_id);
            
            //opportunity
            Opportunity o = [ SELECT id, name, Monthly_Payment_Method__c
                             FROM Opportunity
                             WHERE id = :opportunityID
                             LIMIT 1
                            ];
            //root binding
            o.Monthly_Payment_Method__c = pOpportunityDetails.payment_method;
            o.Phone_Setup_Fee__c        = pOpportunityDetails.phone_setup_fee;
            
            //dml
            update o;
            
            //company
            Account a = [ SELECT id, name, legal_name__c, industry, company_size__c, funding_status__c, has_non_wework_space__c
                         FROM Account
                         WHERE id = :pOpportunityDetails.company.salesforce_id
                         LIMIT 1
                        ];
            
            //bindings
            a.name                    = pOpportunityDetails.company.name;
            a.legal_name__c           = pOpportunityDetails.company.legal_name;
            a.industry                = pOpportunityDetails.company.industry;
            a.company_size__c         = pOpportunityDetails.company.size;
            a.funding_status__c       = pOpportunityDetails.company.funding;
            a.has_non_wework_space__c = pOpportunityDetails.company.has_non_wework_space;
            //dml
            update a;
            
            
            //primary member
            
            Contact pm = [  SELECT id, accountId, uuid__c, name, firstname, lastname, email, phone, birthdate, gender__c, 
                          mailingstreet, mailingcity, mailingstate, mailingpostalcode, Account_UUID__c
                          FROM Contact
                          WHERE id = :pOpportunityDetails.primary_member.salesforce_id
                          LIMIT 1 ];
            
            Contact[] pmByemail = [  SELECT id, accountId, uuid__c, name, firstname, lastname, email, phone, birthdate, gender__c, Status__c,
                                   mailingstreet, mailingcity, mailingstate, mailingpostalcode, Account_UUID__c, Primary_Member__c
                                   FROM Contact
                                   WHERE email = :pOpportunityDetails.primary_member.email AND id != :pOpportunityDetails.primary_member.salesforce_id ];
            
            if (pmByEmail.size() > 0) {
                Contact existing = pmByEmail[0];
                
                // If the found duplicate is an active licensee of a different account, raise an error
                if (existing.Primary_Member__c == 'Yes' && existing.Status__c == 'active' && existing.Account_UUID__c != pm.Account_UUID__c) {
                    throw new OpportunityServicesException('Attempted to change primary member to ' + existing.email + ', who is an active primary member for an existing company');
                }
                
                pm.email = pOpportunityDetails.primary_member.email;
                reconcileDuplicate(pm, existing, o, true);
                pm = existing;
            }
            
            pm.status__c          = 'active';
            pm.firstname          = pOpportunityDetails.primary_member.first_name;
            pm.lastname           = pOpportunityDetails.primary_member.last_name;
            pm.phone              = pOpportunityDetails.primary_member.phone;
            pm.birthdate          = pOpportunityDetails.primary_member.date_of_birth;
            pm.Gender__c          = pOpportunityDetails.primary_member.gender;
            pm.mailingstreet      = pOpportunityDetails.primary_member.address.street;
            pm.mailingcity        = pOpportunityDetails.primary_member.address.city;
            pm.mailingstate       = pOpportunityDetails.primary_member.address.state;
            pm.mailingpostalcode  = pOpportunityDetails.primary_member.address.zip;
            pm.mailingcountry     = pOpportunityDetails.primary_member.address.country;
            
            //dml
            update pm;
            
            //contact - members (we might have new contacts!)
            //containers
            Set<String> SContactEmails = new Set<String>();
            Set<Id> SContactIds = new Set<Id>();
            
            Contact[] upsertable_contacts = new Contact[]{}; 
                
                Map<String, Contact> existingContactsByEmail = new Map<String, Contact>();
            Map<Id, Contact> existingContactsById = new Map<Id, Contact>();
            
            //first pass collect existing Contact Emails or create new ones
            for(WWTypes.Member m : pOpportunityDetails.members) {
                if (m.email != null) 
                    SContactEmails.add(m.email);
                
                if (m.salesforce_id != null && m.salesforce_id.length() > 0)
                    SContactIds.add(m.salesforce_id);
            }
            
            //load existing contacts
            for ( Contact existing : [SELECT id, email, UUID__c FROM Contact WHERE email IN :SContactEmails and id NOT IN :SContactIds] ) {
                if (existing != null && existing.email != null && existing.email.length() > 0)
                    existingContactsByEmail.put(existing.email, existing);
            }
            
            existingContactsById = new Map<Id, Contact>([  SELECT id, email, UUID__c, Status__c, accountId
                                                         FROM Contact 
                                                         WHERE id IN :SContactIds
                                                        ]);
            
            
            //second pass to bind sObjects
            for(WWTypes.Member m : pOpportunityDetails.members) {        
                if (existingContactsById.containsKey(m.salesforce_id) ) {
                    Contact c = existingContactsById.get(m.salesforce_id);
                    
                    // Resolve duplicate by email
                    if (existingContactsByEmail.containsKey(m.email)) {
                        Contact existing = existingContactsByEmail.get(m.email);
                        reconcileDuplicate(c, existing, o, false);
                        c = existing;
                    }
                    
                    c.firstname = m.first_name;
                    c.lastname  = m.last_name;
                    c.email     = m.email;
                    c.phone     = m.phone;
                    c.birthdate = m.date_of_birth;
                    c.gender__c = m.gender;
                    c.status__c = m.status;
                    upsertable_contacts.add(c);
                } else if (existingContactsByEmail.containsKey(m.email)) {
                    Contact existing = existingContactsByEmail.get(m.email);
                    if (existing != null) {
                        existing.AccountID = a.Id;
                        existing.status__c = 'active';
                        update existing;
                    }
                }
                else { //create new contact
                    upsertable_contacts.add(
                        new Contact(
                            firstname = m.first_name,
                            lastname  = m.last_name,
                            email     = m.email,
                            phone     = m.phone,
                            birthdate = m.date_of_birth,
                            gender__c = m.gender,
                            status__c = 'active',
                            AccountID = a.Id
                        )
                    );
                }                
            }
            
            //dml
            upsert upsertable_contacts;
        } catch(Exception pEx) {
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('OpportunityServices','serializeOpportunityDetails',JSON.serialize(pOpportunityDetails), pEx)
            ); 
            throw new OpportunityServicesException(pEx.getMessage());
        }
    }
    
    public static void reconcileDuplicate(Contact newContact, Contact existingContact, Opportunity opportunity, Boolean isPrimary) {
        try{
            if (newContact.id == existingContact.id || newContact.email != existingContact.email) return;
            newContact.UUID__c = null;
            newContact.status__c = 'inactive';
            newContact.email = newContact.email + '.dup' + datetime.now().format('yyMMdd');
            
            // Move existing record to account and make them the PM
            existingContact.accountId = newContact.accountId;
            
            update newContact;
            update existingContact;
            
            if (isPrimary) {
                opportunity.primary_member__c = existingContact.id;	
                update opportunity;
            }
        } catch(Exception pEx) {
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('OpportunityServices','reconcileDuplicate', null, pEx)
            ); 
            throw new OpportunityServicesException(pEx.getMessage());
        }
    }
    
    public static List<String> getEncodedOpportunityIdsForAccount(Id accountId) {
        //container
        List<String> results = new List<String>();
        
        //collect opportunities
        for (Opportunity o : [SELECT Encoded_ID__c FROM Opportunity WHERE accountId = :accountId])
            results.add(o.Encoded_ID__c);
        
        return results;
    }
    
    public static Opportunity getOpportunitybySFId(String pId){
        Opportunity[] Os = [  SELECT Id, Count_of_Desk__c,locations_interested__c,Building__c
                            FROM Opportunity WHERE Id = : pId LIMIT 1
                           ];
        return Os.isEmpty() ? null : Os[0];
    }
    
    public class OpportunityServicesException extends Exception{}
    
}