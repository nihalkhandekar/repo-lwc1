@IsTest
public class SAP_DocumentChecklistJsonGeneratorTest {

    @testSetup
    static void setupTestData() {
        
        RegulatoryAuthorizationType licenseType = new RegulatoryAuthorizationType(Name = 'Test License');
        insert licenseType;
        
        IndividualApplication app = new IndividualApplication(
            SAP_First_Name__c = 'Test',
            SAP_Last_Name__c = 'User',
            SAP_Organization_Name__c = 'Test Org',
            SAP_Expedited__c = true,
            LicenseTypeId = licenseType.Id,
            Category = 'License'
        );
        insert app;
        
        DocumentChecklistItem dci = new DocumentChecklistItem(
            Name = 'Checklist Test Item',
            ParentRecordId = app.Id,
            SAP_Country__c = 'USA',
            SAP_Fees__c = 100,
            SAP_SOTS_Certified_copy_number__c = '00001',
            SAP_Hague_Status__c = 'No',
            Status = 'Submitted'
        );
        insert dci;
        
        
        // Create a ContentVersion record so that a ContentDocument is generated.
        ContentVersion cv = new ContentVersion(
            Title = 'Test File',
            PathOnClient = 'TestFile.pdf',
            VersionData = Blob.valueOf('Test file data')
        );
        insert cv;
        cv = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
        
        
        // Insert a ContentDocumentLink linking the ContentDocument to our checklist item.
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = cv.ContentDocumentId,
            LinkedEntityId = dci.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert cdl;
       
        
        // Insert a Contact record for searchContacts testing.
        Contact con = new Contact(
            LastName = 'TestContact',
            FirstName = 'Search'
        );
        insert con;
       
    }
    
   
    static testMethod void testGenerateJsonFromChecklistItemsByParentId_WithItems() {
        IndividualApplication app = [SELECT Id, SAP_Sequence_Number__c FROM IndividualApplication LIMIT 1];
        SAP_DocumentChecklistJsonGenerator.IdInput input = new SAP_DocumentChecklistJsonGenerator.IdInput();
        input.individualApplicationId = String.valueOf(app.Id);
        List<SAP_DocumentChecklistJsonGenerator.IdInput> inputs = new List<SAP_DocumentChecklistJsonGenerator.IdInput>{ input };
        
        Test.startTest();
        List<SAP_DocumentChecklistJsonGenerator.JsonOutput> outputs = SAP_DocumentChecklistJsonGenerator.generateJsonFromChecklistItemsByParentId(inputs);
        Test.stopTest();
        
       
    }
    
  
    static testMethod void testGenerateJsonFromChecklistItemsByParentId_NoItems() {
        
        RegulatoryAuthorizationType licenseType = new RegulatoryAuthorizationType(Name = 'Test License 2');
        insert licenseType;
        IndividualApplication appNoItems = new IndividualApplication(
            SAP_First_Name__c = 'No',
            SAP_Last_Name__c = 'Items',
            SAP_Organization_Name__c = 'Empty Org',
            SAP_Expedited__c = false,
            LicenseTypeId = licenseType.Id,
            Category = 'License'
        );
        insert appNoItems;
        
        SAP_DocumentChecklistJsonGenerator.IdInput input = new SAP_DocumentChecklistJsonGenerator.IdInput();
        input.individualApplicationId = String.valueOf(appNoItems.Id);
        List<SAP_DocumentChecklistJsonGenerator.IdInput> inputs = new List<SAP_DocumentChecklistJsonGenerator.IdInput>{ input };
        
        Test.startTest();
        List<SAP_DocumentChecklistJsonGenerator.JsonOutput> outputs = SAP_DocumentChecklistJsonGenerator.generateJsonFromChecklistItemsByParentId(inputs);
        Test.stopTest();
        

    }
    
    // When idInputs is null.
    static testMethod void testGenerateJsonFromChecklistItemsByParentId_NullInputs() {
        Test.startTest();
        List<SAP_DocumentChecklistJsonGenerator.JsonOutput> outputs = SAP_DocumentChecklistJsonGenerator.generateJsonFromChecklistItemsByParentId(null);
        Test.stopTest();
       
    }
    
    // When idInputs is empty.
    static testMethod void testGenerateJsonFromChecklistItemsByParentId_EmptyInputs() {
        List<SAP_DocumentChecklistJsonGenerator.IdInput> emptyInputs = new List<SAP_DocumentChecklistJsonGenerator.IdInput>();
        Test.startTest();
        List<SAP_DocumentChecklistJsonGenerator.JsonOutput> outputs = SAP_DocumentChecklistJsonGenerator.generateJsonFromChecklistItemsByParentId(emptyInputs);
        Test.stopTest();
        
    }
    
    // When an invalid IndividualApplication Id is provided.
    static testMethod void testGenerateJsonFromChecklistItemsByParentId_InvalidId() {
        SAP_DocumentChecklistJsonGenerator.IdInput input = new SAP_DocumentChecklistJsonGenerator.IdInput();
        input.individualApplicationId = 'invalidId';
        List<SAP_DocumentChecklistJsonGenerator.IdInput> inputs = new List<SAP_DocumentChecklistJsonGenerator.IdInput>{ input };
        
        Test.startTest();
        List<SAP_DocumentChecklistJsonGenerator.JsonOutput> outputs = SAP_DocumentChecklistJsonGenerator.generateJsonFromChecklistItemsByParentId(inputs);
        Test.stopTest();
        
    }
    
    // When a valid id format is provided but no IndividualApplication is found.
    static testMethod void testGenerateJsonFromChecklistItemsByParentId_ApplicationNotFound() {
        // Construct a valid-format id that does not exist.
        String fakeId = 'a00XXXXXXXXXXXXXXX';
        SAP_DocumentChecklistJsonGenerator.IdInput input = new SAP_DocumentChecklistJsonGenerator.IdInput();
        input.individualApplicationId = fakeId;
        List<SAP_DocumentChecklistJsonGenerator.IdInput> inputs = new List<SAP_DocumentChecklistJsonGenerator.IdInput>{ input };
        
        Test.startTest();
        List<SAP_DocumentChecklistJsonGenerator.JsonOutput> outputs = SAP_DocumentChecklistJsonGenerator.generateJsonFromChecklistItemsByParentId(inputs);
        Test.stopTest();
        
    }
    
   
    // When valid data is provided.
    static testMethod void testGenerateJsonFromChecklistItemsByParentIdLwc_Valid() {
        // Retrieve the test IndividualApplication from setup.
        IndividualApplication app = [SELECT Id, SAP_Sequence_Number__c FROM IndividualApplication LIMIT 1];
        // Call the LWC version which returns a JSON string.
        Test.startTest();
        String jsonResult = SAP_DocumentChecklistJsonGenerator.generateJsonFromChecklistItemsByParentIdLwc(String.valueOf(app.Id));
        Test.stopTest();
       
    }
    
    // When an invalid individualApplicationId is provided to the LWC method.
    static testMethod void testGenerateJsonFromChecklistItemsByParentIdLwc_InvalidId() {
        Test.startTest();
        String jsonResult = SAP_DocumentChecklistJsonGenerator.generateJsonFromChecklistItemsByParentIdLwc('invalidId');
        Test.stopTest();
       
    }
    
    // When a valid id is provided but no IndividualApplication record exists.
    static testMethod void testGenerateJsonFromChecklistItemsByParentIdLwc_AppNotFound() {
        String fakeId = 'a00XXXXXXXXXXXXXXX';
        Test.startTest();
        String jsonResult = SAP_DocumentChecklistJsonGenerator.generateJsonFromChecklistItemsByParentIdLwc(fakeId);
        Test.stopTest();
    }
    
    
    static testMethod void testSearchContacts_BlankPosition() {
        // Insert a test Contact.
        Contact con = new Contact(LastName = 'SearchTest', FirstName = 'Contact');
        insert con;
        
        Test.startTest();
        String resultJson = SAP_DocumentChecklistJsonGenerator.searchContacts('SearchTest', '');
        Test.stopTest();
        
    }
    
    // Test: searchContacts with non-blank position.
    static testMethod void testSearchContacts_WithPosition() {
       
        Contact con = new Contact(LastName = 'PositionTest', FirstName = 'Contact');
        insert con;
        
        Test.startTest();
        String resultJson = SAP_DocumentChecklistJsonGenerator.searchContacts('PositionTest', 'Manager');
        Test.stopTest();
        
    }
    
    // Indirect test for date formatting via searchContacts.
    static testMethod void testFormatCustomDate_ViaSearchContacts() {
        Date startDate = Date.newInstance(2020, 1, 5);
        Date endDate = Date.newInstance(2020, 12, 15);
        
       
        Map<String, Schema.RecordTypeInfo> rtMap = Contact.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName();
        Id rtId = rtMap.containsKey('Apostille_Official') ? rtMap.get('Apostille_Official').getRecordTypeId() : null;
        
        Contact con = new Contact(LastName = 'DateTest', FirstName = 'Contact', SAP_Start_Term__c = startDate, SAP_End_Term__c = endDate);
        if(rtId != null) {
            con.RecordTypeId = rtId;
        }
        insert con;
        
        Test.startTest();
        String resultJson = SAP_DocumentChecklistJsonGenerator.searchContacts('DateTest', '');
        Test.stopTest();
        
    }
}