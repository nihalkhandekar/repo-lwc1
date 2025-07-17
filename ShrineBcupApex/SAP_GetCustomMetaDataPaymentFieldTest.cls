@isTest
public class SAP_GetCustomMetaDataPaymentFieldTest {
    @isTest
    static void testGetPaymentGateways() {
        Test.startTest();
        List<Application_Switch__mdt> result = SAP_GetCustomMetaDataPaymentField.getPaymentGateways();
        Test.stopTest();
		
        System.assertNotEquals(null, result, 'Result should not be null');
        
    }
}