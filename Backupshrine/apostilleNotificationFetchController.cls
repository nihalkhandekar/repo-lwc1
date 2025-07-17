public class apostilleNotificationFetchController {
    @AuraEnabled(cacheable=true)
    public static List<apostilleNotification__c> Notifications() {
        // Step 1: Retrieve the current user's ContactId - single query
        User currentUser = [
            SELECT ContactId 
            FROM User 
            WHERE Id = :UserInfo.getUserId()
            WITH SECURITY_ENFORCED
        ];

        if (currentUser.ContactId == null) {
            return new List<apostilleNotification__c>();
        }

        // Step 2: Retrieve all notifications in a single query
        List<apostilleNotification__c> specificUserNotification = [
            SELECT Id, Contact__c, description__c, iconName__c, isRead__c, Name, title__c, Type__c, 
                   CreatedDate, object_Name_For_Notification__c, object_Id_For_Notification__c 
            FROM apostilleNotification__c 
            WHERE Contact__c = :currentUser.ContactId 
            WITH SECURITY_ENFORCED
            ORDER BY CreatedDate DESC 
        ];

        // Step 3: Process deletions in a separate transaction
        if (!specificUserNotification.isEmpty()) {
            deleteNotificationsAsync(JSON.serialize(specificUserNotification));
        }

        // Step 4: Return the notifications list
        return specificUserNotification;
    }
 
    // Private method to handle the deletion logic asynchronously
    @future
    private static void deleteNotificationsAsync(String notificationsJson) {
        List<apostilleNotification__c> notifications = (List<apostilleNotification__c>)JSON.deserialize(
            notificationsJson, 
            List<apostilleNotification__c>.class
        );
        
        Set<Id> applicationIds = new Set<Id>();
        Map<Id, apostilleNotification__c> notificationsByApplicationId = new Map<Id, apostilleNotification__c>();

        for (apostilleNotification__c notification : notifications) {
            if (notification.object_Name_For_Notification__c == 'Individual Application' 
                && notification.object_Id_For_Notification__c != null) {
                applicationIds.add(notification.object_Id_For_Notification__c);
                notificationsByApplicationId.put(notification.object_Id_For_Notification__c, notification);
            }
        }

        if (applicationIds.isEmpty()) {
            return;
        }

        // Query existing applications in a single query
        Set<Id> existingApplicationIds = new Map<Id, IndividualApplication>([
            SELECT Id 
            FROM IndividualApplication 
            WHERE Id IN :applicationIds
            WITH SECURITY_ENFORCED
        ]).keySet();

        // Identify notifications to delete based on missing applications
        List<apostilleNotification__c> notificationsToDelete = new List<apostilleNotification__c>();
        for (Id applicationId : notificationsByApplicationId.keySet()) {
            if (!existingApplicationIds.contains(applicationId)) {
                notificationsToDelete.add(notificationsByApplicationId.get(applicationId));
            }
        }

        // Perform a single bulk delete operation if there are notifications to delete
        if (!notificationsToDelete.isEmpty()) {
            Database.delete(notificationsToDelete, false, AccessLevel.USER_MODE);
            System.debug('Deleted ' + notificationsToDelete.size() + ' notifications with non-existent records.');
        }
    }

    @AuraEnabled
    public static list<apostilleNotification__c> notificationsMoveToAllRead(String type,list<apostilleNotification__c> notificationFetchBack){
       // list<apostilleNotification__c> specificUserNotification = [select id,Contact__c,description__c, iconName__c, isRead__c, Name, title__c, Type__c,CreatedDate,object_Name_For_Notification__c,object_Id_For_Notification__c from apostilleNotification__c where Contact__c=:currentUser1.ContactId order by CreatedDate desc];
       // list<apostilleNotification__c> specificTypeNotification = [select id,Contact__c,description__c, iconName__c, isRead__c, Name, title__c, Type__c,CreatedDate,object_Name_For_Notification__c,object_Id_For_Notification__c from apostilleNotification__c where Type__c=:type and isRead__c=false order by CreatedDate desc];
       list<apostilleNotification__c> specificTypeNotification=notificationFetchBack;
        list<apostilleNotification__c> newList = new list<apostilleNotification__c>();
        for(apostilleNotification__c a1:specificTypeNotification){
            //system.debug('Before'+a1);
            a1.isRead__c=true;
            newList.add(a1);
            //system.debug('After'+a1);
           
        }
         User currentUser1 = [SELECT  ContactId FROM User where id=:UserInfo.getUserId() WITH SECURITY_ENFORCED];
      system.debug(newList);
       update newList;
       list<apostilleNotification__c> allNotification = [select id,Contact__c,description__c, iconName__c, isRead__c, Name, title__c, Type__c,CreatedDate,object_Name_For_Notification__c,object_Id_For_Notification__c from apostilleNotification__c where Contact__c=:currentUser1.ContactId WITH SECURITY_ENFORCED order by CreatedDate desc]; 
       //list<apostilleNotification__c> allNotification = [select id,Contact__c,description__c, iconName__c, isRead__c, Name, title__c, Type__c,CreatedDate,object_Name_For_Notification__c,object_Id_For_Notification__c from apostilleNotification__c where Contact__c='0033S00000dcFaMQAU' order by CreatedDate desc]; 
       
        
        system.debug(allNotification.size());
        system.debug(allNotification+'\n');
        return allNotification;     
    }

}