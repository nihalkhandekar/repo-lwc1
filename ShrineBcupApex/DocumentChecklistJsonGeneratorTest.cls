@isTest
public class DocumentChecklistJsonGeneratorTest {

    @testSetup
    static void setupTestData() {
        RegulatoryAuthorizationType authType = new RegulatoryAuthorizationType(Name = 'Test Regulatory Authorization Type');
        insert authType;

        IndividualApplication app = new IndividualApplication(
            ParentApplicationId = null,
            AppliedDate = System.now(),
            Status = 'Draft',
            Destination__c = 'Test Destination',
            Category = 'License',
            LicenseTypeId = authType.Id
        );
        insert app;

        // Create a few test Document Checklist Items
        List<DocumentChecklistItem> checklistItems = new List<DocumentChecklistItem>();
        for (Integer i = 1; i <= 3; i++) {
            DocumentChecklistItem item = new DocumentChecklistItem(
                Name = 'Checklist Item ' + i,
                ParentRecordId = app.Id,
                country__c = 'USA',
                Fees__c = 100 * i,
                Hague_Status__c = 'Yes'
            );
            checklistItems.add(item);
        }
        insert checklistItems;

        // Create a Contact with the specified Record Type
        RecordType recordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Apostille_Official' AND SObjectType = 'Contact' LIMIT 1];

        Contact contact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Start_Term__c = Date.today(),
            End_Term__c = Date.today().addYears(1),
            Indefinite_Term__c = false,
            Position__c = 'Chief Clerk',
            RecordTypeId = recordType.Id
        );
        insert contact;
    }

    @isTest
    static void testGenerateJsonFromChecklistItemsByParentId() {
        // Retrieve the test Individual Application ID
        IndividualApplication app = [SELECT Id FROM IndividualApplication LIMIT 1];
        List<DocumentChecklistJsonGenerator.IdInput> idInputs = new List<DocumentChecklistJsonGenerator.IdInput>();

        DocumentChecklistJsonGenerator.IdInput input = new DocumentChecklistJsonGenerator.IdInput();
        input.individualApplicationId = app.Id;
        idInputs.add(input);

        // Call the invocable method and assert results
        List<DocumentChecklistJsonGenerator.JsonOutput> result = DocumentChecklistJsonGenerator.generateJsonFromChecklistItemsByParentId(idInputs);

        System.assert(!result.isEmpty(), 'The result should not be empty');
        System.assertNotEquals(null, result[0].jsonData, 'JSON data should be generated');
        System.assert(result[0].jsonData.contains('Checklist Item'), 'The JSON output should contain Checklist Item data');
    }

    @isTest
    static void testGenerateJsonFromChecklistItemsByParentIdLwc() {
        // Retrieve the test Individual Application ID
        IndividualApplication app = [SELECT Id FROM IndividualApplication LIMIT 1];

        // Call the AuraEnabled method for LWC
        String jsonData = DocumentChecklistJsonGenerator.generateJsonFromChecklistItemsByParentIdLwc(app.Id);

        System.assertNotEquals(null, jsonData, 'JSON data should be generated');
        System.assert(jsonData.contains('Checklist Item'), 'The JSON output should contain Checklist Item data');
    }

    @isTest
    static void testSearchContacts() {
        // Search for a contact using the searchContacts method
        List<Contact> contacts = DocumentChecklistJsonGenerator.searchContacts('John');

        System.assert(!contacts.isEmpty(), 'The search should return contacts');
        System.assertEquals(1, contacts.size(), 'The search should return exactly one contact');
        System.assertEquals('John Doe', contacts[0].Name, 'The contact name should be John Doe');
    }

    @isTest
    static void testInvalidIndividualApplicationId() {
        // Test with an invalid Individual Application ID
        List<DocumentChecklistJsonGenerator.IdInput> idInputs = new List<DocumentChecklistJsonGenerator.IdInput>();

        DocumentChecklistJsonGenerator.IdInput input = new DocumentChecklistJsonGenerator.IdInput();
        input.individualApplicationId = 'InvalidId';
        idInputs.add(input);

        // Call the invocable method with an invalid ID
        List<DocumentChecklistJsonGenerator.JsonOutput> result = DocumentChecklistJsonGenerator.generateJsonFromChecklistItemsByParentId(idInputs);

        // Validate that no results are returned due to the invalid ID
        System.assert(result.isEmpty(), 'The result should be empty for an invalid ID');
    }
}