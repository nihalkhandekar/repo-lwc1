@isTest
public class SAP_BatchFinsysControllerTest {
    @testSetup
    static void setupTestData() {

         RegulatoryAuthorizationType licenseType = new RegulatoryAuthorizationType(Name = 'Extradition License');
        insert licenseType;
        
         IndividualApplication app = new IndividualApplication(
            SAP_Sequence_Number__c='WO123',
            Status = 'Cancelled', LicenseTypeId = licenseType.Id, 
             Category = 'Permit', SAP_Cancellation_Type__c = 'Type A',
            SAP_Cancellation_Date__c = System.today(), 
             SAP_Reason_for_Cancellation__c = 'Test Reason', 
             AppliedDate = System.now().addDays(-1),
             RecordTypeId = Schema.SObjectType.IndividualApplication.getRecordTypeInfosByName().get('FinSys').getRecordTypeId()

        );
        insert app;
        
        // Create test Batch__C records
        Batch__c batch1 = new Batch__c(
            SAP_Batch_Name__c = 'Notary Public',
            SAP_Batch_Status__c = 'Open',
            SAP_Batch_Date__c = Date.today()
        );
        insert batch1;
        
        Batch__c batch2 = new Batch__c(
            SAP_Batch_Name__c = 'Authentication/Apostille',
            SAP_Batch_Status__c = 'Closed',
            SAP_Batch_Date__c = Date.today()
        );
        insert batch2;
        
        // Create test RegulatoryTrxnFee records
        RegulatoryTrxnFee fee1 = new RegulatoryTrxnFee(
            ParentRecordId = app.Id,
            Batch_Look_Up__c = batch1.Id,
            SAP_Payment_Type__c = 'Check',
            Status='DRAFT'
        );
        insert fee1;
        RegulatoryTrxnFee fee2 = new RegulatoryTrxnFee(
            ParentRecordId = app.Id,
            Batch_Look_Up__c = batch1.Id,
            SAP_Payment_Type__c = 'Check',
            Status='DRAFT'
        );
        insert fee2;
    }

    @isTest
    static void testGetActivityTransactionData() {

        Test.startTest();
        String searchParamsJson = '{"batchCode":"Notary Public","batchDate":"' + Date.today() + '","status":"Open","transactionCount":2,"paymentType":"Check","sortBy":"SAP_Batch_Status__c","sortDirection":"ASC","offsetVal":0,"pageSize":10}';

        Map<String, Object> result = SAP_BatchFinsysController.getActivityTransactionData(searchParamsJson);
        
        Test.stopTest();
        
        // Validate the response
        System.assert(result != null, 'Result should not be null');
        System.assert(result.containsKey('totalRecords'), 'Result should contain totalRecords');
    }
    @isTest
    static void testupdateStatus() {

        Batch__c batch = [SELECT Id FROM Batch__c WHERE  SAP_Batch_Name__c = 'Authentication/Apostille' LIMIT 1];

        Test.startTest();
        
        String result = SAP_BatchFinsysController.updateStatus(batch.Id,'Open');
        
        Test.stopTest();
        
        // Validate the response
       System.assertEquals('Success', result, 'Status update should return Success');
    }
    
}