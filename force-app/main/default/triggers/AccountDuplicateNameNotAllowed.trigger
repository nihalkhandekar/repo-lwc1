trigger AccountDuplicateNameNotAllowed on Account (before insert,before update) {
    List<Account> acclist = new List<Account>();
    acclist=[SELECT id,Name From Account];
    
    for(Account a:Trigger.New){
        for(Account acc : acclist){
            if(a.Name==acc.Name){
                a.Name.addError('Duplicate Name Found!!');
            }
        }     
    }
}