/************************************************************************************************************************************
	Author		: 	Nikhil Mehta
	Description	: 	This class handle Geography insertion using google api.
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE	        	AUTHOR                     DETAIL
	1	    	4 December 2018		Nikhil Mehta            Initial Developement
**************************************************************************************************************************************/
public class GeographyHandler {
	public static GoogleGeolocationAPI googleGeolocationAPIRec;
    
    /************************************************************************************************************************************
        Author              :   Nikhil Mehta
        Description         :   This method get google api setting from sales console setting.
        Created Date  		:   04 December 2018
		Issue No.			:	ST-3200
    **************************************************************************************************************************************/    
    public static void getGoogleGeolocationApi(){
        if(googleGeolocationAPIRec == null){
            Setting__c googleGeolocationAPISetting = Settings.get('Google Geolocation API');
            if(googleGeolocationAPISetting != null && String.isNotBlank(googleGeolocationAPISetting.Data__c)){
                String googleGeolocationAPISettingData = googleGeolocationAPISetting.Data__c.replace('accept-encoding','acceptEncoding');
                googleGeolocationAPIRec = (GoogleGeolocationAPI)System.JSON.deserialize(googleGeolocationAPISettingData, GoogleGeolocationAPI.class);
            }
        }
    }
    
    /************************************************************************************************************************************
        Author              :   Nikhil Mehta
        Description         :   This method returns map id with geographies for addressses.
        Created Date  		:   04 December 2018
		Issue No.			:	ST-3200
    **************************************************************************************************************************************/    
    public static Map<Id, Id> getGeogrphies(Map<Id, Map<String, String>> mapNewGrographyData){
        Map<String, Geography__c> mapGeographies = new Map<String, Geography__c>();
        Map<Id, String> mapParentWithGeoId = new Map<Id, String>();
        
        if(!mapNewGrographyData.isEmpty()){
            List<Geography__c> lstGeographiesToInsert = new List<Geography__c>();
            for(Id recordId : mapNewGrographyData.keySet()){
                if(mapNewGrographyData.get(recordId) != null && !mapNewGrographyData.get(recordId).isEmpty()){
                    Geography__c geographyRec = getGeography(mapNewGrographyData.get(recordId));
                    if(geographyRec != NULL){
                        mapParentWithGeoId.put(recordId, geographyRec.Place_ID__c);
                        mapGeographies.put(geographyRec.Place_ID__c, geographyRec);
                    }
                }
            }
            if(mapGeographies != NULL && !mapGeographies.isEmpty()){
                Database.upsert(mapGeographies.values(), false);
                for(Id recordId : mapNewGrographyData.keySet()){
                    mapParentWithGeoId.put(recordId, mapParentWithGeoId.containsKey(recordId) && mapParentWithGeoId.get(recordId) != NULL ? mapGeographies.containsKey(mapParentWithGeoId.get(recordId)) && mapGeographies.get(mapParentWithGeoId.get(recordId)) != NULL ?  mapGeographies.get(mapParentWithGeoId.get(recordId)).Id : NULL : NULL);
                }
            }
        }
        return mapParentWithGeoId;
    }
    
    /************************************************************************************************************************************
        Author              :   Nikhil Mehta
        Description         :   This method hit google api and insert geography .
        Created Date  		:   04 December 2018
		Issue No.			:	ST-3200
    **************************************************************************************************************************************/    
    public static Geography__c getGeography(Map<String, String> mapAddress){
        getGoogleGeolocationApi();
        if(googleGeolocationAPIRec != null && mapAddress != null){
            String address = mapAddress.get('address');
            String city = mapAddress.get('city');
            String state = mapAddress.get('state');
            String country = mapAddress.get('country');
            String zip = mapAddress.get('zip');
            String endPointUrl = getEndPointURL(address, city, state, country, zip);           
            Debug.Log('endPointUrl---'+endPointUrl);
            HttpRequest httpRequestRec = new HttpRequest();
            httpRequestRec.setEndpoint(endPointUrl);
            httpRequestRec.setMethod('GET');
            httpRequestRec.setHeader('accept', googleGeolocationAPIRec.geolocationAPI.headers.accept);
            httpRequestRec.setHeader('accept-encoding', googleGeolocationAPIRec.geolocationAPI.headers.acceptEncoding);
            Http httpRec = new Http();
            HTTPResponse httpResponseRec = httpRec.send(httpRequestRec);
            Debug.Log('HTTPResponse---'+httpResponseRec.getBody());
            if(String.isNotBlank(httpResponseRec.getBody())){
                GoogleResult googleResultRecord= (GoogleResult)System.JSON.deserialize(httpResponseRec.getBody(), GoogleResult.class);
                Debug.Log('GoogleResult---'+googleResultRecord);
                if(googleResultRecord != null && googleResultRecord.results.size() > 0){
                    Geography__c geographyRec;
                    List<Geography__c> lstGeographies = [SELECT Id, Geocode__Latitude__s, Geocode__Longitude__s, Place_ID__c FROM Geography__c WHERE Place_ID__c =: googleResultRecord.results[0].place_id];
                    if(lstGeographies != null && lstGeographies.size() > 0){
                        geographyRec = lstGeographies[0];
                        return geographyRec;
                    }else{
                        Results googleResultRec = googleResultRecord.results[0];
                        geographyRec = new geography__c(
                            Geocode__Latitude__s = googleResultRec.geometry.location.lat,
                            Geocode__Longitude__s = googleResultRec.geometry.location.lng,
                            Formatted_Address__c = googleResultRec.formatted_address,
                            Place_ID__c = googleResultRec.place_id,
                            JSON__c = System.JSON.serialize(googleResultRec),
                            Location_Type__c = googleResultRec.geometry.location_type
                        );
                        if(String.isNotBlank(googleResultRec.formatted_address)){
                            if(googleResultRec.formatted_address.split(',')[0].length() > 80){
                                geographyRec.Name = googleResultRec.formatted_address.split(',')[0].substring(0, 79);
                                geographyRec.Name = geographyRec.Name.substringBeforeLast(' ');
                            }else{
                                geographyRec.Name = googleResultRec.formatted_address.split(',')[0];
                            } 
                        }
                        for(Address_components addressComponent : googleResultRec.address_components){
                            if(addressComponent.types != NULL && addressComponent.types.size() > 0){
                                if(addressComponent.types[0].equals('country')){
                                    geographyRec.Country__c = addressComponent.long_name;
                                }                                
                                if(addressComponent.types[0].equals('administrative_area_level_1')){
                                    geographyRec.State__c = addressComponent.long_name;
                                    geographyRec.Name += ', ' + geographyRec.State__c;
                                }
                                if(addressComponent.types[0].equals('administrative_area_level_2')){
                                    geographyRec.District__c = addressComponent.long_name;
                                } 
                                if(addressComponent.types[0].equals('locality')){
                                    geographyRec.City__c = addressComponent.long_name;
                                } 
                                if(addressComponent.types[0].equals('postal_code')){
                                    geographyRec.Zip_Postal_Code__c = addressComponent.long_name;
                                }
                            }
                        }
                        Debug.Log('geographyRec---'+geographyRec);
                        return geographyRec;
                    }
                }
            }
        }
        return null;
    }
      
    
    /************************************************************************************************************************************
        Author              :   Nikhil Mehta
        Description         :   This method return end point url using google api setting.
        Created Date  		:   04 December 2018
    **************************************************************************************************************************************/    
    public static String getEndPointURL(String address, String city, String state, String country, String zip){
        getGoogleGeolocationApi();
        string urlAddress = '' + address + ' ' + city + ' ' + state + ' ' + country + ' ' + (String.isNotBlank(zip) ? zip : '') ;       
        urlAddress = EncodingUtil.urlEncode(urlAddress, 'UTF-8').replaceAll('\\+','%20');
        return googleGeolocationAPIRec.geolocationAPI.url + '?address=' + urlAddress + '&key=' + googleGeolocationAPIRec.GeolocationAPI.params.key;
    }
    
    /********************************************************************************************************************
        Author              : Nikhil Mehta
        Description         : This following classes is used convert Google Geolocation API's JSON data to object
        Created Date        : 14 May, 2018
        Last Modified By	: Nikhil Mehta
        Last Modified Date  : 7 December 2018
	**********************************************************************************************************************/
    public class GoogleGeolocationAPI {
        public GeolocationAPI geolocationAPI;
        public GeolocationMap geolocationMap;
    } 
    
    public class GeolocationMap {
        public String url;
        public Headers headers;
    }
    
    public class GeolocationAPI {
        public String url;
        public Params params;
        public Headers headers;
    }
    
    public class Headers {
        public String accept;
        public String acceptEncoding;
    }
    
    public class Params {
        public String address;
        public String key;
    }
    
    /********************************************************************************************************************
        Author              : Nikhil Mehta
        Description         : This following classes is used convert googleAPi response JSON data to object
        Created Date        : 14 May, 2018
    	Last Modified By	: Nikhil Mehta
        Last Modified Date  : 7 December 2018
    **********************************************************************************************************************/
    public class Address_components {
        public String long_name;
        public String short_name;
        public List<String> types;
    }
    public class Geometry {
        public Location location;
        public String location_type;
        public Viewport viewport;
    }
    public class GoogleResult {
        public List<Results> results;
        public String status;
    }
    public class Results {
        public List<Address_components> address_components;
        public String formatted_address;
        public Geometry geometry;
        public String place_id;
        public List<String> types;
    }
    public class Viewport {
        public Location northeast;
        public Location southwest;
    }
    public class Location {
        public Double lat;
        public Double lng;
    }
}