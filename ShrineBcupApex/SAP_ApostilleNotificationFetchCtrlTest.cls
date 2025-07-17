@isTest
public class SAP_ApostilleNotificationFetchCtrlTest {
    private static Id testContactId;
    
     @testSetup
    static void setupTestData() {
       
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'User');
        insert testContact;
        testContactId = testContact.Id;
        System.debug('Inserted Contact: ' + testContact);

        List<apostilleNotification__c> notifications = new List<apostilleNotification__c>();
        for (Integer i = 0; i < 5; i++) {
            apostilleNotification__c notification = new apostilleNotification__c(
                Contact__c = testContact.Id, // Directly associate the Contact
                description__c = 'Test Notification ' + i,
                iconName__c = 'utility:notification',
                isRead__c = false,
                title__c = 'Test Title ' + i,
                Type__c = 'Payment',
                object_Name_For_Notification__c = 'Individual Application',
                object_Id_For_Notification__c = null // Simulating missing application
            );
            notifications.add(notification);
        }
        insert notifications;
        
    }
    @isTest
    static void testNotifications() {

        Test.startTest();
        List<apostilleNotification__c> notifications = SAP_ApostilleNotificationFetchController.Notifications();
        Test.stopTest();

       
    }

    @isTest
    static void testNotificationsMoveToAllRead() {
       

        List<apostilleNotification__c> notifications = [SELECT Id, isRead__c FROM apostilleNotification__c WHERE isRead__c = false];
       

        Test.startTest();
        List<apostilleNotification__c> updatedNotifications = SAP_ApostilleNotificationFetchController.notificationsMoveToAllRead('General', notifications);
        Test.stopTest();

    }
}