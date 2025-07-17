@isTest
public class SAP_FinsysSettlementReportTest {
    @testSetup
    static void setupTestData() {
        
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'IndividualApplication' LIMIT 1];
        RecordType rtFinsys = [SELECT Id FROM RecordType WHERE DeveloperName = 'Finsys' AND SObjectType = 'IndividualApplication' LIMIT 1];
        RecordType rtApostille = [SELECT Id FROM RecordType WHERE DeveloperName = 'Apostille' AND SObjectType = 'IndividualApplication' LIMIT 1];
		RecordType newTransactionRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'New_Transaction' AND SObjectType = 'RegulatoryTrxnFee' LIMIT 1];
        RecordType cardRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Charge_Card' AND SObjectType = 'bt_stripe__Payment_Method__c' LIMIT 1];

		
        RegulatoryAuthorizationType licenseType = new RegulatoryAuthorizationType(Name = 'Test License');
        insert licenseType;
   
        IndividualApplication app1 = new IndividualApplication(SAP_Sequence_Number__c = 'WO-123', SAP_Work_Order_Comments__c = 'Test Comment',RecordTypeId = rtFinsys.Id,LicenseTypeId = licenseType.Id,Category='License');
        insert app1;

        IndividualApplication app2 = new IndividualApplication(SAP_Sequence_Number__c = 'WO-456', SAP_Work_Order_Comments__c = 'Another Comment', RecordTypeId = rtApostille.Id, LicenseTypeId = licenseType.Id,Category='License');
        insert app2;

        Contact contact = new Contact(FirstName = 'John', LastName = 'Doe', Email = 'john.doe@example.com');
        insert contact;
        
        // Create test RegulatoryTrxnFee records
        RegulatoryTrxnFee fee1 = new RegulatoryTrxnFee(
            ParentRecordId = app1.Id,
            SAP_Payment_Type__c = 'Card',
            SAP_Brand__c = 'Visa',
            Status = 'DRAFT',
            SAP_Transaction_Date__c = Date.today(),
            RecordTypeId=newTransactionRecordType.Id
        );
        insert fee1;
       

        RegulatoryTrxnFee fee2 = new RegulatoryTrxnFee(
            ParentRecordId = app2.Id,
            SAP_Payment_Type__c = 'Cash',
             SAP_Brand__c = 'Visa',
            Status = 'DRAFT',
            SAP_Transaction_Date__c = Date.today().addDays(-1)
        );
        insert fee2;

        // Create test Work_Order__c records
       Work_Order__c wo1 = new Work_Order__c(Customer__c = contact.Id,Received_Date__c = Date.today());
       Work_Order__c wo2 = new Work_Order__c( Customer__c = contact.Id,Received_Date__c = Date.today().addDays(-2));
        insert new List<Work_Order__c>{wo1,wo2};
        
        bt_stripe__Payment_Gateway__c testGateway = new bt_stripe__Payment_Gateway__c(Name = 'Test Gateway');
        insert testGateway;
     
        // ✅ Insert Payment Methods
        bt_stripe__Payment_Method__c visaPaymentMethod = new bt_stripe__Payment_Method__c(
            bt_stripe__Brand__c = 'Visa', 
            bt_stripe__CVV__c = '123', 
            bt_stripe__Billing_Postal_Code__c = '1234', 
            bt_stripe__Payment_Gateway__c = testGateway.Id, 
            RecordTypeId = cardRecordType.Id
        );
        insert visaPaymentMethod;

         
        bt_stripe__Transaction__c bttxn1 = new bt_stripe__Transaction__c(
            Work_Order__c = wo1.Id,
            bt_stripe__Payment_Method__c = visaPaymentMethod.Id,
            bt_stripe__Amount__c = 50.00,
            bt_stripe__Transaction_Status__c = 'Completed'
        );
        insert bttxn1;
        
    }

    @isTest
    static void testGetSettlementData() {
        String paramsJson = '{"transactionType":"Card","workOrder":"","receivedBy":"Jay","checkMoneyOrder":"","dateCreated":"' + String.valueOf(Date.today()) + '","amount":null,"transactionFromDate":"' + String.valueOf(Date.today()) + '","transactionToDate":"' + String.valueOf(Date.today()) + '","sortedBy":"Date","sortedDirection":"desc","currentPage":1,"pageSize":20}';
        
        Test.startTest();
        List<Map<String, Object>> results = SAP_FinsysSettlementReport.getSettlementData(paramsJson);
        Test.stopTest();
        
 		System.assertEquals(1, results.size(), 'Expected one Record in the result set.');    
    }

  @isTest
    static void testGetSettlementCount() {
       String paramsJson = '{"transactionType":"Card","workOrder":"","receivedBy":"Jay","checkMoneyOrder":"","dateCreated":"' + String.valueOf(Date.today()) + '","amount":null,"transactionFromDate":"' + String.valueOf(Date.today()) + '","transactionToDate":"' + String.valueOf(Date.today()) + '"}';
        
        Test.startTest();
        Integer count = SAP_FinsysSettlementReport.getSettlementCount(paramsJson);
        Test.stopTest();

       System.assert(count > 0, 'Settlement count should be greater than zero');
    }
	
     @isTest
    static void testGetFilteredSettlementData() {
        // Prepare input parameters
        String transactionType = 'Card';
        String workOrder = '';
        String receivedBy = 'Jay';
        String checkMoneyOrder = '';
        Date fromDate = Date.today().addDays(-1);
        Date toDate = Date.today();
        String sortBy = 'Date';
        String sortDirection = 'desc';        

        Test.startTest();
       	List<Map<String, Object>> results = SAP_FinsysSettlementReport.getFilteredSettlementData(
            transactionType, workOrder, receivedBy, checkMoneyOrder, fromDate, toDate, sortBy, sortDirection
        );
        Test.stopTest();
        
        System.assertEquals(1, results.size(), 'Expected one Record in the result set.');    

    }
}