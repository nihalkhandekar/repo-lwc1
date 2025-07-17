public with sharing class BatchFinsysControllerDuplicate {
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getActivityTransactionDataWhenOnlyIdIsAvailable(Id searchParamsJson) {
        Map<String, Object> result = new Map<String, Object>();
        List<Map<String, Object>> dataList = new List<Map<String, Object>>();
    
        try {
            System.debug('batch record Id is '+ searchParamsJson);

            String batchQuery = 'select id,Batch_Name__c, Batch_Date__c, CreatedBy.Name, Batch_Status__c, Transacation_Count__c, Transacation_Amount__c, LastModifiedDate FROM Batch__c WHERE Id=:searchParamsJson LIMIT 1';


            System.debug('### Batch Query: ' + batchQuery);
    
    
            // Execute Batch query
            List<Batch__c> batches = Database.query(batchQuery);
            System.debug('### Retrieved Batches: ' + batches.size());
            System.debug('### Retrieved Batches: ' + batches);

           String feeQuery ='SELECT Id, Payment_Type__c, TotalFeeAmount, CreatedDate, Batch_Look_Up__r.Batch_Name__c, Batch_Look_Up__r.Batch_Date__c, Batch_Look_Up__r.CreatedBy.Name, Batch_Look_Up__r.Batch_Status__c, Batch_Look_Up__r.Transacation_Count__c, Batch_Look_Up__r.Transacation_Amount__c,ParentRecordId, Batch_Look_Up__r.LastModifiedDate FROM RegulatoryTrxnFee WHERE Batch_Look_Up__r.id =:searchParamsJson AND ParentRecordId in (select id from IndividualApplication)';
           System.debug('### Fee Query: ' + feeQuery);

           List<RegulatoryTrxnFee> fees = Database.query(feeQuery);
            System.debug('### Retrieved feeQuery: ' + fees.size());
            System.debug('### Retrieved feeQuery: ' + fees);

    
           
    
            for (RegulatoryTrxnFee fee : fees) {
                System.debug('### Processing Fee Record: ' + fee.Id);
            }

            //

            Map<String, Object> batchData = new Map<String, Object>();


            // Fetch IndividualApplication data for each fee
            Set<Id> parentRecordIds = new Set<Id>();
            for (RegulatoryTrxnFee fee : fees) {
                parentRecordIds.add(fee.ParentRecordId);
            }
            
            // Query IndividualApplication records based on ParentRecordId
            List<IndividualApplication> individualApplications = [SELECT Id, Name,First_Name__c, Last_Name__c  FROM IndividualApplication WHERE Id IN :parentRecordIds WITH SECURITY_ENFORCED];
            
            // Create a map for easy lookup by ParentRecordId
            Map<Id, IndividualApplication> individualApplicationMap = new Map<Id, IndividualApplication>();
            for (IndividualApplication app : individualApplications) {
                individualApplicationMap.put(app.Id, app);
            }
            
            System.debug('individualApplicationMap data is '+individualApplicationMap);

    Decimal totalTrxnAmount=0;

    id RegulatoryTrxnFeeId ;

    for (Batch__c batch : batches) {
        batchData.put('Id', batch.Id);
        batchData.put('BatchCode', batch.Batch_Name__c);
        batchData.put('CreatedDate', batch.Batch_Date__c);
        batchData.put('CreatedBy', batch.CreatedBy.Name);
        batchData.put('BatchStatus', batch.Batch_Status__c);
        batchData.put('TransactionCount', batch.Transacation_Count__c);
        batchData.put('LastModifiedDate', batch.LastModifiedDate);
        
        // Collect Fees under this batch
        List<Map<String, Object>> feeList = new List<Map<String, Object>>();
       // List<Map<String,String>> ActivityData = new List<Map<String,String>>();
        for (RegulatoryTrxnFee fee : fees) {
            Map<String, Object> feeData = new Map<String, Object>();
            feeData.put('Id', fee.Id);
            RegulatoryTrxnFeeId=fee.id;
            feeData.put('PaymentType', fee.Payment_Type__c);
            feeData.put('TotalFeeAmount', formatAmount((Double)fee.TotalFeeAmount));

            totalTrxnAmount +=fee.TotalFeeAmount;

            // Datetime dt = Datetime.valueOf(fee.CreatedDate);
            // String formattedCreatedDate = dt.format('dd/MM/yyyy', 'GMT');

            feeData.put('CreatedDate', fee.CreatedDate.format('MM/dd/yyyy', 'GMT'));
            feeData.put('ParentRecordId', fee.ParentRecordId);
            feeData.put('BatchStatus', fee.Batch_Look_Up__r.Batch_Status__c);
            // feeData.put('TransactionCount', fee.Batch_Look_Up__r.Transacation_Count__c);
            feeData.put('TransactionAmount', fee.Batch_Look_Up__r.Transacation_Amount__c);

            // Add IndividualApplication info if available
            IndividualApplication app = individualApplicationMap.get(fee.ParentRecordId);
            if (app != null) {
                feeData.put('firstName', app.First_Name__c);
                feeData.put('lastName', app.Last_Name__c);
                feeData.put('individualApplicationId', app.id);

            }


            feeList.add(feeData);

        }

        
        batchData.put('TransactionAmount', formatAmount((Double)totalTrxnAmount));

       // batchData.put('ActivityIds', ActivityData);
        batchData.put('Fees', feeList); // Attach fee list to batch data
    }

    result.put('BatchData', batchData);
    
        } catch (Exception e) {
            System.debug('### ERROR: ' + e.getMessage());
            result.put('error', e.getMessage());
        }
    
        System.debug('### END: getActivityTransactionDataWhenOnlyIdIsAvailable');
        return result;
    }
    

    private static Decimal formatAmount(Double amount) {
        if (amount == 0 || amount == null) {
            return 0.00;
        }
        
        Decimal decAmount = Decimal.valueOf(amount).setScale(2);
        System.debug('amount is'+decAmount);
       // return '$' + decAmount.format();
        return decAmount;
    }

    private static set<id> GetActivityId(id regulatoryFeeId){
        set<id> activityId = new set<id>();

        system.debug('regulatoryFeeId'+regulatoryFeeId);
        list<ActivityTransactionItemMapping__c > mappingObject = [select Id, Activity__c, Regulatory_Transaction_Fee_Item__c, Regulatory_Transaction_Fee__c, Refund_Transaction_Id__c, Transaction_Type__c  from ActivityTransactionItemMapping__c where Regulatory_Transaction_Fee__c =: regulatoryFeeId WITH SECURITY_ENFORCED];
        for(ActivityTransactionItemMapping__c  mapObj : mappingObject){
            activityId.add(mapObj.Activity__c);
        }
        system.debug('activityId'+activityId);

        return activityId;

    }

    @AuraEnabled
    public static String UpdateBatchStatus(String BatchData) {
        try {
            // Deserialize JSON data
            Map<String, Object> batchDataRetrieved = (Map<String, Object>) JSON.deserializeUntyped(BatchData);
            String batchId = (String) batchDataRetrieved.get('BatchId');
            String batchStatus = (String) batchDataRetrieved.get('NewBatchStatus');
    
            // Query and update in one transaction
            Batch__c batchToUpdate = [SELECT Id FROM Batch__c WHERE Id = :batchId WITH SECURITY_ENFORCED LIMIT 1];
            batchToUpdate.Batch_Status__c = batchStatus;
             Database.update(batchToUpdate, false, AccessLevel.USER_MODE);
    
            return 'Success';
        } catch (Exception e) {
            return 'Error: ' + e.getMessage();
        }
    }
    

}