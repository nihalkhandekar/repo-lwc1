public with sharing class SAP_ElectionOfficeController {

    @AuraEnabled(cacheable=true)
    public static List<String> getOfficeOptions(String recordTypeName) {
        try {
            // Get the RecordType ID for the given RecordType name
            RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Office__c' AND Name = :recordTypeName WITH SECURITY_ENFORCED LIMIT 1];

            // Fetch Office__c records based on the RecordType and collect names
            List<Office__c> offices = [SELECT SAP_Name__c FROM Office__c WHERE RecordTypeId = :rt.Id WITH SECURITY_ENFORCED];

            // Create a list of names to return
            List<String> options = new List<String>();
            for (Office__c office : offices) {
                options.add(office.SAP_Name__c);
            }
            return options;
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching office options: ' + e.getMessage());
        }
    }


    @AuraEnabled
    public static List<OfficeWrapper> getElectionOffices(String searchCriteriaJson) {
        Map<String, Object> searchCriteria = (Map<String, Object>) JSON.deserializeUntyped(searchCriteriaJson);
    
        // Retrieve parameters from the Map
        String electionOfficeBy = (String) searchCriteria.get('electionOfficeBy');
        String electionHeldIn = (String) searchCriteria.get('electionHeldIn');
        String congressionalDistId = (String) searchCriteria.get('congressionalDistId');
        String houseAssemblyDistId = (String) searchCriteria.get('houseAssemblyDistId');
        String senatorialDistId = (String) searchCriteria.get('senatorialDistId');
        String townsElectionOffice = (String) searchCriteria.get('townsElectionOffice');
        String stateElectionOffice = (String) searchCriteria.get('stateElectionOffice');
        String boroughCityElectionOffice = (String) searchCriteria.get('boroughCityElectionOffice');
        String city = (String) searchCriteria.get('city');
        String zip = (String) searchCriteria.get('zip');
       // Parse date values from String to Date
        String startDateStr = (String) searchCriteria.get('startDate');
        Date startDate = (startDateStr != null) ? Date.valueOf(startDateStr) : null;
        
        String endDateStr = (String) searchCriteria.get('endDate');
        Date endDate = (endDateStr != null) ? Date.valueOf(endDateStr) : null;
        Integer pageSize = (Integer) searchCriteria.get('pageSize');
        Integer pageNumber = (Integer) searchCriteria.get('pageNumber');
        String sortedBy = (String) searchCriteria.get('sortedBy');
        String sortedDirection = (String) searchCriteria.get('sortedDirection');

        System.debug('Sortby' + sortedBy);
        System.debug('Sort direction' + sortedDirection);
        List<OfficeWrapper> officeWrappers = new List<OfficeWrapper>();
        List<Id> officeIds = new List<Id>();

        // If the search type is "Town" and district criteria are provided, first search district mappings
        // If the search type is "Town" and district criteria are provided, first search district mappings
        if (electionOfficeBy == 'Town' && 
        (String.isNotBlank(congressionalDistId) || String.isNotBlank(houseAssemblyDistId) || String.isNotBlank(senatorialDistId))) {

        // Step 1: Collect all required districts
        Set<String> requiredDistrictValues = new Set<String>();
        if (String.isNotBlank(congressionalDistId)) {
            requiredDistrictValues.add(congressionalDistId);
        }
        if (String.isNotBlank(houseAssemblyDistId)) {
            requiredDistrictValues.add(houseAssemblyDistId);
        }
        if (String.isNotBlank(senatorialDistId)) {
            requiredDistrictValues.add(senatorialDistId);
        }

        // Step 2: Fetch all mappings that match any required district
        List<Office_District_Mapping__c> districtMappings = [
            SELECT Office__c, District__c
            FROM Office_District_Mapping__c
            WHERE District__c IN :requiredDistrictValues
        ];

        // Step 3: Group mappings by Office and collect matching districts
        Map<Id, Set<String>> officeToDistrictsMap = new Map<Id, Set<String>>();
        for (Office_District_Mapping__c mapping : districtMappings) {
            if (!officeToDistrictsMap.containsKey(mapping.Office__c)) {
                officeToDistrictsMap.put(mapping.Office__c, new Set<String>());
            }
            officeToDistrictsMap.get(mapping.Office__c).add(mapping.District__c);
        }

        // Step 4: Filter offices that satisfy all required districts
        Set<Id> matchingOfficeIds = new Set<Id>();
        for (Id officeId : officeToDistrictsMap.keySet()) {
            if (officeToDistrictsMap.get(officeId).containsAll(requiredDistrictValues)) {
                matchingOfficeIds.add(officeId);
            }
        }

        // Step 5: Return `null` or empty list if no matching offices are found
        if (matchingOfficeIds.isEmpty()) {
            return officeWrappers; // You can also return `new List<OfficeWrapper>()` if you prefer an empty list.
        } else {
            officeIds.addAll(matchingOfficeIds); // Add matching office IDs
        }
        }





        // List to hold conditions for querying Office__c records
        List<String> officeConditions = new List<String>();

        if (!officeIds.isEmpty()) {
            officeConditions.add('Id IN :officeIds');
        }

        if (String.isNotBlank(electionOfficeBy)) {
            officeConditions.add('RecordType.Name = \'' + String.escapeSingleQuotes(electionOfficeBy) + '\'');
        }

        if (String.isNotBlank(electionHeldIn)) {
            officeConditions.add('SAP_Election_Held_In__c = \'' + String.escapeSingleQuotes(electionHeldIn) + '\'');
        }

        if (String.isNotBlank(city)) {
            officeConditions.add('SAP_Mailing_Address_City__c LIKE \'%' + String.escapeSingleQuotes(city) + '%\'');
        }

        if (String.isNotBlank(zip)) {
            officeConditions.add('SAP_Mailing_Address_Zip__c LIKE \'%' + String.escapeSingleQuotes(zip) + '%\'');
        }

        if (String.isNotBlank(boroughCityElectionOffice)) {
            officeConditions.add('SAP_Name__c LIKE \'%' + String.escapeSingleQuotes(boroughCityElectionOffice) + '%\'');
        }

        if (String.isNotBlank(townsElectionOffice)) {
            officeConditions.add('SAP_Name__c LIKE \'%' + String.escapeSingleQuotes(townsElectionOffice) + '%\'');
        }

        if (String.isNotBlank(stateElectionOffice)) {
            officeConditions.add('SAP_Name__c LIKE \'%' + String.escapeSingleQuotes(stateElectionOffice) + '%\'');
        }

        if (startDate != null && endDate != null) {
            officeConditions.add('CreatedDate >= :startDate AND CreatedDate <= :endDate');
        }

        // Step 1: Build the main query for `Office__c` records
        String officeQuery = 'SELECT Id, SAP_Name__c, SAP_Id__c, SAP_ROV_Name__c, SAP_Election_Held_In__c, SAP_Title__c, SAP_Mailing_Address_Line_1__c, SAP_Mailing_Address_City__c, SAP_Mailing_Address_State__c, SAP_Mailing_Address_Zip__c, '
            + '(SELECT District__r.SAP_District_Id__c, District__r.RecordType.Name FROM Office_District_Mappings__r) '  // Subquery for districts
            + 'FROM Office__c';

        // Apply the office conditions to filter the records
        if (!officeConditions.isEmpty()) {
            officeQuery += ' WHERE ' + String.join(officeConditions, ' AND ');
        }


        // Apply sorting and pagination
        Integer offset = (pageNumber != null && pageNumber > 0) ? (pageNumber - 1) * pageSize : 0;
        officeQuery += ' ORDER BY ' + (String.isNotBlank(sortedBy) ? sortedBy : 'SAP_Name__c') + ' ' + (String.isNotBlank(sortedDirection) ? sortedDirection : 'ASC');
        officeQuery += ' LIMIT :pageSize OFFSET :offset';

        // Step 2: Execute the query
        List<Office__c> offices = Database.query(officeQuery, AccessLevel.USER_MODE);

        // Step 3: Process the query result
        for (Office__c office : offices) {
            OfficeWrapper wrapper = new OfficeWrapper();
            wrapper.office = office;

            // Lists to hold multiple district values
            List<String> congressionalDist = new List<String>();
            List<String> houseAssemblyDist = new List<String>();
            List<String> senatorialDist = new List<String>();

            // Iterate over the related district mappings (subquery results)
            for (Office_District_Mapping__c mapping : office.Office_District_Mappings__r) {
                if (mapping.District__r.RecordType.Name == 'Congressional') {
                    congressionalDist.add(mapping.District__r.SAP_District_Id__c);
                } else if (mapping.District__r.RecordType.Name == 'House Assembly') {
                    houseAssemblyDist.add(mapping.District__r.SAP_District_Id__c);
                } else if (mapping.District__r.RecordType.Name == 'Senatorial') {
                    senatorialDist.add(mapping.District__r.SAP_District_Id__c);
                }
            }

            // Set the district values in the wrapper (concatenate multiple districts)
            wrapper.congressionalDist = String.join(congressionalDist, ', ');
            wrapper.houseAssemblyDist = String.join(houseAssemblyDist, ', ');
            wrapper.senatorialDist = String.join(senatorialDist, ', ');

            officeWrappers.add(wrapper);
        }

        return officeWrappers;
    }

    // Wrapper class for the response structure
    public class OfficeWrapper {
        @AuraEnabled public Office__c office { get; set; }
        @AuraEnabled public String congressionalDist { get; set; }
        @AuraEnabled public String houseAssemblyDist { get; set; }
        @AuraEnabled public String senatorialDist { get; set; }
    }

    @AuraEnabled
    public static Integer getElectionOfficesCount(String searchCriteriaJson){
         // Deserialize the JSON string into a Map
        Map<String, Object> searchCriteria = (Map<String, Object>) JSON.deserializeUntyped(searchCriteriaJson);
        
        // Retrieve parameters from the Map
        String electionOfficeBy = (String) searchCriteria.get('electionOfficeBy');
        String electionHeldIn = (String) searchCriteria.get('electionHeldIn');
        String congressionalDistId = (String) searchCriteria.get('congressionalDistId');
        String houseAssemblyDistId = (String) searchCriteria.get('houseAssemblyDistId');
        String senatorialDistId = (String) searchCriteria.get('senatorialDistId');
        String townsElectionOffice = (String) searchCriteria.get('townsElectionOffice');
        String stateElectionOffice = (String) searchCriteria.get('stateElectionOffice');
        String boroughCityElectionOffice = (String) searchCriteria.get('boroughCityElectionOffice');
        String city = (String) searchCriteria.get('city');
        String zip = (String) searchCriteria.get('zip');
        // Parse date values from String to Date
        String startDateStr = (String) searchCriteria.get('startDate');
        Date startDate = (startDateStr != null) ? Date.valueOf(startDateStr) : null;
        
        String endDateStr = (String) searchCriteria.get('endDate');
        Date endDate = (endDateStr != null) ? Date.valueOf(endDateStr) : null;

        List<OfficeWrapper> officeWrappers = new List<OfficeWrapper>();
        List<Id> officeIds = new List<Id>();

        if (electionOfficeBy == 'Town' && 
        (String.isNotBlank(congressionalDistId) || String.isNotBlank(houseAssemblyDistId) || String.isNotBlank(senatorialDistId))) {

        // Step 1: Collect all required districts
        Set<String> requiredDistrictValues = new Set<String>();
        if (String.isNotBlank(congressionalDistId)) {
            requiredDistrictValues.add(congressionalDistId);
        }
        if (String.isNotBlank(houseAssemblyDistId)) {
            requiredDistrictValues.add(houseAssemblyDistId);
        }
        if (String.isNotBlank(senatorialDistId)) {
            requiredDistrictValues.add(senatorialDistId);
        }

        // Step 2: Fetch all mappings that match any required district
        List<Office_District_Mapping__c> districtMappings = [
            SELECT Office__c, District__c
            FROM Office_District_Mapping__c
            WHERE District__c IN :requiredDistrictValues 
        ];

        // Step 3: Group mappings by Office and collect matching districts
        Map<Id, Set<String>> officeToDistrictsMap = new Map<Id, Set<String>>();
        for (Office_District_Mapping__c mapping : districtMappings) {
            if (!officeToDistrictsMap.containsKey(mapping.Office__c)) {
                officeToDistrictsMap.put(mapping.Office__c, new Set<String>());
            }
            officeToDistrictsMap.get(mapping.Office__c).add(mapping.District__c);
        }

        // Step 4: Filter offices that satisfy all required districts
        Set<Id> matchingOfficeIds = new Set<Id>();
        for (Id officeId : officeToDistrictsMap.keySet()) {
            if (officeToDistrictsMap.get(officeId).containsAll(requiredDistrictValues)) {
                matchingOfficeIds.add(officeId);
            }
        }

        // Step 5: Return `null` or empty list if no matching offices are found
        if (matchingOfficeIds.isEmpty()) {
            return 0; // You can also return `new List<OfficeWrapper>()` if you prefer an empty list.
        } else {
            officeIds.addAll(matchingOfficeIds); // Add matching office IDs
        }
        }

        // List to hold conditions for querying Office__c records
        List<String> officeConditions = new List<String>();

        if (!officeIds.isEmpty()) {
            officeConditions.add('Id IN :officeIds');
        }

        if (String.isNotBlank(electionOfficeBy)) {
            officeConditions.add('RecordType.Name = \'' + String.escapeSingleQuotes(electionOfficeBy) + '\'');
        }

        if (String.isNotBlank(electionHeldIn)) {
            officeConditions.add('SAP_Election_Held_In__c = \'' + String.escapeSingleQuotes(electionHeldIn) + '\'');
        }

        if (String.isNotBlank(city)) {
            officeConditions.add('SAP_Mailing_Address_City__c LIKE \'%' + String.escapeSingleQuotes(city) + '%\'');
        }

        if (String.isNotBlank(zip)) {
            officeConditions.add('SAP_Mailing_Address_Zip__c LIKE \'%' + String.escapeSingleQuotes(zip) + '%\'');
        }

        if (String.isNotBlank(boroughCityElectionOffice)) {
            officeConditions.add('SAP_Name__c LIKE \'%' + String.escapeSingleQuotes(boroughCityElectionOffice) + '%\'');
        }

        if (String.isNotBlank(townsElectionOffice)) {
            officeConditions.add('SAP_Name__c LIKE \'%' + String.escapeSingleQuotes(townsElectionOffice) + '%\'');
        }

        if (String.isNotBlank(stateElectionOffice)) {
            officeConditions.add('SAP_Name__c LIKE \'%' + String.escapeSingleQuotes(stateElectionOffice) + '%\'');
        }

        if (startDate != null && endDate != null) {
            officeConditions.add('CreatedDate >= :startDate AND CreatedDate <= :endDate');
        }

       // Use COUNT() to get the number of records
       String officeQuery = 'SELECT COUNT() FROM Office__c';
        // Apply the office conditions to filter the records
        if (!officeConditions.isEmpty()) {
            officeQuery += ' WHERE ' + String.join(officeConditions, ' AND ');
        }

        try {
            // Use countQuery for counting the records
            Integer countResult = Database.countQuery(officeQuery, AccessLevel.USER_MODE);
            return countResult;
        } catch (Exception e) {
            System.debug('### Error executing count query: ' + e.getMessage());
            throw e;
        }

    }

    @AuraEnabled
    public static void deleteOffice(Id recordId) {
        System.debug('### deleteOffice called with recordId: ' + recordId);
        
        if (recordId != null) {
            try {
                // Step 1: Query all contacts associated with the Office__c
                List<Contact> contactsToDelete = [
                    SELECT Id 
                    FROM Contact 
                    WHERE Office__c = :recordId WITH SECURITY_ENFORCED
                ];
                
                // Step 2: Delete the associated contacts if they exist
                if (!contactsToDelete.isEmpty()) {
                      Database.delete(contactsToDelete, AccessLevel.USER_MODE);
                    System.debug('### Associated contacts deleted successfully');
                }

                // Step 3: Delete the Office__c record
                delete [SELECT Id FROM Office__c WHERE Id = :recordId WITH SECURITY_ENFORCED LIMIT 1];
                System.debug('### Office__c record deleted successfully');
            } catch (DmlException e) {
                System.debug('### Error occurred during deletion: ' + e.getMessage());
                throw new AuraHandledException('Error occurred during deletion: ' + e.getMessage());
            }
        } else {
            throw new AuraHandledException('Invalid Office__c ID provided.');
        }
    }


    @AuraEnabled
    public static List<Contact> getPublicOfficial(String searchCriteriaJson) {
            // Deserialize the JSON string into a Map
        Map<String, Object> searchCriteria = (Map<String, Object>) JSON.deserializeUntyped(searchCriteriaJson);
        
        // Retrieve parameters from the Map
        String recordId = (String) searchCriteria.get('recordId');
        // Parse date values from String to Date
        String startDateStr = (String) searchCriteria.get('startDate');
        Date startDate = (startDateStr != null) ? Date.valueOf(startDateStr) : null;
        
        String endDateStr = (String) searchCriteria.get('endDate');
        Date endDate = (endDateStr != null) ? Date.valueOf(endDateStr) : null;

        Integer pageSize = (Integer) searchCriteria.get('pageSize');
        Integer pageNumber = (Integer) searchCriteria.get('pageNumber');
        String sortedBy = (String) searchCriteria.get('sortedBy');
        String sortedDirection = (String) searchCriteria.get('sortedDirection');
        System.debug('### recordId: ' + recordId);
        System.debug('### startDate: ' + startDate);
        System.debug('### endDate: ' + endDate);
        System.debug('### pageSize: ' + pageSize);
        System.debug('### pageNumber: ' + pageNumber);
        System.debug('### sortedBy: ' + sortedBy);
        System.debug('### sortedDirection: ' + sortedDirection);

        List<String> conditions = new List<String>();
        
        if (String.isNotBlank(recordId)) {
            conditions.add('Office__c = \'' + String.escapeSingleQuotes(recordId) + '\'');
            System.debug('### townsOffice condition added: ' + conditions);
        }
        if (startDate != null && endDate != null) {
            conditions.add('CreatedDate >= :startDate AND CreatedDate <= :endDate');
            System.debug('### Date condition added: ' + conditions);
        }

        String query = 'SELECT Id, Office__c, Office__r.SAP_Name__c, SAP_Title__c, SAP_Party__c, LastName, FirstName, SAP_Start_Term__c, SAP_End_Term__c, HomePhone, Phone, SAP_Extension__c, CreatedDate FROM Contact';
        
        if (!conditions.isEmpty()) {
            query += ' WHERE ' + String.join(conditions, ' AND ');
        }
        //query += ' WITH SECURITY_ENFORCED';


        String defaultSortBy = String.isNotBlank(sortedBy) ? sortedBy : 'CreatedDate';
        String defaultSortDirection = (sortedDirection == 'ASC' || sortedDirection == 'DESC') ? sortedDirection : 'DESC';
        query += ' ORDER BY ' + defaultSortBy + ' ' + defaultSortDirection;

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

    @AuraEnabled
    public static Integer getPublicOfficialsCount(
        String searchCriteriaJson
    ) {

        Map<String, Object> searchCriteria = (Map<String, Object>) JSON.deserializeUntyped(searchCriteriaJson);
        
        // Retrieve parameters from the Map
        String recordId = (String) searchCriteria.get('recordId');
        // Parse date values from String to Date
        String startDateStr = (String) searchCriteria.get('startDate');
        Date startDate = (startDateStr != null) ? Date.valueOf(startDateStr) : null;
        
        String endDateStr = (String) searchCriteria.get('endDate');
        Date endDate = (endDateStr != null) ? Date.valueOf(endDateStr) : null;

        System.debug('### recordId: ' + recordId);
        System.debug('### startDate: ' + startDate);
        System.debug('### endDate: ' + endDate);

        List<String> conditions = new List<String>();
        
        if (String.isNotBlank(recordId)) {
            conditions.add('Office__c = \'' + String.escapeSingleQuotes(recordId) + '\'');
            System.debug('### townsOffice condition added: ' + conditions);
        }
        if (startDate != null && endDate != null) {
            conditions.add('CreatedDate >= :startDate AND CreatedDate <= :endDate');
            System.debug('### Date condition added: ' + conditions);
        }

        String query = 'SELECT COUNT() FROM Contact';

        if (!conditions.isEmpty()) {
            query += ' WHERE ' + String.join(conditions, ' AND ');
        }

        query += ' WITH SECURITY_ENFORCED';


        // Debug final count query
        System.debug('### Final count query: ' + query);

        try {
            Integer countResult = Database.countQuery(query,AccessLevel.USER_MODE);
            System.debug('### Count result: ' + countResult);
            return countResult;
        } catch (Exception e) {
            System.debug('### Error executing count query: ' + e.getMessage());
            throw e;
        }
    }



}