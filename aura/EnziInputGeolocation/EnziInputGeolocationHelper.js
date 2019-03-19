({
	search : function(component) {
        var keyword = component.get("v.keyword");//event.currentTarget.value;
        component.set("v.keyword", keyword);
        if(component.get("v.keyword").length>=4){
            component.find("referenceSpinner").showProcessing();                        
            component.set("v.search", true);
            var settings = component.get("v.settings")["GeolocationAPI"];            
            var keys = [];
            for(var i in Object.entries(settings.params)){
                keys.push(Object.entries(settings.params)[i].join("="));
            }        
            var endPointUrl = settings.url+"?"+keys.join("&");
            var keyAddress = keyword.split(" ").join("%20");
            endPointUrl = endPointUrl.replace("ADDRESS", keyAddress);
            component.find("utils").execute("c.executeRest",{"method":"GET","endPointUrl":endPointUrl,"headers":settings.headers,"body":""},function(response){
                try{
                    var result = JSON.parse(response);
                    if(result.status=="OK"){
                        var searchResultMap = {};
                        var searchResult = [];
                        for(var i in result.results){
                            searchResult.push({"label": result.results[i]["formatted_address"], "value": result.results[i]});
                            searchResultMap[result.results[i]["place_id"]] = result.results[i];
                        }
                        component.set("v.searchResult", searchResult);                                    
                        component.set("v.searchResultMap", searchResultMap);
                        component.find("referenceSpinner").hideProcessing();
                    }
                }catch(err){
                    component.find("referenceSpinner").hideProcessing();
                }
            },function(error){
                component.find("referenceSpinner").hideProcessing();
                component.find("utils").showError(error);
                console.log(error);
            });
        }
    },
    select: function(component, event, helper){
        component.find("referenceSpinner").showProcessing();
        var mapResult = component.get("v.searchResultMap");
        var searchResult = component.get("v.searchResult");
        var index = component.get("v.selectedIndex");
        if(index != undefined && searchResult[index] != undefined){
            component.set("v.keyword", searchResult[index].label);
            var searchResultLength = searchResult[index].value.address_components.length;
            var selectedLocation = searchResult[index].value;
            var googlePlaceRec = {
                "sobjectType": "Geography__c"
            };            
            if(searchResultLength>0){
                googlePlaceRec["Name"] = selectedLocation.formatted_address.split(",")[0];
                googlePlaceRec["Geocode__Latitude__s"] = selectedLocation.geometry.location.lat;
                googlePlaceRec["Geocode__Longitude__s"] = selectedLocation.geometry.location.lng;
                googlePlaceRec["Formatted_Address__c"] = selectedLocation.formatted_address;
                googlePlaceRec["Place_ID__c"] = selectedLocation.place_id;
                googlePlaceRec["JSON__c"] = JSON.stringify(selectedLocation);
                googlePlaceRec["Location_Type__c"] = selectedLocation.geometry.location_type;
                for(var searchResultCount=0; searchResultCount<searchResultLength; searchResultCount++){
                    if(searchResult[index].value.address_components[searchResultCount].types[0]=="country"){
                        googlePlaceRec["Country__c"] = selectedLocation.address_components[searchResultCount].long_name;                        
                    }
                    if(selectedLocation.address_components[searchResultCount].types[0]=="administrative_area_level_1"){
                        googlePlaceRec["State__c"] = selectedLocation.address_components[searchResultCount].long_name;
                        googlePlaceRec["Name"] = googlePlaceRec["Name"]+", "+googlePlaceRec["State__c"];
                    } 
                    if(selectedLocation.address_components[searchResultCount].types[0]=="administrative_area_level_2"){
                        googlePlaceRec["District__c"] = selectedLocation.address_components[searchResultCount].long_name;
                    } 
                    if(selectedLocation.address_components[searchResultCount].types[0]=="locality"){
                        googlePlaceRec["City__c"] = selectedLocation.address_components[searchResultCount].long_name;                        
                    }
                    if(selectedLocation.address_components[searchResultCount].types[0]=="postal_code"){
                        googlePlaceRec["Zip_Postal_Code__c"] = selectedLocation.address_components[searchResultCount].long_name;
                    }  
                }  
            }   
            component.find("referenceSpinner").showProcessing();
            component.find("utils").execute("c.upsertGeolocation",{"objGeography":googlePlaceRec},function(response){
                component.set("v.value",response);
                component.set("v.search",false);
                component.set("v.searchResult", []);
                component.find("referenceSpinner").hideProcessing();
            },function(error){
                component.find("referenceSpinner").hideProcessing();
                component.find("utils").showError(error);
            })
        }
    },
    selectUp : function(component) {
        var index = component.get("v.selectedIndex")==0?0:(component.get("v.selectedIndex")-1);
        component.set("v.selectedIndex",index);
    },
    selectDown : function(component) {
        var index = component.get("v.selectedIndex")==(component.get("v.searchResult").length-1)?(component.get("v.searchResult").length-1):(component.get("v.selectedIndex")+1);
        component.set("v.selectedIndex",index);
    },
    setGeocodeValue:function(component){
        if(component.get("v.value") && component.get("v.value")!=""){
            component.find("utils").execute("c.getQueryData",{"query":"Select Id,Formatted_Address__c From Geography__c Where Id='"+component.get("v.value")+"'"},function(response){
                component.set("v.keyword",response[0].Formatted_Address__c);
            },function(error){
                component.find("utils").showError(error);
            })
        }else if(component.get("v.keyword")!=""){
            component.set("v.keyword","");
        }
    }
})