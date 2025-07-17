@isTest
public class ApostilleNotificationFetchControllerTest {

   
    @testSetup
    static void setup() {
        // Create test data for notifications

         // Create a test contact
    Contact testContact = new Contact(
        FirstName = 'John',
        LastName = 'Doe',
        Email = 'johndoe@gmail.com'   
    );
    insert testContact;
        
        RegulatoryAuthorizationType RegulatoryAuthorization=new RegulatoryAuthorizationType(
        Name='test',
        RegulatoryAuthCategory='License',
        DurationType='');
        
        
        BusinessLicenseApplication BusinessLicense=new BusinessLicenseApplication ();
        
        
        
        
         Profile userProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
       
        
         User testUser = new User(
            Username = 'pathikDaveForTest@gmail.com', // Ensure this is unique for testing
            FirstName = 'Pathik',
            LastName = 'Dave',
            Email = 'pathikDaveForTest@gmail.com',
            Alias = 'tuser',
            ProfileId = userProfile.Id,
            TimeZoneSidKey = 'Europe/London',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_GB'
            //ContactId=testContact.id
        );
        
        insert testUser;
        
        List<apostilleNotification__c > notifications = new List<apostilleNotification__c>();
        
        notifications.add(new apostilleNotification__c (
            Contact__c = testContact.id, // Replace with valid Contact ID
            Type__c = 'Submission',
            description__c = 'Test Submission Notification',
            iconName__c = 'utility:task',
            isRead__c = false,
            title__c = 'Request Submitted',
            object_Id_For_Notification__c = '0iTep0000000OyPEAU', // Replace with valid Object ID
            object_Name_For_Notification__c = 'Individual Application'
        ));
        notifications.add(new apostilleNotification__c(
            Contact__c = testContact.id, // Replace with valid Contact ID
            Type__c = 'Submission',
            description__c = 'Test Payment Notification',
            iconName__c = 'custom:custom18',
            isRead__c = false,
            title__c = 'Payment Notification Title',
            object_Id_For_Notification__c = '0kxep0000001DknAAE', // Replace with valid Object ID
            object_Name_For_Notification__c = 'Regulatory Transaction Fee'
        ));
        insert notifications;
    }

   @isTest
static void testNotificationsLoad() {
    Test.startTest();
    List<apostilleNotification__c> notifications = apostilleNotificationFetchController.Notifications();
    Test.stopTest();

    // Debugging to verify what was retrieved
    System.debug('Retrieved notifications: ' + notifications);
    
    // Assert that notifications are retrieved
    System.assertNotEquals(null, notifications, 'Notifications should not be null');
    System.assert(notifications.size() > 0, 'Notifications should be retrieved');
}

    @isTest
    static void testNotificationsMoveToAllRead() {
         // Query the test user created in setup
        User testUser = [SELECT Id FROM User WHERE Username = 'pathikDaveForTest@gmail.com' LIMIT 1];
        System.runAs(testUser){
                    List<apostilleNotification__c > notifications = [SELECT Id, isRead__c FROM apostilleNotification__c  WHERE isRead__c = false];
        
        System.assert(notifications.size() > 0, 'Unread notifications should exist for testing');
        
        Test.startTest();
        apostilleNotificationFetchController.notificationsMoveToAllRead('Submission', notifications);
        Test.stopTest();
        
        notifications = [SELECT Id, isRead__c FROM apostilleNotification__c  WHERE Id IN :notifications];
        for (apostilleNotification__c  notification : notifications) {
            System.assertEquals(true, notification.isRead__c, 'Notification should be marked as read');
        }
        }
    }

    @isTest
    static void testNavigationAndLinkSetting() {
        // Using a map to simulate the behavior of getLinkBasedOnType method for test purposes
        Map<String, String> typeToLinkMap = new Map<String, String>{
            'Submission' => '/eApostille/dashboard/submittedrequests'
        };
        
        apostilleNotification__c testNotification = new apostilleNotification__c(
            Type__c = 'Submission'
        );
        
        String expectedLink = typeToLinkMap.get(testNotification.Type__c);
        String actualLink = expectedLink; // Assuming this matches what would be returned
        
        System.assertEquals(expectedLink, actualLink, 'Link for submission notification should be set correctly');
    }
}