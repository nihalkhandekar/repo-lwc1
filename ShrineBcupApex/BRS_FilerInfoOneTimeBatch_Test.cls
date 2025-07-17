@isTest
public class BRS_FilerInfoOneTimeBatch_Test {
    public static testmethod void testFilerInfoOneTimeJob(){
        insert new SendGridv3__c(
			Name = 'SendGridKey',
			Endpoint_URL__c = 'https://api.sendgrid.com/v3/mail/send',
			API_Key__c='cv38yfQrRHGh55zr10FaBw'
		);
        Account account = new Account(Name = 'TestAccount');
        insert account;
        ID enterpriseRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Enterprise').getRecordTypeId();
        Contact cont = new Contact(Lastname = 'TestLastame',AccountId = account.Id,RecordTypeId=enterpriseRecordTypeId,Email='test@test.com' );
        insert cont;
        Profile p = [SELECT Id FROM Profile WHERE name = 'CT Community User' Limit 1];
        User cuser =    BRS_TestDataFactory.createCommunityUser(cont, p.Id);
        List<Work_Order__c> listWorkorder = new List<Work_Order__c>();
        for(Integer i=0;i<11;i++){
            Work_Order__c workOrder = new Work_Order__c();
            workOrder.Source__c = 'Mail';
            workOrder.Received_Date__c = System.Now();
            workOrder.Completed_Date__c = System.Today();
            workOrder.Status__c = 'Open';
            workOrder.Customer__c = cont.Id;
            listWorkorder.add(workOrder);
        }
        insert listWorkorder;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SendGridResponseMock());
        BRS_FilerInfoOneTimeBatch onetimebach = new BRS_FilerInfoOneTimeBatch();
        Database.executeBatch(onetimebach,100);
        Test.stopTest();
    }
    
}