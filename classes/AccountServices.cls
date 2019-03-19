public class AccountServices {
    public Account a    {get; set;}
    public Contact c    {get; set;}
    public Lead existingLead   {get; set;}
    TriggerSettings.TriggersMappedField triggerSetting = TriggerSettings.get();
    public class AccountServicesException extends Exception {}
    // Load init from Web Handler
    public AccountServices(){}
    public AccountServices(WWTypes.InboundLead pInboundLead) {
        try{
            // Load Account
            this.a = this.get_account_by_uuid(pInboundLead.account_uuid);
            Debug.log('Account Service :: get_account_by_uuid : '+this.a);
            // Load Contact
            // SOQL Optimization
            this.c = this.get_contact_by_uuid_or_email(pInboundLead.contact_uuid,pInboundLead.email);
            
            //Load Existing Lead if any
            this.existingLead = this.get_Lead_By_Id(pInboundLead.Email);
            
            // Account exists
            if (this.a != null) {
                //CSI-637
                updateAccountForInterestedDesk(this.a,pInboundLead);
               
                // Contact not exists
                if (this.c == null) {
                    insert_contact_by_web(pInboundLead);
                }
                // Contact exists
                else if (this.c != null) {
                    Debug.log('In Account Service contact != null');
                    // Do nothing if belongs to Account
                    if (this.c.AccountId != this.a.Id) {
                        Debug.log('this.c.AccountId != this.a.Id');
                        // If Contact is Primary Member on another Account
                        if (this.c.Is_Primary_Member__c) {
                            //Author   : Sunil bhosale 
                            //Issue No.   :ST-1445
                            //Date    :26/09/2017
                            //Comment  : Sync: Tour: Issues When Syncing Tours between SS <> SFDC Remove validation of Primary contact
                            if(triggerSetting.Tour_primaryContractValidation){
                                throw new AccountServicesException('Contact is Primary Member on different Account');
                            }
                            else{
                                //update_contact_account();
                                mapPrimaryContactToAccount(this.a.Id,this.c.Id);
                            }
                            
                        }
                        // Contact is a regular member on another Account, move to this Account
                        else {
                            Debug.log('In Account Service contact else');
                            // ST-164 :-Endpoint Tour: Should not update existing Contact's Account
                            //update_contact_account();
                        }
                    }
                }
            }
            // Account not exists
            else {
                Debug.Log('Account Not exist : '+this.c);
                // Contact Exists
                if (this.c != null) {
                    // If Contact is Primary Member on another Account
                    if (this.c.Is_Primary_Member__c) {
                        //Author : Sunil bhosale 
                        //ST-1445
                        //Date:26/09/2017
                        //Sync: Tour: Issues When Syncing Tours between SS <> SFDC
                        if(triggerSetting.Tour_primaryContractValidation){
                            throw new AccountServicesException('Contact is Primary Member on different Account');
                        }
                        else{
                            debug.log('lead Parent Account==>'+this.existingLead.Account__c);
                            insert_account_by_web(pInboundLead);
                            Debug.log('pInboundLead'+pInboundLead);
                            Account a1 =this.get_account_by_uuid(pInboundLead.account_uuid);
                            if(a1 != null){
                                mapPrimaryContactToAccount(a1.Id,this.c.Id);  
                            }                           
                        }
                    }
                    // Contact is a regular member on another Account, create Account and transfer Contact
                    else {
                        insert_account_by_web(pInboundLead);
                        update_contact_account();
                    }
                }
                // Contact does not exist
                else {
                    Debug.log('In Account Service Insert account and contact');
                    insert_account_by_web(pInboundLead);
                    insert_contact_by_web(pInboundLead);
                }
            }
            
            //Changes added by : Anant Kumar
            //Date : 04/Aug/2016
            //LeadServices ls = new LeadServices(pInboundLead);
            Debug.log('this.a.Id ::'+this.a);
            if((this.existingLead != null && !this.existingLead.isConverted) && (this.a.Id == this.c.AccountId)){
                //Lead owner should be User. Date : 13-01-17 
                String existingLeadOwnerId = this.existingLead.OwnerId;
                String existingLeadId = this.existingLead.Id;
                
                if(existingLeadOwnerId.startsWith('00G')){
                    this.existingLead.OwnerId = userInfo.getUserId();
                    update this.existingLead;
                    List<Journey__c> journeyToUpdate = new List<Journey__c>();
                    for(Journey__c journey: [SELECT Id, OwnerId FROM Journey__c WHERE Primary_Lead__c=:existingLeadId AND Status__c = 'Started']){
                        journey.OwnerId = userInfo.getUserId();
                        journeyToUpdate.add(journey);
                    }
                    if(journeyToUpdate.size() > 0)
                        update journeyToUpdate;
                }
                
                Database.LeadConvert lc = new Database.LeadConvert();
                lc.setAccountId(this.a.Id);
                lc.setContactId(this.c.Id);
                lc.setDoNotCreateOpportunity(true);
                lc.setLeadId(this.existingLead.Id);
                
                LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
                Debug.log('Before convert lead ::');
                lc.setConvertedStatus(convertStatus.MasterLabel);
                Database.LeadConvertResult lcr = Database.convertLead(lc);
                Debug.log('After convert lead ::');
            }
        }catch(Exception ex){
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('AccountServices','AccountServices',JSON.serializePretty(pInboundLead), ex)
            );
            throw new AccountServicesException(ex.getMessage());
        }
    }

    //Author : Sunil bhosale 
    //ST-1445
    //Date:28/09/2017
    //Sync: Tour: Issues When Syncing Tours between SS <> SFDC
    //Description : this method is used to update the primary member on account
    private void mapPrimaryContactToAccount(Id accId,Id conId){
        try{
            Account a = new Account();
            a.Id =  accId;
            a.Primary_Member__c =  conId;
            update a; 
        }catch(Exception ex){
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('AccountServices','mapPrimaryContactToAccount',accId +','+ conId, ex)
            );
            throw new AccountServicesException(ex.getMessage());
        }
    }
    
    private void insert_account_by_web(WWTypes.InboundLead pInboundLead) {
        try{
            debug.log('this.existingLead==>'+this.existingLead);           
            this.a = new Account(
                Name = pInboundLead.company_name,
                UUID__c = pInboundLead.account_uuid,
                ParentId = (this.existingLead.Account__c != null ? this.existingLead.Account__c : null),
                Org_Identification_Status__c = (this.existingLead.Account__c != null ? 'Processed':'Pending'),
                //CSI-637
                Interested_in_Number_of_Desks_Range__c  = (String.isNotBlank(pInboundLead.desks_interested_range)) ? pInboundLead.desks_interested_range :  null,
                Interested_in_Number_of_Desks_Min__c = (String.isNotBlank(pInboundLead.desks_interested_min)) ? Integer.valueOf(pInboundLead.desks_interested_min) : null,
                Interested_in_Number_of_Desks_Max__c = (String.isNotBlank(pInboundLead.desks_interested_max)) ? Integer.valueOf(pInboundLead.desks_interested_max) : null
            );
            //CSI-637
           this.a =  insert_or_update_desk(this.a,pInboundLead);
            
            if(this.existingLead != null)
                this.a.Lead_Source__c = this.existingLead.LeadSource;
            else 
                this.a.Lead_Source__c = pInboundLead.lead_source;
            
            insert this.a;
        }catch(Exception ex){
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('AccountServices','insert_account_by_web',JSON.serializePretty(pInboundLead), ex)
            );
            throw new AccountServicesException(ex.getMessage());
        }
    }
    
    private void insert_contact_by_web(WWTypes.InboundLead pInboundLead) {
        try{
            Debug.log('pInboundLead In insert_contact_by_web ==>'+pInboundLead);
            this.c = new Contact(
                FirstName = pInboundLead.first_name,
                LastName = pInboundLead.last_name,
                Phone = pInboundLead.phone,
                Email = pInboundLead.email,
                Locale__c = pInboundLead.locale,
                Product_Interests__c = LeadServices.getProduct_Interests(pInboundLead.product_interests),
                Country_Code__c = pInboundLead.country_code,
                Product_Line__c = pInboundLead.product_line,
                UUID__c = pInboundLead.contact_uuid,
                AccountId = this.a.Id,
                Marketing_Consent__c = (pInboundLead.marketing_consent != null ? AccountServices.checkIsValidBoolean(pInboundLead.marketing_consent,'marketing_consent') :false),
                Affiliate_Consent__c = (pInboundLead.affiliates_consent != null ? AccountServices.checkIsValidBoolean(pInboundLead.affiliates_consent,'Affiliate_Consent__c'):false),
                Ts_and_Cs_Consent__c = (pInboundLead.t_and_cs_consent != null ? AccountServices.checkIsValidBoolean(pInboundLead.t_and_cs_consent,'Ts_and_Cs_Consent__c'):false),
                Referral_Fail_Reason__c	= pInboundLead.referral_fail_reason != null &&pInboundLead.referral_fail_reason!= '' ? pInboundLead.referral_fail_reason.length() > 255 ? pInboundLead.referral_fail_reason.substring(0, 255):pInboundLead.referral_fail_reason: null
            );
            
            //ST-803
            if(this.existingLead != null)
            {
                this.c.LeadSource = this.existingLead.LeadSource;
                this.c.Lead_Source_Detail__c = this.existingLead.Lead_Source_Detail__c;
            }
            else {
                this.c.LeadSource = pInboundLead.lead_source;
                this.c.Lead_Source_Detail__c = pInboundLead.lead_source_detail;
            }
            
            insert this.c;
            
            //reload
            this.c = get_contact_by_id(this.c.Id);        
            
            // Reload records as Contact might have been set as Primary Member for Account
            if (this.a.Primary_Member__c == null) {
                this.a = get_account_by_id(this.a.Id);
            }
            
            //explicit set of contact_uuid to the new one
            pInboundLead.contact_uuid = this.c.uuid__c;
        }catch(Exception ex){
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('AccountServices','insert_contact_by_web',JSON.serializePretty(pInboundLead), ex)
            );
            throw new AccountServicesException(ex.getMessage());
        }
    }
    
    private void update_contact_account() {
        try{
            this.c.AccountId = this.a.Id;
            update this.c;
            // Reload records as Contact might have been set as Primary Member for Account
            if (this.a.Primary_Member__c == null) {
                this.c = get_contact_by_id(this.c.Id);
                this.a = get_account_by_id(this.a.Id);
            }
        }catch(Exception ex){
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('AccountServices','update_contact_account',null, ex)
            );
            throw new AccountServicesException(ex.getMessage());
        }
    }
    
    //Author : Rupesh Patil 
    //Issue  : CSI-637
    //Date   : 13/03/2018
    //Description : this method is used to insert or update the fields Interested_in_Number_of_Desks__c,Interested_in_Number_of_Desks_Range__c,Interested_in_Number_of_Desks_Min__c,Interested_in_Number_of_Desks_Max__c,company_size on Account
    private Account insert_or_update_desk(Account a, WWTypes.InboundLead pInboundLead){
        //parameter desks_interested_min will be passed which will be mapped in Interested_in_Number_of_Desks__c
            if(String.isNotBlank(pInboundLead.desks_interested_min)){
                this.a.Interested_in_Number_of_Desks__c = Integer.valueof(pInboundLead.desks_interested_min);
            }else if(String.isNotBlank(pInboundLead.company_size) && pInboundLead.company_size != 'Unknown'){
                String quantity = pInboundLead.company_size;
                Debug.log('quantity :: '+quantity);
                Integer q;
                if(!quantity.contains('-') && !quantity.contains('+') ){
                    if(String.isBlank(quantity))
                        q = Integer.valueOf('1');
                    else
                        q = Integer.valueOf(quantity.split(' ')[0]);
                }
                else{
                    quantity = quantity.replaceAll( ' ', '');
                    q = Integer.valueOf(String.isBlank(quantity)?'1':(quantity.contains('-')?(quantity.split('-')[0]):(quantity.contains('+')?(quantity.substring(0,quantity.indexOf('+'))):(quantity.split(' ')[0]))));
                }
                this.a.Interested_in_Number_of_Desks__c = q;
                
            }else if((String.isNotBlank(pInboundLead.company_size) && pInboundLead.company_size == 'Unknown')){
                this.a.Interested_in_Number_of_Desks__c = 0;
            }
        return a;
    }
    //Author : Rupesh Patil 
    //Issue  : CSI-637
    //Date   : 13/03/2018
    //Description: This method is used to update existing account for the interested no of desk fields
    private void updateAccountForInterestedDesk(Account a, WWTypes.InboundLead pInboundLead){
        if(String.isNotBlank(pInboundLead.desks_interested_min))
           this.a.Interested_in_Number_of_Desks_Min__c =  Integer.valueOf(pInboundLead.desks_interested_min);
        if(String.isNotBlank(pInboundLead.desks_interested_max)) 
           this.a.Interested_in_Number_of_Desks_Max__c =  Integer.valueOf(pInboundLead.desks_interested_max);
        if(String.isNotBlank(pInboundLead.desks_interested_range))
           this.a.Interested_in_Number_of_Desks_Range__c = pInboundLead.desks_interested_range;
        
        this.a = insert_or_update_desk(this.a,pInboundLead);
        update this.a;
    }
    private Contact get_contact_by_uuid_or_email(String uuid, String email) {
        Debug.log('Account Service :: get_account_by_uuid_or_email:: uuid:'+uuid+' email:'+email);  
        //dramatic exit
        if (String.isBlank(uuid) && String.isBlank(email)) return null;
        
        Contact[] Cs = [SELECT Id,
                        AccountId,
                        OwnerId,
                        Is_Primary_Member__c,
                        FirstName,
                        LastName,
                        Phone,
                        Email,
                        Product_Interests__c,
                        Product_Line__c,  
                        UUID__c,
                        Id_Kind__c
                        FROM Contact 
                        WHERE UUID__c = :uuid OR Email = :email 
                        ORDER BY CreatedDate DESC
                        LIMIT 1];
        
        return Cs.size() > 0 ? Cs[0] : null;
    }
    
    private Contact get_contact_by_email(String email) {
        if (email == null || email == '') return null;
        Contact[] Cs = [SELECT Id,
                        AccountId,
                        OwnerId,
                        Is_Primary_Member__c,
                        FirstName,
                        LastName,
                        Phone,
                        Email,
                        Product_Interests__c,
                        Product_Line__c,  
                        UUID__c,
                        Id_Kind__c
                        FROM Contact 
                        WHERE Email = :email 
                        ORDER BY CreatedDate DESC
                        LIMIT 1];
        
        return Cs.size() > 0 ? Cs[0] : null;
    }
    
    private Contact get_contact_by_id(Id contactId) {
        Contact[] Cs = [SELECT Id,
                        AccountId,
                        OwnerId,
                        Is_Primary_Member__c,
                        FirstName,
                        LastName,
                        Phone,
                        Email,
                        Product_Interests__c,
                        Product_Line__c,
                        UUID__c,
                        Id_Kind__c
                        FROM Contact 
                        WHERE Id = :contactId];
        
        return Cs.size() > 0 ? Cs[0] : null;
    }
    
    private Account get_account_by_uuid(String uuid) {
        //dramatic exit
        if (uuid == null || uuid == '') return null;
        
        //ST-1156
        //Changes made by Amol Darekar to get UUID from Merge Account Object records call to method WeworkEngine.getMasterAccountUUID().
        String masterAccountUUID = WeworkEngine.getMasterAccountUUID(uuid);
        String useAccUUID = null;
        if(masterAccountUUID == null)
            useAccUUID = uuid;
        else
            useAccUUID = masterAccountUUID;
        Account[] Accs = [SELECT Id, OwnerId, Primary_Member__c,ParentId,Interested_in_Number_of_Desks_Max__c,Interested_in_Number_of_Desks_Range__c,Interested_in_Number_of_Desks_Min__c,Interested_in_Number_of_Desks__c
                          FROM Account
                          WHERE UUID__c = :useAccUUID 
                          ORDER BY CreatedDate DESC
                          LIMIT 1];
        
        Debug.log('IN get_account_by_uuid :: '+Accs);
        return Accs.size() > 0 ? Accs[0] : null;
    }
    
    private Account get_account_by_id(Id accountId) {
        
        Account[] Accs = [SELECT Id, OwnerId, Primary_Member__c,ParentId
                          FROM Account
                          WHERE Id = :accountId];
        
        return Accs.size() > 0 ? Accs[0] : null;
    }
    
    private Lead get_Lead_By_Id(String emailId) {
        Lead[] leads = [SELECT Id, LeadSource,Account__c,Lead_Source_Detail__c, isConverted, ownerId
                        FROM Lead
                        WHERE Email = :emailId];
        return leads.size() > 0 ? leads[0] : null;
    }
    
    //Created By  :   Samadhan kadam
    //Issue No  :   ST-1232
    //Discription :   This method return a string which is used in UpdateCleansedAccNameAndUnomyName in AccountTriggerHandler class method to update Cleansed Company Name and  Cleansed Unomy Company Name.
    //CreatedDate :   24/07/2017
    public static String createCleansedAccAndUnomyName(string name){  
        try{
            String[] prefix,suffix;
            String specialCharacter;
            Setting__c accountCleansing = new Setting__c();
            accountCleansing = Settings.get('AccountCleansingSetting');
            debug.log('accountCleansing:::'+accountCleansing);
            AccountCleansingSetting settingData = new AccountCleansingSetting();
            if(accountCleansing != null){
                settingData = (AccountCleansingSetting)JSON.deserialize(accountCleansing.Data__c, AccountCleansingSetting.class);
                debug.log('settingData:::'+settingData);
                prefix = settingData.starts_With;
                suffix = settingData.ends_With;         
                specialCharacter = settingData.specialCharacters;  
                String cleansedName = name;     
                cleansedName = cleansedName.trim();
                cleansedName = cleansedName.toLowerCase();
                for(integer i=0; i<specialCharacter.split('|').size(); i++)
                {
                    cleansedName = cleansedName.replace(specialCharacter.split('|')[i], ' ');
                }
				cleansedName = cleansedName.trim();
                while(true){
                    Boolean flag = true;
                    for(string str : prefix){
                        // Debug.log('str----'+str);
                        if(cleansedName.startsWith(str.toLowerCase()+' ')){
                            cleansedName = cleansedName.substring(str.length(),cleansedName.length());
                            cleansedName = cleansedName.trim();
                            flag = false;
                        }
                    }
                    for(string str : suffix){
                        // Debug.log('str----'+str);
                        if(cleansedName.endsWith(' '+str.toLowerCase())){
                            cleansedName = cleansedName.substring(0,cleansedName.length()-str.length());
                            cleansedName = cleansedName.trim();
                            flag = false;
                        }
                    }
                    //Debug.log('cleansedName----'+cleansedName);
                    if(flag){
                        break;
                    }
                }
                cleansedName = cleansedName.replaceAll('\\s+','');              
                return cleansedName;
            }
            return null;
            
        }catch(Exception ex){
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('AccountServices','createCleansedAccAndUnomyName',name, ex)
            );
            throw new AccountServicesException(ex.getMessage()); 
        }
    }
    
    /****************************************************************************************************************************
    Author 				: Shivprasad Patil
    Description  		: This method wheather boolean value is valid or not
    Created Date		: 05,April 2018
    Last Modified By 	: 
    Last Modified Date  : 
*****************************************************************************************************************************/
    public static Boolean checkIsValidBoolean(Object flag,String fieldName){  
        try{
            Debug.log('In checkIsValidBoolean==');
            String strFlag;
            Debug.log('flag=='+flag);
            if(flag != null){
                strFlag = String.valueOf(flag).toLowerCase();                               
            } 
            Debug.log('strFlag=='+strFlag);
            Boolean result = (strFlag=='true' || strFlag=='1') ? True : ( (strFlag=='false' || strFlag=='0' || strFlag==null || strFlag=='') ? False : null );
             Debug.log('result=='+result);
            if(result==null)
                throw new AccountServicesException('Invalid boolean or String: '+strFlag+' of Field '+fieldName+' ');
            return result;
        }catch(Exception ex){
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('AccountServices','createCleansedAccAndUnomyName:Flag Paramater',String.valueOf(flag), ex)
            );
            throw new AccountServicesException(ex.getMessage()); 
        }
    }
    public class AccountCleansingSetting {
        public String[] starts_With;
        public String[] ends_With;
        public String specialCharacters;        
    }  
}