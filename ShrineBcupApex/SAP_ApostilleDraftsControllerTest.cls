@isTest
public class SAP_ApostilleDraftsControllerTest {
    @testSetup
    static void setupTestData() {
       
        RegulatoryAuthorizationType licenseType = new RegulatoryAuthorizationType(Name = 'Test License');
        insert licenseType;
        

        List<IndividualApplication> applications = new List<IndividualApplication>();

        for (Integer i = 0; i < 5; i++) {
            IndividualApplication app = new IndividualApplication();
            
            
            app.LicenseTypeId = licenseType.Id; 
            app.SAP_Organization_Name__c = 'Test Org ' + i;
            app.SAP_Sequence_Number__c = 'SEQ' + String.valueOf(i);
            app.SAP_First_Name__c = 'First ' + String.valueOf(i);
            app.SAP_Last_Name__c = 'Last ' + String.valueOf(i);
            app.SAP_Expedited__c = true;
            app.Category='License';
            app.SAP_Cancellation_Date__c = Date.valueOf('2025-02-20');
            app.AppliedDate = Date.valueOf('2025-02-17');

            
            if (Math.mod(i, 2) == 0) {
                app.Status = 'Draft';
            } else {
                app.Status = 'Cancelled By Customer';
            }

            applications.add(app);
        }

        insert applications; 
        
        List<DocumentChecklistItem> documents = new List<DocumentChecklistItem>();
        DocumentType docTypes = [SELECT Id FROM DocumentType WHERE MasterLabel= 'Vital Records'];


    for (IndividualApplication app : applications) {
        DocumentChecklistItem doc = new DocumentChecklistItem();
        doc.Name = app.SAP_First_Name__c;
        doc.ParentRecordId = app.Id; 
        doc.DocumentTypeId = docTypes.Id;  
        
        documents.add(doc);
    }

    insert documents;
        
        
    }
    
    @isTest
    static void testGetApplications_Draft() {
        Test.startTest();
        String paramsJson = '{"offsetVal":0, "pageSize":5, "sortBy":"ApplicationID", "sortDirection":"ASC"}';
        List<Map<String, Object>> result = SAP_ApostilleDraftsController.getApplications(paramsJson, 'Draft');
        Test.stopTest();
        
        System.assertNotEquals(0, result.size(), 'Expected non-empty result for Draft applications');
        
    }
     
    @isTest
    static void testGetApplications_Cancelled() {
        Test.startTest();
        String paramsJson = '{"offsetVal":0, "pageSize":5, "sortBy":"CancellationDate", "sortDirection":"DESC"}';
        List<Map<String, Object>> result = SAP_ApostilleDraftsController.getApplications(paramsJson, 'Cancelled By Customer');
        Test.stopTest();
        
        
        System.assertNotEquals(0, result.size(), 'Expected non-empty result for Cancelled applications');
        
    }
    
    
    @isTest
    static void testGetApplications_InvalidStatus() {
        Test.startTest();
        try {
            String paramsJson = '{"offsetVal":0, "pageSize":5, "sortBy":"ApplicationID", "sortDirection":"ASC"}';
            List<Map<String, Object>> result = SAP_ApostilleDraftsController.getApplications(paramsJson, 'InvalidStatus');
            System.assertEquals(0, result.size(), 'Expected empty result for invalid status');
            
        } catch (Exception e) {
            System.debug('Error occures ' + e.getMessage());
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetApplicationsCount() {
        Test.startTest();
        Integer count = SAP_ApostilleDraftsController.getApplicationsCount('Draft');
        Test.stopTest();
        
        System.assertEquals(3, count, 'Expected count to be exactly 3 for Draft applications');

    
    }
    
    @isTest
    static void testUpdateApplicationStatusToDraft_Success() {
        IndividualApplication app = [SELECT Id FROM IndividualApplication WHERE Status = 'Cancelled By Customer' LIMIT 1];

        Test.startTest();
        Boolean result = SAP_ApostilleDraftsController.updateApplicationStatusToDraft(app.Id);
        Test.stopTest();
        
        System.assertEquals(true, result, 'Expected update status to Draft to return true');

    }
      
    @isTest
    static void testUpdateApplicationStatusToDraft_Failure() {
        IndividualApplication app = [SELECT Id FROM IndividualApplication WHERE Status = 'Draft' LIMIT 1];

        Test.startTest();
        Boolean result = SAP_ApostilleDraftsController.updateApplicationStatusToDraft(app.Id);
        Test.stopTest();
        
        
        System.assertEquals(false, result, 'Expected update status to Draft to return false for already Draft status');

    }
}