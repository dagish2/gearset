public with sharing class WWResult {

	public Boolean success;
	public String response;
	
	/** 
	*	Constructors 
	*/
	public WWResult(){		
	}
	
	public WWResult(Boolean s, String r) {
		this.success 	= s;
		this.response 	= this.sanitize(r);
	}
	
	/** 
	*	Helper methods
	*/
	public void setSuccess(String r) {
		this.success	= true;
		this.response	= this.sanitize(r);
	}
		
	public void setFailure(String r) {
		this.success	= false;
		this.response	= this.sanitize(r);
	}
		
	private String sanitize(String s) {
		return s;
	}
	
	
		
}