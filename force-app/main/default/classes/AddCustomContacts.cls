public class AddCustomContacts {
public string CusId {get; set;}
public Contact con {get; set;}
public List<Contact> ConList {get; set;}
//public List<Contact> DeleteList;
public integer SelectRowIndex {get; set;}
public account act{get;set;}

        //Constructor//    
    public AddCustomContacts() {
    act=new account();
    CusId = ApexPages.CurrentPage().GetParameters().get('Id');
    act=[select id , name, type, industry from account where id =:CusId];
    //to check wheather the id is coming or not we can print it and check debug log when constructor loads after button clicks//
    //system.debug('values are:'+CusId);//
    ConList = new List<Contact>();
    //DeleteList = new List<Contact>();
    /*con = new Contact();
    ConList.add(con);
    con.AccountId=CusId;
    con.lastname=act.name;*/
    }
       //Add Method//    
    public PageReference AddRecord() {
    Contact cont = new Contact();
    cont.AccountId=act.id;
    cont.lastname=act.name;
    ConList.add(cont);
    return null;
    }
      //Save Method//    
    public PageReference SaveRecord() {
    insert ConList;
    PageReference Pnext = new PageReference('/'+CusId);
    return Pnext;
    }
      //Cancel Method//        
    public PageReference CancelRecord() {
    PageReference Pnext = new PageReference('/apex/AddCustomContacts');
    pNext.setRedirect(true);
    return Pnext;
    }
      //Remove Method//    
    public void RemoveRow() {
    //DeleteList.add(ConList[SelectRowIndex]);//
    ConList.remove(SelectRowIndex);
    }
}