/* This trigger was created by the Youreka package and is integral to it. 
Please do not delete */
trigger Youreka_Account_trigger on Account (after update){
    disco.Util.updateObjectsFieldLinkAnswers(trigger.new,'Account');
}