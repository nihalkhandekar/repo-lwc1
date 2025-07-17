@isTest
public class MaintainStaffDataControllerTest {
 @isTest
    static void testGetStateSealStaffData() {
        // Arrange
        createTestContacts(5, 'Staff');
        Date startDate = Date.today().addDays(-10);
        Date endDate = Date.today().addDays(1);

        Test.startTest();

        // Test without filters and sorting
        MaintainStaffDataController.PaginatedResult result = MaintainStaffDataController.getStateSealStaffData(2, 1, null, null, null, null);
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(2, result.records.size(), 'Should return 2 records for first page');
        System.assertEquals(5, result.totalRecordCount, 'Total record count should be 5');

        // Test with date filters
        result = MaintainStaffDataController.getStateSealStaffData(2, 1, startDate, endDate, null, null);
        System.assertNotEquals(null, result, 'Result with date filters should not be null');
        System.assertEquals(2, result.records.size(), 'Should return 2 records with date filters');
        System.assertEquals(5, result.totalRecordCount, 'Total record count with date filters should be 5');

        // Test with valid sorting
        result = MaintainStaffDataController.getStateSealStaffData(2, 1, null, null, 'LastName', 'ASC');
        System.assertNotEquals(null, result, 'Result with sorting should not be null');
        System.assertEquals(2, result.records.size(), 'Should return 2 records with sorting');
        System.assertEquals(5, result.totalRecordCount, 'Total record count with sorting should be 5');

        List<Contact> contacts = (List<Contact>)result.records;
        System.assertEquals('User  0', contacts[0].LastName, 'First record should be User 0 when sorted by LastName ASC');

        // Test with invalid sort field
        result = MaintainStaffDataController.getStateSealStaffData(2, 1, null, null, 'InvalidField', 'ASC');
        System.assertNotEquals(null, result, 'Result with invalid sort field should not be null');
        System.assertEquals(2, result.records.size(), 'Should return 2 records with invalid sort field');
        System.assertEquals(5, result.totalRecordCount, 'Total record count with invalid sort should be 5');

        // Test with invalid sort direction
        result = MaintainStaffDataController.getStateSealStaffData(2, 1, null, null, 'LastName', 'INVALID');
        System.assertNotEquals(null, result, 'Result with invalid sort direction should not be null');
        System.assertEquals(2, result.records.size(), 'Should return 2 records with invalid sort direction');
        System.assertEquals(5, result.totalRecordCount, 'Total record count with invalid direction should be 5');

        Test.stopTest();
    }

    @isTest
    static void testSearchStaffData() {
        // Arrange
        createTestContacts(5, 'Staff');

        // Act
        MaintainStaffDataController.PaginatedResult result = MaintainStaffDataController.searchStaffData('User ', 'Test', '123-456-789', 'Director of Elections', 
                                                                                                         'Business Service Division', 2, 1, null, null);

        // Assert
        System.assertNotEquals(null, result);
        System.assertEquals(2, result.records.size());
    }

    @isTest
    static void testDeleteContact() {
        // Arrange
        Contact contact = createTestContact('Test', 'User ');
        Id contactId = contact.Id;

        // Act
        MaintainStaffDataController.deleteContact(contactId);

        // Assert
        System.assertEquals(0, [SELECT COUNT() FROM Contact WHERE Id = :contactId]);
    }

    @isTest
    static void testGetAttorneyInspectorOptions() {
        // Arrange
        createTestContacts(3, 'Attorney Inspector');

        // Act
        List<Map<String, String>> options = MaintainStaffDataController.getAttorneyInspectorOptions();

        // Assert
        System.assertNotEquals(null, options);
        System.assertEquals(3, options.size());
    }

@isTest
static void testUpdateContactWithFile() {
    // Create test contact
    Contact testContact = new Contact(FirstName = 'John', LastName = 'Doe');
    insert testContact;

    // Create test ContentVersion records
    ContentVersion cv1 = new ContentVersion(
        Title = 'Test Document 1',
        PathOnClient = 'test1.pdf',
        VersionData = Blob.valueOf('Test Content 1'),
        IsMajorVersion = true
    );
    insert cv1;

    ContentVersion cv2 = new ContentVersion(
        Title = 'Test Document 2',
        PathOnClient = 'test2.pdf',
        VersionData = Blob.valueOf('Test Content 2'),
        IsMajorVersion = true
    );
    insert cv2;

    // Query ContentVersion to get ContentDocumentId
    List<ContentVersion> insertedCVs = [
        SELECT Id, ContentDocumentId 
        FROM ContentVersion 
        WHERE Id IN (:cv1.Id, :cv2.Id)
    ];

    // Link files to the contact
    for (ContentVersion cv : insertedCVs) {
        ContentDocumentLink cdl = new ContentDocumentLink(
            LinkedEntityId = testContact.Id,
            ContentDocumentId = cv.ContentDocumentId,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert cdl;
    }

    // Prepare file ID lists
    List<String> uploadedFileIds = new List<String>();
    List<String> deletedFileIds = new List<String>();

    uploadedFileIds.add(insertedCVs[0].ContentDocumentId); // Add first file for upload
    deletedFileIds.add(insertedCVs[1].ContentDocumentId);  // Add second file for deletion

    // Use valid picklist value
    String validDivision = 'Business Service Division';

    Test.startTest();

    try {
        MaintainStaffDataController.updateContactWithFile(
            testContact.Id,
            'Smith',
            'Jane',
            'B',
            'Sr.',
            'Director',
            validDivision, // Use valid value here
            true,
            '9876543210',
            'Inactive',
            uploadedFileIds,
            deletedFileIds
        );

        // Verify contact updates
        Contact updatedContact = [
            SELECT FirstName, LastName, MiddleName, Suffix, Staff_Title__c, 
                   Division__c, Phone, Esquire__c, Status__c
            FROM Contact 
            WHERE Id = :testContact.Id
        ];

        System.assertEquals('Smith', updatedContact.LastName, 'LastName should be updated');
        System.assertEquals('Jane', updatedContact.FirstName, 'FirstName should be updated');
        System.assertEquals(validDivision, updatedContact.Division__c, 'Division should be updated');

    } catch (Exception e) {
        System.debug('Exception: ' + e.getMessage());
        System.assert(false, 'Test failed with exception: ' + e.getMessage());
    }

    Test.stopTest();
}




    @isTest
    static void testUpdateContact() {
        // Arrange
        Contact contact = createTestContact('Test', 'User ');

        // Act
        MaintainStaffDataController.updateContact(contact.Id, 'Apostille');

        // Assert
        Contact updatedContact = [SELECT State_Seal_Default_Staff__c, State_Extradition_Default_Staff__c, Apostille_Default_Staff__c, Public_Official_Default_Staff__c FROM Contact WHERE Id = :contact.Id];
        System.assertEquals(true, updatedContact.Apostille_Default_Staff__c);
    }

    @isTest
    static void testSearchContacts() {
        // Arrange
        createTestContacts(5, 'Staff');

        // Act
        List<Contact> contacts = MaintainStaffDataController.searchContacts('User ');

        // Assert
        System.assertNotEquals(null, contacts);
        System.assertEquals(5, contacts.size());
    }

    @isTest
    static void testGetContactById() {
        // Arrange
        Contact contact = createTestContact('Test', 'User ');

        // Act
        MaintainStaffDataController.ContactWithFiles result = MaintainStaffDataController.getContactById(contact.Id, System.currentTimeMillis());

        // Assert
        System.assertNotEquals(null, result);
        System.assertEquals(contact.Id, result.contact.Id);
    }

    @isTest
    static void testCreateContactWithFile() {
        // Arrange
        List<String> uploadedFileIds = new List<String>(); // Assuming you have some uploaded file Ids

        // Act
        Id newContactId = MaintainStaffDataController.createContactWithFile('User ', 'Test', null, null, null, null, false, '1234567890', null, uploadedFileIds);

        // Assert
        System.assertNotEquals(null, newContactId);
        System.assertNotEquals(null, [SELECT Id FROM Contact WHERE Id = :newContactId LIMIT 1]);
    }

     @IsTest
    static void testFileDownload() {
        // Create a ContentVersion record
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        insert cv;
        
        // Get ContentDocument Id
        cv = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        
        Test.startTest();
        Map<String, String> result = MaintainStaffDataController.downloadFile(cv.ContentDocumentId);
        Test.stopTest();
        
        // Verify the results
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertNotEquals(null, result.get('base64Data'), 'Base64 data should not be null');
        System.assertEquals('application/octet-stream', result.get('contentType'), 'Content type should match');
        
        // Verify the base64 data is correct
        Blob decodedData = EncodingUtil.base64Decode(result.get('base64Data'));
        System.assertEquals('Test Content', decodedData.toString(), 'Content should match the original data');
    }
    
    // Helper method to create test contacts
    private static void createTestContacts(Integer count, String recordTypeName) {
        RecordType recordType = [SELECT Id FROM RecordType WHERE Name = :recordTypeName AND SObjectType = 'Contact' LIMIT 1];
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < count; i++) {
            contacts.add(new Contact(FirstName = 'Test', LastName = 'User  ' + i, RecordTypeId = recordType.Id, Phone = '123-456-789' + i, Staff_Title__c = 'Director of Elections',
                                    Division__c = 'Business Service Division'));
        }
        insert contacts;
    }

    // Helper method to create a single test contact
    private static Contact createTestContact(String firstName, String lastName) {
        RecordType recordType = [SELECT Id FROM RecordType WHERE Name = 'Staff' AND SObjectType = 'Contact' LIMIT 1];
        Contact contact = new Contact(FirstName = firstName, LastName = lastName, RecordTypeId = recordType.Id);
        insert contact;
        return contact;
    }
}