public with sharing class InHousePublicOfficialController {

 @AuraEnabled
    public static List<Map<String, Object>> getPublicOfficial(String paramsJson) {

         Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(paramsJson);
        String lastName = (String)params.get('lastname');
        String firstName = (String)params.get('firstname');
        String position = (String)params.get('position');
        Date termstart = null;
        Date termend = null;
        // Check for null and convert string to Date if valid
        if (params.containsKey('termstart') && params.get('termstart') != null) {
            termstart = Date.valueOf((String)params.get('termstart'));
        }
        if (params.containsKey('termend') && params.get('termend') != null) {
            termend = Date.valueOf((String)params.get('termend'));
        }
        
        String town = (String)params.get('town');
        Integer offsetVal = (Integer)params.get('offsetVal');
        Integer pageSize = (Integer)params.get('pageSize');
        String sortBy = (String)params.get('sortBy');
        String sortDirection = (String)params.get('sortDirection');
        Date transactionFromDate = null;
        Date transactionToDate = null;

            // Check for null and convert string to Date if valid
        if (params.containsKey('transactionFromDate') && params.get('transactionFromDate') != null) {
            transactionFromDate = Date.valueOf((String)params.get('transactionFromDate'));
        }
        if (params.containsKey('transactionToDate') && params.get('transactionToDate') != null) {
            transactionToDate = Date.valueOf((String)params.get('transactionToDate'));
        }

        List<String> conditions = new List<String>();
        conditions.add('RecordType.DeveloperName = \'Apostille_Official\'');
        System.debug('### Initial condition (RecordType.DeveloperName): ' + conditions);

        Set<Id> matchingIds = new Set<Id>();
        
        String query = 'SELECT Id, LastName, FirstName, Position__c,Town__c, Start_Term__c, End_Term__c, Indefinite_Term__c, LastModifiedDate, CreatedDate FROM Contact';

        if (String.isNotBlank(lastName)) {
            conditions.add('LastName LIKE \'%' + String.escapeSingleQuotes(lastName) + '%\'');
            System.debug('### lastName condition added: ' + conditions);
        }

        if (String.isNotBlank(firstName)) {
            conditions.add('FirstName LIKE \'%' + String.escapeSingleQuotes(firstName) + '%\'');
            System.debug('### firstName condition added: ' + conditions);
        }

        if (String.isNotBlank(position)) {
            conditions.add('Position__c LIKE \'%' + String.escapeSingleQuotes(position) + '%\'');
            System.debug('### position condition added: ' + conditions);
        }
       
        // Date conditions
        if (termstart != null && termend != null) {
            // If both termstart and termend are provided
            conditions.add('Start_Term__c >= :termstart AND End_Term__c <= :termend');
            System.debug('### Date range condition added: ' + conditions);
        } else if (termstart != null) {
            // If only termstart is provided
            conditions.add('Start_Term__c >= :termstart');
            System.debug('### termstart condition added: ' + conditions);
        } else if (termend != null) {
            // If only termend is provided
            conditions.add('End_Term__c <= :termend');
            System.debug('### termend condition added: ' + conditions);
        }

        if (String.isNotBlank(town)) {
            conditions.add('Town__c LIKE \'%' + String.escapeSingleQuotes(town) + '%\'');
            System.debug('### Town condition added: ' + conditions);
        }

        //  if (transactionFromDate != null && transactionToDate != null) {
        //      conditions.add('CreatedDate >= :transactionFromDate AND CreatedDate <= :transactionToDate');
        // }

        if (transactionFromDate != null && transactionToDate != null) {
            if (transactionFromDate == transactionToDate) {
            	conditions.add('CreatedDate = TODAY');
            } else {
                conditions.add('CreatedDate >= :transactionFromDate AND CreatedDate <= :transactionToDate');
            }
        }  

        // Office__c, Office__r.Name__c, Title__c, Party__c,
        
        if (!conditions.isEmpty()) {
            query += ' WHERE ' + String.join(conditions, ' AND ');
        }
        String sortField = String.isNotBlank(sortBy) ? sortBy : 'CreatedDate';
        String sortOrder = (sortDirection == 'ASC' || sortDirection == 'DESC') ? sortDirection : 'DESC';

        String lastSortingField;
if(offsetVal > 1) {
    String IdQuery = query + ' LIMIT 1 OFFSET ' + (offsetVal - 1);
    SObject[] IdResults = Database.query(IdQuery);
    
    // Check if results exist
    if (!IdResults.isEmpty()) {
        Object fieldValue = IdResults[0].get(sortField);
        if(fieldValue instanceof DateTime) {
            lastSortingField = ((DateTime)fieldValue).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        } else if(fieldValue instanceof Date) {
            lastSortingField = ((Date)fieldValue).format();
        } else {
            lastSortingField = String.valueOf(fieldValue);
        }
    }
}

try {
    SObject[] results = Database.query(query, AccessLevel.USER_MODE);
    
    // Only try to get lastId if results are not empty
    Id lastId;
    if (!results.isEmpty()) {
        lastId = results[results.size() - 1].Id;
    }
    
    List<Map<String, Object>> formattedResults = new List<Map<String, Object>>();
    
    // Process only if there are results
    if (!results.isEmpty()) {
        for (Integer i = 0; i < results.size(); i++) {
            Map<String, Object> contactData = new Map<String, Object>();
            Contact con = (Contact)results[i];
            contactData.put('Id', con.Id);
            contactData.put('Indefinite_Term__c', con.Indefinite_Term__c);
            contactData.put('LastName', capitalizeFirstLetter(con.LastName));
            contactData.put('FirstName', capitalizeFirstLetter(con.FirstName));
            contactData.put('Position__c', capitalizeFirstLetter(con.Position__c));
            contactData.put('Town__c', capitalizeFirstLetter(con.Town__c));
            if(con.Indefinite_Term__c) {
                contactData.put('FormattedStartTerm', 'N/A');
                contactData.put('FormattedEndTerm', 'Indefinite Term');
            } else {
                contactData.put('FormattedStartTerm', (con.Start_Term__c != null) ? formatCustomDate(con.Start_Term__c) : null);
                contactData.put('FormattedEndTerm', (con.End_Term__c != null) ? formatCustomDate(con.End_Term__c) : null);
            }
            formattedResults.add(contactData);
        }
    }
    
    System.debug('Result is ' + formattedResults);
    return formattedResults;
    
} catch (Exception e) {
    System.debug('### Error executing query: ' + e.getMessage());
    throw e;
}
    }

    public static String capitalizeFirstLetter(String inputString) {
        if (String.isBlank(inputString)) {
            return '';
        }
        String formattedString = inputString.substring(0, 1).toUpperCase() + inputString.substring(1).toLowerCase();
        return formattedString;
    }

    
        private static String formatCustomDate(Date inputDate) {
            if (inputDate == null) return null;
            String formattedMonth = (inputDate.month() < 10) ? '0' + String.valueOf(inputDate.month()) : String.valueOf(inputDate.month());
            String formattedDay = (inputDate.day() < 10) ? '0' + String.valueOf(inputDate.day()) : String.valueOf(inputDate.day());
            return formattedMonth + '/' + formattedDay + '/' + String.valueOf(inputDate.year());
        }

    @AuraEnabled
    public static Integer getPublicOfficialCount(String paramsJson) {

         Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(paramsJson);
        String lastName = (String)params.get('lastname');
        String firstName = (String)params.get('firstname');
        String position = (String)params.get('position');
        Date termstart = null;
        Date termend = null;
        // Check for null and convert string to Date if valid
        if (params.containsKey('termstart') && params.get('termstart') != null) {
            termstart = Date.valueOf((String)params.get('termstart'));
        }
        if (params.containsKey('termend') && params.get('termend') != null) {
            termend = Date.valueOf((String)params.get('termend'));
        }
        String town = (String)params.get('town');

        Date transactionFromDate = null;
        Date transactionToDate = null;

            // Check for null and convert string to Date if valid
        if (params.containsKey('transactionFromDate') && params.get('transactionFromDate') != null) {
            transactionFromDate = Date.valueOf((String)params.get('transactionFromDate'));
        }
        if (params.containsKey('transactionToDate') && params.get('transactionToDate') != null) {
            transactionToDate = Date.valueOf((String)params.get('transactionToDate'));
        }
        
         List<String> conditions = new List<String>();
        conditions.add('RecordType.DeveloperName = \'Apostille_Official\'');
        System.debug('### Initial condition (RecordType.DeveloperName): ' + conditions);

        String query = 'SELECT COUNT(Id) cnt FROM Contact';

         if (String.isNotBlank(lastName)) {
            conditions.add('LastName LIKE \'%' + String.escapeSingleQuotes(lastName) + '%\'');
            System.debug('### lastName condition added: ' + conditions);
        }

        if (String.isNotBlank(firstName)) {
            conditions.add('FirstName LIKE \'%' + String.escapeSingleQuotes(firstName) + '%\'');
            System.debug('### firstName condition added: ' + conditions);
        }

        if (String.isNotBlank(position)) {
            conditions.add('Position__c LIKE \'%' + String.escapeSingleQuotes(position) + '%\'');
            System.debug('### position condition added: ' + conditions);
        }
       
        // Date conditions
        if (termstart != null && termend != null) {
            // If both termstart and termend are provided
            conditions.add('Start_Term__c >= :termstart AND End_Term__c <= :termend');
            System.debug('### Date range condition added: ' + conditions);
        } else if (termstart != null) {
            // If only termstart is provided
            conditions.add('Start_Term__c >= :termstart');
            System.debug('### termstart condition added: ' + conditions);
        } else if (termend != null) {
            // If only termend is provided
            conditions.add('End_Term__c <= :termend');
            System.debug('### termend condition added: ' + conditions);
        }

        if (String.isNotBlank(town)) {
            conditions.add('Town__c LIKE \'%' + String.escapeSingleQuotes(town) + '%\'');
            System.debug('### Town condition added: ' + conditions);
        }

        if (transactionFromDate != null && transactionToDate != null) {
            if (transactionFromDate == transactionToDate) {
            	conditions.add('CreatedDate = TODAY');
            } else {
                conditions.add('CreatedDate >= :transactionFromDate AND CreatedDate <= :transactionToDate');
            }
        }  


        // Office__c, Office__r.Name__c, Title__c, Party__c,
        
        if (!conditions.isEmpty()) {
            query += ' WHERE ' + String.join(conditions, ' AND ');
        }

         List<AggregateResult> countResult = Database.query(query, AccessLevel.USER_MODE);
        Integer totalCount = (countResult != null && !countResult.isEmpty()) ? (Integer) countResult[0].get('cnt') : 0;

        System.debug('total is ->'+ totalCount);
         return totalCount;
    }

    @AuraEnabled
    public static void deleteContact(Id recordId) {
        System.debug('### deleteContact called with recordId: ' + recordId);
        if (recordId != null) {
            try {
                delete [SELECT Id FROM Contact WHERE Id = :recordId LIMIT 1];
                System.debug('### Contact deleted successfully');
            } catch (DmlException e) {
                System.debug('### Error deleting contact: ' + e.getMessage());
                throw new AuraHandledException('Error deleting contact: ' + e.getMessage());
            }
        }
    }



// Being used into Modal component
    @AuraEnabled
    public static Map<String, Object> fetchPublicOfficialData(Id recordId) {
        
        List<Contact> records = [ 
            SELECT Id, Prefix__c, FirstName, MiddleName, LastName, Start_Term__c, End_Term__c, 
                   Position__c, Town__c, Indefinite_Term__c, Judicial_District__c, 
                   Seal_Stramp_of__c, Notes__c 
            FROM Contact 
            WHERE Id = :recordId 
            WITH SECURITY_ENFORCED 
            LIMIT 1 
        ];        

        Map<String, Object> result = new Map<String, Object>();
        
        system.debug('------Apex going data--->'+result);
        system.debug('------id going data--->'+recordId);
        result.put('records', records);
        return result;   
    }

@AuraEnabled
public static Id updatePublicOfficialData(Contact newRecord) {
Id officialRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Apostille_Official').getRecordTypeId();
System.debug('--newRecord--' + newRecord);

try {
// **Check CRUD Permissions Before DML**
if (!Schema.sObjectType.Contact.isCreateable() || !Schema.sObjectType.Contact.isUpdateable()) {
    throw new AuraHandledException('Insufficient permissions to create/update Contact records.');
}

// **Check Field-Level Security (FLS) Before Accessing Fields**
if (!Schema.sObjectType.Contact.fields.RecordTypeId.isAccessible()) {
    throw new AuraHandledException('Insufficient permissions to access the RecordTypeId field.');
}

if (newRecord.Id == null) {
    newRecord.RecordTypeId = officialRecordTypeId;
    System.debug('Record is being created, setting RecordTypeId to Official.');
}

// **Perform Upsert in User Mode**
upsert newRecord;

} catch (DmlException e) {
throw new AuraHandledException(e.getMessage()); 
}

return newRecord.Id;
}



    @AuraEnabled
public static List<Map<String, Object>> processNameFieldHistory(String contactId) {

    Contact contactRecord = [
        SELECT FirstName, MiddleName, LastName,CreatedDate
        FROM Contact
        WHERE Id = :contactId
        WITH SECURITY_ENFORCED
        LIMIT 1
    ];

    List<ContactHistory> historyRecords = [
        SELECT Field, OldValue, NewValue, CreatedDate
        FROM ContactHistory
        WHERE ContactId = :contactId
        AND CreatedDate > :contactRecord.CreatedDate
        AND Field IN ('FirstName', 'MiddleName', 'LastName')
        WITH SECURITY_ENFORCED
        ORDER BY CreatedDate ASC
    ];

    System.debug('total history record length is ' + historyRecords.size());

    if (historyRecords.isEmpty()) {
        return new List<Map<String, Object>>();
    }

    String initialFirstName = contactRecord.FirstName;
    String initialMiddleName = contactRecord.MiddleName;
    String initialLastName = contactRecord.LastName;

    Boolean firstNameSet = false;
    Boolean middleNameSet = false;
    Boolean lastNameSet = false;
    DateTime lastCreatedDate = null;

    for (ContactHistory history : historyRecords) {
        if (history.Field == 'FirstName' && !firstNameSet) {
            initialFirstName = history.OldValue != null ? (String)history.OldValue : (String)history.NewValue;
            firstNameSet = true;
        } else if (history.Field == 'MiddleName' && !middleNameSet) {
            initialMiddleName = history.OldValue != null ? (String)history.OldValue : (String)history.NewValue;
            middleNameSet = true;
        } else if (history.Field == 'LastName' && !lastNameSet) {
            initialLastName = history.OldValue != null ? (String)history.OldValue : (String)history.NewValue;
            lastNameSet = true;
        }
    }

    List<Map<String, Object>> historyLog = new List<Map<String, Object>>();

    Map<String, Object> initialState = new Map<String, Object>();
    initialState.put('FirstName', initialFirstName);
    initialState.put('MiddleName', initialMiddleName);
    initialState.put('LastName', initialLastName);
    historyLog.add(initialState);

    System.debug('initialState is =>> :' + initialState);

    String currentFirstName = initialFirstName;
    String currentMiddleName = initialMiddleName;
    String currentLastName = initialLastName;

    Map<String, Object> tempSnapshot = new Map<String, Object>();
    
    for (ContactHistory history : historyRecords) {
        // Check if we're processing a new CreatedDate
        if (lastCreatedDate != null && !lastCreatedDate.equals(history.CreatedDate)) {
            // Add accumulated snapshot to historyLog
            historyLog.add(0, new Map<String, Object>(tempSnapshot));
            tempSnapshot.clear();
        }

        // Update fields in tempSnapshot without adding it to historyLog yet
        if (history.Field == 'FirstName') {
            currentFirstName = (String)history.NewValue;
        } else if (history.Field == 'MiddleName') {
            currentMiddleName = (String)history.NewValue;
        } else if (history.Field == 'LastName') {
            currentLastName = (String)history.NewValue;
        }

        tempSnapshot.put('FirstName', currentFirstName);
        tempSnapshot.put('MiddleName', currentMiddleName);
        tempSnapshot.put('LastName', currentLastName);

        // Update lastCreatedDate to current history record's CreatedDate
        lastCreatedDate = history.CreatedDate;
    }

    // Add the final snapshot after the loop ends
    if (!tempSnapshot.isEmpty()) {
        historyLog.add(0, new Map<String, Object>(tempSnapshot));
    }

    // Remove the first entry from historyLog
    if (!historyLog.isEmpty() && historyLog.size()>1) {
        historyLog.remove(0);
    }

    return historyLog;
}


    @AuraEnabled
public static List<Map<String, Object>> processTermFieldHistory(String contactId) {
    // Fetch the current contact record to get initial term field values
    Contact contactRecord = [
        SELECT Start_Term__c, End_Term__c
        FROM Contact
        WHERE Id = :contactId
        WITH SECURITY_ENFORCED
        LIMIT 1
    ];

    // Fetch the ContactHistory records for the specified term fields
    List<ContactHistory> historyRecords = [
        SELECT Id,Field, OldValue, NewValue, CreatedDate
        FROM ContactHistory
        WHERE ContactId = :contactId
        AND Field IN ('Start_Term__c', 'End_Term__c')
        WITH SECURITY_ENFORCED
        ORDER BY CreatedDate ASC
    ];

    System.debug('Total history record length is ' + historyRecords.size());

    if (historyRecords.isEmpty()) {
        return new List<Map<String, Object>>();
    }

    // Set initial values for the term fields from the current contact record
    String initialStartTerm = contactRecord.Start_Term__c != null ? formatCustomDate(contactRecord.Start_Term__c) : 'Indefinite Term';
    String initialEndTerm = contactRecord.End_Term__c != null ? formatCustomDate(contactRecord.End_Term__c) : 'Indefinite Term';

    Boolean startTermSet = false;
    Boolean endTermSet = false;
    DateTime lastCreatedDate = null;

    // Initialize initial field values from history records if available
    for (ContactHistory history : historyRecords) {
        if (history.Field == 'Start_Term__c' && !startTermSet) {
            initialStartTerm = history.OldValue != null ? formatCustomDate((Date)history.OldValue) : 'Indefinite Term';
            startTermSet = true;
        } else if (history.Field == 'End_Term__c' && !endTermSet) {
            initialEndTerm = history.OldValue != null ? formatCustomDate((Date)history.OldValue) : 'Indefinite Term';
            endTermSet = true;
        }
    }

    // List to store snapshots of changes
    List<Map<String, Object>> historyLog = new List<Map<String, Object>>();

    // Add the initial state to the log
    Map<String, Object> initialState = new Map<String, Object>();
    initialState.put('Start_Term__c', initialStartTerm);
    initialState.put('End_Term__c', initialEndTerm);
    historyLog.add(initialState);

    // System.debug('Initial state is =>> :' + initialState);

    // Variables to hold the current state as changes are processed
    String currentStartTerm = initialStartTerm;
    String currentEndTerm = initialEndTerm;

    // Temporary snapshot for accumulating changes with the same CreatedDate
    Map<String, Object> tempSnapshot = new Map<String, Object>();

    System.debug('historyRecords is =>> :' + historyRecords);


    for (ContactHistory history : historyRecords) {
        // If processing a new CreatedDate, add the accumulated snapshot to historyLog
        if (lastCreatedDate != null && !lastCreatedDate.equals(history.CreatedDate)) {
            historyLog.add(0, new Map<String, Object>(tempSnapshot));
            tempSnapshot.clear();
        }

        // Update the appropriate field in tempSnapshot with 'Indefinite Term' if the NewValue is null
        if (history.Field == 'Start_Term__c') {
            currentStartTerm = history.NewValue != null ? formatCustomDate((Date)history.NewValue) : 'Indefinite Term';
        } else if (history.Field == 'End_Term__c') {
            currentEndTerm = history.NewValue != null ? formatCustomDate((Date)history.NewValue) : 'Indefinite Term';
        }

        // Add current field values to tempSnapshot
        tempSnapshot.put('Id', history.Id);
        tempSnapshot.put('Start_Term__c', currentStartTerm);
        tempSnapshot.put('End_Term__c', currentEndTerm);
        System.debug('current tempSnapshot data is :=>'+tempSnapshot);
        // Update lastCreatedDate to current record's CreatedDate
        lastCreatedDate = history.CreatedDate;
    }

    // Add the final snapshot after the loop ends
    if (!tempSnapshot.isEmpty()) {
        historyLog.add(0, new Map<String, Object>(tempSnapshot));
    }

    // Remove the first entry from historyLog if there’s more than one entry (initial state)
    if (!historyLog.isEmpty() && historyLog.size() > 1) {
        historyLog.remove(0);
    }

    System.debug('final term result is '+historyLog);
    return historyLog;
}

     
    
}