@isTest
public class ApostilleIndividualApplicationDetailTest {
    
    @isTest
    static void testGetApplicationDetails() {
        RegulatoryAuthorizationType licenseType = new RegulatoryAuthorizationType(Name = 'Extradition License');
    	insert licenseType;
    
        IndividualApplication indApp = new IndividualApplication(
            Sequence_Number__c = '12345',
            First_Name__c = 'John',
            Last_Name__c = 'Doe',
            Category = 'Permit', LicenseTypeId = licenseType.Id
        );
        insert indApp;

        RegulatoryTrxnFee fee = new RegulatoryTrxnFee(
            ParentRecordId = indApp.Id,
            Auth_Code__c = 'AUTH123',
            Status = 'Draft',
            Transaction_Date__c = Date.today(),
            Payment_Method__c = 'Credit Card'
        );
        insert fee;

        RegulatoryTrxnFeeItem feeItem1 = new RegulatoryTrxnFeeItem(
            Name = 'Regulatory Transaction Fee item1',
            FeeAmount = 100,
            RegulatoryTrxnFeeId = fee.Id
        );
        RegulatoryTrxnFeeItem feeItem2 = new RegulatoryTrxnFeeItem(
            Name = 'Regulatory Transaction Fee item2',
            FeeAmount = 200,
            RegulatoryTrxnFeeId = fee.Id
        );

        insert new List<RegulatoryTrxnFeeItem>{ feeItem1, feeItem2 };
        Test.startTest();
        Map<String, String> result = ApostilleIndividualApplicationDetails.getApplicationDetails(indApp.Id);
        Test.stopTest();

        System.assertEquals('John', result.get('firstName'), 'First name should match');
        System.assertEquals('Doe', result.get('lastName'), 'Last name should match');
        System.assertEquals('12345', result.get('sequanceNumber'), 'Sequence number should match');
        System.assertEquals('AUTH123', result.get('AuthenticationCode'), 'Authentication code should match');
        System.assertEquals('300.00', result.get('TotalFees'), 'Total fees should match'); 
        System.assertEquals('Credit Card', result.get('MethodofPayment'), 'Payment method should match');
        System.assertEquals(String.valueOf(Date.today()), result.get('DateofPayment'), 'Payment date should match');
    }
}