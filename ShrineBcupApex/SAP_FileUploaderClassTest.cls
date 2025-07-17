@IsTest
private class SAP_FileUploaderClassTest {

    @TestSetup
    static void setupTestData() {
    
    Account testRecord = new Account(Name = 'Test Account');
    insert testRecord;

    
    ContentVersion contentVersion = new ContentVersion(
        Title = 'Test File',
        VersionData = Blob.valueOf('Test file content'),
        PathOnClient = 'TestFile.txt',
        IsMajorVersion = true
    );
    insert contentVersion;

   
    contentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id LIMIT 1];

    
    ContentDocument contentDocument = [SELECT Id FROM ContentDocument WHERE Id = :contentVersion.ContentDocumentId LIMIT 1];

    // Create ContentDocumentLink to associate file with the record
    ContentDocumentLink contentLink = new ContentDocumentLink(
        LinkedEntityId = testRecord.Id,
        ContentDocumentId = contentDocument.Id,
        ShareType = 'V' // Viewer access
    );
    insert contentLink;
}
    
    
    @IsTest
    static void testFetchFiles() {
        // Fetch the test record
        Account testRecord = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        List<ContentVersion> files = SAP_FileUploaderClass.fetchFiles(testRecord.Id);
        Test.stopTest();

      
        System.assertNotEquals(0, files.size(), 'Files should be fetched');
        System.assertEquals('Test File', files[0].Title, 'File title should match');
    }

    @IsTest
    static void testGetRelatedFilesByRecordId() {
        // Fetch the test record
        Account testRecord = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        Map<ID, String> relatedFiles = SAP_FileUploaderClass.getRelatedFilesByRecordId(testRecord.Id);
        Test.stopTest();

        
        System.assertNotEquals(0, relatedFiles.size(), 'There should be at least one related file');
        System.assertEquals('Test File', relatedFiles.values()[0], 'File name should match');
    }

    @IsTest
    static void testUploadFiles() {
        List<SAP_FileUploaderClass.FileInfo> fileInfos = new List<SAP_FileUploaderClass.FileInfo>();

        SAP_FileUploaderClass.FileInfo fileInfo = new SAP_FileUploaderClass.FileInfo();
        fileInfo.filename = 'NewFile.txt';
        fileInfo.base64 = EncodingUtil.base64Encode(Blob.valueOf('Sample Content'));
        fileInfos.add(fileInfo);

        Test.startTest();
        List<String> uploadedFileIds = SAP_FileUploaderClass.uploadFiles(fileInfos);
        Test.stopTest();

        
        System.assertNotEquals(0, uploadedFileIds.size(), 'Files should be uploaded');
    }

    @IsTest
    static void testDeleteFile() {
        // Fetch an existing ContentDocumentId
        ContentDocument contentDoc = [SELECT Id FROM ContentDocument LIMIT 1];

        Test.startTest();
        SAP_FileUploaderClass.deleteFile(contentDoc.Id);
        Test.stopTest();

        // Verify the file is deleted
        List<ContentDocument> docs = [SELECT Id FROM ContentDocument WHERE Id = :contentDoc.Id];
        System.assertEquals(0, docs.size(), 'File should be deleted');
    }
}