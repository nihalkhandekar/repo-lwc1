trigger DupNumForConError on Contact (before insert) {
    List<Contact> conList = [select id, Phone, MobilePhone from Contact];
    for(Contact con : trigger.new){
        for(Contact c : conList){
            if(c.Phone != null && con.MobilePhone == c.Phone){               
               con.MobilePhone.addError('Same number exists in the database. Duplicate number can’t be entered in the system.'); 
            } 
        }
    }
}