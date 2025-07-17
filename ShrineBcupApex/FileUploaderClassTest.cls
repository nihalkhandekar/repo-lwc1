@isTest
public class FileUploaderClassTest {
    
    // Helper method to create a test record for file upload
    private static Id createTestRecord() {
        RegulatoryAuthorizationType license1 = new RegulatoryAuthorizationType(
            Name = 'Test',
            RegulatoryAuthCategory = 'License',
            DurationType = 'Hour'
        );
        insert license1;
        
        IndividualApplication testAccount = new IndividualApplication(
            Sequence_Number__c = 'APO-202411-0005',
            First_Name__c = 'JAMES',
            Last_Name__c = 'HARI',
            LicenseTypeId = license1.Id,
            Category = 'License',
            Status = 'In Progress'
        );
        insert testAccount;
        return testAccount.Id;
    }

    // Test the fetchFiles method
    @isTest
    static void testFetchFiles() {
        Id testRecordId = createTestRecord();

        ContentVersion cv = new ContentVersion(
            Title = 'Test File',
            PathOnClient = 'testfile.txt',
            VersionData = Blob.valueOf('Test File Content')
        );
        insert cv;

        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];

        ContentDocumentLink docLink = new ContentDocumentLink(
            ContentDocumentId = cv.ContentDocumentId,
            LinkedEntityId = testRecordId,
            ShareType = 'V'
        );
        insert docLink;

        Test.startTest();
        List<ContentVersion> files = FileUploaderClass.fetchFiles(testRecordId);
        Test.stopTest();

        System.assertNotEquals(0, files.size(), 'Files should not be empty');
        System.assertEquals('Test File', files[0].Title, 'File title should match');
    }

    // Test the getRelatedFilesByRecordId method
    @isTest
    static void testGetRelatedFilesByRecordId() {
        Id testRecordId = createTestRecord();

        ContentVersion cv = new ContentVersion(
            Title = 'Test File for Record',
            PathOnClient = 'testfile2.txt',
            VersionData = Blob.valueOf('Another Test File Content')
        );
        insert cv;

        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];

        ContentDocumentLink docLink = new ContentDocumentLink(
            ContentDocumentId = cv.ContentDocumentId,
            LinkedEntityId = testRecordId,
            ShareType = 'V'
        );
        insert docLink;

        Test.startTest();
        Map<ID, String> relatedFiles = FileUploaderClass.getRelatedFilesByRecordId(testRecordId);
        Test.stopTest();
system.debug(relatedFiles);
        System.assertEquals(1, relatedFiles.size(), 'There should be one related file');
        System.assertEquals('Test File for Record', relatedFiles.get(cv.ContentDocumentId), 'File title should match');
    }

    @isTest
    static void testUploadFiles() {
        List<FileUploaderClass.FileInfo> filesToUpload = new List<FileUploaderClass.FileInfo>();
        FileUploaderClass.FileInfo fileInfo = new FileUploaderClass.FileInfo();
        fileInfo.base64 = EncodingUtil.base64Encode(Blob.valueOf('Test content for file upload'));
        fileInfo.filename = 'uploadedFile.txt';
        filesToUpload.add(fileInfo);

        Test.startTest();
        List<Id> contentDocumentIds = FileUploaderClass.uploadFiles(filesToUpload);
        Test.stopTest();

        System.assertNotEquals(0, contentDocumentIds.size(), 'There should be at least one file uploaded');
    }

    // Test the deleteFile method
    @isTest
    static void testDeleteFile() {
        Id testRecordId = createTestRecord();

        ContentVersion cv = new ContentVersion(
            Title = 'File to delete',
            PathOnClient = 'filetodelete.txt',
            VersionData = Blob.valueOf('Content for deletion')
        );
        insert cv;

        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];

        ContentDocumentLink docLink = new ContentDocumentLink(
            ContentDocumentId = cv.ContentDocumentId,
            LinkedEntityId = testRecordId,
            ShareType = 'V'
        );
        insert docLink;

        Test.startTest();
        FileUploaderClass.deleteFile(cv.ContentDocumentId);
        Test.stopTest();

        List<ContentDocument> deletedDoc = [SELECT Id FROM ContentDocument WHERE Id = :cv.ContentDocumentId];
        System.assertEquals(0, deletedDoc.size(), 'ContentDocument should be deleted');

        List<ContentDocumentLink> deletedDocLink = [SELECT Id FROM ContentDocumentLink WHERE ContentDocumentId = :cv.ContentDocumentId];
        System.assertEquals(0, deletedDocLink.size(), 'ContentDocumentLink should be deleted');
    }
}