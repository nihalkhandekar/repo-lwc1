@isTest(SeeAllData=false)
public class ApostillePrintSubmissionDocContrTest
{	
    
@isTest(SeeAllData=false)
static void testGetDocDetailsWithExpeditedFalse() {

    RegulatoryAuthorizationType regAuthType = new RegulatoryAuthorizationType(
        Name = 'TestRegulatoryAuthorizationType'
    );
    insert regAuthType;

    // Make sure Expedited__c is false here
    IndividualApplication testApplication = new IndividualApplication(
        LicenseTypeId = regAuthType.Id,
        Category = 'License',
        First_Name__c = 'John',
        Last_Name__c = 'Doe',
        Organization_Name__c = 'Test Org',
        Expedited__c = false, // Set this to false
        Sequence_Number__c = '1'
    );
    insert testApplication;

    // Setup mock data for DocumentChecklistItem
    DocumentChecklistItem doc1 = new DocumentChecklistItem(
        Name = 'Document1',
        ParentRecordId = testApplication.Id,
        Country__c = 'UK',
        Requester_Name__c = 'Alice Smith',
        Hague_Status__c = 'Yes',
        Fees__c = 150
    );
    
    DocumentChecklistItem doc2 = new DocumentChecklistItem(
        Name = 'Document2',
        ParentRecordId = testApplication.Id,
        Country__c = 'UK',
        Requester_Name__c = 'Bob Smith',
        Hague_Status__c = 'No',
        Fees__c = 250
    );
    insert new List<DocumentChecklistItem>{doc1, doc2};

    // Call the method to test
    Test.startTest();
    Map<String, Object> result = ApostillePrintSubmissionDocController.getDocDetails(testApplication.Id);
    Test.stopTest();

    // Verify the number of documents
    List<Map<String, Object>> documentList = (List<Map<String, Object>>) result.get('documents');
    System.assertEquals(2, documentList.size());

    // Verify the fees are as originally set (no discount for expedited)
    System.assertEquals(150, documentList[0].get('fees'));
    System.assertEquals(250, documentList[1].get('fees'));

    // Verify the total fees (no expedited fee applied)
    Map<String, Object> individualAppData = (Map<String, Object>) result.get('individualApplication');
    System.assertEquals(150 + 250, individualAppData.get('finalTotal')); // Total should be the sum of the document fees
}


@isTest(SeeAllData=false)
static void testGetDocDetailsWithExpeditedTrue(){
    
    RegulatoryAuthorizationType regAuthType = new RegulatoryAuthorizationType(
        Name = 'TestRegulatoryAuthorizationType'
    );
    insert regAuthType;

    IndividualApplication testApplication = new IndividualApplication(
        LicenseTypeId = regAuthType.Id,
        Category = 'License',
        First_Name__c = 'John',
        Last_Name__c = 'Doe',
        Organization_Name__c = 'Test Org',
        Expedited__c = true,
        Sequence_Number__c = '1'
    );
    insert testApplication;

    DocumentChecklistItem doc1 = new DocumentChecklistItem(
        Name = 'Document1',
        Certificate_Number__c = 'CERT123',
        ParentRecordId = testApplication.Id,
        Country__c = 'USA',
        Requester_Name__c = 'Martin William',
        Hague_Status__c = 'Yes',
        Fees__c = 100
    );

    DocumentChecklistItem doc2 = new DocumentChecklistItem(
        Name = 'Document2',
        ParentRecordId = testApplication.Id,
        Country__c = 'CANADA',
        Requester_Name__c = 'Jane Doe',
        Hague_Status__c = 'No',
        Fees__c = 200
    );
    
    insert new List<DocumentChecklistItem>{doc1, doc2};

    Test.startTest();
    Map<String, Object> result = ApostillePrintSubmissionDocController.getDocDetails(testApplication.Id);
    Test.stopTest();

    List<Map<String, Object>> documentList = (List<Map<String, Object>>) result.get('documents');
    System.assertEquals(2, documentList.size());

    Decimal expectedFeesForDoc1 = 100 - 50; // Expedited reduces fees by 50
    Decimal expectedFeesForDoc2 = 200 - 50; // Expedited reduces fees by 50

    System.assertEquals(expectedFeesForDoc1, documentList[0].get('fees'));
    System.assertEquals(expectedFeesForDoc2, documentList[1].get('fees'));

    Map<String, Object> individualAppData = (Map<String, Object>) result.get('individualApplication');
    System.assertEquals(50 * documentList.size(), individualAppData.get('expedited')); // Expedited fee is 50 * number of documents
    System.assertEquals(expectedFeesForDoc1 + expectedFeesForDoc2 + 50 * documentList.size(), individualAppData.get('finalTotal'));
}

}