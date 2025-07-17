@IsTest
public class SAP_ExtrPublicOfficialControllerTest{

    @testSetup
    static void setupTestData() {
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName  = 'Official',
            SAP_Prefix__c = 'Mr.',
            SAP_Suffix__c = 'Jr.'
        );
        insert testContact;
    }

    @IsTest
    static void testFetchPublicOfficialData() {
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];

        Test.startTest();
        Map<String, Object> resultMap = SAP_ExtraditionPublicOfficialController.fetchPublicOfficialData(testContact.Id);
        Test.stopTest();

        System.assertNotEquals(null, resultMap, 'Result map should not be null');
        System.assert(resultMap.containsKey('records'), 'Result map should contain the "records" key');
        
        List<Contact> contacts = (List<Contact>) resultMap.get('records');
        System.assertNotEquals(0, contacts.size(), 'Contacts list should not be empty');
        System.assertEquals(testContact.Id, contacts[0].Id, 'Returned contact ID should match the test contact ID');
    }

     @IsTest
     static void testFetchPublicOfficialData_NullId() {
         try {
             
              SAP_ExtraditionPublicOfficialController.fetchPublicOfficialData(null);
              System.assert(false, 'Expected an AuraHandledException but did not get one');
             
             } catch (AuraHandledException e) {
                 
        String errorMessage = e.getMessage();
        
        Boolean isValidMessage = errorMessage.contains('Record ID cannot be null') || 
                                 errorMessage.contains('Script-thrown exception');

        System.assert(isValidMessage, 
                      'Exception message should indicate that the Record ID is required. Actual: ' + errorMessage);
    }
}


    @IsTest
    static void testUpdatePublicOfficialData_Insert() {
        Contact newContact = new Contact(
            FirstName = 'New',
            LastName  = 'Official'
        );

        Test.startTest();
        Id newId = SAP_ExtraditionPublicOfficialController.updatePublicOfficialData(newContact);
        Test.stopTest();

        System.assertNotEquals(null, newId, 'Inserted Contact ID should not be null');

        Contact insertedContact = [SELECT Id, FirstName, LastName FROM Contact WHERE Id = :newId LIMIT 1];
        System.assertEquals('New', insertedContact.FirstName, 'Inserted Contact First Name should match');
        System.assertEquals('Official', insertedContact.LastName, 'Inserted Contact Last Name should match');
    }
}