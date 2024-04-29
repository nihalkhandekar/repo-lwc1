public class Task3 {

public Account acc{get; set;}  //getter & setter//

        //**Constructor**//
    public Task3(){    
    acc = new Account(); //initiating the Account Obj to attend the account obj properties//
    acc.name='Nihal'; //we can add predefined names by adding them in the constructor//
       } 
       //**Method**//
    public PageReference CustomSave(){
    insert acc;//id created when inserted//
    PageReference pNext = new PageReference('/apex/Task3?id='+acc.id); 
    pNext.setRedirect(true); //to refresh the page//
    return pNext;
    }
    public PageReference CustomCancel(){
    PageReference pNext = new PageReference('/001/o');
    pNext.setRedirect(true); //to refresh the page//
    return pNext;
    }
}