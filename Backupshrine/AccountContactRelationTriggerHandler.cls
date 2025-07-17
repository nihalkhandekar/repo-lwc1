/*****************************************************************************************************
 * NAME:  Account trigger
 * DESCRIPTION: Create new action item when new account-contact relationship created
 *  or annual due date changes 
 *
 * MODIFICATION LOG
 * DEVELOPER                         DATE                               DESCRIPTION
 * ----------------------------------------------------------------------------------------------------
 * Shreya Bordia                    15/10/2020                         CTBOS-7031 | Due date changes
 ******************************************************************************************************/
public without sharing class AccountContactRelationTriggerHandler {
    public static void afterInsert(List<AccountContactRelation> newACRList){
     /*   List<Action_Item__c> newActionItems = new List<Action_Item__c>();
		user userdata = [
            SELECT Id, ContactID 
            FROM User 
            WHERE Id =: UserInfo.getUserId() 
            LIMIT 1
        ];
		
        for(Account acc: [
            SELECT Id, Annual_Report_Due_Date__c
            FROM Account 
            WHERE Id IN 
                (
                    SELECT AccountId
                    FROM AccountContactRelation
                    WHERE Id IN :newACRList
                )
                AND RecordType.DeveloperName = :System.Label.ActionItem_AccountRecordType
        ]){        
            newActionItems.add(new Action_Item__c(
                Action_Item_Name__c = System.Label.ActionItem_AnnualReportName,
                Due_Date__c = acc.Annual_Report_Due_Date__c,
                Account__c = acc.Id,
                Status__c = System.Label.ActionItem_StatusOpen,
                Contact__c = userdata.ContactId
            ));
        }
    
        try{
            if(!newActionItems.isEmpty())  {
                insert newActionItems;
            }
        }catch(Exception ex){
            BOS_Utility.ExceptionHandler('AccountContactRelationTriggerHandler','afterInsert', 'Action_Item__c',null, 'High',ex,null);
        } */
    }

    public static void createNewActionItems(Map<Id, sObject> newItems, Map<Id, sObject> oldItems) {
     /*
        Map<Id, Account> mapAccounts = new Map<Id, Account>();
        List<Action_Item__c> listActions = new List<Action_Item__c>();
         Map<Id, Date> actionItemMap = new Map<Id, Date>();
        
List<Action_Item__c> allExistingItems = [Select id ,Account__c,Due_Date__c from Action_Item__c where Account__c in : newItems.keySet()];
      
        for(Action_Item__c item : allExistingItems){
            actionItemMap.put(item.Account__c,item.Due_Date__c);
            
        }
        //1. Where due date has changed
        for(Account newAccount :(List<Account>)newItems.values()) {
            if(System.Label.ACTIVE.equalsIgnoreCase(newAccount.Status__c)
                && newAccount.Annual_Report_Due_Date__c != null
                &&  oldItems.get(newAccount.Id).get('Annual_Report_Due_Date__c') != newAccount.Annual_Report_Due_Date__c
            ) {
                mapAccounts.put(newAccount.Id, newAccount);   
            }
        }
        
        //2. Get related contacts & AI
            
        for(Account account :[
            SELECT Id,Annual_Report_Due_Date__c ,
                (
                    SELECT ContactId
                    FROM AccountContactRelations LIMIT :BOS_Utility.getAvailableQueryLimit() 
                ),
                (
                    SELECT Id, Status__c, Notification_Status__c
                    FROM Action_Items__r
                    WHERE Status__c = :System.Label.ActionItem_StatusOpen
                        AND Action_Item_Name__c = :System.Label.ActionItem_AnnualReportName
                )
            FROM Account
            WHERE Id IN :mapAccounts.keySet()
                AND RecordType.Name = :System.Label.ActionItem_AccountRecordType
        ]) 
        
        {
            if( Schema.SObjectType.Action_Item__c.isAccessible()) {  
            //i. Old Action Items
            for(Action_Item__c oldAI :account.Action_Items__r) {
                listActions.add(new Action_Item__c(
                    Id = oldAI.Id,
                    Notification_Status__c = System.Label.Action_Item_Status_Sent,
                    Status__c = System.Label.TASK_STATUS 
                ));
            }

            //ii. New Action Items
            for(AccountContactRelation relation :account.AccountContactRelations) {
                
                if(actionItemMap.get(account.id) != account.Annual_Report_Due_Date__c){
                listActions.add(new Action_Item__c(
                    Action_Item_Name__c = System.Label.ActionItem_AnnualReportName,
                    Account__c = account.Id,
                    Contact__c = relation.ContactId,
                    Due_Date__c = mapAccounts.get(account.Id).Annual_Report_Due_Date__c, //New value isnt committed to DB yet
                    Status__c = System.Label.ActionItem_StatusOpen
                ));
                }
            }
        }
        }

        //3. Update to completed the old ones, insert new ones for this year
        if(!listActions.isEmpty()) {
            upsert listActions;
        }
        */
    }
}