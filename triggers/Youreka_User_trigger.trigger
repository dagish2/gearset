/* This trigger was created by the Youreka package and is integral to it. 
Please do not delete */
trigger Youreka_User_trigger on User (after update){
    disco.Util.updateObjectsFieldLinkAnswers(trigger.new,'User');
}