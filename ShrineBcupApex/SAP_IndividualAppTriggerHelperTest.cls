@isTest
private class SAP_IndividualAppTriggerHelperTest {

    static Id recordTypeId;

    @testSetup
    static void setupTestData() {
        // Fetch RecordTypeId dynamically
        recordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'IndividualApplication' AND Name = 'Apostille' LIMIT 1].Id;
        
        RegulatoryAuthorizationType licenseType = new RegulatoryAuthorizationType(Name = 'Test License');
        insert licenseType;
        
        // Create test IndividualApplication records
        List<IndividualApplication> testApps = new List<IndividualApplication>();
        for (Integer i = 0; i < 3; i++) {
            testApps.add(new IndividualApplication(
                LicenseTypeId = licenseType.Id,
                RecordTypeId = recordTypeId,
                SAP_First_Name__c = 'Test',
                SAP_Last_Name__c = 'User' + i,
                SAP_Email_Address__c = 'testuser' + i + '@example.com',
                Email_Address_For_Receiving_Apostille__c = 'recipient' + i + '@example.com',
                Category='License',
                Status = 'In Progress'
            ));
        }
        insert testApps;
    }

    @isTest
    static void testGenerateSequence() {
        List<IndividualApplication> apps = [SELECT Id, RecordTypeId, SAP_Sequence_Number__c FROM IndividualApplication];
        
        Test.startTest();
        SAP_IndividualApplicationTriggerHelper.generateSequence(apps);
        Test.stopTest();

        // Validate that sequence numbers are generated
        for (IndividualApplication app : apps) {
            System.assertNotEquals(null, app.SAP_Sequence_Number__c, 'Sequence number should be assigned');
            System.assert(app.SAP_Sequence_Number__c.startsWith('APO-'), 'Sequence number prefix should match record type');
        }
    }

    @isTest
    static void testSendStatusChangeEmails() {
        List<IndividualApplication> apps = [SELECT Id, SAP_Sequence_Number__c, SAP_First_Name__c, SAP_Last_Name__c, SAP_Email_Address__c, Email_Address_For_Receiving_Apostille__c FROM IndividualApplication];

        Test.startTest();
        SAP_IndividualApplicationTriggerHelper.sendStatusChangeEmails(apps, true, false);
        Test.stopTest();


    }

    @isTest
    static void testDeleteRelatedRecords() {
        // Fetch test applications
        List<IndividualApplication> apps = [SELECT Id FROM IndividualApplication LIMIT 2];

        // Create related apostilleNotification__c records
        List<apostilleNotification__c> notifications = new List<apostilleNotification__c>();
        for (IndividualApplication app : apps) {
            notifications.add(new apostilleNotification__c(object_Id_For_Notification__c = app.Id));
        }
        insert notifications;

        // Create related RegulatoryTrxnFee records
        List<RegulatoryTrxnFee> fees = new List<RegulatoryTrxnFee>();
        for (IndividualApplication app : apps) {
            fees.add(new RegulatoryTrxnFee(ParentRecordId = app.Id,Status = 'DRAFT'));
            
        }
        insert fees;

        Test.startTest();
        SAP_IndividualApplicationTriggerHelper.deleteRelatedRecords(apps);
        Test.stopTest();

    }
}