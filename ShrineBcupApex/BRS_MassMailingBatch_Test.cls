@isTest
public with sharing class BRS_MassMailingBatch_Test {
    @isTest
    public static void testMethod1() {

        insert new SendGridv3__c(
			Name = 'SendGridValidationKey',
			Endpoint_URL__c = 'https://api.sendgrid.com/v3/validations/email',
			API_Key__c='cv38yfQrRHGh55zr10FaBw'
		);

        insert new SendGridv3__c(
			Name = 'SendGridKey',
			Endpoint_URL__c = 'https://api.sendgrid.com/v3/mail/send',
			API_Key__c='cv38yfQrRHGh55zr10FaBw'
		);

        List<Account> lstAccount1 = BRS_TestDataFactory.listOfAccount();
        Contact con1 = BRS_TestDataFactory.createContactObject(lstAccount1[0].Id);
        con1.Due_date_reminders_email_notification__c=true;
        con1.Due_date_reminders_sms_notification__c=true;
        update con1;
        lstAccount1[0].Status__c=label.ACTIVE;
        lstAccount1[0].Business_Email_Address__c='abc@xyz.com';
        lstAccount1[0].Sub_status__c= 'Annual report due';
        lstAccount1[0].Annual_report_past_due_date__c=Date.today();
        lstAccount1[0].Date_Registration__c = Date.today();
        lstAccount1[0].Citizenship__c='Domestic';
        lstAccount1[0].Business_Type__c=Label.LLC;
        lstAccount1[0].ShippingStreet='Baker street';
        lstAccount1[0].ShippingCity='Mumbai';
        lstAccount1[0].ShippingState='WA';
        lstAccount1[0].ShippingPostalCode='12345';
        lstAccount1[0].ShippingCountry='India';
        lstAccount1[0].Mailing_International_Address__c='ABC street, abc city, abc state, abc country, 12345';
        lstAccount1[0].BillingStreet='Baker street';
        lstAccount1[0].BillingCity='Mumbai';
        lstAccount1[0].BillingState='WA';
        lstAccount1[0].BillingPostalCode='12345';
        lstAccount1[0].BillingCountry='India';
        //update lstAccount1[0];

        lstAccount1[1].Status__c=label.ACTIVE;
        lstAccount1[1].Business_Email_Address__c='abc@xyz.com';
        lstAccount1[1].Sub_status__c= 'Annual report past due';
        lstAccount1[1].Annual_report_past_due_date__c=Date.today().addDays(-3);
        lstAccount1[1].Date_Registration__c = Date.today();
        lstAccount1[1].Citizenship__c='Domestic';
        lstAccount1[1].Business_Type__c=Label.LLC;
        lstAccount1[1].ShippingStreet='Baker street';
        lstAccount1[1].ShippingCity='Mumbai';
        lstAccount1[1].ShippingState='WA';
        lstAccount1[1].ShippingPostalCode='12345';
        lstAccount1[1].ShippingCountry='India';
        lstAccount1[1].BillingStreet='Baker street';
        lstAccount1[1].BillingCity='Mumbai';
        lstAccount1[1].BillingState='WA';
        lstAccount1[1].BillingPostalCode='12345';
        lstAccount1[1].BillingCountry='India';
        lstAccount1[1].Mailing_International_Address__c='ABC street, abc city, abc state, abc country, 12345';
        //update lstAccount1[1];

        lstAccount1[2].Status__c=label.ACTIVE;
        lstAccount1[2].Business_Email_Address__c='abc@xyz.com';
        lstAccount1[2].Sub_status__c= 'Annual report due';
        lstAccount1[2].Annual_report_past_due_date__c=Date.today().addDays(2);
        lstAccount1[2].Date_Registration__c = Date.today();
        lstAccount1[2].Citizenship__c='Domestic';
        lstAccount1[2].Business_Type__c=Label.LLC;
        lstAccount1[2].ShippingStreet='Baker street';
        lstAccount1[2].ShippingCity='Mumbai';
        lstAccount1[2].ShippingState='WA';
        lstAccount1[2].ShippingPostalCode='12345';
        lstAccount1[2].ShippingCountry='India';
        lstAccount1[2].Mailing_International_Address__c='ABC street, abc city, abc state, abc country, 12345';
        lstAccount1[2].BillingStreet='Baker street';
        lstAccount1[2].BillingCity='Mumbai';
        lstAccount1[2].BillingState='WA';
        lstAccount1[2].BillingPostalCode='12345';
        lstAccount1[2].BillingCountry='India';
        update lstAccount1;

        Account acct = new Account();
           acct.name='Test444';
           acct.Franchise_Tax__c=200;
           acct.ClientAccountNum__c='12345';
           acct.Status__c=label.ACTIVE;
           acct.Business_Email_Address__c='abc@xyz.com';
           acct.Sub_status__c= 'Annual report due';
           acct.Annual_report_past_due_date__c=Date.today().addDays(2);
           acct.Date_Registration__c = Date.today();
           acct.Citizenship__c='Domestic';
           acct.Business_Type__c=Label.LLC;
           acct.ShippingStreet='Baker street';
           acct.ShippingCity='Mumbai';
           acct.ShippingState='WA';
           acct.ShippingPostalCode='12345';
           acct.ShippingCountry='India';
           acct.Mailing_International_Address__c='ABC street, abc city, abc state, abc country, 12345';
           acct.BillingStreet='Baker street';
           acct.BillingCity='Mumbai';
           acct.BillingState='WA';
           acct.BillingPostalCode='12345';
           acct.BillingCountry='India';
            insert acct;
           lstAccount1.add(acct);

           Mass_Mailing_Result__c mmr = new Mass_Mailing_Result__c();
           mmr.Account__c = acct.Id;
           mmr.Batch_Name__c = 'TestClassBatch';
           mmr.Status_Code__c = 250;
           insert mmr;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SendGridResponseMock());
        List<BRS_MassMailingBatch.Requests> reqList = new List<BRS_MassMailingBatch.Requests>();
        BRS_MassMailingBatch.Requests req = new BRS_MassMailingBatch.Requests();
        req.fromDate = Date.today().addDays(-1);
        req.toDate = Date.today().addDays(1);
        req.uniqueName = 'TestClassBatch';
        reqList.add(req);
        BRS_MassMailingBatch.getMailingConfig(reqList);
        //Database.executebatch(batch, 10);
        Test.stopTest();

    }
}