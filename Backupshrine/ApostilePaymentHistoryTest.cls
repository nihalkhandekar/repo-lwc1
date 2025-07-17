@isTest
public class ApostilePaymentHistoryTest {

    // Method to set up common test data for all tests
    private static Map<String, Id> setupTestData() {
        
       Id createTransaction = Schema.SObjectType.RegulatoryTrxnFeeItem.getRecordTypeInfosByDeveloperName()
            .get('Create_Transaction')
       .getRecordTypeId();
        
        RegulatoryAuthorizationType license1=new RegulatoryAuthorizationType(
            Name='Test',
            RegulatoryAuthCategory='License',
            DurationType='Hour'
        );
        insert license1;
        
        
        
        // Create a dummy IndividualApplication record
        IndividualApplication app = new IndividualApplication(
            Sequence_Number__c = 'APO-202411-0005',
            First_Name__c = 'JAMES',
            Last_Name__c = 'HARI',
            LicenseTypeId=license1.id,
            Category='License',
            Status='In Progress'
        );
        insert app;
        
        
        

        // Create a list of dummy RegulatoryTrxnFee records
        RegulatoryTrxnFee txn1 = new RegulatoryTrxnFee(
            Transaction_Date__c = Date.today(),
            Auth_Code__c = 'AU0007',
            Payment_Method__c = 'Credit Card',
            ParentRecordId = app.Id,
            Transaction_Status__c = 'Paid',
            Credit_Card_Owner__c = 'John Doe',
            Status='DRAFT'
        );
        
        RegulatoryTrxnFee txn2 = new RegulatoryTrxnFee(
            Transaction_Date__c = Date.today(),
            Auth_Code__c = 'AU0008',
            Payment_Method__c = 'Credit Card',
            ParentRecordId = app.Id,
            Transaction_Status__c = 'Refunded',
            Credit_Card_Owner__c = 'Jane Doe',
            Status='PAID'
            
        );

        // Insert the transaction records
        insert new List<RegulatoryTrxnFee>{txn1, txn2};
        
        
        list<RegulatoryTrxnFeeItem> txnitemList = new list<RegulatoryTrxnFeeItem>();
        RegulatoryTrxnFeeItem txnitem1 = new RegulatoryTrxnFeeItem(
        
            RegulatoryTrxnFeeId=txn1.id,
            Name='test1',
            FeeAmount=100,
            RecordTypeId =createTransaction 
        );
        
        
        RegulatoryTrxnFeeItem txnitem2 = new RegulatoryTrxnFeeItem(
            RegulatoryTrxnFeeId=txn1.id,
            Name='test2',
            FeeAmount=101,
            RecordTypeId = createTransaction
        );
         
        
        RegulatoryTrxnFeeItem txnitem3 = new RegulatoryTrxnFeeItem(
        
            RegulatoryTrxnFeeId=txn2.id,
            Name='test3',
            FeeAmount=103,
            RecordTypeId = createTransaction
        
        );
        
        insert new list<RegulatoryTrxnFeeItem>{txnitem1,txnitem2,txnitem3};
        
        
        

        

        // Return a map with IDs for use in tests
        return new Map<String, Id>{
            'appId' => app.Id,
            'txn1Id' => txn1.Id,
            'txn2Id' => txn2.Id,
            'txnitem1Id'=>txnitem1.id,
            'txnitem2Id'=>txnitem2.id,
			'txnitem3Id'=>txnitem3.id
        };
    }

    // Test method for getTransaction
    @isTest
    static void testGetTransaction() {
        // Step 1: Setup test data
        Map<String, Id> testData = setupTestData();
        Id txn1Id = testData.get('txn1Id');

        // Step 2: Mock the method parameters
        String paramsJson = JSON.serialize(new Map<String, Object>{
            'RegulatoryTrxnFeeId' => txn1Id,
            'offsetVal' => 0,
            'pageSize' => 10,
            'sortBy' => 'TransactionDate',
            'sortDirection' => 'desc'
        });

        // Step 3: Call the method being tested
        Test.startTest();
        List<Map<String, Object>> results = ApostilePaymentHistory.getTransaction(paramsJson);
        Test.stopTest();

        // Step 4: Assert that the results are correct
        System.assertNotEquals(results.size(), 0, 'No results were returned');
        System.assertEquals(results[0].get('TransactionStatus'), 'Paid', 'Transaction status should be Paid');
        System.assertEquals(results[0].get('PaymentAmount'), 201.00, 'Payment amount should be 100.00');
        System.assertEquals(results[0].get('CreditCardName'), 'John Doe', 'Credit card owner should be John Doe');
    }

    // Test method for getTransactionCount
    @isTest
    static void testGetTransactionCount() {
        // Step 1: Setup test data
        Map<String, Id> testData = setupTestData();
        Id appId = testData.get('appId');

        // Step 2: Call the method being tested
        Test.startTest();
        Integer count = ApostilePaymentHistory.getTransactionCount(appId);
        Test.stopTest();

        // Step 3: Assert that the transaction count is correct
        System.assertEquals(count, 2, 'The transaction count should be 2');
    }

    // Test method for exception handling in getTransaction (Error case)
    @isTest
    static void testGetTransactionException() {
        // Simulate an error scenario by passing invalid parameters
        String invalidParamsJson = JSON.serialize(new Map<String, Object>{
            'RegulatoryTrxnFeeId' => null, // Invalid ID
            'offsetVal' => 0,
            'pageSize' => 10,
            'sortBy' => 'InvalidField', // Invalid sort field
            'sortDirection' => 'asc'
        });

        Test.startTest();
        try {
            List<Map<String, Object>> results = ApostilePaymentHistory.getTransaction(invalidParamsJson);
            System.assert(false, 'An exception should have been thrown');
        }catch (AuraHandledException e) { // Ensure catching AuraHandledException specifically
            system.debug(e.getMessage());
        System.assert(e.getMessage().contains('Script-thrown exception'), 
            'Error message should be related to data fetching, but was: ' + e.getMessage());
    }
        Test.stopTest();
    }

    //Test method for invalid input in getTransactionCount (Error case)
    @isTest
   static void testGetTransactionCountException() {
        Test.startTest();
        try {
            Integer count = ApostilePaymentHistory.getTransactionCount(null);
            System.assert(false, 'An exception should have been thrown');
        } catch (Exception e) {
            System.assert(e.getMessage().contains('RegulatoryTrxnFeeId cannot be null or empty'), 'Error message should be related to fetching count');
        }
        Test.stopTest();
    }
}