public virtual class RESTAPIBase {
    
    public virtual RESTAPIResult executePost(RESTAPI.PayloadDetails payload){
        RESTAPIResult result = new RESTAPIResult();
        result.setFailure('This API is currently not implemented');
        return result;
    }
    
    public virtual RESTAPIResult executeGet(RESTAPI.PayloadDetails payload){
        RESTAPIResult result = new RESTAPIResult();
        result.setFailure('This API is currently not implemented');
        return result;
    }
    
    public virtual void parseInput(RESTAPI.PayloadDetails payload){
        Type typePayload = Type.forName(payload.APIModelsClassName + '.Input');
        RESTAPIBase apiBase = new RESTAPIBase();
        if(String.isNotBlank(payload.Body)){
            payload.Input = JSON.deserialize(payload.Body, typePayload);
        }
    }
}