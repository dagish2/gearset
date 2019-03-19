global class ConfigureSandbox implements SandboxPostCopy { 
    global void runApexClass(SandboxContext context) {
        createUsers(context.sandboxName());
    }
    global static void createUsers(String sandboxName) {
        SandboxWrapper objSandboxWrapper = (SandboxWrapper)JSON.deserialize(Settings.get('SandboxConfiguration').Data__c, SandboxWrapper.class);
        if(objSandboxWrapper.sandboxes.containsKey(sandboxName)){
            Map<String,Map<String,String>> mapUsers = objSandboxWrapper.users;
            Map<String,List<String>> mapSandboxes = objSandboxWrapper.sandboxes;
            List<String> lstUsersName = mapSandboxes.get(sandboxName);
            List<User> lstUsers = new List<User>();
            Profile objProfile = [Select Id,Name From Profile Where Name = 'WeWork System Administrator'];
            UserRole objRole = [Select Id,Name From UserRole Where Name = 'Admin'];
            for(String strUserName : lstUsersName){
                if(mapUsers.containsKey(strUserName)){
                    Map<String,String> objUserTemplate = mapUsers.get(strUserName);
                    User objUser = new User();
                    objUser.FirstName = objUserTemplate.get('name').split(' ')[0];
                    objUser.LastName = objUserTemplate.get('name').split(' ')[1];
                    objUser.Email = objUserTemplate.get('email');
                    objUser.Username = objUserTemplate.get('email').split('@')[0] + '@wework.com.' + sandboxName;
                    objUser.ProfileId = objProfile.Id;
                    objUser.UserRoleId = objRole.Id;
                    objUser.UserPermissionsMarketingUser = true;
                    objUser.EmailEncodingKey = 'ISO-8859-1';
                    objUser.LanguageLocaleKey = 'en_US';
                    objUser.LocaleSidKey = 'en_US';
                    objUser.TimeZoneSidKey = 'America/Los_Angeles';
                    objUser.alias = objUser.FirstName.substring(0,0) + '' + objUser.LastName.substring(0, 3);
                    objUser.CommunityNickname = objUserTemplate.get('email').split('@')[0];
                    objUser.UserPermissionsSupportUser = true;                   
                    lstUsers.add(objUser);
                }
            }
            if(lstUsers.size()>0){
                Database.DMLOptions dlo = new Database.DMLOptions();
                dlo.EmailHeader.triggerUserEmail = true;
                Database.insert(lstUsers, dlo);
            }
        }
    }
    
    global static void resetPassword(String sandboxName) {
        SandboxWrapper objSandboxWrapper = (SandboxWrapper)JSON.deserialize(Settings.get('SandboxConfiguration').Data__c, SandboxWrapper.class);
        if(objSandboxWrapper.sandboxes.containsKey(sandboxName)){
            Map<String,Map<String,String>> mapUsers = objSandboxWrapper.users;
            Map<String,List<String>> mapSandboxes = objSandboxWrapper.sandboxes;
            List<String> lstUsersName = mapSandboxes.get(sandboxName);
            List<String> lstUserEmails = new List<String>();
            for(String strUserName : lstUsersName){
                if(mapUsers.containsKey(strUserName)){
                    Map<String,String> objUserTemplate = mapUsers.get(strUserName);
                    lstUserEmails.add(objUserTemplate.get('email'));
                }
            }
            if(lstUserEmails.size()>0){
                List<User> lstUsers = [Select Id From User Where Email IN : lstUserEmails];
                for(User objUser : lstUsers){
                    System.resetPassword(objUser.Id, true);
                }
            }
        }
    }
    
    global class SandboxWrapper {
        global Map<String,Map<String,String>> users{get;set;}
        global Map<String,List<String>> sandboxes{get;set;}
    }
}