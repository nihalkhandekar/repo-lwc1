@IsTest
public class SAP_DocumentChecklistItemHandlerTest {

    @testSetup
    static void setupTestData() {
       
        RegulatoryAuthorizationType licenseType = new RegulatoryAuthorizationType(Name = 'Test License');
        insert licenseType;
       
        IndividualApplication testApp = new IndividualApplication(
            SAP_First_Name__c = 'John',
            SAP_Last_Name__c = 'Doe',
            SAP_Organization_Name__c = 'Test Org',
            SAP_Expedited__c = false,
            LicenseTypeId = licenseType.Id,
            Category = 'License'
        );
        insert testApp;
 
        
        
        String currentYear = String.valueOf(Date.today().year());
        DocumentChecklistItem certifiedItem = new DocumentChecklistItem(
            Name = 'Certified Item',
            ParentRecordId = testApp.Id,
            SAP_Country__c = 'USA',
            Status = 'Accepted',
            SAP_Certificate_Number__c = currentYear + '-00010',  // valid certificate number
            SAP_ApprovedDate__c = DateTime.now()
        );
        insert certifiedItem;
     
        
        DocumentChecklistItem pendingItem = new DocumentChecklistItem(
            Name = 'Pending Item',
            ParentRecordId = testApp.Id,
            SAP_Country__c = 'USA',
            Status = 'Pending',
            SAP_Certificate_Number__c = null
        );
        insert pendingItem;
        System.debug('Inserted Pending DocumentChecklistItem: ' + pendingItem);
    }
   
    @IsTest
    static void testHandleAfterUpdate_NoChanges() {
  
        IndividualApplication testApp = [SELECT Id FROM IndividualApplication LIMIT 1];
 
        DocumentChecklistItem doc = new DocumentChecklistItem(
            Name = 'AfterUpdate No Changes',
            ParentRecordId = testApp.Id,
            SAP_Country__c = 'USA',
            SAP_Fees__c = 10.00,
            SAP_SOTS_Certified_copy_number__c = '00001',
            SAP_Hague_Status__c = 'No',
            Status = 'Pending'
        );
        insert doc;
        
       
        Map<Id, DocumentChecklistItem> oldMap = new Map<Id, DocumentChecklistItem>{ doc.Id => doc.clone() };
        List<DocumentChecklistItem> newRecords = new List<DocumentChecklistItem>{ doc };
        
        Test.startTest();
        SAP_DocumentChecklistItemHandler.handleAfterUpdate(newRecords, oldMap);
        Test.stopTest();
        
        System.assertEquals(doc.Status, 'Pending');
       
    }
    
   
    @IsTest
    static void testHandleAfterUpdate_NoContentDocuments() {
  
        IndividualApplication testApp = [SELECT Id FROM IndividualApplication LIMIT 1];
        
        DocumentChecklistItem doc = new DocumentChecklistItem(
            Name = 'AfterUpdate No CD',
            ParentRecordId = testApp.Id,
            SAP_Country__c = 'USA',
            SAP_Fees__c = 20.00,
            SAP_SOTS_Certified_copy_number__c = '00002',
            SAP_Hague_Status__c = 'No',
            Status = 'Pending'
        );
        insert doc;
        DocumentChecklistItem oldDoc = doc.clone();
        doc.SAP_Country__c = 'Canada'; 
        
        Map<Id, DocumentChecklistItem> oldMap = new Map<Id, DocumentChecklistItem>{ doc.Id => oldDoc };
        List<DocumentChecklistItem> newRecords = new List<DocumentChecklistItem>{ doc };
        
        Test.startTest();
        SAP_DocumentChecklistItemHandler.handleAfterUpdate(newRecords, oldMap);
        Test.stopTest();
        
        System.assertEquals(doc.SAP_Country__c, 'Canada');
       
    }
    
   
    @IsTest
    static void testHandleAfterUpdate_WithContentDocumentDeletion() {
        
        IndividualApplication testApp = [SELECT Id FROM IndividualApplication LIMIT 1];
        
        DocumentChecklistItem doc = new DocumentChecklistItem(
            Name = 'AfterUpdate With CD',
            ParentRecordId = testApp.Id,
            SAP_Country__c = 'USA',
            SAP_Fees__c = 30.00,
            SAP_SOTS_Certified_copy_number__c = '00003',
            SAP_Hague_Status__c = 'No',
            Status = 'Pending'
        );
        insert doc;
        DocumentChecklistItem oldDoc = doc.clone();
        doc.SAP_Country__c = 'Mexico'; // Change a field to trigger update.
        
        Map<Id, DocumentChecklistItem> oldMap = new Map<Id, DocumentChecklistItem>{ doc.Id => oldDoc };
        List<DocumentChecklistItem> newRecords = new List<DocumentChecklistItem>{ doc };
        
        // Create a ContentVersion with Title containing 'Apostille_Document' to match the deletion criteria.
        ContentVersion cv = new ContentVersion(
            Title = 'Apostille_Document - Test',
            PathOnClient = 'TestDoc.pdf',
            VersionData = Blob.valueOf('Test data')
        );
        insert cv;
        cv = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
        String validDocId = String.valueOf(cv.ContentDocumentId);
        
        // Create a ContentDocumentLink linking the ContentDocument to our checklist item.
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = validDocId,
            LinkedEntityId = doc.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert cdl;
        
        Test.startTest();
        SAP_DocumentChecklistItemHandler.handleAfterUpdate(newRecords, oldMap);
        Test.stopTest();
        
        List<ContentDocument> docsAfterDeletion = [SELECT Id FROM ContentDocument WHERE Id = :validDocId];
        System.assertEquals(0, docsAfterDeletion.size(), 'ContentDocument should be deleted');
       
    }
}