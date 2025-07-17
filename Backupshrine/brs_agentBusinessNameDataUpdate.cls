global class brs_agentBusinessNameDataUpdate implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'Select Id,Name,Type__c,Business_Name__c,Agent_Account_ID__c,Agent_Account_ID__r.Name from Agent__c where (Type__c=\'Business\' AND Business_Name__c=NULL AND Agent_Account_ID__c !=NULL) OR (Type__c=\'Individual\' AND Agent_Account_ID__c !=NULL)';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Agent__c> scope) {
        List<Error_Log__c> errorFilingLst = new List<Error_Log__c>();
        List<Agent__c> aglistToUpdate=new List<Agent__c>();
        for (Agent__c ag:scope){
            if(ag.Type__c == 'Business'){
                ag.Business_Name__c=ag.Agent_Account_ID__r.Name;
            }else if(ag.Type__c == 'Individual'){
                ag.Agent_Account_ID__c=null;
            }
            aglistToUpdate.add(ag);
        }              
        
        Database.SaveResult[] agresult=Database.update(aglistToUpdate, false);
        for(Database.SaveResult res : agresult){
            if (!res.isSuccess()) {
                String error='ERROR: Id:'+res.getId();
                for(Database.Error err : res.getErrors()){
                    error=error+' '+err.getStatusCode() + ': ' + err.getMessage();
                }
                Error_Log__c err = BOS_Utility.errorRecordLogger('brs_agentBusinessNameDataUpdate', 'Updating Agent', 'Agent', res.getId(), BOS_Utility.sSeverity, null, error);
                errorFilingLst.add(err);
            }
        }
        
        if(!errorFilingLst.IsEmpty()){
            BOS_Utility.insertErrorRecordLst(errorFilingLst);
        }
    }     
    
    global void finish(Database.BatchableContext BC) { }
}