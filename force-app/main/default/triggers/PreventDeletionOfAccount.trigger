trigger PreventDeletionOfAccount on Account (before delete) {
    if(trigger.isDelete && trigger.isBefore){
        List<Account> AccOppList = [select id, (select id,AccountId from Opportunities) from Account];
        Set<id> AccIdSet = new Set<id> ();
       for(Account acc: AccOppList){
           for(Opportunity op : acc.Opportunities){
               if(op.AccountId != null){
                AccIdSet.add(op.AccountId);   
               }
               system.debug(AccIdSet);
           }
           for(Account ac : trigger.old){
               if(AccIdSet != null){
                ac.addError('Account cannot be deleted if it has opportunity'); 
               }
           }
      }   
    }
}