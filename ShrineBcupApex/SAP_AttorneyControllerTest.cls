@isTest
public class SAP_AttorneyControllerTest {
    @testSetup
    static void setupTestData() {
        TestDataFactory.createTestAttorneyContact();
    }
    

    @isTest
    static void testFetchAttorneyData() {
       
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        
        Test.startTest();
        Map<String, Object> result = SAP_AttorneyController.fetchAttorneyData(testContact.Id);
        Test.stopTest();
        
       
        System.assert(result != null, 'Result should not be null');
        System.assert(result.containsKey('records'), 'Result should contain records key');
        List<Contact> contacts = (List<Contact>) result.get('records');
        System.assertEquals(1, contacts.size(), 'Should return one contact');
        System.assertEquals(testContact.Id, contacts[0].Id, 'Returned Contact Id should match');
    }

    @isTest
    static void testUpdateAttorneyData() {
        
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        
        // Prepare input data
        Map<String, Object> inputData = new Map<String, Object>{
            'recordId' => testContact.Id,
            'prefix' => 'Dr.',
            'firstname' => 'Jane',
            'middlename' => 'M',
            'lastname' => 'Smith',
            'suffix' => 'Jr.',
            'phone' => '9876543210',
            'address1' => '456 Elm St',
            'address2' => 'Suite 5C',
            'city' => 'Los Angeles',
            'state' => 'CA',
            'pincode' => '90001',
            'country' => 'USA'
        };

        Test.startTest();
        SAP_AttorneyController.updateAttorneyData(inputData);
        Test.stopTest();

        // Verify the update
        Contact updatedContact = [SELECT FirstName, LastName, Phone, MailingStreet, MailingCity, MailingState FROM Contact WHERE Id = :testContact.Id];
        System.assertEquals('Jane', updatedContact.FirstName, 'First name should be updated');
        System.assertEquals('Smith', updatedContact.LastName, 'Last name should be updated');
        System.assertEquals('9876543210', updatedContact.Phone, 'Phone should be updated');
        System.assertEquals('456 Elm St', updatedContact.MailingStreet, 'Street should be updated');
        System.assertEquals('Los Angeles', updatedContact.MailingCity, 'City should be updated');
        System.assertEquals('Ca', updatedContact.MailingState, 'State should be updated');
    }
}