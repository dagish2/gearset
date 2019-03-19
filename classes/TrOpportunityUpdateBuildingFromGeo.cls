/**
* @author Gad Sharon    
* @date 02/10/18
* @description If the field "Building__c" is null, we set it according to the field "Geography__c".
				Runs on before insert and before update.
* --------------------------------------------------------------------------------------
* CHANGE HISTORY:
* --------------------------------------------------------------------------------------
* @author      - 
* @date        - 
* @description - 
* --------------------------------------------------------------------------------------
*/

public class TrOpportunityUpdateBuildingFromGeo implements IProcessHandler{

	/**
    * @author Gad Sharon
    * @date 02/10/18
    * @description Main logic of the trigger.
    * @param list<sObject> - records from trigger.new list.
    		 map<Id, sObject> - Records from trigger.oldMap. 
    		 					On insert action this map is null.
    * @return None.
    */

	public void handle(list<sObject> triggerNew, map<Id, sObject> triggerOldMap)
	{
        map <Id, list <Opportunity>> mapGeoIdToOpps = filter((list <Opportunity>)triggerNew, triggerOldMap);

        if(!mapGeoIdToOpps.isEmpty())
        {
        	updateBuilding(mapGeoIdToOpps);
        }
	}

	/**
    * @author Gad Sharon
    * @date 02/10/18
    * @description Find relevant opps we need to run the logic on.
    * @param List<Opportunity> - The opps this trigger is running on.
    		 Map<Id, sObject> - The old stage of the opps this trigger is running on.
    * @return map <Id, list <Opportunity>> - Map of geography id to list of opps that have that geography. 
    */

	public map <Id, list <Opportunity>> filter(list<Opportunity> triggerNew, map<Id, sObject> triggerOldMap)
	{
        map <Id, list <Opportunity>> mapGeoIdToOpps = new map <Id, list <Opportunity>>();

		for(Opportunity opp : triggerNew)
        {
            if(opp.Geography__c != null && 
               opp.Building__c == null &&
            	(triggerOldMap.isEmpty() ||
            		(opp.Geography__c != triggerOldMap.get(opp.Id).get('Geography__c'))))
            {
                if(!mapGeoIdToOpps.containsKey(opp.Geography__c))
                {
                    mapGeoIdToOpps.put(opp.Geography__c, new list <Opportunity>());
                }
                
                mapGeoIdToOpps.get(opp.Geography__c).add(opp);
            }
        }
        
        return mapGeoIdToOpps;
	}

	/**
    * @author Gad Sharon
    * @date 02/10/18
    * @description Find relevant opps we need to run the logic on.
    * @param map <Id, list <Opportunity>> - Map of geography id to list of opps that have that geography.
    * @return None. 
    */

	public void updateBuilding(map <Id, list <Opportunity>> mapGeoIdToOpps)
	{
		list <Geography__c> lstGeography = new list <Geography__c>([SELECT Id, Nearest_Building__c 
                                                                    FROM Geography__c 
                                                                    WHERE Id IN  :mapGeoIdToOpps.keySet()
                                                                    AND Nearest_Building__c != null]);
		
        for(Geography__c curGeo :lstGeography)
        {
            for(Opportunity opp : mapGeoIdToOpps.get(curGeo.Id))
            {
                opp.Building__c = curGeo.Nearest_Building__c;
            }
        }
	}

}