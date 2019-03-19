/* This trigger was created by the Youreka package and is integral to it. 
Please do not delete */
trigger Youreka_Case_trigger on Case (after update){
    disco.Util.updateObjectsFieldLinkAnswers(trigger.new,'Case');
}