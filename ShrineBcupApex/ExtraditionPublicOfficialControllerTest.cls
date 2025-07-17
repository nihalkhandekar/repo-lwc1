@isTest
public class ExtraditionPublicOfficialControllerTest {

    @testSetup
    static void setup() {
        // Create test data for Contacts with necessary fields
        
        // Create a Contact with the 'Extradition_Official' Record Type
        RecordType extraditionRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Extradition_Official' LIMIT 1];
        
        contact contactForSignedby = new Contact(FirstName = 'Johny',
        LastName = 'Doe',
        RecordTypeId = extraditionRecordType.Id);
        insert contactForSignedby;
        
        Contact testContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            RecordTypeId = extraditionRecordType.Id,
            Prefix__c = 'Mr.',
            Start_Term__c = Date.today(),
            End_Term__c = Date.today().addYears(1),
            Position__c = 'Deputy Clerk',
            GA__c = '12',
            Indefinite_Term__c = false,
            Judicial_District__c = 'District 1',
            Seal_Stramp_of__c = 'Seal123',
            Notes__c = 'Official notes',
            SignedBy__c =contactForSignedby.id,
            
            Esquire__c = true,
            Wet_Signature__c ='No'
        );
        insert testContact;
    }

    @isTest
    static void testFetchPublicOfficialData() {
        // Retrieve the test contact inserted during setup
        Contact testContact = [SELECT Id FROM Contact WHERE FirstName = 'John' AND LastName = 'Doe' LIMIT 1];
        
        Test.startTest();
        // Call the fetchPublicOfficialData method
        Map<String, Object> result = ExtraditionPublicOfficialController.fetchPublicOfficialData(testContact.Id);
        Test.stopTest();

        // Verify that the result is not null
        System.assertNotEquals(null, result, 'Result should not be null');
        
        // Verify that the 'records' key exists in the result
        System.assert(result.containsKey('records'), 'Result should contain the "records" key');
        
        // Verify that the records list is not empty
        List<Contact> records = (List<Contact>) result.get('records');
        System.assert(records.size() > 0, 'Records list should contain at least one Contact record');
        
        // Verify that the contact data returned matches the expected values
        System.assertEquals('John', records[0].FirstName, 'First name should match');
        System.assertEquals('Doe', records[0].LastName, 'Last name should match');
    }

    @isTest
    static void testUpdatePublicOfficialData() {
        // Retrieve the test contact inserted during setup
        Contact testContact = [SELECT Id, FirstName, LastName FROM Contact WHERE FirstName = 'John' AND LastName = 'Doe' LIMIT 1];
        
        // Modify the contact data
        testContact.Notes__c = 'Updated notes';
        
        Test.startTest();
        // Call the updatePublicOfficialData method to upsert the contact
        Id updatedContactId = ExtraditionPublicOfficialController.updatePublicOfficialData(testContact);
        Test.stopTest();

        // Verify that the contact was successfully updated
        Contact updatedContact = [SELECT Id, Notes__c FROM Contact WHERE Id = :updatedContactId LIMIT 1];
        System.assertEquals('Updated notes', updatedContact.Notes__c, 'Notes should be updated');
    }

    @isTest
    static void testUpdatePublicOfficialDataWithoutId() {
        
        
        
        // Create a new contact without setting the ID
        Contact newContact = new Contact(
            FirstName = 'Jane',
            LastName = 'Doe',
            Prefix__c = 'Ms.',
            Start_Term__c = Date.today(),
            End_Term__c = Date.today().addYears(1),
            
            GA__c = '12',
            Indefinite_Term__c = false,
            Judicial_District__c = 'District 2',
            Seal_Stramp_of__c = 'Seal456',
            Notes__c = 'New contact notes',
            
            Esquire__c = true,
            Wet_Signature__c = 'No'
        );
        insert newContact;
        
        Test.startTest();
        // Call the updatePublicOfficialData method to create the new contact
        Id newContactId = ExtraditionPublicOfficialController.updatePublicOfficialData(newContact);
        Test.stopTest();

        // Verify that the new contact was created and has an ID
        Contact createdContact = [SELECT Id, Notes__c FROM Contact WHERE Id = :newContactId LIMIT 1];
        System.assertNotEquals(null, createdContact.Id, 'New contact should have an ID');
        System.assertEquals('New contact notes', createdContact.Notes__c, 'New contact should have the correct notes');
    }

    @isTest
    static void testExceptionHandling() {
        try {
            // Call the method with invalid data that will throw an exception
            ExtraditionPublicOfficialController.updatePublicOfficialData(null);
            System.assert(false, 'An exception should have been thrown');
        } catch (AuraHandledException e) {
            // Verify that the exception is handled correctly
            system.debug(e);
            System.assert(e.getMessage().contains('Script-thrown exception'), 'The exception message should be as expected');
        }
    }
    
    @isTest
    static void testfetchPublicOfficialData1() {
        Test.startTest();
        try {
            Map<String, Object> result = ExtraditionPublicOfficialController.fetchPublicOfficialData(null);
        }
        catch(Exception e) {
            
        }
        Test.stopTest();
    }
    
    @isTest 
    static void testUpdatePublicOfficialData1() {
        Contact con = new Contact(FirstName = 'Test', LastName = 'User');
        Test.startTest();
        Id result = ExtraditionPublicOfficialController.updatePublicOfficialData(con);
        Test.stopTest();
    }
}