@isTest(SeeAllData=false)
public class appostileWorkOrderControllerTest {

    @isTest(SeeAllData=false)
    static void testGetDocumentChecklistItem() {
        // Step 1: Set up test data
        RegulatoryAuthorizationType regAuthType = new RegulatoryAuthorizationType(
            Name = 'TestRegulatoryAuthorizationType'
        );
        insert regAuthType;

        IndividualApplication app = new IndividualApplication(
            Expedited__c = true,
            Status = 'Pending',
            LicenseTypeId = regAuthType.Id,
            Category = 'License',
            AppliedDate = DateTime.now().addDays(-10)
        );
        insert app;

        DocumentChecklistItem docItem1 = new DocumentChecklistItem(
            Name = 'Document1',
            ParentRecordId = app.Id,
            Requester_Name__c = 'Alice Smith',
            Certificate_Number__c = '123456789',
            country__c = 'USA',
            Status = 'Completed'
        );

        DocumentChecklistItem docItem2 = new DocumentChecklistItem(
            Name = 'Document2',
            ParentRecordId = app.Id,
            Requester_Name__c = 'Bob Johnson',
            Certificate_Number__c = '987654321',
            country__c = 'USA',
            Status = 'Pending'
        );
        insert new List<DocumentChecklistItem>{docItem1, docItem2};

        // Start the test
        Test.startTest();
        
        // Step 2: Test the method without any filter parameters
        Map<String, Object> result = appostileWorkOrderController.getDocumentChecklistItem(
            null, null, null, null, null, null, null, null, null, null
        );
        
        // Validate that records are returned
        System.assertNotEquals(result.get('records'), null, 'Result should not be null');
        System.assertEquals(((List<DocumentCheckListWithApplication>) result.get('records')).size(), 2, 'Expected 2 records');
        System.assertEquals(result.get('count'), 2, 'Expected record count to be 2');

        // Step 3: Test with some filters (Date range filter)
        Date fromDate = Date.today().addDays(-7);
        Date toDate = Date.today();

        result = appostileWorkOrderController.getDocumentChecklistItem(
            fromDate, toDate, 'Completed', 'John Doe', 'Alice Smith', DateTime.now().addDays(-10), '123456789', 'USA', 'Manager', 'APP12345'
        );
        
        // Validate the filtered result
        System.assertNotEquals(result.get('records'), null, 'Result should not be null');

        // Step 4: Test with no records found (Nonexistent data)
        result = appostileWorkOrderController.getDocumentChecklistItem(
            fromDate, toDate, 'Pending', 'Nonexistent Name', 'Nonexistent Requestor', DateTime.now(), '111111111', 'Canada', 'Clerk', 'APP99999'
        );
        
        // Validate that no records are returned
        System.assertEquals(((List<DocumentCheckListWithApplication>) result.get('records')).size(), 0, 'Expected 0 records');
        System.assertEquals(result.get('count'), 0, 'Expected record count to be 0');
        
        // End the test
        Test.stopTest();
    }
}