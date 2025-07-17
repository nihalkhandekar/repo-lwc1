public with sharing class FinsysExcelController {
    @AuraEnabled
    public static List<Map<String, Object>> agingReport(String jsonInput) {
        try {
            if (String.isBlank(jsonInput)) {
                throw new AuraHandledException('Input is null or empty.');
            }
    
            Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(jsonInput);
            String nameSearch = (String) params.get('customerName');
            Date reportDate = params.containsKey('reportDate') && params.get('reportDate') != null 
                ? Date.valueOf((String) params.get('reportDate')) 
                : Date.today();
    
            Integer currentPage = params.containsKey('currentPage') ? (Integer) params.get('currentPage') : 1;
            Integer recordsPerPage = params.containsKey('recordsPerPage') ? (Integer) params.get('recordsPerPage') : 10;
            String sortedBy = params.containsKey('sortedBy') ? (String) params.get('sortedBy') : 'Customer__c';
            String sortedDirection = params.containsKey('sortedDirection') ? (String) params.get('sortedDirection') : 'ASC';
    
            System.debug('Input Parameters for Results: ' + params);
    
            Id finsysCustomerRecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'FinSys Customers' LIMIT 1].Id;
            System.debug('Finsys Customer RecordTypeId for Results: ' + finsysCustomerRecordTypeId);
    
            // Build the query
            String query = 'SELECT Id, Customer__c, Name, Email, Phone, Customer_Account_Balance__c, Last_Balance_Update__c ' +
                           'FROM Contact ' +
                           'WHERE RecordTypeId = :finsysCustomerRecordTypeId ' +
                           'AND Customer_Account_Balance__c > 0';
    
            if (!String.isBlank(nameSearch)) {
                query += ' AND Name LIKE :nameSearch';
                nameSearch = '%' + nameSearch + '%';
            }
    
            // Apply sorting
            query += ' ORDER BY ' + sortedBy + ' ' + sortedDirection;
    
           
            System.debug('SOQL Query for Results: ' + query);
    
            // Execute query
            List<Contact> customers = Database.query(query, AccessLevel.USER_MODE);
            System.debug('Number of Customers Fetched for Results: ' + customers.size());
    
            // Prepare results
            List<Map<String, Object>> agingReport = new List<Map<String, Object>>();
            for (Contact customer : customers) {
                Decimal totalBalance = customer.Customer_Account_Balance__c != null ? customer.Customer_Account_Balance__c : 0;
    
                Integer daysSinceUpdate = customer.Last_Balance_Update__c != null
                    ? customer.Last_Balance_Update__c.date().daysBetween(reportDate)
                    : 0;
    
                Decimal balance1Day = (daysSinceUpdate >= 1 && daysSinceUpdate < 30) ? totalBalance : 0;
                Decimal balance30Days = (daysSinceUpdate >= 30 && daysSinceUpdate < 60) ? totalBalance : 0;
                Decimal balance60Days = (daysSinceUpdate >= 60 && daysSinceUpdate < 90) ? totalBalance : 0;
                Decimal balance90Days = (daysSinceUpdate >= 90 && daysSinceUpdate < 120) ? totalBalance : 0;
                Decimal balance120PlusDays = (daysSinceUpdate >= 120) ? totalBalance : 0;
    
                agingReport.add(new Map<String, Object>{
                    'CustomerId' => customer.Id,
                    'CustomerID' => customer.Customer__c,
                    'Name' => customer.Name,
                    'Email' => customer.Email,
                    'PhoneNumber' => customer.Phone,
                    '1Day' => balance1Day,
                    '30Days' => balance30Days,
                    '60Days' => balance60Days,
                    '90Days' => balance90Days,
                    '120PlusDays' => balance120PlusDays,
                    'TotalBalance' => totalBalance
                });
            }
    
            System.debug('Aging Report Results Data: ' + agingReport);
            return agingReport;
    
        } catch (Exception e) {
            System.debug('Error in agingReportResults: ' + e.getMessage());
            throw new AuraHandledException('Error fetching aging report results: ' + e.getMessage());
        }
    }
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
                transactionType, workOrder, receivedBy, dateofTransaction, checkMoneyOrder, amount
            );
            List<Map<String, Object>> workOrderData = fetchWorkOrderData(
                transactionType, workOrder, dateofTransaction, receivedBy, amount
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
    

            return combinedData;

    
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching settlement data: ' + e.getMessage());
        }
    }
    

    private static List<Map<String, Object>> fetchIndividualApplicationData(
        String transactionType, String workOrder, String receivedBy, Date dateofTransaction, String checkMoneyOrder, Decimal amount
    ) {
        List<Map<String, Object>> results = new List<Map<String, Object>>();

        // Query IndividualApplication
        String applicationQuery = 'SELECT Id, Sequence_Number__c, Work_Order_Comments__c ' +
                                  'FROM IndividualApplication ' +
                                  'WHERE RecordType.DeveloperName IN (\'FinSys\', \'Apostille\')';
        if (!String.isEmpty(workOrder)) {
            applicationQuery += ' AND Sequence_Number__c LIKE \'%' + String.escapeSingleQuotes(workOrder) + '%\'';
        }

        List<IndividualApplication> applications = Database.query(applicationQuery, AccessLevel.USER_MODE);

        // Collect application IDs
        Set<Id> applicationIds = new Set<Id>();
        for (IndividualApplication app : applications) {
            applicationIds.add(app.Id);
        }

        // Query RegulatoryTrxnFee
        String feeQuery = 'SELECT Id, Payment_Type__c, TotalFeeAmount, Transaction_Date__c, CreatedBy.Name, Payment_Number__c, ParentRecordId ' +
                          'FROM RegulatoryTrxnFee ' +
                          'WHERE ParentRecordId IN :applicationIds AND RecordType.Name = \'New Transaction\'';
        if (!String.isEmpty(transactionType)) {
            feeQuery += ' AND Payment_Type__c = :transactionType';
        }
        if (dateofTransaction != null) {
            feeQuery += ' AND Transaction_Date__c = :dateofTransaction';
        }
        if (amount != null) {
            feeQuery += ' AND TotalFeeAmount = :amount';
        }

        List<RegulatoryTrxnFee> fees = Database.query(feeQuery, AccessLevel.USER_MODE);

        // Map IndividualApplication data with RegulatoryTrxnFee data
        for (IndividualApplication app : applications) {
            for (RegulatoryTrxnFee fee : fees) {
                if (fee.ParentRecordId == app.Id) {
                    results.add(new Map<String, Object>{
                        'WorkOrderID' => app.Sequence_Number__c,
                        'TransactionType' => fee.Payment_Type__c,
                        'PaymentNumber' => fee.Payment_Number__c,
                        'CreatedBy' => fee.CreatedBy.Name,
                        'Amount' => fee.TotalFeeAmount,
                        'Date' => fee.Transaction_Date__c, // Convert Datetime to Date
                        'Comments' => app.Work_Order_Comments__c
                    });
                }
            }
        }

        return results;
    }

    private static List<Map<String, Object>> fetchWorkOrderData(
        String transactionType, String workOrder, Date dateofTransaction, String receivedBy, Decimal amount
    ) {
        List<Map<String, Object>> results = new List<Map<String, Object>>();

        // Query Work_Order__c
        String workOrderQuery = 'SELECT Id, Name, Total_Payment__c, Received_Date__c, CreatedBy.Name ' +
                                'FROM Work_Order__c WHERE Id != NULL';
        if (!String.isEmpty(workOrder)) {
            workOrderQuery += ' AND Name LIKE \'%' + String.escapeSingleQuotes(workOrder) + '%\'';
        }
        if (dateofTransaction != null) {
            workOrderQuery += '  AND Received_Date__c = :dateofTransaction';
        }

        List<Work_Order__c> workOrders = Database.query(workOrderQuery, AccessLevel.USER_MODE);

        // Collect WorkOrder IDs
        Set<Id> workOrderIds = new Set<Id>();
        for (Work_Order__c wo : workOrders) {
            workOrderIds.add(wo.Id);
        }

        // Query bt_stripe__Transaction__c
        String transactionQuery = 'SELECT Work_Order__c, bt_stripe__Amount__c, bt_stripe__Payment_Method__r.RecordType.Name ' +
                                  'FROM bt_stripe__Transaction__c ' +
                                  'WHERE Work_Order__c IN :workOrderIds';
        if (!String.isEmpty(transactionType)) {
            transactionQuery += ' AND bt_stripe__Payment_Method__r.RecordType.Name = :transactionType';
        }
        if (amount != null) {
            transactionQuery += ' AND bt_stripe__Amount__c = :amount';
        }

        List<bt_stripe__Transaction__c> transactions = Database.query(transactionQuery, AccessLevel.USER_MODE);

        // Map Work_Order__c data with bt_stripe__Transaction__c data
        for (Work_Order__c wo : workOrders) {
            for (bt_stripe__Transaction__c txn : transactions) {
                if (txn.Work_Order__c == wo.Id) {
                    results.add(new Map<String, Object>{
                        'WorkOrderID' => wo.Name,
                        'TransactionType' => txn.bt_stripe__Payment_Method__r.RecordType.Name,
                        'PaymentNumber' => null,
                        'CreatedBy' => wo.CreatedBy.Name,
                        'Amount' => txn.bt_stripe__Amount__c,
                        'Date' => wo.Received_Date__c.date(), // Convert Datetime to Date
                        'Comments' => null
                    });
                }
            }
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

    @AuraEnabled
    public static List<Map<String, Object>> creditBalanceReport(String paramsJson) {
        try {
            if (String.isBlank(paramsJson)) {
                throw new AuraHandledException('Input is null or empty.');
            }

            // Parse input JSON parameters
            Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(paramsJson);
            String customerId = (String) params.get('customerId');
            String nameSearch = (String) params.get('name');

            Date createddate = params.containsKey('createddate') && params.get('createddate') != null 
                ? Date.valueOf((String) params.get('createddate')) 
                : null;
            Date transactionFromDate = params.containsKey('transactionFromDate') && params.get('transactionFromDate') != null 
                ? Date.valueOf((String) params.get('transactionFromDate')) 
                : null;
            Date transactionToDate = params.containsKey('transactionToDate') && params.get('transactionToDate') != null 
                ? Date.valueOf((String) params.get('transactionToDate')) 
                : null;

            Integer currentPage = params.containsKey('currentPage') ? (Integer) params.get('currentPage') : 1;
            Integer pageSize = params.containsKey('pageSize') ? (Integer) params.get('pageSize') : 10;
            String sortedBy = params.containsKey('sortedBy') ? (String) params.get('sortedBy') : 'Name';
            String sortedDirection = params.containsKey('sortedDirection') ? (String) params.get('sortedDirection') : 'ASC';

            System.debug('Input Parameters for Results: ' + params);

            // Fetch the RecordTypeId for "FinSys Customers"
            Id finsysCustomerRecordTypeId = [
                SELECT Id 
                FROM RecordType 
                WHERE SObjectType = 'Contact' AND Name = 'FinSys Customers'
                LIMIT 1
            ].Id;

            // Build the query for Contacts
            String query = 'SELECT Id, Name, Customer__c, Email, Phone, Customer_Account_Balance__c, ' +
                           'Last_Balance_Update__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, CreatedDate ' +
                           'FROM Contact ' +
                           'WHERE RecordTypeId = :finsysCustomerRecordTypeId ' +
                           'AND Customer_Account_Balance__c > 0';

            if (!String.isBlank(customerId)) {
                query += ' AND Customer__c = :customerId';
            }
            if (createddate != null) {
                query += ' AND CreatedDate = :createddate';
            }
            if (!String.isBlank(nameSearch)) {
                query += ' AND Name LIKE :nameSearch';
                nameSearch = '%' + nameSearch + '%';
            }
            if (transactionFromDate != null) {
                query += ' AND CreatedDate >= :transactionFromDate';
            }
            if (transactionToDate != null) {
                query += ' AND CreatedDate <= :transactionToDate';
            }

            // Apply sorting
            query += ' ORDER BY ' + sortedBy + ' ' + sortedDirection;

            

            System.debug('SOQL Query for Results: ' + query);

            // Execute query
            List<Contact> customers = Database.query(query, AccessLevel.USER_MODE);
            System.debug('Number of Customers Fetched for Results: ' + customers.size());

            // Prepare results
            List<Map<String, Object>> results = new List<Map<String, Object>>();
            for (Contact customer : customers) {
                String formattedAddress = (customer.MailingStreet != null ? customer.MailingStreet + ', ' : '') +
                                          (customer.MailingCity != null ? customer.MailingCity + ', ' : '') +
                                          (customer.MailingState != null ? customer.MailingState + ', ' : '') +
                                          (customer.MailingPostalCode != null ? customer.MailingPostalCode + ', ' : '') +
                                          (customer.MailingCountry != null ? customer.MailingCountry : '');

                results.add(new Map<String, Object>{
                    'Customer__c' => customer.Customer__c,
                    'Name' => customer.Name,
                    'MailingAddress' => formattedAddress,
                    'Customer_Account_Balance__c' => customer.Customer_Account_Balance__c,
                    'CreatedDate' => customer.CreatedDate.date()
                });
            }

            return results;

        } catch (Exception e) {
            System.debug('Error in creditBalanceReport: ' + e.getMessage());
            throw new AuraHandledException('Error fetching credit balance report: ' + e.getMessage());
        }
    }

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
                WHERE RecordType.DeveloperName = 'Finsys'  WITH SECURITY_ENFORCED
            ]) {
                finsysIds.add(app.Id);
            }
    
            // Step 2: Fetch Apostille Work Orders
            List<Id> apostilleIds = new List<Id>();
            for (IndividualApplication app : [
                SELECT Id FROM IndividualApplication 
                WHERE RecordType.DeveloperName = 'Apostille'  WITH SECURITY_ENFORCED
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
    
            List<RegulatoryTrxnFee> transactions = Database.query(regTxnQuery, AccessLevel.USER_MODE);
    
            // Step 4: Fetch Work Orders Data
            String workOrderQuery = 'SELECT Name, Received_Date__c, Total_Payment__c, Type__c ' +
                                    'FROM Work_Order__c ' +
                                    'WHERE Received_Date__c >= :transactionFromDate ' +
                                    'AND Received_Date__c <= :transactionToDate ';
    
            List<Work_Order__c> workOrders = Database.query(workOrderQuery, AccessLevel.USER_MODE);

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



}