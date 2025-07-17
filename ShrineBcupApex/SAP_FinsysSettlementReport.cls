public with sharing class SAP_FinsysSettlementReport {

    @AuraEnabled
    public static List<Map<String, Object>> getSettlementData(String paramsJson) {
        
        try {
            // Parse input JSON parameters
            Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(paramsJson);
    
            // Extract search parameters
            String transactionType = (String) params.get('transactionType');
            String workOrder = (String) params.get('workOrder');
            String receivedBy = (String) params.get('receivedBy');
            String checkMoneyOrder = (String) params.get('checkMoneyOrder');
            Date dateofTransaction = params.containsKey('dateCreated') && params.get('dateCreated') != null
            ? Date.valueOf((String) params.get('dateCreated'))
            : null;
            Decimal amount = params.containsKey('amount') && params.get('amount') != null
                ? Decimal.valueOf((String) params.get('amount'))
                : null;
            System.debug(params.get('transactionFromDate'));
            Date transactionFromDate = params.containsKey('transactionFromDate') && params.get('transactionFromDate') != null
                ? Date.valueOf((String) params.get('transactionFromDate'))
                : null;
            Date transactionToDate = params.containsKey('transactionToDate') && params.get('transactionToDate') != null
                ? Date.valueOf((String) params.get('transactionToDate'))
                : null;
            String sortedBy = (String) params.get('sortedBy');
            String sortedDirection = (String) params.get('sortedDirection');
            Integer currentPage = (Integer) params.get('currentPage');
            Integer pageSize = (Integer) params.get('pageSize');
    
            // Set default sorting by Date in descending order
            if (String.isEmpty(sortedBy)) {
                sortedBy = 'Date';
            }
            if (String.isEmpty(sortedDirection)) {
                sortedDirection = 'desc';
            }
    
            // Fetch data from IndividualApplication and WorkOrder objects
            List<Map<String, Object>> individualApplicationData = fetchIndividualApplicationData(
                transactionType, workOrder, receivedBy, dateofTransaction, checkMoneyOrder, amount, transactionFromDate, transactionToDate
            );
            List<Map<String, Object>> workOrderData = fetchWorkOrderData(
                transactionType, workOrder, dateofTransaction, receivedBy, amount, transactionFromDate, transactionToDate
            );
    
            // Combine the results into a single list
            List<Map<String, Object>> combinedData = new List<Map<String, Object>>();
            combinedData.addAll(individualApplicationData);
            combinedData.addAll(workOrderData);
    
            // Apply date range filtering on the combined list
            if (transactionFromDate != null || transactionToDate != null) {
                combinedData = applyDateRangeFilter(combinedData, transactionFromDate, transactionToDate);
            }
    
            // Apply sorting
            combinedData = applySorting(combinedData, sortedBy, sortedDirection);
			System.debug(combinedData);
            // Apply pagination
            Integer startIndex = (currentPage - 1) * pageSize;
            System.debug(startIndex);
            Integer endIndex = Math.min(startIndex + pageSize, combinedData.size());
            if (startIndex >= combinedData.size()) {
                return new List<Map<String, Object>>(); // Return an empty list if page exceeds total records
            }
		
            // Create a sublist manually for pagination
            List<Map<String, Object>> paginatedData = new List<Map<String, Object>>();
            for (Integer i = startIndex; i < endIndex; i++) {
                paginatedData.add(combinedData[i]);
            }

            return paginatedData;

    
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching settlement data: ' + e.getMessage());
        }
    }
    
    

    @AuraEnabled(cacheable = true)
    public static Integer getSettlementCount(String paramsJson) {
        try {
            // Parse input JSON parameters
            Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(paramsJson);

            // Extract search parameters
            String transactionType = (String) params.get('transactionType');
            String workOrder = (String) params.get('workOrder');
            String receivedBy = (String) params.get('receivedBy');
            String checkMoneyOrder = (String) params.get('checkMoneyOrder');
            Date dateofTransaction = params.containsKey('dateCreated') && params.get('dateCreated') != null
            ? Date.valueOf((String) params.get('dateCreated'))
            : null;
            Decimal amount = params.containsKey('amount') && params.get('amount') != null
                ? Decimal.valueOf((String) params.get('amount'))
                : null;
            Date transactionFromDate = params.containsKey('transactionFromDate') && params.get('transactionFromDate') != null
                ? Date.valueOf((String) params.get('transactionFromDate'))
                : null;
            Date transactionToDate = params.containsKey('transactionToDate') && params.get('transactionToDate') != null
                ? Date.valueOf((String) params.get('transactionToDate'))
                : null;

            // Fetch data from IndividualApplication and WorkOrder objects
            List<Map<String, Object>> individualApplicationData = fetchIndividualApplicationData(
                transactionType, workOrder, receivedBy, dateofTransaction, checkMoneyOrder, amount, transactionFromDate, transactionToDate
            );
            List<Map<String, Object>> workOrderData = fetchWorkOrderData(
                transactionType, workOrder, dateofTransaction, receivedBy, amount, transactionFromDate, transactionToDate
            );

            // Combine the results into a single list
            List<Map<String, Object>> combinedData = new List<Map<String, Object>>();
            combinedData.addAll(individualApplicationData);
            combinedData.addAll(workOrderData);

            // Apply date range filtering on the combined list
            if (transactionFromDate != null || transactionToDate != null) {
                combinedData = applyDateRangeFilter(combinedData, transactionFromDate, transactionToDate);
            }

            // Return the count of filtered records
            return combinedData.size();

        } catch (Exception e) {
            throw new AuraHandledException('Error fetching settlement count: ' + e.getMessage());
        }
    }

    private static List<Map<String, Object>> fetchIndividualApplicationData(
        String transactionType, String workOrder, String receivedBy, Date dateofTransaction, String checkMoneyOrder, Decimal amount, Date transactionFromDate, Date transactionToDate
    ) {
        List<Map<String, Object>> results = new List<Map<String, Object>>();

        // Query IndividualApplication
        String applicationQuery = 'SELECT Id, SAP_Sequence_Number__c, SAP_Work_Order_Comments__c ' +
                                  'FROM IndividualApplication ' +
                                  'WHERE RecordType.DeveloperName IN (\'FinSys\', \'Apostille\')';
        if (!String.isEmpty(workOrder)) {
            applicationQuery += ' AND SAP_Sequence_Number__c LIKE \'%' + String.escapeSingleQuotes(workOrder) + '%\'';
        }

        List<IndividualApplication> applications = Database.query(applicationQuery);

        // Collect application IDs
        Set<Id> applicationIds = new Set<Id>();
        for (IndividualApplication app : applications) {
            applicationIds.add(app.Id);
       system.debug('applicationIds'+app.Id);

        }
        // Query RegulatoryTrxnFee
        String feeQuery = 'SELECT Id, SAP_Payment_Type__c, TotalFeeAmount, SAP_Transaction_Date__c, CreatedBy.Name, SAP_Payment_Number__c, ParentRecordId ' +
                          'FROM RegulatoryTrxnFee ' +
                          'WHERE ParentRecordId IN :applicationIds AND RecordType.Name = \'New Transaction\'';
        if (!String.isEmpty(transactionType)) {
            feeQuery += ' AND SAP_Payment_Type__c = :transactionType';
        }
        if (!String.isEmpty(receivedBy)) {
            feeQuery += ' AND CreatedBy.Name LIKE \'%' + String.escapeSingleQuotes(receivedBy) + '%\'';
        }
        if (transactionFromDate == null && transactionToDate == null && dateofTransaction != null) {
            feeQuery += ' AND SAP_Transaction_Date__c = :dateofTransaction';
        }
        if (amount != null) {
            feeQuery += ' AND TotalFeeAmount = :amount';
        }
		
        List<RegulatoryTrxnFee> fees = Database.query(feeQuery);
        // Map IndividualApplication data with RegulatoryTrxnFee data
        for (IndividualApplication app : applications) {
            for (RegulatoryTrxnFee fee : fees) {
                if (fee.ParentRecordId == app.Id) {
                    results.add(new Map<String, Object>{
                        'WorkOrderID' => app.SAP_Sequence_Number__c,
                        'TransactionType' => fee.SAP_Payment_Type__c,
                        'PaymentNumber' => fee.SAP_Payment_Number__c,
                        'CreatedBy' => fee.CreatedBy.Name,
                        'Amount' => fee.TotalFeeAmount,
                        'Date' => fee.SAP_Transaction_Date__c, // Convert Datetime to Date
                        'Comments' => app.SAP_Work_Order_Comments__c
                    });
                }
            }
        }

        return results;
    }

    private static List<Map<String, Object>> fetchWorkOrderData(
        String transactionType, String workOrder, Date dateofTransaction, String receivedBy, Decimal amount, Date transactionFromDate, Date transactionToDate
    ) {
        List<Map<String, Object>> results = new List<Map<String, Object>>();

        // Query Work_Order__c
        String workOrderQuery = 'SELECT Id ' +
                                'FROM Work_Order__c WHERE Id != NULL';
        if (!String.isEmpty(workOrder)) {
            workOrderQuery += ' AND Name LIKE \'%' + String.escapeSingleQuotes(workOrder) + '%\'';
        }
        if (!String.isEmpty(receivedBy)) {
            workOrderQuery += ' AND CreatedBy.Name LIKE \'%' + String.escapeSingleQuotes(receivedBy) + '%\'';
        }
        if (transactionFromDate == null && transactionToDate == null && dateofTransaction != null) {
            workOrderQuery += '  AND Received_Date__c = :dateofTransaction';
        }

        List<Work_Order__c> workOrders = Database.query(workOrderQuery);

        // Collect WorkOrder IDs
        Set<Id> workOrderIds = new Set<Id>();
        for (Work_Order__c wo : workOrders) {
            workOrderIds.add(wo.Id);
        }

        // Query bt_stripe__Transaction__c
        String transactionQuery = 'SELECT  Work_Order__r.Name, Work_Order__r.Received_Date__c, bt_stripe__Payment_Method__r.bt_stripe__Card_Last_4_Digit__c, Work_Order__r.CreatedBy.Name, bt_stripe__Amount__c, bt_stripe__Payment_Method__r.RecordType.Name ' +
                                  'FROM bt_stripe__Transaction__c ' +
                                  'WHERE Work_Order__c IN :workOrderIds';
        if (!String.isEmpty(transactionType)) {
            transactionQuery += ' AND bt_stripe__Payment_Method__r.RecordType.Name = :transactionType';
        }
        if (amount != null) {
            transactionQuery += ' AND bt_stripe__Amount__c = :amount';
        }

        List<bt_stripe__Transaction__c> transactions = Database.query(transactionQuery);

        // Map Work_Order__c data with bt_stripe__Transaction__c data
        for (bt_stripe__Transaction__c txn : transactions) {
            results.add(new Map<String, Object>{
                'WorkOrderID' => txn.Work_Order__r.Name,
                'TransactionType' => txn.bt_stripe__Payment_Method__r.RecordType.Name,
                'PaymentNumber' => txn.bt_stripe__Payment_Method__r.bt_stripe__Card_Last_4_Digit__c,
                'CreatedBy' => txn.Work_Order__r.CreatedBy.Name,
                'Amount' => txn.bt_stripe__Amount__c,
                'Date' => txn.Work_Order__r.Received_Date__c.date(), // Convert Datetime to Date
                'Comments' => null
            });

        }
        

        return results;
    }

    private static List<Map<String, Object>> applyDateRangeFilter(
        List<Map<String, Object>> combinedData, Date transactionFromDate, Date transactionToDate
    ) {
        List<Map<String, Object>> filteredData = new List<Map<String, Object>>();

        for (Map<String, Object> record : combinedData) {
            Date recordDate = (Date) record.get('Date');

            // Check if the record falls within the date range
            if ((transactionFromDate == null || recordDate >= transactionFromDate) &&
                (transactionToDate == null || recordDate <= transactionToDate)) {
                filteredData.add(record);
            }
        }

        return filteredData;
    }

    private static List<Map<String, Object>> applySorting(
        List<Map<String, Object>> data, String sortedBy, String sortedDirection
    ) {
        // Default sorting by 'Date' if no column is specified
        sortedBy = String.isEmpty(sortedBy) ? 'Date' : sortedBy;
        Boolean isAscending = sortedDirection == 'asc';

        // Sort using a custom comparator
        data.sort(new SortingComparator(sortedBy, isAscending));
        return data;
    }

    // Inner class to implement the Comparator
    private class SortingComparator implements System.Comparator<Map<String, Object>> {
        private String sortedBy;
        private Boolean isAscending;

        // Constructor to pass sorting options
        public SortingComparator(String sortedBy, Boolean isAscending) {
            this.sortedBy = sortedBy;
            this.isAscending = isAscending;
        }

        public Integer compare(Map<String, Object> map1, Map<String, Object> map2) {
            Object valueA = map1.get(sortedBy);
            Object valueB = map2.get(sortedBy);

            // Handle null values
            if (valueA == null) valueA = '';
            if (valueB == null) valueB = '';

            // Compare the values
            Integer comparisonResult = String.valueOf(valueA).compareTo(String.valueOf(valueB));
            return isAscending ? comparisonResult : -comparisonResult;
        }
    }

    public static List<Map<String, Object>> getFilteredSettlementData(
        String transactionType, String workOrder, String receivedBy, String checkMoneyOrder, 
        Date fromDate, Date toDate, String sortBy, String sortDirection
    ) {
        List<Map<String, Object>> combinedData = new List<Map<String, Object>>();

        // Fetch data from IndividualApplication and WorkOrder objects
        combinedData.addAll(fetchIndividualApplicationData(transactionType, workOrder, receivedBy, null, checkMoneyOrder, null, fromDate, toDate));
        combinedData.addAll(fetchWorkOrderData(transactionType, workOrder, null, receivedBy, null, fromDate, toDate));

        // Apply date range filter
        if (fromDate != null || toDate != null) {
            combinedData = applyDateRangeFilter(combinedData, fromDate, toDate);
        }

        // Apply sorting
        if (!String.isEmpty(sortBy) && !String.isEmpty(sortDirection)) {
            combinedData = applySorting(combinedData, sortBy, sortDirection);
        }

        return combinedData;
    }








}