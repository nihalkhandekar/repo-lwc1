@isTest
public class SAP_FinsysDailySettlementReportTest {

    // Setup test data
    @testSetup
    static void setupTestData() {
        
        // ✅ Retrieve RecordTypes for IndividualApplication
        RecordType rtFinsys = [SELECT Id FROM RecordType WHERE DeveloperName = 'Finsys' AND SObjectType = 'IndividualApplication' LIMIT 1];
        RecordType rtApostille = [SELECT Id FROM RecordType WHERE DeveloperName = 'Apostille' AND SObjectType = 'IndividualApplication' LIMIT 1];
		RecordType refundRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Refund_Transaction' AND SObjectType = 'RegulatoryTrxnFee' LIMIT 1];
        RecordType newRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'New_Transaction' AND SObjectType = 'RegulatoryTrxnFee' LIMIT 1];
        RecordType cardRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Charge_Card' AND SObjectType = 'bt_stripe__Payment_Method__c' LIMIT 1];

        RegulatoryAuthorizationType licenseType = new RegulatoryAuthorizationType(Name = 'Test License');
        insert licenseType;

        // ✅ Insert Individual Applications
        IndividualApplication app1 = new IndividualApplication(SAP_Sequence_Number__c = 'WO-123', Category = 'License', RecordTypeId = rtFinsys.Id, LicenseTypeId = licenseType.Id);
        IndividualApplication app2 = new IndividualApplication(SAP_Sequence_Number__c = 'WO-456', Category = 'License', RecordTypeId = rtApostille.Id, LicenseTypeId = licenseType.Id);
        insert new List<IndividualApplication>{ app1, app2 };

        // ✅ Insert RegulatoryTrxnFee (Transactions)
        RegulatoryTrxnFee txn1 = new RegulatoryTrxnFee(ParentRecordId = app1.Id, SAP_Payment_Type__c = 'Card',SAP_Card_Type__c='VISA', SAP_Brand__c = 'Visa', Status = 'DRAFT', SAP_Transaction_Date__c = Date.today(),RecordTypeId=newRecordType.Id);
        RegulatoryTrxnFee txn2 = new RegulatoryTrxnFee(ParentRecordId = app2.Id, SAP_Payment_Type__c = 'Card',SAP_Card_Type__c='VISA', SAP_Brand__c = 'MasterCard', Status = 'DRAFT', SAP_Transaction_Date__c = Date.today(),RecordTypeId=newRecordType.Id);
        insert new List<RegulatoryTrxnFee>{ txn1, txn2 };

        // ✅ Insert Refund Transactions
        RegulatoryTrxnFee refund1 = new RegulatoryTrxnFee(ParentRecordId = app1.Id, SAP_Payment_Type__c = 'Card',SAP_Card_Type__c='VISA', SAP_Brand__c = 'Visa', Status = 'DRAFT', SAP_Transaction_Date__c = Date.today(), Related_to_Transaction__c = txn1.Id, RecordTypeId = refundRecordType.Id);
        RegulatoryTrxnFee refund2 = new RegulatoryTrxnFee(ParentRecordId = app2.Id, SAP_Payment_Type__c = 'Card',SAP_Card_Type__c='VISA', SAP_Brand__c = 'MasterCard', Status = 'DRAFT', SAP_Transaction_Date__c = Date.today(), Related_to_Transaction__c = txn2.Id, RecordTypeId = refundRecordType.Id);
        insert new List<RegulatoryTrxnFee>{ refund1, refund2 };

         RegulatoryTrxnFeeItem feeItem1 = new RegulatoryTrxnFeeItem(
            Name = 'Test Fee Item 2', 
            RegulatoryTrxnFeeId = txn1.Id, 
            FeeAmount = 150.00
          );
         RegulatoryTrxnFeeItem feeItem2 = new RegulatoryTrxnFeeItem(
            Name = 'Test Fee Item 1', 
            RegulatoryTrxnFeeId = txn2.Id, 
            FeeAmount = 250.00
         );
        RegulatoryTrxnFeeItem feeItem3 = new RegulatoryTrxnFeeItem(
            Name = 'Test Fee Item 2', 
            RegulatoryTrxnFeeId = refund1.Id, 
            FeeAmount = 50.00
          );
         RegulatoryTrxnFeeItem feeItem4 = new RegulatoryTrxnFeeItem(
            Name = 'Test Fee Item 1', 
            RegulatoryTrxnFeeId = refund2.Id, 
            FeeAmount = 100.00
         );
       
        insert new List<RegulatoryTrxnFeeItem>{ feeItem1, feeItem2,feeItem3,feeItem4 };
        // ✅ Insert Contact
        Contact contact = new Contact(FirstName = 'John', LastName = 'Doe', Email = 'john.doe@example.com');
        insert contact;

        // ✅ Insert Work Orders
        Work_Order__c wo1 = new Work_Order__c(Customer__c = contact.Id, Received_Date__c = Date.today());
        Work_Order__c wo2 = new Work_Order__c(Customer__c = contact.Id, Received_Date__c = Date.today().addDays(-1)); 
        insert new List<Work_Order__c>{ wo1, wo2 };

        // ✅ Collect Work Order IDs
        Set<Id> workOrderIds = new Set<Id>{ wo1.Id, wo2.Id };
        System.debug('workOrderIds: ' + workOrderIds);

        // ✅ Insert Payment Gateway
        bt_stripe__Payment_Gateway__c testGateway = new bt_stripe__Payment_Gateway__c(Name = 'Test Gateway');
        insert testGateway;
     
        // ✅ Insert Payment Methods
        bt_stripe__Payment_Method__c visaPaymentMethod = new bt_stripe__Payment_Method__c(bt_stripe__Brand__c = 'Visa', bt_stripe__CVV__c = '123', bt_stripe__Billing_Postal_Code__c = '1234', bt_stripe__Payment_Gateway__c = testGateway.Id, RecordTypeId = cardRecordType.Id);
        bt_stripe__Payment_Method__c masterCardPaymentMethod = new bt_stripe__Payment_Method__c(bt_stripe__Brand__c = 'MasterCard', bt_stripe__CVV__c = '123', bt_stripe__Billing_Postal_Code__c = '5643', bt_stripe__Payment_Gateway__c = testGateway.Id, RecordTypeId = cardRecordType.Id);
        insert new List<bt_stripe__Payment_Method__c>{ visaPaymentMethod, masterCardPaymentMethod };

         
        // ✅ Insert BRS Transactions
        bt_stripe__Transaction__c brsTxn1 = new bt_stripe__Transaction__c(bt_stripe__Amount__c = 200.00, bt_stripe__Transaction_Status__c = 'Completed', bt_stripe__Payment_Method__c = visaPaymentMethod.Id, Work_Order__c = wo1.Id);
        bt_stripe__Transaction__c brsTxn2 = new bt_stripe__Transaction__c(bt_stripe__Amount__c = 150.00, bt_stripe__Transaction_Status__c = 'Completed', bt_stripe__Payment_Method__c = masterCardPaymentMethod.Id, Work_Order__c = wo2.Id);
        insert new List<bt_stripe__Transaction__c>{ brsTxn1, brsTxn2 };

        // ✅ Insert BRS Refund Transactions
        bt_stripe__Transaction__c brsRefund1 = new bt_stripe__Transaction__c(bt_stripe__Parent_Transaction__c = brsTxn1.Id, bt_stripe__Refunded_Application_Fee__c = 50.00);
        bt_stripe__Transaction__c brsRefund2 = new bt_stripe__Transaction__c(bt_stripe__Parent_Transaction__c = brsTxn2.Id, bt_stripe__Refunded_Application_Fee__c = 25.00);
        insert new List<bt_stripe__Transaction__c>{ brsRefund1, brsRefund2 };
    }
    @isTest
    static void testGetDailySettlementReport() {

        String paramsJson = '{"transactionDate":"' + String.valueOf(Date.today()) + '"}';
        
        Test.startTest();
        List<SAP_FinsysDailySettlementReport.CardTransactionWrapper> result = SAP_FinsysDailySettlementReport.getDailySettlementReport(paramsJson);
        Test.stopTest();
       
        System.assertNotEquals(0, result.size(), 'Results should not be empty');
       }
 @isTest
    static void testNoTransactionsFound() {

        String paramsJson = '{"transactionDate":"' + String.valueOf(Date.today().addDays(-1)) + '"}';
        
        Test.startTest();
		List<SAP_FinsysDailySettlementReport.CardTransactionWrapper> result = SAP_FinsysDailySettlementReport.getDailySettlementReport(paramsJson);
        Test.stopTest();
        System.assertEquals(0, result.size(), 'No transactions should be found for the given date.');

    }
   
    
}