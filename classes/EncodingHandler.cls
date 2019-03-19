public with sharing class EncodingHandler{
    
	public static String encode(String pTarget) {		
		String result;
		try {
			result = EncodingUtil.base64Encode(
				Blob.valueOf(pTarget)
			 );
		}
		catch(Exception pEx) {
			result = null; //default value
		}

		return result;
	}

	public static String decode(String pEncoded) {
		String result;
		try {
			result = EncodingUtil.base64Decode(pEncoded).toString();
		}
		catch(Exception pEx) {
			result = null; //default value
		}

		return result;	
	}



}