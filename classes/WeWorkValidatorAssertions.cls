/************************************************************************************************************************************
    Author 		: 	Ajaysinh Chauhan
    Description : 	

    History:
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE				AUTHOR					DETAIL											Issue No.
    1			08 Feb 2018			Ajaysinh Chauhan		Initial Developement.							-
**************************************************************************************************************************************/
public class WeWorkValidatorAssertions {
    public static void verifyLeadCreation(Map<String,Object> mapData){
        List<Lead> lstLeads = [Select Id,FirstName,LastName,Email,Company From Lead Where Email=:String.valueOf(mapData.get('email'))];
        if(lstLeads.size()>0){
            Lead objLead = lstLeads[0];
            System.assertEquals(String.valueOf(mapData.get('first_name')),objLead.FirstName,'First Name not mapped on lead.');
            System.assertEquals(String.valueOf(mapData.get('last_name')),objLead.LastName,'Last Name not mapped on lead.');
            System.assertEquals(String.valueOf(mapData.get('email')),objLead.Email,'Email not mapped on lead.');
            System.assertEquals(String.valueOf(mapData.get('company_name')),objLead.Company,'Company Name not mapped on lead.');
        }else{
            System.assert(false,'Lead creation failed.');
        }
    }
    public static void verifyLeadConversion(List<Lead> lstLeads){
        if(lstLeads.size()>0){
            System.assertEquals(true, lstLeads[0].IsConverted,'Lead conversion failed');
        }else{
            System.assert(false,'Lead has been deleted.');
        }
    }
    public static void verifyAccountStructure(Lead objLead,Account objAccount,Contact objContact,Opportunity objOpportunity,Building__c objBuilding){
        System.assertEquals(objLead.FirstName,objContact.FirstName,'First Name not mapped on contact.');
        System.assertEquals(objLead.LastName,objContact.LastName,'Last Name not mapped on contact.');
        System.assertEquals(objLead.Email,objContact.Email,'Email not mapped on contact.');
        System.assertEquals(objLead.Company,objAccount.Name,'Company Name not mapped on account.');
        System.assertEquals(objAccount.Id,objContact.AccountId,'Account not mapped on contact.');
        System.assertEquals(objAccount.Id,objOpportunity.AccountId,'Account not mapped on opportunity.');
        System.assertEquals(objContact.Id,objOpportunity.Primary_Member__c,'Primary member not mapped on opportunity.');
        System.assertEquals(objBuilding.Id,objOpportunity.Building__c,'Building not mapped on opportunity.');
    }
    public static void verifyAccountAssignments(Account objAccount,Contact objContact,Opportunity objOpportunity,Building__c objBuilding,String strRecordType,String strDealType){
        System.assertEquals(strRecordType,objAccount.RecordType.Name,'Invalid record type for account.');
        if(strDealType=='Stratergic' || strRecordType=='Enterprize Solutions'){
            Account_Queue__c objQueue = [Select Id,Member__c From Account_Queue__c Where Portfolio__c=:objBuilding.Market__c AND Account_Record_Type__c='Consumer'][0];
            System.assertEquals(objQueue.Member__c,objAccount.OwnerId,'Invalid assignment for Relational Deal Type.');
        }else if(strDealType=='Relational'){
            System.assertEquals(objBuilding.Cluster__r.Sales_Lead__c,objAccount.OwnerId,'Invalid assignment for Relational Deal Type.');
        }else if(strDealType=='Transactional'){
            System.assertEquals('005F0000003KmbwIAC',objAccount.OwnerId,'Invalid assignment for Transactional Deal Type.');
            
        }
    }
    public static void verifyChangeChildsRecordType(Account objAccount,Contact objContact,Opportunity objOpportunity){
        System.assertEquals(objAccount.RecordType.Name,objContact.RecordType.Name,'Contact record type is diffrent from account.');
        System.assertEquals(objAccount.OwnerId,objContact.OwnerId,'Contact owner is diffrent from account.');
        System.assertEquals(objAccount.RecordType.Name,objOpportunity.RecordType.Name,'Opportunity record type is diffrent from account.');
        System.assertEquals(objAccount.OwnerId,objOpportunity.OwnerId,'Opportunity owner is diffrent from account.');
    }
  
    /*---------------------------------------
     * Sr	From		To		Allow Merge
     * --------------------------------------
	 * 1	Org		To	Org		Yes
	 * 2	Sales	To	Sales	No
	 * 3	Bill	To	Bill	No
	 * 4	Blank	To	Bill	Yes
	 * 5	Blank	To	Blank	Yes
	 * --------------------------------------
     */
    public static void verifyUnomyAccountMergePositive(List<Account> lstParentAcc,List<Account> lstChildAccount){
        if(lstParentAcc[0].Account_Type__c =='Org'){
            System.assertEquals(0, lstChildAccount.size(), 'Child Account is Not Merged with the Parent Account' );
        }else if(lstParentAcc[0].Account_Type__c =='Bill'){
            System.assertEquals(0, lstChildAccount.size(), 'Child Account is Not Merged with the Parent Account' );
        }else if(lstParentAcc[0].Account_Type__c ==null){
            System.assertEquals(0, lstChildAccount.size(), 'Child Account is Not Merged with the Parent Account' );
        }
    }
    
    public static void verifyTourOutcome(Tour_Outcome__C tour){
        
    }
}