/*********************************************************************************************
* NAME:  BOSSendNotification_Test
* DESCRIPTION: Test class for BOSSendNotification
* 				 
*
* @AUTHOR: Piyush Jogdand
* @DATE: 9/1/2020
*
*
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* ----------------------------------------------------------------------------
  Piyush Jogdand				  9/28/2020                              Created
*********************************************************************************************/
@isTest
private class BOSSendNotification_Test {
    @testSetup 
    private static void initData() {
        Map<Account,List<Contact>> AccountsVsContacts = QnA_TestDataFactory.createAccountWithContacts();
        Account acc = [Select Id From Account limit 1];
        Credential__c cred = QnA_TestDataFactory.createCredential();
        Account_Credential_Relationship__c relation = QnA_TestDataFactory.createAccountCredRelation(acc.Id,cred.Id);
        Action_Item__c item = QnA_TestDataFactory.createActionItem('Open',acc.Id,cred.Id);
		Contact con = [Select Id From Contact limit 1];
        item.Contact__c = con.Id;
        update item;
    }
    
	@isTest
    private static void BOSSendNotification_test(){
        Test.startTest();
        DataBase.executeBatch(new BOSSendNotification('123'));
        Test.stopTest();
    }
    @isTest
    private static void BOSTwilioSMSService_test(){
        Test.startTest();
        	BOSTwilioSMSService.sendSMS('','','');
        Test.stopTest();
    }
	@isTest
    private static void SendNotificationScheduler_test(){
        Test.startTest();
        try{
        	SendNotificationScheduler scheduler = new SendNotificationScheduler();
            String sch = '0 0 23 * * ?';
            system.schedule('Test SendNotificationScheduler', sch, scheduler);
        }catch(Exception e){
            system.assertNotEquals(null, e);
        }
        Test.stopTest();
    }
}