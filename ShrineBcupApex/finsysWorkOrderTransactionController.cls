public with sharing class finsysWorkOrderTransactionController {
    static Id finsysWORecordTypeId = Schema.SObjectType.IndividualApplication.getRecordTypeInfosByDeveloperName().get('FinSys').getRecordTypeId();
    static Id apostilleWORecordTypeId = Schema.SObjectType.IndividualApplication.getRecordTypeInfosByDeveloperName().get('Apostille').getRecordTypeId();
    static Id feeItemRecordTypeId = Schema.SObjectType.RegulatoryTrxnFeeItem.getRecordTypeInfosByDeveloperName().get('Create_Transaction').getRecordTypeId();

    public class WorkOrderWrapper {
        @AuraEnabled public List<Map<String, Object>> applications { get; set; }
        @AuraEnabled public List<Map<String, Object>> workOrders { get; set; }

        public WorkOrderWrapper() {
            this.applications = new List<Map<String, Object>>();
            this.workOrders = new List<Map<String, Object>>();
        }
    }
    @AuraEnabled
    public static WorkOrderWrapper getWorkOrderApplication(String paramsJson) {
        try {
            Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(paramsJson);
            System.debug('paramsJson: ' + params);

            String workOrderRecordType = params.containsKey('worecordType') ? (String)params.get('worecordType') : 'FinSys';
            params.put('worecordType', workOrderRecordType);

            List<Work_Order__c> workOrders = new List<Work_Order__c>();
            List<IndividualApplication> workOrderList = new List<IndividualApplication>();



            if(workOrderRecordType != null){
                if(workOrderRecordType == 'BRS'){
                    // Get Work Orders with filtering
                    String workOrderQuery = buildWorkOrderQuery(params);
                    workOrders = Database.query(workOrderQuery);
                }
                else{
                    // Get Individual Applications
                    Set<Id> matchingApplicationIds = getMatchingApplicationIds(params);
                    String applicationQuery = buildQuery(params, matchingApplicationIds);
                    workOrderList = Database.query(applicationQuery);
                }

            }


            // Get transactions for Work Orders
            Map<Id, List<bt_stripe__Transaction__c>> workOrderToTransactions = new Map<Id, List<bt_stripe__Transaction__c>>();
            if (!workOrders.isEmpty()) {
                List<bt_stripe__Transaction__c> transactions = [
                    SELECT Id, bt_stripe__Amount__c, Work_Order__c,
                           bt_stripe__Payment_Method__r.bt_stripe__Funding__c, CreatedDate
                    FROM bt_stripe__Transaction__c
                    WHERE Work_Order__c IN :workOrders
                    WITH SECURITY_ENFORCED
                    ORDER BY CreatedDate DESC
                ];

                for (bt_stripe__Transaction__c trx : transactions) {
                    if (!workOrderToTransactions.containsKey(trx.Work_Order__c)) {
                        workOrderToTransactions.put(trx.Work_Order__c, new List<bt_stripe__Transaction__c>());
                    }
                    workOrderToTransactions.get(trx.Work_Order__c).add(trx);
                }
            }

            Map<Id, List<Map<String, Object>>> feeItemsMap = getFeeItemsForApplications(workOrderList, params);

            WorkOrderWrapper wrapper = new WorkOrderWrapper();
            wrapper.applications = processApplicationResults(workOrderList, feeItemsMap);
            wrapper.workOrders = processWorkOrderResults(workOrders, workOrderToTransactions);

            return wrapper;
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching data: ' + e.getMessage());
        }
    }



    private static String buildWorkOrderQuery(Map<String, Object> params) {
        String query = 'SELECT Id, Name, Type__c, Status__c, Customer__r.FirstName, Customer__r.LastName, CreatedDate ' +
                      'FROM Work_Order__c WHERE Id != null';

        // Add filters that match Individual Application filters
        if (params.containsKey('firstName') && String.isNotBlank((String)params.get('firstName'))) {
            query += ' AND Customer__r.FirstName LIKE \'%' + String.escapeSingleQuotes((String)params.get('firstName')) + '%\'';
        }

        if (params.containsKey('lastName') && String.isNotBlank((String)params.get('lastName'))) {
            query += ' AND Customer__r.LastName LIKE \'%' + String.escapeSingleQuotes((String)params.get('lastName')) + '%\'';
        }

        if (params.containsKey('workOrderNumber') && String.isNotBlank((String)params.get('workOrderNumber'))) {
            query += ' AND Name LIKE \'%' + String.escapeSingleQuotes((String)params.get('workOrderNumber')) + '%\'';
        }

        if (params.containsKey('activity') && String.isNotBlank((String)params.get('activity'))) {
            query += ' AND Type__c = \'' + String.escapeSingleQuotes((String)params.get('activity')) + '\'';
        }

        if (params.containsKey('workOrderStatus') && String.isNotBlank((String)params.get('workOrderStatus'))) {
            query += ' AND Status__c = \'' + String.escapeSingleQuotes((String)params.get('workOrderStatus')) + '\'';
        }

        String transactionDate = (String)params.get('transactionDate');
        String transaction2Date = (String)params.get('transaction2Date');
        System.debug('transactionDate: ' + transactionDate);
        System.debug('transaction2Date: ' + transaction2Date);

        if (String.isNotBlank(transactionDate)) {
            Date trxnDate= Date.valueOf(transactionDate);
            System.debug('trxndata is : '+ trxnDate);
            String formattedDate = trxnDate.year() + '-' +
                                     String.valueOf(trxnDate.month()).leftPad(2, '0') + '-' +
                                     String.valueOf(trxnDate.day()).leftPad(2, '0');
            query += ' AND DAY_ONLY(CreatedDate) >= ' + formattedDate; // Use DAY_ONLY to compare date portion only
            System.debug('formattedDate ###: ' + formattedDate);
        }

        // Check for transaction2Date
        if (String.isNotBlank(transaction2Date)) {
            Date trxn2Date = Date.valueOf(transaction2Date);
            String formatted2Date = trxn2Date.year() + '-' +
                                    String.valueOf(trxn2Date.month()).leftPad(2, '0') + '-' +
                                    String.valueOf(trxn2Date.day()).leftPad(2, '0');
            query += ' AND DAY_ONLY(CreatedDate) <= ' + formatted2Date; // Less than or equal
            System.debug('formattedDate (from transaction2Date): ' + formatted2Date);
        }

        // Add date range filters
        String fromDateString = (String)params.get('transactionFromDate');
        String toDateString = (String)params.get('transactionToDate');
        if (String.isNotBlank(fromDateString) && String.isNotBlank(toDateString)) {
            Date fromDate = Date.valueOf(fromDateString);
            Date toDate = Date.valueOf(toDateString);
            String formattedFrom = fromDate.year() + '-' +
                                    String.valueOf(fromDate.month()).leftPad(2, '0') + '-' +
                                    String.valueOf(fromDate.day()).leftPad(2, '0');
            String formattedTo = toDate.year() + '-' +
                                    String.valueOf(toDate.month()).leftPad(2, '0') + '-' +
                                    String.valueOf(toDate.day()).leftPad(2, '0');

            query += ' AND DAY_ONLY(CreatedDate) >= ' + String.escapeSingleQuotes(fromDateString) +
                    ' AND DAY_ONLY(CreatedDate) <= ' + String.escapeSingleQuotes(toDateString);
        }

        // Add transaction amount filter through related transactions
        if (params.containsKey('transactionAmount') && String.isNotBlank((String)params.get('transactionAmount'))) {
            Decimal amount = Decimal.valueOf((String)params.get('transactionAmount'));
            query += ' AND Id IN (SELECT Work_Order__c FROM bt_stripe__Transaction__c WHERE bt_stripe__Amount__c = ' + amount + ')';
        }

        // Add payment type filter through related transactions
        if (params.containsKey('paymentType') && String.isNotBlank((String)params.get('paymentType'))) {
            query += ' AND Id IN (SELECT Work_Order__c FROM bt_stripe__Transaction__c ' +
                    'WHERE bt_stripe__Payment_Method__r.bt_stripe__Funding__c = \'' +
                    String.escapeSingleQuotes((String)params.get('paymentType')) + '\')';
        }

        // Add sorting
        String sortBy = (String)params.get('sortBy');
        String sortDirection = (String)params.get('sortDirection');
        if (String.isNotBlank(sortBy)) {
            query += ' ORDER BY ' + String.escapeSingleQuotes(getWorkOrderSortField(sortBy)) + ' ' +
                    String.escapeSingleQuotes(sortDirection) + ' NULLS LAST';
        } else {
            query += ' ORDER BY CreatedDate DESC';
        }

        // Add pagination
        Integer offsetVal = (Integer)params.get('offsetVal');
        Integer pageSize = (Integer)params.get('pageSize');
        query += ' LIMIT ' + pageSize + ' OFFSET ' + offsetVal;

        System.debug('Final Query: ' + query);

        return query;
    }

    private static String getWorkOrderSortField(String sortBy) {
        Map<String, String> sortFieldMap = new Map<String, String>{
            'firstName' => 'Customer__r.FirstName',
            'lastName' => 'Customer__r.LastName',
            'workOrderNumber' => 'Name',
            'createdDate' => 'CreatedDate'
        };
        return sortFieldMap.containsKey(sortBy) ? sortFieldMap.get(sortBy) : sortBy;
    }


    private static List<Map<String, Object>> processWorkOrderResults(
        List<Work_Order__c> workOrders,
        Map<Id, List<bt_stripe__Transaction__c>> workOrderToTransactions
    ) {

        Map<String, String> typeMap = new Map<String, String>{
            'UCC' => 'UCC Filing',
            'Business' => 'Business Filing'
          };


        List<Map<String, Object>> results = new List<Map<String, Object>>();

        for (Work_Order__c wo : workOrders) {
            Decimal feeAmount;
            String paymentType;
            String createdDate;

            // Get the latest transaction if any exists
            List<bt_stripe__Transaction__c> transactions = workOrderToTransactions.get(wo.Id);
            if (transactions != null && !transactions.isEmpty()) {
                bt_stripe__Transaction__c latestTransaction = transactions[0];
                feeAmount = latestTransaction.bt_stripe__Amount__c;

                if (latestTransaction.bt_stripe__Payment_Method__r != null) {
                    paymentType = latestTransaction.bt_stripe__Payment_Method__r.bt_stripe__Funding__c;
                }

                if (latestTransaction.CreatedDate != null) {
                    createdDate = latestTransaction.CreatedDate.format('MM/dd/yyyy', 'GMT');
                }

            }

            Map<String, Object> resultMap = new Map<String, Object>{
                'id' => wo.Id,
                'workOrderName' => wo.Name !=null ? wo.Name : null,
                'firstName' => capitalizeFirstLetter(wo.Customer__r.FirstName),
                'lastName' => capitalizeFirstLetter(wo.Customer__r.LastName),
                'selectActivity' => wo.Type__c !=null ? typeMap.get(wo.Type__c) : null,
                'workOrderStatus'=> wo.Status__c,
                'feeAmount' => feeAmount,
                'paymentType' => paymentType,
                'isWorkOrder' => true,
                'recordType' => 'workOrder',
                'createdDate' => createdDate
            };

            results.add(resultMap);
        }

        return results;
    }





    private static Set<Id> getMatchingApplicationIds(Map<String, Object> params) {
        Set<Id> applicationIds = new Set<Id>();

        // Build base query for fee items
        String feeItemQuery = 'SELECT RegulatoryTrxnFee.ParentRecordId ' +
                            'FROM RegulatoryTrxnFeeItem ' +
                            'WHERE RegulatoryTrxnFee.ParentRecordId != NULL AND RegulatoryTrxnFeeId !=NULL '+
            	  			'AND RecordTypeId = \'' + String.escapeSingleQuotes(feeItemRecordTypeId) + '\'';

        // Add filters for RegulatoryTrxnFeeItem fields
        if (params.containsKey('activity') && String.isNotBlank((String)params.get('activity'))) {
            feeItemQuery += ' AND Select_Activity__c = \'' + String.escapeSingleQuotes((String)params.get('activity')) + '\'';
        }

        if (params.containsKey('activityCode') && String.isNotBlank((String)params.get('activityCode'))) {
            feeItemQuery += ' AND Select_Sub_Activity__c = \'' + String.escapeSingleQuotes((String)params.get('activityCode')) + '\'';
        }

        if (params.containsKey('paymentType') && String.isNotBlank((String)params.get('paymentType'))) {
            feeItemQuery += ' AND Payment_Type__c = \'' + String.escapeSingleQuotes((String)params.get('paymentType')) + '\'';
        }

        if (params.containsKey('transactionAmount') && String.isNotBlank((String)params.get('transactionAmount'))) {
            Decimal amount = Decimal.valueOf((String)params.get('transactionAmount'));
            feeItemQuery += ' AND FeeAmount = ' + amount;
        }
        String transactionDate = (String)params.get('transactionDate');
        String transaction2Date = (String)params.get('transaction2Date');
        System.debug('transactionDate: ' + transactionDate);
        System.debug('transaction2Date: ' + transaction2Date);

        if (String.isNotBlank(transactionDate)) {
            Date trxnDate= Date.valueOf(transactionDate);
            System.debug('trxndata is : '+ trxnDate);
            String formattedDate = trxnDate.year() + '-' +
                                     String.valueOf(trxnDate.month()).leftPad(2, '0') + '-' +
                                     String.valueOf(trxnDate.day()).leftPad(2, '0');
            feeItemQuery += ' AND Transaction_Date__c >= ' + formattedDate; // Use DAY_ONLY to compare date portion only
            System.debug('formattedDate ###: ' + formattedDate);
        }

        // Check for transaction2Date
        if (String.isNotBlank(transaction2Date)) {
            Date trxn2Date = Date.valueOf(transaction2Date);
            String formatted2Date = trxn2Date.year() + '-' +
                                    String.valueOf(trxn2Date.month()).leftPad(2, '0') + '-' +
                                    String.valueOf(trxn2Date.day()).leftPad(2, '0');
            feeItemQuery += ' AND Transaction_Date__c <= ' + formatted2Date; // Less than or equal
            System.debug('formattedDate (from transaction2Date): ' + formatted2Date);
        }



        // Add date range filter if provided
        String fromDateString = (String)params.get('transactionFromDate');
        String toDateString = (String)params.get('transactionToDate');
        if (String.isNotBlank(fromDateString) && String.isNotBlank(toDateString)) {
            Date fromDate = Date.valueOf(fromDateString);
            Date toDate = Date.valueOf(toDateString);
            String formattedfromDate = fromDate.year() + '-' +
                                     String.valueOf(fromDate.month()).leftPad(2, '0') + '-' +
                                     String.valueOf(fromDate.day()).leftPad(2, '0');
            String formattedtoDate = toDate.year() + '-' +
                                     String.valueOf(toDate.month()).leftPad(2, '0') + '-' +
                                     String.valueOf(toDate.day()).leftPad(2, '0');
            System.debug('formattedfromDate ###: ' + formattedfromDate+'formattedtoDate ###: ' + formattedtoDate );


            feeItemQuery += ' AND Transaction_Date__c >= ' + formattedfromDate +
                           ' AND Transaction_Date__c <= ' + formattedtoDate;
        }

        System.debug('Fee Item Query: ' + feeItemQuery);

        // Execute query and collect parent record IDs
        for (RegulatoryTrxnFeeItem feeItem : Database.query(feeItemQuery, AccessLevel.USER_MODE)) {
            applicationIds.add(feeItem.RegulatoryTrxnFee.ParentRecordId);
        }
        System.debug('Final application Ids are: ' + applicationIds.size());

        return applicationIds;
    }

    private static String buildQuery(Map<String, Object> params, Set<Id> matchingApplicationIds) {
        // String query = 'SELECT Id, First_Name__c, Last_Name__c, Work_Order_Status__c, Sequence_Number__c ' +
        //               'FROM IndividualApplication WHERE RecordTypeId = \'' + recordTypeId  + '\'' +
        //      			'AND Id IN (SELECT ParentRecordId FROM RegulatoryTrxnFee WHERE RecordType.Name = \'New Transaction\')';

        // String query = 'SELECT Id, First_Name__c, Last_Name__c, Work_Order_Status__c, Sequence_Number__c ' +
        //               'FROM IndividualApplication WHERE (RecordTypeId = \'' + finsysWORecordTypeId + '\' OR RecordTypeId = \'' + apostilleWORecordTypeId + '\')' +
        //               'AND Id IN (SELECT ParentRecordId FROM RegulatoryTrxnFee WHERE RecordType.Name = \'New Transaction\')';

        String query = 'SELECT Id, First_Name__c, Last_Name__c, Work_Order_Status__c, Sequence_Number__c, RecordType.DeveloperName ' +
                       'FROM IndividualApplication ';

        String workOrderRecordType = (String)params.get('worecordType');
        System.debug('workOrderRecordType ###: ' + workOrderRecordType);

        if (String.isNotBlank(workOrderRecordType)) {
                        // If a specific record type is passed, filter based on that
                        Id recordTypeId = getRecordTypeIdByDeveloperName(workOrderRecordType);
                        System.debug('recordTypeId ###: ' + recordTypeId);
                        if (recordTypeId != null) {
                            query += 'WHERE (RecordTypeId = \'' + recordTypeId + '\' )';
                        }
                    } else {
                        // If no record type is passed, get both FinSys and Apostille record types
                        query += 'WHERE (RecordTypeId = \'' + finsysWORecordTypeId + '\' OR RecordTypeId = \'' + apostilleWORecordTypeId + '\')';
                    }

                    // Add additional condition for regulatory transaction fee
        query += ' AND Id IN (SELECT ParentRecordId FROM RegulatoryTrxnFee WHERE RecordType.Name = \'New Transaction\')';

        System.debug('current Query: ' + query);


        // Add basic filters
        if (params.containsKey('workOrderNumber') && String.isNotBlank((String)params.get('workOrderNumber'))) {
            query += ' AND Sequence_Number__c LIKE \'%' + String.escapeSingleQuotes((String)params.get('workOrderNumber')) + '%\'';
        }

        if (params.containsKey('firstName') && String.isNotBlank((String)params.get('firstName'))) {
            query += ' AND First_Name__c LIKE \'%' + String.escapeSingleQuotes((String)params.get('firstName')) + '%\'';
        }

        if (params.containsKey('lastName') && String.isNotBlank((String)params.get('lastName'))) {
            query += ' AND Last_Name__c LIKE \'%' + String.escapeSingleQuotes((String)params.get('lastName')) + '%\'';
        }

        if (params.containsKey('workOrderStatus') && String.isNotBlank((String)params.get('workOrderStatus'))) {
            query += ' AND Work_Order_Status__c = \'' + String.escapeSingleQuotes((String)params.get('workOrderStatus')) + '\'';
        }

        // Filter by matching application IDs from fee items if any fee item filters were applied
        Boolean hasFeeItemFilters = (params.containsKey('activity') && String.isNotBlank((String)params.get('activity'))) ||
                                  (params.containsKey('activityCode') && String.isNotBlank((String)params.get('activityCode'))) ||
                                  (params.containsKey('paymentType') && String.isNotBlank((String)params.get('paymentType'))) ||
                                  (params.containsKey('transactionDate') && String.isNotBlank((String)params.get('transactionDate'))) ||
                                  (params.containsKey('transaction2Date') && String.isNotBlank((String)params.get('transaction2Date'))) ||
                                  (params.containsKey('transactionFromDate') && String.isNotBlank((String)params.get('transactionFromDate'))) ||
                                  (params.containsKey('transactionToDate') && String.isNotBlank((String)params.get('transactionToDate'))) ||
                                  (params.containsKey('transactionAmount') && String.isNotBlank((String)params.get('transactionAmount')));

        query += ' AND Id IN :matchingApplicationIds';


        // if (hasFeeItemFilters) {
        //     if (!matchingApplicationIds.isEmpty()) {
        //         query += ' AND Id IN :matchingApplicationIds';
        //     } else {
        //         query += ' AND Id = null'; // No matches found for fee item filters
        //     }
        // }

        // Add sorting
        String sortBy = (String)params.get('sortBy');
        String sortDirection = (String)params.get('sortDirection');
        if (String.isNotBlank(sortBy)) {
            String sortField = getSortField(sortBy);
            query += ' ORDER BY ' + String.escapeSingleQuotes(sortField) + ' ' +
                    String.escapeSingleQuotes(sortDirection) + ' NULLS LAST';
        }

        // Add pagination
        Integer offsetVal = (Integer)params.get('offsetVal');
        Integer pageSize = (Integer)params.get('pageSize');
        query += ' LIMIT ' + pageSize + ' OFFSET ' + offsetVal;

        System.debug('Final Query: ' + query);
        return query;
    }

        // Helper method to get RecordTypeId by developer name
    private static Id getRecordTypeIdByDeveloperName(String developerName) {
        Map<String, Schema.RecordTypeInfo> recordTypeInfos = Schema.SObjectType.IndividualApplication.getRecordTypeInfosByDeveloperName();
        if (recordTypeInfos.containsKey(developerName)) {
            return recordTypeInfos.get(developerName).getRecordTypeId();
        }
        return null;
    }


    private static Map<Id, List<Map<String, Object>>> getFeeItemsForApplications(List<IndividualApplication> applications, Map<String, Object> params) {
        Set<Id> applicationIds = new Map<Id, IndividualApplication>(applications).keySet();

        String recordTypeName = (String)params.get('worecordType');
        System.debug('recordTypeName is : '+ recordTypeName);

        String feeItemQuery = 'SELECT Id, Select_Activity__c, Select_Sub_Activity__c, Payment_Type__c, ' +
                            'FeeAmount, CreatedDate,Transaction_Date__c, RegulatoryTrxnFee.ParentRecordId ' +
                            'FROM RegulatoryTrxnFeeItem ' +
                            'WHERE RegulatoryTrxnFee.ParentRecordId IN :applicationIds  AND RegulatoryTrxnFeeId != NULL '+
            				'AND RecordTypeId = \'' + String.escapeSingleQuotes(feeItemRecordTypeId) + '\'';


        Map<Id, List<Map<String, Object>>> feeItemsMap = new Map<Id, List<Map<String, Object>>>();

        for (RegulatoryTrxnFeeItem item : Database.query(feeItemQuery, AccessLevel.USER_MODE)) {
            Id parentId = item.RegulatoryTrxnFee.ParentRecordId;
            if (!feeItemsMap.containsKey(parentId)) {
                feeItemsMap.put(parentId, new List<Map<String, Object>>());
            }

            System.debug('Transaction_Date__c is : '+ item.Transaction_Date__c);

            DateTime trxnDate = item.Transaction_Date__c !=null ? (DateTime) item.Transaction_Date__c: null;
            String formattedtrxnDate = trxnDate!=null ? trxnDate.format('MM/dd/yyyy', 'GMT') :null;
            String formattedCreatedDate = formattedtrxnDate == null ? item.CreatedDate.format('MM/dd/yyyy', 'GMT') : null;

            System.debug('trxn Id is '+ item.Id);
            System.debug('trxn date is '+ formattedtrxnDate);
            System.debug('created date is '+ formattedCreatedDate);


            feeItemsMap.get(parentId).add(new Map<String, Object>{
                'id' => item.Id,
                'selectActivity' => item.Select_Activity__c,
                'activityCode' => item.Select_Sub_Activity__c,
                'paymentType' => item.Payment_Type__c,
                'feeAmount' => item.FeeAmount,
                'createdDate' => recordTypeName != 'Apostille' ?  formattedtrxnDate : formattedCreatedDate
            });
        }

        return feeItemsMap;
    }


    private static String capitalizeFirstLetter(String inputString) {
        if (String.isBlank(inputString)) {
            return '';
        }
        String formattedString = inputString.substring(0, 1).toUpperCase() + inputString.substring(1).toLowerCase();
        return formattedString;
    }

    private static String getSortField(String sortBy) {
        Map<String, String> sortFieldMap = new Map<String, String>{
            'firstName' => 'First_Name__c',
            'lastName' => 'Last_Name__c',
            'workOrderStatus' => 'Work_Order_Status__c',
            'workOrderNumber' => 'Sequence_Number__c'
        };
        return sortFieldMap.containsKey(sortBy) ? sortFieldMap.get(sortBy) : sortBy;
    }

    private static List<Map<String, Object>> processApplicationResults(List<IndividualApplication> applications, Map<Id, List<Map<String, Object>>> feeItemsMap) {
        List<Map<String, Object>> results = new List<Map<String, Object>>();


        for (IndividualApplication app : applications) {
            List<Map<String, Object>> feeItems = feeItemsMap.containsKey(app.Id)
                ? feeItemsMap.get(app.Id)
                : new List<Map<String, Object>>();

            Map<String, Object> resultMap = new Map<String, Object>{
                'id' => app.Id,
                'firstName' => capitalizeFirstLetter(app.First_Name__c),
                'lastName' => capitalizeFirstLetter(app.Last_Name__c),
                'workOrderNumber' => app.Sequence_Number__c,
                'workOrderStatus' => app.Work_Order_Status__c,
                'workOrderRecordType' => app.RecordType.DeveloperName
            };

            // If there are fee items, add the first one's fields to the parent
            if (!feeItems.isEmpty()) {
                Map<String, Object> firstFeeItem = feeItems[0];
                resultMap.putAll(new Map<String, Object>{
                    'feeItemId' => firstFeeItem.get('id'),
                    'selectActivity' => firstFeeItem.get('selectActivity'),
                    'activityCode' => firstFeeItem.get('activityCode'),
                    'paymentType' => firstFeeItem.get('paymentType'),
                    'feeAmount' => firstFeeItem.get('feeAmount'),
                    'createdDate' => firstFeeItem.get('createdDate')
                });

                // If there are more fee items, keep them in feeItems array (excluding the first one)
                if (feeItems.size() > 1) {
                    List<Map<String, Object>> remainingFeeItems = new List<Map<String, Object>>();
                    for(Integer i = 1; i < feeItems.size(); i++) {
                        remainingFeeItems.add(feeItems[i]);
                    }
                    resultMap.put('feeItems', remainingFeeItems);
                }
            }

            results.add(resultMap);
        }


        return results;
    }

    @AuraEnabled(cacheable=true)
    public static Integer getApplicationsCount(String paramsJson) {
        // First get matching application IDs based on fee item filters
        Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(paramsJson);

        Set<Id> matchingApplicationIds = getMatchingApplicationIds(params);

        String query = buildQuery(params, matchingApplicationIds);

        System.debug('query ==> ' + query);

        String countQuery = 'SELECT COUNT() ' + query.substring(query.indexOf('FROM'));
            Integer orderByIndex = countQuery.indexOf('ORDER BY');
            if (orderByIndex != -1) {
                countQuery = countQuery.substring(0, orderByIndex);
            }

        System.debug('Count Query: ' + countQuery);
       // List<IndividualApplication> workOrderList = Database.query(query);
       Integer totalCount = Database.countQuery(countQuery, AccessLevel.USER_MODE);


        System.debug('results Query: ' + totalCount);

        return totalCount!=null ? totalCount : 0;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Integer> getRecordCounts(String paramsJson) {
        Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(paramsJson);

        Integer applicationCount = 0;
        Integer workOrderCount = 0;

        String workOrderRecordType = (String)params.get('worecordType');

        if(workOrderRecordType != null){
            if(workOrderRecordType == 'BRS'){
                  // Get filtered Work Orders count
                String workOrderCountQuery = buildWorkOrderQuery(params);
                String woCountQuery = 'SELECT COUNT() ' + workOrderCountQuery.substring(workOrderCountQuery.indexOf('FROM'));
                Integer orderByIndex = woCountQuery.indexOf('ORDER BY');
                if (orderByIndex != -1) {
                    woCountQuery = woCountQuery.substring(0, orderByIndex);
                }
                workOrderCount = Database.countQuery(woCountQuery, AccessLevel.USER_MODE);
            }
            else{
                // Get Individual Applications count
                Set<Id> matchingApplicationIds = getMatchingApplicationIds(params);
                String applicationCountQuery = buildQuery(params, matchingApplicationIds);
                String countQuery = 'SELECT COUNT() ' + applicationCountQuery.substring(applicationCountQuery.indexOf('FROM'));
                Integer orderByIndex = countQuery.indexOf('ORDER BY');
                if (orderByIndex != -1) {
                    countQuery = countQuery.substring(0, orderByIndex);
                }
                applicationCount = Database.countQuery(countQuery, AccessLevel.USER_MODE);
            }

        }
         else{
            // Get Individual Applications count
            Set<Id> matchingApplicationIds = getMatchingApplicationIds(params);
            String applicationCountQuery = buildQuery(params, matchingApplicationIds);
            String countQuery = 'SELECT COUNT() ' + applicationCountQuery.substring(applicationCountQuery.indexOf('FROM'));
            Integer orderByIndex = countQuery.indexOf('ORDER BY');
            if (orderByIndex != -1) {
                countQuery = countQuery.substring(0, orderByIndex);
            }
            applicationCount = Database.countQuery(countQuery, AccessLevel.USER_MODE);

            // Get filtered Work Orders count
            String workOrderCountQuery = buildWorkOrderQuery(params);
            String woCountQuery = 'SELECT COUNT() ' + workOrderCountQuery.substring(workOrderCountQuery.indexOf('FROM'));
            orderByIndex = woCountQuery.indexOf('ORDER BY');
            if (orderByIndex != -1) {
                woCountQuery = woCountQuery.substring(0, orderByIndex);
            }
            workOrderCount = Database.countQuery(woCountQuery, AccessLevel.USER_MODE);

        }

        System.debug('workOrderCount ==> ' + workOrderCount);
        System.debug('applicationCount ==> ' + applicationCount);



        return new Map<String, Integer>{
            'applicationCount' => applicationCount,
            'workOrderCount' => workOrderCount
        };
    }

    @AuraEnabled
    public static Map<String, Object> getEmailData(String jsonRequest) {
        Map<String, Object> response = new Map<String, Object>();

        try {
            // Parse JSON input
            Map<String, Object> inputParams = (Map<String, Object>) JSON.deserializeUntyped(jsonRequest);
            String recordId = (String) inputParams.get('recordId');

            // Validate the Record ID
            if (String.isBlank(recordId)) {
                throw new AuraHandledException('Record ID is required.');
            }

            // Fetch Individual Application Data
            IndividualApplication individualApp = [
                SELECT
                    Id,
                    First_Name__c,
                    Last_Name__c,
                    Email_Address__c,
                    Sequence_Number__c
                FROM IndividualApplication
                WHERE Id = :recordId
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];

            // Add User Information to Response
            Map<String, String> userInfo = new Map<String, String>();
            userInfo.put('firstName', individualApp.First_Name__c);
            userInfo.put('lastName', individualApp.Last_Name__c);
            userInfo.put('email', individualApp.Email_Address__c);
            userInfo.put('workOrderNo', individualApp.Sequence_Number__c);
            response.put('userInfo', userInfo);

            // Fetch Regulatory Transaction Fees linked to the Individual Application
            List<RegulatoryTrxnFee> transactionFees = [
                SELECT
                    Id,
                    Name,
                    Payment_Type__c,
                    Amount__c,
                    Transaction_Date__c,
                    Transaction_ID_Count__c,
                    CreatedBy.Name
                FROM RegulatoryTrxnFee
                WHERE ParentRecordId = :recordId AND RecordType.Name = 'New Transaction'
                WITH SECURITY_ENFORCED
            ];

            // Fetch Regulatory Transaction Fee Items
            List<RegulatoryTrxnFeeItem> feeItems = [
                SELECT
                    Id,
                    RegulatoryTrxnFeeId,
                    Select_Activity__c,
                    Select_Sub_Activity__c,
                    FeeAmount
                FROM RegulatoryTrxnFeeItem
                WHERE RegulatoryTrxnFeeId IN :transactionFees
                WITH SECURITY_ENFORCED
            ];

            // Map Fee Items to their Parent Fees
            Map<Id, RegulatoryTrxnFeeItem> feeToItemMap = new Map<Id, RegulatoryTrxnFeeItem>();
            for (RegulatoryTrxnFeeItem feeItem : feeItems) {
                feeToItemMap.put(feeItem.RegulatoryTrxnFeeId, feeItem);
            }

            // Prepare Mapped Data
            List<Map<String, Object>> mappedTransactions = new List<Map<String, Object>>();
            for (RegulatoryTrxnFee fee : transactionFees) {
                RegulatoryTrxnFeeItem feeItem = feeToItemMap.get(fee.Id);

                mappedTransactions.add(new Map<String, Object>{
                    'paymentUId' => fee.Name,
                    'paymentType' => fee.Payment_Type__c,
                    'authCode' => fee.Transaction_ID_Count__c,
                    'activity' => feeItem != null ? feeItem.Select_Activity__c : 'N/A',
                    'subActivity' => feeItem != null ? feeItem.Select_Sub_Activity__c : 'N/A',
                    'feeAmount' => fee.Amount__c != null ? fee.Amount__c : 0,
                    'createdDate' => fee.Transaction_Date__c,
                    'createdBy' => fee.CreatedBy.Name
                });
            }

            // Add Mapped Transactions to Response
            response.put('mappedTransactions', mappedTransactions);

        } catch (Exception e) {
            System.debug('Error occurred: ' + e.getMessage());
            throw new AuraHandledException('An error occurred: ' + e.getMessage());
        }

        return response;
    }



}