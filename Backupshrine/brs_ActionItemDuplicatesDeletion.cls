public class brs_ActionItemDuplicatesDeletion implements Database.Batchable<sObject>,Schedulable {
   
        
    public Database.QueryLocator start(Database.BatchableContext BC){
        
        return Database.getQueryLocator('Select id,name,Business_Filing__c,Due_Date__c from Action_Item__c where Status__c =\'Open\'and Business_Filing__c =null');
    } 
    public void execute(Database.BatchableContext BC, List<Action_Item__c> lstScope) {
        List<Action_Item__c> actionItemDeletionList=new List<Action_Item__c>();
        for(Action_Item__c ac:lstScope)
        {
            actionItemDeletionList.add(ac);
        }
        if(!actionItemDeletionList.isEmpty())
        {
            delete actionItemDeletionList;
        }
        
    } 
    public void finish(Database.BatchableContext BC) {
    } 
    
    /********************************************************************************************
        METHOD NAME    : execute
        DESCRIPTION    : Batch execute method
        RETURN TYPE    : void
        PARAMETER      : SchedulableContext
    ********************************************************************************************/
    public void execute(SchedulableContext sc){
        Database.executeBatch(new brs_ActionItemDuplicatesDeletion(),200);
    }
}