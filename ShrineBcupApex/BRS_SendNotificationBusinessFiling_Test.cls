@isTest
private class BRS_SendNotificationBusinessFiling_Test {
    @isTest
    static void testMethod1() 
    {
        List<Account> lstAccount1 = BRS_TestDataFactory.listOfAccount();
        Contact con1 = BRS_TestDataFactory.createContactObject(lstAccount1[0].Id);
        con1.Due_date_reminders_email_notification__c=true;
        con1.Due_date_reminders_sms_notification__c=true;
        update con1;
        lstAccount1[0].Status__c=label.ACTIVE;
        lstAccount1[0].Business_Email_Address__c='abc@xyz.com';
        lstAccount1[0].Sub_status__c= 'Annual report due';
        lstAccount1[0].Annual_report_past_due_date__c=Date.today();
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
        update lstAccount1[0];
       
        
       /* List<Account> lstAccount= new List<Account>();
        for(Integer i=0 ;i <200;i++)
        {
            Account acc = new Account();
            acc.Name ='Name'+i;
            lstAccount.add(acc);
        }
        
        insert lstAccount;*/
        
        Test.startTest();

            BRS_SendNotificationBusinessFiling obj = new BRS_SendNotificationBusinessFiling();
            DataBase.executeBatch(obj); 
            
        Test.stopTest();
    }
    
    @isTest
    static void testMethod2() { 
    	List<Account> lstAccount1 = BRS_TestDataFactory.listOfAccount();
        Contact con2 = BRS_TestDataFactory.createContactObject(lstAccount1[1].Id);
        con2.Due_date_reminders_email_notification__c=true;
        con2.Due_date_reminders_sms_notification__c=true;
        update con2;
        
        lstAccount1[1].Status__c=label.ACTIVE;
        lstAccount1[1].Business_Email_Address__c='abc@xyz.com';
        lstAccount1[1].Sub_status__c= Label.Annual_report_due2;
        lstAccount1[1].Annual_report_past_due_date__c=Date.today()-3;
        lstAccount1[1].Citizenship__c='Domestic';
        lstAccount1[1].Business_Type__c=Label.LLC;
        lstAccount1[1].ShippingStreet='Baker street';
        lstAccount1[1].ShippingCity='Mumbai';
        lstAccount1[1].ShippingState='WA';
        lstAccount1[1].ShippingPostalCode='12345';
        lstAccount1[1].ShippingCountry='India';
        lstAccount1[1].Mailing_International_Address__c='ABC street, abc city, abc state, abc country, 12345';
        lstAccount1[1].BillingStreet='Baker street';
        lstAccount1[1].BillingCity='Mumbai';
        lstAccount1[1].BillingState='WA';
        lstAccount1[1].BillingPostalCode='12345';
        lstAccount1[1].BillingCountry='India';
        update lstAccount1[1];
        
        Test.startTest();

            BRS_SendNotificationBusinessFiling obj = new BRS_SendNotificationBusinessFiling();
            DataBase.executeBatch(obj); 
            
        Test.stopTest();
    }
    
    @isTest
    static void Testmethod3() {
        List<Account> lstAccount1 = BRS_TestDataFactory.listOfAccount();
        Contact con3 = BRS_TestDataFactory.createContactObject(lstAccount1[2].Id);
        con3.Due_date_reminders_email_notification__c=true;
        con3.Due_date_reminders_sms_notification__c=true;
        update con3;
        
        lstAccount1[2].Status__c=label.ACTIVE;
        lstAccount1[2].Business_Email_Address__c='abc@xyz.com';
        lstAccount1[2].Sub_status__c= Label.Annual_report_due2;
        lstAccount1[2].Annual_report_past_due_date__c=Date.today().addDays(30);
        lstAccount1[2].Citizenship__c='Domestic';
        lstAccount1[2].Business_Type__c=Label.LLP;
        lstAccount1[2].ShippingStreet='Baker street';
        lstAccount1[2].ShippingCity='Mumbai';
        lstAccount1[2].ShippingState='WA';
        lstAccount1[2].ShippingPostalCode='12345';
        lstAccount1[2].ShippingCountry='India';
        lstAccount1[2].Mailing_International_Address__c='ABC street, abc city, abc state, abc country, 12345';
        lstAccount1[2].Purpose_of_Business__c='Business required';
        update lstAccount1[2];
        
        Test.startTest();

            BRS_SendNotificationBusinessFiling obj = new BRS_SendNotificationBusinessFiling();
            DataBase.executeBatch(obj); 
            
        Test.stopTest();
    }
    
    @isTest
    static void TestMethod4() {
        List<Account> lstAccount1 = BRS_TestDataFactory.listOfAccount();
        Contact con3 = BRS_TestDataFactory.createContactObject(lstAccount1[2].Id);
        con3.Due_date_reminders_email_notification__c=true;
        con3.Due_date_reminders_sms_notification__c=true;
        update con3;  
        lstAccount1[2].Status__c=label.ACTIVE;
        lstAccount1[2].Business_Email_Address__c='abc@xyz.com';
        lstAccount1[2].Sub_status__c= Label.Account_Annual_report_past_due;
        lstAccount1[2].Annual_report_past_due_date__c=Date.today().addDays(-30);
        lstAccount1[2].Citizenship__c='Domestic';
        lstAccount1[2].Business_Type__c=Label.LLP;
        lstAccount1[2].ShippingStreet='Baker street';
        lstAccount1[2].ShippingCity='Mumbai';
        lstAccount1[2].ShippingState='WA';
        lstAccount1[2].ShippingPostalCode='12345';
        lstAccount1[2].ShippingCountry='India';
        lstAccount1[2].Mailing_International_Address__c='ABC street, abc city, abc state, abc country, 12345';
        lstAccount1[2].Purpose_of_Business__c='Business required';
        update lstAccount1[2];
        
        Test.startTest();

            BRS_SendNotificationBusinessFiling obj = new BRS_SendNotificationBusinessFiling();
            DataBase.executeBatch(obj); 
            
        Test.stopTest();
    }
   }