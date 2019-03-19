@isTest
private class WWResultTest {
	
	@isTest static void test_1() {
		//pre-context
			WWResult r = null;
			
		//test
		Test.startTest();

			r = new WWResult();
			
			r.setSuccess('Yes!');		
			System.assertEquals(
				true, r.success
			);
			
			r = new WWResult();
			r.setFailure('No!');
			System.assertEquals(
				false, r.success
			);
			
			r	= new WWResult(true, 'THIS IS A RESPONSE');
			System.assertNotEquals(null, r);

		Test.stopTest();
	}

}