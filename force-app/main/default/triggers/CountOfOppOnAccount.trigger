trigger CountOfOppOnAccount on Opportunity (after insert, after update, after delete, after undelete) {
    List<Account> AccToBeUpdatedList = new List<Account>();
    Set<Id> OppIdSet = new Set<Id>();
        if(trigger.isAfter){
        if(trigger.isInsert || Trigger.isUndelete){
            for(Opportunity Opp : Trigger.new){
                if(Opp.AccountId != null)
                OppIdSet.add(Opp.AccountId); 
            } 
         }
        if(trigger.isDelete){
            for(Opportunity Opp : Trigger.old){
                if(Opp.AccountId != null)
                OppIdSet.add(Opp.AccountId); 
            } 
         }            
        if(trigger.isUpdate){
            for(Opportunity Opp : Trigger.new){
                if(Opp.AccountId != null && trigger.oldMap.get(Opp.Id).AccountId != Opp.AccountId){
                    OppIdSet.add(trigger.oldMap.get(Opp.Id).AccountId);}
                    OppIdSet.add(Opp.AccountId);
           }   
        }
       list<Account> accList = [select id, name, Count_of_Opportunities__c, (select id, name, Amount, StageName, AccountId from Opportunities where StageName = 'Closed Won' AND Amount > 5000 ) from Account where id =: OppIdSet];     
            for(Account acc : accList){
                acc.Count_of_Opportunities__c = acc.Opportunities.size();
                AccToBeUpdatedList.add(acc);
            }
    }
    update AccToBeUpdatedList;
}