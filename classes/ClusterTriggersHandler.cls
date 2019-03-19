/************************************************************************************************************************************
    Author 		: 	Milanjeet	
    Description : 	This class contain buisness logic of cluster trigger.

    History:
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE				AUTHOR					DETAIL
	1			09 November 2017	Milanjeet				Initial Developement
**************************************************************************************************************************************/
public class ClusterTriggersHandler extends ITriggerHandler{
    public ClusterTriggersHandler(){ 
        super('Cluster__c'); 
    }
    /************************************************************************************************************************************
        Author 				: 	Milanjeet
        Description 		: 	This method overrides after update method from ITriggerHander which will control the execution flow.
        Created Date		:	09 November 2017
	**************************************************************************************************************************************/
    public override void AfterUpdate(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems){
        updateClusterInfoOnBuilding(listNewItems, mapNewItems, listOldItems, mapOldItems);
    }  
    /************************************************************************************************************************************
        Author 				: 	Milanjeet
        Description 		: 	This method will update cluster information on building after cluster update.
		Created Date		: 	09 November 2017 
		Issue No.			: 	ST-1653
	**************************************************************************************************************************************/
    public static void updateClusterInfoOnBuilding(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems){
        if(TriggerSettings.mappedField.Cluster_UpdateClusterInfoOnBuilding){
            Set<Id> setClusterIds = new Set<Id>();   
            try{
                for(Cluster__c cluster:(List<Cluster__c>)listNewItems){
                    if((cluster.Name==null || !cluster.Name.equalsIgnoreCase(String.valueOf(mapOldItems.get(cluster.Id).get('Name')))) || cluster.Cluster_Sales_Manager__c!=mapOldItems.get(cluster.Id).get('Cluster_Sales_Manager__c') || cluster.Sales_Lead__c!=mapOldItems.get(cluster.Id).get('Sales_Lead__c')){
                        setClusterIds.add(cluster.Id);
                    }
                }
                if(setClusterIds.size()>0){
                    List<Building__c> lstBuildings = [Select Id,Cluster__r.Name,Cluster__r.Cluster_Sales_Manager__r.Name,Cluster__r.Cluster_Sales_Manager__r.Email,Cluster__r.Sales_Lead__r.Name,Cluster__r.Sales_Lead__r.Email From Building__c Where Cluster__c IN:setClusterIds];
                    List<Building__c> lstBuildingsToUpdate = new List<Building__c>();
                    for(Building__c bldng:lstBuildings){
                        Building__c b = new Building__c(Id=bldng.Id);
                        b.Cluster_Name__c = bldng.Cluster__r.Name;
                        b.Cluster_Sales_Manager_Name__c = bldng.Cluster__r.Cluster_Sales_Manager__r!=null?bldng.Cluster__r.Cluster_Sales_Manager__r.Name:'';
                        b.Cluster_Sales_Lead_Name__c = bldng.Cluster__r.Sales_Lead__r!=null?bldng.Cluster__r.Sales_Lead__r.Name:'';
                        b.Cluster_Sales_Manager_Email__c = bldng.Cluster__r.Cluster_Sales_Manager__r!=null?bldng.Cluster__r.Cluster_Sales_Manager__r.Email:'';
                        b.Cluster_Sales_Lead_Email__c = bldng.Cluster__r.Sales_Lead__r!=null?bldng.Cluster__r.Sales_Lead__r.Email:'';
                        lstBuildingsToUpdate.add(b);
                    }
                    update lstBuildingsToUpdate;
                }  
            }catch(Exception pEx) { 
                List<Id> ids = New List<Id>();
                if(mapOldItems.keyset()!=null)
                    ids.addAll(mapOldItems.keyset());
                new ApexDebugLog().createLog( 
                    new ApexDebugLog.Error('ClusterTriggersHandler','updateClusterInfoOnBuilding',String.join(ids,','),pEx)
                );
                throw new ClusterTriggersHandlerException(pEx.getMessage());
            }        
        }
    }
    /************************************************************************************************************************************
        Author 				: 	Milanjeet
        Description 		: 	This is a custom exception class inherites exception class to handle exception.
		Created Date		: 	09 November 2017 
	**************************************************************************************************************************************/
    public class ClusterTriggersHandlerException extends Exception{}
}