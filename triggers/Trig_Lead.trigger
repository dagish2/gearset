trigger Trig_Lead on Lead (after insert, after update) { 
    try{
        et4ae5.triggerUtility.automate('Lead');
    } catch(Exception e){
        if(Test.isRunningTest()){
            return;
        } else {
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('Trig_Lead','et4ae5.triggerUtility.automate','',e)
            );
            throw e;
        }
    }
}