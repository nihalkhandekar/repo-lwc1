@isTest
public class SAP_AddOfficialContactControllerTest {

    @TestSetup
    static void setupTestData() {
       
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
     
        RecordType contactRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Official' LIMIT 1];
       
        Office__c testOffice = new Office__c(
            SAP_Name__c = 'Test Office'
        );
        insert testOffice;
     
        Contact testContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'john.doe@example.com',
            Office__c = testOffice.Id,
            RecordTypeId = contactRecordType.Id,
            AccountId = testAccount.Id
        );
        insert testContact;
    }
    
     @isTest
     static void testFetchOffices() {
        Test.startTest();
        List<Office__c> offices = SAP_AddOfficialContactController.fetchOffices();
        Test.stopTest();
        System.assertEquals(true, offices.size() > 0, 'Offices should be fetched successfully.');
        
    }
     
    @isTest
    static void testUpsertContactInsert() {
    if ([SELECT COUNT() FROM Office__c] == 0) {
        Office__c newOffice = new Office__c(SAP_Name__c = 'Test Office');
        insert newOffice;
    }
   
    Office__c office = [SELECT Id FROM Office__c WHERE SAP_Name__c = 'Test Office' LIMIT 1];
  
    Map<String, Object> formData = new Map<String, Object>();
    formData.put('firstName', 'Jane');
    formData.put('lastName', 'Smith');
    formData.put('email', 'jane.smith@example.com');
    formData.put('sbt', office.Id);
    formData.put('apo', true);
    formData.put('indefiniteTerm', true);
                                     
    Test.startTest();
    String newContactId = SAP_AddOfficialContactController.upsertContact(formData);
    Test.stopTest();
     System.assertEquals(true, newContactId != null, 'Contact should be inserted successfully.');
    
}
 
    @isTest
    static void testUpsertContactUpdate() {
    Contact existingContact;
    if ([SELECT COUNT() FROM Contact WHERE LastName = 'Doe'] == 0) {
        existingContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'john.doe@example.com'
        );
        insert existingContact;
    } else {
        existingContact = [SELECT Id, FirstName, LastName FROM Contact WHERE LastName = 'Doe' LIMIT 1];
    }

    Map<String, Object> formData = new Map<String, Object>();
    formData.put('recordId', existingContact.Id);
    formData.put('firstName', 'Johnny');
    formData.put('lastName', 'Doe');
    formData.put('email', 'johnny.doe@example.com');

    Test.startTest();
    String updatedContactId = SAP_AddOfficialContactController.upsertContact(formData);
    Test.stopTest();
        
    
        Contact updatedContact = [SELECT FirstName, Email FROM Contact WHERE Id = :updatedContactId LIMIT 1];
        System.assertEquals('Johnny', updatedContact.FirstName, 'Contact first name should be updated.');
        System.assertEquals('johnny.doe@example.com', updatedContact.Email, 'Contact email should be updated.');

}

     @isTest
     static void testFetchContactData() {
       
        Contact existingContact = [SELECT Id FROM Contact WHERE LastName = 'Doe' LIMIT 1];

        Test.startTest();
        Contact fetchedContact = SAP_AddOfficialContactController.fetchContactData(existingContact.Id);
        Test.stopTest();
        
        System.assertEquals(existingContact.Id, fetchedContact.Id, 'Fetched contact ID should match the requested ID.');

    }



    
}