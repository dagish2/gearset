public virtual class RESTAPIModel {
    public virtual object getMockModel(RESTAPI.PayloadDetails payload) {
        RESTAPIResult result = new RESTAPIResult();
        result.setFailure('This Mock API is currently not implemented');
        return result;
    }
}