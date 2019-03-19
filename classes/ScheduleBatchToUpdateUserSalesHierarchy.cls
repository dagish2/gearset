/************************************************************************************************************************************
    Author 		: Rupesh Patil
    Description : This batch apex will run every one hour and identify Director of Sales and VP of Sales for each user for which Sales Role is specified and update the user

    History:
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE				AUTHOR					DETAIL
    1			7 Mar 2018			Rupesh Patil			Initial Developement.
	2			12 Mar 2018			Rupesh Patil			Modifications
**************************************************************************************************************************************/
public class ScheduleBatchToUpdateUserSalesHierarchy implements Schedulable, Database.Batchable<sObject> {
    public User GetParentUserWithRole(User userRole, String role){
        Debug.log('UserRole::'+userRole.Sales_Role__c + 'Role::'+role);
        //Validation
        if(userRole.Sales_Role__c == role)
            return userRole;
        if(userRole.Manager.Sales_Role__c == role)
            return userRole.Manager;
        if(userRole.Manager.Manager.Sales_Role__c == role)
            return userRole.Manager.Manager;
        if(userRole.Manager.Manager.Manager.Sales_Role__c == role)
            return userRole.Manager.Manager.Manager;
        if(userRole.Manager.Manager.Manager.Manager.Sales_Role__c == role)
            return userRole.Manager.Manager.Manager.Manager;
        return null;
    }
    public Database.QueryLocator start(Database.BatchableContext bc){
        DateTime dtLastModified = DateTime.now().addHours(-2);      
        String query = 'SELECT Id,Sales_Role__c,Name,Email,Manager.Id,Manager.Email, Manager.Sales_Role__c, Manager.Name,Manager.Manager.Id, Manager.Manager.Sales_Role__c, Manager.Manager.Name,Manager.Manager.Email,Manager.Manager.Manager.Id,Manager.Manager.Manager.Sales_Role__c,Manager.Manager.Manager.Name,Manager.Manager.Manager.Email,Manager.Manager.Manager.Manager.Id,Manager.Manager.Manager.Manager.Sales_Role__c, Manager.Manager.Manager.Manager.Name,Manager.Manager.Manager.Manager.Email FROM User WHERE IsActive = true And Sales_Role__c != \'\' And (LastModifiedDate > :dtLastModified OR VP__c = \'\' )';         
        if(Test.isRunningTest()){
            query += ' LIMIT 50';
        }        
        return Database.getQueryLocator(query);
    }
     public void execute(SchedulableContext sc){
        ScheduleBatchToUpdateUserSalesHierarchy objBatch = new ScheduleBatchToUpdateUserSalesHierarchy(); 
      	database.executebatch(objBatch);
    }
    public void execute(Database.BatchableContext bc,List<User> listRecords){        
        if(listRecords.size() != 0){
            for(User lstUser : listRecords){
                lstUser.Manager_Name__c = lstUser.Manager.Name;
                lstUser.Manager_Email__c = lstUser.Manager.Email;
                User objUserVP = GetParentUserWithRole(lstUser,'VP of Sales');
                User objUserDirector = GetParentUserWithRole(lstUser,'Director of Sales');
                if(objUserVP != null){
                    lstUser.VP__c = objUserVP.Name;
                    lstUser.VP_Email__c = objUserVP.Email;
                }
                if(objUserDirector != null){
                    lstUser.Director__c = objUserDirector.Name;
                    lstUser.Director_Email__c = objUserDirector.Email;
                }
            }
        }        
       	Database.update(listRecords);
    }
    public void finish(Database.BatchableContext bc){
        //finish
    }
    
}