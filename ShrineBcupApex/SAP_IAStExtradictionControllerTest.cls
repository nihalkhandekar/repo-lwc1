@isTest
private class SAP_IAStExtradictionControllerTest {
    @testSetup
    static void setupTestData() {
        RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'State Extraditions' LIMIT 1];
       RegulatoryAuthorizationType licenseType = TestDataFactory.createTestLicenseType();
        
        
   
        IndividualApplication app1 = new IndividualApplication(
            SAP_First_Name__c = 'John',
            SAP_Last_Name__c = 'Doe',
            SAP_Extradicted_From__c = 'State A',
            SAP_Extradicted_File_Number__c = '12345',
            Received_for_filling_with_Governor_s_Act__c = Date.today(),
            SAP_Office__c= 'Office1',
            RecordTypeId = rt.Id,
            LicenseTypeId = licenseType.Id
        );
        
        IndividualApplication app2 = new IndividualApplication(
            SAP_First_Name__c = 'Jane',
            SAP_Last_Name__c = 'Smith',
            SAP_Extradicted_From__c = 'State B',
            SAP_Extradicted_File_Number__c = '67890',
            Received_for_filling_with_Governor_s_Act__c = Date.today().addDays(-10),
            SAP_Office__c = 'Office2',
            RecordTypeId = rt.Id,
           LicenseTypeId = licenseType.Id
        );
        insert new List<IndividualApplication>{app1, app2};
    }
    
    @isTest
    static void testGetStateExtradictionApplications() {
        Test.startTest();
        Map<String, Object> searchParams = new Map<String, Object>{
            'firstName' => 'John',
            'lastName' => 'Doe',
            'extradictedFrom' => 'State A',
            'extradictedFileNo' => '12345',
            'office' => 'Office1',
            'pageSize' => 10,
            'offsetVal' => 0,
            'sortField' => 'CreatedDate',
            'sortDirection' => 'DESC',
            'toDate' =>'2025-12-31',
            'fromDate' =>'2025-01-01'
                
        };
        
        Map<String, Object> result = SAP_IAStExtradictionController.getStateExtradictionApplications(searchParams);
        List<Map<String, Object>> records = (List<Map<String, Object>>) result.get('records');
        System.debug(' records==='+ records);
        Integer count = (Integer) result.get('count');
        System.debug(' count==='+ count);
        
       
        Test.stopTest();
        
        System.assertNotEquals(records, null, 'Records should not be null');
        System.assert(records.size() > 0, 'There should be at least one record returned');
        System.assertEquals(count, records.size(), 'Count should match records size');

    }
    
    @isTest
    static void testWithPagination() {
        Test.startTest();
        Map<String, Object> searchParams = new Map<String, Object>{
            'pageSize' => 1,
            'offsetVal' => 1
        };
        
        Map<String, Object> result = SAP_IAStExtradictionController.getStateExtradictionApplications(searchParams);
        List<Map<String, Object>> records = (List<Map<String, Object>>) result.get('records');
        Integer count = (Integer) result.get('count');
        
        Test.stopTest();
        
        System.assertNotEquals(records, null, 'Records should not be null');
        System.assertEquals(records.size(), 1, 'Should return only 1 record as per pagination');
        System.assert(count >= records.size(), 'Total count should be greater than or equal to the records returned');

    }
    
    @isTest
    static void testEmptyResult() {
        Test.startTest();
        Map<String, Object> searchParams = new Map<String, Object>{
            'firstName' => 'NonExistent'
        };
        
        Map<String, Object> result = SAP_IAStExtradictionController.getStateExtradictionApplications(searchParams);
        List<Map<String, Object>> records = (List<Map<String, Object>>) result.get('records');
        Integer count = (Integer) result.get('count');
        
       
        Test.stopTest();
        
        System.assertNotEquals(records, null, 'Records should not be null');
        System.assertEquals(records.size(), 0, 'No records should be returned for a non-existent name');
        System.assertEquals(count, 0, 'Count should be 0 when no records exist');
    }
    
    
}