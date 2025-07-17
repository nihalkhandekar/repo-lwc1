public with sharing class SAP_AttorneyInspectorController {
    @AuraEnabled
    public static List<Map<String, Object>> getAttorneyRecord(String paramsJson) {

        Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(paramsJson);
       String lastName = (String)params.get('lastname');
       String firstName = (String)params.get('firstname');
       String middleName = (String)params.get('middlename');   
       String phoneNumber = (String)params.get('phonenumber');

       Integer offsetVal = (Integer)params.get('offsetVal');
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

       List<String> conditions = new List<String>();
       conditions.add('RecordType.DeveloperName = \'Attorney_Inspector\'');
       System.debug('### Initial condition (RecordType.DeveloperName): ' + conditions);

       String query = 'SELECT Id, FirstName, LastName, MiddleName, MailingCity, MailingCountry, MailingStreet, MailingPostalCode, Phone, CreatedDate, LastModifiedDate FROM Contact';

       if (String.isNotBlank(lastName)) {
           conditions.add('LastName LIKE \'%' + String.escapeSingleQuotes(lastName) + '%\'');
           System.debug('### lastName condition added: ' + conditions);
       }

       if (String.isNotBlank(firstName)) {
           conditions.add('FirstName LIKE \'%' + String.escapeSingleQuotes(firstName) + '%\'');
           System.debug('### firstName condition added: ' + conditions);
       }

       if (String.isNotBlank(middleName)) {
           conditions.add('MiddleName LIKE \'%' + String.escapeSingleQuotes(middleName) + '%\'');
           System.debug('### position condition added: ' + conditions);
       }
      

       if (String.isNotBlank(phoneNumber)) {
           conditions.add('Phone LIKE \'%' + String.escapeSingleQuotes(phoneNumber) + '%\'');
           System.debug('### Town condition added: ' + conditions);
       }

       if (transactionFromDate != null && transactionToDate != null) {
           if (transactionFromDate == transactionToDate) {
               conditions.add('CreatedDate = TODAY');
           } else {
               conditions.add('CreatedDate >= :transactionFromDate AND CreatedDate <= :transactionToDate');
           }
       }  
       
       if (!conditions.isEmpty()) {
           query += ' WHERE ' + String.join(conditions, ' AND ');
       }

        String sortField = String.isNotBlank(sortBy) ? sortBy : 'LastModifiedDate';
       String sortOrder = (sortDirection == 'ASC' || sortDirection == 'DESC') ? sortDirection : 'DESC';
       query += ' ORDER BY ' + sortField + ' ' + sortOrder+ ' NULLS LAST ';

       query += ' LIMIT ' + pageSize + ' OFFSET ' + offsetVal;

       // Debug final query before sorting
       System.debug('### Final query before sorting: ' + query);
       System.debug('### Final query with sorting and pagination: ' + query);

       try {
        List<Contact> result = Database.query(query, AccessLevel.USER_MODE);
           
           List<Map<String, Object>> formattedResults = new List<Map<String, Object>>();
       for (Contact con : result) {
           Map<String, Object> contactData = new Map<String, Object>();
           contactData.put('Id', con.Id);
           contactData.put('LastName', capitalizeFirstLetter(con.LastName));
           contactData.put('FirstName', capitalizeFirstLetter(con.FirstName));
           contactData.put('MiddleName', capitalizeFirstLetter(con.MiddleName));
           contactData.put('Phone', capitalizeFirstLetter(con.Phone));
           contactData.put('MailingStreet', capitalizeFirstLetter(con.MailingStreet));
           contactData.put('MailingCity', capitalizeFirstLetter(con.MailingCity));
           contactData.put('MailingPostalCode', capitalizeFirstLetter(con.MailingPostalCode));
           contactData.put('MailingCountry', capitalizeFirstLetter(con.MailingCountry));

           // Add the contact data map to the result list
           formattedResults.add(contactData);
        //   System.debug('contactData is '+ contactData);
       }
       System.debug('Result is '+ formattedResults);
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


@AuraEnabled
public static Integer getAttorneyRecordCount(String paramsJson) {

     Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(paramsJson);
     String lastName = (String)params.get('lastname');
     String firstName = (String)params.get('firstname');
     String middleName = (String)params.get('middlename');   
     String phoneNumber = (String)params.get('phonenumber');
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
    conditions.add('RecordType.DeveloperName = \'Attorney_Inspector\'');
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


    if (String.isNotBlank(middleName)) {
        conditions.add('MiddleName LIKE \'%' + String.escapeSingleQuotes(middleName) + '%\'');
        System.debug('### position condition added: ' + conditions);
    }
   

    if (String.isNotBlank(phoneNumber)) {
        conditions.add('Phone LIKE \'%' + String.escapeSingleQuotes(phoneNumber) + '%\'');
        System.debug('### Town condition added: ' + conditions);
    }

    if (transactionFromDate != null && transactionToDate != null) {
        if (transactionFromDate == transactionToDate) {
            conditions.add('CreatedDate = TODAY');
        } else {
            conditions.add('CreatedDate >= :transactionFromDate AND CreatedDate <= :transactionToDate');
        }
    }  
    
    if (!conditions.isEmpty()) {
        query += ' WHERE ' + String.join(conditions, ' AND ');
    }

    List<AggregateResult> countResult = Database.query(query, AccessLevel.USER_MODE);
    Integer totalCount = (countResult != null && !countResult.isEmpty()) ? (Integer) countResult[0].get('cnt') : 0;

    System.debug('total is ->'+ totalCount);
     return totalCount;
}



}