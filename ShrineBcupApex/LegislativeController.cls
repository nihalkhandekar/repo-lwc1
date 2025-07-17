public with sharing class LegislativeController {
    @AuraEnabled
    public static List<Contact> legislativeData (String selectionCriteriaJson) {
        try {
             // Deserialize the JSON string into a Map
             Map<String, Object> searchCriteria = (Map<String, Object>) JSON.deserializeUntyped(selectionCriteriaJson);

             // Access the values from the Map (you can now access each parameter)
             String firstname = (String) searchCriteria.get('firstname');
             String lastname = (String) searchCriteria.get('lastname');
             String title = (String) searchCriteria.get('title');
             String district = (String) searchCriteria.get('district');
             String party = (String) searchCriteria.get('party');
             Integer pageSize = (Integer) searchCriteria.get('pageSize');
             Integer pageNumber = (Integer) searchCriteria.get('pageNumber');
             String sortedBy = (String) searchCriteria.get('sortedBy');
             String sortedDirection = (String) searchCriteria.get('sortedDirection');
    
            // Initialize the conditions list
            List<String> conditions = new List<String>();
            conditions.add('RecordType.Name = \'Legislator\'');
            System.debug('### Initial condition (RecordTypeId): ' + conditions);
        
        if (String.isNotBlank(title)) {
            conditions.add('Legislator_Title__c = \'' + String.escapeSingleQuotes(title) + '\'');
            System.debug('### title condition added: ' + conditions);
        }
        if (String.isNotBlank(party)) {
            conditions.add('Party__c = \'' + String.escapeSingleQuotes(party) + '\'');
            System.debug('### party condition added: ' + conditions);
        }
        if (String.isNotBlank(lastname)) {
            conditions.add('LastName LIKE \'%' + String.escapeSingleQuotes(lastname) + '%\'');
            System.debug('### lastName condition added: ' + conditions);
        }
        if (String.isNotBlank(firstname)) {
            conditions.add('FirstName LIKE \'%' + String.escapeSingleQuotes(firstname) + '%\'');
            System.debug('### firstName condition added: ' + conditions);
        }
        if (String.isNotBlank(district)) {
            conditions.add('DistrictID__c = \'' + String.escapeSingleQuotes(district) + '\'');
            System.debug('### district condition added: ' + conditions);
        }


        String query = 'SELECT Id, FirstName, LastName, MiddleName, District__c, Party__c, DistrictID__c, Legislator_Title__c, LastModifiedDate FROM Contact';
        
        if (!conditions.isEmpty()) {
            query += ' WHERE ' + String.join(conditions, ' AND ');
        }

        // Debug final query before sorting
        System.debug('### Final query before sorting: ' + query);
    
        String defaultSortBy = String.isNotBlank(sortedBy) ? sortedBy : 'CreatedDate';
        String defaultSortDirection = (sortedDirection == 'ASC' || sortedDirection == 'DESC') ? sortedDirection : 'DESC';
        query += ' ORDER BY ' + defaultSortBy + ' ' + defaultSortDirection + ' NULLS LAST ';

        Integer offset = (pageNumber != null && pageNumber > 0) ? (pageNumber - 1) * pageSize : 0;
        query += ' LIMIT :pageSize OFFSET :offset';

        // Debug final query
        System.debug('### Final query with sorting and pagination: ' + query);

        try {
            List<Contact> result = Database.query(query, AccessLevel.USER_MODE);
            System.debug('### Query result size: ' + result.size());
            return result;
        } catch (Exception e) {
            System.debug('### Error executing query: ' + e.getMessage());
            throw e;
        }
        }
        catch (Exception ex) {
            throw new AuraHandledException('### Error legislativeData: ' + ex.getMessage());
        }
    }

    @AuraEnabled
    public static Integer getlegislativeDataCount(String selectionCriteriaJson) {
        try {
            // Deserialize the JSON string into a Map
            Map<String, Object> searchCriteria = (Map<String, Object>) JSON.deserializeUntyped(selectionCriteriaJson);

            // Access the values from the Map (you can now access each parameter)
            String firstname = (String) searchCriteria.get('firstname');
            String lastname = (String) searchCriteria.get('lastname');
            String title = (String) searchCriteria.get('title');
            String district = (String) searchCriteria.get('district');
            String party = (String) searchCriteria.get('party');
    
            // Initialize the conditions list
            List<String> conditions = new List<String>();
            conditions.add('RecordType.Name = \'Legislator\'');
            System.debug('### Initial condition (RecordType.Name): ' + conditions);   

        
        if (String.isNotBlank(title)) {
            conditions.add('Legislator_Title__c = \'' + String.escapeSingleQuotes(title) + '\'');
            System.debug('### title condition added: ' + conditions);
        }
        if (String.isNotBlank(party)) {
            conditions.add('Party__c = \'' + String.escapeSingleQuotes(party) + '\'');
            System.debug('### party condition added: ' + conditions);
        }
        if (String.isNotBlank(lastname)) {
            conditions.add('LastName LIKE \'%' + String.escapeSingleQuotes(lastname) + '%\'');
            System.debug('### lastName condition added: ' + conditions);
        }
        if (String.isNotBlank(firstname)) {
            conditions.add('FirstName LIKE \'%' + String.escapeSingleQuotes(firstname) + '%\'');
            System.debug('### firstName condition added: ' + conditions);
        }
        if (String.isNotBlank(district)) { 
            conditions.add('DistrictID__c = \'' + String.escapeSingleQuotes(district) + '\'');
            System.debug('### district condition added: ' + conditions);
        }


        String query = 'SELECT COUNT() FROM Contact';

        if (!conditions.isEmpty()) {
            query += ' WHERE ' + String.join(conditions, ' AND ');
        }

        query += ' WITH SECURITY_ENFORCED';

        // Debug final count query
        System.debug('### Final count query: ' + query);

        try {
            Integer countResult = Database.countQuery(query, AccessLevel.USER_MODE);
            System.debug('### Count result: ' + countResult);
            return countResult;
        } catch (Exception e) {
            System.debug('### Error executing count query: ' + e.getMessage());
            throw e;
        }
    }
    catch (Exception ex) {
        throw new AuraHandledException('### Error getlegislativeDataCount: ' + ex.getMessage());
    }

    }


}