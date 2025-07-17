public with sharing class SAP_ApostilePaymentHistory {

    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getTransaction(String paramsJson) {
        try {
            Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(paramsJson);
            String query = buildQuery(params);
            List<RegulatoryTrxnFee> transactionsList = Database.query(query);

            Set<Id> parentRecordIds = new Set<Id>();

            for (RegulatoryTrxnFee txn : transactionsList) {
                if (txn.ParentRecordId != null) {
                    parentRecordIds.add(txn.ParentRecordId);
                }
            }

            Map<Id, IndividualApplication> relatedApplications = new Map<Id, IndividualApplication>();
            if (!parentRecordIds.isEmpty()) {
                relatedApplications = new Map<Id, IndividualApplication>(
                    [SELECT Id, SAP_Sequence_Number__c, SAP_First_Name__c, SAP_Last_Name__c 
                     FROM IndividualApplication 
                     WHERE Id IN :parentRecordIds]
                );
            }

           return processTransactionResults(transactionsList, relatedApplications);

        } catch (Exception e) {
            throw new AuraHandledException('Error fetching data: ' + e.getMessage());
        }
    }

    private static String buildQuery(Map<String, Object> params) {
        String query = 'SELECT Id, SAP_Transaction_Date__c, SAP_Auth_Code__c, Name, Status, SAP_Card_Number__c, SAP_Card_Type__c, SAP_Brand__c, ' +
                       'CreatedDate, SAP_Transaction_Status__c, SAP_Credit_Card_Type__c,SAP_Credit_Card_Owner__c, SAP_Payment_Type__c, TotalFeeAmount, ' +
                       'SAP_Refund_Denied_Reason__c, SAP_Payment_Method__c,(SELECT Id, Name From RegulatoryTrxnFeeItems), ParentRecordId ' +
                       'FROM RegulatoryTrxnFee WHERE ParentRecord.RecordType.Name = \'Apostille\'' +
                       'AND SAP_Payment_Type__c = \'Card\' ';
    
        if (params.containsKey('RegulatoryTrxnFeeId') && params.get('RegulatoryTrxnFeeId') != null) {
            query += ' AND Id = \'' + String.escapeSingleQuotes((String)params.get('RegulatoryTrxnFeeId')) + '\' ';
        }
    
        if (params.containsKey('sortBy') && params.get('sortBy') != null) {
            String sortField = getSortField((String)params.get('sortBy'));
            String sortDirection = (String)params.get('sortDirection');
            query += ' ORDER BY ' + String.escapeSingleQuotes(sortField) + ' ' + String.escapeSingleQuotes(sortDirection);
        }
    
        Integer offsetVal = (Integer)params.get('offsetVal');
        Integer pageSize = (Integer)params.get('pageSize');
        query += ' LIMIT ' + pageSize + ' OFFSET ' + offsetVal;
    
        return query;
    }
    
    private static String getSortField(String sortBy) {
        Map<String, String> sortFieldMap = new Map<String, String>{
            'PaymentAmount' => 'TotalFeeAmount',
            'CreditCardName' => 'SAP_Credit_Card_Owner__c',
            'AuthCode' => 'SAP_Auth_Code__c',
            'TransactionStatus' => 'SAP_Transaction_Status__c',
            'TransactionDate' => 'CreatedDate'
        };
        return sortFieldMap.containsKey(sortBy) ? sortFieldMap.get(sortBy) : sortBy;
    }

    private static List<Map<String, Object>> processTransactionResults(List<RegulatoryTrxnFee> transactionsList, Map<Id, IndividualApplication> relatedApplications) {
        List<Map<String, Object>> results = new List<Map<String, Object>>();
    
        for (RegulatoryTrxnFee txn : transactionsList) {
            Map<String, Object> result = new Map<String, Object>{
                'Id' => txn.Id,
                'TransactionDate' => formatDateTime(txn.CreatedDate),
                'AuthCode' => txn.SAP_Auth_Code__c,
                'PaymentAmount' => txn.TotalFeeAmount,
                'PaymentType' => txn.SAP_Payment_Type__c,
                'CreditCardName' => txn.SAP_Credit_Card_Owner__c,
                'TransactionStatus' => txn.Status,
                'CardName' => txn.SAP_Brand__c,
                'CardLastDigit' => txn.SAP_Card_Number__c
            };
    

            List<String> childNames = new List<String>();
            if (txn.RegulatoryTrxnFeeItems != null && !txn.RegulatoryTrxnFeeItems.isEmpty()) {
                for (RegulatoryTrxnFeeItem item : txn.RegulatoryTrxnFeeItems) {
                    childNames.add(item.Name);  
                }
            }
            result.put('ChildNames', childNames);

            
            if (relatedApplications.containsKey(txn.ParentRecordId)) {
                IndividualApplication app = relatedApplications.get(txn.ParentRecordId);
                result.put('WorkorderNumber', app.SAP_Sequence_Number__c);
                result.put('Name', app.SAP_First_Name__c + ' ' + app.SAP_Last_Name__c);
                result.put('IndiAppId', app.Id);
            }
    
            results.add(result);
        }
    
        return results;
    }
    

    private static String formatDateTime(DateTime dt) {
        if (dt == null) return '';
        return dt.format('MM/dd/yyyy | hh:mm:ss a');
    }
    @AuraEnabled(cacheable=true)
    public static Integer getTransactionCount() {
        // Query to get the count
        String countQuery = 'SELECT COUNT(Id) FROM RegulatoryTrxnFee WHERE ParentRecord.RecordType.Name = \'Apostille\' ';
        system.debug('count query: ' + countQuery);
    
        // Run the query
        AggregateResult[] results = Database.query(countQuery);
    
        // Extract the count from the AggregateResult
        Integer count = (Integer) results[0].get('expr0');
    
        // Return the count
        return count;
    }

    
}