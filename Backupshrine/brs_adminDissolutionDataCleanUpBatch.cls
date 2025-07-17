global class brs_adminDissolutionDataCleanUpBatch implements Database.Batchable<sObject>,Database.Stateful{
    //BRS-7964
    public List<Id> listFilingIds=new List<Id>();
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //Querying 
        String query = 'Select Id,Filing_Type__c,Type__c,Account__r.Status__c, Account__r.Sub_status__c,Status__c from Business_Filing__c where Type__c = \'Administrative Dissolution\' AND Filing_Type__c=NULL AND Status__c=\'Approved\'';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Business_Filing__c> scope) {
        List<Id> currentBatchSuccessIds = new List<Id>();
        List<Error_Log__c> errorFilingLst = new List<Error_Log__c>();
        List<Business_Filing__c> filingsToUpdate=new List<Business_Filing__c>();
        //Process Filing Type
        for(Business_Filing__c bf:scope){            
            if(bf.Account__r.Status__c == 'Revoked' || bf.Account__r.Status__c == 'Forfeited'){
                bf.Filing_Type__c = System.Label.Certificate_of_Dissolution_Revocation_Label;  
            }
            else if(bf.Account__r.Sub_status__c == 'Admin Dissolution Initiated'){
                bf.Filing_Type__c = System.Label.Notice_of_Intent_to_Dissolve_Revoke_Label;   
            }
            filingsToUpdate.add(bf);
        }
              
        Database.SaveResult[] bfresult=Database.update(filingsToUpdate, false);
        for(Database.SaveResult res : bfresult){
            if (res.isSuccess()) {
                currentBatchSuccessIds.add(res.getId());//Add Success Ids
            }else {
                String error='ERROR: Id:'+res.getId();
                for(Database.Error err : res.getErrors()){
                    error=error+' '+err.getStatusCode() + ': ' + err.getMessage();
                }
                Error_Log__c err = BOS_Utility.errorRecordLogger('brs_adminDissolutionDataCleanUpBatch', 'Execute', 'Business_Filing__c', res.getId(), BOS_Utility.sSeverity, null, error);
                errorFilingLst.add(err);
            }
        }
        if(!errorFilingLst.IsEmpty()){
            BOS_Utility.insertErrorRecordLst(errorFilingLst);
        }      
        
        //Delete Attachments to Records
        List<Attachment> linkedAttachments = [SELECT Id,ParentId FROM Attachment WHERE ParentId in: currentBatchSuccessIds];
        System.debug('###2 Delete Batch Attachment'+linkedAttachments);
        if(!linkedAttachments.isEmpty()){
            delete linkedAttachments;
        }
        
        //Added Records Ids to further process
        listFilingIds.addAll(currentBatchSuccessIds);
        
    }
    global void finish(Database.BatchableContext BC) { 
        //Create New Nintex Attachments
        System.debug('###3 Create Attachments'+listFilingIds);
        System.debug('###3.1 Create Attachments Size'+listFilingIds.size());
         if(!listFilingIds.IsEmpty() && !test.isRunningTest()){
        Database.executeBatch(new NintexBatchGeneration(listFilingIds, UCCFilingAcknowledgement.Operation.ADMIN_DISSOLUTION), 10);
         }
        //Files will get created automatically from attachment trigger
    }
}