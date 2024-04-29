public class InvokableClass {
@invocableMethod 
    public static void myMethod(list<id> InvokedAndUpdated){ //InvokedAndUpdated--->> Variable written inside method will be mapped with account id in process builder//
        list<Account> accToBeUpdated = new list<Account>();
        //Query
        list<Account> accListQuery = [select id, name from Account where id IN:InvokedAndUpdated];
        
        for(Account acc:accListQuery){
            acc.Name = acc.Name + '007';
            acc.type = 'Customer - Direct';
            accToBeUpdated.add(acc);
        }
        if(accToBeUpdated.size()>0)
            update accToBeUpdated;
    }  
}