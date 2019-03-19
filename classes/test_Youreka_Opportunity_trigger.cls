/* This class was created by the Youreka package and is integral to it. 
Please do not delete */
@istest(SeeAllData=true)
private class test_Youreka_Opportunity_trigger{
    static testMethod void test_Youreka_Opportunity_triggertest(){
        disco.Util.testLinkedObjTrigger('Opportunity');
    }
}