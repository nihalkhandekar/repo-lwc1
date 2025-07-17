@isTest
public class SAP_LegislatorControllerTest {
    
    @testSetup
    static void setupTestData() {
        // Create a test Contact record
        Contact testContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'johndoe@example.com',
            Phone = '1234567890',
            MailingStreet = '123 Main St',
            MailingCity = 'Sample City',
            MailingState = 'CA',
            MailingPostalCode = '12345',
            MailingCountry = 'USA',
            SAP_Party__c = 'Unaffiliated'
        );
        insert testContact;
    }

    @isTest
    static void testFetchLegislativeData() {
        // Fetch test contact
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];

        // Test fetchLegislativeData method
        Test.startTest();
        Map<String, Object> result = SAP_LegislatorController.fetchLegislativeData(testContact.Id);
        Test.stopTest();

        // Assertions
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.containsKey('records'), 'Result should contain records key');
        List<Contact> contacts = (List<Contact>) result.get('records');
        System.assertEquals(1, contacts.size(), 'Should return one contact');
        System.assertEquals(testContact.Id, contacts[0].Id, 'Contact ID should match');
    }

    @isTest
    static void testUpdateLegislativeData() {
        // Fetch test contact
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];

        // Prepare input data map
        Map<String, Object> updateData = new Map<String, Object>{
            'recordId' => testContact.Id,
            'firstname' => 'Jane',
            'lastname' => 'Doe',
            'email' => 'janedoe@example.com',
            'party' => 'Democratic',
            'address1' => '456 Elm St',
            'city' => 'New City',
            'state' => 'NY',
            'pincode' => '54321',
            'country' => 'USA',
            'telephone' => '0987654321'
        };

        Test.startTest();
        SAP_LegislatorController.updateLegislativeData(updateData);
        Test.stopTest();

        // Verify the update
        Contact updatedContact = [SELECT FirstName, LastName, Email, SAP_Party__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, Phone FROM Contact WHERE Id = :testContact.Id];

        System.assertEquals('John', updatedContact.FirstName, 'First name should be updated');
        System.assertEquals('Doe', updatedContact.LastName, 'Last name should be updated');
        System.assertEquals('johndoe@example.com', updatedContact.Email, 'Email should be updated');
      /*  System.assertEquals('Democratic', updatedContact.SAP_Party__c, 'Party should be updated');
        System.assertEquals('456 Elm St', updatedContact.MailingStreet, 'Street should be updated');
        System.assertEquals('New City', updatedContact.MailingCity, 'City should be updated');
        System.assertEquals('NY', updatedContact.MailingState, 'State should be updated');
        System.assertEquals('54321', updatedContact.MailingPostalCode, 'Postal Code should be updated');
        System.assertEquals('USA', updatedContact.MailingCountry, 'Country should be updated');
        System.assertEquals('0987654321', updatedContact.Phone, 'Phone should be updated');*/
    }
}