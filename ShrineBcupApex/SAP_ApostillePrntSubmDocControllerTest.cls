@isTest
public class SAP_ApostillePrntSubmDocControllerTest {
    
    @TestSetup
    static void setupTestData() {
        
        RegulatoryAuthorizationType licenseType = new RegulatoryAuthorizationType(Name = 'Test License');
        insert licenseType;        
        
        IndividualApplication testApplication = new IndividualApplication(
            SAP_First_Name__c = 'John',
            SAP_Last_Name__c = 'Doe',
            SAP_Organization_Name__c = 'Test Org',
            SAP_Sequence_Number__c = 'SEQ-001',
            SAP_Expedited__c = true,
            LicenseTypeId = licenseType.Id,
            Category='License'
        );
        insert testApplication;

        
        List<DocumentType> docTypes = [SELECT Id, MasterLabel FROM DocumentType WHERE MasterLabel IN ('SOTS Certified Copies', 'Vital Records')];

        
        Map<String, Id> docTypeMap = new Map<String, Id>();
        for (DocumentType dt : docTypes) {
            docTypeMap.put(dt.MasterLabel, dt.Id);
        }

       
        if (!docTypeMap.containsKey('SOTS Certified Copies') ) {
            System.debug('Required DocumentType records are missing. Please create them in Salesforce.');
        }

        
        List<DocumentChecklistItem> docItems = new List<DocumentChecklistItem>();

       
        docItems.add(new DocumentChecklistItem(
            Name = 'Test Document 1',
            ParentRecordId = testApplication.Id,
            SAP_Fees__c = 100,
            SAP_Hague_Status__c = 'Yes',
            SAP_Requester_Name__c = 'John Requester',
            SAP_Country__c = 'USA',
            SAP_SOTS_Certified_copy_number__c = 'SOTS-001',
            DocumentTypeId = docTypeMap.get('SOTS Certified Copies')
        ));

        
        docItems.add(new DocumentChecklistItem(
            Name = 'Test Document 2',
            ParentRecordId = testApplication.Id,
            SAP_Fees__c = 150,
            SAP_Hague_Status__c = 'Yes',
            SAP_Requester_Name__c = 'Doe Requester',
            SAP_Country__c = 'Canada',
            DocumentTypeId = docTypeMap.get('Vital Records')
        ));

        insert docItems;
    }

    @isTest
    static void testGetDocDetails() {
       
        IndividualApplication testApplication = [SELECT Id FROM IndividualApplication LIMIT 1];

        Test.startTest();
    
        Map<String, Object> result = SAP_ApostillePrntSubmDocController.getDocDetails(testApplication.Id);
        Test.stopTest();

        
       System.assertNotEquals(null, result, 'Expected result should not be null.');
       System.assert(result.containsKey('documents'), 'Result should contain document details.');
       
    }
}