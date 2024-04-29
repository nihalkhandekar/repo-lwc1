trigger ContactDuplicatePhone on Contact (before insert, before update) {
 List<Contact> ConList = new List<Contact>();
    ConList = [select id, name, phone from Contact];
    
    for(Contact c:Trigger.new){
        for(Contact con : ConList){
            if(c.Phone == con.Phone){
                c.Phone.addError('Duplicate Phone no.');
            }
        }
        
    }
}