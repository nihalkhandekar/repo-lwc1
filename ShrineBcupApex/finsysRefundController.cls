public with sharing class finsysRefundController {
    static Id recordTypeId = Schema.SObjectType.IndividualApplication.getRecordTypeInfosByDeveloperName().get('FinSys').getRecordTypeId();
    static Id feeRecordTypeId = Schema.SObjectType.RegulatoryTrxnFee.getRecordTypeInfosByDeveloperName().get('Refund_Transaction').getRecordTypeId();

    @AuraEnabled
    public static List<Map<String, Object>> getWorkOrderApplication(String paramsJson) {
        try {
            Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(paramsJson);
            
            Set<Id> qualifyingApplicationIds = getQualifyingApplicationIds(params);
            
            // Return empty list if no qualifying applications found
            if (qualifyingApplicationIds.isEmpty()) {
                return new List<Map<String, Object>>();
            }
            
            String query = buildQuery(params, qualifyingApplicationIds);
            List<IndividualApplication> workOrderList = Database.query(query, AccessLevel.USER_MODE);
            
            Map<Id, List<Map<String, Object>>> feeItemsMap = getFeeItemsForApplications(workOrderList, params);
            return processApplicationResults(workOrderList, feeItemsMap);
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching data: ' + e.getMessage());
        }
    }
    
    private static Set<Id> getQualifyingApplicationIds(Map<String, Object> params) {
        List<String> feeConditions = new List<String>();
        // Always include the base record type condition
        feeConditions.add('RecordTypeId = :feeRecordTypeId');
        
        addFilterCondition(feeConditions, 'Refund_ID__c', (String)params.get('refundId'), false);
        addFilterCondition(feeConditions, 'Refund_Reason__c', (String)params.get('rejectionReason'), false);
        addFilterCondition(feeConditions, 'Payment_Type__c', (String)params.get('refundMethod'), false);        
        addFilterCondition(feeConditions, 'Refund_Voucher_ID__c', (String)params.get('checkCC'), true);
    
        String status = (String)params.get('status');
        if (String.isNotBlank(status)) {
            feeConditions.add('Transaction_Status__c = \'' + String.escapeSingleQuotes(status) + '\'');
        }    
    
        String amountRangeStart = String.valueOf(params.get('amountRangeStart'));
        String amountRangeEnd = String.valueOf(params.get('amountRangeEnd'));
    
        if (String.isNotBlank(amountRangeStart) && String.isNotBlank(amountRangeEnd)) {
            Decimal startAmount = Decimal.valueOf(amountRangeStart);
            Decimal endAmount = Decimal.valueOf(amountRangeEnd);
            feeConditions.add('TotalFeeAmount >= ' + startAmount + ' AND TotalFeeAmount <= ' + endAmount);
        }
    
        String refundAmount = (String)params.get('refundAmount');
        if (String.isNotBlank(refundAmount)) {
            feeConditions.add('TotalFeeAmount = ' + Decimal.valueOf(refundAmount));
        }
    
        String refundDate = (String)params.get('refundDate');
        if (String.isNotBlank(refundDate)) {
            Date searchDate = Date.valueOf(refundDate);
            feeConditions.add('Transaction_Date__c = :searchDate');
        }
    
        // Build and execute the query
        String feeQuery = 'SELECT ParentRecordId FROM RegulatoryTrxnFee WHERE ' + 
                         String.join(feeConditions, ' AND ');
        
        System.debug('Fee Query: ' + feeQuery);
        
        Set<Id> applicationIds = new Set<Id>();
        
        // Execute query to get applications with matching refund transaction fees
        for (RegulatoryTrxnFee fee : Database.query(feeQuery,AccessLevel.USER_MODE)) {
            applicationIds.add(fee.ParentRecordId);
        }
    
        return applicationIds;
    }
    
    private static String buildQuery(Map<String, Object> params, Set<Id> qualifyingApplicationIds) {
        String baseQuery = 'SELECT Id, First_Name__c, Last_Name__c, Work_Order_Status__c, Sequence_Number__c, CreatedDate ' +
                          'FROM IndividualApplication ' +
                          'WHERE RecordTypeId = :recordTypeId';
        
        // Only add the IN clause if we have qualifying application IDs
        if (!qualifyingApplicationIds.isEmpty()) {
            baseQuery += ' AND Id IN :qualifyingApplicationIds';
        } else {
            // Force empty results by adding an impossible condition
            baseQuery += ' AND Id = null';
        }
        
        List<String> conditions = new List<String>();
        
        addFilterCondition(conditions, 'First_Name__c', (String)params.get('firstName'), false);
        addFilterCondition(conditions, 'Last_Name__c', (String)params.get('lastName'), false);
    
        String fromDate = (String)params.get('transactionFromDate');
        String toDate = (String)params.get('transactionToDate');
        if (String.isNotBlank(fromDate) && String.isNotBlank(toDate)) {
            conditions.add('CreatedDate >= ' + formatDateForSOQL(Date.valueOf(fromDate)) +
                         ' AND CreatedDate <= ' + formatDateForSOQL(Date.valueOf(toDate)));
        }
    
        if (!conditions.isEmpty()) {
            baseQuery += ' AND ' + String.join(conditions, ' AND ');
        }
    
        String sortBy = (String)params.get('sortBy');
        String sortDirection = (String)params.get('sortDirection');
        if (String.isNotBlank(sortBy)) {
            baseQuery += ' ORDER BY ' + getSortField(sortBy) + ' ' + sortDirection + ' NULLS LAST';
        }
    
        Integer offsetVal = (Integer)params.get('offsetVal');
        Integer pageSize = (Integer)params.get('pageSize');
        baseQuery += ' LIMIT ' + pageSize + ' OFFSET ' + offsetVal;
    
        return baseQuery;
    }


    private static void addFilterCondition(List<String> conditions, String field, String value, Boolean isNumberField) {
        if (String.isNotBlank(value)) {
            if (isNumberField) {
                conditions.add(field + ' = ' + Decimal.valueOf(value));
            } else {
                conditions.add(field + ' LIKE \'%' + String.escapeSingleQuotes(value) + '%\'');
            }
        }
    }    

    private static String formatDateForSOQL(Date d) {
        return d != null ? Datetime.newInstance(d.year(), d.month(), d.day()).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'') : '';
    }

    private static Map<Id, List<Map<String, Object>>> getFeeItemsForApplications(List<IndividualApplication> applications, Map<String, Object> params) {
        Map<Id, List<Map<String, Object>>> feeMap = new Map<Id, List<Map<String, Object>>>();
        if (applications.isEmpty()) return feeMap;

        Set<Id> applicationIds = new Map<Id, IndividualApplication>(applications).keySet();
        
        String feeQuery = 'SELECT Id, Refund_ID__c, Refund_Reason__c, Payment_Type__c, TotalFeeAmount, ' +
                       'amount__c, Refund_Voucher_ID__c, Transaction_Date__c, CK_Number__c, Transaction_Status__c, ' +
                       'ParentRecordId ' +
                       'FROM RegulatoryTrxnFee ' +
                       'WHERE ParentRecordId IN :applicationIds ' +
                       'AND RecordTypeId = :feeRecordTypeId';

        List<String> feeConditions = new List<String>();
        
        addFilterCondition(feeConditions, 'Refund_ID__c', (String)params.get('refundId'), false);
        addFilterCondition(feeConditions, 'Refund_Reason__c', (String)params.get('rejectionReason'), false);
        addFilterCondition(feeConditions, 'Payment_Type__c', (String)params.get('refundMethod'), false);        
        addFilterCondition(feeConditions, 'Refund_Voucher_ID__c', (String)params.get('checkCC'), true);

        String status = (String)params.get('status');
        if (String.isNotBlank(status)) {
            feeConditions.add('Transaction_Status__c = \'' + String.escapeSingleQuotes(status) + '\'');
        }    

        String refundDate = (String)params.get('refundDate');
        if (String.isNotBlank(refundDate)) {
            Date searchDate = Date.valueOf(refundDate);
            feeConditions.add('Transaction_Date__c = :searchDate');
        }

        if (!feeConditions.isEmpty()) {
            feeQuery += ' AND ' + String.join(feeConditions, ' AND ');
        }
        
        System.debug('Final fee item query: ' + feeQuery);

        for (RegulatoryTrxnFee fee : Database.query(feeQuery, AccessLevel.USER_MODE)) {
            if (!feeMap.containsKey(fee.ParentRecordId)) {
                feeMap.put(fee.ParentRecordId, new List<Map<String, Object>>());
            }
            feeMap.get(fee.ParentRecordId).add(new Map<String, Object>{
                'id' => fee.Id,
                'voucherId' => fee.Refund_Voucher_ID__c,
                'rejectionReason' => capitalizeFirstLetter(fee.Refund_Reason__c),
                'refundMethod' => fee.Payment_Type__c,
                'refundAmount' => fee.TotalFeeAmount,
                'checkCC' => fee.CK_Number__c,
                'refundDate' => fee.Transaction_Date__c,
                'status' => fee.Transaction_Status__c,
                'refundId' => fee.Refund_ID__c  
            });
        }

        return feeMap;
    }

    private static String getSortField(String sortBy) {
        Map<String, String> sortFieldMap = new Map<String, String>{
            'firstName' => 'First_Name__c',
            'lastName' => 'Last_Name__c',
            'workOrderNumber' => 'Sequence_Number__c'
        };
        return sortFieldMap.containsKey(sortBy) ? sortFieldMap.get(sortBy) : sortBy;
    }

    private static List<Map<String, Object>> processApplicationResults(List<IndividualApplication> applications, Map<Id, List<Map<String, Object>>> feeMap) {
        List<Map<String, Object>> result = new List<Map<String, Object>>();

        for (IndividualApplication app : applications) {
            List<Map<String, Object>> fee = feeMap.containsKey(app.Id) ? 
                                               feeMap.get(app.Id) : 
                                               new List<Map<String, Object>>();
            
            Map<String, Object> applicationData = new Map<String, Object>{
                'id' => app.Id,
                'firstName' => capitalizeFirstLetter(app.First_Name__c),
                'lastName' => capitalizeFirstLetter(app.Last_Name__c),
                'workOrderNumber' => app.Sequence_Number__c,
                'feeItems' => fee
            };

            result.add(applicationData);
        }

        return result;
    }

    @AuraEnabled(cacheable=true)
    public static Integer getApplicationsCount(String paramsJson) {
        try {
            Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(paramsJson);
    
            Set<Id> qualifyingApplicationIds = getQualifyingApplicationIds(params);
            
            // Return 0 if no qualifying applications found
            if (qualifyingApplicationIds.isEmpty()) {
                return 0;
            }
    
            List<String> conditions = new List<String>();
            conditions.add('RecordTypeId = :recordTypeId');
            conditions.add('Id IN :qualifyingApplicationIds');
    
            addFilterCondition(conditions, 'First_Name__c', (String)params.get('firstName'), false);
            addFilterCondition(conditions, 'Last_Name__c', (String)params.get('lastName'), false);
    
            String fromDate = (String)params.get('transactionFromDate');
            String toDate = (String)params.get('transactionToDate');
            if (String.isNotBlank(fromDate) && String.isNotBlank(toDate)) {
                conditions.add('CreatedDate >= ' + formatDateForSOQL(Date.valueOf(fromDate)));
                conditions.add('CreatedDate <= ' + formatDateForSOQL(Date.valueOf(toDate)));
            }
    
            String query = 'SELECT COUNT(Id) cnt FROM IndividualApplication WHERE ' + 
                           String.join(conditions, ' AND ');
    
            List<AggregateResult> results = Database.query(query, AccessLevel.USER_MODE);
            return (results != null && !results.isEmpty()) ? (Integer)results[0].get('cnt') : 0;
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching application count: ' + e.getMessage());
        }
    }

    private static String capitalizeFirstLetter(String inputString) {
        if (String.isBlank(inputString)) {
            return '';
        }
        String formattedString = inputString.substring(0, 1).toUpperCase() + inputString.substring(1).toLowerCase();
        return formattedString;
    }

    
}