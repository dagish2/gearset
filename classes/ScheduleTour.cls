/**
 * Controller for the "Schedule a Tour" VF page.
 *
 * @author  - Antonio Grassi
 * @date    - 02/11/2014
 */
public without sharing class ScheduleTour {
    
    private Map<String, Building__c[]>  cityToBuildingMap;
    private TimeZone                    buildingTZ;
    
    public Tour_Outcome__c  newTour             {get; set;}
    public String           selectedCity        {get; set;}
    public String           selectedBuilding    {get; set;}
    public String           selectedTime        {get; set;}
    public Date             maxTourDate         {get; set;}
    public String           tourDetails         {get; set;}
    public SelectOption[]   availableTimes      {get; set;}
    public String           tourNotes           {get; set;}
    public String           product_line      {get; set;}
    
    public ScheduleTour() {
        newTour = new Tour_Outcome__c();
        
        selectedCity = null;
        selectedBuilding = null;
        selectedTime = null;

        if (System.currentPageReference().getParameters().get('leadId') != null) {
            newTour.Lead__c = System.currentPageReference().getParameters().get('leadId');
            tourNotes = [select Tour_Notes__c from Lead where Id = :newTour.Lead__c].Tour_Notes__c;
        }
        else if (System.currentPageReference().getParameters().get('oppId') != null) {
            newTour.Opportunity__c = System.currentPageReference().getParameters().get('oppId');
            tourNotes = [select Tour_Notes__c from Opportunity where Id = :newTour.Opportunity__c].Tour_Notes__c;
        }
        else if (System.currentPageReference().getParameters().get('journeyId') != null) {
            newTour.Journey__c = System.currentPageReference().getParameters().get('journeyId');
        }
        
        product_line = System.currentPageReference().getParameters().get('product_line');
        if(String.isEmpty(product_line))
            product_line ='WeWork';
            
        loadLocations();
    }
    
    private void loadLocations() {      
        cityToBuildingMap = new Map<String, Building__c[]>{};
        for (Tour_Schedule__c t:[Select Id, Name,Building__r.Id,Building__r.Name,Building__r.City__c From Tour_Schedule__c Where Product_Line__c =: product_line order by Building__r.Sort_Order__c asc]) {       
            if (t.Building__r.City__c != null) {
                if (!cityToBuildingMap.containsKey(t.Building__r.City__c)) {
                    cityToBuildingMap.put(t.Building__r.City__c, new Building__c[]{});
                }
                Building__c b = new Building__c(Id = t.Building__r.Id,Name = t.Building__r.Name );
                cityToBuildingMap.get(t.Building__r.City__c).add(b);
            }
        }
    }
    
    public SelectOption[] getCityList() {
        
        SelectOption[] res = new SelectOption[]{};
        
        String[] orderedCities = new List<String>(cityToBuildingMap.keySet());
        orderedCities.sort();
        
        for (String c:orderedCities) {
            res.add(new SelectOption(c, c));
        }
        
        return res;
    }
    
    public void citySelected() {
        SelectOption[] buildingList = getBuildingListForSelectedLocation();
        
        if (buildingList.size() == 1) {
            selectedBuilding = buildingList[0].getValue();
            buildingSelected();
        }
        else {
            selectedBuilding = null;
        }
    }
    
    public SelectOption[] getBuildingListForSelectedLocation() {

        SelectOption[] res = new SelectOption[]{};

        if (selectedCity != null) {
            for (Building__c b:cityToBuildingMap.get(selectedCity)) {
                res.add(new SelectOption(b.Id, b.Name));
            }
        }
        return res;
    }
    
    public void buildingSelected() {
        newTour.Tour_Date__c = null;
        Building__c buildingTimeZone = [select Time_Zone__c from Building__c where Id = :selectedBuilding Limit 1];
        Tour_Schedule__c tour_schedule = [select Maximum_Tour_Days__c from Tour_Schedule__c where Building__c = :selectedBuilding and Product_Line__c =: product_line Limit 1]; 
        buildingTZ = TimeZone.getTimeZone(buildingTimeZone.Time_Zone__c != null ? buildingTimeZone.Time_Zone__c : 'America/Los_Angeles');
        maxTourDate = Date.today().addDays(tour_schedule.Maximum_Tour_Days__c != null ? tour_schedule.Maximum_Tour_Days__c.intValue() : 21);
    }
    
    public void dateSelected() {
        if (newTour.Tour_Date__c != null && newTour.Tour_Date__c > maxTourDate) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Please select a date before ' + maxTourDate.format()));
            newTour.Tour_Date__c = null;
        }
        else if (newTour.Tour_Date__c != null) {
            reloadAvailableTimes();
        }
        selectedTime = null;
    }
    
    public void reloadAvailableTimes() {
        
        availableTimes = new SelectOption[]{};
        for (Time t:TourServices.getAvailableTimes(newTour.Tour_Date__c, selectedBuilding, product_line)) {
            String timeAsString = DateTime.newInstance(newTour.Tour_Date__c, t).format('h:mma', buildingTZ.getID());
            availableTimes.add(new SelectOption(timeAsString, timeAsString));
        }
    }
    
    public void timeSelected() {
        
        if (selectedTime != null) {
            Set<Time> availableTimes = TourServices.getAvailableTimesAsSet(newTour.Tour_Date__c, selectedBuilding, product_line);
            Datetime selectedDT = TourServices.adjustToTimeZone(newTour.Tour_Date__c, TourServices.parsePicklistTime(selectedTime), buildingTZ);
            
            if (!availableTimes.contains(selectedDT.time())) {
                reloadAvailableTimes();
                selectedTime = null;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,
                                                           'That time slot is no longer available.  Please select another time.'));
            }
            else {
                Building__c b = [select Name from Building__c where Id = :selectedBuilding];
                Datetime dt = TourServices.adjustToTimeZone(newTour.Tour_Date__c, TourServices.parsePicklistTime(selectedTime), buildingTZ);
                
                String tourFor = '(None)';
                
                if (newTour.Lead__c != null) {
                    tourFor = [select Name from Lead where Id = :newTour.Lead__c].Name;
                }
                else if (newTour.Opportunity__c != null) {
                    tourFor = [select Name from Opportunity where Id = :newTour.Opportunity__c].Name;
                }
                else if (newTour.Journey__c != null) {
                    tourFor = [select Name from Journey__c where Id = :newTour.Journey__c].Name;
                }
                tourDetails = 'Tour for ' + tourFor + ', on ' + b.Name + ' at ' + dt.format('EEEE MMMM d, yyyy - h:mma', buildingTZ.getId());
            }
        }
    }
    
    public PageReference confirmTour() {
        
        Set<Time> availableTimes = new Set<Time>(TourServices.getAvailableTimes(newTour.Tour_Date__c, selectedBuilding, product_line));
        Datetime selectedDT = TourServices.adjustToTimeZone(newTour.Tour_Date__c, TourServices.parsePicklistTime(selectedTime), buildingTZ);

        if (availableTimes.contains(selectedDT.time())) {
            
            Tour_Outcome__c t = TourServices.scheduleTour(newTour.Lead__c,
                                                          newTour.Opportunity__c,
                                                          selectedBuilding,
                                                          newTour.Tour_Date__c,
                                                          selectedTime,
                                                          product_line );
            
                                                          //newTour.Journey__c,
            // Refresh, as underlying trigger may have updated it
            t = [select Id, Lead__c, Opportunity__c, Journey__c from Tour_Outcome__c where Id = :t.Id limit 1];

            SObject redirectionObject = t;
            
            if (t.Lead__c != null) {
                redirectionObject = [select Id, Tour_Notes__c from Lead where Id = :t.Lead__c];
                redirectionObject.put('Tour_Notes__c', tourNotes);
                update redirectionObject;
            }
            else if (t.Opportunity__c != null) {
                redirectionObject = [select Id, Tour_Notes__c from Opportunity where Id = :t.Opportunity__c];
                redirectionObject.put('Tour_Notes__c', tourNotes);
                redirectionObject.put('Building__c', selectedBuilding);
                update redirectionObject;
            }
            else if (t.Journey__c != null) {
                redirectionObject = [select Id, Status__c, Primary_Contact__c from Journey__c where Id = :t.Journey__c];
                redirectionObject.put('Status__c', 'Completed');
                t.Primary_Member__c = (Id)redirectionObject.get('Primary_Contact__c');
                update t;
                update redirectionObject;
            }
            
            ApexPages.StandardController sc = new ApexPages.StandardController(redirectionObject);
            PageReference pr = sc.view();
            pr.setRedirect(true);
            return pr;
        }
        else {
            selectedTime = null;
            reloadAvailableTimes();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,
                                                       'That time slot is no longer available.  Please select another time.'));
        }
        return null;
    }
}