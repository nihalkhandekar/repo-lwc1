@isTest
public with sharing class SAP_WorkOrderCheckProcessingTest {
    @testSetup
    static void setupTestData() {
        
        RegulatoryAuthorizationType licenseType = new RegulatoryAuthorizationType(Name = 'Test License');
        insert licenseType;
        
        
       
        IndividualApplication ia = new IndividualApplication(
            LicenseTypeId = licenseType.Id,
            RecordTypeId = Schema.SObjectType.IndividualApplication.getRecordTypeInfosByName().get('FinSys').getRecordTypeId(),
            SAP_First_Name__c = 'John',
            SAP_Last_Name__c = 'Doe',
            Category='License'
        );
        insert ia;
        
      
       RegulatoryTrxnFee fee = new RegulatoryTrxnFee(
           SAP_Payment_Type__c = 'Check',
           RecordTypeId = Schema.SObjectType.RegulatoryTrxnFee.getRecordTypeInfosByName().get('New Transaction').getRecordTypeId(),
           ParentRecordId = ia.Id,
           SAP_CK_Number__c = 12345,
           SAP_Transaction_Date__c = Date.today(),
           SAP_Reason_for_Returned_Check__c = 'Insufficient Funds',
           SAP_Deliquent__c = true,
           Status = 'DRAFT'
          
     );
     insert fee;
        
         DocumentChecklistItem dci = new DocumentChecklistItem(
            Name = 'Checklist Test Item',
            ParentRecordId = ia.Id,
            SAP_Country__c = 'USA',
            SAP_Fees__c = 100,
            SAP_SOTS_Certified_copy_number__c = '00001',
            SAP_Hague_Status__c = 'No',
            Status = 'Submitted'
        );
        insert dci;
        
         // Create a ContentVersion record so that a ContentDocument is generated.
        ContentVersion cv = new ContentVersion(
            Title = 'Test File',
            PathOnClient = 'TestFile.pdf',
            VersionData = Blob.valueOf('Test file data')
        );
        insert cv;
        cv = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
        
        
        // Insert a ContentDocumentLink linking the ContentDocument to our checklist item.
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = cv.ContentDocumentId,
            LinkedEntityId = dci.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert cdl;
       
        

    }

@isTest
static void testFetchSearchResultsUpdated() {
    


    // Prepare search criteria
    Map<String, Object> searchCriteria = new Map<String, Object>{
        //'workOrderNumber' => 'WO12345', 
       // 'check' => 12345.0, 
        'amount' => '100.00',
        'date' => String.valueOf(Date.today()),
        'pageSize' => 10,
        'currentPage' => 3,
        'startDate' => '2025-02-01', 
        'endDate' => '2025-02-18',   
        'sortedBy' => 'SAP_Transaction_Date__c', 
        'activity' => 'ACT001' ,
        //'firstName' => 'John', 
        'lastName' => 'Doe'
    };
    String searchCriteriaJSON = JSON.serialize(searchCriteria);

    Test.startTest();
    List<Map<String, Object>> results = SAP_WorkOrderCheckProcessing.fetchSearchResultsUpdated(searchCriteriaJSON);
    Test.stopTest();

}


  @isTest
static void testGetSearchResultsCountUpdated() {
    Map<String, Object> searchCriteria = new Map<String, Object>{
        //'workOrderNumber' => 'WO12345',
       // 'firstName' => 'John', 
        'lastName' => 'Doe', 
        //'check' => 12345.0,
        'amount' => '100.00',
        'date' => '2025-02-19',
        'pageSize' => 10,
        'currentPage' => 2,
        'startDate' => '2025-02-01',
        'endDate' => '2025-02-28',
        'sortedBy' => 'SAP_Transaction_Date__c',
        'activity' => 'ACT001'
    };
    
    String searchCriteriaJSON = JSON.serialize(searchCriteria);

    Test.startTest();
    Integer count = SAP_WorkOrderCheckProcessing.getSearchResultsCountUpdated(searchCriteriaJSON);
    Test.stopTest();

    
}

    @isTest
    static void testLogDropdownChange() {
        RegulatoryTrxnFee fee = [SELECT Id FROM RegulatoryTrxnFee LIMIT 1];
        
        Map<String, Object> logData = new Map<String, Object>{
            'transactionId' => fee.Id,
            'reasonReturnedCheck' => 'Fraudulent Check'
        };
        String logDataJSON = JSON.serialize(logData);
        
        Test.startTest();
        SAP_WorkOrderCheckProcessing.logDropdownChange(logDataJSON);
        Test.stopTest();
        
    }
    
    @isTest
static void testLogCheckboxChange() {
    Test.startTest();
    
    // Retrieve test data
    IndividualApplication testIA = [SELECT Id, LicenseTypeId, SAP_Sequence_Number__c, SAP_First_Name__c, SAP_Last_Name__c 
                                    FROM IndividualApplication 
                                    WHERE SAP_First_Name__c = 'John' LIMIT 1];

    RegulatoryTrxnFee testFee = [SELECT Id, SAP_Deliquent__c, SAP_Bounce_Date__c, SAP_Reason_for_Returned_Check__c, Status, TotalFeeAmount 
                                 FROM RegulatoryTrxnFee 
                                 WHERE ParentRecordId = :testIA.Id LIMIT 1];

    // Create a test Contact record linked to the IndividualApplication (assuming Contact is required)
    Contact testContact = new Contact(
        FirstName = testIA.SAP_First_Name__c,
        LastName = testIA.SAP_Last_Name__c,
        RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('FinSys Customers').getRecordTypeId(),
        SAP_Customer_Account_Balance__c = 500.00,
        SAP_Deliquent__c = false
    );
    insert testContact;

    // Associate IndividualApplication with Contact
    testIA.Contact__c = testContact.Id;
    update testIA;

    // Prepare JSON data for marking delinquent
    Map<String, Object> loggingData = new Map<String, Object>{
        'contactId' => testContact.Id,
        'transactionId' => testFee.Id,
        'paymentAmount' => '100.00',
        'delinquent' => true,
        'currenrDStatus' => false
    };
    String loggingDataJSON = JSON.serialize(loggingData);

   
    SAP_WorkOrderCheckProcessing.logCheckboxChange(loggingDataJSON);

   
    // Prepare JSON data for unmarking delinquent
    loggingData.put('delinquent', false);
    loggingDataJSON = JSON.serialize(loggingData);

    // Call the method to unmark as delinquent
    SAP_WorkOrderCheckProcessing.logCheckboxChange(loggingDataJSON);

   
    Test.stopTest();
}
    
    @isTest
static void testDeleteFile() {
    // Fetch test data
    IndividualApplication ia = [SELECT Id FROM IndividualApplication WHERE SAP_First_Name__c = 'John' LIMIT 1];
    RegulatoryTrxnFee fee = [SELECT Id FROM RegulatoryTrxnFee WHERE ParentRecordId = :ia.Id LIMIT 1];

    // Prepare test file data
    ContentVersion contentVersion = new ContentVersion(
        Title = 'TestDocument.pdf',
        PathOnClient = 'TestDocument.pdf',
        VersionData = Blob.valueOf('Test file content')
    );
    insert contentVersion;

    ContentDocument contentDoc = [SELECT Id FROM ContentDocument WHERE Id IN (SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id) LIMIT 1];

    // Link file to transaction
    ContentDocumentLink cdl = new ContentDocumentLink(
        LinkedEntityId = fee.Id,
        ContentDocumentId = contentDoc.Id,
        ShareType = 'V',
        Visibility = 'AllUsers'
    );
    insert cdl;

    Test.startTest();
    String response = SAP_WorkOrderCheckProcessing.deleteFile(contentDoc.Id, fee.Id);
    Test.stopTest();

}
    
    @isTest
static void testUploadFile() {
    // Fetch the test RegulatoryTrxnFee record
    RegulatoryTrxnFee fee = [SELECT Id FROM RegulatoryTrxnFee LIMIT 1];

    // Prepare test JSON data
    Map<String, Object> loggingData = new Map<String, Object>{
        'workOrderId' => fee.Id
    };
    String loggingDataJSON = JSON.serialize(loggingData);

    // Create test file data
    String fileName = 'TestDocument.pdf';
    String fileBody = EncodingUtil.base64Encode(Blob.valueOf('Test file content'));

    Test.startTest();
    String response = SAP_WorkOrderCheckProcessing.uploadFile(loggingDataJSON, fileBody, fileName);
    Test.stopTest();

}



}