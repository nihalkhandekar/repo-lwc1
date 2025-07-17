public with sharing class ApostilleLetterController {
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getAllCertificates(Integer offsetVal, Integer pageSize, String sortBy, String sortDirection) {
        System.debug('offsetVal: ' + offsetVal);
        System.debug('pageSize: ' + pageSize);
        System.debug('sortBy: ' + sortBy);
        System.debug('sortDirection: ' + sortDirection);

        try {
            List<DocumentChecklistItem> checklistItems = [
                SELECT Id, ParentRecordId, Certificate_Number__c, DocumentType.MasterLabel, Status, ApprovedDate__c
                FROM DocumentChecklistItem
                WHERE Certificate_Number__c != null WITH SECURITY_ENFORCED
            ];

            System.debug('Checklist Items: ' + checklistItems);

            Set<Id> parentRecordIds = new Set<Id>();
            for (DocumentChecklistItem item : checklistItems) {
                parentRecordIds.add(item.ParentRecordId);
            }

            if (parentRecordIds.isEmpty()) {
                return new List<Map<String, Object>>(); // Return empty result if no certificates are found
            }

            String query = 'SELECT Id, Sequence_Number__c, Organization_Name__c, First_Name__c, Last_Name__c, AppliedDate, Status ' +
                        'FROM IndividualApplication ' +
                        'WHERE Id IN :parentRecordIds ' +
                        'AND RecordType.Name = \'Apostille\' ' +
                        'AND Status != \'Draft\' AND Status != \'Submitted\'';

            // Add sorting logic
            if (sortBy != null) {
                if (sortBy == 'ApplicationID') sortBy = 'Sequence_Number__c';
                if (sortBy == 'requestorName') sortBy = 'Organization_Name__c';
                if (sortBy == 'AppliedDate') sortBy = 'AppliedDate';
                if (sortBy == 'Status') sortBy = 'Status';

                query += 'ORDER BY ' + sortBy + ' ' + sortDirection + ' ';
            }

            query += 'LIMIT ' + pageSize + ' OFFSET ' + offsetVal;
            System.debug('Final Query: ' + query);
            List<IndividualApplication> applications = Database.query(query);
            return processApplicationResults(applications);
        } catch (Exception e) {
            // Log the exception and throw an AuraHandledException
            System.debug('Error: ' + e.getMessage());
            throw new AuraHandledException('Error fetching data. Please try again later.');
        }
    }

    private static List<Map<String, Object>> processApplicationResults(List<IndividualApplication> applications) {
        List<Map<String, Object>> result = new List<Map<String, Object>>();

        // Get all application IDs
        Set<Id> applicationIds = new Set<Id>();
        for (IndividualApplication app : applications) {
            applicationIds.add(app.Id);
        }

        // Query only relevant fields from DocumentChecklistItem
        Map<Id, List<DocumentChecklistItem>> documentsByApplication = new Map<Id, List<DocumentChecklistItem>>();
        for (DocumentChecklistItem doc : [
            SELECT Id, ParentRecordId, Certificate_Number__c,Status, DocumentType.MasterLabel, ApprovedDate__c
            FROM DocumentChecklistItem
            WHERE ParentRecordId IN :applicationIds WITH SECURITY_ENFORCED
            ORDER BY CreatedDate ASC
        ]) {
            if (!documentsByApplication.containsKey(doc.ParentRecordId)) {
                documentsByApplication.put(doc.ParentRecordId, new List<DocumentChecklistItem>());
            }
            documentsByApplication.get(doc.ParentRecordId).add(doc);
        }

        for (IndividualApplication app : applications) {
            Map<String, Object> record = new Map<String, Object>();

            List<DocumentChecklistItem> docs = documentsByApplication.get(app.Id);
            DocumentChecklistItem firstDoc = docs != null && !docs.isEmpty() ? docs[0] : null;

            String nameFirst = app.First_Name__c != null ? app.First_Name__c : '';
            String nameLast = app.Last_Name__c != null ? app.Last_Name__c : '';
            String name = String.isNotBlank(app.Organization_Name__c) ?
                         app.Organization_Name__c : (nameFirst + ' ' + nameLast).trim();

            record.put('Id', app.Id);
            record.put('ApplicationID', app.Sequence_Number__c);
            record.put('requestorName', name);
            record.put('AppliedDate', formatCustomDateTime(app.AppliedDate));

            // Set certificate-related fields from first document
            if (firstDoc != null) {
                record.put('Certificate', firstDoc.Certificate_Number__c);
                record.put('documentType', firstDoc.DocumentType.MasterLabel);
                record.put('ApproveDate', formatCustomDateTime(firstDoc.ApprovedDate__c));
            } else {
                record.put('Certificate', '');
                record.put('documentType', '');
                record.put('ApproveDate', '');
            }

            String unexpandedStatus = app.Status + (firstDoc != null ? ' / ' + firstDoc.Status : '');
            record.put('unexpandedStatus', unexpandedStatus);

            // Expanded main record status
            String expandedStatus = (firstDoc != null ? firstDoc.Status + ' / ' : '') + app.Status;
            record.put('expandedStatus', expandedStatus);

            // Process remaining documents for expanded view
            List<Map<String, Object>> documents = new List<Map<String, Object>>();
            if (docs != null) {
                for (Integer i = 1; i < docs.size(); i++) {
                    DocumentChecklistItem doc = docs[i];
                    Map<String, Object> document = new Map<String, Object>();

                    document.put('Id', doc.Id);
                    document.put('ApplicationID', app.Sequence_Number__c);
                    document.put('requestorName', name);
                    document.put('AppliedDate', formatCustomDateTime(app.AppliedDate));
                    document.put('Certificate', doc.Certificate_Number__c);
                    document.put('documentType', doc.DocumentType.MasterLabel);
                    document.put('ApproveDate', formatCustomDateTime(doc.ApprovedDate__c));
                    document.put('Status', doc.Status);

                    documents.add(document);
                }
            }

            // Add document metadata
            record.put('docCount', documents.size());
            record.put('hasDocuments', !documents.isEmpty());
            record.put('documents', documents);

            result.add(record);
        }

        return result;
    }

    private static String formatCustomDateTime(DateTime dt) {
            if (dt == null) return null;
            Date dateOnly = dt.dateGmt();
            String formattedMonth = (dateOnly.month() < 10) ? '0' + String.valueOf(dateOnly.month()) : String.valueOf(dateOnly.month());
            String formattedDay = (dateOnly.day() < 10) ? '0' + String.valueOf(dateOnly.day()) : String.valueOf(dateOnly.day());
            return formattedMonth + '/' + formattedDay + '/' + dateOnly.year();
        }



    @AuraEnabled(cacheable=true)
public static Integer getTotalApplicationsWithCertificates() {
    try {
        // Step 1: Find all ParentRecordId from DocumentChecklistItem where Certificate_Number__c is not null
        List<AggregateResult> certificateResults = [
            SELECT ParentRecordId
            FROM DocumentChecklistItem
            WHERE Certificate_Number__c != null WITH SECURITY_ENFORCED
            GROUP BY ParentRecordId
        ];

        // Step 2: Extract all distinct ParentRecordIds (these are IndividualApplication Ids)
        Set<Id> parentRecordIds = new Set<Id>();
        for (AggregateResult result : certificateResults) {
            parentRecordIds.add((Id) result.get('ParentRecordId'));
        }

        // Step 3: Find total number of IndividualApplication records with the extracted ParentRecordIds
        if (!parentRecordIds.isEmpty()) {
            Integer totalCount = [
                SELECT COUNT()
                FROM IndividualApplication
                WHERE Id IN :parentRecordIds
                AND RecordType.Name = 'Apostille'
                AND Status != 'Draft' WITH SECURITY_ENFORCED
            ];

            // Debug log the total count
            System.debug('Total Applications with Certificates: ' + totalCount);
            return totalCount;
        } else {
            // No certificates found
            return 0;
        }

    } catch (Exception e) {
        // Log any errors and throw an AuraHandledException
        System.debug('Error: ' + e.getMessage());
        throw new AuraHandledException('Error fetching total applications with certificates.');
    }
}

    @AuraEnabled(cacheable=true)
    public static String getBase64Image(String imageName) {
        try {
            StaticResource resource = [SELECT Body FROM StaticResource WHERE Name = :imageName WITH SECURITY_ENFORCED LIMIT 1];
            Blob imageBlob = resource.Body;
            return EncodingUtil.base64Encode(imageBlob);
        } catch (Exception e) {
            System.debug('Error fetching base64 image: ' + e.getMessage());
            return null;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<RegulatoryTrxnFee> getPaymentDetails(Id itemId) {
        try {
            return [
                SELECT Id, TotalFeeAmount, Partial_Refund__c, Payment_Method__c
                FROM RegulatoryTrxnFee
                WHERE ParentRecordId = :itemId WITH SECURITY_ENFORCED
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching payment details: ' + e.getMessage());
        }
    }

    @AuraEnabled
public static List<DocumentChecklistItem> getDocumentChecklistItems(String recordId, String documentTypeLabel, String certificateNo) {
    // Validate input parameters
    if (String.isEmpty(recordId) && String.isEmpty(documentTypeLabel) && String.isEmpty(certificateNo)) {
        throw new AuraHandledException('Record ID and Document Type Label must not be empty.');
    }

    try {
        // Query the DocumentChecklistItem with specified filters
        List<DocumentChecklistItem> checklistItems = [
            SELECT Id, ParentRecordId, Status, Requester_Name__c, country__c, Hague_Status__c, Signed_By__r.Name, Signed_By__r.Seal_Stramp_of__c, Signed_By__r.Position__c,
                   Signing_Authority__r.Name, Signing_Authority__r.Staff_Title__c,
                   CreatedDate, ParentRecord.Name, Rejection_Reason__c, Notes__c,
                   Certificate_Number__c, DocumentType.MasterLabel, ApprovedDate__c
            FROM DocumentChecklistItem
            WHERE ParentRecordId = :recordId
              AND DocumentType.MasterLabel = :documentTypeLabel
            AND Certificate_Number__c = :certificateNo 
        ];

        // Debug statement to print the query result
        System.debug('Queried DocumentChecklistItems: ' + checklistItems);

        return checklistItems;

    } catch (Exception e) {
        // Log and throw the exception as an AuraHandledException
        System.debug('Error in getDocumentChecklistItems: ' + e.getMessage());
        throw new AuraHandledException('Failed to retrieve document checklist items: ' + e.getMessage());
    }
}


@AuraEnabled
public static List<DocumentChecklistItem> getDocumentChecklistItem(String docId) {

    try {
        // Query the DocumentChecklistItem with specified filters
        List<DocumentChecklistItem> checklistItems = [
            SELECT Id, ParentRecordId, Status, Requester_Name__c, country__c, Hague_Status__c, Signed_By__r.Name, Signed_By__r.Position__c, Signed_By__r.Seal_Stramp_of__c,
                   Signing_Authority__r.Name, Signing_Authority__r.Staff_Title__c,
                   CreatedDate, ParentRecord.Name, Rejection_Reason__c, Notes__c,
                   Certificate_Number__c, DocumentType.MasterLabel, ApprovedDate__c
            FROM DocumentChecklistItem
            WHERE Certificate_Number__c != null
            AND ID=:docId
        ];
        if(checklistItems.isEmpty()){
            throw new AuraHandledException('Record ID and Document Type Label must not be empty.');
        }
        // Debug statement to print the query result
        System.debug('Queried DocumentChecklistItems: ' + checklistItems);

        return checklistItems;

    } catch (Exception e) {
        // Log and throw the exception as an AuraHandledException
        System.debug('Error in getDocumentChecklistItems: ' + e.getMessage());
        throw new AuraHandledException('Failed to retrieve document checklist items: ' + e.getMessage());
    }
}



    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getDocumentChecklistItemDetails(Id itemId) {
        // Query DocumentChecklistItem where ParentRecordId is an IndividualApplication
        List<DocumentChecklistItem> item = [
            SELECT Id, ParentRecordId, Status, Requester_Name__c, country__c, Hague_Status__c, CreatedDate,
                   ParentRecord.Name, Rejection_Reason__c, RejectionReason__c, Notes__c, Certificate_Number__c, DocumentType.MasterLabel, ApprovedDate__c
            FROM DocumentChecklistItem
            WHERE ParentRecordId = :itemId
        ];

        IndividualApplication app = [SELECT Id, Name, AppliedDate, Sequence_Number__c, Address_Line_1__c, City__c,State__c, Zip_Code__c,
                                    First_Name__c,Last_Name__c,Organization_Name__c, Status
                                    FROM IndividualApplication
                                    WHERE id =:itemId WITH SECURITY_ENFORCED];

        Map<String, Object> result = new Map<String, Object>();

        List<Map<String, Object>> documentDataList = new List<Map<String, Object>>();
        for (DocumentChecklistItem item1 : item) {
            // Prepare data map to return
            Map<String, Object> dataMap = new Map<String, Object>();
            dataMap.put('Id', item1.Id);
            dataMap.put('status', item1.Status);
            dataMap.put('name', item1.Requester_Name__c !=null ? item1.Requester_Name__c : '');
            dataMap.put('country', item1.country__c !=null ? item1.country__c :'');
            dataMap.put('hagueStatus', item1.Hague_Status__c !=null ? item1.Hague_Status__c : '');
            dataMap.put('customRejectionReason', item1.Rejection_Reason__c);
            dataMap.put('RejectionReason', item1.RejectionReason__c);
            dataMap.put('Notes', item1.Notes__c);
            dataMap.put('documentType', item1.DocumentType.MasterLabel);
            dataMap.put('certificateNumber', item1.Certificate_Number__c);
            dataMap.put('approveDate', formatCustomDateTime(item1.ApprovedDate__c));

            documentDataList.add(dataMap);
        }

        Map<String, Object> individualAppData = new Map<String, Object>();
        String firstName = app.First_Name__c != null ? app.First_Name__c : '';
        String lastName = app.Last_Name__c !=null ? app.Last_Name__c :'';
        String name = firstName + ' ' + lastName;

        if(app.Organization_Name__c != null)
            name = app.Organization_Name__c;

        individualAppData.put('AppliedDate', formatCustomDateTime(app.AppliedDate));
        individualAppData.put('SequenceNumber', app.Sequence_Number__c);
        individualAppData.put('AddressLine', app.Address_Line_1__c);
        individualAppData.put('City', app.City__c);
        individualAppData.put('State', app.State__c);
        individualAppData.put('ZipCode', app.Zip_Code__c);
        individualAppData.put('name', name);
        individualAppData.put('individualApplicationStatus', app.Status);

        result.put('document', documentDataList);
        result.put('individualAppData', individualAppData);

        return result;
    }

    @AuraEnabled(cacheable=true)
public static Integer getLetterCount() {
    // Construct the base SOQL count query
    String countQuery = 'SELECT COUNT(Id) cnt FROM DocumentChecklistItem WHERE (Status = \'Approved\' OR Status = \'Accepted\' OR Status = \'Rejected\')' +
                        'AND ParentRecordId IN (SELECT Id FROM IndividualApplication WHERE Status LIKE \'%Order Completed%\')';

    // Execute the count query and retrieve the count value
    List<AggregateResult> countResult = Database.query(countQuery , AccessLevel.USER_MODE);

    // Extract the count value from the AggregateResult
    Integer letterCount = (countResult != null && !countResult.isEmpty()) ? (Integer) countResult[0].get('cnt') : 0;

    return letterCount;
}



}