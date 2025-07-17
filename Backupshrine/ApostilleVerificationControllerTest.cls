@isTest(SeeAllData=false)
private class ApostilleVerificationControllerTest {

    @isTest(SeeAllData=false)
    static void testGetApplications() {

        Contact testContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            position__c = 'Deputy Clerk'
        );
        insert testContact;
	
		RegulatoryAuthorizationType regAuthType = new RegulatoryAuthorizationType(
		Name = 'TestRegulatoryAuthorizationType'
        );
		insert regAuthType;

        IndividualApplication testApplication = new IndividualApplication(
		LicenseTypeId = regAuthType.Id,
        Category = 'License'
        );
        insert testApplication;

        DocumentChecklistItem testDoc1 = new DocumentChecklistItem(
			Name = 'testDocumentChecklistItem',
            Certificate_Number__c = 'CERT123',
            ParentRecordId = testApplication.Id,
            Country__c = 'USA',
            Status = 'Approved',
	        Signed_By__c = testContact.Id,
            ApprovedDate__c = System.now()
        );
        insert testDoc1;

        Test.startTest();
        List<Map<String, Object>> result = ApostilleVerificationController.getApplications('CERT123');
        Test.stopTest();

        System.assertNotEquals(result, null, 'The result should not be null.');
        System.assertEquals(result.size(), 1, 'The result should contain exactly one record.');

        Map<String, Object> record = result[0];
        System.assertEquals(record.get('certificateNumber'), 'CERT123', 'The certificate number should match.');
        System.assertEquals(record.get('signedBy'), 'John Doe', 'The Signed By name should match.');
        System.assertEquals(record.get('officialCapacity'), 'Deputy Clerk', 'The official capacity should match.');
        System.assertEquals(record.get('status'), 'Approved', 'The status should match.');
        System.assertEquals(record.get('countryToBeUsed'), 'USA', 'The country should match.');

        // Check if the approved date is correctly formatted
        String formattedDate = (String) record.get('approvedDate');
        System.assert(formattedDate.contains('/'), 'The approved date should be in MM/DD/YYYY format.');
    }

    @isTest(SeeAllData=false)
    static void testGetApplicationsNoRecords() {
        // Step 1: Call the method with a certificate number that doesn't exist
        Test.startTest();
        List<Map<String, Object>> result = ApostilleVerificationController.getApplications('NONEXISTENT123');
        Test.stopTest();

        // Step 2: Validate the result
        System.assertEquals(result.size(), 0, 'The result should contain no records.');
    }
}