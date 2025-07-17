public class brs_MarkFilingDataFix implements Database.Batchable<sObject>,Database.Stateful{
    public Set<Id> filingsToUpdate = new Set<Id>();
    public Boolean getSize;
    public brs_MarkFilingDataFix(Boolean getSize){
        this.getSize = getSize;
    }
    public Database.QueryLocator start(Database.BatchableContext BC) {        
        Id RecordTypeId = Schema.SObjectType.Mark_Filing__c.getRecordTypeInfosByName().get('Registration').getRecordTypeId();
        String q = 'Select Id,Name,Class_of_Goods_Service__c,Mark__c,Mark__r.Class_of_Goods_Service__c from Mark_Filing__c where RecordTypeId!=\''+RecordTypeId+'\' AND createdBy.Name!=\'Data Admin\' AND Mark__c!=null AND Mark__r.Class_of_Goods_Service__c!=null AND Class_of_Goods_Service__c=\'Chemicals\' LIMIT 50000';
        return Database.getQueryLocator(q);
    }
    public void execute(Database.BatchableContext BC, List<Mark_Filing__c> scope) {
        List<Error_Log__c> errorFilingLst = new List<Error_Log__c>();
        Set<Id> mfilingsIds = new Set<Id>();
        List<Mark_Filing__c> mfilings = new List<Mark_Filing__c>();
        for(Mark_Filing__c mfile:scope){
            if(mfile.mark__r.Class_of_Goods_Service__c != mfile.Class_of_Goods_Service__c && mfile.Class_of_Goods_Service__c=='Chemicals'){
                mfile.Class_of_Goods_Service__c = mfile.mark__r.Class_of_Goods_Service__c;
                mfilings.add(mfile);
                mfilingsIds.add(mfile.Id);                    
            }         
        }
        if(!getSize){          
            Database.SaveResult[] agresult=Database.update(mfilings, false);
            for(Database.SaveResult res : agresult){
                if (!res.isSuccess()) {
                    String error='ERROR: Id:'+res.getId();
                    for(Database.Error err : res.getErrors()){
                        error=error+' '+err.getStatusCode() + ': ' + err.getMessage();
                    }
                    Error_Log__c err = BOS_Utility.errorRecordLogger('brs_MarkFilingDataFix', 'execute', 'Mark_Filing__c', res.getId(), BOS_Utility.sSeverity, null, error);
                    errorFilingLst.add(err);
                }
            }
            
            if(!errorFilingLst.IsEmpty()){
                BOS_Utility.insertErrorRecordLst(errorFilingLst);
            }
        } 
        filingsToUpdate.addAll(mfilingsIds);
    }
    public void finish(Database.BatchableContext BC) { 
        System.debug('###SAMPLE FILING IDs:'+filingsToUpdate);
        System.debug('###SIZE OF FILING TO UPDATE:'+filingsToUpdate.size());
    }
}