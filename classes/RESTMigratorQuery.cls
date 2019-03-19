/************************************************************************************************************************************
    Author 		: Ajaysinh Chauhan
	Issue NO	: -
    Description : This REST class is used to insert the Data into SF from DataMigrator class.

    History:
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE				AUTHOR					DETAIL
    1.0			8 Jan 2018			Ajaysinh Chauhan			Initial Developement.
**************************************************************************************************************************************/
@RestResource(urlMapping='/MigratorQuery/*')
global class RESTMigratorQuery {
    @HttpPost
    global static Response doPost(){
        String requestBody = RestContext.request.requestBody.toString();
        debug.log('requestBody---'+requestBody);
        QueryWrapper wrapper = (QueryWrapper)JSON.deserialize(requestBody,QueryWrapper.class);
        debug.log('wrapper---'+wrapper);
        Response response = new Response();
        try{
            Map<String,List<sObject>> mapRecords = new Map<String,List<sObject>>();
            for(String sObjectName:wrapper.mapQuery.keySet()){
                 Debug.log('sObjectName=='+RESTMigratorQuery.waiting());
                 Debug.log('query=='+wrapper.mapQuery.get(sObjectName));
                 	
                mapRecords.put(sObjectName,Database.query(wrapper.mapQuery.get(sObjectName)));
            }    
            //Debug.log('mapRecords=='+mapRecords);
            response.setSuccess(mapRecords);
        }catch(Exception ex){
            response.setFailure('unable to process: ' + ex );
        }
        return response;
    }
    global class QueryWrapper {
        public Map<String,String> mapQuery;
        public List<String> ids;
    }
	global class Response {
        public Boolean success;
        public String message;
        public Map<String,List<sObject>> mapRecords;
        public void setSuccess(Map<String,List<sObject>> mapRecords) {
            this.success = true;
            this.mapRecords = mapRecords;
        }
        public void setFailure(String message) {
            this.success = false; 
            this.message = message;
        }
    }
    global static string waiting(){
        Long startingTime = System.now().getTime(); // Num milliseconds since Jan 1 1970
        Integer delayInMilliseconds = 1000; // One-second delay
        while (System.now().getTime() - startingTime < delayInMilliseconds)  {
            
        }
        return 'Building__c';
    }
}