@isTest
public class LegislativeControllerTest {
    @isTest
    static void testLegislativeData() {
        Contact contact1 = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Legislator_Title__c = 'Senator',
            Party__c = 'Democratic',
            DistrictID__c = 'D12345',
            RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Legislator' LIMIT 1].Id
        );
        insert contact1;
        
        Contact contact2 = new Contact(
            FirstName = 'Jane',
            LastName = 'Smith',
            Legislator_Title__c = 'Representative',
            Party__c = 'Republican',
            DistrictID__c = 'D67890',
            RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Legislator' LIMIT 1].Id
        );
        insert contact2;
        
        Map<String, Object> selectionCriteria = new Map<String, Object>{
            'firstname' => 'John',
            'lastname' => 'Doe',
            'title' => 'Senator',
            'district' => 'D12345',
            'party' => 'Democrat',
            'pageSize' => 10,
            'pageNumber' => 1,
            'sortedBy' => 'LastName',
            'sortedDirection' => 'ASC'
        };
        String selectionCriteriaJson = JSON.serialize(selectionCriteria);
        Test.startTest();
        List<Contact> result = LegislativeController.legislativeData(selectionCriteriaJson);
        Integer result1 = LegislativeController.getlegislativeDataCount(selectionCriteriaJson);
        Test.stopTest();
    }
    
    @istest
    static void testLegislativeDataException() {
        Test.startTest();
        try {
            List<Contact> result = LegislativeController.legislativeData('invalid json format'); 
            Test.stopTest();
        } catch (AuraHandledException e) {
           
        }
    }
    
    @istest
    static void testgetLegislativeDataCountException() {
        Test.startTest();
        try {
            Integer result1 = LegislativeController.getlegislativeDataCount('invalid Json format');
            Test.stopTest();
        } catch (AuraHandledException e) {
           
        }
    }
    
    @istest
    static void testgetLegislativeDataCountException1() {
        Map<String, Object> selectionCriteria = new Map<String, Object>{
            'firstname' => 'John',
            'lastname' => 'Doe',
            'title' => 'Senator',
            'district' => 'D12345',
            'party' => 'Democrat',
            'pageSize' => 10,
            'pageNumber' => 1,
            'sortedBy' => 'NonExistentField',
            'sortedDirection' => 'ASC'
        };
        String selectionCriteriaJson = JSON.serialize(selectionCriteria);
        Test.startTest();
        try {
            List<Contact> result = LegislativeController.legislativeData(selectionCriteriaJson); 
            Test.stopTest();
        } catch (AuraHandledException e) {
           
        }
    }
}