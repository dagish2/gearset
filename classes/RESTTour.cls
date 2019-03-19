//@RestResource(urlMapping='/Tour/*')
global class RESTTour {
    /*@HttpPost
    global static Response doPost(WWTypes.InboundLead body) {
        Debug.log('body==>'+body);
        RESTTour.Response response = new RESTTour.Response();
        SavePoint sp = Database.setSavePoint();
        try {
            
            Id so_id = LeadHandler.book_a_tour(body);            
            
            System.debug('Total Number of SOQL Queries Consumed: ' +  Limits.getQueries());
            response.setSuccess(so_id);     
        }
        catch(Exception pEx) {
            response.setFailure(WeworkEngine.exceptionFormatter(pEx));
            Database.rollback(sp);   
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('RESTTour','doPost',JSON.serializePretty(body), pEx)
            );
        }   
        return response;
    } 
    @HttpGet
    global static Response doGet() {
        WWTypes.TourDetail result;
        Response response = new Response();
        try {            
            
            String tour_id = RestContext.request.requestURI.substring(
                RestContext.request.requestURI.lastIndexOf('/') + 1
            );
            
            
            result = TourServices.get_tour_by_id( Id.valueOf(tour_id) );
            
            
            response.setSuccess(result); 
            
        } catch(Exception pEx) {
            response.setFailure(WeworkEngine.exceptionFormatter(pEx));
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('RESTTour','doGet',RestContext.request.requestURI.substring(RestContext.request.requestURI.lastIndexOf('/') + 1 ), pEx)
            );
        }
        return response;
    }
    
    global class Response {
        public Boolean success;
        public String message;
        public String result;
        
        public void setSuccess(Object pResult) {
            this.success = true; 
            this.result = pResult != null ? JSON.serializePretty(pResult) : '';
        }
        
        public void setFailure(String pMessage) {
            this.success = false; 
            this.message = pMessage;
        }
    }*/
}