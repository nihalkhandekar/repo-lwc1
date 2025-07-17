@isTest
public class BatchControllerTest {
    @testSetup
    public static void setup() {
        // Create test data
        List<Batch__c> batches = new List<Batch__c>();
        for (Integer i = 0; i < 10; i++) {
            Batch__c batch = new Batch__c(
                Batch_Code__c = 'BARBARA',
                Transacation_Count__c = 10,
                Transacation_Amount__c = 1000,
                Batch_Date__c = Date.today(),
                Batch_Status__c = 'Open'
            );
            batches.add(batch);
        }
        insert batches;
    }

    @isTest
    public static void testBatchItems() {
        // Test with no filters
        List<Batch__c> batches = BatchController.batchItems(null, null, null, null, null, null, null, 1, 10);
        System.assert(batches.size() == 10);

        // Test with batch code filter
        batches = BatchController.batchItems('BARBARA', null, null, null, null, null, null, 1, 10);
        System.assert(batches.size() == 10);

        // Test with transaction amount filter
        batches = BatchController.batchItems(null, null, '0 - 1000', null, null, null, null, 1, 10);
        System.assert(batches.size() == 10);
        
        batches = BatchController.batchItems(null, null, '1000 - 5000', null, null, null, null, 1, 10);
        System.assert(batches.size() == 10);

        // Test with batch date filter
        batches = BatchController.batchItems(null, null, null, Date.valueOf('2024-08-15'), Date.valueOf('2024-08-21'), null, null, 1, 10);

        // Test with batch status filter
        batches = BatchController.batchItems(null, null, null, null, null, 'Open', null, 1, 10);
        System.assert(batches.size() == 10);

        // Test with date filter
        batches = BatchController.batchItems(null, null, null, null, null, null, 'ThisWeek', 1, 10);
        System.assert(batches.size() == 10);
        
        batches = BatchController.batchItems(null, null, null, null, null, null, 'ThisMonth', 1, 10);
        System.assert(batches.size() == 10);
        
        batches = BatchController.batchItems(null, null, null, null, null, null, 'ThisQuarter', 1, 10);
        System.assert(batches.size() == 10);
        
        batches = BatchController.batchItems(null, null, null, null, null, null,  'ThisYear', 1, 10);
        System.assert(batches.size() == 10);
        
        batches = BatchController.batchItems(null, null, null, null, null, null,  'ThisDay', 1, 10);
        System.assert(batches.size() == 10);
    }

    @isTest
    public static void testGetBatchItemCount() {
        // Test with no filters
        Integer count = BatchController.getBatchItemCount(null, null, null, null, null, null, null);
        System.assert(count == 10);

        // Test with batch code filter
        count = BatchController.getBatchItemCount('BARBARA', null, null, null, null, null, null);
        System.assert(count == 10);

        // Test with transaction amount filter
        count = BatchController.getBatchItemCount(null, null, '0 - 1000', null, null, null, null);
        System.assert(count == 10);
        
        count = BatchController.getBatchItemCount(null, null, '1000 - 5000', null, null, null, null);
        System.assert(count == 10);

        // Test with batch date filter
        count = BatchController.getBatchItemCount(null, null, null, Date.valueOf('2024-08-15'), Date.valueOf('2024-08-21'), null, null);
        
        // Test with batch status filter
        count = BatchController.getBatchItemCount(null, null, null, null, null, 'Open', null);
        System.assert(count == 10);

        // Test with date filter
        count = BatchController.getBatchItemCount(null, null, null, null, null, null, 'ThisWeek');
        System.assert(count == 10);
        
        count = BatchController.getBatchItemCount(null, null, null, null, null, null, 'ThisMonth');
        System.assert(count == 10);
        
        count = BatchController.getBatchItemCount(null, null, null, null, null, null, 'ThisQuarter');
        System.assert(count == 10);
        
        count = BatchController.getBatchItemCount(null, null, null, null, null, null,  'ThisYear');
        System.assert(count == 10);
        
       	count = BatchController.getBatchItemCount(null, null, null, null, null, null,  'ThisDay');
        System.assert(count == 10);
    }
}