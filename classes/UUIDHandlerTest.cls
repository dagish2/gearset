@isTest
private class UUIDHandlerTest {
	
	/*
	Version 4 (random)[edit]

	Version 4 UUIDs use a scheme relying only on random numbers. This algorithm sets the version number 
	as well as two reserved bits. All other bits (the remaining 122 bits) are set using a random or 
	pseudorandom data source. Version 4 UUIDs have the form xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx 
	where x is any hexadecimal digit and y is one of 8, 9, A, or B (e.g., f47ac10b-58cc-4372-a567-0e02b2c3d479).

	*/

	private static testMethod void test_1() {
		set<string> setTestUUID = new set<string>();
        Integer count = 5000;
		for(Integer num =0; num<count; num++)
		{	
            if(num == count/2){
                Test.startTest();
            }
			String u = UUIDHandler.generateVersion4();
			system.assertNotEquals(null, u);
			system.assertEquals(36, u.length() );
			system.assertEquals('-', u.substring(8,9) );
			system.assertEquals('-', u.substring(13,14) );
			system.assertEquals('4', u.substring(14,15) );
			system.assertEquals('-', u.substring(18,19) );
			system.assertEquals('-', u.substring(23,24) );

			system.assert(u.substring(19,20).containsOnly('89ab'));
			for(Integer i=0; i < u.length()-1; i++) {
				system.assert(
					u.substring(i,i+1).containsOnly('0123456789abcdef-')
				);
			}
				setTestUUID.add(u);
		}
        Test.stopTest();
		system.assertEquals(setTestUUID.size(), 5000);
		
	}

}