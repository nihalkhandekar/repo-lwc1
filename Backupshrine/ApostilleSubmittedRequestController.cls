public with sharing class ApostilleSubmittedRequestController {

@AuraEnabled(cacheable=true)
public static List<Map<String, Object>> getApplications(String paramsJson) {
    try {
        String query = buildQuery(paramsJson);
        List<IndividualApplication> applications = Database.query(query, AccessLevel.SYSTEM_MODE);
        return processApplicationResults(applications);
    } catch (Exception e) {
        throw new AuraHandledException('Error fetching data. Please try again later.');
    }
}

private static String buildQuery(String paramsJson) {

    Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(paramsJson);

    String workOrder = (String)params.get('workOrder');
    String requestDate = (String)params.get('requestDate');
    String requesterName = (String)params.get('requesterName');
    Integer offsetVal = (Integer)params.get('offsetVal');
    Integer pageSize = (Integer)params.get('pageSize');
    String sortBy = (String)params.get('sortBy');
    String sortDirection = (String)params.get('sortDirection');
    String documentType = (String)params.get('documentType');
    String workOrderStatus = (String)params.get('workOrderStatus');

    String recordId = params.containsKey('recordId') ? (String)params.get('recordId') : '';

    String query = 'SELECT Id, Sequence_Number__c, Organization_Name__c, First_Name__c, Last_Name__c, AppliedDate, Country__c, Status ' +
                   'FROM IndividualApplication ' +
                   'WHERE RecordType.Name = \'Apostille\' AND Status NOT IN (\'Cancelled\', \'Cancelled By Customer\', \'Cancelled By System\', \'Cancelled By Staff\', \'Draft\',\'Cancelled\')';

    if (String.isNotBlank(workOrder)) {
        query += ' AND Sequence_Number__c LIKE \'%' + String.escapeSingleQuotes(workOrder) + '%\'';
    }

    if (String.isNotBlank(recordId)) {
        query += ' AND Id = \'' + recordId + '\'';
    }

    if (String.isNotBlank(workOrderStatus)) {
        query += ' AND Status = \'' + String.escapeSingleQuotes(workOrderStatus) + '\'';
    }

    if (String.isNotBlank(documentType)) {
        query += ' AND Id IN (SELECT ParentRecordId FROM DocumentChecklistItem WHERE DocumentType.MasterLabel = \'' + String.escapeSingleQuotes(documentType) + '\')';
    }

    if (String.isNotBlank(requesterName)) {
        query += ' AND (Organization_Name__c LIKE \'%' + String.escapeSingleQuotes(requesterName) + '%\' ' +
                 'OR (Organization_Name__c = null AND (First_Name__c LIKE \'%' + String.escapeSingleQuotes(requesterName) + '%\' ' +
                 'OR Last_Name__c LIKE \'%' + String.escapeSingleQuotes(requesterName) + '%\')))';
    }

     if (String.isNotBlank(requestDate)) {
        try {
            // Parse the date string into a Date object
            Date receivedDate = Date.valueOf(requestDate);

            // Create Datetime objects for the start and end of the day
            Datetime startOfDay = Datetime.newInstance(receivedDate, Time.newInstance(0, 0, 0, 0));
            Datetime endOfDay = Datetime.newInstance(receivedDate, Time.newInstance(23, 59, 59, 999));

            // Add the date range condition to the query
            query += ' AND AppliedDate >= ' + startOfDay.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'') +
                     ' AND AppliedDate <= ' + endOfDay.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        } catch (Exception e) {
            System.debug('Error parsing date: ' + e.getMessage());
            throw new AuraHandledException('Invalid date format. Please use YYYY-MM-DD format.');
        }
    }


    if (String.isNotBlank(sortBy)) {
            String sortField = getSortField(sortBy);
            query += ' ORDER BY ' + String.escapeSingleQuotes(sortField) + ' ' + String.escapeSingleQuotes(sortDirection);
    }

    query += ' LIMIT ' + pageSize + ' OFFSET ' + offsetVal;

    return query;
}

private static String getSortField(String sortBy) {
    Map<String, String> sortFieldMap = new Map<String, String>{
        'ApplicationID' => 'Sequence_Number__c',
        'requestorName' => 'Organization_Name__c',
        'AppliedDate' => 'AppliedDate',
        'Destination__c' => 'Country__c',
        'Status' => 'Status'
    };
    return sortFieldMap.containsKey(sortBy) ? sortFieldMap.get(sortBy) : sortBy;
}

private static List<Map<String, Object>> processApplicationResults(List<IndividualApplication> applications) {
    List<Map<String, Object>> result = new List<Map<String, Object>>();
    Set<Id> applicationIds = new Set<Id>();
    for (IndividualApplication app : applications) {
        applicationIds.add(app.Id);
    }

    Map<Id, List<DocumentChecklistItem>> documentsByApplication = getDocumentsByApplication(applicationIds);

    for (IndividualApplication app : applications) {
        Map<String, Object> record = new Map<String, Object>();
        List<DocumentChecklistItem> docs = documentsByApplication.get(app.Id);
        DocumentChecklistItem firstDoc = docs != null && !docs.isEmpty() ? docs[0] : null;

        String name = String.isNotBlank(app.Organization_Name__c) ?
                     app.Organization_Name__c : (app.First_Name__c + ' ' + app.Last_Name__c).trim();

        record.put('Id', app.Id);
        record.put('ApplicationID', app.Sequence_Number__c);
        record.put('requestorName', name);
        record.put('AppliedDate', formatCustomDateTime(app.AppliedDate));
        record.put('Status',app.Status);

        if (firstDoc != null) {
            record.put('signedByName', firstDoc.Signed_By__r.Name);
            record.put('signedByPosition', firstDoc.signedBy_Position__c);
            record.put('Destination__c', firstDoc.Country__c);
            record.put('documentType', firstDoc.DocumentType.MasterLabel);
        } else {
            record.put('signedByName', '');
            record.put('signedByPosition', '');
            record.put('Destination__c', app.Country__c);
            record.put('documentType', '');
        }

        String unexpandedStatus = app.Status + (firstDoc != null ? ' / ' + firstDoc.Status : '');
        record.put('unexpandedStatus', unexpandedStatus);
        record.put('expandedStatus', (firstDoc != null ? firstDoc.Status + ' / ' : '') + app.Status);

        List<Map<String, Object>> documents = processDocuments(docs, app, name);
        record.put('docCount', documents.size());
        record.put('hasDocuments', !documents.isEmpty());
        record.put('documents', documents);

        result.add(record);
    }

    return result;
}

private static Map<Id, List<DocumentChecklistItem>> getDocumentsByApplication(Set<Id> applicationIds) {
    Map<Id, List<DocumentChecklistItem>> documentsByApplication = new Map<Id, List<DocumentChecklistItem>>();
    for (DocumentChecklistItem doc : [SELECT Id, ParentRecordId, Signed_By__r.Name, signedBy_Position__c,
                                      Country__c, DocumentType.MasterLabel, Status, CreatedDate
                                      FROM DocumentChecklistItem
                                      WHERE ParentRecordId IN :applicationIds
                                      ORDER BY CreatedDate ASC ]) {
        if (!documentsByApplication.containsKey(doc.ParentRecordId)) {
            documentsByApplication.put(doc.ParentRecordId, new List<DocumentChecklistItem>());
        }
        documentsByApplication.get(doc.ParentRecordId).add(doc);
    }
    return documentsByApplication;
}

private static List<Map<String, Object>> processDocuments(List<DocumentChecklistItem> docs, IndividualApplication app, String name) {
    List<Map<String, Object>> documents = new List<Map<String, Object>>();
    if (docs != null) {
        for (Integer i = 1; i < docs.size(); i++) {
            DocumentChecklistItem doc = docs[i];
            Map<String, Object> document = new Map<String, Object>{
                'Id' => doc.Id,
                'ApplicationID' => app.Sequence_Number__c,
                'requestorName' => name,
                'AppliedDate' => formatCustomDateTime(app.AppliedDate),
                'signedByName' => doc.Signed_By__r.Name,
                'signedByPosition' => doc.signedBy_Position__c,
                'Destination__c' => doc.Country__c,
                'documentType' => doc.DocumentType.MasterLabel,
                'Status' => doc.Status
            };
            documents.add(document);
        }
    }
    return documents;
}

    @AuraEnabled(cacheable=true)
    //public static Integer getApplicationsCount(String workOrder, String requestDate, String requesterName, String documentType, String workOrderStatus,String recordId)
    public static Integer getApplicationsCount(String paramsJson)
    {

    Map<String, Object> params = new Map<String, Object>();
    if (paramsJson != null) {
        params = (Map<String, Object>) JSON.deserializeUntyped(paramsJson);
    }

    String workOrder = (String)params.get('workOrder');
    String requestDate = (String)params.get('requestDate');
    String requesterName = (String)params.get('requesterName');
    String documentType = (String)params.get('documentType');
    String workOrderStatus = (String)params.get('workOrderStatus');
    String recordId = (String)params.get('recordId');

        // String query = buildCountQuery(workOrder, requestDate, requesterName, documentType, workOrderStatus,recordId);
        String query = buildCountQuery(params);
        List<AggregateResult> countResult = Database.query(query, AccessLevel.SYSTEM_MODE);
        return (countResult != null && !countResult.isEmpty()) ? (Integer) countResult[0].get('cnt') : 0;
    }

    // private static String buildCountQuery(String workOrder, String requestDate, String requesterName, String documentType, String workOrderStatus, String recordId) {
        private static String buildCountQuery(Map<String, Object> params) {
            String workOrder = (String)params.get('workOrder');
            String requestDate = (String)params.get('requestDate');
            String requesterName = (String)params.get('requesterName');
            String documentType = (String)params.get('documentType');
            String workOrderStatus = (String)params.get('workOrderStatus');
            String recordId = (String)params.get('recordId');

        String query = 'SELECT COUNT(Id) cnt FROM IndividualApplication ' +
                       'WHERE RecordType.Name = \'Apostille\' AND Status NOT IN (\'Cancelled\', \'Cancelled By Customer\', \'Cancelled By System\', \'Cancelled By Staff\', \'Draft\')';

        if (String.isNotBlank(workOrder)) {
            query += ' AND Sequence_Number__c LIKE \'%' + String.escapeSingleQuotes(workOrder) + '%\'';
        }

        if (String.isNotBlank(recordId)) {
            query += ' AND Id = \'' + recordId + '\'';
        }

        if (String.isNotBlank(workOrderStatus)) {
            query += ' AND Status = \'' + String.escapeSingleQuotes(workOrderStatus) + '\'';
        }

        if (String.isNotBlank(documentType)) {
            query += ' AND Id IN (SELECT ParentRecordId FROM DocumentChecklistItem WHERE DocumentType.MasterLabel = \'' + String.escapeSingleQuotes(documentType) + '\')';
        }

        if (String.isNotBlank(requesterName)) {
            query += ' AND (Organization_Name__c LIKE \'%' + String.escapeSingleQuotes(requesterName) + '%\' ' +
                     'OR (Organization_Name__c = null AND (First_Name__c LIKE \'%' + String.escapeSingleQuotes(requesterName) + '%\' ' +
                     'OR Last_Name__c LIKE \'%' + String.escapeSingleQuotes(requesterName) + '%\')))';
        }

      if (String.isNotBlank(requestDate)) {
        try {
            // Parse the date string into a Date object
            Date receivedDate = Date.valueOf(requestDate);

            // Create Datetime objects for the start and end of the day
            Datetime startOfDay = Datetime.newInstance(receivedDate, Time.newInstance(0, 0, 0, 0));
            Datetime endOfDay = Datetime.newInstance(receivedDate, Time.newInstance(23, 59, 59, 999));

            // Add the date range condition to the query
            query += ' AND AppliedDate >= ' + startOfDay.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'') +
                     ' AND AppliedDate <= ' + endOfDay.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        } catch (Exception e) {
            System.debug('Error parsing date: ' + e.getMessage());
            throw new AuraHandledException('Invalid date format. Please use YYYY-MM-DD format.');
        }
    }

        return query;
    }

    private static String formatCustomDateTime(DateTime dt) {
        if (dt == null) return null;
        Date dateOnly = dt.dateGmt();
        String formattedMonth = (dateOnly.month() < 10) ? '0' + String.valueOf(dateOnly.month()) : String.valueOf(dateOnly.month());
        String formattedDay = (dateOnly.day() < 10) ? '0' + String.valueOf(dateOnly.day()) : String.valueOf(dateOnly.day());
        return formattedMonth + '/' + formattedDay + '/' + dateOnly.year();
    }



    @AuraEnabled
    public static Boolean updateApplicationStatusToCancelled(String recordId) {
        try {
            IndividualApplication app = [SELECT Status FROM IndividualApplication WHERE Id = :recordId AND Status = 'Submitted' WITH SECURITY_ENFORCED LIMIT 1];
            if (app != null) {
                app.Status = 'Cancelled By Customer';
                app.Cancellation_Type__c = 'Cancelled by Customer';
                app.Reason_for_Cancellation__c = 'Cancelled by Customer';
                app.Cancellation_Date__c = Date.today();
                Database.update(app, false, AccessLevel.USER_MODE);
                return true;
            }
            return false;
        } catch (Exception e) {
            system.debug('error' + e.getCause());
            system.debug(e.getStackTraceString());
            System.debug('Error: ' + e.getMessage());
            return false;
        }
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Integer> getApplicationCountsByStatus(Date startDateForQuery, Date endDateForQuery) {
        Map<String, Integer> statusCounts = new Map<String, Integer>{
            'submitted' => 0,
            'completed' => 0,
            'draft' => 0
        };

        String query = 'SELECT Status, COUNT(Id) cnt FROM IndividualApplication ' +
                       'WHERE RecordType.Name = \'Apostille\' ';

        if (startDateForQuery != null) {
            query += 'AND AppliedDate >= :startDateForQuery ';
        }
        if (endDateForQuery != null) {
            query += 'AND AppliedDate <= :endDateForQuery ';
        }

        query += 'GROUP BY Status';

        for (AggregateResult ar : Database.query(query, AccessLevel.USER_MODE)) {
            String status = (String) ar.get('Status');
            Integer count = (Integer) ar.get('cnt');

            if (status == 'Submitted') {
                statusCounts.put('submitted', count);
            } else if (status == 'Completed') {
                statusCounts.put('completed', count);
            } else if (status == 'Draft') {
                statusCounts.put('draft', count);
            } else if (status == 'Cancelled') {
                statusCounts.put('draft', count);
            }else if (status == 'In Review') {
                statusCounts.put('in_review', count);
            } else if (status == 'Application Accepted') {
                statusCounts.put('application_accepted', count);
            } else if (status == 'Approved') {
                statusCounts.put('approved', count);
            } else if (status == 'Denied') {
                statusCounts.put('denied', count);
            } else if (status == 'Order Completed - Mail') {
                statusCounts.put('order_completed_mail', count);
            } else if (status == 'Order Completed – Pick Up') {
                statusCounts.put('Order_completed_pick_up', count);
            } else if (status == 'Cancelled') {
                statusCounts.put('cancelled', count);
            }
        }

        return statusCounts;
    }
}