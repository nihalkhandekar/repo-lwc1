@isTest
public class SAP_FinsysRefundControllerTest {
    
    @TestSetup
    static void setupTestData() {
       
           RecordType appRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'FinSys' AND  SObjectType = 'IndividualApplication' LIMIT 1];
           RecordType feeRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Refund_Transaction' AND  SObjectType = 'RegulatoryTrxnFee' LIMIT 1];
          
            RegulatoryAuthorizationType licenseType = new RegulatoryAuthorizationType(Name = 'Test License');
            insert licenseType;
            
           
           IndividualApplication app = new IndividualApplication(
            RecordTypeId = appRecordType.Id,
            SAP_First_Name__c = 'John',
            SAP_Last_Name__c = 'Doe',
            SAP_Sequence_Number__c = 'WO12345',
            LicenseTypeId=licenseType.Id,
            Category = 'License'
        );
        insert app;
        
        // Create Regulatory Transaction Fee
        RegulatoryTrxnFee fee = new RegulatoryTrxnFee(
            RecordTypeId = feeRecordType.Id,
            ParentRecordId = app.Id,
            SAP_Refund_ID__c = 'REF123',
            SAP_Refund_Reason__c = 'Duplicate Payment',
            SAP_Payment_Type__c = 'Card',
            SAP_Transaction_Status__c = 'Refunded',
            Status='DRAFT'
        );
        insert fee;
        
        System.debug(app.Id+','+fee.Id);
        
        RegulatoryTrxnFeeItem feeItem = new RegulatoryTrxnFeeItem(
        Name = 'Test Fee Item', 
        RegulatoryTrxnFeeId = fee.Id, 
        FeeAmount = 50.00 
        );
        insert feeItem;
            
    }

    @isTest
    static void testGetWorkOrderApplication() {
        
            
            String paramsJson = '{"refundId":"REF123","rejectionReason":"Duplicate Payment",'+
                '"refundMethod":"Card","status":"Refunded",'+
                '"amountRangeStart":"10.00","amountRangeEnd":"100.00","refundAmount":"50.00",'+
                '"refundDate":""}';
            Test.startTest();
            SAP_FinsysRefundController.getWorkOrderApplication(paramsJson);
            Test.stopTest();
      
    }

   /* @IsTest
    static void testGetApplicationsCount() {
        
      
            Test.startTest();
          
           String params = new Map<String, Object>{
                'firstName' => 'John',
                'lastName' => 'Doe',
                'refundId' => 'RFD-001'
            };
            Test.startTest();
            SAP_FinsysRefundController.getApplicationsCount(v);
            Test.stopTest();
       
    }*/
}