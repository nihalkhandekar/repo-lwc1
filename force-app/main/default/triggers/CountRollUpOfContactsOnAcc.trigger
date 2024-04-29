trigger CountRollUpOfContactsOnAcc on Contact (after insert, after update, after delete, after undelete) {
List<Account> AccountsToBeUpdated = new List<Account>();
Set<Id> AccIdSet = new Set<Id> ();
    if(trigger.isAfter){
        if(trigger.isInsert || trigger.isUndelete){
            for(Contact con : trigger.new){
                if(con.AccountId != null){
                  AccIdSet.add(con.AccountId);  
                }
            }
        }
        else if(trigger.isDelete){
            for(Contact con : trigger.old){
                if(con.AccountId != null){
                  AccIdSet.add(con.AccountId);  
                }
            }    
        }
        else if(trigger.isUpdate){
            for(Contact con : trigger.new){
                if(con.AccountId != null && trigger.oldMap.get(con.Id).AccountId != con.AccountId ){
                 AccIdSet.add(con.AccountId) ; //new contact id  
                } 
                 AccIdSet.add(trigger.oldMap.get(con.Id).AccountId); //old contact id
            }
        }
        
        List<Account> AccConList = [select id, Count__c, (select id from Contacts) from Account where id =: AccIdSet];
        
        for(Account acc : AccConList){
            acc.Count__c = acc.Contacts.size();
            AccountsToBeUpdated.add(acc); 
        }
        update AccountsToBeUpdated;
    }
}