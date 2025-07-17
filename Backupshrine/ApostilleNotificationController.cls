public class ApostilleNotificationController {
    @AuraEnabled
    public static void sendReviewNotification(Id userId) {
        try {
            // Create the notification
            CustomNotificationType customNotify = [SELECT Id, CustomNotifTypeName from CustomNotificationType where CustomNotifTypeName='Apostille Review Notification'];
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setTitle('Request Under Review');
            notification.setBody('Your Apostille request is currently under review.');
            notification.setNotificationTypeId(customNotify.Id);
            notification.setTargetId('0053S000002lOCrQAM'); // Set the target ID to the user ID

            // Send the notification
            notification.send(new Set<String>{userId});
        } catch (Exception e) {
            System.debug('Error sending custom notification: ' + e.getMessage());
        }
    }
}