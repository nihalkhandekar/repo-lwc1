@isTest(SeeAllData=false)
public class IndividualApplicationTriggerHelperTest {

    // Helper method to create test data for IndividualApplication
    private static IndividualApplication createIndividualApplication(String status, String recordTypeName) {
        // Create RecordType dynamically for testing
        RecordType recordType = [SELECT Id FROM RecordType WHERE SObjectType = 'IndividualApplication' AND Name = :recordTypeName LIMIT 1];

	    RegulatoryAuthorizationType regAuthType = new RegulatoryAuthorizationType(
            Name = 'TestRegulatoryAuthorizationType'
        );
        insert regAuthType;

        // Create the IndividualApplication with the given status and record type
        IndividualApplication app = new IndividualApplication(
            First_Name__c = 'John',
            Last_Name__c = 'Doe',
            Status = status,
		    LicenseTypeId = regAuthType.Id,
            Category = 'License',
            RecordTypeId = recordType.Id,
            Email_Address__c = 'john.doe@example.com',
            Email_Address_For_Receiving_Apostille__c = 'apostille@example.com'
        );
        insert app; // Insert the application to create a record in the database
        return app;
    }

    // Test for the generateSequence method
    @isTest
    static void testGenerateSequence() {
        // Create a few individual applications
        List<IndividualApplication> recordsToProcess = new List<IndividualApplication>();
        recordsToProcess.add(createIndividualApplication('Submitted', 'Apostille'));
        recordsToProcess.add(createIndividualApplication('Submitted', 'Finance System'));

        // Call the method to generate sequence numbers
        Test.startTest();
        IndividualApplicationTriggerHelper.generateSequence(recordsToProcess);
        Test.stopTest();

        // Verify that the sequence number is set correctly
        for (IndividualApplication app : recordsToProcess) {
            System.assertNotEquals(app.Sequence_Number__c, null, 'Sequence number should not be null');
            System.debug('Generated Sequence: ' + app.Sequence_Number__c);
        }
    }

    // Test for the sendStatusChangeEmails method
    @isTest
    static void testSendStatusChangeEmails() {
        // Create a list of individual applications
        IndividualApplication app1 = createIndividualApplication('Submitted', 'Apostille');

        // Update the application status to trigger email send
        app1.Status = 'Accepted';
        update app1;


    }

    // Test for the deleteRelatedRecords method
    @isTest
    static void testDeleteRelatedRecords() {
        // Create an IndividualApplication
        IndividualApplication app = createIndividualApplication('Cancelled', 'Apostille');

        // Create related records to be deleted
        apostilleNotification__c notification = new apostilleNotification__c(
            object_Id_For_Notification__c = app.Id
        );
        insert notification;

        RegulatoryTrxnFee fee = new RegulatoryTrxnFee(
            ParentRecordId = app.Id,
			Status = 'Paid'
        );
        insert fee;

        // Verify the related records exist
        List<apostilleNotification__c> notificationsBeforeDelete = [SELECT Id FROM apostilleNotification__c WHERE object_Id_For_Notification__c = :app.Id];
        List<RegulatoryTrxnFee> feesBeforeDelete = [SELECT Id FROM RegulatoryTrxnFee WHERE ParentRecordId = :app.Id];
        System.assertEquals(notificationsBeforeDelete.size(), 1, 'There should be one notification');
        System.assertEquals(feesBeforeDelete.size(), 1, 'There should be one fee');

        // Call the deleteRelatedRecords method
        Test.startTest();
        IndividualApplicationTriggerHelper.deleteRelatedRecords(new List<IndividualApplication>{app});
        Test.stopTest();

        // Verify the related records are deleted
        List<apostilleNotification__c> notificationsAfterDelete = [SELECT Id FROM apostilleNotification__c WHERE object_Id_For_Notification__c = :app.Id];
        List<RegulatoryTrxnFee> feesAfterDelete = [SELECT Id FROM RegulatoryTrxnFee WHERE ParentRecordId = :app.Id];
        System.assertEquals(notificationsAfterDelete.size(), 0, 'The notification should be deleted');
        System.assertEquals(feesAfterDelete.size(), 0, 'The fee should be deleted');
    }
}