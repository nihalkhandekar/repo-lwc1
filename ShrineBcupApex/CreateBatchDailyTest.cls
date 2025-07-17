@isTest
public class CreateBatchDailyTest {
    @isTest
    static void testCreateBatchDaily() {
        
        Test.startTest();
        CreateBatchDaily batchCreator = new CreateBatchDaily();
        batchCreator.execute(null);
        Test.stopTest();
        
        List<Batch__c> createdBatches = [SELECT Name FROM Batch__c];
        
        Set<String> batchNames = new Set<String>();
        for (Batch__c batch : createdBatches) {
            batchNames.add(batch.Name);
        }
    }
}