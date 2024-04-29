//Prevent deleting a record if it has opportunity whose amount is greater than 2000//
trigger PreventAccDeletionWhenOppAmountMoreThn2000 on Account (before delete) {
    if(trigger.isDelete && trigger.isBefore){
        List<Account> AccOppList = [select id, name, (select id, name, AccountId, Amount from Opportunities) from Account];
        Set<id> AccIdSet = new Set<id> ();
        for(Account acc : AccOppList){
            for(Opportunity op : acc.Opportunities){
                if(op.Amount >= 2000)
                AccIdSet.add(op.AccountId);
            }
        }    
        for(Account ac : Trigger.old){
            if(AccIdSet.contains(ac.Id) ){
               ac.addError('You Cannot delete an Account whose Opportunity Amount is >= 2000 '); 
            }
        }
    }
}