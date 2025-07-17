@isTest
public class SAP_FinsysWorkOrderTransactionCtrlTest {

    @TestSetup
    static void setupTestData() {
        
        RegulatoryAuthorizationType licenseType = new RegulatoryAuthorizationType(Name = 'Test License');
        insert licenseType;
      
        IndividualApplication app = new IndividualApplication(
            LicenseTypeId = licenseType.Id,
            SAP_First_Name__c = 'John',
            SAP_Last_Name__c = 'Doe',
            SAP_Work_Order_Status__c = 'In Progress',
            SAP_Sequence_Number__c = '12345',
            Category='License',
            RecordTypeId = Schema.SObjectType.IndividualApplication.getRecordTypeInfosByDeveloperName().get('FinSys').getRecordTypeId()
        );
        insert app;

        RegulatoryTrxnFee fee = new RegulatoryTrxnFee(
            ParentRecordId = app.Id,
            SAP_Payment_Type__c = 'Card',
            Status = 'DRAFT',
            SAP_Amount__c = 100.00,
            SAP_Transaction_Date__c = Date.today(),
            RecordTypeId = Schema.SObjectType.RegulatoryTrxnFee.getRecordTypeInfosByDeveloperName().get('New_Transaction').getRecordTypeId()
        );
        insert fee;

 
        RegulatoryTrxnFeeItem feeItem = new RegulatoryTrxnFeeItem(
            Name = 'TestItem',
            RegulatoryTrxnFeeId = fee.Id,
            SAP_Select_Activity__c = 'Authentication/Apostille',
            SAP_Select_Sub_Activity__c = 'Regular',
            FeeAmount = 100.00,
            RecordTypeId = Schema.SObjectType.RegulatoryTrxnFeeItem.getRecordTypeInfosByDeveloperName().get('Create_Transaction').getRecordTypeId()
        );
        insert feeItem;
        
        Contact customer = new Contact(
              FirstName = 'John',
              LastName = 'Doe',
              Email = 'johndoe@example.com'
       );
       insert customer;



        Work_Order__c workOrder = new Work_Order__c(
            Type__c = 'UCC',
            Status__c = 'Open',
            Customer__c = customer.Id
        );
        insert workOrder;
        
        bt_stripe__Payment_Method__c paymethod=new bt_stripe__Payment_Method__c(
          bt_stripe__Bank_Name__c = 'SBI',
          bt_stripe__CVV__c = '123',
          bt_stripe__Billing_Postal_Code__c = '560001'
            
        );
    

        // Create test data for bt_stripe__Transaction__c
        bt_stripe__Transaction__c testtransaction = new bt_stripe__Transaction__c(
            Work_Order__c = workOrder.Id,
            bt_stripe__Amount__c = 100.00,
            bt_stripe__Payment_Method__c = paymethod.Id
        );
        insert testtransaction;
    }

    @isTest
    static void testGetWorkOrderApplication() {
        // Prepare test data
        IndividualApplication app = [SELECT Id FROM IndividualApplication LIMIT 1];
        Map<String, Object> params = new Map<String, Object>{
            'worecordType' => 'FinSys',
            'firstName' => 'John',
            'lastName' => 'Doe',
            'workOrderNumber' => '12345',
            'workOrderStatus' => 'In-Progress',
            'paymentType' => 'Card',
            'transactionAmount' => '100.00',
            'transactionDate' => String.valueOf(Date.today()),
            'transaction2Date' => String.valueOf(Date.today()),
            'transactionFromDate' => String.valueOf(Date.today()),
            'transactionToDate' => String.valueOf(Date.today()),
            'sortBy' => 'firstName',
            'sortDirection' => 'ASC',
            'offsetVal' => 0,
            'pageSize' => 10
        };
        String paramsJson = JSON.serialize(params);

        
        Test.startTest();
        SAP_FinsysWorkOrderTransactionController.WorkOrderWrapper wrapper = SAP_FinsysWorkOrderTransactionController.getWorkOrderApplication(paramsJson);
        Test.stopTest();

    }

    @isTest
    static void testGetApplicationsCount() {
        // Prepare test data
        Map<String, Object> params = new Map<String, Object>{
            'worecordType' => 'FinSys',
            'firstName' => 'John',
            'lastName' => 'Doe',
            'workOrderNumber' => '12345',
            'workOrderStatus' => 'Pending',
            'paymentType' => 'Credit Card',
            'transactionAmount' => '100.00',
            'transactionDate' => String.valueOf(Date.today()),
            'transaction2Date' => String.valueOf(Date.today()),
            'transactionFromDate' => String.valueOf(Date.today()),
            'transactionToDate' => String.valueOf(Date.today())
            
        };
        String paramsJson = JSON.serialize(params);

     
        Test.startTest();
        Integer count = SAP_FinsysWorkOrderTransactionController.getApplicationsCount(paramsJson);
        Test.stopTest();

    }

    @isTest
    static void testGetRecordCounts() {
        // Prepare test data
        Map<String, Object> params = new Map<String, Object>{
            'worecordType' => 'FinSys',
            'firstName' => 'John',
            'lastName' => 'Doe',
            'workOrderNumber' => '12345',
            'workOrderStatus' => 'Pending',
            'paymentType' => 'Card',
            'transactionAmount' => '100.00',
            'transactionDate' => String.valueOf(Date.today()),
            'transaction2Date' => String.valueOf(Date.today()),
            'transactionFromDate' => String.valueOf(Date.today()),
            'transactionToDate' => String.valueOf(Date.today()),
            'sortBy' => 'SAP_Transaction_Date__c'
        };
        String paramsJson = JSON.serialize(params);

        Test.startTest();
        Map<String, Integer> counts = SAP_FinsysWorkOrderTransactionController.getRecordCounts(paramsJson);
        Test.stopTest();

    }

    @isTest
    static void testGetEmailData() {
       
        IndividualApplication app = [SELECT Id FROM IndividualApplication LIMIT 1];
        Map<String, Object> inputParams = new Map<String, Object>{
            'recordId' => app.Id
        };
        String jsonRequest = JSON.serialize(inputParams);

        Test.startTest();
        Map<String, Object> emailData = SAP_FinsysWorkOrderTransactionController.getEmailData(jsonRequest);
        Test.stopTest();

    }
}