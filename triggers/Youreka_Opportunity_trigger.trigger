/* This trigger was created by the Youreka package and is integral to it. 
Please do not delete */
trigger Youreka_Opportunity_trigger on Opportunity (after update){
    disco.Util.updateObjectsFieldLinkAnswers(trigger.new,'Opportunity');
}