/************************************************************************************************************************************
    Author      :  Sunil Bhosale  
    Description :  Forcefully update longstanding Journeys.
    Issue No    :  ST-1547

    History     :
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION    DATE        AUTHOR            DETAIL
        1                 Sunil Bhosale      Initial Developement
        2   14/11/2018    Jitesh Adwani      ST-3033 Change Name of the fields.
**************************************************************************************************************************************/
global class SchedulableToForceFullyUpdateJourney implements Schedulable {
	global void execute(SchedulableContext SC) {
        BatchToForceFullyUpdateJourneys objBatch = new BatchToForceFullyUpdateJourneys();         
        Database.executeBatch(objBatch);
    }
}