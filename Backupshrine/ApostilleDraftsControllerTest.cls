@isTest
public class ApostilleDraftsControllerTest {
    
	@isTest
	static void testGetApplications_Cancelled() {
    	RegulatoryAuthorizationType licenseType = new RegulatoryAuthorizationType(Name = 'Extradition License');
    	insert licenseType;
    
    	DocumentType docType = [SELECT Id, MasterLabel FROM DocumentType WHERE MasterLabel = 'Vital Records' LIMIT 1];
    	List<IndividualApplication> applications = new List<IndividualApplication>();
    
    	for (Integer i = 0; i < 5; i++) {
        	applications.add(new IndividualApplication(
            	Status = 'Cancelled', Organization_Name__c = 'Org ' + i, Sequence_Number__c = String.valueOf(i + 1), First_Name__c = 'First ' + i, Last_Name__c = 'Last ' + i,
            	Expedited__c = false, Address_Line_1__c = '123 Test St', City__c = 'Test City', State__c = 'TS', Zip_Code__c = '12345', Country__c = 'Test Country',
            	Category = 'Permit', LicenseTypeId = licenseType.Id, Cancellation_Type__c = 'Type ' + i, Cancellation_Date__c = System.today(),
            	Reason_for_Cancellation__c = 'Reason ' + i, AppliedDate = System.now().addDays(-1)
        	));
    	}
    	insert applications;

    	String paramsJson = '{"offsetVal":0,"pageSize":5,"sortBy":"CancellationType","sortDirection":"ASC"}';
    	String status = 'Cancelled';
        
    	List<DocumentChecklistItem> docs = new List<DocumentChecklistItem>();
    	for (Integer i = 0; i < 3; i++) { 
        	docs.add(new DocumentChecklistItem(
            	ParentRecordId = applications[i].Id, DocumentTypeId = docType.Id, Name = 'Document ' + i
        	));
    	}
    	insert docs;
        
    	Test.startTest();
    	List<Map<String, Object>> result = ApostilleDraftsController.getApplications(paramsJson, status);
    	Test.stopTest();
        
    	System.assertNotEquals(null, result);
    	System.assertEquals(5, result.size());
    	System.assertEquals('Org 0', result[0].get('requestorName'));
    	System.assertEquals('Type 0', result[0].get('CancellationType'));
    	System.assertEquals('Reason 0', result[0].get('ReasonForCancellation'));
		System.assertEquals('', result[3].get('documentType'), 'Expected empty string for documentType as no document exists for this application');
    	System.assertEquals('', result[4].get('documentType'), 'Expected empty string for documentType as no document exists for this application');

    	Boolean exceptionThrown = false;
    	try {
        	ApostilleDraftsController.getApplications('{"invalidJson"}', status);
    	} catch (Exception e) {
        	exceptionThrown = true;
        	System.assert(e instanceof AuraHandledException, 'Expected AuraHandledException but got a different exception type.');
    	}

    	System.assert(exceptionThrown, 'Expected AuraHandledException was not thrown.');
	}

	@isTest
	static void testGetApplications_Draft() {
    	RegulatoryAuthorizationType licenseType = new RegulatoryAuthorizationType(Name = 'Extradition License');
    	insert licenseType;
    
    	DocumentType docType = [SELECT Id, MasterLabel FROM DocumentType WHERE MasterLabel = 'Vital Records' LIMIT 1];
     	List<IndividualApplication> applications = new List<IndividualApplication>();
    
    	for (Integer i = 0; i < 5; i++) {
        	applications.add(new IndividualApplication(
            	Status = 'Draft', Organization_Name__c = 'Org ' + i, Sequence_Number__c = String.valueOf(i + 1), First_Name__c = 'First ' + i,
            	Last_Name__c = 'Last ' + i, Expedited__c = false, Address_Line_1__c = '123 Test St', City__c = 'Test City', State__c = 'TS',
             	Zip_Code__c = '12345', Country__c = 'Test Country, ', Category = 'Permit', LicenseTypeId = licenseType.Id
        	));
    	}
    	insert applications;

    	List<DocumentChecklistItem> docs = new List<DocumentChecklistItem>();
    	for (Integer i = 0; i < 5; i++) {
        	docs.add(new DocumentChecklistItem(
            	ParentRecordId = applications[i].Id, DocumentTypeId = docType.Id, Name = 'Document ' + i
        	));
    	}
    	insert docs;

    	String paramsJson = '{"offsetVal":0,"pageSize":5,"sortBy":"ApplicationID","sortDirection":"ASC"}';
    	String status = 'Draft';

    	Test.startTest();
    	List<Map<String, Object>> result = ApostilleDraftsController.getApplications(paramsJson, status);
    	Test.stopTest();

    	System.assertNotEquals(null, result);
    	System.assertEquals(5, result.size());
    	System.assertEquals('Org 0', result[0].get('requestorName'));
    
    	String address = (String) result[0].get('address');
    	System.assertNotEquals(null, address);
    	System.assert(address.endsWith(',') == false, 'Address should not end with a comma');
	}

	@isTest
	static void testProcessDocuments() {
    	RegulatoryAuthorizationType licenseType = new RegulatoryAuthorizationType(Name = 'Extradition License');
    	insert licenseType;
    
    	DocumentType docType = [SELECT Id, MasterLabel FROM DocumentType WHERE MasterLabel = 'Vital Records' LIMIT 1];
    
    	IndividualApplication app = new IndividualApplication(
        	Sequence_Number__c = '123', Category = 'Permit', First_Name__c = 'John', Last_Name__c = 'Doe', Expedited__c = false, LicenseTypeId = licenseType.Id
    	);
    	insert app;
    
    	List<DocumentChecklistItem> docs = new List<DocumentChecklistItem>();
    	for (Integer i = 0; i < 5; i++) {
        	DocumentChecklistItem doc = new DocumentChecklistItem(
            	Name = 'Test' + i, ParentRecordId = app.Id, DocumentTypeId = docType.Id
        	);
        	docs.add(doc);
    	}
    	insert docs;
    
    	Test.startTest();
    	String requestorName = app.First_Name__c + ' ' + app.Last_Name__c;
    	List<Map<String, Object>> result = ApostilleDraftsController.processDocuments(docs, app, requestorName);
    	Test.stopTest();

    	System.assertEquals(4, result.size(), 'Expected 4 documents');
    
    	for (Integer i = 0; i < result.size(); i++) {
        	Map<String, Object> document = result[i];
        	DocumentChecklistItem expectedDoc = docs[i + 1];
        
        	System.debug('Expected DocumentType.MasterLabel: ' + expectedDoc.DocumentType.MasterLabel);    
        	System.assertEquals(expectedDoc.Id, document.get('Id'), 'Document Id should match');
        	System.assertEquals(app.Sequence_Number__c, document.get('ApplicationID'), 'Application ID should match');
        	System.assertEquals(requestorName, document.get('requestorName'), 'Requestor name should match');
        	System.assertEquals(app.Expedited__c, document.get('Expedited'), 'Expedited value should match');
        	System.assertEquals(expectedDoc.DocumentType.MasterLabel, document.get('documentType'), 'Document type label should match');
    	}
	}
    
      @isTest
      static void testGetApplicationsCount() {
        RegulatoryAuthorizationType licenseType = new RegulatoryAuthorizationType(Name = 'Extradition License');
        insert licenseType;

        List<IndividualApplication> applications = new List<IndividualApplication>{
            new IndividualApplication(Status = 'Cancelled', LicenseTypeId = licenseType.Id, Category = 'Permit'),
            new IndividualApplication(Status = 'Cancelled', LicenseTypeId = licenseType.Id, Category = 'Permit'),
            new IndividualApplication(Status = 'Draft', LicenseTypeId = licenseType.Id, Category = 'Permit'),
            new IndividualApplication(Status = 'Draft', LicenseTypeId = licenseType.Id, Category = 'Permit'),
            new IndividualApplication(Status = 'In Progress', LicenseTypeId = licenseType.Id, Category = 'Permit')
        };
        insert applications;

        Test.startTest();
        Integer cancelledCount = ApostilleDraftsController.getApplicationsCount('Cancelled');
        System.assertEquals(2, cancelledCount, 'The count for Cancelled applications should be 2.');

        // Test the count for 'Draft' status
        Integer draftCount = ApostilleDraftsController.getApplicationsCount('Draft');
        System.assertEquals(2, draftCount, 'The count for Draft applications should be 2.');

        // Test the count for 'In Progress' status
        Integer inProgressCount = ApostilleDraftsController.getApplicationsCount('In Progress');
        System.assertEquals(1, inProgressCount, 'The count for In Progress applications should be 1.');

        // Test the count for a status with no applications
        Integer unknownCount = ApostilleDraftsController.getApplicationsCount('Unknown Status');
        System.assertEquals(0, unknownCount, 'The count for Unknown Status applications should be 0.');
        Test.stopTest();
    }
    
	@isTest
	static void testUpdateApplicationStatusToDraft() {
    	RegulatoryAuthorizationType licenseType = new RegulatoryAuthorizationType(Name = 'Extradition License');
    	insert licenseType;

    	IndividualApplication app = new IndividualApplication(
        	Status = 'Cancelled', LicenseTypeId = licenseType.Id, Category = 'Permit', Cancellation_Type__c = 'Type A',
        	Cancellation_Date__c = System.today(), Reason_for_Cancellation__c = 'Test Reason', AppliedDate = System.now().addDays(-1)
    	);
    	insert app;

    	// Test successful update scenario
    	Test.startTest();
    	Boolean result = ApostilleDraftsController.updateApplicationStatusToDraft(app.Id);
    	Test.stopTest();

    	System.assertEquals(true, result, 'Expected update result to be true');
    	app = [SELECT Status FROM IndividualApplication WHERE Id = :app.Id LIMIT 1];
    	System.assertEquals('Draft', app.Status, 'Expected status to be updated to Draft');

    	// Test exception scenario by passing an invalid ID
    	Boolean resultWithInvalidId = ApostilleDraftsController.updateApplicationStatusToDraft('invalidId');
    	System.assertEquals(false, resultWithInvalidId, 'Expected result to be false when an invalid ID is used');
    }
    
    @isTest
    static void testUpdateApplicationStatusToDraft_NotCancelled() {
        RegulatoryAuthorizationType licenseType = new RegulatoryAuthorizationType(Name = 'Extradition License');
        insert licenseType;

        IndividualApplication app = new IndividualApplication(
            Status = 'Draft', LicenseTypeId = licenseType.Id, Category = 'Permit'
        );
        insert app;

        Test.startTest();
        Boolean result = ApostilleDraftsController.updateApplicationStatusToDraft(app.Id);
        Test.stopTest();

        System.assertEquals(false, result);
        app = [SELECT Status FROM IndividualApplication WHERE Id = :app.Id LIMIT 1];
        System.assertEquals('Draft', app.Status);
    }
}