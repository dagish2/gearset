global class RESTAPIResult {
    public Boolean success;
    public String message;
    public Object result;
    
    public void setSuccess(Object pResult) {
        this.success = true; 
        this.result = pResult;        
    }
	public void setSuccess(String message,Object pResult) {
        this.success = true; 
        this.result = pResult;
		this.message = message;        
    }    
    public void setFailure(String pMessage) {
        this.success = false; 
        this.message = pMessage;
    }
    public void setFailure(String pMessage,Object pResult) {
        this.success = false; 
        this.message = pMessage;
        this.result = pResult;
    }
    public void setFailure(Exception ex) {
        this.success = false; 
        this.message = ex.getMessage();
    }
}