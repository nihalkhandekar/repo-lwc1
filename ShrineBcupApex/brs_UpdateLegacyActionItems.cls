public class brs_UpdateLegacyActionItems implements Database.Batchable<sObject>,Database.Stateful {
    public String actionName;
    public Date dateBefore;
    public String queryParam;
    //For Update
    public brs_UpdateLegacyActionItems(String actionName){
        this.actionName = actionName;
    }
    //For Create
    public brs_UpdateLegacyActionItems(String actionName,Date dateBefore){
        this.actionName = actionName;
        this.dateBefore = dateBefore;
    }
    public brs_UpdateLegacyActionItems(String actionName,String queryParam){
        this.actionName = actionName;
        this.queryParam = queryParam;       
    }
    public Database.QueryLocator start(Database.BatchableContext BC) {
        //Querying 
        String query;
        if(actionName == 'update'){
            if(String.isBlank(queryParam)){
                query = 'Select Id,Action_Item_Name__c,Account__r.Status__c,Status__c,Business_Filing__c From Action_Item__c where Status__c=\'Open\' AND Action_Item_Name__c=\'Annual Report\' AND Account__c!=null AND Account__r.Status__c=\'Active\' AND Business_Filing__c=null';
            }else{
                query = queryParam;
            }
        }else if(actionName == 'create'){
            if(String.isBlank(queryParam)){
                query = 'Select Id,Name,Account__r.Status__c,Status__c,Type__c,Account__c,Due_Date__c from Business_Filing__c where (Status__c=\'Due\' OR Status__c=\'Past Due\') AND (Type__c=\'Annual Report\' OR Type__c=\'First Report\') AND Account__c!=null AND Account__r.Status__c=\'Active\' AND CreatedDate <: dateBefore';
            }else{
                query = queryParam;
            }
        }
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        if(actionName == 'update'){
            List<Action_Item__c> actList = (List<Action_Item__c>)scope;
            for(Action_Item__c ait:actList){
                ait.Status__c='Completed';
            }
            update actList;
        }else if(actionName == 'create'){
            List<Business_Filing__c> bfilings = (List<Business_Filing__c>)scope;
            brs_ActionItemUtility.createActionItem(bfilings);
        }
    }
    public void finish(Database.BatchableContext BC) { }
}