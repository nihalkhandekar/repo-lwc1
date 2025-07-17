@isTest
private class BRS_annualFilingReportBatch_Test {
    Static List<Id> acctIdList = new List<Id>(); 
    @testSetup 
    static void setup() {
        Account acc=new Account(Status__c='Active',
                                Date_of_Formation__c=Date.newInstance(2021,01,01),
                                Date_Registration__c=Date.newInstance(2021,01,03),
                                Business_Type__c=System.Label.Stock,
                                Citizenship__c='Domestic',
                                Mailing_Address__c='WA',
                                State_or_Territory_Formation__c='WA',
                                State__c='WA',
                                Country__c='India',
                                Name='Test',Mailing_International_Address__c = 'Mailing address',BillingStreet='xyz', BillingCity='abc', BillingState='abcd', BillingPostalCode='12345', BillingCountry='India', ShippingStreet='abc', ShippingCity='xyz', ShippingState='abcd', ShippingPostalCode='12345', ShippingCountry='India', Mailing_Jurisdiction_BusinessCity__c='Mumbai', Mailing_Jurisdiction_BusinessState__c='WA', Mailing_Jurisdiction_BusinessStreet__c='ABC', Mailing_Jurisdiction_BusinessZipCode__c='12345', Mailing_Jurisdiction_Country__c='India',Purpose_of_Business__c='abcxyz',Total_Authorized_Shares__c=100); 
        Id recordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByName().get(System.Label.ActionItem_AccountRecordType).getRecordTypeId();
        insert acc;
        acc.Business_Type__c =  System.Label.businessTypeLLP;
        update acc;
        acc.Business_Type__c = System.Label.Stock;
        update acc;
        acc.RecordtypeId=recordTypeId;
        acctIdList.add(acc.Id);
        
        Contact con=BRS_TestDataFactory.createContactObject(acc.Id);       
        
        Work_Order__c workOrder1 = new Work_Order__c();
        workOrder1.Source__c = 'Email';
        workOrder1.Received_Date__c = System.Now();
        workOrder1.Completed_Date__c = System.Today();
        workOrder1.Status__c = 'Open';
        workOrder1.Customer__c=con.Id;
        insert workOrder1;
        
         Id annualFirstrecTypeId = Wizard_Utlity.getRecordTypeId(system.label.Annual_First_recordtype_label,Schema.Business_Filing__c.getSObjectType());
        OnOff_Filing_Auto_Refund__c onOff1 = BRS_TestDataFactory.onOffCustomSetting();
        Business_Filing__c filing = new Business_Filing__c();
        filing.Account__c=acc.Id;
        filing.Filing_Fee__c=30;
        filing.Type__c = System.Label.First_Report_Label;
        filing.Citizenship__c = 'Domestic';
        filing.Filing_Date__c = System.Today().addDays(-30);
        filing.Due_Date__c = (System.today() + 5);
        filing.recordtypeId=annualFirstrecTypeId;
        insert filing;
        
        Business_Filing__c filing1 = new Business_Filing__c();
        filing1.Account__c=acc.Id;
        filing1.Filing_Fee__c=30;
        filing1.Type__c = system.label.Annual_Report;
        filing1.Citizenship__c = 'Domestic';
        filing1.Filing_Date__c = System.Today().addDays(-30);
        filing1.Due_Date__c = (System.today() + 5);
        filing1.recordtypeId=annualFirstrecTypeId;
        insert filing1;
    }
    @isTest
    static void insertUccRelatedInforTest1(){
        
        Test.startTest();
        BRS_annualFilingReportBatch.createAnnualFiling(acctIdList);
        BRS_annualFilingReportBatch obj = new BRS_annualFilingReportBatch(2021,false);
        BRS_annualFilingReportBatch obj1 = new BRS_annualFilingReportBatch(2021,acctIdList);
        DataBase.executeBatch(obj); 
        DataBase.executeBatch(obj1);
        Test.stopTest();
        
    }
    
    testMethod static void createBusinessFiling(){
        Account acc1 = [Select Id, Name,Date_Registration__c,Date_of_Formation__c,Business_Type__c,Citizenship__c,Mailing_Address__c,State__c,Country__c from Account where Name='Test'];
        Business_filing__c busFil1 = [Select Id from Business_Filing__c where Account__r.Name='Test' AND Type__c=:System.Label.First_Report_Label];
        Integer yearvalue;
        yearvalue = 2021;
        
        
        Test.startTest();
        BRS_annualFilingReportBatch createBusinessFilingclass = new BRS_annualFilingReportBatch(yearvalue,false);
        createBusinessFilingclass.createBusinessFiling(acc1,busFil1, yearvalue);
        acc1.Citizenship__c = 'Domestic';
        acc1.Business_Type__c = 'LLC';
        update acc1;
        createBusinessFilingclass.createBusinessFiling(acc1,busFil1, yearvalue);
        Account acc2=new Account(Status__c='Active',
        Date_of_Formation__c=Date.newInstance(2021,01,01),
        Date_Registration__c=Date.newInstance(2021,02,29),
        Business_Type__c='LLP',
        Citizenship__c='Domestic',
        Mailing_Address__c='Mumbai, India',
        State__c='WA',
        State_or_Territory_Formation__c='WA',
        Country__c='India',
        Name='Test',Mailing_International_Address__c = 'Mailing address',BillingStreet='xyz', BillingCity='abc', BillingState='abcd', BillingPostalCode='12345', BillingCountry='India', ShippingStreet='abc', ShippingCity='xyz', ShippingState='abcd', ShippingPostalCode='12345', ShippingCountry='India', Mailing_Jurisdiction_BusinessCity__c='Mumbai', Mailing_Jurisdiction_BusinessState__c='WA', Mailing_Jurisdiction_BusinessStreet__c='ABC', Mailing_Jurisdiction_BusinessZipCode__c='12345', Mailing_Jurisdiction_Country__c='India',Purpose_of_Business__c='abcxyz',Total_Authorized_Shares__c=100); 
        Id recordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByName().get(System.Label.ActionItem_AccountRecordType).getRecordTypeId();
        insert acc2;
        createBusinessFilingclass.createBusinessFiling(acc2,busFil1, yearvalue);
        Test.stopTest();
        
    }
    testMethod static void createBusinessFilingee(){
        Business_filing__c busFil1 = [Select Id from Business_Filing__c where Account__r.Name='Test' AND Type__c='Annual Report'];
        Integer yearvalue;
        yearvalue = 2021;
        
        Test.startTest();
        BRS_annualFilingReportBatch createBusinessFilingclass = new BRS_annualFilingReportBatch(yearvalue,false);
        Account acc2=new Account(Status__c='Active',
        Date_of_Formation__c=Date.newInstance(2021,01,01),
        Date_Registration__c=Date.newInstance(2021,02,29),
        Business_Type__c='LLP',
        Citizenship__c='Domestic',
        Mailing_Address__c='Mumbai, India',
        State__c='WA',
        State_or_Territory_Formation__c='WA',
        Country__c='India',
        Name='Test',Mailing_International_Address__c = 'Mailing address',BillingStreet='xyz', BillingCity='abc', BillingState='abcd', BillingPostalCode='12345', BillingCountry='India', ShippingStreet='abc', ShippingCity='xyz', ShippingState='abcd', ShippingPostalCode='12345', ShippingCountry='India', Mailing_Jurisdiction_BusinessCity__c='Mumbai', Mailing_Jurisdiction_BusinessState__c='WA', Mailing_Jurisdiction_BusinessStreet__c='ABC', Mailing_Jurisdiction_BusinessZipCode__c='12345', Mailing_Jurisdiction_Country__c='India',Purpose_of_Business__c='abcxyz',Total_Authorized_Shares__c=100); 
        Id recordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByName().get(System.Label.ActionItem_AccountRecordType).getRecordTypeId();
        insert acc2;
        createBusinessFilingclass.createBusinessFiling(acc2,busFil1, yearvalue);
        Test.stopTest();
    }

    testMethod static void getBusinessFiling() {
        Account acc1 = [Select Id, Name,Date_Registration__c,Date_of_Formation__c,Business_Type__c,Citizenship__c,Mailing_Address__c,State__c,Country__c from Account where Name='Test'];
        Business_filing__c busFil1 = [Select Id from Business_Filing__c where Account__r.Name='Test' AND Type__c=:System.Label.First_Report_Label];
        Boolean isMaintainanceFlowOrNot;
        
        test.startTest();
        BRS_annualFilingReportBatch.getBusinessFiling(acc1.Id,isMaintainanceFlowOrNot);
        BRS_annualFilingReportBatch.getFirstFiling(acc1.Id);
        test.stopTest();
    }
    testMethod static void createAnnualFiling() {
        Account acc1 = [Select Id, Name,Date_Registration__c,Date_of_Formation__c,Business_Type__c,Citizenship__c,Mailing_Address__c,State__c,Country__c from Account where Name='Test'];
        Business_filing__c busFil1 = [Select Id from Business_Filing__c where Account__r.Name='Test' AND Type__c=:System.Label.Annual_Report];
        List<Business_Filing__c> filingList=new List<Business_Filing__c>();
        Business_Filing__c filing = new Business_Filing__c();
        filing.Account__c=acc1.Id;
        filing.status__c='Submitted - Agent acceptance pending';
        filing.Agent_Email_Address__c='sbabarabbani@deloitte.com';
        filing.Citizenship__c ='Domestic';
        filing.Agent_Id__c='12345';
        filing.Type__c=system.label.Annual_Report;
        filing.Agent_Phone_Number__c=1234567890;
        filing.Business_Type__c=System.Label.Stock;
        filing.Total_Authorized_Shares__c=100;
        filingList.add(filing);
        insert filingList;
        
        List<Id> accIds = new List<Id>();
        accIds.add(acc1.Id);
        
        test.startTest();
        BRS_annualFilingReportBatch.createAnnualFiling(accIds);  
        
        BRS_annualFilingReportBatch scheUpdateAccount = new BRS_annualFilingReportBatch(2020,false); 
        String sch ='0 48 * * * ?'; 
        System.schedule('ScheduleTest', sch,scheUpdateAccount);
        BRS_annualFilingReportBatch scheUpdateAccount1 = new BRS_annualFilingReportBatch(2020,accIds); 
        test.stopTest();
        
    }
    testMethod static void createAnnualFilingForAccountWithoutFilings() {
        Database.BatchableContext BC;
        
        Account acc1=new Account(Status__c='Active',
                                 Date_of_Formation__c=Date.newInstance(2021,01,01),
                                 Date_Registration__c=Date.newInstance(2021,01,03),
                                 Business_Type__c=System.Label.Stock,
                                 Citizenship__c='Domestic',
                                 Mailing_Address__c='Mumbai, India',
                                 State__c='WA',
                                 State_or_Territory_Formation__c='WA',
                                 Country__c='India',
                                 Name='Test',Mailing_International_Address__c = 'Mailing address',BillingStreet='xyz', BillingCity='abc', BillingState='abcd', BillingPostalCode='12345', BillingCountry='India', ShippingStreet='abc', ShippingCity='xyz', ShippingState='abcd', ShippingPostalCode='12345', ShippingCountry='India', Mailing_Jurisdiction_BusinessCity__c='Mumbai', Mailing_Jurisdiction_BusinessState__c='WA', Mailing_Jurisdiction_BusinessStreet__c='ABC', Mailing_Jurisdiction_BusinessZipCode__c='12345', Mailing_Jurisdiction_Country__c='India',Purpose_of_Business__c='abcxyz',Total_Authorized_Shares__c=100); 
        Id recordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByName().get(System.Label.ActionItem_AccountRecordType).getRecordTypeId();
        insert acc1;    
        
        List<Id> accIds = new List<Id>();
        List<Account> accList = new List<Account>();
        accIds.add(acc1.Id);
        accList.add(acc1);
            Business_Filing__c filing = new Business_Filing__c();
        filing.Account__c=acc1.Id;
        filing.status__c='Approved';
        filing.Agent_Email_Address__c='sbabarabbani@deloitte.com';
        filing.Citizenship__c ='Domestic';
        filing.Agent_Id__c='12345';
        filing.Type__c=system.label.Annual_Report;
        filing.Agent_Phone_Number__c=1234567890;
        filing.Business_Type__c=System.Label.Stock;
        filing.Total_Authorized_Shares__c=100;
        insert filing;
        test.startTest();
        
        BRS_annualFilingReportBatch scheUpdateAccount = new BRS_annualFilingReportBatch(2020,false); 
        String sch ='0 48 * * * ?'; 
        System.schedule('ScheduleTest', sch,scheUpdateAccount);
        BRS_annualFilingReportBatch.createAnnualFiling(accIds);
        scheUpdateAccount.execute(BC, accList);
        BRS_annualFilingReportBatch.getBusinessFiling(acc1.Id, true);
        test.stopTest();
        
    }

    testMethod static void createAnnualFilingForAccountWithoutFilingsTest() {
        Database.BatchableContext BC;
        test.startTest();
        Account acc1=new Account(Status__c='Active',
                                 Date_of_Formation__c=Date.newInstance(2021,01,01),
                                 Date_Registration__c=Date.newInstance(2020,01,03),
                                 Business_Type__c=System.Label.Stock,
                                 Citizenship__c='Domestic',
                                 Mailing_Address__c='Mumbai, India',
                                 State__c='WA',
                                 State_or_Territory_Formation__c='WA',
                                 Country__c='India',
                                 Name='Test',Mailing_International_Address__c = 'Mailing address',BillingStreet='xyz', BillingCity='abc', BillingState='abcd', BillingPostalCode='12345', BillingCountry='India', ShippingStreet='abc', ShippingCity='xyz', ShippingState='abcd', ShippingPostalCode='12345', ShippingCountry='India', Mailing_Jurisdiction_BusinessCity__c='Mumbai', Mailing_Jurisdiction_BusinessState__c='WA', Mailing_Jurisdiction_BusinessStreet__c='ABC', Mailing_Jurisdiction_BusinessZipCode__c='12345', Mailing_Jurisdiction_Country__c='India',Purpose_of_Business__c='abcxyz',Total_Authorized_Shares__c=100); 
        Id recordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByName().get(System.Label.ActionItem_AccountRecordType).getRecordTypeId();
        System.debug('***acc1'+acc1);
        insert acc1;    
        List<id> acccid = new List<id>();
        acccid.add(acc1.id);
       /* List<Id> accIds = new List<Id>();
        List<Account> accList = new List<Account>();
        accIds.add(acc1.Id);
        accList.add(acc1);*/
        
        List<Business_Filing__c> filingList=new List<Business_Filing__c>();
        Business_Filing__c filing = new Business_Filing__c();
        filing.Account__c=acc1.Id;
        filing.status__c='Approved';
        filing.Agent_Email_Address__c='sbabarabbani@deloitte.com';
        filing.Citizenship__c ='Domestic';
        filing.Agent_Id__c='12345';
        filing.Type__c='First report';
        filing.Agent_Phone_Number__c=1234567890;
        filing.Business_Type__c=System.Label.Stock;
        filing.Total_Authorized_Shares__c=100;
        filingList.add(filing);
        System.debug('***filing'+filing);
        insert filingList;

        
        
        BRS_annualFilingReportBatch obj1 = new BRS_annualFilingReportBatch(2021,acccid);
        DataBase.executeBatch(obj1); 
        BRS_annualFilingReportBatch.getBusinessFiling(acc1.Id, true);
        // Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
String CRON_EXP = '0 6 * * * ?';
        System.Schedule('Test',CRON_EXP,new BRS_annualFilingReportBatchScheduler());
        test.stopTest();
        
    }
    @isTest
    private static void testFailureCase(){
        test.startTest();
        Account acc = [select id,Status__c,Citizenship__c , Date_Registration__c, Business_Type__c from Account Limit 1];
        List<id> acccid = new List<id> {acc.id};
        BRS_annualFilingReportBatch obj1 = new BRS_annualFilingReportBatch(2021,acccid);
        BRS_annualFilingReportBatch obj2 = new BRS_annualFilingReportBatch(2021,'Select id,Status__c,Sub_status__c,Annual_Report_Processing_Year__c,Date_Registration__c,Citizenship__c,Business_Type__c from Account Limit 1');
        DataBase.executeBatch(obj1); 
        DataBase.executeBatch(obj2);
        test.stopTest();
    }
    @isTest
 private static void testFailureCaseInfo(){
     test.startTest();
     Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Citizenship__c='Domestic';
        acc.Business_Type__c='LLP';
        acc.ClientAccountNum__c='12345';
        acc.Purpose_of_Business__c = 'Test business run';
        acc.Status__c='Active';
        acc.Date_Registration__c=Date.newInstance(2021,02,29);
        insert acc;
      BRS_annualFilingReportBatch.getBusinessFiling(acc.id,true);
     test.stopTest();
 }
      @isTest
 private static void testFailureCaseInfo1(){
     test.startTest();
              Id annualFirstrecTypeId = Wizard_Utlity.getRecordTypeId(system.label.Annual_First_recordtype_label,Schema.Business_Filing__c.getSObjectType());
     Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Citizenship__c='Domestic';
        acc.Business_Type__c='Stock';
        acc.ClientAccountNum__c='12345';
        acc.Purpose_of_Business__c = 'Test business run';
        acc.Status__c='Active';
        acc.Date_Registration__c=Date.newInstance(2021,02,29);
     	acc.Total_Authorized_Shares__c=1;
        insert acc;
             Business_Filing__c filing = new Business_Filing__c();
        filing.Account__c=acc.Id;
        filing.Filing_Fee__c=30;
        filing.Type__c = 'Annual Report';
        filing.Citizenship__c = 'Domestic';
        filing.Business_Type__c='Stock';
        filing.Filing_Date__c = System.Today().addDays(-30);
        filing.Due_Date__c = (System.today() + 5);
        filing.recordtypeId=annualFirstrecTypeId;
        insert filing;
        Integer yearvalue;
        yearvalue = 2021;
       System.debug('Inside My Method@@@');
        BRS_annualFilingReportBatch createBusinessFilingclass = new BRS_annualFilingReportBatch(yearvalue,false);
        createBusinessFilingclass.createBusinessFiling(acc,filing, yearvalue);
     test.stopTest();
 }
 @isTest
 private static void recordFailureBatch()
 {
     Account acc2=new Account(Status__c='Active',
     Date_of_Formation__c=Date.newInstance(2023,01,01),
     Date_Registration__c=Date.newInstance(2023,02,29),
     Business_Type__c='LLP',
     Citizenship__c='Domestic',
     Mailing_Address__c='Mumbai, India',
     State__c='WA',
     State_or_Territory_Formation__c='WA',
     Country__c='India',
     Name='Test',Mailing_International_Address__c = 'Mailing address',BillingStreet='xyz', BillingCity='abc', BillingState='abcd', BillingPostalCode='12345', BillingCountry='India', ShippingStreet='abc', ShippingCity='xyz', ShippingState='abcd', ShippingPostalCode='12345', ShippingCountry='India', Mailing_Jurisdiction_BusinessCity__c='Mumbai', Mailing_Jurisdiction_BusinessState__c='WA', Mailing_Jurisdiction_BusinessStreet__c='ABC', Mailing_Jurisdiction_BusinessZipCode__c='12345', Mailing_Jurisdiction_Country__c='India',Purpose_of_Business__c='abcxyz',Total_Authorized_Shares__c=100); 
     insert acc2;
     test.startTest();
     BRS_annualFilingReportBatch obj1 = new BRS_annualFilingReportBatch(2024,true);
     database.executeBatch(obj1);
     test.stopTest();
 }
    testMethod static void createAnnualFilingForAccountWithoutFilings1() {
        Database.BatchableContext BC;
        
        Account acc1=new Account(Status__c='Active',
                                 Date_of_Formation__c=Date.newInstance(2021,01,01),
                                 Date_Registration__c=Date.newInstance(2021,01,03),
                                 Business_Type__c=System.Label.Stock,
                                 Citizenship__c='Domestic',
                                 Mailing_Address__c='Mumbai, India',
                                 State__c='WA',
                                 State_or_Territory_Formation__c='WA',
                                 Country__c='India',
                                 Reason_for_Administrative_Dissolution__c='sas',
                                 Name='Test',Mailing_International_Address__c = 'Mailing address',BillingStreet='xyz', BillingCity='abc', BillingState='abcd', BillingPostalCode='12345', BillingCountry='India', ShippingStreet='abc', ShippingCity='xyz', ShippingState='abcd', ShippingPostalCode='12345', ShippingCountry='India', Mailing_Jurisdiction_BusinessCity__c='Mumbai', Mailing_Jurisdiction_BusinessState__c='WA', Mailing_Jurisdiction_BusinessStreet__c='ABC', Mailing_Jurisdiction_BusinessZipCode__c='12345', Mailing_Jurisdiction_Country__c='India',Purpose_of_Business__c='abcxyz',Total_Authorized_Shares__c=100); 
        Id recordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByName().get(System.Label.ActionItem_AccountRecordType).getRecordTypeId();
        insert acc1;    
        
        List<Id> accIds = new List<Id>();
        List<Account> accList = new List<Account>();
        accIds.add(acc1.Id);
        BRS_annualFilingReportBatch.createAnnualFiling(accIds);
    }
    testMethod static void createAnnualFilingForAccountWithoutFilings2() {
        Database.BatchableContext BC;
        
        Account acc1=new Account(Status__c='Active',
                                 sub_status__c='Admin Dissolution Initiated',
                                 Date_of_Formation__c=Date.newInstance(2021,01,01),
                                 Date_Registration__c=Date.newInstance(2021,01,03),
                                 Business_Type__c=System.Label.Stock,
                                 Citizenship__c='Domestic',
                                 Mailing_Address__c='Mumbai, India',
                                 State__c='WA',
                                 State_or_Territory_Formation__c='WA',
                                 Country__c='India',
                                 Reason_for_Administrative_Dissolution__c='sas',
                                 Name='Test',Mailing_International_Address__c = 'Mailing address',BillingStreet='xyz', BillingCity='abc', BillingState='abcd', BillingPostalCode='12345', BillingCountry='India', ShippingStreet='abc', ShippingCity='xyz', ShippingState='abcd', ShippingPostalCode='12345', ShippingCountry='India', Mailing_Jurisdiction_BusinessCity__c='Mumbai', Mailing_Jurisdiction_BusinessState__c='WA', Mailing_Jurisdiction_BusinessStreet__c='ABC', Mailing_Jurisdiction_BusinessZipCode__c='12345', Mailing_Jurisdiction_Country__c='India',Purpose_of_Business__c='abcxyz',Total_Authorized_Shares__c=100); 
        Id recordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByName().get(System.Label.ActionItem_AccountRecordType).getRecordTypeId();
        insert acc1;    
        
        List<Id> accIds = new List<Id>();
        List<Account> accList = new List<Account>();
        accIds.add(acc1.Id);
            Business_Filing__c filing = new Business_Filing__c();
        filing.Account__c=acc1.Id;
        filing.status__c='Approved';
        filing.Agent_Email_Address__c='sbabarabbani@deloitte.com';
        filing.Citizenship__c ='Domestic';
        filing.Agent_Id__c='12345';
        filing.Type__c='First report';
        filing.Agent_Phone_Number__c=1234567890;
        filing.Business_Type__c=System.Label.Stock;
        filing.Total_Authorized_Shares__c=100;
        insert filing;
        BRS_annualFilingReportBatch.createAnnualFiling(accIds);
    }
    
}