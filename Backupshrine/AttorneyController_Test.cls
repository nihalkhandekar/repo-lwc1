@isTest
public class AttorneyController_Test {
    @testSetup
    static void setupTestData() {
        Contact testContact = new Contact(
            Salutation = 'Mr.',
            FirstName = 'John',
            MiddleName = 'A.',
            LastName = 'Doe',
            Suffix = 'Jr.',
            Phone = '123-456-7890',
            MailingStreet = '123 Main St',
            MailingCity = 'Springfield',
            MailingState = 'IL',
            MailingAddress2__c = 'Apt 101',
            MailingPostalCode = '62704',
            MailingCountry = 'USA'
        );
        insert testContact;
    }


    @isTest
    static void testUpdateAttorneyData() {
        // Arrange
        Contact existingContact = [SELECT Id FROM Contact LIMIT 1];
        Map<String, Object> updateData = new Map<String, Object>{
            'recordId' => existingContact.Id,
            'prefix' => 'Dr.',
            'firstname' => 'Jane',
            'middlename' => 'B.',
            'lastname' => 'Smith',
            'suffix' => 'Sr.',
            'phone' => '987-654-3210',
            'address1' => '456 Elm St',
            'address2' => 'Apt 3B',
            'city' => 'Metropolis',
            'state' => 'NY',
            'pincode' => '10128',
            'country' => 'USA'
        };

        Test.startTest();
        AttorneyController.updateAttorneyData(updateData);
        Test.stopTest();

        Contact updatedContact = [SELECT Salutation, FirstName, LastName, MailingCity FROM Contact WHERE Id = :existingContact.Id];
        System.assertEquals('Dr.', updatedContact.Salutation);
        System.assertEquals('Jane', updatedContact.FirstName);
        System.assertEquals('Metropolis', updatedContact.MailingCity);
    }

    @isTest
    static void testInsertAttorneyData() {
        Map<String, Object> newData = new Map<String, Object>{
            'prefix' => 'Dr.',
            'firstname' => 'Alice',
            'middlename' => 'M.',
            'lastname' => 'Brown',
            'suffix' => 'Sr.',
            'phone' => '555-123-4567',
            'address1' => '789 Maple Ave',
            'address2' => 'Suite 10',
            'city' => 'Smallville',
            'state' => 'KS',
            'pincode' => '67501',
            'country' => 'USA'
        };

        Test.startTest();
        AttorneyController.updateAttorneyData(newData);
        Test.stopTest();

        Contact newContact = [SELECT FirstName, LastName, MailingCity FROM Contact WHERE FirstName = 'Alice' LIMIT 1];
        System.assertEquals('Alice', newContact.FirstName);
        System.assertEquals('Smallville', newContact.MailingCity);
    }
    
    @isTest
    static void testFetchAttorneyData() {
        Contact existingContact = [SELECT Id FROM Contact LIMIT 1];
        Test.startTest();
        Map<String, Object> result = AttorneyController.fetchAttorneyData(existingContact.Id);
        Test.stopTest();
        List<Contact> fetchedContacts = (List<Contact>)result.get('records');
    	System.assertEquals(1, fetchedContacts.size(), 'Expected one record to be returned.');
    }
}