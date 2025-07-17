/*********************************************************************************************
* NAME: SAP_FinsysRefundController
* DESCRIPTION: Controller class for managing Refund transactions and retrieving Individual Applications
*********************************************************************************************/
public with sharing class SAP_FinsysRefundController {
    // Record Type IDs for different transaction types
    static Id recordTypeId = Schema.SObjectType.IndividualApplication.getRecordTypeInfosByDeveloperName().get('FinSys').getRecordTypeId();
    static Id feeRecordTypeId = Schema.SObjectType.RegulatoryTrxnFee.getRecordTypeInfosByDeveloperName().get('Refund_Transaction').getRecordTypeId();

    /*********************************************************************************************
    * METHOD: getWorkOrderApplication
    * DESCRIPTION: Retrieves Individual Applications with associated refund transactions
    * PARAMS: 
    *   - paramsJson: JSON string containing filter and pagination parameters
    * RETURNS: List of processed application results with refund details
    * COMPLEXITY: Supports multiple filtering conditions, sorting, and pagination
    *********************************************************************************************/
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
    /*********************************************************************************************
    * METHOD: getQualifyingApplicationIds
    * DESCRIPTION: Identifies application IDs matching specific refund transaction criteria
    * PARAMS: 
    *   - params: Map of filter parameters for refund transactions
    * RETURNS: Set of application IDs that match the specified conditions
    * COMPLEXITY: Dynamically builds complex query to filter refund transactions
    *********************************************************************************************/    
    private static Set<Id> getQualifyingApplicationIds(Map<String, Object> params) {
        List<String> feeConditions = new List<String>();
        // Always include the base record type condition
        feeConditions.add('RecordTypeId = :feeRecordTypeId');
       
        addFilterCondition(feeConditions, 'SAP_Refund_ID__c', (String)params.get('refundId'), false);
        addFilterCondition(feeConditions, 'SAP_Refund_Reason__c', (String)params.get('rejectionReason'), false);
        addFilterCondition(feeConditions, 'SAP_Payment_Type__c', (String)params.get('refundMethod'), false);        
        addFilterCondition(feeConditions, 'SAP_Refund_Voucher_ID__c', (String)params.get('checkCC'), true);
    
        String status = (String)params.get('status');
        if (String.isNotBlank(status)) {
            feeConditions.add('SAP_Transaction_Status__c = \'' + String.escapeSingleQuotes(status) + '\'');
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
            feeConditions.add('SAP_Transaction_Date__c = :searchDate');
        }
        // Build and execute the query
        String feeQuery = 'SELECT ParentRecordId FROM RegulatoryTrxnFee WHERE ' + 
                         String.join(feeConditions, ' AND ');        
        Set<Id> applicationIds = new Set<Id>();
        // Execute query to get applications with matching refund transaction fees
        for (RegulatoryTrxnFee fee : Database.query(feeQuery,AccessLevel.USER_MODE)) {
            applicationIds.add(fee.ParentRecordId);
        }
        return applicationIds;
    }
    /*********************************************************************************************
    * METHOD: buildQuery
    * DESCRIPTION: Dynamically builds a query for Individual Applications based on filter parameters
    * PARAMS: 
    *   - params: Map of filter parameters
    *   - qualifyingApplicationIds: Set of application IDs matching fee item criteria
    * RETURNS: Dynamically constructed SOQL query string for Individual Applications
    * COMPLEXITY: Supports multiple filter conditions, sorting, and pagination
    *********************************************************************************************/    
    private static String buildQuery(Map<String, Object> params, Set<Id> qualifyingApplicationIds) {
        String baseQuery = 'SELECT Id, SAP_First_Name__c, SAP_Last_Name__c, SAP_Work_Order_Status__c, SAP_Sequence_Number__c, CreatedDate ' +
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
        addFilterCondition(conditions, 'SAP_First_Name__c', (String)params.get('firstName'), false);
        addFilterCondition(conditions, 'SAP_Last_Name__c', (String)params.get('lastName'), false);
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
    /*********************************************************************************************
        * METHOD: addFilterCondition
        * DESCRIPTION: Utility method to add filter conditions to a list of query conditions
        * PARAMS: 
        *   - conditions: List of existing conditions to be modified
        *   - field: Field name to apply the filter
        *   - value: Filter value
        *   - isNumberField: Flag to determine string or number comparison
        * RETURNS: void (modifies the conditions list in-place)
        * COMPLEXITY: Supports dynamic filtering for different field types
        *********************************************************************************************/
    private static void addFilterCondition(List<String> conditions, String field, String value, Boolean isNumberField) {
        if (String.isNotBlank(value)) {
            if (isNumberField) {
                conditions.add(field + ' = ' + Decimal.valueOf(value));
            } else {
                conditions.add(field + ' LIKE \'%' + String.escapeSingleQuotes(value) + '%\'');
            }
        }
    }    

    /*********************************************************************************************
    * METHOD: formatDateForSOQL
    * DESCRIPTION: Converts a Date object to a SOQL-compatible datetime string format
    * PARAMS: 
    *   - d: Date object to be formatted
    * RETURNS: Formatted datetime string for use in SOQL queries
    * COMPLEXITY: Handles null dates and converts to specific datetime string format
    *********************************************************************************************/
    private static String formatDateForSOQL(Date d) {
        return d != null ? Datetime.newInstance(d.year(), d.month(), d.day()).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'') : '';
    }

    /*********************************************************************************************
    * METHOD: getFeeItemsForApplications
    * DESCRIPTION: Retrieves and maps fee items for a list of individual applications
    * PARAMS: 
    *   - applications: List of IndividualApplication records
    *   - params: Map of filter parameters for fee items
    * RETURNS: Map of application IDs to their associated fee items
    * COMPLEXITY: Dynamically builds and executes query with multiple optional filters
    *********************************************************************************************/
    private static Map<Id, List<Map<String, Object>>> getFeeItemsForApplications(List<IndividualApplication> applications, Map<String, Object> params) {
        Map<Id, List<Map<String, Object>>> feeMap = new Map<Id, List<Map<String, Object>>>();
        if (applications.isEmpty()) return feeMap;

        Set<Id> applicationIds = new Map<Id, IndividualApplication>(applications).keySet();
        
        String feeQuery = 'SELECT Id, SAP_Refund_ID__c, SAP_Refund_Reason__c, SAP_Payment_Type__c, TotalFeeAmount, ' +
                       'SAP_amount__c, SAP_Refund_Voucher_ID__c, SAP_Transaction_Date__c, SAP_CK_Number__c, SAP_Transaction_Status__c, ' +
                       'ParentRecordId ' +
                       'FROM RegulatoryTrxnFee ' +
                       'WHERE ParentRecordId IN :applicationIds ' +
                       'AND RecordTypeId = :feeRecordTypeId';

        List<String> feeConditions = new List<String>();
        
        addFilterCondition(feeConditions, 'SAP_Refund_ID__c', (String)params.get('refundId'), false);
        addFilterCondition(feeConditions, 'SAP_Refund_Reason__c', (String)params.get('rejectionReason'), false);
        addFilterCondition(feeConditions, 'SAP_Payment_Type__c', (String)params.get('refundMethod'), false);        
        addFilterCondition(feeConditions, 'SAP_Refund_Voucher_ID__c', (String)params.get('checkCC'), true);

        String status = (String)params.get('status');
        if (String.isNotBlank(status)) {
            feeConditions.add('SAP_Transaction_Status__c = \'' + String.escapeSingleQuotes(status) + '\'');
        }    
        String refundDate = (String)params.get('refundDate');
        if (String.isNotBlank(refundDate)) {
            Date searchDate = Date.valueOf(refundDate);
            feeConditions.add('SAP_Transaction_Date__c = :searchDate');
        }
        if (!feeConditions.isEmpty()) {
            feeQuery += ' AND ' + String.join(feeConditions, ' AND ');
        }
        
        for (RegulatoryTrxnFee fee : Database.query(feeQuery, AccessLevel.USER_MODE)) {
            if (!feeMap.containsKey(fee.ParentRecordId)) {
                feeMap.put(fee.ParentRecordId, new List<Map<String, Object>>());
            }
            feeMap.get(fee.ParentRecordId).add(new Map<String, Object>{
                'id' => fee.Id,
                'voucherId' => fee.SAP_Refund_Voucher_ID__c,
                'rejectionReason' => capitalizeFirstLetter(fee.SAP_Refund_Reason__c),
                'refundMethod' => fee.SAP_Payment_Type__c,
                'refundAmount' => fee.TotalFeeAmount,
                'checkCC' => fee.SAP_CK_Number__c,
                'refundDate' => fee.SAP_Transaction_Date__c,
                'status' => fee.SAP_Transaction_Status__c,
                'refundId' => fee.SAP_Refund_ID__c  
            });
        }

        return feeMap;
    }

    /*********************************************************************************************
    * METHOD: getSortField
    * DESCRIPTION: Translates user-friendly sort parameters to actual Salesforce field names
    * PARAMS: 
    *   - sortBy: User-provided sort parameter
    * RETURNS: Corresponding Salesforce field name for sorting
    * COMPLEXITY: Provides a mapping between display-friendly names and actual field names
    *********************************************************************************************/
    private static String getSortField(String sortBy) {
        Map<String, String> sortFieldMap = new Map<String, String>{
            'firstName' => 'SAP_First_Name__c',
            'lastName' => 'SAP_Last_Name__c',
            'workOrderNumber' => 'SAP_Sequence_Number__c'
        };
        return sortFieldMap.containsKey(sortBy) ? sortFieldMap.get(sortBy) : sortBy;
    }

    /*********************************************************************************************
    * METHOD: processApplicationResults
    * DESCRIPTION: Transforms raw Individual Application records into a structured result format
    * PARAMS: 
    *   - applications: List of IndividualApplication records
    *   - feeMap: Map of application IDs to their associated fee items
    * RETURNS: List of processed application results with associated fee details
    * COMPLEXITY: Formats and enriches application data with capitalized names and fee information
    *********************************************************************************************/
    private static List<Map<String, Object>> processApplicationResults(List<IndividualApplication> applications, Map<Id, List<Map<String, Object>>> feeMap) {
        List<Map<String, Object>> result = new List<Map<String, Object>>();

        for (IndividualApplication app : applications) {
            List<Map<String, Object>> fee = feeMap.containsKey(app.Id) ? 
                                               feeMap.get(app.Id) : 
                                               new List<Map<String, Object>>();
            
            Map<String, Object> applicationData = new Map<String, Object>{
                'id' => app.Id,
                'firstName' => capitalizeFirstLetter(app.SAP_First_Name__c),
                'lastName' => capitalizeFirstLetter(app.SAP_Last_Name__c),
                'workOrderNumber' => app.SAP_Sequence_Number__c,
                'feeItems' => fee
            };

            result.add(applicationData);
        }

        return result;
    }
    /*********************************************************************************************
    * METHOD: getApplicationsCount
    * DESCRIPTION: Calculates total number of applications matching specific refund criteria
    * PARAMS: 
    *   - paramsJson: JSON string with filtering parameters
    * RETURNS: Total count of matching applications
    * COMPLEXITY: Dynamically builds count query with flexible filtering
    *********************************************************************************************/
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
    
            addFilterCondition(conditions, 'SAP_First_Name__c', (String)params.get('firstName'), false);
            addFilterCondition(conditions, 'SAP_Last_Name__c', (String)params.get('lastName'), false);
    
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

    /*********************************************************************************************
    * METHOD: capitalizeFirstLetter
    * DESCRIPTION: Capitalizes the first letter of a given string and converts the rest to lowercase
    * PARAMS: 
    *   - inputString: String to be formatted
    * RETURNS: String with first letter capitalized and remaining letters in lowercase
    * COMPLEXITY: Handles null or empty string inputs safely
    *********************************************************************************************/
    private static String capitalizeFirstLetter(String inputString) {
        if (String.isBlank(inputString)) {
            return '';
        }
        String formattedString = inputString.substring(0, 1).toUpperCase() + inputString.substring(1).toLowerCase();
        return formattedString;
    }
    
}