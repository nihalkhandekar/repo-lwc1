trigger RollUpOppAmountOnAccount on Opportunity (after insert, after update, after delete, after undelete) {
    List<Account> AccToBeUpdated = new List<Account>();
    Set<Id> AccIdSet = new Set<Id>();
    if(trigger.isAfter){
        if(trigger.isInsert || trigger.isUndelete){
            for(Opportunity opp : trigger.new){
                if(opp.AccountId != null){
                 AccIdSet.add(opp.AccountId);   
                }
            }
        }
        else if (trigger.isUpdate){
            for(Opportunity opp : trigger.new){
                if(opp.AccountId != null && trigger.OldMap.get(opp.id).AccountId != opp.AccountId){  //Condition//
                 AccIdSet.add(opp.AccountId);                                                 
                }
                AccIdSet.add(trigger.OldMap.get(opp.id).AccountId);                  
            }
        }
        else if (trigger.isDelete){
            for(Opportunity opp : trigger.old){
                if(opp.AccountId != null){
                 AccIdSet.add(opp.AccountId);   
                }
            }
        }
        List<Account> AccOppList = [select id, name, Total_Amount_Opportunity__c, (select id, name, Amount from Opportunities) from Account where id =: AccIdSet ];
        for(Account acc : AccOppList){
            Double AmountValue = 0;
            for(Opportunity opp : acc.Opportunities){
                if(opp.Amount != 0)    // Imp to avoid null pointer exception//
               AmountValue += opp.Amount; 
            }
            acc.Total_Amount_Opportunity__c = AmountValue;
            AccToBeUpdated.add(acc);
        }
        Update AccToBeUpdated;
    }
}