/*********************************************************************************************
* NAME:  BOS_ResourceNotificationUtility_Test
* DESCRIPTION: Test class for BOS_ResourceNotificationUtility
*
* MODIFICATION LOG:
* DEVELOPER                 DATE                               DESCRIPTION
* ----------------------------------------------------------------------------
* Himanshi Mayal           4/6/21                    Test class for BOS_ResourceNotificationUtility
*********************************************************************************************/
@isTest
private class BOS_ResourceNotificationUtility_Test {
    @isTest(SeeAllData=true)
    private static void isResourceNotificationEnabledFalse_Test(){
        Test.startTest();
        Account ac1 = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(System.label.ActionItem_AccountRecordType).getRecordTypeId(),
            Name ='test123',
            Status__c = System.Label.ACTIVE
        );
        insert ac1;
        Contact con = new Contact(LastName ='testCon1',Email='abcd@gmail.com',AccountId = ac1.Id,Due_date_reminders_email_notification__c=true,Resource_Email_Notification__c=true);
        insert con;
        Boolean retVal;
        User u =[Select ID,ContactID from User where usertype ='Guest' AND Name = 'business Site Guest User' LIMIT 1];
        System.runAs(u) {
            retVal = BOS_ResourceNotificationUtility.isResourceNotificationEnabled();
        }
        System.assertEquals(false, retVal);
        Test.stopTest();
    }
    @isTest
    private static void isResourceNotificationEnabledTrue_Test(){
        Test.startTest();
        Account ac1 = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(System.label.ActionItem_AccountRecordType).getRecordTypeId(),
            Name ='test123',
            Status__c = System.Label.ACTIVE
        );
        insert ac1;
        Id profileId = [SELECT ID FROM Profile WHERE NAME ='CT Community User'].id;
        Contact con = new Contact(LastName ='testCon1',Email='abcd@gmail.com',AccountId = ac1.Id,Due_date_reminders_email_notification__c=true,Resource_Email_Notification__c=true);
        insert con;
        Boolean retVal;
        User user = new User(
            alias = 'test123', email='test123@noemail.com',
            emailencodingkey='UTF-8', middlename='some', 
            lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = profileId, 
            country='United States',IsActive =true,
            ContactId = con.Id, timezonesidkey='America/Los_Angeles', 
            username='tester123@noemail.com'
        );
        insert user;
        System.runAs(user) {
            retVal = BOS_ResourceNotificationUtility.isResourceNotificationEnabled();
        }
        System.assertEquals(true, retVal);
        Test.stopTest();
    }
}