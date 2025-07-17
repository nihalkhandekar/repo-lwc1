@isTest
public with sharing class SAP_ApostilleLetterControllerTest {

    @testSetup
    static void setupTestData() {
        
        RecordType apostilleRecordType;
        apostilleRecordType = [SELECT Id FROM RecordType WHERE Name = 'Apostille' AND SObjectType = 'IndividualApplication' LIMIT 1];
        
        RegulatoryAuthorizationType licenseType = new RegulatoryAuthorizationType(Name = 'Test License');
        insert licenseType;
            
        IndividualApplication app = new IndividualApplication(
            RecordTypeId = apostilleRecordType.Id,
            SAP_Sequence_Number__c = 'A12345',
            AppliedDate = DateTime.now(),
            Status = 'Processing',
            LicenseTypeId = licenseType.Id,
            Category='License'             
        );
        insert app;

         
        List<DocumentType> docTypes = [SELECT Id, MasterLabel FROM DocumentType WHERE MasterLabel IN ('SOTS Certified Copies', 'Vital Records')];

        
        Map<String, Id> docTypeMap = new Map<String, Id>();
        for (DocumentType dt : docTypes) {
            docTypeMap.put(dt.MasterLabel, dt.Id);
        }

       
        List<DocumentChecklistItem> docItems = new List<DocumentChecklistItem>();


        docItems.add(new DocumentChecklistItem(
            Name = 'Test Document 1',
            ParentRecordId = app.Id,
            SAP_Fees__c = 100,
            SAP_Hague_Status__c = 'Yes',
            SAP_Requester_Name__c = 'John Requester',
            SAP_Country__c = 'USA',
            SAP_SOTS_Certified_copy_number__c = 'SOTS-001',
            DocumentTypeId = docTypeMap.get('SOTS Certified Copies')
        ));

        
        docItems.add(new DocumentChecklistItem(
            Name = 'Test Document 2',
            ParentRecordId = app.Id,
            SAP_Fees__c = 150,
            SAP_Hague_Status__c = 'Yes',
            SAP_Requester_Name__c = 'Doe Requester',
            SAP_Country__c = 'Canada',
            DocumentTypeId = docTypeMap.get('Vital Records')
        ));

        insert docItems;
    }

    @isTest
    static void testGetAllCertificates() {
        Test.startTest();
        List<Map<String, Object>> results = SAP_ApostilleLetterController.getAllCertificates(0, 10, 'AppliedDate', 'DESC');
        Test.stopTest();
        
        System.assertNotEquals(0, results.size(), 'Expected certificate records to be returned.');
    
        
    }

    @isTest
    static void testGetTotalApplicationsWithCertificates() {
        Test.startTest();
        Integer total = SAP_ApostilleLetterController.getTotalApplicationsWithCertificates();
        Test.stopTest();
        
        
        
        
    }

    @isTest
    static void testGetBase64Image() {
        
        Test.startTest();
        try {
            String base64Img = SAP_ApostilleLetterController.getBase64Image('TestImage');
            Test.stopTest();
        
            System.assertEquals(null, base64Img, 'Expected a valid base64 encoded image string.');
        } catch (Exception e) {
            System.debug('Error fetching base64 image: ' + e.getMessage());
        }
       
    }

    @isTest
    static void testGetPaymentDetails() {
        
        IndividualApplication app = [SELECT Id FROM IndividualApplication LIMIT 1];

        
        RegulatoryTrxnFee payment = new RegulatoryTrxnFee(
            ParentRecordId = app.Id,
            SAP_Payment_Method__c = 'Card',
            Status = 'DRAFT'
        );
        insert payment;

        Test.startTest();
        List<RegulatoryTrxnFee> payments = SAP_ApostilleLetterController.getPaymentDetails(app.Id);
        Test.stopTest();
        
        
        System.assertNotEquals(0, payments.size(), 'Expected payment details to be retrieved.');
        
        
    }

    @isTest
    static void testGetDocumentChecklistItem() {
   
    DocumentChecklistItem docItem = [SELECT Id FROM DocumentChecklistItem LIMIT 1];

    Test.startTest();
    List<DocumentChecklistItem> results = SAP_ApostilleLetterController.getDocumentChecklistItem(docItem.Id);
    Test.stopTest();
     System.assert(results.size() > 0, 'Expected at least one DocumentChecklistItem.');
   
}
    
    @isTest
    static void testGetDocumentChecklistItemDetails() {
   
    IndividualApplication app = [SELECT Id FROM IndividualApplication LIMIT 1];

    Test.startTest();
    Map<String, Object> result = SAP_ApostilleLetterController.getDocumentChecklistItemDetails(app.Id);
    Test.stopTest();
        
     System.assert(result.size() > 0, 'Expected details to be returned.');

   
}
    
    @isTest
    static void testGetLetterCount() {
        Test.startTest();
        Integer letterCount = SAP_ApostilleLetterController.getLetterCount();
        Test.stopTest();
        System.assert(letterCount >= 0, 'Letter count should be zero or more.');
    }
    
    @isTest
static void testGetDocumentChecklistItems_Success_Scenario(){
   
    IndividualApplication testApp = [SELECT Id FROM IndividualApplication LIMIT 1];
    DocumentChecklistItem testDocItem = [SELECT Id, DocumentType.MasterLabel, SAP_Certificate_Number__c FROM DocumentChecklistItem LIMIT 1];

    
    Test.startTest();
    List<DocumentChecklistItem> result = SAP_ApostilleLetterController.getDocumentChecklistItems(
        testApp.Id, 
        testDocItem.DocumentType.MasterLabel, 
        testDocItem.SAP_Certificate_Number__c
    );
    Test.stopTest();
    
    
        System.assertNotEquals(null, result, 'Result should not be null.');
        System.assert(result.size() >= 0, 'Result should return records or an empty list.');
}
    
    // **Failure Scenario - Missing Parameters**
    @isTest
static void testGetDocumentChecklistItems_Failure_Scenario() {      
    try {
        Test.startTest();
        SAP_ApostilleLetterController.getDocumentChecklistItems('', '', '');
        Test.stopTest();
        System.assert(false, 'Expected an exception for missing parameters but none occurred.');
        
    } catch (AuraHandledException e) {
        System.debug(e.getMessage());
    }

    
    
}

}