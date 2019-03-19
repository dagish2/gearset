/**
* Name			:	ContractEventAccountHandler	 
* Issue No.		: 	ST-2520 
* Purpose		:	This is used to handle account logic in contract event.
* History		
	Version			Author				Date			Detail						Feature			IssueNumber
	1.0				Shobhit Gahlot		11/6/2018		Initial Development         
***********************************************************************************************************************************************************
*/ 
public class ContractEventAccountHandler {
    static Billing_Account__c billingAccountToUse;
    public static Billing_Account__c createOrReuseBillingAccount(String billingAccountUUId, String primaryMemberEmail,  Map<String, Map<String,sObject>> mapContactsMembers){
        List<Billing_Account__c> lstBillingAccount = new List<Billing_Account__c>([SELECT Id, Name, UUID__c, Parent_Account__c, Parent_Account__r.Lead_Source__c FROM Billing_Account__c WHERE UUID__c =: billingAccountUUId]);
        
        if(lstBillingAccount.size() > 0 ){
            if(lstBillingAccount[0].UUID__c == billingAccountUUId){
                billingAccountToUse = lstBillingAccount[0];
                return lstBillingAccount[0];
            }
        }
        throw new ContractEventAccountHandlerException('Billing account not found with company UUID '+ billingAccountUUId);
    }
    
    //ST-2550: find org account while creating new opportunity
    public static Id getOrgAccountOrCreate(Map<String, Map<String,sObject>> mapContactsMembers, Boolean createOrg){
        sObject objContact;
        Id OrgId;
        if(mapContactsMembers.get('Contact') != null){
            objContact = contactUsedForOrgFinding(mapContactsMembers);
            Debug.log('billingAccountToUse '+billingAccountToUse);
            Debug.log('billingAccountToUse objContact'+objContact);
            if(objContact != null){
                if(createOrg){
                    if(objContact.get('Company__c') == null){
                        String cleansedBillAccName = OrganizationHelper.getCleansedName(billingAccountToUse.Name);
                        if(objContact.get('AccountId') == null && (objContact.get('Cleansed_Company_Name__c') == null || cleansedBillAccName != String.valueOf(objContact.get('Cleansed_Company_Name__c')))){
                            objContact.put('Cleansed_Company_Name__c',cleansedBillAccName);
                        }  
                        objContact.put('Company__c',billingAccountToUse.Name);
                    }
                    Debug.log('getOrgAccountOrCreate after update objContact::'+objContact);
                    OrgId = OrganizationHelper.findOrCreateRelatedOrg(objContact);
                }else{
                    OrgId = OrganizationHelper.findRelatedOrg(objContact); 
                }
            }
        }
        return OrgId;
    }
    
    public static sObject contactUsedForOrgFinding(Map<String, Map<String,sObject>> mapContactsMembers){
        sObject objContact;
        if(mapContactsMembers.get('Contact').get('PrimaryMemberEmailInContact') != null){
            objContact = mapContactsMembers.get('Contact').get('PrimaryMemberEmailInContact');
        }else if(mapContactsMembers.get('Contact').get('PrimaryMemberDomainInContact') != null){
            objContact = mapContactsMembers.get('Contact').get('PrimaryMemberDomainInContact');
        }
        return objContact;
    }
    public class ContractEventAccountHandlerException extends Exception{}
}