/*
 * Created By : Anant
 * Date : 20/Dec/2016
 */
@isTest
private class CampMemUpdateBuildingInterestedBatchTest {
    @isTest
    public static void VerifyBatch(){
        //Deprecated batch class
        Test.startTest();
        	CampMemberUpdateBuildingInterestedBatch CMem = new CampMemberUpdateBuildingInterestedBatch();
			Database.executeBatch(CMem, 1); 
        Test.stopTest();
    }
}