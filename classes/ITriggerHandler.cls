/************************************************************************************************************************************
    Author 		: 	Hemanshu Shah
    Description : 	This is an abstract class used in all triggers.

    History		:
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE				AUTHOR					DETAIL
	1			15 January 2018		Hemanshu Shah			Initial Developement
**************************************************************************************************************************************/
public abstract class ITriggerHandler {
    String objectName;
    
    public ITriggerHandler(String strObjectName){
        Debug.log(strObjectName+'--LIMIT---'+Limits.getQueries());
        objectName = strObjectName;
    }

    /************************************************************************************************************************************
		Author 				: 	Hemanshu Shah
		Description 		: 	This virtual method need to override in handler of respective trigger for before insert event.
		Created Date		:	15 January 2018
	**************************************************************************************************************************************/
    public virtual void BeforeInsert(List<SObject> listNewItems){}
	/************************************************************************************************************************************
		Author 				: 	Hemanshu Shah
		Description 		: 	This virtual method need to override in handler of respective trigger for before update event.
		Created Date		:	15 January 2018
	**************************************************************************************************************************************/
    public virtual void BeforeUpdate(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems){}
    /************************************************************************************************************************************
		Author 				: 	Hemanshu Shah
		Description 		: 	This virtual method need to override in handler of respective trigger for after insert event.
		Created Date		:	15 January 2018
	**************************************************************************************************************************************/
    public virtual void AfterInsert(List<SObject> listNewItems, Map<Id, SObject> mapNewItems){}
    /************************************************************************************************************************************
		Author 				: 	Hemanshu Shah
		Description 		: 	This virtual method need to override in handler of respective trigger for after update event.
		Created Date		:	15 January 2018
	**************************************************************************************************************************************/
    public virtual void AfterUpdate(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems){}
	/************************************************************************************************************************************
		Author 				: 	Hemanshu Shah
		Description 		: 	This virtual method need to override in handler of respective trigger for before delete event.
		Created Date		:	15 January 2018
	**************************************************************************************************************************************/
    public virtual void BeforeDelete(List<SObject> listOldItems, Map<Id, SObject> mapOldItems){}
    /************************************************************************************************************************************
		Author 				: 	Hemanshu Shah
		Description 		: 	This virtual method need to override in handler of respective trigger for after delete event.
		Created Date		:	15 January 2018
	**************************************************************************************************************************************/
    public virtual void AfterDelete(List<SObject> listOldItems, Map<Id, SObject> mapOldItems){}
    /************************************************************************************************************************************
		Author 				: 	Hemanshu Shah
		Description 		: 	This virtual method need to override in handler of respective trigger for after undelete event.
		Created Date		:	15 January 2018
	**************************************************************************************************************************************/
    public virtual void AfterUndelete(List<SObject> listOldItems, Map<Id, SObject> mapOldItems){}
}