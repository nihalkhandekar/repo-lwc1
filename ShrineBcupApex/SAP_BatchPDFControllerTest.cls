@isTest
public class SAP_BatchPDFControllerTest {
    @testSetup
    static void setupTestData() {
        // Create test data using factory methods
        User testUser = TestDataFactory.createTestUser();
        Batch__C testBatch = TestDataFactory.createTestBatch();
        RegulatoryAuthorizationType licenseType = TestDataFactory.createTestLicenseType();
        IndividualApplication app = TestDataFactory.createTestIndividualApplication(licenseType);
        RegulatoryTrxnFee testFee = TestDataFactory.createTestRegulatoryTrxnFee(testBatch, app);
    }

    @isTest
    static void testGetBatchData() {
        // Fetch test Batch__C record
        Batch__C testBatch = [SELECT Id FROM Batch__C LIMIT 1];

        Test.startTest();
        SAP_BatchPDFController.BatchWrapper result = SAP_BatchPDFController.getBatchData(testBatch.Id);
        Test.stopTest();

        // Assertions
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(testBatch.Id, result.batchId, 'Batch ID should match');
        System.assertEquals('Notary Public', result.batchName, 'Batch Name should match');
        System.assertEquals('Closed', result.batchStatus, 'Batch Status should match');
        System.assertEquals(1, result.transactionCount, 'Transaction count should match');

        // Verify fees
        System.assertNotEquals(null, result.fees, 'Fees should not be null');
        System.assertEquals(1, result.fees.size(), 'Should have one fee record');
        System.assertEquals('Card', result.fees[0].paymentType, 'Payment type should match');
    }
}