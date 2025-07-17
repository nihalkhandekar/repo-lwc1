public with sharing class IndividualApplicationStateSealController {
    @AuraEnabled
    public static List<IndividualApplication> searchApplications(Map<String, Object> searchCriteria) {
        String stateSealRecordTypeId = '';
        try {
            stateSealRecordTypeId = [
                SELECT Id 
                FROM RecordType 
                WHERE DeveloperName = 'State_Seal' AND SObjectType = 'IndividualApplication'
                LIMIT 1
            ].Id;
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching RecordTypeId for State Seal: ' + e.getMessage());
        }
        
        if (String.isBlank(stateSealRecordTypeId)) {
            throw new AuraHandledException('RecordTypeId for State Seal not found.');
        }

        List<String> conditions = new List<String>();
        conditions.add('RecordTypeId = :stateSealRecordTypeId');
        Set<Id> matchingIds = new Set<Id>();
    
        // Extract parameters with null checks
        String letterText = (String)searchCriteria.get('letterText');
        String proposedUse = (String)searchCriteria.get('proposedUse');
        String lastName = (String)searchCriteria.get('lastName');
        String firstName = (String)searchCriteria.get('firstName');
        String city = (String)searchCriteria.get('city');
        String email = (String)searchCriteria.get('email');
        String disposition = (String)searchCriteria.get('disposition');
        String approvedFor = (String)searchCriteria.get('approvedFor');
        String entity = (String)searchCriteria.get('entity');
        Date transactionDate = (Date)searchCriteria.get('transactionDate');
        Date startDate = (Date)searchCriteria.get('startDate');
        Date endDate = (Date)searchCriteria.get('endDate');
        Integer pageSize = searchCriteria.get('pageSize') != null 
        ? Integer.valueOf(searchCriteria.get('pageSize')) 
        : null;
        Integer pageNumber = searchCriteria.get('pageNumber') != null 
            ? Integer.valueOf(searchCriteria.get('pageNumber')) 
            : null;
        String sortedBy = (String)searchCriteria.get('sortedBy');
        String sortedDirection = (String)searchCriteria.get('sortedDirection');
    
        // Use SOSL to get matching IDs for 'letterText' and 'proposedUse'
        if (String.isNotBlank(letterText) || String.isNotBlank(proposedUse)) {
            String soslQuery = 'FIND \'%' + String.escapeSingleQuotes(letterText != null ? letterText : proposedUse) + '%\' IN ALL FIELDS RETURNING IndividualApplication (Id)';
            List<List<IndividualApplication>> soslResults = search.query(soslQuery);
            
            if (!soslResults.isEmpty() && !soslResults[0].isEmpty()) {
                for (IndividualApplication app : soslResults[0]) {
                    matchingIds.add(app.Id);
                }
            }
            
            // If no matching SOSL results, return an empty list
            if (matchingIds.isEmpty()) {
                return new List<IndividualApplication>();
            }
    
            // Add the SOSL condition to filter the SOQL results by matching IDs
            conditions.add('Id IN :matchingIds');
        }
    
        // Add other conditions for the SOQL query
        if (String.isNotBlank(lastName)) {
            conditions.add('Last_Name__c LIKE \'%' + String.escapeSingleQuotes(lastName) + '%\'');
        }
        if (String.isNotBlank(firstName)) {
            conditions.add('First_Name__c LIKE \'%' + String.escapeSingleQuotes(firstName) + '%\'');
        }
        if (String.isNotBlank(city)) {
            conditions.add('City__c LIKE \'%' + String.escapeSingleQuotes(city) + '%\'');
        }
        if (String.isNotBlank(email)) {
            conditions.add('Email_Address__c LIKE \'%' + String.escapeSingleQuotes(email) + '%\'');
        }
        if (String.isNotBlank(disposition)) {
            conditions.add('Disposition__c = \'' + String.escapeSingleQuotes(disposition) + '\'');
        }
        if (String.isNotBlank(approvedFor)) {
            conditions.add('Approved_For__c = \'' + String.escapeSingleQuotes(approvedFor) + '\'');
        }
        if (String.isNotBlank(entity)) {
            conditions.add('Organization_Name__c LIKE \'%' + String.escapeSingleQuotes(entity) + '%\'');
        }
        if (transactionDate != null) {
            conditions.add('Date_of_SOTS_Response__c = :transactionDate');
        }
        if (startDate != null && endDate != null) {
            conditions.add('Date_of_SOTS_Response__c >= :startDate AND Date_of_SOTS_Response__c <= :endDate');
        }
    
        String query = 'SELECT Id, Application_ID__c, Last_Name__c, First_Name__c, Address_Line_1__c, Organization_Name__c, City__c, Date_of_SOTS_Response__c, Letter_Type__c, Disposition__c ' + 
                       'FROM IndividualApplication ';
        
        if (!conditions.isEmpty()) {
            query += 'WHERE ' + String.join(conditions, ' AND ');
        }
    
        String defaultSortBy = String.isNotBlank(sortedBy) ? sortedBy : 'CreatedDate';
        String defaultSortDirection = (sortedDirection == 'ASC' || sortedDirection == 'DESC') ? sortedDirection : 'DESC';
        query += ' ORDER BY ' + defaultSortBy + ' ' + defaultSortDirection + ' NULLS LAST ';
    
        Integer offset = (pageNumber != null && pageNumber > 0) ? (pageNumber - 1) * pageSize : 0;
        query += ' LIMIT :pageSize OFFSET :offset';
    
        return Database.query(query);
    }
    

    @AuraEnabled
    public static Integer searchApplicationCount(Map<String, Object> searchCriteria) {
        List<String> conditions = new List<String>();
        conditions.add('RecordTypeId = \'0123S000001MsK8QAK\'');
        Set<Id> matchingIds = new Set<Id>();

        // Extract parameters with null checks
        String letterText = (String)searchCriteria.get('letterText');
        String proposedUse = (String)searchCriteria.get('proposedUse');
        String lastName = (String)searchCriteria.get('lastName');
        String firstName = (String)searchCriteria.get('firstName');
        String city = (String)searchCriteria.get('city');
        String email = (String)searchCriteria.get('email');
        String disposition = (String)searchCriteria.get('disposition');
        String approvedFor = (String)searchCriteria.get('approvedFor');
        String entity = (String)searchCriteria.get('entity');
        Date transactionDate = (Date)searchCriteria.get('transactionDate');
        Date startDate = (Date)searchCriteria.get('startDate');
        Date endDate = (Date)searchCriteria.get('endDate');

        // Use SOSL to get matching IDs for 'letterText' and 'proposedUse'
        if (String.isNotBlank(letterText) || String.isNotBlank(proposedUse)) {
            String soslQuery = 'FIND \'%' + String.escapeSingleQuotes(letterText != null ? letterText : proposedUse) + '%\' IN ALL FIELDS RETURNING IndividualApplication (Id)';
            List<List<IndividualApplication>> soslResults = search.query(soslQuery);
            
            if (!soslResults.isEmpty() && !soslResults[0].isEmpty()) {
                for (IndividualApplication app : soslResults[0]) {
                    matchingIds.add(app.Id);
                }
            }
            
            // If no matching SOSL results, return a count of 0
            if (matchingIds.isEmpty()) {
                return 0;
            }

            // Add the SOSL condition to filter the SOQL results by matching IDs
            conditions.add('Id IN :matchingIds');
        }

        // Add other conditions for the SOQL query
        if (String.isNotBlank(lastName)) {
            conditions.add('Last_Name__c LIKE \'%' + String.escapeSingleQuotes(lastName) + '%\'');
        }
        if (String.isNotBlank(firstName)) {
            conditions.add('First_Name__c LIKE \'%' + String.escapeSingleQuotes(firstName) + '%\'');
        }
        if (String.isNotBlank(city)) {
            conditions.add('City__c LIKE \'%' + String.escapeSingleQuotes(city) + '%\'');
        }
        if (String.isNotBlank(email)) {
            conditions.add('Email_Address__c LIKE \'%' + String.escapeSingleQuotes(email) + '%\'');
        }
        if (String.isNotBlank(disposition)) {
            conditions.add('Disposition__c = \'' + String.escapeSingleQuotes(disposition) + '\'');
        }
        if (String.isNotBlank(approvedFor)) {
            conditions.add('Approved_For__c = \'' + String.escapeSingleQuotes(approvedFor) + '\'');
        }
        if (String.isNotBlank(entity)) {
            conditions.add('Organization_Name__c LIKE \'%' + String.escapeSingleQuotes(entity) + '%\'');
        }
        if (transactionDate != null) {
            conditions.add('Date_of_SOTS_Response__c = :transactionDate');
        }
        if (startDate != null && endDate != null) {
            conditions.add('Date_of_SOTS_Response__c >= :startDate AND Date_of_SOTS_Response__c <= :endDate');
        }

        String query = 'SELECT COUNT() FROM IndividualApplication ';
        if (!conditions.isEmpty()) {
            query += 'WHERE ' + String.join(conditions, ' AND ');
        }

        return Database.countQuery(query);
    }

    // Existing updateIndividualApplication method remains the same
    @AuraEnabled
    public static void updateIndividualApplication(Id recordId, String signedBy, String letterType, String wetSignature) {
        IndividualApplication application = [SELECT Id, Signedby__c, Letter_Type__c, Wet_Signature__c 
                                             FROM IndividualApplication 
                                             WHERE Id = :recordId LIMIT 1];

        application.Signedby__c = signedBy;
        application.Letter_Type__c = letterType;
        application.Wet_Signature__c = wetSignature;

        update application;
    }
}