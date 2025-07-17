@isTest
public class SAP_LoadPaymentDataControllerTest {

    // Test for loadPaymentData method
    @isTest
    public static void testLoadPaymentData() {
        
        RegulatoryAuthorizationType licenseType = new RegulatoryAuthorizationType(Name = 'Test License');
        insert licenseType;
        
        IndividualApplication app = new IndividualApplication(
            LicenseTypeId = licenseType.Id,
            SAP_First_Name__c = 'John', 
            SAP_Last_Name__c = 'Doe',
            SAP_Email_Address__c = 'john.doe@example.com',
            Category='License'
        );
        insert app;

        
        Test.startTest();
        Map<String, Object> result = SAP_LoadPaymentDataController.loadPaymentData(app.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.containsKey('records'), 'Result should contain key "records"');
        System.assert(result.containsKey('totalFees'), 'Result should contain key "totalFees"');
       

    }

    // Test for loadPreviousPayment method
   @isTest
   public static void testLoadPreviousPayment() {
    
    
    RegulatoryAuthorizationType licenseType = new RegulatoryAuthorizationType(Name = 'Test License');
    insert licenseType;
    
    IndividualApplication app = new IndividualApplication(
        LicenseTypeId = licenseType.Id,
        SAP_First_Name__c = 'John', 
        SAP_Last_Name__c = 'Doe',
        SAP_Email_Address__c = 'john.doe@example.com',
        Category = 'License'
    );
    insert app;

   
    RegulatoryTrxnFee fee = new RegulatoryTrxnFee(
        ParentRecordId = app.Id,
        SAP_Payment_Type__c = 'Card',
        SAP_Card_Number__c = Decimal.valueOf('1234567890123456'),
        SAP_Auth_Code__c = 'AUTH123',
        Status = 'DRAFT'
       
    );
    insert fee;

    
    fee = [SELECT Id, TotalFeeAmount FROM RegulatoryTrxnFee WHERE Id = :fee.Id LIMIT 1];
    
    
    Test.startTest();
    Map<String, Object> result = SAP_LoadPaymentDataController.loadPreviousPayment(app.Id);
    Test.stopTest();
       
    System.assertNotEquals(null, result, 'Result should not be null');
    System.assert(result.containsKey('records'), 'Result should contain key "records"');
    System.assert(result.containsKey('totalAmount'), 'Result should contain key "totalAmount"');
    

    
}

    /* Test for createNewRegulatoryTrxnFee method
    @isTest
    public static void testCreateNewRegulatoryTrxnFee() {
    
    RegulatoryAuthorizationType licenseType = new RegulatoryAuthorizationType(Name = 'Test License');
    insert licenseType;
    
    IndividualApplication app = new IndividualApplication(
        LicenseTypeId = licenseType.Id,
        SAP_First_Name__c = 'John', 
        SAP_Last_Name__c = 'Doe',
        SAP_Email_Address__c = 'john.doe@example.com',
        Category = 'License'
    );
    insert app;
    
    Map<String, Object> addPaymentValues = new Map<String, Object>();
    addPaymentValues.put('Payment_Type', 'Credit Card');
    addPaymentValues.put('Last_Four_digits_of_CreditCard', '1234');
    addPaymentValues.put('Payment_Amount', 150.00);

    
    Test.startTest();
    
    
    Boolean result = SAP_LoadPaymentDataController.createNewRegulatoryTrxnFee(addPaymentValues);
    
    Test.stopTest();
        
    List<RegulatoryTrxnFee> insertedFees = [SELECT Id, SAP_Payment_Type__c, TotalFeeAmount FROM RegulatoryTrxnFee WHERE ParentRecordId = :app.Id];
    System.assertEquals(1, insertedFees.size(), 'One RegulatoryTrxnFee record should be inserted');
    System.assertEquals('Credit Card', insertedFees[0].SAP_Payment_Type__c, 'Payment Type should match');
    System.assertEquals(150.00, insertedFees[0].TotalFeeAmount, 'Payment Amount should match');
   
}*/


}