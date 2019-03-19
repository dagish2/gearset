/*
* Created By: Anant Kumar
* Date : 15/June/2016
* Handler class for Referral__c object
*/
public class ReferenceHandler {
	public static ReferenceSettings settingsReference;
	static {
		settingsReference = (ReferenceSettings)Settings.get('ReferenceSettings',ReferenceSettings.class);
		if( settingsReference == null )
			settingsReference = DefaultReferenceSettings();
	}
    
	public static ReferenceSettings DefaultReferenceSettings() {
        ReferenceHandler.ReferenceSettings settingReference;
		settingReference = new ReferenceHandler.ReferenceSettings();
        settingReference.expireafter = 60;
        return settingReference;
    }

	public class ReferenceSettings {
		public Integer expireafter{get;Set;}
	}

    public static void ExtendReference(Set<String> emails)
    {
		List<Referral__c> references = [SELECT Id FROM Referral__c WHERE Referral_Email__c in:emails AND IsActive__c=true];
    	for(Referral__c reference : references){
    		reference.Expires_On__c = System.today().addDays(settingsReference.expireafter);
    	}
    	update references;	
    }
    
    static map <string,Id> mapActiveReferenceToControlSOQL = new map<string,Id>();
    static map <string,Id> mapActiveReference = new map<string,Id>();
    public static map <string,Id> getActiveReference(Set<String> setEmail)
    {	
    	Boolean newEmailinSet = false;
    	if(mapActiveReferenceToControlSOQL.size() > 0){
	    	for(String email : setEmail){
	    		if(!mapActiveReferenceToControlSOQL.containsKey(email.toLowerCase())){
	    			newEmailinSet = true;
	    		}
	    	}
    	}
    	else
    		newEmailinSet = true;
    	Debug.log('Test : mapActiveReference ::: ' + mapActiveReference);
    	Debug.log('Test : newEmailinSet ::: ' + newEmailinSet);
    	Debug.log('Test : setEmail ::: ' + setEmail);
    	Debug.log('Test : mapActiveReferenceToControlSOQL ::: ' + mapActiveReferenceToControlSOQL);
    	if(newEmailinSet){
    		List<Referral__c> allReferral = [ SELECT Referral_Email__c, Referrer_Email__c, Referrer__c FROM Referral__c WHERE Referral_Email__c in:setEmail AND IsActive__c = true];
			for(Referral__c reference : allReferral)
			{
				if(reference.Referrer__c != null)
				{ 
					if(!string.isBlank(reference.Referral_Email__c) && !mapActiveReference.containsKey(reference.Referral_Email__c))
					{
						mapActiveReference.put(reference.Referral_Email__c.toLowerCase(),reference.Referrer__c);
						mapActiveReferenceToControlSOQL.put(reference.Referral_Email__c.toLowerCase(),reference.Referrer__c );
					}
					//return reference.Referrer__c;
				}
			}
			if(allReferral.size() == 0){
				for(String email : setEmail){
		    		if(email != null && !mapActiveReferenceToControlSOQL.containsKey(email)){
		    			mapActiveReferenceToControlSOQL.put(email.toLowerCase(), null );
		    		}
				}
	    	}
			
    	}
		Debug.log('mapActiveReference in reference handler::'+mapActiveReference);
		return mapActiveReference;
    }
 
    public static Id getActiveReference(String email)

    {		
    	Referral__c[] reference = [ SELECT Referrer_Email__c, Referral_Email__c, Referrer__c FROM Referral__c WHERE Referral_Email__c = :email AND IsActive__c = true];
		Debug.log('Test : email ::: ' + email);
        if(reference.size() > 0)
		{
            Debug.log('Test : reference ::: ' + reference);
            Debug.log('Test : reference[0].Referrer__c ::: ' + reference[0].Referrer__c);
			return reference[0].Referrer__c;
		}
		return null;
    }
     
	/*
    * @Comment   : This method override for Extend Reference form given date. 
    * @Issue     : ST-529
    * @Author    : Pranay Jadhav
    * @Date      : 22/07/2016 
  */  
	public static SaveResult ExtendReference(Id recordId, Date startDate, Date referredDate){
    	try{
			SaveResult referenceResult;
			if(startDate < System.today().addDays(-settingsReference.expireafter)){
				Referral__c reference = [ Select Id,Expires_On__c, Referred_Date__c From Referral__c where Id =: recordId AND IsActive__c = true Limit 1];
				if(reference != null){
					reference.Expires_On__c = startDate.addDays(settingsReference.expireafter);
					reference.Start_Date__c = startDate;
					reference.Referred_Date__c = referredDate;
					reference.IsActive__c = false;
					referenceResult = new SaveResult(Database.update(reference));
				}
			}else{
				Referral__c reference = [ Select Id,Expires_On__c From Referral__c where Id =: recordId AND IsActive__c = true Limit 1];
				if(reference != null){
					reference.Expires_On__c = startDate.addDays(settingsReference.expireafter);
					reference.Start_Date__c = startDate;
					reference.Referred_Date__c = referredDate;
					reference.IsActive__c = true;
					referenceResult = new SaveResult(Database.update(reference));
				}	
			}	
			return referenceResult;
		}catch(Exception ex){
			SaveResult referenceResult = new SaveResult();
			referenceResult.IsSuccess = false;
			return referenceResult;
		}
    }
    
    public static void PreventDuplicateActiveReference()
    { 
    	set<string> setReferenceEmails = new set<string>();
    	set<string> setExistingReferenceEmails = new set<string>();
    	list<Referral__c> lstReferences = trigger.new;
    	Boolean errorFlag = false;
    	
    	for(Referral__c currentReference : lstReferences)
    	{
    		if(!String.isBlank(currentReference.Referral_Email__c))
    		{
    			setReferenceEmails.add(currentReference.Referral_Email__c.toLowerCase());
    		}	
    	}
    	list<Referral__c> lstExistingReferences = [Select Id, Name, Referral_Email__c , IsActive__c from Referral__c where Referral_Email__c IN : setReferenceEmails and IsActive__c = true];
    	for(Referral__c currentReference : lstExistingReferences)
    	{
    		setExistingReferenceEmails.add(currentReference.Referral_Email__c.toLowerCase());
    	}
    	for(Referral__c currentReference : lstReferences)
    	{
    		if(!String.isBlank(currentReference.Referral_Email__c))
    		{
    			setReferenceEmails.add(currentReference.Referral_Email__c.toLowerCase());
    		}
    	}
    	for(Referral__c currentReference : lstReferences)
    	{
    		if(!String.isBlank(currentReference.Referral_Email__c))
    		{
    			if(setExistingReferenceEmails.contains(currentReference.Referral_Email__c.toLowerCase()))
    			{
    				errorFlag = true;
    			}
    		}
    	}
    	if(errorFlag)
    		trigger.new[0].addError('Duplicate reference'); 
    } 
}