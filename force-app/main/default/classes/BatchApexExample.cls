global class BatchApexExample implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
         
        String query = 'SELECT Id, Name FROM Account';
        return Database.getQueryLocator(query);
    }
     
    global void execute(Database.BatchableContext BC, List<Account> accList) {
        
        // process each batch of records default size is 200
// process each batch of records default size is 200
        for(Account acc : accList) {        
            // Update the Account Name 
            acc.Name = acc.Name + '++';

        }
        try {
            // Update the Account Record
            update accList;
         //system.debug(accList);
        } catch(Exception e) {
            System.debug(e);
        }
         
    }   
     
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations
    }
}