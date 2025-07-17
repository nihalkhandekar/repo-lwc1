@isTest
public class InHousePublicOfficialControllerTest {

    private static Id recordTypeId;
    
    @testSetup
    static void setupTestData() {
        recordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Apostille_Official' LIMIT 1].Id;
        List<Contact> contacts = new List<Contact>{
            new Contact(
                FirstName = 'John',
                LastName = 'Doe',
                Position__c = 'Assistant Clerk',
                Town__c = 'Springfield',
                Start_Term__c = Date.newInstance(2025, 1, 1),
                End_Term__c = Date.newInstance(2029, 1, 1),
                Indefinite_Term__c = true,
                RecordTypeId = recordTypeId
            ),
            new Contact(
                FirstName = 'John',
                LastName = 'Doe',
                Position__c = 'Assistant Clerk',
                Town__c = 'Springfield',
                Start_Term__c = Date.newInstance(2025, 1, 1),
                End_Term__c = Date.newInstance(2029, 1, 1),
                Indefinite_Term__c = false,
                RecordTypeId = recordTypeId
            )
        };

        insert contacts;
    }

    @isTest
    static void testGetPublicOfficial() {
        List<String> testParams = new List<String>{
            '{"lastname":"Doe","firstname":"John","position":"Assistant Clerk","Town__c":"Springfield","Indefinite_Term__c":true,"termstart":"2025-01-01","termend":"2024-12-31","town":"Springfield","transactionFromDate":"2025-01-01","transactionToDate":"2024-12-31","offsetVal":0,"pageSize":10,"sortBy":"LastName","sortDirection":"ASC"}',
            '{"lastname":"Doe","firstname":"John","position":"Assistant Clerk","Town__c":"Springfield","Indefinite_Term__c":false,"termstart":null,"termend":"2024-12-31","town":"Springfield","transactionFromDate":"2025-01-01","transactionToDate":"2024-12-31","offsetVal":0,"pageSize":10,"sortBy":"LastName","sortDirection":"ASC"}',
            '{"lastname":"Doe","firstname":"John","position":"Assistant Clerk","Town__c":"Springfield","termstart":"2025-01-01","termend":null,"town":"Springfield","transactionFromDate":"2025-01-01","transactionToDate":"2024-12-31","offsetVal":0,"pageSize":10,"sortBy":"LastName","sortDirection":"ASC"}',
            '{"lastname":"Doe","firstname":"Jane","position":"Assistant Clerk","Town__c":"Springfield","termstart":"2025-01-01","termend":null,"town":"Springfield","transactionFromDate":"2024-12-31","transactionToDate":"2024-12-31","offsetVal":0,"pageSize":10,"sortBy":"LastName","sortDirection":"ASC"}'
        };

        Test.startTest();
        for (String params : testParams) {
            List<Map<String, Object>> result = InHousePublicOfficialController.getPublicOfficial(params);
            Integer result1 = InHousePublicOfficialController.getPublicOfficialCount(params);
            System.assertNotEquals(null, result, 'Result should not be null');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetPublicOfficialWithSpecificFilters() {
        String paramsJson = '{"lastname":"Doe","firstname":"John","position":"Assistant Clerk","town":"Springfield","termstart":"2025-01-01","termend":"2029-01-01","transactionFromDate":"2025-01-01","transactionToDate":"2029-01-01","offsetVal":0,"pageSize":10,"sortBy":"LastName","sortDirection":"ASC"}';
        Test.startTest();
        List<Map<String, Object>> result = InHousePublicOfficialController.getPublicOfficial(paramsJson);
        System.assertNotEquals(null, result, 'Result should not be null');
        Test.stopTest();
    }
    
    @isTest 
    static void testDeleteContact() {
        Contact con = [SELECT Id FROM Contact WHERE FirstName = 'John' LIMIT 1];
        Test.startTest();
        InHousePublicOfficialController.deleteContact(con.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testFetchPublicOfficialData() {
        Contact con = [SELECT Id FROM Contact WHERE FirstName = 'John' LIMIT 1];
        Test.startTest();
        Map<String, Object> result = InHousePublicOfficialController.fetchPublicOfficialData(con.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testUpdatePublicOfficialData() {
        Contact con = [SELECT Id FROM Contact WHERE FirstName = 'John' LIMIT 1];
        Test.startTest();
        Id result = InHousePublicOfficialController.updatePublicOfficialData(con);
        Test.stopTest();
    }
    
    @isTest
    static void testProcessNameFieldHistory() {
        String recordId = String.valueOf([SELECT Id FROM Contact WHERE FirstName = 'John' LIMIT 1].Id);
        Test.startTest();
        List<Map<String, Object>> result = InHousePublicOfficialController.processNameFieldHistory(recordId);
        Test.stopTest();
    }

    
}