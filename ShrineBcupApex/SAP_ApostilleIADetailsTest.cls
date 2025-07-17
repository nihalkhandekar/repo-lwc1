@isTest
public class SAP_ApostilleIADetailsTest {
    
    @testSetup
    static void setupTestData() {
        
        RegulatoryAuthorizationType licenseType = new RegulatoryAuthorizationType(Name = 'Test License');
        insert licenseType;
       
        IndividualApplication indApp = new IndividualApplication(
            LicenseTypeId = licenseType.Id,
            SAP_First_Name__c = 'John',
            SAP_Last_Name__c = 'Doe',
            Category='License'            
        );
        insert indApp;

        
        RegulatoryTrxnFee fee = new RegulatoryTrxnFee(
            ParentRecordId = indApp.Id,
            SAP_Auth_Code__c = 'AUTH123',
            SAP_Transaction_Date__c = Date.today(),
            SAP_Payment_Type__c = 'Card',
            SAP_Card_Number__c = 1234,
            SAP_Brand__c = 'Visa',
            Status = 'DRAFT'
            
        );
        insert fee;
    }

   @isTest
   static void testGetApplicationDetails_Success() {
       
        
        IndividualApplication testApp = [SELECT Id FROM IndividualApplication LIMIT 1];

        Test.startTest();
        Map<String, String> result = SAP_ApostilleIADetails.getApplicationDetails(testApp.Id);
        Test.stopTest();
       
        
        // Expected result map
        Map<String, String> expectedResult = new Map<String, String>{
            'firstName' => 'John',
            'lastName' => 'Doe',
            'sequanceNumber' => 'APO-202503-0001',
            'AuthenticationCode' => 'AUTH123',
            'TotalFees' => '0.00',
            'MethodofPayment' => 'Card',
            'DateofPayment' => String.valueOf(Date.today()),
            'CardLastDigit' => '1234',
            'CreditCardName' => 'Visa'
        };

        
        System.assertEquals(expectedResult, result, 'Returned application details do not match expected values');
     
    }
    
     @isTest
   static void testGetApplicationDetails_Filure() {
       RegulatoryAuthorizationType licenseType = new RegulatoryAuthorizationType(Name = 'Test License');
        insert licenseType;
        
        IndividualApplication indApp = new IndividualApplication(
            LicenseTypeId = licenseType.Id,
            SAP_First_Name__c = 'Jane',
            SAP_Last_Name__c = 'Smith',
            Category='License'            
        );
        insert indApp;

       

        Test.startTest();
        Map<String, String> result = SAP_ApostilleIADetails.getApplicationDetails(indApp.Id);
        Test.stopTest();
       
       // Expected result map when no RegulatoryTrxnFee is found
        Map<String, String> expectedResult = new Map<String, String>{
            'firstName' => 'Jane',
            'lastName' => 'Smith',
            'AuthenticationCode' => '',
            'TotalFees' => '0.00',
            'MethodofPayment' => 'Check',
            'DateofPayment' => '',
            'CardLastDigit' => '',
            'CreditCardName' => '',
            'sequanceNumber' => 'APO-202503-0002'
        };

        // Single assert statement
        System.assertEquals(expectedResult, result, 'Returned application details do not match expected values');
    
     
    }

}