/************************************************************************************************************************************
    Author      :   Anant Kumar
    Description :   This class will contain buisness logic of opportunity trigger.

    History:
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1           23 February 2016    Anant Kumar             Initial Developement
    2           12 May 2016         Amol Darekar
**************************************************************************************************************************************/
global class OpportunityTriggerHandler extends ITriggerHandler{
    public OpportunityTriggerHandler(){
        super('Opportunity');
    }
    public static Map<Id,List<OpportunityTeamMember>> mapOppRelatedTeamMembers = new Map<Id,List<OpportunityTeamMember>>();
    static Boolean handleRecursiveFlagForNotifyTeamMemberCwOrCl = true;
    static Boolean handleRecursiveForNotifyEmailOwnership = true;
    static Boolean hasOnceEmailSentForNotifyEmailOwnership = true;
    static Boolean handleRecursiveFlagForNotifyEmailAlertToReferralTeam = True;
    /************************************************************************************************************************************
    Author              :   Anant Kumar
    Description         :   This method overrides before insert method from ITriggerHander which will control the execution flow.
    Created Date        :   23 February 2016
    Last Modified Date  :   12 May 2016
    Last Modified By    :   Amol Darekar
    **************************************************************************************************************************************/
    public override void BeforeInsert(List<SObject> listNewItems){
        Debug.log('opportunity trigger'+listNewItems);
        handleRecursiveForNotifyEmailOwnership = false;
        if(TriggerSettings.mappedField.Opportunity_SetBrokerInvolved){
            OpportunityTriggerHandler.setBrokerInvolved((List<Opportunity>)listNewItems, null, null, null);
        }
        if(TriggerSettings.mappedField.Opportunity_inheritOrganizationRecordTypeAndOwner){
            //OpportunityTriggerHandler.inheritOrganizationRecordTypeAndOwner((List<Opportunity>)listNewItems, null);
        }
        Debug.log('Limits.getQueries() in opp Before Insert Start::'+Limits.getQueries());
        if (TriggerSettings.mappedField.Opportunity_UpdateWeLiveOpportunityType){
            OpportunityTriggerHandler.setTypeAndRecordTypeOfOpprtunity((List<Opportunity>)listNewItems);
        }
        Debug.log('Limits.getQueries() in opp Before Insert 01::'+Limits.getQueries());
        if(TriggerSettings.mappedField.Opportunity_UpdateActiveReferrer){
            OpportunityTriggerHandler.updateActiveReferrer((List<Opportunity>)listNewItems);
        }
        Debug.log('Limits.getQueries() in opp Before Insert 02::'+Limits.getQueries());
        if (TriggerSettings.mappedField.Opportunity_CopyFieldsFromLastOpportunity){
            OpportunityTriggerHandler.copyFieldsFromLastOpportunity((List<Opportunity>)listNewItems);
        }
        Debug.log('Limits.getQueries() in opp Before Insert 03::'+Limits.getQueries());
        if(TriggerSettings.mappedField.Opportunity_MapWithLatestTour){
            OpportunityTriggerHandler.mapWithLatestTour((List<Opportunity>)listNewItems);
        }
        Debug.log('Limits.getQueries() in opp Before Insert 04::'+Limits.getQueries());
        if(TriggerSettings.mappedField.Opportunity_SetOwnerByDealType){
            AccountAssignmentController.setOwnerByRoeAssignment(listNewItems, null, null, null);
        }
        
        Debug.log('Limits.getQueries() in opp Before Insert 05::'+Limits.getQueries());
        if(TriggerSettings.mappedField.Opportunity_ExtendReference){
            OpportunityTriggerHandler.extendReference((List<Opportunity>)listNewItems, null, null, null);
        }
        Debug.log('Limits.getQueries() in opp Before Insert 06::'+Limits.getQueries());
        if(TriggerSettings.mappedField.Opportunity_UpdateOpporunityOwnerOnSendPaperwork){
            OpportunityTriggerHandler.updateOpporunityOwnerOnSendPaperwork((List<Opportunity>)listNewItems, null, null, null);
        }
        Debug.log('Limits.getQueries() in opp Before Insert 07::'+Limits.getQueries());
        if (TriggerSettings.mappedField.Opportunity_UpdateOpportunityName){
            OpportunityTriggerHandler.updateOppName((List<Opportunity>)listNewItems,null,null,null);
        }
        if(TriggerSettings.mappedField.Opportunity_updateBrokerAccount){
            OpportunityTriggerHandler.updateBrokerAccount(listNewItems, null, null, null);
        }
         Debug.log('Limits.getQueries() in opp Before Insert 09::'+Limits.getQueries());
        if(TriggerSettings.mappedField.Opportunity_UpdateOppForecastCategory){
            OpportunityTriggerHandler.updateOppForecastCategory((List<Opportunity>)listNewItems, null);
        }
         Debug.log('Limits.getQueries() in opp Before Insert End::'+Limits.getQueries());
    }
    /************************************************************************************************************************************
    Author              :   Anant Kumar
    Description         :   This method overrides before update method from ITriggerHander which will control the execution flow.
    Last Modified Date  :   12 May 2016
    Last Modified By    :   Amol Darekar
    **************************************************************************************************************************************/
    public override void BeforeUpdate(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems){
        Debug.log('Limits.getQueries() in opp BeforeUpdate Start==>'+Limits.getQueries());
        if(TriggerSettings.mappedField.Opportunity_SetBrokerInvolved){
            OpportunityTriggerHandler.setBrokerInvolved((List<Opportunity>)listNewItems, (Map<Id,Opportunity>)mapNewItems, (List<Opportunity>)listOldItems, (Map<Id,Opportunity>)mapOldItems);
        }
        if(TriggerSettings.mappedField.Opportunity_inheritOrganizationRecordTypeAndOwner){
            OpportunityTriggerHandler.inheritOrganizationRecordTypeAndOwner((List<Opportunity>)listNewItems,(Map<Id,Opportunity>)mapNewItems);
        } 
        if(TriggerSettings.mappedField.Opportunity_ExtendReference){
            OpportunityTriggerHandler.extendReference((List<Opportunity>)listNewItems,(Map<Id,Opportunity>)mapNewItems,(List<Opportunity>)listOldItems,(Map<Id,Opportunity>)mapOldItems);
        }
        Debug.log('Limits.getQueries() in opp BeforeUpdate 01==>'+Limits.getQueries());
        if(TriggerSettings.mappedField.Opportunity_UpdateOpporunityOwnerOnSendPaperwork){
            OpportunityTriggerHandler.updateOpporunityOwnerOnSendPaperwork((List<Opportunity>)listNewItems,(Map<Id,Opportunity>)mapNewItems,(List<Opportunity>)listOldItems,(Map<Id,Opportunity>)mapOldItems);
        }
        Debug.log('Limits.getQueries() in opp BeforeUpdate 02==>'+Limits.getQueries());
        if(TriggerSettings.mappedField.Opportunity_UpdateOpportunityName){
            OpportunityTriggerHandler.updateOppName((List<Opportunity>)listNewItems,(Map<Id,Opportunity>)mapNewItems,(List<Opportunity>)listOldItems,(Map<Id,Opportunity>)mapOldItems);
        }
        Debug.log('Limits.getQueries() in opp BeforeUpdate 03==>'+Limits.getQueries());
        if(TriggerSettings.mappedField.Opportunity_RestrictUserToChangeLeadSource){
            OpportunityTriggerHandler.restrictUserToChangeLeadSource((List<Opportunity>)listNewItems,(Map<Id,Opportunity>)mapNewItems,(List<Opportunity>)listOldItems,(Map<Id,Opportunity>)mapOldItems);
        }
        if(TriggerSettings.mappedField.Opportunity_ManageEnterpriseOppTeamMembers){
            OpportunityTriggerHandler.storeOpportunityMembers((List<Opportunity>)listNewItems,(Map<Id,Opportunity>)mapNewItems,(List<Opportunity>)listOldItems,(Map<Id,Opportunity>)mapOldItems);
        }        
        Debug.log('Limits.getQueries() in opp BeforeUpdate 05::'+Limits.getQueries());
        if(TriggerSettings.mappedField.Opportunity_updateBrokerAccount){
            OpportunityTriggerHandler.updateBrokerAccount(listNewItems,(Map<Id,Opportunity>)mapNewItems,listOldItems,(Map<Id,Opportunity>)mapOldItems);
        }
		
        if(TriggerSettings.mappedField.Opportunity_UpdateOppForecastCategory){
            OpportunityTriggerHandler.updateOppForecastCategory((List<Opportunity>)listNewItems, (Map<Id,Opportunity>)mapOldItems);
        }
    }
    /************************************************************************************************************************************
    Author              :   Anant Kumar
    Description         :   This method overrides after insert method from ITriggerHander which will control the execution flow.
    Last Modified Date  :   12 May 2016
    Last Modified By    :   Amol Darekar
    **************************************************************************************************************************************/
    public override void AfterInsert(List<SObject> listNewItems, Map<Id, SObject> mapNewItems){
        Debug.log('Limits.getQueries() in opp After Insert Start::'+Limits.getQueries());
        if (TriggerSettings.mappedField.Opportunity_CreateDealOnOpportunityCreate){
            OpportunityTriggerHandler.createDealOnOpportunityCreate((List<Opportunity>)listNewItems, (Map<Id, Opportunity>) mapNewItems);
        }
        Debug.log('Limits.getQueries() in opp After Insert 01::'+Limits.getQueries());
        if (TriggerSettings.mappedField.Opportunity_UpdateEncodedID){
            OpportunityTriggerHandler.encodedOpportunityID((List<Opportunity>)listNewItems,(Map<Id,Opportunity>)mapNewItems);
        }
        Debug.log('Limits.getQueries() in opp After Insert 03::'+Limits.getQueries());
        if(TriggerSettings.mappedField.Opportunity_SetOwnerByDealType){
            AccountAssignmentController.setOwnerByRoeAssignment(listNewItems, mapNewItems, null, null);
        }
        Debug.log('Limits.getQueries() in opp After Insert 04::'+Limits.getQueries());
        if( TriggerSettings.mappedField.Opportunity_GenerateBuildingInterests){
            OpportunityTriggerHandler.UpsertBuildingInterests((List<Opportunity>)listNewItems,(Map<Id,Opportunity>)mapNewItems,null,null);
            OpportunityTriggerHandler.UpdateBuildingInterestsOfficeType((List<Opportunity>)listNewItems,(Map<Id,Opportunity>)mapNewItems,null,null);
            setOppIds = null;
            setLeadIds = null;
            lstBuildingintrested = null;
        }
        Debug.log('Limits.getQueries() in opp After Insert 05::'+Limits.getQueries());
        if(TriggerSettings.mappedField.Opportunity_MapOpportunityContactRole){
            OpportunityTriggerHandler.mapOpportunityContactRole((List<Opportunity>)listNewItems,(Map<Id,Opportunity>)mapNewItems,null,null);
        }
        Debug.log('Limits.getQueries() in opp After Insert 07::'+Limits.getQueries());
        
        if(TriggerSettings.mappedField.Opportunity_ChangeBillAccountConventionalName){
           OpportunityTriggerHandler.changeBillAccountConventionalName((List<Opportunity>)listNewItems,(Map<Id,Opportunity>)mapNewItems, null, null);
        }
        handleRecursiveForNotifyEmailOwnership = true;
        Debug.log('Limits.getQueries() in opp After Insert End::'+Limits.getQueries());
    }
    /************************************************************************************************************************************
    Author              :   Anant Kumar
    Description         :   This method overrides after update method from ITriggerHander which will control the execution flow.
    Last Modified Date  :   12 May 2016
    Last Modified By    :   Amol Darekar
    **************************************************************************************************************************************/
    public override void AfterUpdate(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems){
        Debug.log('Limits.getQueries() in opp AfterUpdate Start==>'+Limits.getQueries());
        Debug.log('Limits.getQueries() in opp AfterUpdate 01==>'+Limits.getQueries());
        if (TriggerSettings.mappedField.Opportunity_UpdateDealOnOpportunityUpdate){
            OpportunityTriggerHandler.updateDealWhenOpprtunityStageChange((List<Opportunity>)listNewItems,(Map<Id,Opportunity>)mapNewItems,(List<Opportunity>)listOldItems,(Map<Id,Opportunity>)mapOldItems);
        }
        Debug.log('Limits.getQueries() in opp AfterUpdate 02==>'+Limits.getQueries());
        if( TriggerSettings.mappedField.Opportunity_GenerateBuildingInterests){
            OpportunityTriggerHandler.MoveBuildingInterestsFromLead((List<Opportunity>)listNewItems,(Map<Id,Opportunity>)mapNewItems,(List<Opportunity>)listOldItems,(Map<Id,Opportunity>)mapOldItems);
            OpportunityTriggerHandler.UpsertBuildingInterests((List<Opportunity>)listNewItems,(Map<Id,Opportunity>)mapNewItems,(List<Opportunity>)listOldItems,(Map<Id,Opportunity>)mapOldItems);
            OpportunityTriggerHandler.UpdateBuildingInterestsOfficeType((List<Opportunity>)listNewItems,(Map<Id,Opportunity>)mapNewItems,(List<Opportunity>)listOldItems,(Map<Id,Opportunity>)mapOldItems);
            setOppIds = null;
            setLeadIds = null;
            lstBuildingintrested = null;
        }
        Debug.log('Limits.getQueries() in opp AfterUpdate 03==>'+Limits.getQueries());
        if(TriggerSettings.mappedField.Opportunity_MapOpportunityContactRole){
            OpportunityTriggerHandler.mapOpportunityContactRole((List<Opportunity>)listNewItems,(Map<Id,Opportunity>)mapNewItems,(List<Opportunity>)listOldItems,(Map<Id,Opportunity>)mapOldItems);
        }
        if(TriggerSettings.mappedField.Opportunity_ChangeBillAccountConventionalName){
            OpportunityTriggerHandler.changeBillAccountConventionalName((List<Opportunity>)listNewItems,(Map<Id,Opportunity>)mapNewItems,(List<Opportunity>)listOldItems,(Map<Id,Opportunity>)mapOldItems);        
        }
        if(TriggerSettings.mappedField.Opportunity_ReparentOpportunity){
            OpportunityTriggerHandler.reparentOpportunity((List<Opportunity>)listNewItems,mapNewItems,(List<Opportunity>)listOldItems,mapOldItems);   
        }
        if(TriggerSettings.mappedField.Opportunity_NotifyTeamMember){
            OpportunityTriggerHandler.notifyTeamMemberWhenOppGetsCwOrCl((List<Opportunity>)listNewItems, (Map<Id,Opportunity>)mapNewItems, (List<Opportunity>)listOldItems, (Map<Id,Opportunity>) mapOldItems);
        }
        if(TriggerSettings.mappedField.Opportunity_SendEmailOnOwnerChange){
            sendEmailOnOwnerChange((List<Opportunity>)listNewItems, (Map<Id, Opportunity>) mapNewItems, (List<Opportunity>) listOldItems, (Map<Id, Opportunity>) mapOldItems);
        }
        if(TriggerSettings.mappedField.Opportunity_SendEmailOnOwnerChange){
            notifyEmailAlertToReferralTeam((List<Opportunity>)listNewItems, (Map<Id, Opportunity>) mapNewItems, (List<Opportunity>) listOldItems, (Map<Id, Opportunity>) mapOldItems);
        }
        Debug.log('Limits.getQueries() in opp AfterUpdate End ==>'+Limits.getQueries());
    }
    /************************************************************************************************************************************
    Author              :   Anant Kumar
    Description         :   This method overrides before delete method from ITriggerHander which will control the execution flow.
    Last Modified Date  :   12 May 2016
    Last Modified By    :   Amol Darekar
    **************************************************************************************************************************************/
    public override void BeforeDelete(List<SObject> listOldItems, Map<Id, SObject> mapOldItems){
        Debug.log('Limits.getQueries() in opp BeforeDelete Start ==>'+Limits.getQueries());
        if(TriggerSettings.mappedField.Opportunity_DeleteBuildingInterests){
            OpportunityTriggerHandler.DeleteBuildingInterests((List<Opportunity>)listOldItems,(Map<Id,Opportunity>)mapOldItems);
        }
        Debug.log('Limits.getQueries() in opp BeforeDelete End ==>'+Limits.getQueries());
    }
    /************************************************************************************************************************************
        Author              :   Anant Kumar
        Description         :   This method used for create Deal record before opprtunity get created and assigne that Deal record to Deal lookup field on Opprtunity object.
        Issue No.           :   ST-317
        Last Modified Date  :   12 May 2016
        Last Modified By    :   Amol Darekar
        Last Modified By    :   Nikhil Mehta
        Description         :   Convert this method into after becauese after creation of opp then we have create opp role for enterprise.
    **************************************************************************************************************************************/
    public static void createDealOnOpportunityCreate(List<opportunity> lstOpportunities, Map<Id, Opportunity> mapNewOpportunities){
        if(lstOpportunities != null && lstOpportunities.size() > 0){
            set<Id> setRelatedAccountId = new set<Id>();
            Id EntSolutionId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise Solutions').getRecordTypeId();
            for(Opportunity currentOpprotunity:lstOpportunities){
                if(currentOpprotunity.AccountId!=null && currentOpprotunity.Deal__c == null && currentOpprotunity.RecordTypeId == EntSolutionId){
                    setRelatedAccountId.add(currentOpprotunity.AccountId);
                }
            }
            if(setRelatedAccountId.size()>0){
                map<Id,String> relatedAccounts = new map<Id,String>();
                for(Account currentAccount : [SELECT Id,Name FROM Account WHERE Id IN :setRelatedAccountId]) {
                    relatedAccounts.put(currentAccount.Id,currentAccount.Name);
                }
                Map<Id, Deal__c> mapDeals = new Map<Id, Deal__c>();
                Deal__c objDeal;
                for(Opportunity currentOpprotunity:lstOpportunities){
                    if(EntSolutionId != null && currentOpprotunity.RecordTypeId == EntSolutionId){
                        objDeal = new Deal__c();
                        objDeal.Name = currentOpprotunity.Name;
                        //objDeal.Approver_1__c = UseriNFO.getUserId();
                        objDeal.Status__c = 'Active';
                        if(relatedAccounts!=null){
                            objDeal.Counter_Party__c = relatedAccounts.get(currentOpprotunity.AccountId)!=null?relatedAccounts.get(currentOpprotunity.AccountId):null;
                        }
                        objDeal.Priority__c = 'I/NU';
                        objDeal.Group__c = 'Enterprise Solution';//ST-331
                        objDeal.Phase__c = 'E';
                        objDeal.Category__c = 'Membership';
                        mapDeals.put(currentOpprotunity.Id, objDeal);
                    }
                }
                if(mapDeals.size() > 0){
                    List<Opportunity> lstOpportunityToUpdate = new List<Opportunity>();
                    for(Opportunity currentOpprotunity:lstOpportunities){
                        if(mapDeals.containsKey(currentOpprotunity.Id) && mapDeals.get(currentOpprotunity.Id) != null && mapDeals.get(currentOpprotunity.Id).Id != null && currentOpprotunity.Deal__c == null){
                            lstOpportunityToUpdate.add(new Opportunity(Id=currentOpprotunity.Id,Deal__c = mapDeals.get(currentOpprotunity.Id).Id));
                        }
                    }
                    if(lstOpportunityToUpdate.size()>0){
                        update lstOpportunityToUpdate;
                    }
                }
            }
        }
    }
    /************************************************************************************************************************************
        Author              :   Amol Darekar
        Description         :   This method used for update Deal record Gate and Status when Opportunity phase change.
        Created Date        :   12 May 2016
        Issue No.           :   ST-318
    **************************************************************************************************************************************/
    public static void updateDealWhenOpprtunityStageChange(List<Opportunity> lstNewOpportunites, Map<Id, Opportunity> mapNewItems, List<Opportunity> listOldItems, Map<Id, Opportunity> mapOldItems){
        List<Opportunity> lstUpdatedOpportunites = new List<Opportunity>();
        List<Deal__c> lstDealToUpdate = new List<Deal__c>();
        Set <Id> setDealIds = new Set<Id>();

        Map <String,String> mapDealStatus = new Map <String,String>();
        mapDealStatus.put('Closed Won','Closed');
        mapDealStatus.put('Closed Lost','Dead');
        Map <String,String> mapDealGate = new Map <String,String>();
        mapDealGate.put('D','D');
        mapDealGate.put('C','C');
        mapDealGate.put('B','B');
        mapDealGate.put('A','A');
        // mapDealGate.put('Internal Sign Off','B');
        mapDealGate.put('Closed Won','A');
        Id EntSolutionId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise Solutions').getRecordTypeId();
        for(Opportunity currentOpprotunity : lstNewOpportunites){
            if(EntSolutionId != null && currentOpprotunity.RecordTypeId == EntSolutionId){
                Opportunity objOldOpp = mapOldItems.get(currentOpprotunity.ID);
                if(objOldOpp != null && (objOldOpp.StageName != currentOpprotunity.StageName || currentOpprotunity.Deal__c != objOldOpp.Deal__c)){
                    lstUpdatedOpportunites.add(currentOpprotunity);
                    if(currentOpprotunity.Deal__c !=null){
                        setDealIds.add(currentOpprotunity.Deal__c);
                    }

                }
            }
        }

        if(setDealIds.size()>0){
            Map<ID, Deal__c> mapDealToUpdate = new Map<ID, Deal__c>([SELECT Id, Status__c , Phase__c FROM Deal__c where Id IN :setDealIds]);
            if(lstUpdatedOpportunites.size()>0){
                for(Opportunity currentOpprotunity : lstUpdatedOpportunites){
                    Deal__c currentDeal = mapDealToUpdate.get(currentOpprotunity.Deal__c);
                    if(currentDeal!=null && currentOpprotunity.StageName != null){
                        if(mapDealStatus.get(currentOpprotunity.StageName) != null){
                            currentDeal.Status__c = mapDealStatus.get(currentOpprotunity.StageName);
                        }else{
                            currentDeal.Status__c = 'Active';
                        }
                        currentDeal.Phase__c= mapDealGate.get(currentOpprotunity.StageName);
                        lstDealToUpdate.add(currentDeal);
                    }
                }
            }
            if(lstDealToUpdate != null && lstDealToUpdate.size() > 0){
                update lstDealToUpdate;
            }
        }
    }
    /************************************************************************************************************************************
        Author              :   Amol Darekar
        Description         :   This method used for Change Type and Record type to Residential Space when LeadSource is 'WeLive' or 'WeLive.com' and also if Product Line is 'WeLive'.
        Created Date        :   14 June 2016
        Issue No.           :   ST-412
    **************************************************************************************************************************************/
    public static void setTypeAndRecordTypeOfOpprtunity(List<Opportunity>lstNewOpportunites){
        for(Opportunity currentOpprotunity : lstNewOpportunites){
            if(currentOpprotunity.LeadSource == 'WeLive.com' || currentOpprotunity.LeadSource == 'WeLive'){
                currentOpprotunity.Type__c = 'Residential Space';
                currentOpprotunity.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Residential Space').getRecordTypeId();
            }
        }

    }
    /************************************************************************************************************************************
        Author              :   Mayuresh Ghodke
        Description         :   For Enterprise :: Account Name - Market - Close Date - No_of_Desks_unweighted__c. For MidMarket/Consumer :: Account Name - Close Date - No_of_Desks_unweighted__c.
                                in both cases please ensure all text to right of Account Name is NOT clipped and that the entire name fits within 80 chars….
        Issue No.           :  ST-434,ST-921
        Last Modified Date  :  21 November 2016
        Last Modified By    :   Krishana Tupe
        Modified By         :   Priyanka Ambre on 25-April-2018 for ST-2290
  **************************************************************************************************************************************/
    public static void updateOppName(List<Opportunity> lstNewOpportunities, Map<Id, Opportunity> mapNewOpportunities, List<Opportunity> listOldItems, Map<Id, Opportunity> mapOldOpportunities){
        Map<ID,Schema.RecordTypeInfo> oppRecordTypeMap = Opportunity.sObjectType.getDescribe().getRecordTypeInfosById();
        Set<Id> accountIdSet = new Set<Id>();
        Set<Id> setOpportunityIds = new Set<Id>();
        Map<Id, Opportunity> mapOppRelatedOppLineItems = new Map<Id, Opportunity>();
        Map<Id, Geography__c> mapOppRelatedGeographies = new Map<Id, Geography__c>();
        Map<Id, Building__c> mapOppRelatedBuildings = new Map<Id, Building__c>();
        for(Opportunity oppRec : lstNewOpportunities){
            if((mapOldOpportunities == null && oppRec.AccountId != null) || (mapOldOpportunities != null && oppRec.AccountId != mapOldOpportunities.get(oppRec.Id).AccountId)){
                accountIdSet.add(oppRec.AccountId);
            }
            setOpportunityIds.add(oppRec.Id);
        }
        if(setOpportunityIds.size()>0){
            for(Opportunity oppRec : [SELECT Id, Name, AccountId, Opportunity_Account_Name__c, CloseDate, Building__c, Building__r.Name, Geography__c, Geography__r.Name, Geography__r.City__c, Geography__r.State__c, Geography__r.Country__c, Type__c, (SELECT Id, Name, Family__c, Quantity, Geography__c, Geography__r.Name, Geography__r.City__c, Geography__r.State__c, Geography__r.Country__c, Building__c, Building__r.Name, Is_Primary_Product__c FROM OpportunityLineItems) FROM Opportunity WHERE Id IN: setOpportunityIds]){
                debug.log('oppRec-->'+oppRec);
                if(oppRec.OpportunityLineItems != null && oppRec.OpportunityLineItems.size() > 0){
                    mapOppRelatedOppLineItems.put(oppRec.Id, oppRec);
                }
                if(oppRec.Geography__c != null && oppRec.Geography__r != null){
                    mapOppRelatedGeographies.put(oppRec.Geography__c, oppRec.Geography__r);
                }
                if(oppRec.Building__c != null && oppRec.Building__r != null){
                    mapOppRelatedBuildings.put(oppRec.Building__c, oppRec.Building__r);
                }
            }
        }
        if(accountIdSet.size() > 0 ||setOpportunityIds.size()>0){
            for(Opportunity oppRec : lstNewOpportunities){
                String accountName = oppRec.Opportunity_Account_Name__c;
                String oppName = null;
                DateTime todayDT;
                String dateStr = null;
                if(oppRec.CloseDate == null){
                    todayDT = System.now();
                    dateStr = todayDT.format('MMM dd, yyyy');
                }else{
                    todayDT = DateTime.newInstance(oppRec.CloseDate.year(), oppRec.CloseDate.month(), oppRec.CloseDate.day());
                    dateStr = todayDT.format('MMM dd, yyyy');
                    Debug.log('dateStr :: '+dateStr);
                }
                Debug.log('todayDT :: '+todayDT);
                if(oppRec.recordTypeId != null && oppRecordTypeMap.get(oppRec.recordTypeID).getName().containsIgnoreCase('Enterprise Solutions')){
                    // Modified By Priyanka Ambre on 25-April-2018 for ST-2290
                    if(oppRec.Id == null){
                        oppName = accountName+oppRec.Type__c+dateStr;
                    }else if(oppRec.Id != null){
                        Integer noOfMemmeberships = 0;
                        if(mapOppRelatedOppLineItems.size()>0 && mapOppRelatedOppLineItems.containsKey(oppRec.Id) && mapOppRelatedOppLineItems.get(oppRec.Id).OpportunityLineItems != null && mapOppRelatedOppLineItems.get(oppRec.Id).OpportunityLineItems.size() > 0){
                            for(OpportunityLineItem oppLineItem : mapOppRelatedOppLineItems.get(oppRec.Id).OpportunityLineItems){
                                noOfMemmeberships += Integer.valueOf(oppLineItem.Quantity);
                            }
                        }
                        String geography = '';
                        String marketInterested = '';
                        if(oppRec.Type__c == 'Mixed'){
                            oppName = accountName + '-' + oppRec.Type__c + '-' + dateStr;
                        }else if(oppRec.Type__c != null && oppRec.Type__c != 'Mixed'){
                            Building__c building = mapOppRelatedBuildings.get(oppRec.Building__c);
                            if(oppRec.Geography__c != null && mapOppRelatedGeographies!= null && mapOppRelatedGeographies.get(oppRec.Geography__c) != null){
                                Geography__c oppRelatedGeo = mapOppRelatedGeographies.get(oppRec.Geography__c);
                                if(oppRelatedGeo.City__c != null){
                                    geography = oppRelatedGeo.City__c;
                                } else if(oppRelatedGeo.State__c != null) {
                                    geography = oppRelatedGeo.State__c;
                                } else if(oppRelatedGeo.Country__c != null) {
                                    geography = oppRelatedGeo.Country__c;
                                }
                            }else if(String.isNotBlank(oppRec.Building__c) && building != null &&  String.isNotBlank(building.Name)){
                                marketInterested += building.Name;
                            }
                            if(oppRec.Type__c.toLowerCase() == 'wework'){
                                Integer noOfDesks = (oppRec.No_of_Desks_unweighted__c != null && oppRec.No_of_Desks_unweighted__c != 0)  ? Integer.valueOf(oppRec.No_of_Desks_unweighted__c) : (oppRec.Requirement_Quantity__c != null ? Integer.valueOf(oppRec.Requirement_Quantity__c) : 0);
                                marketInterested = geography != null && !String.isBlank(geography) ? geography : marketInterested;
                                Debug.Log('marketInterested---'+marketInterested);
                                oppName = accountName + (!String.isEmpty(marketInterested) ? '-'+marketInterested : '')+'-WW-' + (noOfDesks == 0 ? '' : noOfDesks + '-') + dateStr;
                            }else if(oppRec.Type__c.toLowerCase() == 'global access'){
                                Integer noOfDesks = (noOfMemmeberships != null && noOfMemmeberships != 0 ? noOfMemmeberships : (oppRec.Requirement_Quantity__c != null && oppRec.Requirement_Quantity__c != 0 ? Integer.valueOf(oppRec.Requirement_Quantity__c) : 0));
                                oppName = accountName + (!String.isEmpty(geography) ? '-'+geography : '') + '-GA-' + (noOfDesks == 0 ? '' : noOfDesks + '-') + dateStr;
                            }else if(oppRec.Type__c.toLowerCase() == 'pxwe'){
                                oppName = accountName + (!String.isEmpty(geography) ? '-'+geography : '') + '-PxWe-' + dateStr;
                            }else{
                                oppName = accountName + '-' + oppRec.Type__c + '-' + (oppRec.Requirement_Quantity__c != null && oppRec.Requirement_Quantity__c != 0 ? Integer.valueOf(oppRec.Requirement_Quantity__c) + '-' : '') + dateStr;
                            }
                        }else{
                            oppName = accountName + '-' +dateStr;
                        }
                    }
                } else if(oppRec.AccountId != null){
                    oppName = accountName+'-'+dateStr+((oppRec.No_of_Desks_unweighted__c != 0 && oppRec.No_of_Desks_unweighted__c != null) ? +'-'+oppRec.No_of_Desks_unweighted__c: '');
                    if(oppName.length() < 81){
                        oppRec.Name = oppName;
                    }else{
                        oppName = accountName.substring(0, 30)+'-'+dateStr+''+((oppRec.No_of_Desks_unweighted__c != 0 && oppRec.No_of_Desks_unweighted__c != null) ? +'-'+oppRec.No_of_Desks_unweighted__c: '');
                    }
                }
                if(!String.isBlank(oppName)){
                    if(oppName.length()>120){
                        oppName = accountName.substring(0,120-(oppName.length()-accountName.length())).substringBeforeLast(' ')+oppName.removeStartIgnoreCase(accountName);
                    }
                    oppRec.Name = oppName;
                } else{
                    oppRec.Name = 'Test';
                }
            }
        }
    }
    /************************************************************************************************************************************
        Author              :   Samadhan Kadam
        Description         :   This method will Copy field from last opportunity.
        Created Date        :   17 June 2016
        Issue No.           :   ST-451
        Last Modified Date  :   10 August 2016
        Last Modified By    :   Pranay Jadhav
    **************************************************************************************************************************************/
    public static void copyFieldsFromLastOpportunity(List<Opportunity> lstNewOpportunities){
        set<Id> setContacts = new set<Id>();
        map<Id, Opportunity> mapExistingOpp = new map<Id, Opportunity>();
        for(Opportunity opp : lstNewOpportunities){
            if(opp.Primary_Member__c != null){
                setContacts.add(opp.Primary_Member__c);
            }
        }
        if(!setContacts.isEmpty()){
            Debug.log('In copyFieldsFromLastOpportunity setContacts :: '+setContacts);
            Setting__c setting = Settings.get('OpportunityFromLatestOpportunity');
            debug.Log('OpportunityFromLatestOpportunity :: '+setting);
            if(setting != null){
                Map<String, Object> mapData = (Map<String,Object>)JSON.deserializeUntyped(setting.Data__c);
                Debug.log('In copyFieldsFromLastOpportunity mapData :: '+mapData);
                String strQuery = 'Select Primary_Member__c, CreatedDate, ';
                for(String strKey : mapData.KeySet()){
                    if(strKey != 'createDuration')
                        strQuery += strKey + ',';
                }
                DateTime lastNDays = System.now();
                String createDurationJson = JSON.serialize(mapData.get('createDuration'));
                Debug.log('createDurationJson :: '+createDurationJson);
                Map<String, Object> copyDurationJsonVal = (Map<String, Object>) JSON.deserializeUntyped(createDurationJson);
                Debug.log('copyDurationJsonVal upto :: '+copyDurationJsonVal.get('upto'));
                String toSplit = String.valueOf(copyDurationJsonVal.get('upto'));
                Debug.log('toSplit :: '+toSplit.length());
                if(toSplit.length() != 0){
                    String[] copyDurationVal = toSplit.split(' ');
                    if(copyDurationVal.size() == 2){
                        Debug.log('copyDurationVal :: '+copyDurationVal);
                        Integer numberOfDays = 0;
                        Debug.log('copyDurationVal[0] :: '+copyDurationVal[0]);

                        if(copyDurationVal[1].toLowerCase() == 'months' || copyDurationVal[1].toLowerCase() == 'month')
                            lastNDays = lastNDays.addMonths(-Integer.valueof(copyDurationVal[0]));
                        else if(copyDurationVal[1].toLowerCase() == 'weeks' || copyDurationVal[1].toLowerCase() == 'week'){
                            numberOfDays = Integer.valueof(copyDurationVal[0]) * 7;
                            lastNDays = lastNDays.addDays(-numberOfDays);
                        }
                        else if(copyDurationVal[1].toLowerCase() == 'days' || copyDurationVal[1].toLowerCase() == 'day')
                            lastNDays = lastNDays.addDays(-Integer.valueof(copyDurationVal[0]));
                        else
                            lastNDays = lastNDays.addDays(-60);
                    }
                    else
                        lastNDays = lastNDays.addDays(-60);
                }
                else
                    lastNDays = lastNDays.addDays(-60);

                Debug.log('lastNDays :: '+lastNDays);
                strQuery = strQuery.removeEnd(',');
                strQuery += ' FROM Opportunity WHERE CreatedDate >: lastNDays AND Primary_Member__c in :setContacts ORDER BY CreatedDate DESC LIMIT 100000';

                for(Opportunity existingOpp : Database.Query(strQuery)){
                    if(!mapExistingOpp.containsKey(existingOpp.Primary_Member__c)){
                        mapExistingOpp.put(existingOpp.Primary_Member__c, existingOpp);
                    }
                }
                Debug.Log('mapExistingOpp :: '+mapExistingOpp);
                for(Opportunity opportunity : lstNewOpportunities)
                {
                    Opportunity existing = mapExistingOpp.get(opportunity.Primary_Member__c);
                    Debug.Log('existing :: '+existing);
                    if(existing!=null)
                    {
                        for(String strKey : mapData.keySet())
                        {
                            if(strKey != 'createDuration'){
                                Debug.log('In copyFieldsFromLastOpportunity strKey :: '+strKey);
                                if(opportunity.get(strKey) == null){
                                    Object fieldObj = mapData.get(strKey);
                                    Map<String, Object> fieldMap = (Map<String, Object>)fieldObj;
                                    opportunity.put((String)fieldMap.get('name'), existing.get(strKey));
                                }
                            }
                        }
                    }
                }
            }
        }

    }
    /************************************************************************************************************************************
        Author              :   Anant Kumar
        Description         :   This method will encode Opportunity Id.
        Created Date        :   21 June 2016
        Issue No.           :   ST-455
    **************************************************************************************************************************************/
    public static void encodedOpportunityID(List<Opportunity> lstNewOpportunities, Map<Id, Opportunity> mapNewOpportunities){
        List<Opportunity> lstOpportunities = new List<Opportunity>();
        for(Opportunity objOpp : lstNewOpportunities){
            if(objOpp.Encoded_Id__c==null){
                lstOpportunities.add(new Opportunity(Id = objOpp.Id, Encoded_Id__c = EncodingUtil.base64Encode(Blob.valueOf(objOpp.Id))));
            }
        }
        if(lstOpportunities != null && lstOpportunities.size()>0){
            update lstOpportunities;
        }
    }
    static List<Building_Interest__c> lstBuildingintrested;
    static Set<Id> setOppIds;
    static Set<Id> setLeadIds;
    private static void getBuildingIntrested(Set<Id> setOppIds,Set<Id> setLeadIds){
        if(setLeadIds != null && setOppIds != null){
            OpportunityTriggerhandler.setOppIds = setOppIds;
            OpportunityTriggerhandler.setLeadIds = setLeadIds;
            OpportunityTriggerhandler.lstBuildingintrested = [SELECT Id, Building__c, Building__r.Name, Opportunity__c, Opportunity__r.Locations_Interested__c,Lead__c,Office_Type__c FROM Building_Interest__c WHERE Opportunity__c IN :setOppIds or Lead__c IN :setLeadIds];
        }else if(setLeadIds != null && setOppIds == null){
            OpportunityTriggerhandler.setLeadIds = setLeadIds;
            OpportunityTriggerhandler.lstBuildingintrested =  [SELECT Id, Building__c, Building__r.Name, Opportunity__c, Opportunity__r.Locations_Interested__c,Lead__c,Office_Type__c FROM Building_Interest__c WHERE Lead__c IN :setLeadIds];
        }else if(setLeadIds == null && setOppIds != null){
            OpportunityTriggerhandler.setOppIds = setOppIds;
            OpportunityTriggerhandler.lstBuildingintrested =  [SELECT Id, Building__c, Building__r.Name, Opportunity__c, Opportunity__r.Locations_Interested__c,Office_Type__c FROM Building_Interest__c WHERE Opportunity__c IN :setOppIds];
        }
        debug.Log('setOppIds: '+setOppIds);
        debug.log('setLeadIds: '+setLeadIds);
    }
    /************************************************************************************************************************************
        Author              :   Hemanshu Shah
        Description         :   This method will move related Building Interest records from Lead to current Opportunity when Opportunity is created.
        Created Date        :   26 June 2016
        Issue               :   Moving from BuildingInterestTrigger.
    **************************************************************************************************************************************/
    public static void MoveBuildingInterestsFromLead(List<Opportunity> lstNewOpportunities, Map<Id, Opportunity> mapNewOpportunities, List<Opportunity> lstOldOpportunities, Map<Id, Opportunity> mapOldOpportunities) {
        Map<Id,string> leadOppMap = new Map<Id,string>();
        Set<Id> setOpportunityIds = new Set<Id>();
        for (Opportunity opp : lstNewOpportunities) {
            if (String.isNotBlank(opp.Lead_Id__c) && (Trigger.isInsert || opp.Lead_Id__c != (mapOldOpportunities.get(opp.Id)).Lead_Id__c)) {
                leadOppMap.put(Id.valueOf(opp.Lead_Id__c), opp.Id);
            }
            if(Trigger.isInsert || (Trigger.isUpdate && opp.Locations_Interested__c != mapOldOpportunities.get(opp.Id).Locations_Interested__c) || (Trigger.isUpdate && opp.Office_Type__c!=mapOldOpportunities.get(opp.Id).Office_Type__c)){
                setOpportunityIds.add(opp.Id);
            }
        }
        if(leadOppMap != null && !leadOppMap.isEmpty()) {
            /*List<Building_Interest__c> lstBuildingIntrestedToBeUpdate = [SELECT
                                                                         Id, Opportunity__c, Lead__c
                                                                         FROM
                                                                         Building_Interest__c
                                                                         WHERE
                                                                         Lead__c IN :leadOppMap.keySet()
                                                                         ORDER BY
                                                                         Lead__c];*/
            List<Building_Interest__c> lstBuildingIntrestedToBeUpdate = new List<Building_Interest__c>();
            if((leadOppMap != null && !leadOppMap.isEmpty()) || (setOpportunityIds != null && setOpportunityIds.size()>0) ){
                if(!(OpportunityTriggerHandler.setOppIds != null && OpportunityTriggerHandler.setLeadIds.containsAll(leadOppMap.keySet()) && OpportunityTriggerHandler.setOppIds != null && OpportunityTriggerHandler.setOppIds.containsAll(setOpportunityIds) && OpportunityTriggerHandler.lstBuildingintrested.size()>0)){
                    OpportunityTriggerHandler.getBuildingIntrested(setOpportunityIds,leadOppMap.keySet());
                }else{
                    lstBuildingIntrestedToBeUpdate = OpportunityTriggerhandler.lstBuildingintrested;
                }
            }
            Debug.log('>>>>>lstBuildingIntrestedToBeUpdate ' + lstBuildingIntrestedToBeUpdate);
            for(Building_Interest__c buildingInterestedRec: lstBuildingIntrestedToBeUpdate) {
                buildingInterestedRec.Opportunity__c = leadOppMap.get(buildingInterestedRec.Lead__c);
                buildingInterestedRec.Lead__c = null;
            }
            Debug.log('>>>>>lstBuildingIntrestedToBeUpdate ' + lstBuildingIntrestedToBeUpdate);
            if (lstBuildingIntrestedToBeUpdate.size() > 0) {
                update lstBuildingIntrestedToBeUpdate;
            }
        }
    }
    /************************************************************************************************************************************
        Author              :   Hemanshu Shah
        Description         :   This method will upsert related Building Interest records when Opportunity is created or updated.
        Created Date        :   26 June 2016
        Issue               :   Moving from BuildingInterestTrigger.
    **************************************************************************************************************************************/
    public static void UpdateBuildingInterestsOfficeType(List<Opportunity> lstNewOpportunities, Map<Id, Opportunity> mapNewOpportunities, List<Opportunity> lstOldOpportunities, Map<Id, Opportunity> mapOldOpportunities) {
        Set<Id> setOpportunityIds = new Set<Id>();
        for(Opportunity objOpp:lstNewOpportunities){
            if(Trigger.isInsert || objOpp.Office_Type__c!=mapOldOpportunities.get(objOpp.Id).get('Office_Type__c')){
                setOpportunityIds.add(objOpp.Id);
            }
        }
        if(setOpportunityIds.size()>0){
            List<Building_Interest__c> lstBuildingInterested = new List<Building_Interest__c>();
            if(OpportunityTriggerHandler.setOppIds != null && OpportunityTriggerHandler.setOppIds.containsAll(setOpportunityIds) && OpportunityTriggerHandler.lstBuildingintrested.size()>0){
                lstBuildingInterested = OpportunityTriggerHandler.lstBuildingintrested;
            }else{
                OpportunityTriggerHandler.getBuildingIntrested(setOpportunityIds,null);
                lstBuildingInterested = OpportunityTriggerHandler.lstBuildingintrested;
            }
            /*List<Building_Interest__c> lstBuildingInterested = [SELECT Id, Opportunity__c, Office_Type__c FROM Building_Interest__c
                                                WHERE Opportunity__c IN :setOpportunityIds];*/
            List<Building_Interest__c> lstBuildingIntrestedToBeUpdate = new List<Building_Interest__c>();
            for(Building_Interest__c buildingInterestedRec : lstBuildingInterested){
                //Update if it is different
                if(buildingInterestedRec.Office_Type__c != mapNewOpportunities.get(buildingInterestedRec.Opportunity__c).Office_Type__c){
                    buildingInterestedRec.Office_Type__c = mapNewOpportunities.get(buildingInterestedRec.Opportunity__c).Office_Type__c;
                    lstBuildingIntrestedToBeUpdate.add(buildingInterestedRec);
                }
            }
            if(lstBuildingIntrestedToBeUpdate.size() > 0){
                update lstBuildingIntrestedToBeUpdate;
            }
        }
    }
    /************************************************************************************************************************************
        Author              :   Hemanshu Shah
        Description         :   This method will upsert related Building Interest records when Opportunity is created or updated.
        Created Date        :   26 June 2016
        Issue               :   Moving from BuildingInterestTrigger.
    **************************************************************************************************************************************/
    public static void UpsertBuildingInterests(List<Opportunity> lstNewOpportunities, Map<Id, Opportunity> mapNewOpportunities, List<Opportunity> listOldOpportunities, Map<Id, Opportunity> mapOldOpportunities){
        //Get all existing Building Interest records
        String NONE_BUILDING_NAME = 'None';
        Set<Id> setOpportunityIds = new Set<Id>();
        for(Opportunity objOpp:lstNewOpportunities){
            if(Trigger.isInsert || (Trigger.isUpdate && objOpp.Locations_Interested__c != mapOldOpportunities.get(objOpp.Id).Locations_Interested__c)){ //|| (Trigger.isUpdate && objOpp.Office_Type__c!=mapOldOpportunities.get(objOpp.Id).Office_Type__c)){
                setOpportunityIds.add(objOpp.Id);
            }
        }
        DEbug.log('UpsertBuildingInterests setOpportunityIds ::'+setOpportunityIds);
        if(setOpportunityIds.size()>0){
            List<Building_Interest__c> lstBuildingInterested = new List<Building_Interest__c>();
            if(OpportunityTriggerHandler.setOppIds != null && OpportunityTriggerHandler.setOppIds.containsAll(setOpportunityIds) && OpportunityTriggerHandler.lstBuildingintrested.size()>0){
                lstBuildingInterested = OpportunityTriggerHandler.lstBuildingintrested;
            }else{
                OpportunityTriggerHandler.getBuildingIntrested(setOpportunityIds,null);
                lstBuildingInterested = OpportunityTriggerHandler.lstBuildingintrested;
            }
            /*List<Building_Interest__c> lstBuildingInterested = [SELECT
                                                       Id, Building__c, Building__r.Name, Opportunity__c, Opportunity__r.Locations_Interested__c
                                                       FROM
                                                       Building_Interest__c
                                                       WHERE
                                                       Opportunity__c IN :setOpportunityIds
                                                       ORDER BY
                                                       Opportunity__c];*/
            Debug.log('lstBuildingIntrested ==>'+lstBuildingInterested);
            //Lists for creation and deletion
            List<Building_Interest__c> lstBuildingInterestedToBeCreated = new List<Building_Interest__c>();
            List<Building_Interest__c> lstBuildingInterestedToBeDeleted = new List<Building_Interest__c>();

            //Check if Building Interest is removed from Locations_Interested__c list
            //Id lastOpp = null;            
            for(Building_Interest__c buildingInterestedRec : lstBuildingInterested){
                Set<string> setOppLocations = new Set<string>();
                if(String.isBlank(buildingInterestedRec.Opportunity__r.Locations_Interested__c)){
                    setOppLocations.add(NONE_BUILDING_NAME);
                }else{
                    setOppLocations.addAll(buildingInterestedRec.Opportunity__r.Locations_Interested__c.split(';'));   
                }
                
                /*if(lastOpp != buildingInterestedRec.Opportunity__c){
                    lastOpp = buildingInterestedRec.Opportunity__c;
                    if(String.isBlank(buildingInterestedRec.Opportunity__r.Locations_Interested__c)) {
                        setOppLocations.add(NONE_BUILDING_NAME);
                    }else{
                        setOppLocations.addAll(buildingInterestedRec.Opportunity__r.Locations_Interested__c.split(';'));
                    }
                }*/
                Debug.log('setOppLocations==>'+setOppLocations);
                if(setOppLocations!= null &&!setOppLocations.contains(buildingInterestedRec.Building__r.Name)){
                    Debug.log('In true for Delete==>'+buildingInterestedRec);
                    lstBuildingInterestedToBeDeleted.add(buildingInterestedRec);
                }
            }
            //Check which have to be added
            Map<Id, Set<String>> mapOppBuildingInterested = new Map<Id, Set<String>>();           
            for(Building_Interest__c buildingInterestedRec : lstBuildingInterested){ 
                if(String.isNotBlank(buildingInterestedRec.Building__c) && String.isNotBlank(buildingInterestedRec.Building__r.Name)){
                    if(mapOppBuildingInterested.containsKey(buildingInterestedRec.Opportunity__c)){                       
                        Set<String> setBuildingInterested = mapOppBuildingInterested.get(buildingInterestedRec.Opportunity__c);
                        setBuildingInterested.add(buildingInterestedRec.Building__r.Name); 
                        mapOppBuildingInterested.put(buildingInterestedRec.Opportunity__c, setBuildingInterested);
                    }else{
                        mapOppBuildingInterested.put(buildingInterestedRec.Opportunity__c,new Set<String>{buildingInterestedRec.Building__r.Name}); 
                    }                
                    
                }  
                         
                /*if(!mapOppBuildingInterested.containsKey(buildingInterestedRec.Opportunity__c)){
                    mapOppBuildingInterested.put(buildingInterestedRec.Opportunity__c, new Set<string>());
                }
                Set<string> setBuildingInterested = mapOppBuildingInterested.get(buildingInterestedRec.Opportunity__c);
                setBuildingInterested.add(buildingInterestedRec.Building__r.Name);*/
            }
            Settings.fetchBuildings();
            Map<string, Building__c> mapBuildings = new Map<string, Building__c>();
            for(Building__c buildingRec : Settings.lstBuildings){
                mapBuildings.put(buildingRec.Name, buildingRec);
            }       
            for(Opportunity oppRec : mapNewOpportunities.values()) {
                Set<String> setSelectedLocations = new Set<String>();
                if(string.isBlank(oppRec.Locations_Interested__c)){
                    setSelectedLocations.add(NONE_BUILDING_NAME);
                }else{
                    setSelectedLocations.addAll(new List<String>(oppRec.Locations_Interested__c.split(';')));
                }          
                if(setSelectedLocations != null && setSelectedLocations.size() >0){
                    Set<String> setExistingLocations = mapOppBuildingInterested.get(oppRec.Id);
                    Debug.log('setExistingLocations==>'+setExistingLocations);
                    for(String selectedLocation : setSelectedLocations) {                       
                        if(setExistingLocations == null || !setExistingLocations.contains(selectedLocation)) {
                            if(mapBuildings.containsKey(selectedLocation)) {
                                lstBuildingInterestedToBeCreated.add(new Building_Interest__c(Opportunity__c = oppRec.Id,Building__c = mapBuildings.get(selectedLocation).Id));
                            }
                        }
                    }   
                }
            }
            Debug.log('lstBuildingInterestedToBeCreated ==>'+lstBuildingInterestedToBeCreated);
            Debug.log('lstBuildingInterestedToBeDeleted ==>'+lstBuildingInterestedToBeDeleted);
            if(lstBuildingInterestedToBeCreated.size() > 0){
                insert lstBuildingInterestedToBeCreated;
            }            
            if(lstBuildingInterestedToBeDeleted.size() > 0){
                delete lstBuildingInterestedToBeDeleted;
            }
        }
    }
    /************************************************************************************************************************************
        Author              :   Hemanshu Shah
        Description         :   This method will delete related Building Interest records when Opportunity is deleted.
        Created Date        :   26 June 2016
        Issue               :   Moving from BuildingInterestTrigger.
    **************************************************************************************************************************************/
    public static void DeleteBuildingInterests(List<Opportunity> lstOldOpportunities, Map<Id, Opportunity> mapOldOpportunities){
        //Get all existing Building Interest records
        delete [SELECT Id FROM Building_Interest__c WHERE Opportunity__c IN :mapOldOpportunities.keySet() ORDER BY Opportunity__c];
    }
    /************************************************************************************************************************************
        Author              :   Anant Kumar
        Description         :   This method has auto tagging for referral app.
        Created Date        :   20 July 2016
        Issue No.           :   ST-530
    **************************************************************************************************************************************/
    public static void updateActiveReferrer(List<Opportunity> lstNewOpportunities){
        Set<String> primaryContactEmails = new Set<String>();
        for(Opportunity opp : lstNewOpportunities){
            if(opp.Primary_Member__c != null){
                primaryContactEmails.add(opp.Primary_Member_Email_New__c);
            }

        }
        if(primaryContactEmails.size() > 0){
            Map<String, Id> mapActiveReferences = ReferenceHandler.getActiveReference(primaryContactEmails);
            for(Opportunity opp : lstNewOpportunities){
                if(mapActiveReferences != null && opp.Primary_Member_Email_New__c != null && mapActiveReferences.containsKey(opp.Primary_Member_Email_New__c.toLowerCase()))
                    opp.Referrer__c = mapActiveReferences.get(opp.Primary_Member_Email_New__c.toLowerCase());
            }
        }
    }
    /************************************************************************************************************************************
        Author              :   Anant Kumar
        Description         :   This method will extend Reference for new Opportunities.
        Created Date        :   21 July 2016
        Issue No.           :   ST-475
    **************************************************************************************************************************************/
    public static void extendReference(List<Opportunity> lstNewOpportunities, Map<Id, Opportunity> mapNewOpportunities, List<Opportunity> lstOldOpportunities, Map<Id, Opportunity> mapOldOpportunities){
        Set<String> primaryContactEmails = new Set<String>();
        for(Opportunity opp : lstNewOpportunities){
            if(opp.Primary_Member__c != null && (Trigger.isInsert || (Trigger.isUpdate && opp.StageName != mapOldOpportunities.get(opp.Id).get('StageName') && opp.StageName == 'Closing'))){
                primaryContactEmails.add(opp.Primary_Member_Email_New__c);
            }
        }
        if(primaryContactEmails.size() > 0){
            ReferenceHandler.ExtendReference(primaryContactEmails);
        }
    }
    
    /************************************************************************************************************************************
        Author              :   Anant Kumar
        Description         :   This method will map opportunity with latest booked tour on its primary member with same location interested.
        Created Date        :   29 July 2016
        Issue No.           :   ST-508
    **************************************************************************************************************************************/
    public static void mapWithLatestTour(List<Opportunity> lstNewOpportunities){
        Debug.log('Trigger-1');
        Set<Id> contactIds = new Set<Id>();
        for(Opportunity opp : lstNewOpportunities){
            if(opp.Primary_Member__c != null){
                contactIds.add(opp.Primary_Member__c);
            }
        }
        if(contactIds.size()>0){
            Map<Id, Contact> mapContacts = new Map<Id, Contact>([SELECT Id, (Select Location__c, CreatedDate From Tours3__r ORDER BY CreatedDate DESC Limit 1) FROM Contact WHERE Id in:contactIds]);
            for(Opportunity opp : lstNewOpportunities){
                if(opp.Primary_Member__c != null){
                    for(Tour_Outcome__c tour : mapContacts.get(opp.Primary_Member__c).Tours3__r){
                        if(tour.Location__c == opp.Building__c)
                            opp.Tour_Outcome__c = tour.Id;
                    }
                }
            }
        }
    }
    /************************************************************************************************************************************
        Author              :   Anant Kumar
        Description         :   This is a wrapper class is used to store splash, opportunity stages, campaign types.
        Created Date        :   23 February 2016
        Last Modified Date  :   28 February 2017
        Last Modified By    :   Dipak Pawar
    **************************************************************************************************************************************/
    public class Campaingsettings {
        public List<SplashSettings> SplashSettings;
        public List<String> AddJourneysToCampaign;
        public AuditCampaignDetailsSettings AuditCampaignDetails;
    }
    /************************************************************************************************************************************
        Author              :   Anant Kumar
        Description         :   This is a wrapper class is used to store opportunity stages and campaign types.
        Created Date        :   23 February 2016
    **************************************************************************************************************************************/
    public class AuditCampaignDetailsSettings{
        public List<String> OpportunityStages;
        public List<String> CampaignTypes;
    }
    /************************************************************************************************************************************
        Author              :   Anant Kumar
        Description         :   This is a wrapper class is used to store splash event type.
        Created Date        :   23 February 2016
    **************************************************************************************************************************************/
    public class SplashSettings {
        public String splasheventtype;
    }
    /************************************************************************************************************************************
        Author              :   Mayuresh Ghodke
        Description         :   When Enterprise opportunity (Enterprise Record Type) stage moves to closed one create the following process automation
                                1. New project created in taskray
                                2. Both account and opportunity should be associated to project
                                3. Project Naming Convention - Account Name +Opportunity Name
                                4. Assign projects based on the following criteria if opportunity team includes any of the
                                   following people Roni, John Lewis, Erik Munck assign ptoject to Mairav and Avi,
                                   if opportunity team includes any of the following people.
        Created Date        :   15 March 2017
        Issue No.           :   ST-916
    **************************************************************************************************************************************/
    /*public static void createTaskRayProject(string triggerOppOldMap,string triggerOppList){
        map<Id,Opportunity> mapTriggerOldMap = (map<Id,Opportunity>)Json.deserialize(triggerOppOldMap,map<Id,Opportunity>.class);
        list<Opportunity> lstTriggerOpp = (List<Opportunity>)Json.deserialize(triggerOppList,List<Opportunity>.class);
        Id EntSolutionId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise Solutions').getRecordTypeId();
        Debug.log('createTaskRayProject ::');
        Set<Id> oppIds = new Set<Id>();
        List<Opportunity> lstOpp = new List<Opportunity>();
        try{
            for(Opportunity opp : lstTriggerOpp){//(List<Opportunity>) Trigger.New
                Opportunity objOldOpp = mapTriggerOldMap.get(opp.ID);//(Opportunity)mapOldItems.get(opp.ID);;
                if(opp.StageName == 'Closed Won' && objOldOpp.StageName != opp.StageName && opp.RecordTypeId == EntSolutionId){
                    oppIds.add(opp.Id);
                    lstOpp.add(opp);
                }
            }
            Debug.log('createTaskRayProject :: lstOpp '+lstOpp);
            Map<Id,Set<Id>> mapOpportunityTeamMember = new Map<Id,Set<Id>>();
            List<OpportunityTeamMember> lstOppTeam = new List<OpportunityTeamMember>();
            If(oppIds.size() > 0)
                lstOppTeam = [Select Id,UserId,OpportunityId From OpportunityTeamMember Where OpportunityId IN : oppIds];
            If(lstOppTeam.size() > 0){
                for(OpportunityTeamMember obj : lstOppTeam){
                    if(mapOpportunityTeamMember.get(obj.OpportunityId) != null){
                        Set<Id> setTeamId = new Set<Id>();
                        setTeamId = mapOpportunityTeamMember.get(obj.OpportunityId);
                        setTeamId.add(obj.UserId);
                        mapOpportunityTeamMember.put(obj.OpportunityId, setTeamId);
                    }
                    else{
                        Set<Id> setTeamId = new Set<Id>();
                        setTeamId.add(obj.UserId);
                        mapOpportunityTeamMember.put(obj.OpportunityId, setTeamId);
                    }
                }
            }
            List<TASKRAY__Project__c> lstProject = new List<TASKRAY__Project__c>();
            TaskRaySetting taskRaySettingVals = new TaskRaySetting();
            Setting__c setting = Settings.get('TaskRayProject');
            Debug.log('setting ::: '+setting);
            if(setting != null){
                taskRaySettingVals = (TaskRaySetting)JSON.deserialize(setting.Data__c, TaskRaySetting.Class);
                for(Opportunity opp : lstTriggerOpp){//(List<Opportunity>) Trigger.New
                    Opportunity objOldOpp = mapTriggerOldMap.get(opp.ID);
                    if(opp.StageName == 'Closed Won' && objOldOpp.StageName != opp.StageName && opp.RecordTypeId == EntSolutionId){
                        TASKRAY__Project__c objTaskRayPro = new TASKRAY__Project__c();
                        objTaskRayPro.Company__c = opp.AccountId;
                        objTaskRayPro.Opportunity__c = opp.Id;
                        if(mapOpportunityTeamMember.get(opp.Id) != null){
                            Boolean flagUser = false;
                            set<Id> setUserIdOppTeam = mapOpportunityTeamMember.get(opp.Id);
                            for(Id objId : setUserIdOppTeam){
                                Id assigneToVal = null;
                                for(OpportunityTeamMemberSet obj : taskRaySettingVals.OpportunityTeamMemberSet){
                                    if(obj.setUserId.contains(objId)){
                                        flagUser = true;
                                        if(assigneToVal == null)
                                            assigneToVal = obj.AssignedTo;
                                        break;
                                    }
                                    if(assigneToVal != null)
                                        break;
                                }
                                Debug.log('createTaskRayProject :: assigneToVal '+assigneToVal);
                                if(flagUser && assigneToVal != null){
                                    objTaskRayPro.OwnerId = assigneToVal;
                                    break;
                                }
                                else
                                    objTaskRayPro.OwnerId = opp.OwnerId;
                            }
                        }
                        else
                            objTaskRayPro.OwnerId = opp.OwnerId;
                        lstProject.add(objTaskRayPro);
                    }
                    Debug.log('createTaskRayProject :: lstProject '+lstProject);
                }
                if(lstProject.size() > 0){
                    insert lstProject;
                }
            }
        } catch(Exception pEx) {
            new ApexDebugLog().createLog(
                new ApexDebugLog.Error('OpportunityTriggerHandler','createTaskRayProject','triggerOppOldMap : '+triggerOppOldMap+' triggerOppList : '+triggerOppList,pEx)
            );
        }
    } */
    /************************************************************************************************************************************
        Author              :   Mayuresh Ghodke
        Description         :   This is a wrapper class used in task ray setting wrapper to store opportunity
                                team memeber field values.
        Created Date        :   23 February 2016
    **************************************************************************************************************************************/
    global class OpportunityTeamMemberSet {
        public Set<Id> setUserId;
        public String AssignedTo;
    }
    /************************************************************************************************************************************
        Author              :   Mayuresh Ghodke
        Description         :   This is a wrapper class used in create task ray project method to
                                make list of set of opportunity team memebers.
        Created Date        :   23 February 2016
    **************************************************************************************************************************************/
    global class TaskRaySetting {
        public List<OpportunityTeamMemberSet> OpportunityTeamMemberSet;
    }
    /************************************************************************************************************************************
        Author              :   Dipak Pawar
        Description         :   This method will update opportunity owner on send paperwork.
        Created Date        :   29 July 2016
    **************************************************************************************************************************************/
    public static void updateOpporunityOwnerOnSendPaperwork(List<Opportunity> lstNewOpportunities, Map<Id, Opportunity> mapNewOpportunities, List<Opportunity> lstOldOpportunities, Map<Id, Opportunity> mapOldOpportunities){
        Debug.log('Trigger.New in updateOpporunityOwnerOnSendPaperwork :: '+lstNewOpportunities);
        Debug.log('Trigger.oldmap in updateOpporunityOwnerOnSendPaperwork :: '+mapOldOpportunities);
        Set<Id> setContactIds = new Set<Id>();
        Set<String> setAllowedEnterpriseProfiles = new Set<String>();
        Id enterpriseSolutionRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise Solutions').getRecordTypeId();
        SendPaperWorkSetting settingData = (SendPaperWorkSetting)JSON.deserialize(Settings.get('SendPaperworkSetting').Data__c, SendPaperWorkSetting.class);
        Debug.Log('settingData'+settingData);
        if(settingData != null && settingData.AllowedEnterpriseProfiles != null){
            for(string strProfile : settingData.AllowedEnterpriseProfiles){
                Debug.Log('strProfile---'+strProfile);
                setAllowedEnterpriseProfiles.add(strProfile.toLowerCase());
            }
        }
        Debug.Log('setAllowedEnterpriseProfiles---'+setAllowedEnterpriseProfiles);
        Set<String> setExcludedOppStages = new Set<String>{'closed won','closed lost'};
            for(Opportunity oppRec : lstNewOpportunities){
                if(Trigger.IsInsert && oppRec.Send_Paperwork_By__c != null){
                    setContactIds.add(oppRec.Send_Paperwork_By__c);
                } else if(Trigger.IsUpdate && oppRec.Send_Paperwork_By__c != null){
                    if(oppRec.Send_Paperwork_By__c != null && oppRec.Send_Paperwork_By__c != mapOldOpportunities.get(oppRec.Id).Send_Paperwork_By__c){
                        setContactIds.add(oppRec.Send_Paperwork_By__c);
                    }
                }
            }
        Debug.log('setContactIds :: '+setContactIds);
        if(!setContactIds.isEmpty()){
            Map<Id,Contact> mapContacts = new Map<Id,Contact>([SELECT Id, Email FROM Contact WHERE Id IN :setContactIds AND Email != '']);
            if(!mapContacts.isEmpty()){
                Settings.fetchUsers();
                Map<String,User> mapEmailToUser = Settings.mapUserByEmail;
                if(mapEmailToUser == null || mapEmailToUser.size() == 0){
                    Set<String> setEmails = new Set<String>();
                    for(Contact conRec : mapContacts.values()){
                        setEmails.add(conRec.Email);
                    }
                    mapEmailToUser = new Map<String,User>();
                    for(User userRec : [SELECT Id, Email, ProfileId, Profile.Name FROM User WHERE Email IN : setEmails]){
                        mapEmailToUser.put(userRec.Email,userRec);
                    }
                }
                if(mapEmailToUser!= null && mapEmailToUser.size()>0){
                    Debug.log('opportunitiesBeforeUpdate :: '+lstNewOpportunities);

                    for(Opportunity oppRec : lstNewOpportunities){
                        if(oppRec.StageName != null && !setExcludedOppStages.contains(oppRec.StageName.toLowerCase())){
                            User contactUser = (mapContacts.get(oppRec.Send_Paperwork_By__c) != null && mapContacts.get(oppRec.Send_Paperwork_By__c).Email != null && mapEmailToUser.get(mapContacts.get(oppRec.Send_Paperwork_By__c).Email) != null)?mapEmailToUser.get(mapContacts.get(oppRec.Send_Paperwork_By__c).Email):null;
                            if(contactUser != null && (enterpriseSolutionRecordTypeId !=oppRec.RecordTypeId ||  (enterpriseSolutionRecordTypeId == oppRec.RecordTypeId && !setAllowedEnterpriseProfiles.contains(contactUser.Profile.Name.toLowerCase())))){
                                Debug.log('contactUser---'+contactUser);
                                Debug.log('contactUser---'+contactUser.Profile.Name);
                                if(Trigger.IsInsert && oppRec.Send_Paperwork_By__c != null ){
                                    oppRec.ownerId = contactUser.Id;
                                }else if(Trigger.IsUpdate && oppRec.Send_Paperwork_By__c != null){
                                    if(mapOldOpportunities.get(oppRec.Id) != null && oppRec.Send_Paperwork_By__c != mapOldOpportunities.get(oppRec.Id).Send_Paperwork_By__c){
                                        Debug.log('In Change sOwner');
                                        oppRec.ownerId = contactUser.Id;
                                    }
                                }
                            }
                        }
                    }
                }
            }
            Debug.log('opportunitiesAfterUpdate :: '+lstNewOpportunities);
        }
        if(trigger.isBefore && trigger.isUpdate){
            AvoidRecurssion.isAfterUpdateOpporunityOwnerOnSendPaperwork = true;
        }
    }

      global class SendPaperWorkSetting {
          global List<OpportunityCreationSetting> OpportunityCreationSetting;
          global List<String> ExcludedProfiles;
          global List<String> ExcludedProductTypes;
          global List<String> AllowedEnterpriseProfiles;
          global String URL;
      }

    global class OpportunityCreationSetting {
        global String RecordType;
        global String CompanySize;
    }
  
    /************************************************************************************************************************************
        Author              :   Dipak Pawar
        Description         :   This method will map opportunity contact role.
        Created Date        :   10 May 2017
        Issue No.           :   ST-1091
    **************************************************************************************************************************************/
    public static void mapOpportunityContactRole(List<Opportunity> lstNewOpportunities, Map<Id, Opportunity> mapNewOpportunities, List<Opportunity> lstOldOpportunities, Map<Id, Opportunity> mapOldOpportunities){
        Debug.log('In mapOpportunityContactRole : ');
        Map<String, List<Opportunity_Role__c>> mapRelatedOpportunityRoles;
        //Map<Id, Opportunity> oppOldMap = new Map<Id, Opportunity>();
        Set<Id> setOpportunityIds = new Set<Id>();
        if(mapOldOpportunities != null){
            for(Opportunity oppRec : lstNewOpportunities) {
                if(mapOldOpportunities.get(oppRec.Id)!=null && mapOldOpportunities.get(oppRec.Id).Primary_Member__c!=null && mapOldOpportunities.get(oppRec.Id).Primary_Member__c!=oppRec.Primary_Member__c){
                    setOpportunityIds.add(oppRec.Id);
                }
            }
            if(setOpportunityIds.size()>0){
                mapRelatedOpportunityRoles = new Map<String, List<Opportunity_Role__c>>();
                for(Opportunity_Role__c oppRole : [SELECT Id, Opportunity__c, Contact__c, Is_Primary_Member__c, Role__c FROM Opportunity_Role__c WHERE Opportunity__c IN :setOpportunityIds]){
                    if(mapRelatedOpportunityRoles.containsKey(oppRole.Opportunity__c)){
                        List<Opportunity_Role__c> lstOppRoles = mapRelatedOpportunityRoles.get(oppRole.Opportunity__c);
                        lstOppRoles.add(oppRole);
                        mapRelatedOpportunityRoles.put(oppRole.Opportunity__c, lstOppRoles);
                    }else{
                        List<Opportunity_Role__c> lstOppRoles = new List<Opportunity_Role__c>();
                        lstOppRoles.add(oppRole);
                        mapRelatedOpportunityRoles.put(oppRole.Opportunity__c, lstOppRoles);
                    }
                }
            }
        }

        Debug.Log('mapRelatedOpportunityRoles :: '+mapRelatedOpportunityRoles);
        // Debug.Log('mapRelatedOpportunityRoles :: '+mapRelatedOpportunityRoles);
        List<Opportunity_Role__c> listOpportunityRolesToSave = new List<Opportunity_Role__c>();
        for(Opportunity oppRec : lstNewOpportunities) {
            if(mapOldOpportunities == null && oppRec.Primary_Member__c != null && oppRec.Do_Not_Create_Opportunity_Role__c == false){
                Opportunity_Role__c oppRoleToInsert = new Opportunity_Role__c();
                oppRoleToInsert.Opportunity__c = oppRec.Id;
                oppRoleToInsert.Contact__c = oppRec.Primary_Member__c;
                oppRoleToInsert.Is_Primary_Member__c = true;
                oppRoleToInsert.Role__c = 'Primary Member';
                listOpportunityRolesToSave.add(oppRoleToInsert);
            } else if(mapOldOpportunities != null && mapRelatedOpportunityRoles!=null && !mapRelatedOpportunityRoles.isEmpty()){
                if(oppRec.Primary_Member__c != null && oppRec.Primary_Member__c != mapOldOpportunities.get(oppRec.Id).Primary_Member__c && mapRelatedOpportunityRoles.get(oppRec.Id) != null){
                    Boolean flag = false;
                    for(Opportunity_Role__c oppRole : mapRelatedOpportunityRoles.get(oppRec.Id)){
                        if(oppRole.Contact__c == oppRec.Primary_Member__c){
                            oppRole.Is_Primary_Member__c = true;
                            flag = true;
                            listOpportunityRolesToSave.add(oppRole);
                        }
                    }
                    if(!flag){
                        Opportunity_Role__c oppRoleToInsert = new Opportunity_Role__c();
                        oppRoleToInsert.Opportunity__c = oppRec.Id;
                        oppRoleToInsert.Contact__c = oppRec.Primary_Member__c;
                        oppRoleToInsert.Is_Primary_Member__c = true;
                        oppRoleToInsert.Role__c = 'Primary Member';
                        listOpportunityRolesToSave.add(oppRoleToInsert);
                    }
                } else if(oppRec.Primary_Member__c != null && oppRec.Primary_Member__c != mapOldOpportunities.get(oppRec.Id).Primary_Member__c && mapRelatedOpportunityRoles.get(oppRec.Id) == null){
                    Opportunity_Role__c oppRoleToInsert = new Opportunity_Role__c();
                    oppRoleToInsert.Opportunity__c = oppRec.Id;
                    oppRoleToInsert.Contact__c = oppRec.Primary_Member__c;
                    oppRoleToInsert.Is_Primary_Member__c = true;
                    oppRoleToInsert.Role__c = 'Primary Member';
                    listOpportunityRolesToSave.add(oppRoleToInsert);
                }
            }
        }
        Debug.Log('listOpportunityRolesToSave :: '+listOpportunityRolesToSave);
        if(listOpportunityRolesToSave.size() > 0){
            upsert listOpportunityRolesToSave;
        }
    }
    /************************************************************************************************************************************
        Author              :   Dipak Pawar
        Description         :   This method will restrict user to change lead source if main contact has tour within the last 60 days.
        Created Date        :   10 May 2017
        Issue No.           :   ST-1091
    **************************************************************************************************************************************/
    public static void restrictUserToChangeLeadSource(List<Opportunity> lstNewOpportunities, Map<Id, Opportunity> mapNewOpportunities, List<Opportunity> lstOldOpportunities, Map<Id, Opportunity> mapOldOpportunities){
        Set<Id> setContactIds=new Set<Id>();
        for(Opportunity oppRec : lstNewOpportunities) {
            if(oppRec.Primary_Member__c !=null && oppRec.LeadSource != null && mapOldOpportunities.get(oppRec.Id).LeadSource != oppRec.LeadSource && oppRec.LeadSource =='Outbound Email/Cold Call'){
                setContactIds.add(oppRec.Primary_Member__c);
            }
        }
        if(setContactIds.size()>0){
            //Debug.log('contactId==>'+setContactIds);
            Set<Id> setPrimaryContacts=new Set<Id>();
            for(Tour_Outcome__c tour : [SELECT Primary_Member__c From Tour_Outcome__c WHERE Primary_Member__c IN:setContactIds AND CreatedDate = LAST_N_DAYS:60]){
                setPrimaryContacts.add(tour.Primary_Member__c);
            }
            Set<string> setofUserRoleNames = (Set<String>)JSON.deserialize(Settings.get('restrictUserRoleToChangeLeadSource').Data__c,Set<String>.class);
            Debug.log('setofUserRoleNames==>'+setofUserRoleNames);
            User currentUser;
            if(Settings.mapUserById != null && Settings.mapUserById.size()>0){
                currentUser = Settings.mapUserById.get(userinfo.getUserID());
            }else{
                currentUser=[SELECT Id, UserRole.Name From User where Id=:userinfo.getUserID()];
            }
            Debug.log('currentUserRoleName==>'+currentUser.UserRole.Name);
            for(Opportunity opp : lstNewOpportunities){
                if(setofUserRoleNames != null && setofUserRoleNames.contains(currentUser.UserRole.Name) && setPrimaryContacts != null && setPrimaryContacts.contains(opp.Primary_Member__c)){
                    opp.addError('You cannot change the lead source to outbound because the main contact was given a tour within the last 60 days');
                }
            }
        }
    }
    
    
    /************************************************************************************************************************************
            Author              :   Dipak Pawar
            Description         :   This method will store the existing Opportunty Team Members in "mapOppRelatedMemberIds" and will be used in
                                    changeSalesRepOnOwnerChange method.
            Issue No            :   ST-2439
            Created Date        :   1st June 2018

   			Last Modified		:	10 Jan 2019
			Last Modified By 	:	Pragalbha Mahajan
    **************************************************************************************************************************************/ 
    public static void storeOpportunityMembers(List<Opportunity> lstNewOpportunities, Map<Id, Opportunity> mapNewItems, List<Opportunity> listOldItems, Map<Id, Opportunity> mapOldOpportunities) {
        mapOppRelatedTeamMembers = new Map<Id, List<OpportunityTeamMember>>();
        if(lstNewOpportunities.size() > 0) {
            for(Opportunity objOpportunity : [SELECT Id, (SELECT Id, OpportunityId, UserId, TeamMemberRole, OpportunityAccessLevel FROM OpportunityTeamMembers) FROM Opportunity WHERE Id IN :lstNewOpportunities]) {
                boolean IsOpportunityTeamMembers = false;
                for(OpportunityTeamMember obj : objOpportunity.OpportunityTeamMembers){
                    IsOpportunityTeamMembers = true;
                    break;
                }
                if(IsOpportunityTeamMembers) { 
                    List<OpportunityTeamMember> lstTempOpp = new List<OpportunityTeamMember>();
                    for(OpportunityTeamMember oppTeamMember : objOpportunity.OpportunityTeamMembers) {
                        lstTempOpp.add(new OpportunityTeamMember(OpportunityId = oppTeamMember.OpportunityId, TeamMemberRole = oppTeamMember.TeamMemberRole, UserId = oppTeamMember.UserId, OpportunityAccessLevel = oppTeamMember.OpportunityAccessLevel));
                    }
                    mapOppRelatedTeamMembers.put(objOpportunity.Id, lstTempOpp); 
                }               
            }  
        }
    }

    /************************************************************************************************************************************
        Author              :   Ajaysinh Chauhan
        Description         :   This method will update RecordType and Owner of the Opportunity same as Account.
        Created Date        :   23 June 2018
    **************************************************************************************************************************************/
    public static void inheritOrganizationRecordTypeAndOwner(List<Opportunity> listNewItems,Map<Id, Opportunity> mapNewItems){
        Map<Id,Schema.RecordTypeInfo> mapAccountRecordType =  Schema.SObjectType.Account.getRecordTypeInfosById();
        Map<String,Schema.RecordTypeInfo> mapOpportunityRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName();
        Id oppMidmarketRecordtypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Mid_Market').getRecordTypeId();
        Setting__c openOpportunityStages = Settings.get('OpenOpportunityStages');
        Set<String> setOppStageNotToBypass;
        if(openOpportunityStages == null || openOpportunityStages.Data__c == null){
            setOppStageNotToBypass = new Set<String>{'qualifying','selling','negotiating'};
                }else{
                    setOppStageNotToBypass = (Set<String>) JSON.deserialize(openOpportunityStages.Data__c.toLowerCase(), Set<String>.Class);       
                }
        for(Opportunity objOpportunity:listNewItems){
            Boolean isValid = setOppStageNotToBypass.contains(objOpportunity.StageName.toLowerCase());
            if(isValid || objOpportunity.Is_From_Add_Opportunity__c){
                if(String.isNotBlank(objOpportunity.Account_Record_Type__c) && mapOpportunityRecordType.containsKey(mapAccountRecordType.get(objOpportunity.Account_Record_Type__c).getName())){
                    objOpportunity.RecordTypeId = mapOpportunityRecordType.get(mapAccountRecordType.get(objOpportunity.Account_Record_Type__c).getName()).getRecordTypeId();
                }
            }
            if(isValid){
                if(Trigger.isInsert && String.isNotBlank(objOpportunity.Account_Owner__c) && Settings.getUserActive(objOpportunity.Account_Owner__c)){
                    if(!(objOpportunity.Owner_Auto_Assign__c == false && String.valueOf(objOpportunity.RecordTypeId) == oppMidmarketRecordtypeId)){
                        objOpportunity.OwnerId = objOpportunity.Account_Owner__c;
                    }               
                }
            }
        }
    }
    
    /************************************************************************************************************************************
        Author              :   Ajaysinh Chauhan
        Description         :   This method will update RecordType and Owner of the Opportunity same as Account.
        Created Date        :   23 June 2018    
    **************************************************************************************************************************************/    
    public static void changeBillAccountConventionalName(List<Opportunity> lstNewOpportunities, Map<Id, Opportunity> mapNewOpportunities, List<Opportunity> lstOldOpportunities, Map<Id, Opportunity> mapOldOpportunities) {
        Debug.log('changeBillAccountConventionalName===>'+lstNewOpportunities); 
        Set<Id> setBillAccIds = new Set <Id>();
        map<Id,String> mapRegionName = new map<Id,String>();
        for(Opportunity opp : lstNewOpportunities){
            if(opp.Billing_Account__c != null){
                mapRegionName.put(opp.Billing_Account__c, opp.Region_Name__c);
            }
        }
        Debug.log('mapRegionName===>'+mapRegionName);
        if(mapRegionName!=null && mapRegionName.size() > 0){
         List<Billing_Account__c> lstBillAcc = [Select Id,Conventional_Name__c,Region_Name__c from Billing_Account__c where Id IN:mapRegionName.keySet()];  
            if(lstBillAcc !=null && lstBillAcc.size() > 0){
            List<Billing_Account__c> lstBilltoUpdate = new List<Billing_Account__c>();    
                for(Billing_Account__c billtoupdate : lstBillAcc){
                    if(billtoupdate.Region_Name__c == null){
                        lstBilltoUpdate.add(new Billing_Account__c(Id=billtoupdate.Id,Region_Name__c=mapRegionName.get(billtoupdate.Id)));
                        Debug.log('<==lstBilltoUpdate===>'+lstBilltoUpdate);
                    }
                }
                Debug.log('lstBilltoUpdate====>'+lstBilltoUpdate);
                if(lstBilltoUpdate != null && lstBilltoUpdate.size() > 0){
                    update lstBilltoUpdate;
                }
            }
        }
    }
    
    /************************************************************************************************************************************
        Author              :   Shivprasad Patil
        Description         :   This method will update broker account on opportunity if referrer contact is populated
        Created Date        :   19 July 2018
        Issue No.           :   -
    **************************************************************************************************************************************/ 
    public static void updateBrokerAccount(List<Opportunity> listNewItems, Map<Id, Opportunity> mapNewItems, List<Opportunity> listOldItems, Map<Id, Opportunity> mapOldItems){
        Set<Id> setOfContactId = new Set<Id>();
        List<Opportunity> listOpportunities = new List<Opportunity>();
        for(Opportunity objOpportunity : listNewItems){
           if((mapOldItems==null && String.isNotBlank(objOpportunity.Referrer__c) ) || (mapOldItems!=null && objOpportunity.Referrer__c != mapOldItems.get(objOpportunity.Id).Referrer__c)){
                setOfContactId.add(objOpportunity.Referrer__c);
                listOpportunities.add(objOpportunity);
            }
        }         
        Debug.log('setOfContactId=='+setOfContactId);
        if(setOfContactId.size() > 0){
            Map<Id,Contact> mapOfContacts = new  Map<Id,Contact>([SELECT Id, AccountId FROM Contact WHERE Id IN :setOfContactId]);
            for(Opportunity objOpportunity : listOpportunities){
                objOpportunity.Referrer_Account__c = (String.isNotEmpty(objOpportunity.Referrer__c)) ? mapOfContacts.get(objOpportunity.Referrer__c).AccountId : null;
                Debug.log('objOpportunity=='+objOpportunity);
            }
            Debug.log('listOpportunities=='+listOpportunities);
        }
     }
    
    /************************************************************************************************************************************
        Author              :   Jitesh Adwani.
        Description         :   This method Notifiy the Opportunity Team Member if Opportunity is Closed Won or Closed Lost.
        Created Date        :   04 Sept 2018.
        Issue No.           :   ST-2741
    **************************************************************************************************************************************/    
    public static void notifyTeamMemberWhenOppGetsCwOrCl(List<Opportunity> lstNewOpportunities,Map<Id,Opportunity> mapNewOpportunities,List<Opportunity> lstOldOpportunities, Map<Id,Opportunity>  mapOldOpportunities){
        Set<Id> setOpportunityId = new Set<Id>();
        Set<String> setEmaidId;
        if(handleRecursiveFlagForNotifyTeamMemberCwOrCl){
            handleRecursiveFlagForNotifyTeamMemberCwOrCl = false;
            for(Opportunity objOpportunity : lstNewOpportunities){
                if(objOpportunity.StageName != mapOldOpportunities.get(objOpportunity.Id).get('StageName') && (objOpportunity.StageName == 'Closed Won' || objOpportunity.StageName == 'Closed Lost')){
                    setOpportunityId.add(objOpportunity.Id);
                }   
            }  
        }
        
        if(setOpportunityId != null && setOpportunityId.size() > 0){
            Setting__c notifyOppTeamMemberRoles = Settings.get('NotifyOppTeamMemberRoles'); 
            Map<String, Set<String>> mapOppTeamMemberRoles = new Map<String, Set<String>>();
            Map<Id,List<OpportunityTeamMember>> mapOppWithTeamMember = new Map<Id,List<OpportunityTeamMember>>();
            if(notifyOppTeamMemberRoles != null){
                mapOppTeamMemberRoles = (Map<String, Set<String>>)JSON.deserialize(notifyOppTeamMemberRoles.Data__c.toLowerCase(), Map<String, Set<String>>.class);
                Set<String> setOppTeamMemberRolesToNotify = mapOppTeamMemberRoles.get('opportunityteammemberroles') != null ? mapOppTeamMemberRoles.get('opportunityteammemberroles') : null;
                if(setOppTeamMemberRolesToNotify != null && setOppTeamMemberRolesToNotify.size() > 0){
                   Map<Id,Opportunity> mapOpportunities = new Map<Id,Opportunity>([SELECT Id, (SELECT Id, Name, User.Email, TeamMemberRole FROM OpportunityTeamMembers) FROM Opportunity WHERE Id IN:setOpportunityId]);
                    for(Opportunity objOpportunity : mapOpportunities.values()){
                        for(OpportunityTeamMember objTeamMember : objOpportunity.OpportunityTeamMembers){
                            if(String.isNotBlank(objTeamMember.TeamMemberRole) && setOppTeamMemberRolesToNotify.contains(objTeamMember.TeamMemberRole.toLowerCase())){
                                if(mapOppWithTeamMember.containsKey(objOpportunity.Id)){
                                    List<OpportunityTeamMember> lstTempOppTeamMember = mapOppWithTeamMember.get(objOpportunity.Id);
                                    lstTempOppTeamMember.add(objTeamMember);
                                    mapOppWithTeamMember.put(objOpportunity.Id,lstTempOppTeamMember);
                                }else{
                                    mapOppWithTeamMember.put(objOpportunity.Id,new List<OpportunityTeamMember>{objTeamMember});  
                                }
                            }
                        }
                    } 
                    if(mapOppWithTeamMember != null && mapOppWithTeamMember.size() > 0){
                        EmailTemplate emailTemplateId;
                        List<Messaging.SingleEmailMessage> lstEmailsToSend = new List<Messaging.SingleEmailMessage>();
                        if(emailTemplateId == null){
                            emailTemplateId = [SELECT Id, Name, DeveloperName FROM EmailTemplate WHERE DeveloperName = 'Email_to_Opportunity_Team_Member'];   
                        }
                        Messaging.SingleEmailMessage objSingleMail;  
                        for(Id oppId : mapOppWithTeamMember.keySet()){
                            for(OpportunityTeamMember objTeamMember : mapOppWithTeamMember.get(oppId)){
                                objSingleMail = new Messaging.SingleEmailMessage();
                                objSingleMail.setTemplateID(emailTemplateId.Id); 
                                objSingleMail.setTargetObjectId(objTeamMember.UserId);
                                objSingleMail.setWhatId(objTeamMember.Id);
                                objSingleMail.setSaveAsActivity(false);
                                objSingleMail.toaddresses = new List<String>{objTeamMember.User.Email};
                                lstEmailsToSend.add(objSingleMail); 
                            }
                        }
                        if(lstEmailsToSend != null && lstEmailsToSend.size() > 0){
                            Messaging.sendEmail(lstEmailsToSend);   
                        }                      
                    }
                }                
            }
        }
    }
    
    /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method will reparent opportunity from one Org or Sales account to another Org or Sales account.
        Created Date        :   06 July 2018    
    **************************************************************************************************************************************/    
    public static void reparentOpportunity(List<Opportunity> listNewItems, Map<Id, SObject> mapNewItems, List<Opportunity> listOldItems, Map<Id, SObject> mapOldItems){
        Set<Id> setOppIds = new Set<Id>();
        Set<Id> setAccountIds = new Set<Id>();
        Set<Id> setPrimaryMembers = new Set<Id>();
        for(Opportunity opp : listNewItems){
            if(String.isNotBlank(Opp.Primary_Member__c)){
                setPrimaryMembers.add(Opp.Primary_Member__c);
            }           
            if(String.isNotBlank(opp.AccountId) && mapOldItems.get(opp.Id).get('AccountId') != null  && opp.AccountId != mapOldItems.get(opp.Id).get('AccountId')){
                setOppIds.add(opp.Id);
                setAccountIds.add(String.valueOf(mapOldItems.get(opp.Id).get('AccountId')));
            }
        }
        Debug.log('setPrimaryMembers==>'+setPrimaryMembers);
        Debug.log('setAccountIds==>'+setAccountIds);
        Debug.log('setOppIds==>'+setOppIds);
        Map<Id,Set<Id>> mapBillingAccounts = new Map<Id,Set<Id>>();        
        User loggedInUser = Settings.getUserById(UserInfo.getUserId());
        Debug.Log('loggedInUser===>'+loggedInUser);
        Setting__c retroactiveSetting = Settings.get('RetroactiveReferralSettings');
        Map<String, Object> mapRetroactiveSetting;
        Set<String> setAllowedUserIds;
        if(String.isNotBlank(retroactiveSetting.data__c)){
            mapRetroactiveSetting = (Map<String, Object>)JSON.deserializeUntyped(retroactiveSetting.data__c);
            setAllowedUserIds = (Set<String>) JSON.deserialize(JSON.serialize(mapRetroactiveSetting.get('AllowedUsersId')), Set<String>.class);
        }          
        Setting__c reparentingBypassProfilesSetting = Settings.get('ReparentingBypassProfilesSettings'); 
        Map<String,Map<String,Set<String>>> mapExcludedProfiles;
        if(reparentingBypassProfilesSetting != null){
            mapExcludedProfiles = (Map<String,Map<String,Set<String>>>)JSON.deserialize(reparentingBypassProfilesSetting.Data__c.toLowerCase(),Map<String,Map<String,Set<String>>>.class);   
        }       
        Debug.log('mapExcludedProfiles==>'+mapExcludedProfiles);
        //ST-2676 : as per discussion with vaibhav for RetroactiveReferral we need to by pass opportunity reparenting validations.
        if(!(setAllowedUserIds != null && (setAllowedUserIds.contains(String.valueOf(UserInfo.getUserId()).substring(0,15)) || setAllowedUserIds.contains(String.valueOf(UserInfo.getUserId()))))){
            if(mapExcludedProfiles != null && mapExcludedProfiles.get('opportunityreparenting').get('excludedprofiles') != null && !mapExcludedProfiles.get('opportunityreparenting').get('excludedprofiles').contains(String.valueOf(loggedInUser.Profile.Name).toLowerCase())){
                if(!setOppIds.isEmpty()){
                    if(!setPrimaryMembers.isEmpty() && setPrimaryMembers.size()>0){
                        for(Contact con : [Select Id,Name,Billing_Account__c From Contact Where Id IN : setPrimaryMembers AND Billing_Account__c != null]){
                            if(String.isNotBlank(con.Billing_Account__c)){
                                if(mapBillingAccounts.containsKey(con.Id)){
                                    Set<Id> setTempBillAccounts = mapBillingAccounts.get(con.Id);
                                    setTempBillAccounts.add(con.Billing_Account__c);
                                    mapBillingAccounts.put(con.Id,setTempBillAccounts);
                                }else{
                                    mapBillingAccounts.put(con.Id,new Set<Id>{con.Billing_Account__c}); 
                                }    
                            }               
                        }            
                        for(Billing_Account__c billAcc : [Select Id,Name,Primary_Member__c From Billing_Account__c Where Primary_Member__c IN : setPrimaryMembers]){
                            if(mapBillingAccounts.containsKey(billAcc.Primary_Member__c)){
                                Set<Id> setTempBillAccounts = mapBillingAccounts.get(billAcc.Primary_Member__c);
                                setTempBillAccounts.add(billAcc.Id);
                                mapBillingAccounts.put(billAcc.Primary_Member__c,setTempBillAccounts);
                            }else{
                                mapBillingAccounts.put(billAcc.Primary_Member__c,new Set<Id>{billAcc.Id}); 
                            } 
                        }
                    } 
                    Debug.log('mapBillingAccounts==>'+mapBillingAccounts);
                    Map<Id,Account> mapAccounts;
                    if(setAccountIds != null && setAccountIds.size() > 0 ){
                        mapAccounts = new Map<Id,Account>([Select Id,Name,Parent_Org_Id__c,Account_Type__c From Account Where Id IN : setAccountIds]);  
                    }  
                    Debug.log('mapAccounts==>'+mapAccounts);       
                    List<Opportunity> lstOpportunity = new List<Opportunity>([Select Id,AccountId,Primary_Member__c,Primary_Member__r.Name,Account.Parent_Org_Id__c,Account.Account_Type__c,Billing_Account__c,Billing_Account__r.Primary_Member__c From Opportunity Where Id IN : setOppIds]);
                    Debug.log('lstOpportunity==>'+lstOpportunity);
                    for(Opportunity opp : lstOpportunity){
                        Boolean isInSameHierarchy = false;
                        if(String.isNotBlank(opp.Billing_Account__c)){
                            //within org hierarchy allowed
                            if(String.isBlank(mapAccounts.get(String.valueOf(mapOldItems.get(opp.Id).get('AccountId'))).Parent_Org_Id__c) && String.isNotBlank(opp.Account.Parent_Org_Id__c)){
                                if(mapAccounts.containsKey(String.valueOf(mapOldItems.get(opp.Id).get('AccountId'))) && mapAccounts.get(String.valueOf(mapOldItems.get(opp.Id).get('AccountId'))).Account_Type__c =='Org' && Id.valueOf(opp.Account.Parent_Org_Id__c) != Id.valueOf((String)mapOldItems.get(opp.Id).get('AccountId'))){                           
                                    mapNewItems.get(opp.Id).addError('You cannot reparent the Opportunity outside the Org if Billing Account is present on it.');    
                                }
                                isInSameHierarchy = true; 
                            }else if(String.isBlank(opp.Account.Parent_Org_Id__c) && mapAccounts.containsKey(String.valueOf(mapOldItems.get(opp.Id).get('AccountId'))) && String.isNotBlank(mapAccounts.get(String.valueOf(mapOldItems.get(opp.Id).get('AccountId'))).Parent_Org_Id__c) && ( Id.valueOf(mapAccounts.get(String.valueOf(mapOldItems.get(opp.Id).get('AccountId'))).Parent_Org_Id__c) != opp.AccountId )){                        
                                mapNewItems.get(opp.Id).addError('You cannot reparent the Opportunity outside the Org if Billing Account is present on it.');    
                            }else if(String.isBlank(opp.Account.Parent_Org_Id__c) && mapAccounts.containsKey(String.valueOf(mapOldItems.get(opp.Id).get('AccountId')))  && String.isBlank(mapAccounts.get(String.valueOf(mapOldItems.get(opp.Id).get('AccountId'))).Parent_Org_Id__c)){                        
                                mapNewItems.get(opp.Id).addError('You cannot reparent the Opportunity outside the Org if Billing Account is present on it.');    
                            }else if(mapAccounts.containsKey(String.valueOf(mapOldItems.get(opp.Id).get('AccountId'))) && (String.isNotBlank(mapAccounts.get(String.valueOf(mapOldItems.get(opp.Id).get('AccountId'))).Parent_Org_Id__c) && String.isNotBlank(opp.Account.Parent_Org_Id__c)) && opp.Account.Parent_Org_Id__c != mapAccounts.get(String.valueOf(mapOldItems.get(opp.Id).get('AccountId'))).Parent_Org_Id__c){                        
                                mapNewItems.get(opp.Id).addError('You cannot reparent the Opportunity outside the Org if Billing Account is present on it.');       
                            }else{
                                isInSameHierarchy =true;  
                            } 
                            if(!isInSameHierarchy){
                                mapNewItems.get(opp.Id).addError('You cannot reparent the Opportunity outside the Org if Billing Account is present on it.');          
                            }                  
                        }else if(String.isNotBlank(opp.Primary_Member__c) && mapBillingAccounts != null && mapBillingAccounts.containsKey(opp.Primary_Member__c)){                  
                            if(String.isBlank(mapAccounts.get(String.valueOf(mapOldItems.get(opp.Id).get('AccountId'))).Parent_Org_Id__c) && String.isNotBlank(opp.Account.Parent_Org_Id__c)){
                                if(mapAccounts.containsKey(String.valueOf(mapOldItems.get(opp.Id).get('AccountId'))) && mapAccounts.get(String.valueOf(mapOldItems.get(opp.Id).get('AccountId'))).Account_Type__c =='Org' && Id.valueOf(opp.Account.Parent_Org_Id__c) != Id.valueOf((String)mapOldItems.get(opp.Id).get('AccountId'))){
                                    mapNewItems.get(opp.Id).addError('You cannot reparent the opportunity outside of Org hierarchy as '+opp.Primary_Member__r.Name+' is a primary member OR Member of '+mapBillingAccounts.get(opp.Primary_Member__c));    
                                }
                            }else if(String.isBlank(opp.Account.Parent_Org_Id__c) && mapAccounts.containsKey(String.valueOf(mapOldItems.get(opp.Id).get('AccountId'))) && String.isNotBlank(mapAccounts.get(String.valueOf(mapOldItems.get(opp.Id).get('AccountId'))).Parent_Org_Id__c) && ( Id.valueOf(mapAccounts.get(String.valueOf(mapOldItems.get(opp.Id).get('AccountId'))).Parent_Org_Id__c) != opp.AccountId )){
                                mapNewItems.get(opp.Id).addError('You cannot reparent the opportunity outside of Org hierarchy as '+opp.Primary_Member__r.Name+' is a primary member OR Member of '+mapBillingAccounts.get(opp.Primary_Member__c));    
                            }else if(String.isBlank(opp.Account.Parent_Org_Id__c) && mapAccounts.containsKey(String.valueOf(mapOldItems.get(opp.Id).get('AccountId')))  && String.isBlank(mapAccounts.get(String.valueOf(mapOldItems.get(opp.Id).get('AccountId'))).Parent_Org_Id__c)){
                                mapNewItems.get(opp.Id).addError('You cannot reparent the opportunity outside of Org hierarchy as '+opp.Primary_Member__r.Name+' is a primary member OR Member of '+mapBillingAccounts.get(opp.Primary_Member__c));    
                            }else if(mapAccounts.containsKey(String.valueOf(mapOldItems.get(opp.Id).get('AccountId'))) && (String.isNotBlank(mapAccounts.get(String.valueOf(mapOldItems.get(opp.Id).get('AccountId'))).Parent_Org_Id__c) && String.isNotBlank(opp.Account.Parent_Org_Id__c)) && opp.Account.Parent_Org_Id__c != mapAccounts.get(String.valueOf(mapOldItems.get(opp.Id).get('AccountId'))).Parent_Org_Id__c){
                                mapNewItems.get(opp.Id).addError('You cannot reparent the opportunity outside of Org hierarchy as '+opp.Primary_Member__r.Name+' is a primary member OR Member of '+mapBillingAccounts.get(opp.Primary_Member__c));    
                            }
                        }                 
                    }            
                }   
            }   
        }
    }

   /************************************************************************************************************************************
        Author              :   Sunil Bhosale
        Description         :   This method used to set Broker Involved to true.
        Created Date        :   30 Aug 2018    
        Issue No            :   ST-2740
    **************************************************************************************************************************************/    
    public static void setBrokerInvolved(List<Opportunity> lstNewOpportunities, Map<Id, Opportunity> mapNewOpportunities, List<Opportunity> lstOldOpportunities, Map<Id, Opportunity> mapOldOpportunities){
        for(Opportunity opportunity : lstNewOpportunities){
            if(String.isNotBlank(opportunity.LeadSource) && opportunity.LeadSource.equalsIgnoreCase('Broker Referral') && String.isNotBlank(opportunity.Referrer__c) && (mapOldOpportunities == null || (opportunity.LeadSource != mapOldOpportunities.get(opportunity.Id).LeadSource || opportunity.Referrer__c != mapOldOpportunities.get(opportunity.Id).Referrer__c))){
                opportunity.Broker_Involvement_Indicated__c = 'Yes';
            }
        }
    }
   /************************************************************************************************************************************
        Author              : Dipak Pawar
        Description         : This wrapper class is used to store API user Details.
        Created Date        : 04 Sept 2018
    **************************************************************************************************************************************/    
    class APIUserContactInfo {
        String UserId{get;set;}
        String Email{get;set;}
        String Name{get;set;}
        String contactId{get;set;}
        String contactUUID{get;set;}
    }
    
    /*****************************************************************************************************************************************
        Author              :   Pragalbha Mahajan
        Description         :   This method sends email to current and previous owners of opportunity when opportunity owner will be changed.
        Created Date        :   01 October 2018
        Issue No            :   ST-2795
    ******************************************************************************************************************************************/
    public static void sendEmailOnOwnerChange(List<Opportunity> listNewItems, Map<Id, Opportunity> mapNewItems, List<Opportunity> listOldItems, Map<Id, Opportunity> mapOldItems){
        Id EntSolutionId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise Solutions').getRecordTypeId();
        Set<Id> setOpportunityIds = new Set<Id>();
        Set<Id> setNonEntOpportunities = new Set<Id>();
        Set<Id> setEntOpportunities = new Set<Id>();
        for(Opportunity objOpp: listNewItems){
            if(((objOpp.OwnerId != mapOldItems.get(objOpp.Id).OwnerId) || (AccountTriggerHandler.mapOpportunityWithOwner.size() > 0 && AccountTriggerHandler.mapOpportunityWithOwner.containsKey(objOpp.Id) && objOpp.OwnerId != AccountTriggerHandler.mapOpportunityWithOwner.get(objOpp.Id).OwnerId))){
                if((String.valueOf(objOpp.RecordTypeId).equalsIgnoreCase(EntSolutionId) && hasOnceEmailSentForNotifyEmailOwnership)){
                    setEntOpportunities.add(objOpp.Id);
                }else if(!String.valueOf(objOpp.RecordTypeId).equalsIgnoreCase(EntSolutionId) && handleRecursiveForNotifyEmailOwnership){
                    setNonEntOpportunities.add(objOpp.Id);
                }
            }
        }
        if(setNonEntOpportunities.size() > 0){
            handleRecursiveForNotifyEmailOwnership = false;
            setOpportunityIds.addAll(setNonEntOpportunities);
        }
        if(setEntOpportunities.size() > 0){
            hasOnceEmailSentForNotifyEmailOwnership = false;
            setOpportunityIds.addAll(setEntOpportunities);
        }
        if(setOpportunityIds.size() > 0){
            AccountTriggerHandler.handleSendEmailOnOwnershipChange(setOpportunityIds, 'Email_on_Opportunity_Owner_Change', mapNewItems, mapOldItems);
        }
    }
    
/************************************************************************************************************************************
   	Author              : Rohit Nimase
    Description         : This method is used to validate user to modify opportunity's forecast category.
    Created Date        : 12 Oct 2018
	Issue No.			: ST-2750
**************************************************************************************************************************************/    
    public static Boolean validateUserToModifyForecast(){
        User currentUser = Settings.getUserById(UserInfo.getUserId());
        if(currentUser != null && String.isNotBlank(currentUser.Sales_Role__c) && currentUser.Sales_Role__c.toLowerCase() == 'director of sales'){
            return true;
        }else{
            return false;
        }
    }

/************************************************************************************************************************************
  	Author              : Rohit Nimase
    Description         : This method contains business logic to update opportunity's forecast category.
    Created Date        : 12 Oct 2018
	Issue No.			: ST-2750
**************************************************************************************************************************************/    
    public static void updateOppForecastCategory(List<Opportunity> listNewItems, Map<Id, Opportunity> mapOldItems){
        Boolean isValidUser = validateUserToModifyForecast();
        Id enterpriseRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Enterprise_Solutions').getRecordTypeId();
        Boolean standardForecastChanged;
        Boolean customForecastChanged;
        for(Opportunity oppRec : listNewItems){
            customForecastChanged = (oppRec.Forecast_Category__c != null && mapOldItems == null) || (mapOldItems != null && mapOldItems.get(oppRec.Id).Forecast_Category__c != oppRec.Forecast_Category__c);
            standardForecastChanged = (oppRec.ForecastCategoryName != null && mapOldItems == null) || (mapOldItems != null && mapOldItems.get(oppRec.Id).ForecastCategoryName != oppRec.ForecastCategoryName);
            if(mapOldItems == null){
                mapForecastCategory(customForecastChanged, standardForecastChanged, oppRec); 
            }else{
                if(customForecastChanged || standardForecastChanged){
                    if(oppRec.OwnerId == UserInfo.getUserID()){
                        mapForecastCategory(customForecastChanged, standardForecastChanged, oppRec);
                    }else if(oppRec.RecordTypeId == enterpriseRecordTypeId && isValidUser){
                        mapForecastCategory(customForecastChanged, standardForecastChanged, oppRec);
                    }else if(mapOldItems.get(oppRec.Id).StageName != oppRec.StageName){
                        mapForecastCategory(false, true, oppRec); 
                    }else{
                        oppRec.addError('Opportunity Owner can modify custom Forecast Category field for any record type and Director of Sales can modify this field for Enterprise Solutions Opportunity.'); 
                    }
                }
            }
        }
    }
    
/************************************************************************************************************************************
  	Author              : Milanjeet Singh
    Description         : This method is a helper method to map forecast category depending on
						  custom forecast and standard forecast field
    Created Date        : 18 Oct 2018
	Issue No.			: ST-2750
**************************************************************************************************************************************/        
    public static void mapForecastCategory(boolean customForecastChanged, boolean standardForecastChanged, Opportunity objOpportunity){
        if((customForecastChanged && standardForecastChanged) || customForecastChanged){
            objOpportunity.ForecastCategoryName = objOpportunity.Forecast_Category__c;
        }else if(standardForecastChanged){
            objOpportunity.Forecast_Category__c = objOpportunity.ForecastCategoryName;
        }
    }
    /*****************************************************************************************************************************************
        Author              :   Nikhil Mehta
        Description         :   This method is used to Send Emails to Referral change method
        Created Date        :   10 October 2018
        Issue No            :   ST-2824
	******************************************************************************************************************************************/
    public static void notifyEmailAlertToReferralTeam(List<Opportunity> lstNewOpportunities, Map<Id, Opportunity> mapNewOpportunities, List<Opportunity> lstOldOpportunities, Map<Id, Opportunity>  mapOldOpportunities){
        Set<Id> setOpportunityId = new Set<Id>();
        map<Id, String> mapUserData = new map<Id, String>();
        Map<Id, String> mapOppId = new Map<Id, String>();
        List<EmailTemplate> lstEmailTemplates = new List<EmailTemplate>();
        if(handleRecursiveFlagForNotifyEmailAlertToReferralTeam){
            Opportunity oldOpportunity;
            for(Opportunity objOpportunity : lstNewOpportunities){
                if(mapOldOpportunities != null){
                    oldOpportunity = mapOldOpportunities.get(objOpportunity.Id);
                }
                if(objOpportunity.Referrer__c != null && objOpportunity.Opportunity_Referral_Type__c != null){
                    setOpportunityId.add(objOpportunity.Id);
                    if(objOpportunity.Referral_Status__c == 'Pending' && objOpportunity.StageName != oldOpportunity.StageName && objOpportunity.StageName == 'Closed Won'){
                        mapOppId.put(objOpportunity.Id, Settings.getEmailTemplateByDeveloperName('Ref_notification_for_pending_approval').Id);
                    }else if((objOpportunity.Referrer__c != oldOpportunity.Referrer__c || objOpportunity.Opportunity_Referral_Type__c != oldOpportunity.Opportunity_Referral_Type__c) && objOpportunity.Referral_Status__c == 'Pending'){
                        mapOppId.put(objOpportunity.Id, Settings.getEmailTemplateByDeveloperName('Referral_Status_Information').Id);
                    }else if(objOpportunity.Opportunity_Referral_Type__c == 'Confidential Referral' && objOpportunity.Referral_Status__c == 'Pending' && objOpportunity.StageName != oldOpportunity.StageName && objOpportunity.StageName == 'Closing'){
                        mapOppId.put(objOpportunity.Id, Settings.getEmailTemplateByDeveloperName('Referral_New_Demo').Id);
                    }
                }
            }
        }
        if(!setOpportunityId.isEmpty()){
            handleRecursiveFlagForNotifyEmailAlertToReferralTeam = false;
            Setting__c retroactiveSetting = Settings.get('RetroactiveReferralSettings');
            Map<String, Object> mapRetroactiveSetting;
            Set<String> queueName; 
            if(String.isNotBlank(retroactiveSetting.data__c)){
                mapRetroactiveSetting = (Map<String, Object>)JSON.deserializeUntyped(retroactiveSetting.data__c);
                queueName = (Set<String>) JSON.deserialize(JSON.serialize(mapRetroactiveSetting.get('referralTeamQueueDevloperNames')), Set<String>.class);
            } 
            Map<Id, User> mapQueueMember = new Map<Id, User>([SELECT Id, Email FROM User WHERE Id IN (SELECT UserOrGroupId FROM GroupMember WHERE Group.DeveloperName IN : queueName)]);          
            if(!mapQueueMember.isEmpty()){
                for(String userId : mapQueueMember.keySet()){
                    User userData = Settings.getUserById(Id.valueOf(userId));
                    if(userData != null){
                        mapUserData.put(userData.Id, userData.Email);  
                    }
                }
                List<Messaging.SingleEmailMessage> lstEmailsToSend = new List<Messaging.SingleEmailMessage>();
                if(!mapUserData.isEmpty()){                    
                    for(Id oppId : setOpportunityId){
                        Opportunity oppRec = mapNewOpportunities.get(oppId);
                        Messaging.SingleEmailMessage objSingleMail; 
                        if(!mapOppId.isEmpty() && mapOppId.containsKey(oppId)){
                            for(Id userId : mapUserData.keySet()){
                                objSingleMail = new Messaging.SingleEmailMessage();
                                objSingleMail.setTemplateId(mapOppId.get(oppId)); 
                                objSingleMail.setTargetObjectId(userId); 
                                objSingleMail.setWhatId(oppId);
                                objSingleMail.setSaveAsActivity(false);
                                objSingleMail.toaddresses = new List<String>{mapUserData.get(userId)};
                                    lstEmailsToSend.add(objSingleMail); 
                            }  
                        }
                    }
                    if(!lstEmailsToSend.isEmpty()){
                        Messaging.sendEmail(lstEmailsToSend);   
                    }
                }
            }
        }
    }
}