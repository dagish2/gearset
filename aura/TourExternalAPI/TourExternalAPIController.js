({
    doInit : function(component, event, helper){
        component.set("v.utils", component.find("utils"));
        component.get("v.utils").execute("c.getSettingDataForBookTour", {}, function(response){
            if(response){
                component.set("v.AllTourEndPoints", response);
            }
        },function(error){
            component.get("v.utils").hideProcessing();
            component.get("v.utils").showError(error);
        },component);
    },
    loadTimeSlots:function(component, event, helper){
        let params = event.getParam('arguments');
        let urlParameters = params.urlParameters;
        let timeSlotsEndpoint = component.get("v.AllTourEndPoints")['tourbuildingavailabilitiesapi'];
        let endPointUrl = timeSlotsEndpoint.EndPoint__c+'?building_id='+urlParameters.building_id+'&date='+urlParameters.date;
        if(urlParameters.show_past != null && urlParameters.show_past != undefined){
            endPointUrl += '&show_past='+urlParameters.show_past
        }
        if(urlParameters.product_line != null && urlParameters.product_line != undefined){
            endPointUrl += '&product_line='+urlParameters.product_line;
        }
        component.get("v.utils").execute("c.executeRest",{"method":timeSlotsEndpoint.Method__c,"endPointUrl":endPointUrl,"headers":JSON.parse(timeSlotsEndpoint.Headers__c),"body":''},function(response){
            let result = JSON.parse(response);
            let times = result.available_tour_times;
            for(let row in times){
                times[row].time = times[row].time.split(" ").join("");
            }
            if(times && times.length > 0){
                params.success(times);
            }else if(result.error){
                params.error(result.message); 
            }else{
                params.error('No times slots available for '+params.urlParameters.building_Name+  ' on date '+params.urlParameters.date );
            }
        },function(error){            
            params.error(error);
        })
    },
    getBUildingUUID : function(tour){
        if(tour.Location__r && tour.Location__r.UUID__c){
            return tour.Location__r.UUID__c;
        }else if(tour.building_uuid){
            return tour.building_uuid;
        }
    },
    createPayload: function(component, event, helper){
        let params = event.getParam('arguments');
        let formData = params["data"]["formData"];
        let contactData = params["data"]["contact"];
        let accountData = params["data"]["account"];
        let loggedInUserContact = params["loggedInUserContact"];
        let contactIdLoggedIn = loggedInUserContact ? loggedInUserContact.Id : null;
        let	Payload ={"date": formData.tourDate,
                      "time": formData.startTime,
                      "building_id": formData.building_id,
                      "notes": formData.notes,
                      "product_line": formData.productLine ? formData.productLine : "WeWork",
                      "contact_name": contactData.Name,
                      "email": contactData.Email,
                      "phone": contactData.Phone,
                      "company_name": contactData.Account.Name? contactData.Account.Name : accountData? accountData.Name: null,
                      "contact_uuid": contactData.UUID__c,
                      "company_uuid": contactData.Account.UUID__c ? contactData.Account.UUID__c: accountData? accountData.UUID__c:null,
                      "sf_journey_uuid": formData.journeyId,
                      "primary_member": contactData.Id ? contactData.Id : contactData.contactId,
                      "booked_by_id": "",
                      "booked_by_contact_id": contactIdLoggedIn,
                      'opportunity_id': formData.opportunityId,
                      "lead_source": formData.LeadSource,
                      "lead_source_detail": formData.LeadSourceDetail,
                      "addBookTourNo": "addBookingId",
                      "booked_by_sales_lead": formData.bookedBySalesLead ? formData.bookedBySalesLead : false,
                      "assigned_host": contactIdLoggedIn,
                      "hosted_by": contactIdLoggedIn
                     }
        return Payload;
    },
    bookATour: function(component, event, helper){
    	let params = event.getParam('arguments');
        let timeSlotsEndpoint = component.get("v.AllTourEndPoints")['tourcreateapi'];
        let endPointUrl = timeSlotsEndpoint.EndPoint__c;
        component.get("v.utils").execute("c.executeRest",{"method":timeSlotsEndpoint.Method__c,"endPointUrl":endPointUrl,"headers":JSON.parse(timeSlotsEndpoint.Headers__c),"body":JSON.stringify(params.payload)},function(response){
            console.log('data ==>'+response);
            params.success(JSON.parse(response));
        },function(error){            
            params.error(error);
        })
    }
})