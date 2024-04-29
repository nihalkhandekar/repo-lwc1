public class RecTriggerCon {
    public static boolean flag = true; 
    public static void onInsertCon (List<Contact> ConList){
        List<Contact> LstOfContact = new   List<Contact>();      
        for(Contact con : ConList){
            Contact c = new Contact();
            c.FirstName = 'test22';
            c.LastName = 'second22';
            LstOfContact.add(c);
        }
        system.debug(LstOfContact);
        insert LstOfContact;
    }
       
 }