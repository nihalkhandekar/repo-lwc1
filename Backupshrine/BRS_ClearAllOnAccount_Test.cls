@isTest
public with sharing class BRS_ClearAllOnAccount_Test {
    @testSetup 
    static void setup() {
        Account testAccts = new Account(Name = 'TestClassAcct', Status__c = 'Active', Account_Name_Without_Designators__c = 'TESTCLASSACCT',Citizenship__c = 'Domestic', Business_Type__c = 'Religious',
                                  BillingCity='Mumbai',
                                  BillingState='WA',
                                  BillingPostalCode='12345',
                                  BillingCountry='India',
                                  BillingStreet='Baker street',
                                  ShippingStreet='Bak',
                                  ShippingCity='Mumbai',
                                  ShippingState='WA',
                                  ShippingPostalCode='12345',
                                  ShippingCountry='India',
                                  Mailing_Address__c='ab',
                                  Mailing_International_Address__c='ABC street, abc city, abc state, abc country, 12345');
        insert testAccts;
        BRS_TestDataFactory.createPrincipalRecords(testAccts.Id);
        BRS_TestDataFactory.createAgent(testAccts.Id);
        List<Stock_Classification__c> lstsk = new List<Stock_Classification__c>();
        Stock_Classification__c sk = new Stock_Classification__c();
        sk.Number_of_Stocks__c=100;
        sk.Par_Value__c =10;
        sk.AccountId__c = testAccts.Id;
        lstsk.add(sk);
        insert lstsk;
    }
    @isTest
    static void testclearAllFields() {
        Account accId  = [Select id,name,Account_Name_Without_Designators__c from Account Limit 1];
        Test.startTest();
        try {
            List<BRS_ClearAllOnAccount.Requests> lstRequest = new  List<BRS_ClearAllOnAccount.Requests>();
            BRS_ClearAllOnAccount.Requests oRequest = new BRS_ClearAllOnAccount.Requests();
            oRequest.accId = accId.Id;
            lstRequest.add(oRequest);
            BRS_ClearAllOnAccount.clearAllFields(lstRequest);
        } catch (Exception e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        Test.stopTest();
    }
}