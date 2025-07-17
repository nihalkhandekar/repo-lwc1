public with sharing class BatchFinsysController {

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getActivityTransactionData(String searchParamsJson) {
        Map<String, Object> result = new Map<String, Object>();
        List<Map<String, Object>> dataList = new List<Map<String, Object>>();

        try {
            Map<String, Object> searchParams = (Map<String, Object>) JSON.deserializeUntyped(searchParamsJson);
            System.debug('params are ' + searchParams);

            String workorderNumber = (String) searchParams.get('workorderNumber');
            String batchCode = (String) searchParams.get('batchCode');
            String batchDate = (String) searchParams.get('batchtDate');
            String batchStatus = (String) searchParams.get('status');
            Integer transactionCount = Integer.valueOf(searchParams.get('transactionCount'));
            String paymentTypeFilter = (String) searchParams.get('paymentType');
            String fromDate = (String) searchParams.get('fromDate');
            String toDate = (String) searchParams.get('toDate');
            Integer offsetVal = (Integer) searchParams.get('offsetVal');
            Integer pageSize = (Integer) searchParams.get('pageSize');
            String sortBy = (String) searchParams.get('sortBy');
            String sortDirection = (String) searchParams.get('sortDirection');

            Set<Id> relevantBatchIds = new Set<Id>();

            String individualApplicationPrefix = Schema.getGlobalDescribe().get('IndividualApplication')?.getDescribe()?.getKeyPrefix();

            System.debug('IndividualApplication prefix: ' + individualApplicationPrefix);
            String initialFeeQuery = '';
            if (paymentTypeFilter != null && paymentTypeFilter != '' && paymentTypeFilter != 'All') {
                initialFeeQuery = 'SELECT ParentRecordId, Batch_Look_Up__c FROM RegulatoryTrxnFee ' +
                                'WHERE Batch_Look_Up__c != null AND ParentRecordId != null ' +
                                'AND Payment_Type__c = \'' + String.escapeSingleQuotes(paymentTypeFilter) + '\'';
            } else {
                initialFeeQuery = 'SELECT ParentRecordId,Batch_Look_Up__c FROM RegulatoryTrxnFee ' +
                                'WHERE Batch_Look_Up__c != null AND ParentRecordId != null';
            }

            System.debug('initial query ' + initialFeeQuery);

            for (RegulatoryTrxnFee fee : Database.query(initialFeeQuery, AccessLevel.USER_MODE)) {
                if(String.valueOf(fee.ParentRecordId).startsWith(individualApplicationPrefix)) {
                    relevantBatchIds.add(fee.Batch_Look_Up__c);
                }
            }

            System.debug('relevantBatchIds are ' + relevantBatchIds.size());

            String batchQuery = 'SELECT Id, Batch_Name__c, Batch_Status__c, Transacation_Count__c, Batch_Date__c ' +
                              'FROM Batch__c WHERE Batch_Name__c != null AND Transacation_Count__c > 0';

            if (!relevantBatchIds.isEmpty()) {
                batchQuery += ' AND Id IN :relevantBatchIds';
            }

            if (batchCode != null && batchCode != '') {
                batchQuery += ' AND Batch_Name__c = \'' + String.escapeSingleQuotes(batchCode) + '\'';
            }

            if (batchDate != null && batchDate != '') {
                Date batchCreatedDate = Date.valueOf(batchDate);
                batchQuery += ' AND Batch_Date__c = :batchCreatedDate';
            }

            if (fromDate != null && toDate != null) {
                Date batchFromDate = Date.valueOf(fromDate);
                Date batchToDate = Date.valueOf(toDate);
                batchQuery += ' AND Batch_Date__c >= :batchFromDate AND Batch_Date__c <= :batchToDate';
            }

            if (batchStatus != null && batchStatus != '') {
                batchQuery += ' AND Batch_Status__c = \'' + String.escapeSingleQuotes(batchStatus) + '\'';
            }

            if (transactionCount != null) {
                batchQuery += ' AND Transacation_Count__c = ' + transactionCount;
            }

            String sortField = String.isNotBlank(sortBy) ? sortBy : 'LastModifiedDate';
            System.debug('Sort field is ' + sortField);
            System.debug('Sort direction is ' + sortDirection);
            String sortOrder = (sortDirection == 'asc' || sortDirection == 'desc') ? sortDirection : 'desc';
            batchQuery += ' ORDER BY ' + sortField + ' ' + sortOrder + ' NULLS LAST ';

            batchQuery += ' LIMIT ' + pageSize + ' OFFSET ' + offsetVal;

            String countQuery = 'SELECT COUNT() ' + batchQuery.substring(batchQuery.indexOf('FROM'));
            Integer orderByIndex = countQuery.indexOf('ORDER BY');
            if (orderByIndex != -1) {
                countQuery = countQuery.substring(0, orderByIndex);
            }

            System.debug('Count Query: ' + countQuery);

            Integer totalCount = Database.countQuery(countQuery,AccessLevel.USER_MODE);
            result.put('totalRecords', totalCount);

            System.debug('Batch Query: ' + batchQuery);

            List<Batch__c> batches = Database.query(batchQuery, AccessLevel.USER_MODE);
            System.debug('total batches are ' + batches.size());

            Set<Id> batchIds = new Set<Id>();
            for (Batch__c batch : batches) {
                batchIds.add(batch.Id);
            }

            String feeQuery = 'SELECT Id, Name, Batch_Look_Up__c, Batch_Look_Up__r.Batch_Name__c, ' +
                             'Batch_Look_Up__r.Batch_Status__c, Batch_Look_Up__r.Batch_Date__c, ' +
                             'Payment_Type__c, TotalFeeAmount, ParentRecordId ' +
                             'FROM RegulatoryTrxnFee ' +
                             'WHERE Batch_Look_Up__c IN :batchIds AND ParentRecordId != null';

            if (paymentTypeFilter != null && paymentTypeFilter != '' && paymentTypeFilter != 'All') {
                feeQuery += ' AND Payment_Type__c = \'' + String.escapeSingleQuotes(paymentTypeFilter) + '\'';
            }

            System.debug('Fee Query: ' + feeQuery);

            List<RegulatoryTrxnFee> feeRecords = Database.query(feeQuery, AccessLevel.SYSTEM_MODE);

            Map<String, Map<String, Object>> groupedData = new Map<String, Map<String, Object>>();

            for (Batch__c batch : batches) {
                String formattedDate = '';
                if(batch.Batch_Date__c != null) {
                    formattedDate = (batch.Batch_Date__c.month() + '/' +
                                   batch.Batch_Date__c.day() + '/' +
                                   batch.Batch_Date__c.year());
                }

                String groupKey = batch.Batch_Name__c + ' - ' +
                                 formattedDate + ' ' +
                                 batch.Batch_Status__c;

                groupedData.put(groupKey, new Map<String, Object>{
                    'id' => batch.Id,
                    'UniqueId' => groupKey,
                    'BatchName' => batch.Batch_Name__c + ' - ' + formattedDate,
                    'BatchStatus' => batch.Batch_Status__c,
                    'CheckAmount' => 0.0,
                    'MoneyOrderAmount' => 0.0,
                    'CardAmount' => 0.0,
                    'CashAmount' => 0.0,
                    'OtherAmount' => 0.0,
                    'totalAmount' => 0.0,
                    'sequenceNumber' => '',
                    'TransactionCount' => 0,
                    'noOfSequenceNumber' => 0
                });
            }

            for (RegulatoryTrxnFee fee : feeRecords) {
                if (fee.Batch_Look_Up__r == null || fee.Batch_Look_Up__r.Batch_Name__c == null ||
                    fee.Batch_Look_Up__r.Batch_Date__c == null || fee.Batch_Look_Up__r.Batch_Status__c == null) {
                    continue;
                }

                String formattedDate = '';
                if(fee.Batch_Look_Up__r.Batch_Date__c != null) {
                    formattedDate = (fee.Batch_Look_Up__r.Batch_Date__c.month() + '/' +
                                   fee.Batch_Look_Up__r.Batch_Date__c.day() + '/' +
                                   fee.Batch_Look_Up__r.Batch_Date__c.year());
                }

                String groupKey = fee.Batch_Look_Up__r.Batch_Name__c + ' - ' +
                                 formattedDate + ' ' +
                                 fee.Batch_Look_Up__r.Batch_Status__c;

                Map<String, Object> currentGroup = groupedData.get(groupKey);
                if (currentGroup == null) continue;

                String paymentType = fee.Payment_Type__c != null ? fee.Payment_Type__c : null;
                String parentObjectType = fee.ParentRecordId.getSObjectType().getDescribe().getName();

                String sequenceNumber = '';
                if (parentObjectType == 'IndividualApplication') {
                    IndividualApplication parentRecord = [
                        SELECT Id, Sequence_Number__c
                        FROM IndividualApplication
                        WHERE Id = :fee.ParentRecordId WITH SECURITY_ENFORCED
                        LIMIT 1
                    ];
                    sequenceNumber = parentRecord.Sequence_Number__c;
                }

                String sequenceNumbers = (String) currentGroup.get('sequenceNumber');

                if (String.isNotBlank(sequenceNumber) && !sequenceNumbers.contains(sequenceNumber)) {
                    sequenceNumbers += String.isEmpty(sequenceNumbers) ?
                                     sequenceNumber :
                                     ', ' + sequenceNumber;
                }

                currentGroup.put('sequenceNumber', sequenceNumbers);
                currentGroup.put('noOfSequenceNumber', String.isEmpty(sequenceNumbers) ? 0 : sequenceNumbers.split(',').size());

                if (paymentType == 'Check') {
                    currentGroup.put('CheckAmount', (Double) currentGroup.get('CheckAmount') + fee.TotalFeeAmount);
                } else if (paymentType == 'Money Order') {
                    currentGroup.put('MoneyOrderAmount', (Double) currentGroup.get('MoneyOrderAmount') + fee.TotalFeeAmount);
                } else if (paymentType == 'Card') {
                    currentGroup.put('CardAmount', (Double) currentGroup.get('CardAmount') + fee.TotalFeeAmount);
                } else if (paymentType == 'Cash') {
                    currentGroup.put('CashAmount', (Double) currentGroup.get('CashAmount') + fee.TotalFeeAmount);
                } else {
                    currentGroup.put('OtherAmount', (Double) currentGroup.get('OtherAmount') + fee.TotalFeeAmount);
                }

                currentGroup.put('TransactionCount', (Integer) currentGroup.get('TransactionCount') + 1);
                currentGroup.put('totalAmount', (Double) currentGroup.get('CheckAmount') +
                               (Double) currentGroup.get('MoneyOrderAmount') +
                               (Double) currentGroup.get('CardAmount') +
                               (Double) currentGroup.get('CashAmount') +
                               (Double) currentGroup.get('OtherAmount'));
            }

            for (String groupKey : groupedData.keySet()) {
                try {
                    Map<String, Object> currentGroup = groupedData.get(groupKey);

                    if (!currentGroup.containsKey('CheckAmount') || !currentGroup.containsKey('totalAmount')) {
                        System.debug('Missing required fields in groupKey: ' + groupKey);
                        continue;
                    }

                    currentGroup.put('CheckAmount', formatAmount((Double) currentGroup.get('CheckAmount')));
                    currentGroup.put('MoneyOrderAmount', formatAmount((Double) currentGroup.get('MoneyOrderAmount')));
                    currentGroup.put('CardAmount', formatAmount((Double) currentGroup.get('CardAmount')));
                    currentGroup.put('CashAmount', formatAmount((Double) currentGroup.get('CashAmount')));
                    currentGroup.put('OtherAmount', formatAmount((Double) currentGroup.get('OtherAmount')));
                    currentGroup.put('totalAmount', formatAmount((Double) currentGroup.get('totalAmount')));

                    dataList.add(currentGroup);
                } catch (Exception e) {
                    System.debug('Error processing groupKey: ' + groupKey + ' - ' + e.getMessage());
                }
            }

            result.put('records', dataList);

        } catch (Exception e) {
            result.put('error', 'Error processing data: ' + e.getMessage() + '. Stack trace: ' + e.getStackTraceString());
            System.debug('Error details: ' + e.getMessage() + '\nStack trace: ' + e.getStackTraceString());
        }
        System.debug('result data' + result.size());
        return result;
    }

    @AuraEnabled
    public static String updateStatus(String recordId, String status) {
        try {
            if (String.isEmpty(recordId) || String.isEmpty(status)) {
                return 'Error: Record ID or Status is empty.';
            }
            List<Batch__c> batchesToUpdate = [SELECT Id, Batch_Status__c FROM Batch__c WHERE Id = :recordId WITH SECURITY_ENFORCED];
            System.debug('batch data is ' + batchesToUpdate);
            for (Batch__c batch : batchesToUpdate) {
                batch.Batch_Status__c = status;
            }

            if (batchesToUpdate != null && !batchesToUpdate.isEmpty()) {
                Database.update(batchesToUpdate, AccessLevel.SYSTEM_MODE);
            }
            return 'Success';
        } catch (DmlException dmlEx) {
            return 'Error: Failed to update status. ' + dmlEx.getMessage();
        }
    }

    private static Decimal formatAmount(Double amount) {
        if (amount == 0 || amount == null) {
            return 0.00;
        }

        Decimal decAmount = Decimal.valueOf(amount).setScale(2);
        System.debug('amount is' + decAmount);
        return decAmount;
    }
}