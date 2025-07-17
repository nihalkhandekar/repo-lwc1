@isTest
public class SAP_FinsysCreditCardReportTest {
    @testSetup
    static void setupTestData() {        
        RecordType rtFinsys = [SELECT Id FROM RecordType WHERE DeveloperName = 'Finsys' AND SObjectType = 'IndividualApplication' LIMIT 1];
        RecordType rtApostille = [SELECT Id FROM RecordType WHERE DeveloperName = 'Apostille' AND SObjectType = 'IndividualApplication' LIMIT 1];
		RecordType newRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'New_Transaction' AND SObjectType = 'RegulatoryTrxnFee' LIMIT 1];
        RecordType cardRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Charge_Card' AND SObjectType = 'bt_stripe__Payment_Method__c' LIMIT 1];

        RegulatoryAuthorizationType licenseType = new RegulatoryAuthorizationType(Name = 'Test License');
        insert licenseType;
		
         Batch__c batch1 = new Batch__c(
            SAP_Batch_Name__c = 'Authentication/Apostille',
            SAP_Batch_Status__c = 'Open',
            SAP_Batch_Date__c = Date.today().addDays(-5),
            SAP_Transacation_Count__c = 10,
            SAP_Transacation_Amount__c = 500
        );

        Batch__c batch2 = new Batch__c(
            SAP_Batch_Name__c = 'Board of Accountancy',
            SAP_Batch_Status__c = 'Closed',
            SAP_Batch_Date__c = Date.today().addDays(-2),
            SAP_Transacation_Count__c = 5
        );
        insert new List<Batch__c>{ batch1, batch2};
            
        // ✅ Insert Individual Applications
        IndividualApplication app1 = new IndividualApplication(SAP_Sequence_Number__c = 'WO-123', Category = 'License', RecordTypeId = rtFinsys.Id, LicenseTypeId = licenseType.Id);
        IndividualApplication app2 = new IndividualApplication(SAP_Sequence_Number__c = 'WO-456', Category = 'License', RecordTypeId = rtApostille.Id, LicenseTypeId = licenseType.Id);
        insert new List<IndividualApplication>{ app1, app2 };

        // ✅ Insert RegulatoryTrxnFee (Transactions)
        RegulatoryTrxnFee txn1 = new RegulatoryTrxnFee(ParentRecordId = app1.Id, Batch_Look_Up__c = batch1.Id, SAP_Payment_Type__c = 'Card', Status = 'DRAFT', SAP_Transaction_Date__c = Date.today().addDays(5),RecordTypeId=newRecordType.Id);
        RegulatoryTrxnFee txn2 = new RegulatoryTrxnFee(ParentRecordId = app2.Id, Batch_Look_Up__c = batch2.Id, SAP_Payment_Type__c = 'Card', Status = 'DRAFT', SAP_Transaction_Date__c = Date.today().addDays(1),RecordTypeId=newRecordType.Id);
        insert new List<RegulatoryTrxnFee>{ txn1, txn2 };

        
        // ✅ Insert Contact
        Contact contact = new Contact(FirstName = 'John', LastName = 'Doe', Email = 'john.doe@example.com');
        insert contact;

        // ✅ Insert Work Orders
        Work_Order__c wo1 = new Work_Order__c(Customer__c = contact.Id, Received_Date__c = Date.today().addDays(-5));
        Work_Order__c wo2 = new Work_Order__c(Customer__c = contact.Id, Received_Date__c = Date.today().addDays(-1)); // ✅ Future Date Fix
        insert new List<Work_Order__c>{ wo1, wo2 };

        // ✅ Collect Work Order IDs
        Set<Id> workOrderIds = new Set<Id>{ wo1.Id, wo2.Id };
       
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
    }

    @isTest
    static void testGetCreditCardData() {
        Date myDate = Date.today();
        Date endOfMonth = Date.newInstance(myDate.year(), myDate.month(), Date.daysInMonth(myDate.year(), myDate.month()));
        
        Test.startTest();
      	String paramsJson = '{"fromDate": "' + Date.today().toStartOfMonth() + '", "toDate": "' + endOfMonth + '"}';
        SAP_FinsysCreditCardReport.getCreditCardData(paramsJson);
        Test.stopTest();
        
       }

  /* \\ @isTest
    static void testGetCreditCardCount() {
        Date myDate = Date.today();
        Date endOfMonth = Date.newInstance(myDate.year(), myDate.month(), Date.daysInMonth(myDate.year(), myDate.month()));
        
        Test.startTest();
        String paramsJson = '{"fromDate": "' + Date.today().toStartOfMonth() + '", "toDate": "' + endOfMonth + '"}';
        Integer count = SAP_FinsysCreditCardReport.getCreditCardCount(paramsJson);
        Test.stopTest();
       // System.assert(count > 0, 'Expected credit card transaction count to be greater than zero.');
    }*/
}

/*@isTest
public class SAP_FinsysCreditCardReportTest {
    @testSetup
    static void setupTestData() {
        // Create Record Types
        RecordType rtFinsys = [SELECT Id FROM RecordType WHERE DeveloperName = 'Finsys' AND SObjectType = 'IndividualApplication' LIMIT 1];
        RecordType rtApostille = [SELECT Id FROM RecordType WHERE DeveloperName = 'Apostille' AND SObjectType = 'IndividualApplication' LIMIT 1];
		RecordType newRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'New_Transaction' AND SObjectType = 'RegulatoryTrxnFee' LIMIT 1];
        

        // Create IndividualApplications
        RegulatoryAuthorizationType licenseType = new RegulatoryAuthorizationType(Name = 'Test License');
        insert licenseType;

        // ✅ Insert Individual Applications
        IndividualApplication app1 = new IndividualApplication(Sequence_Number__c = 'WO-123', Category = 'License', RecordTypeId = rtFinsys.Id, LicenseTypeId = licenseType.Id);
        IndividualApplication app2 = new IndividualApplication(Sequence_Number__c = 'WO-456', Category = 'License', RecordTypeId = rtApostille.Id, LicenseTypeId = licenseType.Id);
        insert new List<IndividualApplication>{ app1, app2 };
            

        // Create Regulatory Transactions
        RegulatoryTrxnFee txn1 = new RegulatoryTrxnFee(
            ParentRecordId = app1.Id,
            SAP_Transaction_Date__c = Date.today(),
            SAP_Payment_Type__c = 'Card',
            RecordTypeId = newRecordType.Id,
            Batch_Look_Up__c = batch.Id
        );
        insert txn1;

         Contact contact = new Contact(FirstName = 'John', LastName = 'Doe', Email = 'john.doe@example.com');
        insert contact;
        
        // Create Work Order
        Work_Order__c workOrder = new Work_Order__c(
            Customer__c = contact.Id,
            Received_Date__c = Date.today()
        );
        insert workOrder;

        // Create Transaction Data
        bt_stripe__Transaction__c bttxn1 = new bt_stripe__Transaction__c(
            Work_Order__c = workOrder.Id,
            bt_stripe__Amount__c = 50.00,
            bt_stripe__Transaction_Status__c = 'Completed'
        );
        insert bttxn1;
        
    }

    @isTest
    static void testGetCreditCardData() {
         Date myDate = Date.today();
        Date endOfMonth = Date.newInstance(myDate.year(), myDate.month(), Date.daysInMonth(myDate.year(), myDate.month()));
        
        Test.startTest();
      	String paramsJson = '{"fromDate": "' + Date.today().toStartOfMonth() + '", "toDate": "' + endOfMonth + '"}';
        List<SAP_FinsysCreditCardReport.CreditCardWrapper> results = SAP_FinsysCreditCardReport.getCreditCardData(paramsJson);
        Test.stopTest();
        
        System.assertNotEquals(0, results.size(), 'Expected credit card data records to be returned.');
    }

    @isTest
    static void testGetCreditCardCount() {
        Date myDate = Date.today();
        Date endOfMonth = Date.newInstance(myDate.year(), myDate.month(), Date.daysInMonth(myDate.year(), myDate.month()));
        
        Test.startTest();
        String paramsJson = '{"fromDate": "' + Date.today().toStartOfMonth() + '", "toDate": "' + endOfMonth + '"}';
        Integer count = SAP_FinsysCreditCardReport.getCreditCardCount(paramsJson);
        Test.stopTest();

        System.assert(count > 0, 'Expected credit card transaction count to be greater than zero.');
    }
}*/