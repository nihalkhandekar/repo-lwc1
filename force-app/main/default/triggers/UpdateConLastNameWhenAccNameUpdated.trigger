trigger UpdateConLastNameWhenAccNameUpdated on Account (After update) {
    List<Contact> ContactsToBeUpdated = new List<Contact>();
    Set<Id> AccIdsWhoseNameIsChanged = new Set<Id> ();
    
    for (Account acc: Trigger.new){
        Account oldAcc = Trigger.oldMap.get(acc.Id);
        
        if(acc.Name != oldAcc.Name){
          AccIdsWhoseNameIsChanged.add(acc.Id);          
        }
    }     
    List<Account> AccWithContacts = new List<Account>([select id, name, (select id, LastName from Contacts) from Account where id IN:AccIdsWhoseNameIsChanged]);
    
    for(Account ac : AccWithContacts){
        for(Contact c : ac.Contacts){
            c.LastName = ac.Name;
            ContactsToBeUpdated.add(c);            
        }
    }
    if(ContactsToBeUpdated.size()>0)
    update ContactsToBeUpdated;

}