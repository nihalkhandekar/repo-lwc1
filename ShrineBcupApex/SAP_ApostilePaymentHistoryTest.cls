@isTest
public class SAP_ApostilePaymentHistoryTest {
    @TestSetup
    static void setupTestData() {
        
        RecordType recordType = [SELECT Id FROM RecordType WHERE SObjectType = 'RegulatoryTrxnFee' limit 1];

       
        RegulatoryAuthorizationType licenseType = new RegulatoryAuthorizationType(
            	Name = 'Test License'     
        );
        insert licenseType;

      
        IndividualApplication testApplication = new IndividualApplication(
            SAP_Sequence_Number__c = 'WO-12345',
            SAP_First_Name__c = 'John',
            SAP_Last_Name__c = 'Doe',
            LicenseTypeId = licenseType.Id,   
            Category = 'License'
        );
        insert testApplication;

      
        RegulatoryTrxnFee testTransaction = new RegulatoryTrxnFee(
            SAP_Transaction_Date__c = Date.today(),
            SAP_Auth_Code__c = 'AUTH123',
            Status = 'DRAFT',
            SAP_Card_Number__c = 1234,  
            SAP_Brand__c = 'Visa',
            SAP_Transaction_Status__c = 'Approved',
            SAP_Credit_Card_Owner__c = 'John Doe',
            SAP_Payment_Type__c = 'Card',
            ParentRecordId = testApplication.Id,
            RecordTypeId = recordType.Id
        );
        insert testTransaction;

       
        RegulatoryTrxnFeeItem testFeeItem = new RegulatoryTrxnFeeItem(
            Name = 'Test Fee Item',
            RegulatoryTrxnFeeId = testTransaction.Id,
            FeeAmount=1000
        );
        insert testFeeItem;
    }
    @isTest
    static void testGetTransaction() {
 
    Map<String, Object> params = new Map<String, Object>{
        'sortBy' => 'TransactionDate',
        'sortDirection' => 'ASC',
        'offsetVal' => 0,
        'pageSize' => 10
    };
    String paramsJson = JSON.serialize(params);

    Test.startTest();
    List<Map<String, Object>> results = SAP_ApostilePaymentHistory.getTransaction(paramsJson);
    Test.stopTest();
        
    
    System.assertEquals(1, results.size(), 'Expected one transaction record to be returned.');
    System.assertEquals('John Doe', results[0].get('CreditCardName'), 'Credit card name should match the test data.');

    }
    
     @isTest
    static void getTransactionCount(){
        Test.startTest();
        Integer count= SAP_ApostilePaymentHistory.getTransactionCount();
        Test.stopTest();
        
        System.assertEquals(1, count, 'Expected one transaction record count.');
    }
    

    
}