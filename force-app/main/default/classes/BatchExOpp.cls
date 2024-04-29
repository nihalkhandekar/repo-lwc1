global class BatchExOpp implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
         
        String query = 'SELECT Id, Name, StageName, Amount FROM Opportunity';
        return Database.getQueryLocator(query);
    }
     
    global void execute(Database.BatchableContext BC, List<Opportunity> oppList) {
        
        // process each batch of records default size is 200
// process each batch of records default size is 200
        for(Opportunity opp : oppList) {        
            // Update the Account Name
            if(opp.Amount > 5000){ 
            opp.StageName = 'Needs Analysis';
            }
        }
        try {
            // Update the Account Record
            update oppList;
         //system.debug(oppList);
        } catch(Exception e) {
            System.debug(e);
        }
         
    }   
     
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations
    }
}