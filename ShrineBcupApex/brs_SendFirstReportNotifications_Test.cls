@isTest
public class brs_SendFirstReportNotifications_Test {
    
    @testSetup
    public static void testDataSetup(){
        List<Profile> lstProfileId = [Select Id From Profile Where Name = 'CT Community User']; 
        Account accInst = BRS_TestDataFactory.createAccountObject();
        Contact con = BRS_TestDataFactory.createContactObject(accInst.id);
        User user = BRS_TestDataFactory.createCommunityUser(con,lstProfileId[0].Id);
        
        List<Account> accountList = new List<Account>();
        List<Business_Filing__c> businessFilingList = new List<Business_Filing__c>();
        Account testAcc1 = new Account(Name = 'TestClassAcct1 B Corp.', 
                                       Citizenship__c = 'Domestic', 
                                       Business_Type__c = 'B Corp',
                                       Election_of_Bcorp_Status__c=true,
                                       Total_Authorized_Shares__c=12,
                                       Business_Email_Address__c = 'test@test.com',
                                       Sub_status__c = 'First report due',
                                       Status__c='Active');
        accountList.add(testAcc1);
        Account testAcc2 = new Account(Name = 'TestClassAcct2 B Corp. past', 
                                       Citizenship__c = 'Domestic', 
                                       Business_Type__c = 'B Corp',
                                       Election_of_Bcorp_Status__c=true,
                                       Total_Authorized_Shares__c=12,
                                       Business_Email_Address__c = 'test@test.com',
                                       Sub_status__c = 'First report past due',
                                       Status__c='Active');
        accountList.add(testAcc2);
        Account testAcc3 = new Account(Name = 'TestClassAcct3 B Corp. past', 
                                       Citizenship__c = 'Domestic', 
                                       Business_Type__c = 'B Corp',
                                       Election_of_Bcorp_Status__c=true,
                                       Total_Authorized_Shares__c=12,
                                       Business_Email_Address__c = 'test@test.com',
                                       Sub_status__c = 'First report due',
                                       Status__c='Active');
        accountList.add(testAcc3);
        insert accountList;
        
        Contact con1 = new Contact(FirstName = 'Test',
                                   LastName = 'Contact098',
                                   Email = 'testFirstReportBatch@test.com',
                                   Due_date_reminders_email_notification__c=true,
                                   AccountId=testAcc1.Id);
        insert con1;
        
        OnOff_Filing_Auto_Refund__c onoffCustomSetting = new OnOff_Filing_Auto_Refund__c();
        onoffCustomSetting.Name = 'On Off Switch';
        onoffCustomSetting.Auto_Refund_UCC_Filing__c = true;
        onoffCustomSetting.Auto_Refund_Business_Filing__c = false;
        insert onoffCustomSetting;
        
        Id newbusinessRecTypeId = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Annual Report / First Report').getRecordTypeId();
        Business_Filing__c onlineBusFiling = new Business_Filing__c();
        onlineBusFiling.RecordTypeId = newbusinessRecTypeId;
        onlineBusFiling.Source__c = 'Online';
        onlineBusFiling.Business_Type__c = 'B Corp';
        onlineBusFiling.Type__c = 'First Report';
        onlineBusFiling.Citizenship__c='Domestic';
        onlineBusFiling.Account__c=testAcc1.Id;
        onlineBusFiling.Due_Date__c=System.today().addDays(30);
        onlineBusFiling.OwnerId=user.Id;
        businessFilingList.add(onlineBusFiling);
        
        Business_Filing__c businessFiling2 = new Business_Filing__c();
        businessFiling2.RecordTypeId = newbusinessRecTypeId;
        businessFiling2.Source__c = 'Online';
        businessFiling2.Business_Type__c = 'B Corp';
        businessFiling2.Type__c = 'First Report';
        businessFiling2.Citizenship__c='Domestic';
        businessFiling2.Account__c=testAcc2.Id;
        businessFiling2.Due_Date__c=System.today().addDays(-30);
        businessFiling2.OwnerId=user.Id;
        businessFilingList.add(businessFiling2);
        
        Business_Filing__c businessFiling3 = new Business_Filing__c();
        businessFiling3.RecordTypeId = newbusinessRecTypeId;
        businessFiling3.Source__c = 'Online';
        businessFiling3.Business_Type__c = 'B Corp';
        businessFiling3.Type__c = 'First Report';
        businessFiling3.Citizenship__c='Domestic';
        businessFiling3.Account__c=testAcc3.Id;
        businessFiling3.Due_Date__c=System.today();
        businessFiling3.OwnerId=user.Id;
        businessFilingList.add(businessFiling3);
        insert businessFilingList;
    }
    
    @isTest
    public static void sendFirstReportNotificationTest(){
        User commUser = [Select Id,ContactId,Contact.Total_Voucher_Balance__c,IsActive from User where IsActive=true and username='testerbrs@noemail.com' LIMIT 1];
        Test.startTest();
        System.runAs(commUser){
            brs_SendFirstReportNotifications sendNotifBatch = new brs_SendFirstReportNotifications();
            Database.executeBatch(sendNotifBatch);
        }
        Test.stopTest();
    }
}