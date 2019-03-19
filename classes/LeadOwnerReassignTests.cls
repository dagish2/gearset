/*
* @ Descrption : Test class for LeadOwnerReassign
* @ Created By : Ajaysinh Chauhan
* @ Created Date : 18 Oct 2016
* @ Issue : ST-689
*/

@isTest
public with sharing class LeadOwnerReassignTests {
    public static void verifyLeadOwnerReassignBatch(){
    	 LeadOwnerReassign c = new LeadOwnerReassign();
      	 Database.executeBatch(c);
    }
}