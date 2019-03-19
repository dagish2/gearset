@isTest
public class EncodingHandlerTest{

  /**
	*	TEST METHOD
	**/
	public static testmethod void test_1() {
		String original = 'abc1234';

		String encoded 	= EncodingHandler.encode(original);
		String decoded 	= EncodingHandler.decode(encoded);

		system.assertEquals(original, decoded);
	}

	public static testmethod void test_2() {
		String original = null;

		String encoded 	= EncodingHandler.encode(original);
		String decoded 	= EncodingHandler.decode(encoded);

		system.assertEquals(original, decoded);
	}
    
}