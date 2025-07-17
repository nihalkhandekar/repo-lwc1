@IsTest
private class SAP_InsertPaymentDataControllerTest {
    
    @TestSetup
    static void setupTestData() {
        RegulatoryAuthorizationType licenseType = TestDataFactory.createTestLicenseType();
        IndividualApplication app = TestDataFactory.createTestIndividualApplication(licenseType);
        
    
    }

    @IsTest
    static void testCreateMultipleTransaction() {
        Test.startTest();
        IndividualApplication app = [SELECT Id FROM IndividualApplication LIMIT 1];

        // Create test input data
        List<Map<String, Object>> testRows = new List<Map<String, Object>>();
        
        Map<String, Object> row1 = new Map<String, Object>{
            'authCode' => 'AUTH123',
            'type' => 'Card',
            'cardType' => 'Visa',
            'last4Digits' => '1234',
            'paymentAmount' => '100.50',
            'recordIdIndApp' => app.Id
        };

        Map<String, Object> row2 = new Map<String, Object>{
            'authCode' => 'AUTH456',
            'type' => 'Card',
            'cardType' => 'MasterCard',
            'last4Digits' => '5678',
            'paymentAmount' => '50.75',
            'recordIdIndApp' => app.Id
        };

        testRows.add(row1);
        testRows.add(row2);

        // Call the method
        Decimal totalSum = SAP_InsertPaymentDataController.createMultipleTransaction(testRows);

        Test.stopTest();

        // Verify expected results
        System.assertEquals(151.25, totalSum, 'Total sum should be the sum of paymentAmount and paymentAmountCheck');

        // Verify that records were inserted
        List<RegulatoryTrxnFee> insertedParents = [SELECT Id, SAP_amount__c FROM RegulatoryTrxnFee WHERE SAP_Auth_Code__c IN ('AUTH123', 'AUTH456')];
        System.assertEquals(2, insertedParents.size(), 'Two RegulatoryTrxnFee records should be inserted');

        List<RegulatoryTrxnFeeItem> insertedChildren = [SELECT Id, FeeAmount FROM RegulatoryTrxnFeeItem];
        System.assertEquals(2, insertedChildren.size(), 'Two RegulatoryTrxnFeeItem records should be inserted');
        System.assertEquals(100.50, insertedChildren[0].FeeAmount, 'First child record should match the payment amount');
        System.assertEquals(50.75, insertedChildren[1].FeeAmount, 'Second child record should match the payment amount check');
    }
    
    @IsTest
    static void testUpdateTransaction() {
        // Fetch an existing RegulatoryTrxnFee record
        RegulatoryTrxnFee txn = [SELECT Id FROM RegulatoryTrxnFee LIMIT 1];
        RegulatoryTrxnFeeItem txnItem = [SELECT Id, FeeAmount FROM RegulatoryTrxnFeeItem WHERE RegulatoryTrxnFeeId = :txn.Id LIMIT 1];

        // Prepare input JSON
        Map<String, Object> updateData = new Map<String, Object>{
            'recordIdTnnx' => txn.Id,
            'authCode' => 'NEW_AUTH123',
            'type' => 'Cash',
            'cardType' => 'Discover',
            'last4Digits' => '4321',
            'paymentAmount' => '200.00',
            'checkNumber' => '123456',
            'moneyOrder' => '654321'
        };
        String updateJson = JSON.serialize(updateData);

        Test.startTest();
        Decimal updatedAmount = SAP_InsertPaymentDataController.updateTransaction(updateJson);
        Test.stopTest();

        // Verify that the transaction was updated
        RegulatoryTrxnFee updatedTxn = [SELECT SAP_Auth_Code__c, SAP_Payment_Type__c, Status FROM RegulatoryTrxnFee WHERE Id = :txn.Id];
        System.assertEquals('NEW_AUTH123', updatedTxn.SAP_Auth_Code__c, 'Auth code should be updated');
        System.assertEquals('Cash', updatedTxn.SAP_Payment_Type__c, 'Payment type should be updated');
        System.assertEquals('Paid', updatedTxn.Status, 'Status should be updated to Paid');

        // Verify that the related fee item was updated
        RegulatoryTrxnFeeItem updatedTxnItem = [SELECT FeeAmount FROM RegulatoryTrxnFeeItem WHERE Id = :txnItem.Id];
        System.assertEquals(200.00, updatedTxnItem.FeeAmount, 'FeeAmount should be updated');
    }

   
}