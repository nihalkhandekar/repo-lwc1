//When A New Contact is Created for an existing Account then set the Contact otherPhone as Account Phone..//
trigger ContactPhoneAsAccountPhone on Contact (before insert) {
    Set<Id> AccIdSet = new Set<Id>();
    for(Contact con : Trigger.new){
        if(con.AccountId != null || String.isNotBlank(con.AccountId)){
            AccIdSet.add(con.AccountId);
        }        
    //}
    if(AccIdSet.size() > 0){
        Map<Id, Account> AccMap = new Map<Id, Account>([select id, name, phone from Account where id IN : AccIdSet]);
        
      //  for(Contact con : Trigger.new){
            if(con.AccountId != null && AccMap.containsKey(con.AccountId)){
                if(AccMap.get(con.AccountId).Phone != null){
                con.OtherPhone = AccMap.get(con.AccountId).Phone;
                }
            }
        }         
    }
    /*List<Contact> conList = new List<Contact>([select id, AccountId, LastName, OtherPhone, Account.Phone from Contact where AccountId =: AccIdSet]);
    
    for(Contact con : conList){
     if(con.AccountId != null && con.Account.Phone != null){
        con.OtherPhone = con.Account.Phone;
     }
    }*/
}