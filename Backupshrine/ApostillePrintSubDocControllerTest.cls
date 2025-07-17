@isTest(SeeAllData=false)
public class ApostillePrintSubDocControllerTest {
	
    @isTest(SeeAllData=false)
    static void testGetDocDetailsWithExpeditedTrue(){
        
        RegulatoryAuthorizationType regAuthType = new RegulatoryAuthorizationType(
            Name = 'TestRegulatoryAuthorizationType'
            );
		insert regAuthType;
        
		IndividualApplication testApplication = new IndividualApplication(
            LicenseTypeId = regAuthType.Id,
            Category = 'License',
            First_Name__c = 'John',
            Last_Name__c = 'Doe',
            Organization_Name__c = 'Test Org',
            Expedited__c = true,
            Sequence_Number__c = '1'
            );
        insert testApplication;

        DocumentChecklistItem doc1 = new DocumentChecklistItem(
			Name = 'Document1',
            Certificate_Number__c = 'CERT123',
            ParentRecordId = testApplication.Id,
            Country__c = 'USA',
            Requester_Name__c = 'Martin William',
            Hague_Status__c = 'Active',
            Fees__c = 100
        );

        DocumentChecklistItem doc2 = new DocumentChecklistItem(
            Name = 'Document2',
            ParentRecordId = testApplication.Id,
            Country__c = 'CANADA',
            Requester_Name__c = 'Jane Doe',
            Hague_Status__c = 'Inactive',
            Fees__c = 200
        );
        
        insert new List<DocumentChecklistItem>{doc1, doc2};

        Test.startTest();
        Map<String, Object> result = ApostillePrintSubmissionDocController.getDocDetails(testApplication.Id);
        Test.stopTest();

	    List<Map<String, Object>> documentList = (List<Map<String, Object>>) result.get('documents');
        System.assertEquals(2, documentList.size());

        Decimal expectedFeesForDoc1 = 100 - 50; // Expedited reduces fees by 50
        Decimal expectedFeesForDoc2 = 200 - 50; // Expedited reduces fees by 50

        System.assertEquals(expectedFeesForDoc1, documentList[0].get('fees'));
        System.assertEquals(expectedFeesForDoc2, documentList[1].get('fees'));

		Map<String, Object> individualAppData = (Map<String, Object>) result.get('individualApplication');
        System.assertEquals('Test Application', individualAppData.get('name'));
        System.assertEquals(50 * documentList.size(), individualAppData.get('expedited')); // Expedited fee is 50 * number of documents
        System.assertEquals(expectedFeesForDoc1 + expectedFeesForDoc2 + 50 * documentList.size(), individualAppData.get('finalTotal'));

    }



}