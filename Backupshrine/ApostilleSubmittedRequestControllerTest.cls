@isTest(SeeAllData=false)
public class ApostilleSubmittedRequestControllerTest {

    // Helper method to create a test application
    private static IndividualApplication createTestApplication(String status) {
        RegulatoryAuthorizationType regAuthType = new RegulatoryAuthorizationType(Name = 'TestRegulatoryAuthorizationType');
        insert regAuthType;

        IndividualApplication app = new IndividualApplication(
            RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'IndividualApplication' AND Name = 'Apostille' LIMIT 1].Id,
            Sequence_Number__c = 'WO123456',
            Organization_Name__c = 'Test Organization',
            First_Name__c = 'John',
            Last_Name__c = 'Doe',
            AppliedDate = DateTime.now(),
            Country__c = 'USA',
            LicenseTypeId = regAuthType.Id,
            Status = status,
            Category = 'License'
        );
        insert app;

        return app;
    }

    // Helper method to create a document for the test application
private static void createTestDocument(IndividualApplication app, String docType, String status) {
    // Query for an existing DocumentType by name
    DocumentType docTypeRecord = [SELECT Id FROM DocumentType WHERE MasterLabel = :docType LIMIT 1];
    
    // Ensure the DocumentType exists
    if (docTypeRecord == null) {
        System.debug('No DocumentType found with MasterLabel: ' + docType);
        return; // Exit if no matching DocumentType is found
    }

    // Create a test Contact
    Contact testContact = new Contact(
        FirstName = 'John',
        LastName = 'Doe',
        Position__c = 'Deputy Clerk'
    );
    insert testContact;

    // Create the DocumentChecklistItem
    DocumentChecklistItem doc = new DocumentChecklistItem(
        ParentRecordId = app.Id,
        Name = 'testDocumentChecklistItem',
        DocumentTypeId = docTypeRecord.Id,
        Status = status,
        Country__c = app.Country__c,
        Signed_By__c = testContact.Id
    );
    insert doc;
}

    // Test the getApplications method
    @isTest
    static void testGetApplications() {
        // Create test applications
        IndividualApplication app1 = createTestApplication('Submitted');
        IndividualApplication app2 = createTestApplication('Completed');

        // Create a document for the application
        createTestDocument(app1, 'Passport', 'Signed');
        createTestDocument(app2, 'Visa', 'Signed');

        // Prepare the parameters JSON for testing
        String paramsJson = JSON.serialize(new Map<String, Object> {
            'workOrder' => 'WO123456',
            'requestDate' => Date.today().format(),
            'requesterName' => 'John',
            'offsetVal' => 0,
            'pageSize' => 10,
            'sortBy' => 'AppliedDate',
            'sortDirection' => 'ASC'
        });

        // Call the method
        Test.startTest();
        List<Map<String, Object>> result = ApostilleSubmittedRequestController.getApplications(paramsJson);
        Test.stopTest();

        // Assertions to ensure correct behavior
        System.assertNotEquals(result, null, 'Result should not be null');
        System.assert(result.size() > 0, 'Result should contain at least one application');
        System.assert(result[0].containsKey('ApplicationID'), 'Result should contain ApplicationID');
        System.assert(result[0].containsKey('requestorName'), 'Result should contain requestorName');
        System.assert(result[0].containsKey('Status'), 'Result should contain Status');
    }

    // Test the getApplicationsCount method
    @isTest
    static void testGetApplicationsCount() {
        // Create test applications with different statuses
        createTestApplication('Submitted');
        createTestApplication('Completed');
        createTestApplication('Cancelled');

        // Test the count method
        Test.startTest();
        Integer count = ApostilleSubmittedRequestController.getApplicationsCount('WO123456', null, 'Test Organization', null, 'Submitted', null);
        Test.stopTest();

        // Assert the count is correct
        System.assertEquals(count, 1, 'Expected one application with status "Submitted"');
    }

    // Test the updateApplicationStatusToCancelled method
    @isTest
    static void testUpdateApplicationStatusToCancelled() {
        // Create a test application with "Submitted" status
        IndividualApplication app = createTestApplication('Submitted');

        // Call the method to update the status
        Test.startTest();
        Boolean result = ApostilleSubmittedRequestController.updateApplicationStatusToCancelled(app.Id);
        Test.stopTest();

        // Reload the app from the database
        app = [SELECT Status FROM IndividualApplication WHERE Id = :app.Id];

        // Assert that the application status is updated to "Cancelled"
        System.assertEquals(result, true, 'The status should be updated to cancelled');
        System.assertEquals(app.Status, 'Cancelled', 'Application status should be "Cancelled"');
    }

    // Test the updateApplicationStatusToCancelled method for a non-submitted application
    @isTest
    static void testInvalidApplicationStatusUpdate() {
        // Create an application with "Completed" status
        IndividualApplication app = createTestApplication('Completed');

        // Try to update the status to Cancelled
        Test.startTest();
        Boolean result = ApostilleSubmittedRequestController.updateApplicationStatusToCancelled(app.Id);
        Test.stopTest();

        // Assert that the result is false since the status was not "Submitted"
        System.assertEquals(result, false, 'The status should not be updated since it is not in "Submitted" status');
    }

    // Test getApplicationCountsByStatus method
	@isTest(SeeAllData=false)
	static void testGetApplicationCountsByStatus() {
    // Create test applications with different statuses
    IndividualApplication app1 = createTestApplication('Submitted');
    IndividualApplication app2 = createTestApplication('Completed');
    IndividualApplication app3 = createTestApplication('Cancelled'); // Make sure there is one with 'Cancelled'
    IndividualApplication app4 = createTestApplication('Draft');
    
    // Call the method
    Test.startTest();
    Map<String, Integer> result = ApostilleSubmittedRequestController.getApplicationCountsByStatus(null, null);
    Test.stopTest();

    // Assert that the counts are correct
    System.assertEquals(result.get('submitted'), 1, 'Expected 1 application with status Submitted');
    System.assertEquals(result.get('completed'), 1, 'Expected 1 application with status Completed');
    System.assertEquals(result.get('draft'), 1, 'Expected 1 application with status Draft');
    System.assertEquals(result.get('cancelled'), 1, 'Expected 1 application with status Cancelled'); // Check for 'Cancelled' status
}


    // Test getApplicationsCount with date filter
@isTest(SeeAllData=false)
static void testGetApplicationsCountWithDateFilter() {
    // Create test applications with different applied dates
    IndividualApplication app1 = createTestApplication('Submitted');
    app1.AppliedDate = DateTime.now().addDays(-10);
    update app1;

    IndividualApplication app2 = createTestApplication('Completed');
    app2.AppliedDate = DateTime.now().addDays(-5);
    update app2;

    // Test the count method with a date filter (ensure the date is formatted correctly)
    Test.startTest();
    
    // Format the start date correctly (ISO 8601 format)
    String startDate = Date.today().addDays(-7).format(); // This will be in 'yyyy-MM-dd' format
    String endDate = Date.today().format(); // The end date is today

    // Call the method to count the applications within the date range
    Integer count = ApostilleSubmittedRequestController.getApplicationsCount('WO123456', startDate, null, null, null, null);
    Test.stopTest();

    // Assert that the count is correct
    System.assertEquals(count, 1, 'Expected one application within the date range');
}

}