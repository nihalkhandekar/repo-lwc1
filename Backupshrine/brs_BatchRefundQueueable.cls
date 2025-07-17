public With Sharing class brs_BatchRefundQueueable implements Queueable{
    public Set<Id> filingsToRefund;
    public brs_BatchRefundQueueable(Set<Id> filingIds){
        filingsToRefund = filingIds;
    }
	 public void execute(QueueableContext context) {
        String obj = SchemaUtility.getObjectFromId(new List<Id>(filingsToRefund).get(0)).getName();
        if(obj == 'Business_Filing__c'){
            List<Business_Filing__c> bfilings = [Select Id,Name,Type__c,status__c,Account__c From Business_Filing__c where Id IN:filingsToRefund];
            BusinessFilingTriggerHelper.rejectAccountOnFilingReject(bfilings);
        }
         BusinessFilingTriggerHelper.processBlackthornRefund(filingsToRefund);       
    }
}