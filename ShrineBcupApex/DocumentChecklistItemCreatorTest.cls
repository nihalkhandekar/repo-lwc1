@isTest
public class DocumentChecklistItemCreatorTest {
    
 @isTest
static void testCreateDocumentChecklistItems() {
    // Setup test data
    RegulatoryAuthorizationType licenseType = new RegulatoryAuthorizationType(Name = 'Extradition License');
    insert licenseType;

    IndividualApplication app = new IndividualApplication(Category = 'Permit', LicenseTypeId = licenseType.Id);
    insert app;

    // Fetch existing DocumentType records
    DocumentType vitalRecordsDocType = [SELECT Id, MasterLabel FROM DocumentType WHERE MasterLabel = 'Vital Records' LIMIT 1];
    DocumentType passportDocType = [SELECT Id, MasterLabel FROM DocumentType WHERE MasterLabel = 'School Records' LIMIT 1];
    
    DocumentChecklistItem doc = new DocumentChecklistItem(DocumentTypeId = vitalRecordsDocType.Id, Name='Test document', ParentRecordId = app.Id);
    insert doc;

    // Prepare JSON input
    String jsonData = '[{"typeOfDocument":"Vital Records", "destinationCountry":"USA", "hague":"Yes", "personName":"John Doe", "fee":"100.00"}, ' +
                      '{"typeOfDocument":"School Records", "destinationCountry":"Canada", "hague":"No", "personName":"Jane Smith", "fee":"75.00"}, ' +
                      '{"typeOfDocument":"", "destinationCountry":"Mexico", "hague":"Yes", "personName":"Bob Johnson", "fee":"50.00"}]';

    // Call the method
    Test.startTest();
    String result = DocumentChecklistItemCreator.createDocumentChecklistItemsLwc(jsonData, app.Id, 'USA');
    Test.stopTest();
    
    Boolean exceptionThrown = false;
    try{
        String invalidParam = DocumentChecklistItemCreator.createDocumentChecklistItemsLwc(jsonData, app.Id, '');
    }
    catch(Exception e){
        exceptionThrown = true;
        System.assert(e instanceof AuraHandledException, 'Expected AuraHandledException but got a different exception type.');
    }

    // Verify results
    System.assertEquals('Success', result, 'The method should return "Success"');

    List<DocumentChecklistItem> items = [
        SELECT Id, Name, Fees__c, Hague_Status__c, DocumentTypeId, ParentRecordId
        FROM DocumentChecklistItem
        WHERE ParentRecordId = :app.Id
    ];

    System.assertEquals(2, items.size(), 'Three Document Checklist Items should be created');

    // Verify the created items
    for (DocumentChecklistItem item : items) {
        if (item.Name == 'John Doe') {
            System.assertEquals(100.00, item.Fees__c, 'The fee should match the input');
            System.assertEquals('Yes', item.Hague_Status__c, 'The Hague status should match the input');
            System.assertEquals(vitalRecordsDocType.Id, item.DocumentTypeId, 'The document type should match the input');
        } else if (item.Name == 'Jane Smith') {
            System.assertEquals(75.00, item.Fees__c, 'The fee should match the input');
            System.assertEquals('No', item.Hague_Status__c, 'The Hague status should match the input');
            System.assertEquals(passportDocType.Id, item.DocumentTypeId, 'The document type should match the input');
        } else {
            System.assert(false, 'Unexpected person name: ' + item.Name);
        }
        System.assertEquals(app.Id, item.ParentRecordId, 'The parent record ID should match the input');
    }
}

    @isTest
    static void testInvalidApplicationId() {
         DocumentChecklistItemCreator.createDocumentChecklistItems(null);
        List<DocumentChecklistItem> item = [SELECT Id FROM DocumentChecklistItem];
    	System.assertEquals(0, item.size(), 'No Document Checklist Items should be created with null input.');

        // Prepare JSON input
        String jsonData = '[{"typeOfDocument":"Passport", "destinationCountry":"USA", "hague":"Yes", "personName":"John Doe", "baseFee":"100.00", "fee":"0.00", "isExpedited":false}]';

        // Create FlowInput object with an invalid application ID
        DocumentChecklistItemCreator.FlowInput input = new DocumentChecklistItemCreator.FlowInput();
        input.jsonData = jsonData;
        input.individualApplicationId = 'invalidId';
        input.destinationCountry = 'USA';
        input.selectedHagueStatus = 'Yes';

        // Call the method and expect no exceptions
        Test.startTest();
        DocumentChecklistItemCreator.createDocumentChecklistItems(new List<DocumentChecklistItemCreator.FlowInput>{ input });
        Test.stopTest();

        // Verify that no Document Checklist Items were created
        List<DocumentChecklistItem> items = [SELECT Id FROM DocumentChecklistItem];
        System.assertEquals(0, items.size(), 'No Document Checklist Items should be created with an invalid application ID.');
    }

@isTest
static void testDeleteExistingItems() {
    // Setup test data
    RegulatoryAuthorizationType licenseType = new RegulatoryAuthorizationType(Name = 'Extradition License');
    insert licenseType;
    DocumentType docType = [SELECT Id, MasterLabel FROM DocumentType WHERE MasterLabel = 'Vital Records' LIMIT 1];

    IndividualApplication app = new IndividualApplication(Category = 'Permit', LicenseTypeId = licenseType.Id);
    insert app;

    // Insert initial Document Checklist Item to test deletion
    DocumentChecklistItem existingItem = new DocumentChecklistItem(
        Name = 'Existing Item',
        Fees__c = 50.00,
        Status = 'In Progress',
        DocumentTypeId = docType.Id,
        ParentRecordId = app.Id,
        Hague_Status__c = 'No'
    );
    insert existingItem;

    // JSON data for Yes, No, and Expedited Hague scenarios
    String jsonDataYes = '[{"typeOfDocument":"Certificate", "destinationCountry":"UK", "hague":"Yes", "personName":"Alice Brown", "baseFee":"200.00", "fee":"0.00", "isExpedited":false}]';
    String jsonDataNo = '[{"typeOfDocument":"Certificate", "destinationCountry":"UK", "hague":"No", "personName":"Bob Smith", "baseFee":"150.00", "fee":"0.00", "isExpedited":false}]';
    String jsonDataExpedited = '[{"typeOfDocument":"Certificate", "destinationCountry":"UK", "hague":"Yes", "personName":"Eve Johnson", "baseFee":"100.00", "fee":"0.00", "isExpedited":true}]';

    // Start Test context
    Test.startTest();
    
    // Step 1: Execute Yes scenario
    DocumentChecklistItemCreator.FlowInput inputYes = new DocumentChecklistItemCreator.FlowInput();
    inputYes.jsonData = jsonDataYes;
    inputYes.individualApplicationId = app.Id;
    inputYes.destinationCountry = 'UK';
    inputYes.selectedHagueStatus = 'Yes';

    // Call the method for Yes scenario
    DocumentChecklistItemCreator.createDocumentChecklistItems(new List<DocumentChecklistItemCreator.FlowInput>{ inputYes });

    // Validate results for Yes scenario
    List<DocumentChecklistItem> itemsYes = [SELECT Id, Name, Fees__c, Hague_Status__c FROM DocumentChecklistItem WHERE ParentRecordId = :app.Id];
    System.assertEquals(1, itemsYes.size(), 'One Document Checklist Item should be created after deletion for Yes scenario.');
    System.assertEquals('Alice Brown', itemsYes[0].Name, 'The name should match the input for the new item in Yes scenario.');
    System.assertEquals(200.00, itemsYes[0].Fees__c, 'The fee should match the input for the new item in Yes scenario.');
    System.assertEquals('Yes', itemsYes[0].Hague_Status__c, 'The Hague status should match the input for the new item in Yes scenario.');

    // Step 2: Clean up and execute No scenario
    delete itemsYes;

    DocumentChecklistItemCreator.FlowInput inputNo = new DocumentChecklistItemCreator.FlowInput();
    inputNo.jsonData = jsonDataNo;
    inputNo.individualApplicationId = app.Id;
    inputNo.destinationCountry = 'UK';
    inputNo.selectedHagueStatus = 'No';

    // Call the method for No scenario
    DocumentChecklistItemCreator.createDocumentChecklistItems(new List<DocumentChecklistItemCreator.FlowInput>{ inputNo });
    
    // Validate results for No scenario
    List<DocumentChecklistItem> itemsNo = [SELECT Id, Name, Fees__c, Hague_Status__c FROM DocumentChecklistItem WHERE ParentRecordId = :app.Id];
    System.assertEquals(1, itemsNo.size(), 'One Document Checklist Item should be created after deletion for No scenario.');
    System.assertEquals('Bob Smith', itemsNo[0].Name, 'The name should match the input for the new item in No scenario.');
    System.assertEquals(150.00, itemsNo[0].Fees__c, 'The fee should match the input for the new item in No scenario.');
    System.assertEquals('No', itemsNo[0].Hague_Status__c, 'The Hague status should match the input for the new item in No scenario.');

    // Step 3: Clean up and execute Expedited scenario
    delete itemsNo;

    DocumentChecklistItemCreator.FlowInput inputExpedited = new DocumentChecklistItemCreator.FlowInput();
    inputExpedited.jsonData = jsonDataExpedited;
    inputExpedited.individualApplicationId = app.Id;
    inputExpedited.destinationCountry = 'UK';
    inputExpedited.selectedHagueStatus = 'Yes';

    // Call the method for Expedited scenario
    DocumentChecklistItemCreator.createDocumentChecklistItems(new List<DocumentChecklistItemCreator.FlowInput>{ inputExpedited });
    
    // Stop Test context
    Test.stopTest();

    // Validate results for Expedited scenario
    List<DocumentChecklistItem> itemsExpedited = [SELECT Id, Name, Fees__c, Hague_Status__c FROM DocumentChecklistItem WHERE ParentRecordId = :app.Id];
    System.assertEquals(1, itemsExpedited.size(), 'One Document Checklist Item should be created after deletion for Expedited scenario.');
    System.assertEquals('Eve Johnson', itemsExpedited[0].Name, 'The name should match the input for the new item in Expedited scenario.');
    System.assertEquals(150.00, itemsExpedited[0].Fees__c, 'The fee should include the expedited surcharge of 50.00 for the Expedited scenario.');
    System.assertEquals('Yes', itemsExpedited[0].Hague_Status__c, 'The Hague status should match the input for the new item in Expedited scenario.');
}


}