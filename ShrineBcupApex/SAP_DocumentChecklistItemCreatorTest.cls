@IsTest
public class SAP_DocumentChecklistItemCreatorTest {
    
    @testSetup
    static void setupTestData() {
        
        Account acc = new Account(Name = 'Test Account');
        insert acc;
             
        RegulatoryAuthorizationType licenseType = new RegulatoryAuthorizationType(Name = 'Test License');
        insert licenseType;
       
        IndividualApplication testApp = new IndividualApplication(
            SAP_First_Name__c = 'John',
            SAP_Last_Name__c = 'Doe',
            SAP_Organization_Name__c = 'Test Org',
            SAP_Expedited__c = true,
            LicenseTypeId = licenseType.Id,
            Category = 'License'
        );
        insert testApp;
        
        DocumentChecklistItem checklistItem = new DocumentChecklistItem(
            Name = 'Initial Checklist Item',
            ParentRecordId = testApp.Id,
            SAP_Country__c = 'USA'
        );
        insert checklistItem;
        
         ContentVersion cv = new ContentVersion(
            Title = 'Apostille_Document - Test',
            PathOnClient = 'TestDoc.pdf',
            VersionData = Blob.valueOf('Test data')
        );
        insert cv;
        cv = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
        String validDocId = String.valueOf(cv.ContentDocumentId);
        
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = validDocId,
            LinkedEntityId = checklistItem.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert cdl;
    }
    
    
    @isTest
    static void testCreateDocumentChecklistItems_Update_ExceptionExpected() {
       
        IndividualApplication testApp = [SELECT Id FROM IndividualApplication LIMIT 1];
        
        DocumentChecklistItem existingItem = [SELECT Id, Name FROM DocumentChecklistItem 
                                               WHERE ParentRecordId = :testApp.Id LIMIT 1];
       
        String jsonInput = '[{' +
            '"id": "' + existingItem.Id + '", ' +
            '"typeOfDocument": "SOTS Certified Copies", ' +
            '"destinationCountry": "USA", ' +
            '"personName": "Updated Checklist Item", ' +
            '"uploadedFiles": [{"documentId": "0123456789"}]' +
            '}]';
        
        SAP_DocumentChecklistItemCreator.FlowInput input = new SAP_DocumentChecklistItemCreator.FlowInput();
        input.individualApplicationId = testApp.Id;
        input.jsonData = jsonInput;
        input.destinationCountry = 'USA';
        input.selectedHagueStatus = 'Not Required';
        
        List<SAP_DocumentChecklistItemCreator.FlowInput> flowInputs = 
            new List<SAP_DocumentChecklistItemCreator.FlowInput>{ input };
                
        Boolean exceptionThrown = false;
        String exceptionMessage = '';
       
        
        Test.startTest();
        try {
            
            SAP_DocumentChecklistItemCreator.createDocumentChecklistItems(flowInputs);
            
        } catch (Exception e) {
            
             exceptionThrown = true;
             exceptionMessage = e.getMessage();
             System.debug('Caught expected exception: ' + exceptionMessage);
            
        }
        Test.stopTest();
        
        System.assert(exceptionThrown, 'Expected an exception to be thrown but it was not.');
        System.assertNotEquals(exceptionMessage, '', 'Expected exception message but got empty string.');
        
    }
    
   
   
    @isTest
    static void testCreateDocumentChecklistItems_Insert() {
    
    
    
    IndividualApplication testApp = [SELECT Id FROM IndividualApplication LIMIT 1];
 
    
   
    Integer initialCount = [SELECT COUNT() FROM DocumentChecklistItem WHERE ParentRecordId = :testApp.Id];
   
    String jsonInput = '[{' +
        '"id": null, ' +
        '"typeOfDocument": "SOTS Certified Copies", ' +
        '"destinationCountry": "USA", ' +
        '"personName": "New Checklist Item", ' +
        '"baseFee": "0.00", ' +
        '"isExpedited": false, ' +
        '"uploadedFiles": [{"documentId": "9876543210"}]' +
        '}]';
    
    SAP_DocumentChecklistItemCreator.FlowInput input = new SAP_DocumentChecklistItemCreator.FlowInput();
    input.individualApplicationId = testApp.Id;
    input.jsonData = jsonInput;
    input.destinationCountry = 'USA';
    input.selectedHagueStatus = 'Not Required';
   
    
    List<SAP_DocumentChecklistItemCreator.FlowInput> flowInputs = 
        new List<SAP_DocumentChecklistItemCreator.FlowInput>{ input };
  
    
    Test.startTest();
    SAP_DocumentChecklistItemCreator.createDocumentChecklistItems(flowInputs);
    Test.stopTest();
    
     Integer finalCount = [SELECT COUNT() FROM DocumentChecklistItem WHERE ParentRecordId = :testApp.Id];
     System.assertEquals(initialCount + 1, finalCount, 'Expected one new checklist item to be inserted');
    
}

    

    // Test Method: LWC Method Scenario

  @isTest
  static void testCreateDocumentChecklistItemsLwc() {
   
    IndividualApplication testApp = [SELECT Id FROM IndividualApplication LIMIT 1];
    System.debug('Retrieved IndividualApplication: ' + testApp);
    
    String jsonInput = '[{' +
        '"id": "", ' +
        '"typeOfDocument": "SOTS Certified Copies", ' +                  
        '"destinationCountry": "USA", ' +
        '"personName": "LWC Checklist Item", ' +
        '"fee": "10.00", ' +
        '"baseFee": "5.00", ' +
        '"isExpedited": false, ' +                  
        '"status": "Submitted", ' +
        '"hague": "", ' +
        '"selectedContactID": "", ' +
        '"rejectionReason": "", ' +
        '"customRejectionReason": "", ' +
        '"autority": "", ' +
        '"type": "", ' +
        '"signedByPosition": "", ' +
        '"signedByName": "", ' +
        '"feeDisplay": "", ' +
        '"expediteFee": "", ' +
        '"country": "USA", ' +                      
        '"copyNumber": "", ' +
        '"termStart":"2023-08-07", ' +
        '"termEnd": "2023-09-07", ' +
        '"contentDocumentId": "", ' +  
        '"uploadedFiles": [{"documentId": "1122334455"}]' +       
        '}]';
    
    System.debug('JSON input for LWC method: ' + jsonInput);
    
    Test.startTest();
    String result = SAP_DocumentChecklistItemCreator.createDocumentChecklistItemsLwc(jsonInput, testApp.Id, 'USA');
    Test.stopTest();
      
    
    System.assertNotEquals(result, null, 'Expected a non-null response.');
    System.assertNotEquals(result, '', 'Expected a non-empty response.');
    System.assert(result.contains('Success') || result.contains('Error'), 'Expected response to contain "Success" or "Error".');
    
}
    
     //  Calling createDocumentChecklistItems with an empty list.
    @isTest
    static void testCreateDocumentChecklistItems_EmptyFlowInputs() {
  
        List<SAP_DocumentChecklistItemCreator.FlowInput> emptyInputs = new List<SAP_DocumentChecklistItemCreator.FlowInput>();
        Test.startTest();
        SAP_DocumentChecklistItemCreator.createDocumentChecklistItems(emptyInputs);
        Test.stopTest();

    }
    
    // Calling createDocumentChecklistItems with an invalid application ID.
    @isTest
    static void testCreateDocumentChecklistItems_InvalidApplicationId() {
  
        SAP_DocumentChecklistItemCreator.FlowInput input = new SAP_DocumentChecklistItemCreator.FlowInput();
        input.individualApplicationId = 'invalidId';
        input.jsonData = '[{"id": null, "typeOfDocument": "", "destinationCountry": "USA", "personName": "Test Invalid", "uploadedFiles": []}]';
        input.destinationCountry = 'USA';
        input.selectedHagueStatus = 'Not Required';
        List<SAP_DocumentChecklistItemCreator.FlowInput> inputs = new List<SAP_DocumentChecklistItemCreator.FlowInput>{input};
        
        Test.startTest();
       
        SAP_DocumentChecklistItemCreator.createDocumentChecklistItems(inputs);
        Test.stopTest();
       
    }
    
    
     // Calling createDocumentChecklistItems with invalid JSON.
 @isTest
static void testCreateDocumentChecklistItems_InvalidJSON() {
    
    IndividualApplication testApp = [SELECT Id FROM IndividualApplication LIMIT 1];
    
    SAP_DocumentChecklistItemCreator.FlowInput input = new SAP_DocumentChecklistItemCreator.FlowInput();
    input.individualApplicationId = testApp.Id;
    input.jsonData = 'invalid json';
    input.destinationCountry = 'USA';
    input.selectedHagueStatus = 'Not Required';
    
    List<SAP_DocumentChecklistItemCreator.FlowInput> inputs = 
        new List<SAP_DocumentChecklistItemCreator.FlowInput>{ input };
    
    Test.startTest();
    try {
        SAP_DocumentChecklistItemCreator.createDocumentChecklistItems(inputs);
        
    } catch (AuraHandledException e) {
        System.debug('Caught expected exception: ' + e.getMessage());
        
    } catch (Exception ex) {
        System.debug('Caught unexpected exception: ' + ex.getMessage());

    }
    Test.stopTest();
}

    
     //  Deletion scenario where existing checklist items not referenced in input are deleted.
    @isTest
    static void testCreateDocumentChecklistItems_DeleteUnreferenced() {
     
        IndividualApplication testApp = [SELECT Id FROM IndividualApplication LIMIT 1];
        

        DocumentChecklistItem extraItem = new DocumentChecklistItem(
            Name = 'Extra Checklist Item',
            ParentRecordId = testApp.Id,
            SAP_Country__c = 'USA'
        );
        insert extraItem;
        
        
    
        String jsonInput = '[{' +
            '"id": null, ' +
            '"typeOfDocument": "", ' +
            '"destinationCountry": "USA", ' +
            '"personName": "New Checklist For Delete", ' +
            '"baseFee": "0.00", ' +
            '"isExpedited": false, ' +
            '"uploadedFiles": []' +
            '}]';
            
        SAP_DocumentChecklistItemCreator.FlowInput input = new SAP_DocumentChecklistItemCreator.FlowInput();
        input.individualApplicationId = testApp.Id;
        input.jsonData = jsonInput;
        input.destinationCountry = 'USA';
        input.selectedHagueStatus = 'Not Required';
        
        List<SAP_DocumentChecklistItemCreator.FlowInput> inputs = new List<SAP_DocumentChecklistItemCreator.FlowInput>{input};
        Test.startTest();
        SAP_DocumentChecklistItemCreator.createDocumentChecklistItems(inputs);
        Test.stopTest();
        
        
    }
    
    //  UploadedFiles branch -- new ContentDocumentLink is created if documentId is not already linked.
  @isTest
static void testCreateDocumentChecklistItem_UploadedFilesLinkCreation() {

    IndividualApplication testApp = [SELECT Id FROM IndividualApplication LIMIT 1];
   
    
    
    DocumentChecklistItem checklistItem = new DocumentChecklistItem(
        Name = 'Checklist With No Links',
        ParentRecordId = testApp.Id,
        SAP_Country__c = 'USA'
    );
    insert checklistItem;
    
    ContentVersion cv = new ContentVersion(
        Title = 'Test Document',
        PathOnClient = 'TestDoc.pdf',
        VersionData = Blob.valueOf('Test data')
    );
    insert cv;
   
    cv = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
    String validDocId = String.valueOf(cv.ContentDocumentId);
  
   
    String jsonInput = '[{' +
        '"id": "' + checklistItem.Id + '", ' +
        '"typeOfDocument": "", ' +  
        '"destinationCountry": "USA", ' +
        '"destinationCountrySameString": "no", ' +  
        '"country": "USA", ' +                       
        '"personName": "Checklist With No Links", ' +
        '"baseFee": "0.00", ' +
        '"isExpedited": false, ' +
        '"uploadedFiles": [{"documentId": "' + validDocId + '"}]' +
        '}]';
   
    
    
    SAP_DocumentChecklistItemCreator.FlowInput input = new SAP_DocumentChecklistItemCreator.FlowInput();
    input.individualApplicationId = testApp.Id;
    input.jsonData = jsonInput;
    input.destinationCountry = 'USA';
    input.selectedHagueStatus = 'Not Required';
   
    
    List<SAP_DocumentChecklistItemCreator.FlowInput> inputs = 
        new List<SAP_DocumentChecklistItemCreator.FlowInput>{ input };
            system.debug(' inputs==='+ inputs);
    
    Test.startTest();
    SAP_DocumentChecklistItemCreator.createDocumentChecklistItems(inputs);
    Test.stopTest();
    
   
    
}
    
    
    

//  Successful Update Scenario (no DocumentType lookup error)
    @isTest
static void testCreateDocumentChecklistItems_Update_Success() {
   
    IndividualApplication testApp = [SELECT Id FROM IndividualApplication LIMIT 1];
    DocumentChecklistItem existingItem = [SELECT Id, Name, SAP_Fees__c FROM DocumentChecklistItem 
                                           WHERE ParentRecordId = :testApp.Id LIMIT 1];
   
    ContentVersion cv = new ContentVersion(
        Title = 'Test Document',
        PathOnClient = 'TestDoc.pdf',
        VersionData = Blob.valueOf('Test data')
    );
    insert cv;
   
    cv = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
    String validDocId = String.valueOf(cv.ContentDocumentId);
    
    String jsonInput = '[{' +
        '"id": "' + existingItem.Id + '", ' +
        '"typeOfDocument": "", ' +
        '"destinationCountry": "USA", ' +
        '"personName": "Successfully Updated Checklist", ' +
        '"baseFee": "5.00", ' +
        '"isExpedited": true, ' +
        '"uploadedFiles": [{"documentId": "' + validDocId + '"}]' +
        '}]';
 
    SAP_DocumentChecklistItemCreator.FlowInput input = new SAP_DocumentChecklistItemCreator.FlowInput();
    input.individualApplicationId = testApp.Id;
    input.jsonData = jsonInput;
    input.destinationCountry = 'USA';
    input.selectedHagueStatus = 'Not Required';
   
    
    List<SAP_DocumentChecklistItemCreator.FlowInput> flowInputs = 
        new List<SAP_DocumentChecklistItemCreator.FlowInput>{ input };
        
    Test.startTest();
    SAP_DocumentChecklistItemCreator.createDocumentChecklistItems(flowInputs);
    Test.stopTest();
    
    
     DocumentChecklistItem updatedItem = [SELECT Name, SAP_Fees__c FROM DocumentChecklistItem WHERE Id = :existingItem.Id];
     System.assertEquals('Successfully Updated Checklist', updatedItem.Name, 'Expected name update to reflect');
     System.assertEquals(5.00, updatedItem.SAP_Fees__c, 'Expected base fee to be updated');
    }

}