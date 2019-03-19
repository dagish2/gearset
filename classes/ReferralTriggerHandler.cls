/************************************************************************************************************************************
	Author 		: -
	Description : This class contains unit tests for validating the behavior of Apex classes and triggers.
 	
History:
----------------------------------------------------------------------------------------------------------------------------------
	VERSION			DATE				AUTHOR					DETAIL							ISSUE
	1				-					Amol Darekar			Initial Developement			-
	2				01 February 2018	Krishana Tupe			Added new trigger structure.	-			
**************************************************************************************************************************************/
public class ReferralTriggerHandler extends ITriggerHandler{
    
    /************************************************************************************************************************************
      Author 			: Krishana Tupe
      Description 		: This is ITriggerHandler constructor which will be used in future.
      Created Date		: 01 February 2018          
    **************************************************************************************************************************************/     
    public ReferralTriggerHandler(){
        super('Referral__c');
        
    }
    
   	/************************************************************************************************************************************
      Author 				: Krishana Tupe
      Description 			: This method overrides before insert method from ITriggerHander which will control the execution flow.
      Last Modified Date	: 01 February 2018
      Last Modified By		: Krishana Tupe (added Comment)
	**************************************************************************************************************************************/
    public override void BeforeInsert(List<SObject> listNewItems){
        PreventDuplicateActiveReference(listNewItems);        
    }
    
    /************************************************************************************************************************************
      Author 			: -
      Description 		: PreventDuplicateActiveReference.
      Created Date		: -
      Modified Date 	: 01 February 2018
      Last Modified By	: Krishana Tupe	  
    **************************************************************************************************************************************/ 
    public static void PreventDuplicateActiveReference(List<SObject> listNewItems){
        if(TriggerSettings.mappedField.Referral_PreventDuplicateActiveReference){
            set<string> setReferenceEmails = new set<string>();
            set<string> setExistingReferenceEmails = new set<string>();
            list<Referral__c> lstReferences = listNewItems;
            Boolean errorFlag = false;
            
            for(Referral__c currentReference : lstReferences){
                if(!String.isBlank(currentReference.Referral_Email__c)){
                    setReferenceEmails.add(currentReference.Referral_Email__c.toLowerCase());
                }   
            }
            list<Referral__c> lstExistingReferences = [Select Id, Name, Referral_Email__c , IsActive__c from Referral__c where Referral_Email__c IN : setReferenceEmails and IsActive__c = true];
            for(Referral__c currentReference : lstExistingReferences){
                setExistingReferenceEmails.add(currentReference.Referral_Email__c.toLowerCase());
            }
            for(Referral__c currentReference : lstReferences){
                if(!String.isBlank(currentReference.Referral_Email__c)){
                    setReferenceEmails.add(currentReference.Referral_Email__c.toLowerCase());
                }
            }
            for(Referral__c currentReference : lstReferences){
                if(!String.isBlank(currentReference.Referral_Email__c)){
                    if(setExistingReferenceEmails.contains(currentReference.Referral_Email__c.toLowerCase())){
                        errorFlag = true;
                    }
                }
            }
            if(errorFlag)
                listNewItems[0].addError('Duplicate reference');
        }        
    }
}