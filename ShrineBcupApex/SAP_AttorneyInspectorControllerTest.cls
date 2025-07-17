@isTest
public class SAP_AttorneyInspectorControllerTest {
    
    @testSetup
    static void setupTestData() {
        // Use TestDataFactory to create a test Contact
        TestDataFactory.createTestAttorneyContact();
    }
    
    @isTest
    static void testGetAttorneyRecord() {
        Test.startTest();
        
        String paramsJson = '{"lastname":"Doe","firstname":"John","middlename":"A","phonenumber":"1234567890","offsetVal":0,"pageSize":10,"sortBy":"LastModifiedDate","sortDirection":"DESC"}';
        List<Map<String, Object>> result = SAP_AttorneyInspectorController.getAttorneyRecord(paramsJson);
        
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.size() > 0, 'There should be at least one record returned');
    }
    
    @isTest
    static void testGetAttorneyRecordCount() {
        Test.startTest();
        
        String paramsJson = '{"lastname":"Doe","firstname":"John","middlename":"A","phonenumber":"1234567890"}';
        Integer count = SAP_AttorneyInspectorController.getAttorneyRecordCount(paramsJson);
        
        Test.stopTest();
        
        System.assert(count > 0, 'Count should be greater than zero');
    }
}