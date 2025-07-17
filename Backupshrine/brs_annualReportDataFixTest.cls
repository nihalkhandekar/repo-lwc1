@isTest public class brs_annualReportDataFixTest {
     Static List<Id> acctIdList = new List<Id>(); 
	@testSetup 
    static void setup() {
        Account acc=new Account(Status__c='Active',
                                Date_of_Formation__c=Date.newInstance(2021,01,01),
                                Date_Registration__c=Date.newInstance(2021,01,03),
                                Business_Type__c=System.Label.Stock,
                                Citizenship__c='Domestic',
                                Mailing_Address__c='WA',
                                State__c='WA',
                                State_or_Territory_Formation__c='WA',
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
        filing.Due_Date__c = (System.today().addYears(-1));
        filing.recordtypeId=annualFirstrecTypeId;
        insert filing;
        
     /*   Business_Filing__c filing1 = new Business_Filing__c();
        filing1.Account__c=acc.Id;
        filing1.Filing_Fee__c=30;
        filing1.Type__c = system.label.Annual_Report;
        filing1.Citizenship__c = 'Domestic';
        filing1.Filing_Date__c = System.Today().addDays(-30);
        filing1.Due_Date__c = (System.today() + 5);
        filing1.recordtypeId=annualFirstrecTypeId;
        insert filing1;*/
    }
     @isTest
    static void insertUccRelatedInforTest1(){
        Account acc=[Select Id,Name from Account];
        acc.Annual_Report_Due_date__c=null;
        update acc;
        test.startTest();
        Database.executeBatch(new brs_annualReportDataFix(new List<String>{acc.Id}));
        test.stopTest();
    }
}