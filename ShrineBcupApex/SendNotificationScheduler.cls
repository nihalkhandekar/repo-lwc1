global without sharing class SendNotificationScheduler implements Schedulable{
    public String account_SID;
    
	global void execute(SchedulableContext SC) {
        Interface_Configuration__mdt accountInfo = BOS_Utility.fetchInterfaceConfig('Twilio API');
        account_SID = accountInfo.API_Key__c;
		BOSSendNotification emailBatch = new BOSSendNotification(account_SID);
        Database.executeBatch(emailBatch);
   }
}