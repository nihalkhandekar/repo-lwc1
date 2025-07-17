public with sharing class SearchOrderController {
    static Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Extradition_Official').getRecordTypeId();
    
    @AuraEnabled
    public static List<Map<String, Object>> getPublicOfficials(String paramsJson) {
        try {
            Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(paramsJson);
            String query = buildQuery(params);
            List<Contact> conList = Database.query(query);
            return convertToMapList(conList);
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching data: ' + e.getMessage());
        }
    }
    
    private static String buildQuery(Map<String, Object> params) {
        String firstName = (String)params.get('firstName');
        String lastName = (String)params.get('lastName');
        String termStart = (String)params.get('termStart');
        String termEnd = (String)params.get('termEnd');
        String position = (String)params.get('position');
        String judicialDistrict = (String)params.get('judicialDistrict');
     
        Integer offsetVal = (Integer)params.get('offsetVal');
        Boolean indefiniteTerm = (Boolean)params.get('indefiniteTerm');
    
        Integer pageSize = (Integer)params.get('pageSize');
        String sortBy = (String)params.get('sortBy');
        String sortDirection = (String)params.get('sortDirection');
    
        Date transactionFromDate = null;
        Date transactionToDate = null;
    
        if (params.containsKey('transactionFromDate') && params.get('transactionFromDate') != null) {
            transactionFromDate = Date.valueOf((String)params.get('transactionFromDate'));
        }
        if (params.containsKey('transactionToDate') && params.get('transactionToDate') != null) {
            transactionToDate = Date.valueOf((String)params.get('transactionToDate'));
        }
    
        String query = 'SELECT Id, FirstName, LastName, Start_Term__c, End_Term__c, Position__c, Judicial_District__c, Indefinite_Term__c, CreatedDate ' +
                       'FROM Contact WHERE RecordTypeId = \'' + recordTypeId + '\'';
    
        if (String.isNotBlank(firstName)) {
            query += ' AND FirstName LIKE \'%' + String.escapeSingleQuotes(firstName) + '%\'';
        }
        if (String.isNotBlank(lastName)) {
            query += ' AND LastName LIKE \'%' + String.escapeSingleQuotes(lastName) + '%\'';
        }
        if (String.isNotBlank(termStart)) {
            query += ' AND Start_Term__c = ' + String.escapeSingleQuotes(termStart);
        }
        if (String.isNotBlank(termEnd)) {
            query += ' AND End_Term__c = ' + String.escapeSingleQuotes(termEnd);
        }
        if (String.isNotBlank(position)) {
            query += ' AND Position__c = \'' + String.escapeSingleQuotes(position) + '\'';
        }
        if (String.isNotBlank(judicialDistrict)) {
            query += ' AND Judicial_District__c = \'' + String.escapeSingleQuotes(judicialDistrict) + '\'';
        }
        if (indefiniteTerm != null) {
            query += ' AND Indefinite_Term__c = ' + indefiniteTerm;
        }
    
        if (transactionFromDate != null || transactionToDate != null) {
            if (transactionFromDate != null) {
                DateTime fromDateTime = DateTime.newInstance(transactionFromDate, Time.newInstance(0, 0, 0, 0));
                query += ' AND CreatedDate >= ' + fromDateTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
            }
            if (transactionToDate != null) {
                DateTime toDateTime = DateTime.newInstance(transactionToDate, Time.newInstance(23, 59, 59, 999));
                query += ' AND CreatedDate <= ' + toDateTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
            }
        }
    
        if (String.isNotBlank(sortBy)) {
            String sortField = getSortField(sortBy);
            query += ' ORDER BY ' + String.escapeSingleQuotes(sortField) + ' ' + String.escapeSingleQuotes(sortDirection)+ ' NULLS LAST';
        } 

        query += ' LIMIT ' + pageSize + ' OFFSET ' + offsetVal;
        System.debug('final build query: ' + query);
    
        return query;
    }

    private static String formatCustomDateTime(DateTime dt) {
        if (dt == null) return null;
        Date dateOnly = dt.dateGmt();
        String formattedMonth = (dateOnly.month() < 10) ? '0' + String.valueOf(dateOnly.month()) : String.valueOf(dateOnly.month());
        String formattedDay = (dateOnly.day() < 10) ? '0' + String.valueOf(dateOnly.day()) : String.valueOf(dateOnly.day());
        return formattedMonth + '/' + formattedDay + '/' + dateOnly.year();
    }
    
    private static String getSortField(String sortBy) {
        Map<String, String> sortFieldMap = new Map<String, String>{
            'firstName' => 'FirstName',
            'lastName' => 'LastName',
            'termStart' => 'Start_Term__c',
            'termEnd' => 'End_Term__c',
            'position' => 'Position__c',
            'judicialDistrict' => 'Judicial_District__c',
            'indefiniteTerm' => 'Indefinite_Term__c',
            'LastModifiedDate' => 'LastModifiedDate'
        };
        
        return sortFieldMap.containsKey(sortBy) ? sortFieldMap.get(sortBy) : 'LastName';
    }
    
    private static List<Map<String, Object>> convertToMapList(List<Contact> contacts) {
        List<Map<String, Object>> result = new List<Map<String, Object>>();
        
        for (Contact con : contacts) {
            Map<String, Object> conMap = new Map<String, Object>{
                'Id' => con.Id,
                'FirstName' => con.FirstName,
                'LastName' => con.LastName,
                'Start_Term__c' => formatCustomDateTime(con.Start_Term__c),
                'End_Term__c' => formatCustomDateTime(con.End_Term__c),
                'Position__c' => con.Position__c,
                'Judicial_District__c' => con.Judicial_District__c,
                'Indefinite_Term__c' => con.Indefinite_Term__c,
                'CreatedDate' => con.CreatedDate
            };
            result.add(conMap);
        }
        
        return result;
    }

    @AuraEnabled
    public static Integer getOfficialsCount(Map<String, Object> parameters) {
        // Extract parameters from the map
    String firstName = (String) parameters.get('firstName');
    String lastName = (String) parameters.get('lastName');
    String termStart = (String) parameters.get('termStart');
    String termEnd = (String) parameters.get('termEnd');
    String position = (String) parameters.get('position');
    String judicialDistrict = (String) parameters.get('judicialDistrict');
    Boolean indefiniteTerm = (Boolean) parameters.get('indefiniteTerm');
    String transactionFromDate = (String) parameters.get('transactionFromDate');
    String transactionToDate = (String) parameters.get('transactionToDate');
    
        String query = buildCountQuery(parameters);
    
        List<AggregateResult> countResult = Database.query(query);
        System.debug('Query result: ' + countResult);
                                       
        Integer count = (Integer)countResult[0].get('cnt');
        System.debug('Count result: ' + count);
                                       
        return count;
    }
    
    private static String buildCountQuery(Map<String, Object> parameters) {
        String firstName = (String) parameters.get('firstName');
    String lastName = (String) parameters.get('lastName');
    String termStart = (String) parameters.get('termStart');
    String termEnd = (String) parameters.get('termEnd');
    String position = (String) parameters.get('position');
    String judicialDistrict = (String) parameters.get('judicialDistrict');
    Boolean indefiniteTerm = (Boolean) parameters.get('indefiniteTerm');
    String transactionFromDate = (String) parameters.get('transactionFromDate');
    String transactionToDate = (String) parameters.get('transactionToDate');
    
        String query = 'SELECT COUNT(Id) cnt FROM Contact WHERE RecordTypeId = :recordTypeId';
    
        if (String.isNotBlank(firstName)) {
            query += ' AND FirstName LIKE \'%' + String.escapeSingleQuotes(firstName) + '%\'';
        }
        if (String.isNotBlank(lastName)) {
            query += ' AND LastName LIKE \'%' + String.escapeSingleQuotes(lastName) + '%\'';
        }
        if (String.isNotBlank(termStart)) {
            query += ' AND Start_Term__c = ' + String.escapeSingleQuotes(termStart);
        }
        if (String.isNotBlank(termEnd)) {
            query += ' AND End_Term__c = ' + String.escapeSingleQuotes(termEnd);
        }
        if (String.isNotBlank(position)) {
            query += ' AND Position__c = \'' + String.escapeSingleQuotes(position) + '\'';
        }
        if (String.isNotBlank(judicialDistrict)) {
            query += ' AND Judicial_District__c = \'' + String.escapeSingleQuotes(judicialDistrict) + '\'';
        }
        if (indefiniteTerm != null) {
        query += ' AND Indefinite_Term__c = ' + indefiniteTerm;
    }
    

        if (String.isNotBlank(transactionFromDate) || String.isNotBlank(transactionToDate)) {
            if (String.isNotBlank(transactionFromDate)) {
                Date fromDate = Date.valueOf(transactionFromDate);
                DateTime fromDateTime = DateTime.newInstance(fromDate, Time.newInstance(0, 0, 0, 0));
                query += ' AND CreatedDate >= ' + fromDateTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
            }
            if (String.isNotBlank(transactionToDate)) {
                Date toDate = Date.valueOf(transactionToDate);
                DateTime toDateTime = DateTime.newInstance(toDate, Time.newInstance(23, 59, 59, 999));
                query += ' AND CreatedDate <= ' + toDateTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
            }
        }
        System.debug('final count query: '+query);
        return query;
    }
    
}