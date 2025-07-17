global class BOS_SendResourceNotificationScheduler implements Schedulable{

    global void execute(SchedulableContext sc) {
        Interface_Configuration__mdt accountInfo = BOS_Utility.fetchInterfaceConfig('Twilio API');
        String account_SID = accountInfo.API_Key__c;
        BOS_SendResourceNotification batch = new BOS_SendResourceNotification(account_SID);
        Database.executeBatch(batch,1);
    }
    
}