/* DESCRIPTION: This class handles Apostille Letter-related operations.
 * It fetches, processes, and returns certificate data associated with Individual Applications,
 * ensuring data is structured correctly for UI presentation.
 **********************************************************************************************/
public with sharing class SAP_ApostilleLetterController {
  public static final String className = 'SAP_ApostilleLetterController';
  public static final String severity = 'High';

  /**
   * Retrieves a paginated and sorted list of certificates associated with Individual Applications.
   * @param offsetVal Starting index, @param pageSize Number of records,
   * @param sortBy Field to sort by, @param sortDirection Sorting order.
   * @return A list of maps containing certificate details.
   */
  @AuraEnabled(cacheable=true)
  public static List<Map<String, Object>> getAllCertificates(
    Integer offsetVal,
    Integer pageSize,
    String sortBy,
    String sortDirection
  ) {
    try {
      List<DocumentChecklistItem> checklistItems = [
        SELECT
          Id,
          ParentRecordId,
          SAP_Certificate_Number__c,
          DocumentType.MasterLabel,
          Status,
          SAP_ApprovedDate__c
        FROM DocumentChecklistItem
        WHERE SAP_Certificate_Number__c != NULL
      ];

      Set<Id> parentRecordIds = new Set<Id>();
      for (DocumentChecklistItem item : checklistItems) {
        parentRecordIds.add(item.ParentRecordId);
      }

      if (parentRecordIds.isEmpty()) {
        return new List<Map<String, Object>>();
      }

      String query =
        'SELECT Id, SAP_Sequence_Number__c, SAP_Organization_Name__c, SAP_First_Name__c, SAP_Last_Name__c, AppliedDate, Status ' +
        'FROM IndividualApplication ' +
        'WHERE Id IN :parentRecordIds ' +
        'AND RecordType.Name = \'Apostille\' ' +
        'AND Status != \'Draft\' AND Status NOT IN (\'Draft\', \'Submitted\', \'Payment Captured\', \'Payment Pending\')';

      if (sortBy != null) {
        if (sortBy == 'ApplicationID')
          sortBy = 'SAP_Sequence_Number__c';
        if (sortBy == 'requestorName')
          sortBy = 'SAP_Organization_Name__c';
        if (sortBy == 'AppliedDate')
          sortBy = 'AppliedDate';
        if (sortBy == 'Status')
          sortBy = 'Status';

        query += 'ORDER BY ' + sortBy + ' ' + sortDirection + ' ';
      }

      query += 'LIMIT ' + pageSize + ' OFFSET ' + offsetVal;
      List<IndividualApplication> applications = Database.query(query);
      return processApplicationResults(applications);
    } catch (Exception e) {
      BOS_Utility.ExceptionHandler(
        className,
        'getAllCertificates',
        'IndividualApplication',
        null,
        severity,
        e,
        null
      );
      throw new AuraHandledException(
        'Error fetching data. Please try again later.'
      );
    }
  }

  /**
   * Maps IndividualApplication records with associated DocumentChecklistItem data.
   * @param applications List of IndividualApplication records.
   * @return Processed application details as a list of maps.
   */
  private static List<Map<String, Object>> processApplicationResults(
    List<IndividualApplication> applications
  ) {
    List<Map<String, Object>> result = new List<Map<String, Object>>();

    Set<Id> applicationIds = new Set<Id>();
    for (IndividualApplication app : applications) {
      applicationIds.add(app.Id);
    }

    Map<Id, List<DocumentChecklistItem>> documentsByApplication = new Map<Id, List<DocumentChecklistItem>>();
    for (DocumentChecklistItem doc : [
      SELECT
        Id,
        ParentRecordId,
        SAP_Certificate_Number__c,
        Status,
        DocumentType.MasterLabel,
        SAP_ApprovedDate__c
      FROM DocumentChecklistItem
      WHERE ParentRecordId IN :applicationIds
      ORDER BY CreatedDate ASC
    ]) {
      if (!documentsByApplication.containsKey(doc.ParentRecordId)) {
        documentsByApplication.put(
          doc.ParentRecordId,
          new List<DocumentChecklistItem>()
        );
      }
      documentsByApplication.get(doc.ParentRecordId).add(doc);
    }

    for (IndividualApplication app : applications) {
      Map<String, Object> record = new Map<String, Object>();

      List<DocumentChecklistItem> docs = documentsByApplication.get(app.Id);
      DocumentChecklistItem firstDoc = docs != null && !docs.isEmpty()
        ? docs[0]
        : null;

      String nameFirst = app.SAP_First_Name__c != null
        ? app.SAP_First_Name__c
        : '';
      String nameLast = app.SAP_Last_Name__c != null
        ? app.SAP_Last_Name__c
        : '';
      String name = String.isNotBlank(app.SAP_Organization_Name__c)
        ? app.SAP_Organization_Name__c
        : (nameFirst + ' ' + nameLast).trim();

      record.put('Id', app.Id);
      record.put('ApplicationID', app.SAP_Sequence_Number__c);
      record.put('requestorName', name);
      record.put('AppliedDate', formatCustomDateTime(app.AppliedDate));

      if (firstDoc != null) {
        record.put('Certificate', firstDoc.SAP_Certificate_Number__c);
        record.put('documentType', firstDoc.DocumentType.MasterLabel);
        record.put(
          'ApproveDate',
          formatCustomDateTime(firstDoc.SAP_ApprovedDate__c)
        );
      } else {
        record.put('Certificate', '');
        record.put('documentType', '');
        record.put('ApproveDate', '');
      }

      String unexpandedStatus =
        app.Status + (firstDoc != null ? ' / ' + firstDoc.Status : '');
      record.put('unexpandedStatus', unexpandedStatus);

      String expandedStatus =
        (firstDoc != null ? firstDoc.Status + ' / ' : '') + app.Status;
      record.put('expandedStatus', expandedStatus);

      List<Map<String, Object>> documents = new List<Map<String, Object>>();
      if (docs != null) {
        for (Integer i = 1; i < docs.size(); i++) {
          DocumentChecklistItem doc = docs[i];
          Map<String, Object> document = new Map<String, Object>();

          document.put('Id', doc.Id);
          document.put('ApplicationID', app.SAP_Sequence_Number__c);
          document.put('requestorName', name);
          document.put('AppliedDate', formatCustomDateTime(app.AppliedDate));
          document.put('Certificate', doc.SAP_Certificate_Number__c);
          document.put('documentType', doc.DocumentType.MasterLabel);
          document.put(
            'ApproveDate',
            formatCustomDateTime(doc.SAP_ApprovedDate__c)
          );
          document.put('Status', doc.Status);

          documents.add(document);
        }
      }

      record.put('docCount', documents.size());
      record.put('hasDocuments', !documents.isEmpty());
      record.put('documents', documents);

      result.add(record);
    }

    return result;
  }

  /**
   * Converts a DateTime object to MM/DD/YYYY format.
   * @param dt The DateTime to format.
   * @return Formatted date string or null if input is null.
   */
  private static String formatCustomDateTime(DateTime dt) {
    if (dt == null)
      return null;
    Date dateOnly = dt.dateGmt();
    String formattedMonth = (dateOnly.month() < 10)
      ? '0' + String.valueOf(dateOnly.month())
      : String.valueOf(dateOnly.month());
    String formattedDay = (dateOnly.day() < 10)
      ? '0' + String.valueOf(dateOnly.day())
      : String.valueOf(dateOnly.day());
    return formattedMonth + '/' + formattedDay + '/' + dateOnly.year();
  }

  /**
   * Gets the total count of applications linked to certificates.
   * @return Total number of applications having associated certificates.
   */
  @AuraEnabled(cacheable=true)
  public static Integer getTotalApplicationsWithCertificates() {
    try {
      List<AggregateResult> certificateResults = [
        SELECT ParentRecordId
        FROM DocumentChecklistItem
        WHERE SAP_Certificate_Number__c != NULL
        GROUP BY ParentRecordId
      ];

      Set<Id> parentRecordIds = new Set<Id>();
      for (AggregateResult result : certificateResults) {
        parentRecordIds.add((Id) result.get('ParentRecordId'));
      }

      if (!parentRecordIds.isEmpty()) {
        Integer totalCount = [
          SELECT COUNT()
          FROM IndividualApplication
          WHERE
            Id IN :parentRecordIds
            AND RecordType.Name = 'Apostille'
            AND Status != 'Draft'
        ];

        return totalCount;
      } else {
        return 0;
      }
    } catch (Exception e) {
      BOS_Utility.ExceptionHandler(
        className,
        'getTotalApplicationsWithCertificates',
        'DocumentChecklistItem',
        null,
        severity,
        e,
        null
      );
      throw new AuraHandledException(
        'Error fetching total applications with certificates.'
      );
    }
  }

  /**
   * Retrieves the Base64 encoded string of a specified static resource image.
   * @param imageName Name of the static resource image.
   * @return Base64 encoded image string, or null if retrieval fails.
   */
  @AuraEnabled(cacheable=true)
  public static String getBase64Image(String imageName) {
    try {
      StaticResource resource = [
        SELECT Body
        FROM StaticResource
        WHERE Name = :imageName
        LIMIT 1
      ];
      Blob imageBlob = resource.Body;
      return EncodingUtil.base64Encode(imageBlob);
    } catch (Exception e) {
      BOS_Utility.ExceptionHandler(
        className,
        'getBase64Image',
        'StaticResource',
        null,
        severity,
        e,
        null
      );
      return null;
    }
  }

  /**
   * Retrieves payment details for a given record ID.
   * @param itemId Parent record ID.
   * @return List of RegulatoryTrxnFee records.
   * @throws AuraHandledException If an error occurs.
   */
  @AuraEnabled(cacheable=true)
  public static List<RegulatoryTrxnFee> getPaymentDetails(Id itemId) {
    try {
      return [
        SELECT Id, TotalFeeAmount, SAP_Partial_Refund__c, SAP_Payment_Method__c
        FROM RegulatoryTrxnFee
        WHERE ParentRecordId = :itemId
      ];
    } catch (Exception e) {
      BOS_Utility.ExceptionHandler(
        className,
        'getPaymentDetails',
        'RegulatoryTrxnFee',
        null,
        severity,
        e,
        null
      );
      throw new AuraHandledException(
        'Error fetching payment details: ' + e.getMessage()
      );
    }
  }

  /**
   * Retrieves document checklist items based on provided filters.
   * @param recordId Parent record ID, @param documentTypeLabel Document type label,
   * @param certificateNo Certificate number.
   * @return List of DocumentChecklistItem records.
   * @throws AuraHandledException If validation fails or an error occurs.
   */
  @AuraEnabled
  public static List<DocumentChecklistItem> getDocumentChecklistItems(
    String recordId,
    String documentTypeLabel,
    String certificateNo
  ) {
    if (
      String.isEmpty(recordId) &&
      String.isEmpty(documentTypeLabel) &&
      String.isEmpty(certificateNo)
    ) {
      throw new AuraHandledException(
        'Record ID and Document Type Label must not be empty.'
      );
    }

    try {
      List<DocumentChecklistItem> checklistItems = [
        SELECT
          Id,
          ParentRecordId,
          Status,
          SAP_Requester_Name__c,
          SAP_country__c,
          SAP_Hague_Status__c,
          Signed_By__r.Name,
          Signed_By__r.SAP_Seal_Stramp_of__c,
          Signed_By__r.SAP_Position__c,
          Signing_Authority__r.Name,
          Signing_Authority__r.SAP_Staff_Title__c,
          CreatedDate,
          ParentRecord.Name,
          SAP_Rejection_Reason__c,
          SAP_Notes__c,
          SAP_Certificate_Number__c,
          DocumentType.MasterLabel,
          SAP_ApprovedDate__c
        FROM DocumentChecklistItem
        WHERE
          ParentRecordId = :recordId
          AND DocumentType.MasterLabel = :documentTypeLabel
          AND SAP_Certificate_Number__c = :certificateNo
      ];

      return checklistItems;
    } catch (Exception e) {
      BOS_Utility.ExceptionHandler(
        className,
        'getDocumentChecklistItems',
        'DocumentChecklistItem',
        null,
        severity,
        e,
        null
      );
      throw new AuraHandledException(
        'Failed to retrieve document checklist items: ' + e.getMessage()
      );
    }
  }

  /**
   * Fetches a document checklist item by its ID.
   * @param docId Document checklist item ID.
   * @return List of DocumentChecklistItem records.
   */
  @AuraEnabled
  public static List<DocumentChecklistItem> getDocumentChecklistItem(
    String docId
  ) {
    try {
      List<DocumentChecklistItem> checklistItems = [
        SELECT
          Id,
          ParentRecordId,
          Status,
          SAP_Requester_Name__c,
          SAP_country__c,
          SAP_Hague_Status__c,
          Signed_By__r.Name,
          Signed_By__r.SAP_Position__c,
          Signed_By__r.SAP_Seal_Stramp_of__c,
          Signing_Authority__r.Name,
          Signing_Authority__r.SAP_Staff_Title__c,
          CreatedDate,
          ParentRecord.Name,
          SAP_Rejection_Reason__c,
          SAP_Notes__c,
          SAP_Certificate_Number__c,
          DocumentType.MasterLabel,
          SAP_ApprovedDate__c
        FROM DocumentChecklistItem
        WHERE SAP_Certificate_Number__c != NULL AND ID = :docId
      ];
      if (checklistItems.isEmpty()) {
        throw new AuraHandledException(
          'Record ID and Document Type Label must not be empty.'
        );
      }

      return checklistItems;
    } catch (Exception e) {
      BOS_Utility.ExceptionHandler(
        className,
        'getDocumentChecklistItems',
        'DocumentChecklistItem',
        null,
        severity,
        e,
        null
      );
      throw new AuraHandledException(
        'Failed to retrieve document checklist items: ' + e.getMessage()
      );
    }
  }

  /**
   * Fetches detailed document checklist item data for a given record.
   * @param itemId Parent record ID.
   * @return Map containing document details and related application data.
   */
  @AuraEnabled(cacheable=true)
  public static Map<String, Object> getDocumentChecklistItemDetails(Id itemId) {
    List<DocumentChecklistItem> item = [
      SELECT
        Id,
        ParentRecordId,
        Status,
        SAP_Requester_Name__c,
        SAP_country__c,
        SAP_Hague_Status__c,
        CreatedDate,
        ParentRecord.Name,
        SAP_Rejection_Reason__c,
        SAP_RejectionReason__c,
        SAP_Notes__c,
        SAP_Certificate_Number__c,
        DocumentType.MasterLabel,
        SAP_ApprovedDate__c
      FROM DocumentChecklistItem
      WHERE ParentRecordId = :itemId
    ];

    IndividualApplication app = [
      SELECT
        Id,
        Name,
        AppliedDate,
        SAP_Sequence_Number__c,
        SAP_Address_Line_1__c,
        SAP_City__c,
        SAP_State__c,
        SAP_Zip_Code__c,
        SAP_First_Name__c,
        SAP_Last_Name__c,
        SAP_Organization_Name__c,
        Status
      FROM IndividualApplication
      WHERE id = :itemId
    ];

    Map<String, Object> result = new Map<String, Object>();

    List<Map<String, Object>> documentDataList = new List<Map<String, Object>>();
    for (DocumentChecklistItem item1 : item) {
      Map<String, Object> dataMap = new Map<String, Object>();
      dataMap.put('Id', item1.Id);
      dataMap.put('status', item1.Status);
      dataMap.put(
        'name',
        item1.SAP_Requester_Name__c != null ? item1.SAP_Requester_Name__c : ''
      );
      dataMap.put(
        'country',
        item1.SAP_country__c != null ? item1.SAP_country__c : ''
      );
      dataMap.put(
        'hagueStatus',
        item1.SAP_Hague_Status__c != null ? item1.SAP_Hague_Status__c : ''
      );
      dataMap.put('customRejectionReason', item1.SAP_Rejection_Reason__c);
      dataMap.put('RejectionReason', item1.SAP_RejectionReason__c);
      dataMap.put('Notes', item1.SAP_Notes__c);
      dataMap.put('documentType', item1.DocumentType.MasterLabel);
      dataMap.put('certificateNumber', item1.SAP_Certificate_Number__c);
      dataMap.put(
        'approveDate',
        formatCustomDateTime(item1.SAP_ApprovedDate__c)
      );

      documentDataList.add(dataMap);
    }

    Map<String, Object> individualAppData = new Map<String, Object>();
    String firstName = app.SAP_First_Name__c != null
      ? app.SAP_First_Name__c
      : '';
    String lastName = app.SAP_Last_Name__c != null ? app.SAP_Last_Name__c : '';
    String name = firstName + ' ' + lastName;

    if (app.SAP_Organization_Name__c != null)
      name = app.SAP_Organization_Name__c;

    individualAppData.put('AppliedDate', formatCustomDateTime(app.AppliedDate));
    individualAppData.put('SequenceNumber', app.SAP_Sequence_Number__c);
    individualAppData.put('AddressLine', app.SAP_Address_Line_1__c);
    individualAppData.put('City', app.SAP_City__c);
    individualAppData.put('State', app.SAP_State__c);
    individualAppData.put('ZipCode', app.SAP_Zip_Code__c);
    individualAppData.put('name', name);
    individualAppData.put('individualApplicationStatus', app.Status);

    result.put('document', documentDataList);
    result.put('individualAppData', individualAppData);

    return result;
  }

  /**
   * Retrieves the count of letters with approved, accepted, or rejected status.
   * @return Total count of matching DocumentChecklistItem records.
   */
  @AuraEnabled(cacheable=true)
  public static Integer getLetterCount() {
    String countQuery =
      'SELECT COUNT(Id) cnt FROM DocumentChecklistItem WHERE (Status = \'Approved\' OR Status = \'Accepted\' OR Status = \'Rejected\')' +
      'AND ParentRecordId IN (SELECT Id FROM IndividualApplication WHERE Status LIKE \'%Order Completed%\')';

    List<AggregateResult> countResult = Database.query(
      countQuery,
      AccessLevel.USER_MODE
    );

    Integer letterCount = (countResult != null && !countResult.isEmpty())
      ? (Integer) countResult[0].get('cnt')
      : 0;

    return letterCount;
  }
}