/**
* @author Gad Sharon
* @date 25/09/18
* @description The interface is used to create classes that can be dynamically invoked using 
*              'TriggerProcessingManager' class.               
*/
public interface IProcessHandler {

    /**
    * @author Gad Sharon
    * @date 25/09/18
    * @description The main method, called from any trigger and performs all actions required to in the context of the trigger.
    * @return void
    */
    void handle(list<sObject> triggerNew, map<Id, sObject> triggerOldMap);
}