public class EditAllContacts {

    public Account acc {get; set;} //Variable to hold all contact Record//
    public Contact con {get; set;}
    public List<Contact> ConList {get; set;} //Variable to hold all contacts edited//
    public List<Contact> DelList {get; set;} //Variable to hold all contacts deleted//
    public Id AccId {get; set;}
    public Integer RowIndex {get; set;}
    public Id RowId {get; set;}

    public EditAllContacts(){
    con = new Contact();
    ConList = new List<Contact>();
    AccId = ApexPages.CurrentPage().getParameters().get('Id');
    
    acc = [select id, ownerid, name, type, phone from Account where id =: AccId ];
    conList = [select id, FirstName, LastName, phone, Email, salary__c from Contact where AccountId =: AccId];
  
    }

      //Update Method//    
    public PageReference UpdateRecord() {
    Contact cont = new Contact();
    cont.AccountId=AccId;
    Update ConList;
    PageReference Pnext = new PageReference('/'+AccId);
    return Pnext;
    }
      //Cancel Method//        
    public PageReference CancelRecord() {
    PageReference Pnext = new PageReference('/001/o');
    pNext.setRedirect(true);
    return Pnext;
    }
       //Remove Method//
    public PageReference RemoveRow() {
    ConList.remove(RowIndex-1);

        return null;

    }
}