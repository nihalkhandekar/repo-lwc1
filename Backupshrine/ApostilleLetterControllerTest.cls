@IsTest
public with sharing class ApostilleLetterControllerTest {
    
    @TestSetup
    static void setupTestData() {
        
        RegulatoryAuthorizationType authType = new RegulatoryAuthorizationType(Name = 'Test Regulatory Authorization Type');
        insert authType;
        
        // Create Record Type for 'Apostille'
        RecordType apostilleRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'IndividualApplication' AND DeveloperName = 'Apostille' LIMIT 1];
        
        // Create Individual Application records
        List<IndividualApplication> applications = new List<IndividualApplication>();
        for (Integer i = 1; i <= 5; i++) {
            applications.add(new IndividualApplication(
                RecordTypeId = apostilleRecordType.Id,
                Sequence_Number__c = 'APP-' + i,
                Organization_Name__c = 'Org ' + i,
                First_Name__c = 'FirstName' + i,
                Last_Name__c = 'LastName' + i,
                AppliedDate = Date.today().addDays(-i),
                LicenseTypeId = authType.Id,
                Destination__c = 'Test Destination',
                Category = 'License',
                Status = (Math.floor(i / 2) * 2 == i) ? 'Approved' : 'Submitted' // Alternate even/odd check
            ));
        }
        insert applications;

        // Create Document Checklist Items
        List<DocumentChecklistItem> checklistItems = new List<DocumentChecklistItem>();
        Integer applicationIndex = 0;
        for (Integer j = 1; j <= 10; j++) {
            checklistItems.add(new DocumentChecklistItem(
                Name = 'Checklist Item ' + j,
                ParentRecordId = applications[applicationIndex].Id,
                Certificate_Number__c = 'CERT-' + j,
                Status = (Math.floor(j / 2) * 2 == j) ? 'Issued' : 'Pending'
            ));
            // Rotate through applications list
            applicationIndex++;
            if (applicationIndex >= applications.size()) {
                applicationIndex = 0;
            }
        }
        insert checklistItems;

        // Create Regulatory Transaction Fee Records
        List<RegulatoryTrxnFee> feeRecords = new List<RegulatoryTrxnFee>();
        for (IndividualApplication app : applications) {
            feeRecords.add(new RegulatoryTrxnFee(
                ParentRecordId = app.Id,
                Status = 'Draft',
                //TotalFeeAmount = 100 + Math.random() * 100,
                Payment_Method__c = (app.Status == 'Approved') ? 'Credit Card' : 'Check'
            ));
        }
        insert feeRecords;
    }

    @IsTest
    static void testGetAllCertificates() {
        Test.startTest();
        List<Map<String, Object>> results = ApostilleLetterController.getAllCertificates(0, 2, 'Sequence_Number__c', 'ASC');
        System.assertNotEquals(0, results.size());
        System.assertEquals(2, results.size()); // Validate pagination
        System.assertEquals('APP-2', results[0].get('ApplicationID')); // Validate sorting
        Test.stopTest();
    }

    @IsTest
    static void testGetTotalApplicationsWithCertificates() {
        Test.startTest();
        Integer totalApplications = ApostilleLetterController.getTotalApplicationsWithCertificates();
        System.assertEquals(5, totalApplications);
        Test.stopTest();
    }

    @IsTest
    static void testGetBase64Image() {
        Test.startTest();
        String imageBase64 = ApostilleLetterController.getBase64Image('certificateImage'); 
        System.assertNotEquals(null, imageBase64);
        System.assert(!String.isEmpty(imageBase64), 'Expected non-empty Base64 image content');
        Test.stopTest();
    }

    @IsTest
    static void testGetPaymentDetails() {
        List<IndividualApplication> apps = [SELECT Id FROM IndividualApplication LIMIT 1];
        Test.startTest();
        List<RegulatoryTrxnFee> payments = ApostilleLetterController.getPaymentDetails(apps[0].Id);
        System.assertNotEquals(0, payments.size());
        Test.stopTest();
    }

    @IsTest
    static void testGetDocumentChecklistItemDetails() {
        List<IndividualApplication> apps = [SELECT Id FROM IndividualApplication LIMIT 1];
        Test.startTest();
        Map<String, Object> details = ApostilleLetterController.getDocumentChecklistItemDetails(apps[0].Id);
        System.assertNotEquals(null, details);
        System.assertNotEquals(0, details.get('documents'));
        Test.stopTest();
    }
}