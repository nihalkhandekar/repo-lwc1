@isTest
public class SAP_LegislativeController_Test {
    @testSetup
    static void setupTestData() {
        // Create a Record Type for Legislator
        RecordType legislatorRT=[SELECT Id FROM RecordType WHERE Name = 'Legislator' AND SObjectType = 'Contact'];
        
        // Create test contacts
        List<Contact> contacts = new List<Contact>{
            new Contact(
                FirstName = 'John',
                LastName = 'Doe',
                SAP_Party__c = 'Unaffiliated',
                SAP_DistrictID__c = 'D1',
                SAP_Legislator_Title__c = 'Senator',
                RecordTypeId = legislatorRT.Id
            ),
            new Contact(
                FirstName = 'Jane',
                LastName = 'Smith',
                SAP_Party__c = 'Democratic',
                SAP_DistrictID__c = 'D2',
                SAP_Legislator_Title__c = 'Representative',
                RecordTypeId = legislatorRT.Id
            )
        };
        insert contacts;
    }
    
    @isTest
    static void testLegislativeData() {
        // Define search criteria
        String searchCriteria = '{"firstname":"John","lastname":"Doe","party":"Unaffiliated","title":"Senator","district":"D1","pageSize":10,"pageNumber":1,"sortedBy":"LastModifiedDate","sortedDirection":"DESC"}';
        
        // Call the method
        Test.startTest();
        List<Contact> results = SAP_LegislativeController.legislativeData(searchCriteria);
        Test.stopTest();
        
        // Assert expected results
        System.assertEquals(1, results.size(), 'Should return 1 matching contact');
        System.assertEquals('John', results[0].FirstName);
        System.assertEquals('Doe', results[0].LastName);
    }
    
    @isTest
    static void testLegislativeDataCount() {
        // Define search criteria
        String searchCriteria = '{"party":"Unaffiliated","title":"Senator","district":"D1"}';
        
        // Call the method
        Test.startTest();
        Integer count = SAP_LegislativeController.getlegislativeDataCount(searchCriteria);
        Test.stopTest();
        
        // Assert expected count
        System.assertEquals(1, count, 'Should return count of 1 for matching records');
    }
}