public with sharing class FinsysCreditCardReport {

    public class CreditCardWrapper {
        @AuraEnabled public String transactionDate;
        @AuraEnabled public String totalAmount;
        @AuraEnabled public List<ActivityWrapper> activities;

        public CreditCardWrapper(String transactionDate, String totalAmount, List<ActivityWrapper> activities) {
            this.transactionDate = transactionDate;
            this.totalAmount = totalAmount;
            this.activities = activities;
        }
    }

    // Wrapper class for activity details
    public class ActivityWrapper {
        @AuraEnabled public String batchName;
        @AuraEnabled public String batchTotal;
        @AuraEnabled public Integer batchTransactionCount; // New field

        public ActivityWrapper(String batchName, String batchTotal, Integer batchTransactionCount) {
            this.batchName = batchName;
            this.batchTotal = batchTotal;
            this.batchTransactionCount = batchTransactionCount;
        }
    }

    @AuraEnabled
    public static List<CreditCardWrapper> getCreditCardData(String paramsJson) {
        try {
            // Parse input parameters
            Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(paramsJson);
    
            Date transactionFromDate = params.containsKey('fromDate') && params.get('fromDate') != null 
                ? Date.valueOf((String) params.get('fromDate')) 
                : null;
            Date transactionToDate = params.containsKey('toDate') && params.get('toDate') != null 
                ? Date.valueOf((String) params.get('toDate')) 
                : null;
    
            // Step 1: Fetch Finsys Work Orders
            List<Id> finsysIds = new List<Id>();
            for (IndividualApplication app : [
                SELECT Id FROM IndividualApplication 
                WHERE RecordType.DeveloperName = 'Finsys'
            ]) {
                finsysIds.add(app.Id);
            }
    
            // Step 2: Fetch Apostille Work Orders
            List<Id> apostilleIds = new List<Id>();
            for (IndividualApplication app : [
                SELECT Id FROM IndividualApplication 
                WHERE RecordType.DeveloperName = 'Apostille'
            ]) {
                apostilleIds.add(app.Id);
            }
    
            // Step 3: Fetch Regulatory Transactions (Card Payments)
            String regTxnQuery = 'SELECT Transaction_Date__c, TotalFeeAmount, Batch_Look_Up__r.Batch_Name__c, ParentRecordId ' +
                                 'FROM RegulatoryTrxnFee ' +
                                 'WHERE Payment_Type__c = \'Card\' ' +
                                 'AND RecordType.DeveloperName = \'New_Transaction\' ';
    
            if (!finsysIds.isEmpty() || !apostilleIds.isEmpty()) {
                regTxnQuery += 'AND (';
                if (!finsysIds.isEmpty()) {
                    regTxnQuery += 'ParentRecordId IN :finsysIds ';
                }
                if (!apostilleIds.isEmpty()) {
                    if (!finsysIds.isEmpty()) regTxnQuery += 'OR ';
                    regTxnQuery += 'ParentRecordId IN :apostilleIds ';
                }
                regTxnQuery += ') ';
            }
    
            if (transactionFromDate != null && transactionToDate != null) {
                regTxnQuery += 'AND Transaction_Date__c >= :transactionFromDate ' +
                               'AND Transaction_Date__c <= :transactionToDate ';
            }
    
            regTxnQuery += 'ORDER BY Transaction_Date__c DESC';
    
            List<RegulatoryTrxnFee> transactions = Database.query(regTxnQuery);
    
            // Step 4: Fetch Work Orders Data
            String workOrderQuery = 'SELECT Name, Received_Date__c, Total_Payment__c, Type__c ' +
                                    'FROM Work_Order__c ' +
                                    'WHERE Received_Date__c >= :transactionFromDate ' +
                                    'AND Received_Date__c <= :transactionToDate ';
    
            List<Work_Order__c> workOrders = Database.query(workOrderQuery);

            // Step 5: Merge Regulatory Transactions and Work Order data
            Map<Date, Map<String, Object>> groupedData = new Map<Date, Map<String, Object>>();
    
            // Process Regulatory Transactions
            for (RegulatoryTrxnFee txn : transactions) {
                Date transactionDate = txn.Transaction_Date__c;
                String batchName = txn.Batch_Look_Up__r != null ? txn.Batch_Look_Up__r.Batch_Name__c : 'Unknown Batch';

                if (apostilleIds.contains(txn.ParentRecordId)) {
                    batchName = 'Apostille';
                }

                if (!groupedData.containsKey(transactionDate)) {
                    groupedData.put(transactionDate, new Map<String, Object>{
                        'TransactionDate' => transactionDate,
                        'TotalAmount' => 0.00,
                        'Batches' => new List<Map<String, Object>>()
                    });
                }

                Map<String, Object> dateGroup = groupedData.get(transactionDate);
                Decimal totalAmount = (Decimal) dateGroup.get('TotalAmount');
                totalAmount += txn.TotalFeeAmount != null ? txn.TotalFeeAmount : 0;
                dateGroup.put('TotalAmount', totalAmount);

                List<Map<String, Object>> batches = (List<Map<String, Object>>) dateGroup.get('Batches');

                // Aggregate batch totals and count transactions
                Boolean batchExists = false;
                for (Map<String, Object> batch : batches) {
                    if (batch.get('BatchName') == batchName) {
                        batch.put('BatchTotal', ((Decimal) batch.get('BatchTotal')) + txn.TotalFeeAmount);
                        batch.put('BatchTransactionCount', ((Integer) batch.get('BatchTransactionCount')) + 1);
                        batchExists = true;
                        break;
                    }
                }

                if (!batchExists) {
                    batches.add(new Map<String, Object>{
                        'BatchName' => batchName,
                        'BatchTotal' => txn.TotalFeeAmount,
                        'BatchTransactionCount' => 1
                    });
                }
            }

            // Process Work Orders
            for (Work_Order__c workOrder : workOrders) {
                Date transactionDate = workOrder.Received_Date__c.date();
                String category = workOrder.Type__c != null ? workOrder.Type__c : 'Unknown Category';
                Decimal amount = workOrder.Total_Payment__c;

                if (!groupedData.containsKey(transactionDate)) {
                    groupedData.put(transactionDate, new Map<String, Object>{
                        'TransactionDate' => transactionDate,
                        'TotalAmount' => 0.00,
                        'Batches' => new List<Map<String, Object>>()
                    });
                }

                Map<String, Object> dateGroup = groupedData.get(transactionDate);
                Decimal totalAmount = (Decimal) dateGroup.get('TotalAmount');
                totalAmount += amount;
                dateGroup.put('TotalAmount', totalAmount);

                List<Map<String, Object>> batches = (List<Map<String, Object>>) dateGroup.get('Batches');
                Boolean categoryExists = false;

                for (Map<String, Object> batch : batches) {
                    if (batch.get('BatchName') == category) {
                        batch.put('BatchTotal', ((Decimal) batch.get('BatchTotal')) + amount);
                        batch.put('BatchTransactionCount', ((Integer) batch.get('BatchTransactionCount')) + 1);
                        categoryExists = true;
                        break;
                    }
                }

                if (!categoryExists) {
                    batches.add(new Map<String, Object>{
                        'BatchName' => category,
                        'BatchTotal' => amount,
                        'BatchTransactionCount' => 1
                    });
                }
            }

            // Step 6: Build and return the final response
            List<CreditCardWrapper> results = new List<CreditCardWrapper>();

            for (Date transactionDate : groupedData.keySet()) {
                Map<String, Object> dateGroup = groupedData.get(transactionDate);
                List<ActivityWrapper> activities = new List<ActivityWrapper>();

                for (Map<String, Object> batch : (List<Map<String, Object>>) dateGroup.get('Batches')) {
                    activities.add(new ActivityWrapper(
                        (String) batch.get('BatchName'),
                        String.valueOf(batch.get('BatchTotal')),
                        (Integer) batch.get('BatchTransactionCount')
                    ));
                }

                results.add(new CreditCardWrapper(transactionDate.format(), String.valueOf(dateGroup.get('TotalAmount')), activities));
            }

            return results;
        } catch (Exception ex) {
            throw new AuraHandledException('Error fetching credit card data: ' + ex.getMessage());
        }
    }
    
    
    
    
    
    
    


    @AuraEnabled(cacheable = true)
    public static Integer getCreditCardCount(String paramsJson) {
        try {
            // Parse input parameters
            Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(paramsJson);
    
            Date transactionFromDate = params.containsKey('fromDate') && params.get('fromDate') != null 
                ? Date.valueOf((String) params.get('fromDate')) 
                : null;
            Date transactionToDate = params.containsKey('toDate') && params.get('toDate') != null 
                ? Date.valueOf((String) params.get('toDate')) 
                : null;
    
            // Step 1: Fetch IndividualApplication IDs for Finsys and Apostille
            List<Id> finsysIds = new List<Id>();
            for (IndividualApplication app : [
                SELECT Id 
                FROM IndividualApplication 
                WHERE RecordType.DeveloperName = 'Finsys'
            ]) {
                finsysIds.add(app.Id);
            }
    
            List<Id> apostilleIds = new List<Id>();
            for (IndividualApplication app : [
                SELECT Id 
                FROM IndividualApplication 
                WHERE RecordType.DeveloperName = 'Apostille'
            ]) {
                apostilleIds.add(app.Id);
            }
    
            Integer regTxnCount = 0;
            Integer workOrderCount = 0;
    
            // Step 2: Count Regulatory Transactions (Card Payments)
            String regTxnQuery = 'SELECT COUNT_DISTINCT(Transaction_Date__c) totalCount ' +
                                 'FROM RegulatoryTrxnFee ' +
                                 'WHERE Payment_Type__c = \'Card\' ' +
                                 'AND RecordType.DeveloperName = \'New_Transaction\' ';
    
            if (!finsysIds.isEmpty() || !apostilleIds.isEmpty()) {
                regTxnQuery += 'AND (';
                if (!finsysIds.isEmpty()) {
                    regTxnQuery += 'ParentRecordId IN :finsysIds ';
                }
                if (!apostilleIds.isEmpty()) {
                    if (!finsysIds.isEmpty()) regTxnQuery += 'OR ';
                    regTxnQuery += 'ParentRecordId IN :apostilleIds ';
                }
                regTxnQuery += ') ';
            }
    
            if (transactionFromDate != null && transactionToDate != null) {
                regTxnQuery += 'AND Transaction_Date__c >= :transactionFromDate ' +
                               'AND Transaction_Date__c <= :transactionToDate ';
            }
    
            List<AggregateResult> regTxnResults = Database.query(regTxnQuery);
            if (!regTxnResults.isEmpty()) {
                regTxnCount = (Integer) regTxnResults[0].get('totalCount');
            }
    
            // Step 3: Count Work Orders (Card Payments)
            String transactionQuery = 'SELECT Work_Order__c FROM bt_stripe__Transaction__c ' +
                                      'WHERE bt_stripe__Payment_Method__r.RecordType.Name = \'Card\' ';
    
            if (transactionFromDate != null && transactionToDate != null) {
                transactionQuery += 'AND CreatedDate >= :transactionFromDate ' +
                                    'AND CreatedDate <= :transactionToDate ';
            }
    
            List<bt_stripe__Transaction__c> cardTransactions = Database.query(transactionQuery);
    
            Set<Id> workOrderIds = new Set<Id>();
            for (bt_stripe__Transaction__c txn : cardTransactions) {
                if (txn.Work_Order__c != null) {
                    workOrderIds.add(txn.Work_Order__c);
                }
            }
    
            if (!workOrderIds.isEmpty()) {
                String workOrderQuery = 'SELECT COUNT_DISTINCT(Received_Date__c) totalCount ' +
                                        'FROM Work_Order__c ' +
                                        'WHERE Id IN :workOrderIds';
    
                List<AggregateResult> workOrderResults = Database.query(workOrderQuery);
                if (!workOrderResults.isEmpty()) {
                    workOrderCount = (Integer) workOrderResults[0].get('totalCount');
                }
            }
    
            // Step 4: Return Total Count
            Integer totalCount = regTxnCount + workOrderCount;
            return totalCount;
    
        } catch (Exception ex) {
            System.debug('Error in getCreditCardCount: ' + ex.getMessage());
            throw new AuraHandledException('Unable to fetch credit card count. Please try again.');
        }
    }
    
    
}