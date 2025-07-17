@isTest
public class SAP_BatchFinsysControllerDuplicate_Test {
    @testSetup
    static void setupTestData() {
        // Use TestDataFactory to create reusable test records
        Batch__C testBatch = TestDataFactory.createTestBatch();
        RegulatoryAuthorizationType licenseType = TestDataFactory.createTestLicenseType();
        IndividualApplication app = TestDataFactory.createTestIndividualApplication(licenseType);
        RegulatoryTrxnFee testFee = TestDataFactory.createTestRegulatoryTrxnFee(testBatch, app);
    }
    
    @isTest
    static void testGetActivityTransactionDataWhenOnlyIdIsAvailable() {
        // Retrieve test Batch ID
        Id batchId = [SELECT Id FROM Batch__C LIMIT 1].Id;
        
        // Call the method and assert results
        Test.startTest();
        Map<String, Object> result = SAP_BatchFinsysControllerDuplicate.getActivityTransactionDataWhenOnlyIdIsAvailable(batchId);
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.containsKey('BatchData'), 'Result should contain BatchData');
    }
    
    @isTest
    static void testUpdateBatchStatus() {
        // Retrieve test Batch ID
        Id batchId = [SELECT Id FROM Batch__C LIMIT 1].Id;
        
        // Prepare JSON data
        String batchData = '{"BatchId": "' + batchId + '", "NewBatchStatus": "Closed"}';
        
        // Call the update method
        Test.startTest();
        String result = SAP_BatchFinsysControllerDuplicate.UpdateBatchStatus(batchData);
        Test.stopTest();
        
        // Assertions
        System.assertEquals('Success', result, 'Batch status should update successfully');
        
        // Verify the status update
        Batch__C updatedBatch = [SELECT SAP_Batch_Status__c FROM Batch__C WHERE Id = :batchId];
        System.assertEquals('Closed', updatedBatch.SAP_Batch_Status__c, 'Batch status should be updated to Closed');
    }
}