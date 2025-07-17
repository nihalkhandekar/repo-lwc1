public class BatchTransactionHandler {
    public static void updateBatchTransactionCount(Set<Id> batchIds) {
        Map<Id, Integer> batchTransactionCount = new Map<Id, Integer>();
        
        String individualApplicationPrefix = Schema.getGlobalDescribe().get('IndividualApplication')  ?.getDescribe() ?.getKeyPrefix();
    
        System.debug('IndividualApplication prefix: ' + individualApplicationPrefix);

        Set<Id> validParentIds = new Set<Id>();
        for(RegulatoryTrxnFee trxn : [SELECT ParentRecordId 
                                    FROM RegulatoryTrxnFee 
                                    WHERE SAP_Batch_Look_Up__c IN :batchIds 
                                    AND ParentRecordId != null]) {
            if(String.valueOf(trxn.ParentRecordId).startsWith(individualApplicationPrefix)) {
                validParentIds.add(trxn.ParentRecordId);
            }
        }

        AggregateResult[] results = [
            SELECT SAP_Batch_Look_Up__c, COUNT(Id) 
            FROM RegulatoryTrxnFee
            WHERE SAP_Batch_Look_Up__c IN :batchIds 
            AND ParentRecordId IN :validParentIds
            GROUP BY SAP_Batch_Look_Up__c
        ];

        System.debug('id is '+batchIds);
        System.debug('result is '+results);

        for (AggregateResult ar : results) {
            batchTransactionCount.put((Id)ar.get('SAP_Batch_Look_Up__c'), (Integer)ar.get('expr0'));
        }

        // Prepare list of batches to update
        List<SAP_Batch__c> batchesToUpdate = new List<SAP_Batch__c>();
        for (Id batchId : batchIds) {
            SAP_Batch__c batch = new SAP_Batch__c(Id = batchId);
            batch.SAP_Transacation_Count__c  = batchTransactionCount.containsKey(batchId) ? batchTransactionCount.get(batchId) : 0;
            batchesToUpdate.add(batch);
        }

        // Update batches with new counts
        if (!batchesToUpdate.isEmpty()) {
            update batchesToUpdate;
        }
    }
}