({
    manageGeo:function(component,list,index){
        var helper = this;
        if(index<list.length){
            component.set("v.msg","Creating "+(index+1)+" of "+list.length+" geography records.");
            helper.getGeo(component,list[index].GeographyName,function(geoid){
                if(geoid){
                    component.find("utils").execute("c.saveRecords",{"records":[{"Id":list[index].BuildingID,"Geography__c":geoid},{"Id":geoid,"Nearest_Building__c":list[index].BuildingID}]},function(response){
                        helper.manageGeo(component,list,(index+1));
                    },function(error){
                        console.log(error+"--"+JSON.stringify(list[index]));
                        helper.manageGeo(component,list,(index+1));
                    })
                }else{
                    helper.manageGeo(component,list,(index+1));
                }
            })
        }else{
            component.find("utils").showSuccess("Geolocations updated successfully");
        }
    },
    getGeo : function(component,keyword,onsuccess) {
        var helper = this;
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
                    helper.createGeo(component,onsuccess)
                }else{
                    console.log(keyword+"---"+response);
                    component.set("v.searchResult", []);
                    helper.createGeo(component,onsuccess);
                }
            }catch(err){
                component.set("v.searchResult", []);
                helper.createGeo(component,onsuccess);
            }
        },function(error){
            component.set("v.searchResult", []);
            helper.createGeo(component,onsuccess);
        });
	},
    createGeo:function(component,onsuccess){
        var searchResult = component.get("v.searchResult");
        var index = 0;
        if(searchResult && index != undefined && searchResult[index] != undefined){
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
            component.find("utils").execute("c.upsertGeolocation",{"objGeography":googlePlaceRec},function(response){
                onsuccess(response);
            },function(error){
                 onsuccess();
            })
        }else{
            onsuccess();
        }
    }
})