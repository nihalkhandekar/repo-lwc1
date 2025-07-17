@isTest
public with sharing class brs_MergeValidationsTest {

    @isTest
    public static void brs_MergeValidationsTestVal() {
        Account acc=new Account();
        acc.Name = 'Test Account';
        acc.Citizenship__c='Foreign';
        acc.Business_Type__c='LLC';
        acc.ClientAccountNum__c='12345';
        acc.Purpose_of_Business__c = 'Test business run';
        acc.status__c = 'Forfeited';
        acc.Mailing_International_Address__c = '2';
        acc.ShippingCountry = 'ALBANIA';
        acc.Began_Transacting_in_CT__c = Date.today().addDays(2);
        acc.Date_of_Formation__c = Date.today().addDays(-2);
        acc.Business_Name_in_state_country__c = 'Test Account';
        acc.Description = 'TEST';
        acc.Country_Formation__c  = 'TEST';
        acc.State_or_Territory_Formation__c  = 'CT';
        acc.Total_Authorized_Shares__c = 50;
        Account acc1=new Account();
        insert acc;
        acc.Total_Authorized_Shares__c = 100;
        update acc;
        acc1.Name = 'Test Account';
        acc1.Citizenship__c='Domestic';
        acc1.Business_Type__c='LLC';
        acc1.ClientAccountNum__c='12345';
        acc1.Purpose_of_Business__c = 'Test business run';
        acc1.status__c = 'Forfeited';
        acc1.Mailing_International_Address__c = '2';
        acc1.ShippingCountry = 'ALBANIA';
        acc1.Began_Transacting_in_CT__c = Date.today().addDays(2);
        acc1.Date_of_Formation__c = Date.today().addDays(-2);
        acc1.Business_Name_in_state_country__c = 'Test Account';
        acc1.Description = 'TEST';
        acc1.Country_Formation__c  = 'TEST';
        acc1.State_or_Territory_Formation__c  = 'AK';
        acc1.Total_Authorized_Shares__c = 50;
        insert acc1;
        acc1.Total_Authorized_Shares__c = 100;
        update acc1;
        Contact con = new Contact();
        con=BRS_TestDataFactory.createContactObject(acc.id);
        Work_Order__c workOrder = new Work_Order__c();
        workOrder=BRS_TestDataFactory.createWorkOrderObject(con.id,'Mail','In-Progress');
        Payment_Method__c payMethod =new Payment_Method__c();
        payMethod=BRS_TestDataFactory.genericPaymentMethod(workOrder.id);
        //Business_Filing__c filing=new Business_Filing__c();
        RecordType nb =[select id,Name,developername from RecordType where developername='New_Business'];
        Business_Filing__c filing=BRS_TestDataFactory.createBusinessFilingObject1(nb.id,acc.id,workOrder.id,'',null);
        insert filing;
        Business_History__c bh = new Business_History__c();
        bh.Surviving_Business__c = acc.id;
        bh.Merging_Business__c = acc1.id;
        bh.Business_Filing__c = filing.id;
        insert bh;
        List<String> Requests = new List<String>();
        Requests.add(filing.id);
        brs_MergeValidations.mergeValidations(Requests);
        brs_MergeUpdates.mergeUpdate(Requests);
    }
}