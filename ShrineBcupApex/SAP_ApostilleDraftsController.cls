public with sharing class SAP_ApostilleDraftsController {
    
   @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getApplications(String paramsJson, String status) {
        try {
            String query = buildQuery(paramsJson, status);
            List<IndividualApplication> applications = Database.query(query);
            return processApplicationResults(applications, status);
        } catch (Exception e) {
            System.debug('Error in getApplications: ' + e.getMessage());
            throw new AuraHandledException('Error fetching data. Please try again later.');
        }
    }

    private static String buildQuery(String paramsJson, String status) {
        Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(paramsJson);

        Integer offsetVal = (Integer)params.get('offsetVal');
        Integer pageSize = (Integer)params.get('pageSize');
        String sortBy = (String)params.get('sortBy');
        String sortDirection = (String)params.get('sortDirection');

        // Base query for applications
        String query = 'SELECT Id, Name, SAP_Organization_Name__c, SAP_Sequence_Number__c, SAP_First_Name__c, SAP_Last_Name__c, ' +
                    'SAP_Expedited__c, CreatedDate ';

        // For "Cancelled" status, add specific fields
        if (status == 'Cancelled By Customer') {
            query += ', AppliedDate, SAP_Cancellation_Type__c, SAP_Cancellation_Date__c, SAP_Reason_for_Cancellation__c ';
        }

        // For "Draft" status, add different fields
        if (status == 'Draft') {
            query += ', SAP_Address_Line_1__c, SAP_Suite_Apartment_Floor__c, SAP_City__c, SAP_State__c, SAP_Zip_Code__c, SAP_Country__c';
        }

        query += ' FROM IndividualApplication WHERE Status = \'' + String.escapeSingleQuotes(status) + '\' ';

        if (params.containsKey('IndividualApplicationId') && params.get('IndividualApplicationId') != null) {
            query += ' AND Id = \'' + String.escapeSingleQuotes((String)params.get('IndividualApplicationId')) + '\' ';
        }


        // Apply sorting
        if (String.isNotBlank(sortBy)) {
            String sortField = getSortField(sortBy, status);
            query += ' ORDER BY ' + String.escapeSingleQuotes(sortField) + ' ' + String.escapeSingleQuotes(sortDirection);
        }

        query += ' LIMIT ' + pageSize + ' OFFSET ' + offsetVal;

        System.debug('Generated Query: ' + query); // For debugging

        return query;
    }

    private static String getSortField(String sortBy, String status) {
        Map<String, String> sortFieldMap = new Map<String, String>{
            'ApplicationID' => 'SAP_Sequence_Number__c',
            'requestorName' => 'SAP_Organization_Name__c'
        };

        // Add sort fields specific to "Cancelled" status
        if (status == 'Cancelled By Customer') {
            sortFieldMap.put('CancellationType', 'SAP_Cancellation_Type__c');
            sortFieldMap.put('CancellationDate', 'SAP_Cancellation_Date__c');
            sortFieldMap.put('ReasonForCancellation','SAP_Reason_for_Cancellation__c');
        }
        if(status == 'Draft'){
            sortFieldMap.put('Expedited', 'SAP_Expedited__c');
            sortFieldMap.put('address', 'SAP_Address_Line_1__c');

        }

        return sortFieldMap.containsKey(sortBy) ? sortFieldMap.get(sortBy) : sortBy;
    }

    private static List<Map<String, Object>> processApplicationResults(List<IndividualApplication> applications, String status) {
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

            String name = String.isNotBlank(app.SAP_Organization_Name__c) ? 
                         app.SAP_Organization_Name__c : (app.SAP_First_Name__c + ' ' + app.SAP_Last_Name__c).trim();

            // Build the address string
            if(status == 'Draft'){
                String address = buildAddress(app);
                record.put('address', address);
                record.put('Expedited', app.SAP_Expedited__c);
            }

            record.put('Id', app.Id);
            record.put('ApplicationID', app.SAP_Sequence_Number__c);
            record.put('requestorName', name);
            String formattedDate = app.CreatedDate.format('MM/dd/yyyy | hh:mm:ss a');
            record.put('CreatedDate', formattedDate);

            // Handle "Cancelled" specific fields
            if (status == 'Cancelled By Customer') {
                record.put('CancellationType', app.SAP_Cancellation_Type__c);
                record.put('ReasonForCancellation', app.SAP_Reason_for_Cancellation__c);
                record.put('CancellationDate', formatCustomDateTime(app.SAP_Cancellation_Date__c));
                record.put('AppliedDate', formatCustomDateTime(app.AppliedDate));
            }

            if (firstDoc != null) {
                record.put('documentType', firstDoc.DocumentType.MasterLabel);
            } else {
                record.put('documentType', '');
            }

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
        for (DocumentChecklistItem doc : [
            SELECT Id, ParentRecordId, DocumentType.MasterLabel, CreatedDate
            FROM DocumentChecklistItem 
            WHERE ParentRecordId IN :applicationIds 
            ORDER BY CreatedDate ASC
        ]) {
            if (!documentsByApplication.containsKey(doc.ParentRecordId)) {
                documentsByApplication.put(doc.ParentRecordId, new List<DocumentChecklistItem>());
            }
            documentsByApplication.get(doc.ParentRecordId).add(doc);
        }
        return documentsByApplication;
    }

    public static List<Map<String, Object>> processDocuments(List<DocumentChecklistItem> docs, IndividualApplication app, String name) {
        List<Map<String, Object>> documents = new List<Map<String, Object>>();
        if (docs != null) {
            for (Integer i = 1; i < docs.size(); i++) {
                DocumentChecklistItem doc = docs[i];
                Map<String, Object> document = new Map<String, Object>{
                    'Id' => doc.Id,
                    'ApplicationID' => app.SAP_Sequence_Number__c,
                    'requestorName' => name,
                    'Expedited' => app.SAP_Expedited__c, 
                    'documentType' => doc.DocumentType.MasterLabel
                };
                documents.add(document);
            }
        }
        return documents;
    }

    private static String buildAddress(IndividualApplication app) {
        String address = '';
        if (app.SAP_Address_Line_1__c != null) address += app.SAP_Address_Line_1__c + ', ';
        if (app.SAP_Suite_Apartment_Floor__c != null) address += app.SAP_Suite_Apartment_Floor__c + ', ';
        if (app.SAP_City__c != null) address += app.SAP_City__c + ', ';
        if (app.SAP_State__c != null) address += app.SAP_State__c + ', ';
        if (app.SAP_Zip_Code__c != null) address += app.SAP_Zip_Code__c + ', ';
        if (app.SAP_Country__c != null) address += app.SAP_Country__c;
        address = address.trim();
        if (address.endsWith(',')) {
            address = address.substring(0, address.length() - 1);
        }
        return address;
    }

    private static String formatCustomDateTime(DateTime dt) {
        if (dt == null) return null;
        Date dateOnly = dt.dateGmt();
        String formattedMonth = (dateOnly.month() < 10) ? '0' + String.valueOf(dateOnly.month()) : String.valueOf(dateOnly.month());
        String formattedDay = (dateOnly.day() < 10) ? '0' + String.valueOf(dateOnly.day()) : String.valueOf(dateOnly.day());
        return formattedMonth + '/' + formattedDay + '/' + dateOnly.year();
}

    @AuraEnabled(cacheable=true)
    public static Integer getApplicationsCount(String status) {
        // Construct the base SOQL count query based on the status
        String countQuery = 'SELECT COUNT(Id) cnt FROM IndividualApplication WHERE Status = \'' + String.escapeSingleQuotes(status) + '\'';

        // Execute the count query and retrieve the count value
        List<AggregateResult> countResult = Database.query(countQuery);

        // Extract the count value from the AggregateResult
        Integer count = (countResult != null && !countResult.isEmpty()) ? (Integer) countResult[0].get('cnt') : 0;

        return count;
    }



    @AuraEnabled
public static Boolean updateApplicationStatusToDraft(String recordId) {
       try {
            // Query the individual application record based on the provided Id
            IndividualApplication app = [SELECT Id, Status FROM IndividualApplication WHERE Id = :recordId WITH SECURITY_ENFORCED LIMIT 1];
            System.debug('values are '+ app);
            // Update the status if it's 'Cancelled'
            if (app != null && app.Status == 'Cancelled By Customer') {
                app.Status = 'Draft';
                 System.debug('Updating status to Draft');
                Database.update(app); // Single DML operation
                  System.debug('Updated');
                  return true;
            }
                else{
                return false;
                }
            }
         catch (Exception e) {
            // Handle exception
                        System.debug('Error: ' + e.getMessage());
                        return false;
        }
}




}