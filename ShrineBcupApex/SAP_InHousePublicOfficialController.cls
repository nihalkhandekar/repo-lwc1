/**
 * SAP_InHousePublicOfficialController
 * It retrieves public official information based on provided parameters such as last name, first name, position,
 * terms, and other conditions, and returns a list of formatted Contact data.
 */
public with sharing class SAP_InHousePublicOfficialController {
  /**
   * Retrieves a list of public officials based on the provided filtering parameters.
   *
   * @param paramsJson A JSON string representing the parameters used to filter the Contact records.
   * @return A list of maps, each containing key-value pairs representing the public official's contact information.
   *
   */

   public class PaginatedContactResult {
        @AuraEnabled public List<Map<String, Object>> records;
        @AuraEnabled public Integer totalRecordsProcessed;
    }

    @AuraEnabled
    public static PaginatedContactResult getPublicOfficial(String paramsJson) {
        Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(paramsJson);
        String lastName = (String) params.get('lastname');
        String firstName = (String) params.get('firstname');
        String position = (String) params.get('position');
        // Date termstart = parseDate(params.get('termstart'));
        // Date termend = parseDate(params.get('termend'));

        Date termstart = null;
        Date termend = null;
        // Check for null and convert string to Date if valid
        if (params.containsKey('termstart') && params.get('termstart') != null) {
            termstart = Date.valueOf((String)params.get('termstart'));
        }
        if (params.containsKey('termend') && params.get('termend') != null) {
            termend = Date.valueOf((String)params.get('termend'));
        }

        String town = (String) params.get('town');
        Integer offsetVal = (Integer) params.get('offsetVal');
        Integer pageSize = (Integer) params.get('pageSize');
        String sortBy = (String) params.get('sortBy');
        String sortDirection = (String) params.get('sortDirection');
        // Date transactionFromDate = parseDate(params.get('transactionFromDate'));
        // Date transactionToDate = parseDate(params.get('transactionToDate'));

        Date transactionFromDate = null;
        Date transactionToDate = null;

            // Check for null and convert string to Date if valid
        if (params.containsKey('transactionFromDate') && params.get('transactionFromDate') != null) {
            transactionFromDate = Date.valueOf((String)params.get('transactionFromDate'));
        }
        if (params.containsKey('transactionToDate') && params.get('transactionToDate') != null) {
            transactionToDate = Date.valueOf((String)params.get('transactionToDate'));
        }

        if (pageSize == null || pageSize <= 0) pageSize = 10;
        if (offsetVal == null || offsetVal < 0) offsetVal = 0;
        if (String.isBlank(sortBy)) sortBy = 'LastModifiedDate';
        if (sortDirection != 'ASC') sortDirection = 'DESC';

        Integer targetOffset = offsetVal;
        Integer batchSize = 20000;
        Integer fullBatches = targetOffset / batchSize;
        Integer remainingOffset = targetOffset - (Integer.valueOf(Math.floor(targetOffset / batchSize)) * batchSize);

        DateTime lastCursorDate = null;
        Id lastCursorId = null;
        List<Contact> batch = new List<Contact>();
        Integer totalProcessed = 0;

        List<String> baseConditions = new List<String>{'RecordType.DeveloperName = \'Apostille_Official\''};
        if (String.isNotBlank(lastName)) baseConditions.add('LastName LIKE \'%' + String.escapeSingleQuotes(lastName) + '%\'');
        if (String.isNotBlank(firstName)) baseConditions.add('FirstName LIKE \'%' + String.escapeSingleQuotes(firstName) + '%\'');
        if (String.isNotBlank(position)) baseConditions.add('SAP_Position__c LIKE \'%' + String.escapeSingleQuotes(position) + '%\'');
        if (termstart != null && termend != null) baseConditions.add('SAP_Start_Term__c >= :termstart AND SAP_End_Term__c <= :termend');
        else if (termstart != null) baseConditions.add('SAP_Start_Term__c >= :termstart');
        else if (termend != null) baseConditions.add('SAP_End_Term__c  <= :termend');
        if (String.isNotBlank(town)) baseConditions.add('SAP_Town__c LIKE \'%' + String.escapeSingleQuotes(town) + '%\'');
        if (transactionFromDate != null && transactionToDate != null) {
            if (transactionFromDate == transactionToDate) baseConditions.add('CreatedDate = TODAY');
            else baseConditions.add('CreatedDate >= :transactionFromDate AND CreatedDate <= :transactionToDate');
        }
        system.debug('fullBatches==='+fullBatches);
        String baseWhereClause = baseConditions.isEmpty() ? '' : ' WHERE ' + String.join(baseConditions, ' AND ');
        for (Integer i = 0; i <= fullBatches; i++) {
            String query = 'SELECT Id, LastName, FirstName, SAP_Position__c, SAP_Town__c, SAP_Start_Term__c, SAP_End_Term__c, SAP_Indefinite_Term__c, LastModifiedDate FROM Contact' + baseWhereClause;

            if (lastCursorDate != null && lastCursorId != null) {
                String cursorCondition = '(LastModifiedDate ' + (sortDirection == 'ASC' ? '>' : '<') + ' ' +
                                         formatDateTime(lastCursorDate) + ' OR (LastModifiedDate = ' +
                                         formatDateTime(lastCursorDate) + ' AND Id > \'' +
                                         String.escapeSingleQuotes(lastCursorId) + '\'))';
                query += (String.isNotBlank(baseWhereClause) ? ' AND ' : ' WHERE ') + cursorCondition;
            }

            query += ' ORDER BY ' + sortBy + ' ' + sortDirection + ' NULLS LAST '+ ', Id ASC LIMIT ' + batchSize;
            System.debug('### Full Query: ' + query);

            batch = Database.query(query);
            if (batch.isEmpty()) break;

            totalProcessed += batch.size();
            lastCursorDate = batch[batch.size() - 1].LastModifiedDate;
            lastCursorId = batch[batch.size() - 1].Id;

            if (i == fullBatches) {
                Integer startIndex = remainingOffset;
                Integer endIndex = Math.min(startIndex + pageSize, batch.size());

                List<Contact> pageSlice = new List<Contact>();
                for (Integer j = startIndex; j < endIndex; j++) {
                    pageSlice.add(batch[j]);
                }

                List<Map<String, Object>> formatted = new List<Map<String, Object>>();
                for (Contact con : pageSlice) {
                    Map<String, Object> data = new Map<String, Object>{
                        'Id' => con.Id,
                        'LastName' => capitalizeFirstLetter(con.LastName),
                        'FirstName' => capitalizeFirstLetter(con.FirstName),
                        'SAP_Position__c' => capitalizeFirstLetter(con.SAP_Position__c),
                        'SAP_Town__c' => capitalizeFirstLetter(con.SAP_Town__c),
                        'SAP_Indefinite_Term__c' => con.SAP_Indefinite_Term__c,
                        'FormattedStartTerm' => (con.SAP_Indefinite_Term__c) ? 'N/A' : formatCustomDate(con.SAP_Start_Term__c),
                        'FormattedEndTerm' => (con.SAP_Indefinite_Term__c) ? 'Indefinite Term' : formatCustomDate(con.SAP_End_Term__c)
                    };
                    formatted.add(data);
                }

                PaginatedContactResult result = new PaginatedContactResult();
                result.records = formatted;
                result.totalRecordsProcessed = totalProcessed;
                return result;
            }
        }

        PaginatedContactResult empty = new PaginatedContactResult();
        empty.records = new List<Map<String, Object>>();
        empty.totalRecordsProcessed = totalProcessed;
        return empty;
    }

 // Helper method to parse date safely
 @TestVisible
 private static Date parseDate(Object dateObj) {
  if (dateObj != null && dateObj instanceof String) {
      try {
          return Date.valueOf((String)dateObj);
      } catch (Exception e) {
          return null;
      }
  }
  return null;
}
      @TestVisible
      private static String formatDate(Date inputDate) {
        return inputDate.format(); // yyyy-MM-dd
    }

    // Format DateTime for dynamic SOQL
    @TestVisible
    private static String formatDateTime(DateTime dt) {
        return dt.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
    }

// Build cursor condition based on sorting field and direction
@TestVisible
private static String buildCursorCondition(String sortField, Object cursorValue, String sortDirection) {
  String condition = '';

  if (cursorValue instanceof String) {
      condition = sortField + (sortDirection == 'ASC' ? ' > ' : ' < ') +
                  '\'' + String.escapeSingleQuotes((String)cursorValue) + '\'';
  } else if (cursorValue instanceof Date) {
      condition = sortField + (sortDirection == 'ASC' ? ' > ' : ' < ') +
                  ((Date)cursorValue).format();
  } else if (cursorValue instanceof DateTime) {
      condition = sortField + (sortDirection == 'ASC' ? ' > ' : ' < ') +
                  ((DateTime)cursorValue).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
  } else {
      condition = sortField + (sortDirection == 'ASC' ? ' > ' : ' < ') +
                  String.valueOf(cursorValue);
  }

  return condition;
}



  /**
   * Capitalizes the first letter of a given string.
   *
   * @param inputString The string to format.
   * @return The input string with the first letter capitalized.
   */
  public static String capitalizeFirstLetter(String inputString) {
    if (String.isBlank(inputString)) {
      return '';
    }
    String formattedString =
      inputString.substring(0, 1).toUpperCase() +
      inputString.substring(1).toLowerCase();
    return formattedString;
  }
  /**
   * Formats a Date object into a custom string format MM/DD/YYYY.
   *
   * @param inputDate The date to format.
   * @return The formatted date as a string in MM/DD/YYYY format.
   */
   @TestVisible 
  private static String formatCustomDate(Date inputDate) {
    if (inputDate == null)
      return null;
    String formattedMonth = (inputDate.month() < 10)
      ? '0' + String.valueOf(inputDate.month())
      : String.valueOf(inputDate.month());
    String formattedDay = (inputDate.day() < 10)
      ? '0' + String.valueOf(inputDate.day())
      : String.valueOf(inputDate.day());
    return formattedMonth +
      '/' +
      formattedDay +
      '/' +
      String.valueOf(inputDate.year());
  }

  /**
   * Retrieves the count of public officials based on the provided search criteria in `paramsJson`.
   * The method deserializes the provided JSON, applies filtering conditions, and returns the count of the matched records.
   *
   * @param paramsJson - A JSON string containing the search parameters. It can include fields like last name, first name,
   *                     position, term start/end dates, town, and transaction dates.
   * @return Integer - The total count of matching public officials in the `Contact` object.
   */
  @AuraEnabled
  public static Integer getPublicOfficialCount(String paramsJson) {
    Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(
      paramsJson
    );
    String lastName = (String) params.get('lastname');
    String firstName = (String) params.get('firstname');
    String position = (String) params.get('position');
    Date termstart = null;
    Date termend = null;
    if (params.containsKey('termstart') && params.get('termstart') != null) {
      termstart = Date.valueOf((String) params.get('termstart'));
    }
    if (params.containsKey('termend') && params.get('termend') != null) {
      termend = Date.valueOf((String) params.get('termend'));
    }
    String town = (String) params.get('town');

    Date transactionFromDate = null;
    Date transactionToDate = null;

    if (
      params.containsKey('transactionFromDate') &&
      params.get('transactionFromDate') != null
    ) {
      transactionFromDate = Date.valueOf(
        (String) params.get('transactionFromDate')
      );
    }
    if (
      params.containsKey('transactionToDate') &&
      params.get('transactionToDate') != null
    ) {
      transactionToDate = Date.valueOf(
        (String) params.get('transactionToDate')
      );
    }

    List<String> conditions = new List<String>();
    conditions.add('RecordType.DeveloperName = \'Apostille_Official\'');

    String query = 'SELECT COUNT(Id) cnt FROM Contact';

    if (String.isNotBlank(lastName)) {
      conditions.add(
        'LastName LIKE \'%' + String.escapeSingleQuotes(lastName) + '%\''
      );
    }

    if (String.isNotBlank(firstName)) {
      conditions.add(
        'FirstName LIKE \'%' + String.escapeSingleQuotes(firstName) + '%\''
      );
    }

    if (String.isNotBlank(position)) {
      conditions.add(
        'SAP_Position__c LIKE \'%' + String.escapeSingleQuotes(position) + '%\''
      );
    }

    if (termstart != null && termend != null) {
      conditions.add(
        'SAP_Start_Term__c >= :termstart AND SAP_End_Term__c <= :termend'
      );
    } else if (termstart != null) {
      conditions.add('SAP_Start_Term__c >= :termstart');
    } else if (termend != null) {
      conditions.add('SAP_End_Term__c <= :termend');
    }

    if (String.isNotBlank(town)) {
      conditions.add(
        'SAP_Town__c LIKE \'%' + String.escapeSingleQuotes(town) + '%\''
      );
    }

    if (transactionFromDate != null && transactionToDate != null) {
      if (transactionFromDate == transactionToDate) {
        conditions.add('CreatedDate = TODAY');
      } else {
        conditions.add(
          'CreatedDate >= :transactionFromDate AND CreatedDate <= :transactionToDate'
        );
      }
    }

    if (!conditions.isEmpty()) {
      query += ' WHERE ' + String.join(conditions, ' AND ');
    }

    List<AggregateResult> countResult = Database.query(
      query,
      AccessLevel.USER_MODE
    );
    Integer totalCount = (countResult != null && !countResult.isEmpty())
      ? (Integer) countResult[0].get('cnt')
      : 0;

    return totalCount;
  }

  @AuraEnabled
  public static void deleteContact(Id recordId) {
    if (recordId != null) {
      try {
        delete [SELECT Id FROM Contact WHERE Id = :recordId LIMIT 1];
      } catch (DmlException e) {
        throw new AuraHandledException(
          'Error deleting contact: ' + e.getMessage()
        );
      }
    }
  }
  /**
   * Fetches the details of a specific public official contact record by its ID. It retrieves the fields related to
   * a public official, such as their name, term start/end dates, position, town, etc.
   *
   * @param recordId - The ID of the Contact record to fetch.
   *
   * @return Map<String, Object> - A map containing the contact record data as a list of records.
   */
  @AuraEnabled
  public static Map<String, Object> fetchPublicOfficialData(Id recordId) {
    List<Contact> records = [
      SELECT
        Id,
        SAP_Prefix__c,
        FirstName,
        MiddleName,
        LastName,
        SAP_Start_Term__c,
        SAP_End_Term__c,
        SAP_Position__c,
        SAP_NotaryCredentialId__c,
        SAP_Town__c,
        SAP_Indefinite_Term__c,
        SAP_Judicial_District__c,
        SAP_Seal_Stramp_of__c,
        SAP_Notes__c
      FROM Contact
      WHERE Id = :recordId
      WITH SECURITY_ENFORCED
      LIMIT 1
    ];

    Map<String, Object> result = new Map<String, Object>();
    result.put('records', records);
    return result;
  }

  /**
   * Updates or inserts a public official record based on the provided `Contact` object.
   * If the `Contact` object doesn't have an ID, it will be inserted as a new record; if it has an ID, it will be updated.
   * The record will be assigned the 'Apostille_Official' record type.
   *
   * @param newRecord - A `Contact` object representing the public official's data to update/insert.
   *
   * @return Id - The ID of the newly inserted or updated contact record.
   */
  @AuraEnabled
  public static Id updatePublicOfficialData(Contact newRecord) {
    Id officialRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
      .get('Apostille_Official')
      .getRecordTypeId();

    try {
      if (
        !Schema.sObjectType.Contact.isCreateable() ||
        !Schema.sObjectType.Contact.isUpdateable()
      ) {
        throw new AuraHandledException(
          'Insufficient permissions to create/update Contact records.'
        );
      }

      if (!Schema.sObjectType.Contact.fields.RecordTypeId.isAccessible()) {
        throw new AuraHandledException(
          'Insufficient permissions to access the RecordTypeId field.'
        );
      }

      if (newRecord.Id == null) {
        newRecord.RecordTypeId = officialRecordTypeId;
      }

      upsert newRecord;
    } catch (DmlException e) {
      throw new AuraHandledException(e.getMessage());
    }

    return newRecord.Id;
  }
  /**
   * Retrieves the history of changes made to the name fields (First Name, Middle Name, and Last Name) for a specific contact.
   * It compares the old and new values and returns a chronological log of these changes.
   *
   * @param contactId - The ID of the contact record for which the name history is being fetched.
   *
   * @return List<Map<String, Object>> - A list of maps representing the historical changes to the name fields.
   */
  @AuraEnabled
  public static List<Map<String, Object>> processNameFieldHistory(
    String contactId
  ) {
    Contact contactRecord = [
      SELECT FirstName, MiddleName, LastName, CreatedDate
      FROM Contact
      WHERE Id = :contactId
      WITH SECURITY_ENFORCED
      LIMIT 1
    ];

    List<ContactHistory> historyRecords = [
      SELECT Field, OldValue, NewValue, CreatedDate
      FROM ContactHistory
      WHERE
        ContactId = :contactId
        AND CreatedDate > :contactRecord.CreatedDate
        AND Field IN ('FirstName', 'MiddleName', 'LastName')
      WITH SECURITY_ENFORCED
      ORDER BY CreatedDate ASC
    ];

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
        initialFirstName = history.OldValue != null
          ? (String) history.OldValue
          : (String) history.NewValue;
        firstNameSet = true;
      } else if (history.Field == 'MiddleName' && !middleNameSet) {
        initialMiddleName = history.OldValue != null
          ? (String) history.OldValue
          : (String) history.NewValue;
        middleNameSet = true;
      } else if (history.Field == 'LastName' && !lastNameSet) {
        initialLastName = history.OldValue != null
          ? (String) history.OldValue
          : (String) history.NewValue;
        lastNameSet = true;
      }
    }

    List<Map<String, Object>> historyLog = new List<Map<String, Object>>();

    Map<String, Object> initialState = new Map<String, Object>();
    initialState.put('FirstName', initialFirstName);
    initialState.put('MiddleName', initialMiddleName);
    initialState.put('LastName', initialLastName);
    historyLog.add(initialState);
    String currentFirstName = initialFirstName;
    String currentMiddleName = initialMiddleName;
    String currentLastName = initialLastName;

    Map<String, Object> tempSnapshot = new Map<String, Object>();

    for (ContactHistory history : historyRecords) {
      if (
        lastCreatedDate != null && !lastCreatedDate.equals(history.CreatedDate)
      ) {
        historyLog.add(0, new Map<String, Object>(tempSnapshot));
        tempSnapshot.clear();
      }

      if (history.Field == 'FirstName') {
        currentFirstName = (String) history.NewValue;
      } else if (history.Field == 'MiddleName') {
        currentMiddleName = (String) history.NewValue;
      } else if (history.Field == 'LastName') {
        currentLastName = (String) history.NewValue;
      }

      tempSnapshot.put('FirstName', currentFirstName);
      tempSnapshot.put('MiddleName', currentMiddleName);
      tempSnapshot.put('LastName', currentLastName);

      lastCreatedDate = history.CreatedDate;
    }

    if (!tempSnapshot.isEmpty()) {
      historyLog.add(0, new Map<String, Object>(tempSnapshot));
    }

    if (!historyLog.isEmpty() && historyLog.size() > 1) {
      historyLog.remove(0);
    }

    return historyLog;
  }
  /**
   * Retrieves the history of changes made to the term fields (SAP_Start_Term__c, SAP_End_Term__c) for a specific contact.
   * It compares the old and new values and returns a chronological log of these changes.
   *
   * @param contactId - The ID of the contact record for which the term history is being fetched.
   */
  @AuraEnabled
  public static List<Map<String, Object>> processTermFieldHistory(
    String contactId
  ) {
    Contact contactRecord = [
      SELECT SAP_Start_Term__c, SAP_End_Term__c
      FROM Contact
      WHERE Id = :contactId
      WITH SECURITY_ENFORCED
      LIMIT 1
    ];

    List<ContactHistory> historyRecords = [
      SELECT Id, Field, OldValue, NewValue, CreatedDate
      FROM ContactHistory
      WHERE
        ContactId = :contactId
        AND Field IN ('SAP_Start_Term__c', 'SAP_End_Term__c')
      WITH SECURITY_ENFORCED
      ORDER BY CreatedDate ASC
    ];

    if (historyRecords.isEmpty()) {
      return new List<Map<String, Object>>();
    }

    String initialStartTerm = contactRecord.SAP_Start_Term__c != null
      ? formatCustomDate(contactRecord.SAP_Start_Term__c)
      : 'Indefinite Term';
    String initialEndTerm = contactRecord.SAP_End_Term__c != null
      ? formatCustomDate(contactRecord.SAP_End_Term__c)
      : 'Indefinite Term';

    Boolean startTermSet = false;
    Boolean endTermSet = false;
    DateTime lastCreatedDate = null;

    for (ContactHistory history : historyRecords) {
      if (history.Field == 'SAP_Start_Term__c' && !startTermSet) {
        initialStartTerm = history.OldValue != null
          ? formatCustomDate((Date) history.OldValue)
          : 'Indefinite Term';
        startTermSet = true;
      } else if (history.Field == 'SAP_End_Term__c' && !endTermSet) {
        initialEndTerm = history.OldValue != null
          ? formatCustomDate((Date) history.OldValue)
          : 'Indefinite Term';
        endTermSet = true;
      }
    }

    List<Map<String, Object>> historyLog = new List<Map<String, Object>>();

    Map<String, Object> initialState = new Map<String, Object>();
    initialState.put('SAP_Start_Term__c', initialStartTerm);
    initialState.put('SAP_End_Term__c', initialEndTerm);
    historyLog.add(initialState);
    String currentStartTerm = initialStartTerm;
    String currentEndTerm = initialEndTerm;

    Map<String, Object> tempSnapshot = new Map<String, Object>();

    for (ContactHistory history : historyRecords) {
      if (
        lastCreatedDate != null && !lastCreatedDate.equals(history.CreatedDate)
      ) {
        historyLog.add(0, new Map<String, Object>(tempSnapshot));
        tempSnapshot.clear();
      }

      if (history.Field == 'SAP_Start_Term__c') {
        currentStartTerm = history.NewValue != null
          ? formatCustomDate((Date) history.NewValue)
          : 'Indefinite Term';
      } else if (history.Field == 'SAP_End_Term__c') {
        currentEndTerm = history.NewValue != null
          ? formatCustomDate((Date) history.NewValue)
          : 'Indefinite Term';
      }

      tempSnapshot.put('Id', history.Id);
      tempSnapshot.put('SAP_Start_Term__c', currentStartTerm);
      tempSnapshot.put('SAP_End_Term__c', currentEndTerm);
      lastCreatedDate = history.CreatedDate;
    }

    if (!tempSnapshot.isEmpty()) {
      historyLog.add(0, new Map<String, Object>(tempSnapshot));
    }

    if (!historyLog.isEmpty() && historyLog.size() > 1) {
      historyLog.remove(0);
    }
    return historyLog;
  }
  /*  @AuraEnabled
public static List<Map<String, Object>> processNameFieldHistory(String contactId) {
    // Fetch the Contact record
    Contact contactRecord = [
        SELECT FirstName, MiddleName, LastName, CreatedDate
        FROM Contact
        WHERE Id = :contactId
        WITH SECURITY_ENFORCED
        LIMIT 1
    ];

    // Fetch the history records
    List<ContactHistory> historyRecords = [
        SELECT Field, OldValue, NewValue, CreatedDate
        FROM ContactHistory
        WHERE
            ContactId = :contactId
            AND CreatedDate > :contactRecord.CreatedDate
            AND Field IN ('FirstName', 'MiddleName', 'LastName')
        WITH SECURITY_ENFORCED
        ORDER BY CreatedDate ASC
    ];

    // Pass the fetched records to the helper method for processing
    return buildNameFieldHistory(contactRecord, historyRecords);
}
public static List<Map<String, Object>> buildNameFieldHistory(Contact contactRecord, List<ContactHistory> historyRecords) {
    // Initialize fields for FirstName, MiddleName, LastName
    String initialFirstName = contactRecord.FirstName;
    String initialMiddleName = contactRecord.MiddleName;
    String initialLastName = contactRecord.LastName;

    // Flags to track if name fields are set
    Boolean firstNameSet = false;
    Boolean middleNameSet = false;
    Boolean lastNameSet = false;
    DateTime lastCreatedDate = null;

    // Process history records to track changes
    for (ContactHistory history : historyRecords) {
        if (history.Field == 'FirstName' && !firstNameSet) {
            initialFirstName = history.OldValue != null ? (String) history.OldValue : (String) history.NewValue;
            firstNameSet = true;
        } else if (history.Field == 'MiddleName' && !middleNameSet) {
            initialMiddleName = history.OldValue != null ? (String) history.OldValue : (String) history.NewValue;
            middleNameSet = true;
        } else if (history.Field == 'LastName' && !lastNameSet) {
            initialLastName = history.OldValue != null ? (String) history.OldValue : (String) history.NewValue;
            lastNameSet = true;
        }
    }

    List<Map<String, Object>> historyLog = new List<Map<String, Object>>();

    // Add initial state before any changes
    Map<String, Object> initialState = new Map<String, Object>();
    initialState.put('FirstName', initialFirstName);
    initialState.put('MiddleName', initialMiddleName);
    initialState.put('LastName', initialLastName);
    historyLog.add(initialState);

    String currentFirstName = initialFirstName;
    String currentMiddleName = initialMiddleName;
    String currentLastName = initialLastName;

    // Temporary map to store the latest name state
    Map<String, Object> tempSnapshot = new Map<String, Object>();

    for (ContactHistory history : historyRecords) {
        if (lastCreatedDate != null && !lastCreatedDate.equals(history.CreatedDate)) {
            historyLog.add(0, new Map<String, Object>(tempSnapshot));
            tempSnapshot.clear();
        }

        // Update the name fields based on history changes
        if (history.Field == 'FirstName') {
            currentFirstName = (String) history.NewValue;
        } else if (history.Field == 'MiddleName') {
            currentMiddleName = (String) history.NewValue;
        } else if (history.Field == 'LastName') {
            currentLastName = (String) history.NewValue;
        }

        tempSnapshot.put('FirstName', currentFirstName);
        tempSnapshot.put('MiddleName', currentMiddleName);
        tempSnapshot.put('LastName', currentLastName);

        lastCreatedDate = history.CreatedDate;
    }

    if (!tempSnapshot.isEmpty()) {
        historyLog.add(0, new Map<String, Object>(tempSnapshot));
    }

    // Remove initial snapshot if only one history entry exists
    if (!historyLog.isEmpty() && historyLog.size() > 1) {
        historyLog.remove(0);
    }

    return historyLog;
}*/


  @AuraEnabled
    public static List<Map<String, Object>> getNotaryPublicNameHistory(String credentialId) {
        List<SAP_Notary_Public_Name_History__c> nameHistoryRecords = [
            SELECT FirstName__c, MiddleName__c, LastName__c, OldName__c, Name_Modified_Date__c
            FROM SAP_Notary_Public_Name_History__c 
            WHERE CredentialId__c = :credentialId WITH SECURITY_ENFORCED
            ORDER BY Name_Modified_Date__c DESC
        ];
        List<Map<String, Object>> nameHistoryList = new List<Map<String, Object>>();
        for (SAP_Notary_Public_Name_History__c record : nameHistoryRecords) {
            Map<String, Object> nameRecord = new Map<String, Object>();
            nameRecord.put('changeDate', record.Name_Modified_Date__c);
            nameRecord.put('FirstName', record.FirstName__c);
            nameRecord.put('oldName', record.OldName__c);
            nameRecord.put('MiddleName', record.MiddleName__c);
            nameRecord.put('LastName', record.LastName__c);
            nameHistoryList.add(nameRecord);
        }
        return nameHistoryList;
    }
    @AuraEnabled
    public static List<Map<String, Object>> getNotaryPublicTermHistory(String credentialId) {
        List<SAP_Notary_Public_Term_History__c> termHistoryRecords = [
            SELECT Start_Term__c, End_Term__c, IndefiniteTerm__c, Term_Modified_Date__c
            FROM SAP_Notary_Public_Term_History__c
            WHERE CredentialId__c = :credentialId WITH SECURITY_ENFORCED
            ORDER BY Start_Term__c DESC
        ];
        List<Map<String, Object>> termHistoryList = new List<Map<String, Object>>();
        for (SAP_Notary_Public_Term_History__c record : termHistoryRecords) {
            Map<String, Object> termRecord = new Map<String, Object>();
            termRecord.put('changeDate', record.Term_Modified_Date__c);
            termRecord.put('SAP_Start_Term__c', record.Start_Term__c);
            termRecord.put('SAP_End_Term__c', record.End_Term__c);
            
            // Handle Indefinite Term styling based on JavaScript logic
            if (record.IndefiniteTerm__c == true) {
                termRecord.put('SAP_Start_Term__c', 'Indefinite Term');
                termRecord.put('SAP_End_Term__c', 'Indefinite Term');
            } else {
                termRecord.put('SAP_Start_Term_Class', 'spacing');
                termRecord.put('SAP_End_Term_Class', 'spacing');
            }
            termHistoryList.add(termRecord);
        }
        return termHistoryList;
    }
}