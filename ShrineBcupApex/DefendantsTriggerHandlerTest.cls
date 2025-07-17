@isTest
public class DefendantsTriggerHandlerTest{

    testmethod static void DefendantsTest(){
    
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Citizenship__c='Domestic';
        acc.Business_Type__c='LLP';
        acc.ClientAccountNum__c='12345';
        acc.Purpose_of_Business__c = 'Test business run';
        acc.BillingStreet = 'test';
        acc.BillingCity = 'test';
        acc.BillingState = 'CT';
        acc.BillingPostalCode = '234567';
        acc.BillingCountry = 'US';
        insert acc;
        
        account acc2 = new account();
        acc2.Name = 'Test account2';
        acc2.Citizenship__c='Domestic';
        acc2.Business_Type__c='LLP';
        acc2.ClientaccountNum__c='12345';
        acc2.Purpose_of_Business__c = 'Test business run';
        acc2.BillingStreet = 'test';
        acc2.BillingCity = 'test';
        acc2.BillingState = 'CT';
        acc2.BillingPostalCode = '234567';
        acc2.BillingCountry = 'US';
        insert acc2;
        
        Contact con = new Contact();
        con=BRS_TestDataFactory.createContactObject(acc.id);
        
        Work_Order__c workOrder = new Work_Order__c();
        workOrder.Source__c = 'Mail';
        workOrder.Received_Date__c = System.Now();
        workOrder.Completed_Date__c = System.Today();
        workOrder.Status__c = 'In-Progress';
        workOrder.Total_Hold_Amount__c= 0;
        workOrder.Payments_Verified__c= true;
        workOrder.Customer__c = con.id;
        insert workOrder;
        
        WRIT_Case__c wc = new WRIT_Case__c();
        wc.Work_Order__c = workOrder.id;
        wc.Number_of_Defendants__c = 4;
        wc.Type__c = 'WRIT Case';
        wc.Status__c = 'In-Progress';
        wc.No_Fee__c = True;
        insert wc;
        
        Id approvedRecordTypeId = Schema.SObjectType.Defendants__c.getRecordTypeInfosByDeveloperName().get('Approved').getRecordTypeId();
        Id rejectedRecordTypeId = Schema.SObjectType.Defendants__c.getRecordTypeInfosByDeveloperName().get('Rejected').getRecordTypeId();
        
        Defendants__c def1 = new Defendants__c();
        def1.Defendant_Name__c = 'test App';
        def1.RecordTypeID = approvedRecordTypeId;
        def1.Type_of_Defendant__c= 'Individuals';
        def1.Section_Number__c = '52-57';
        def1.Mailing_Status__c = 'No Mailing';
        def1.Mail_Type__c = 'Registered';
        def1.Mail_Number__c = '123456789';
        def1.WRIT_Case__c = wc.id;
        insert def1;
        
        Defendants__c def2 = new Defendants__c();
        def2.Defendant_Name__c = 'test App2';
        def2.RecordTypeID = rejectedRecordTypeId;
        def2.Rejection_custom_reason__c = 'test';
        def2.WRIT_Case__c = wc.id;
        insert def2;
        
        Defendants__c def3 = new Defendants__c();
        def3.Defendant_Name__c = 'test App3';
        def3.RecordTypeID = rejectedRecordTypeId;
        def3.Rejection_custom_reason__c = 'test';
        def3.WRIT_Case__c = wc.id;
        insert def3;
        
        Defendants__c def4 = new Defendants__c();
        def4.Defendant_Name__c = 'test App2';
        def4.Account__c = acc.id;
        def4.RecordTypeID = approvedRecordTypeId;
        def4.Type_of_Defendant__c= 'Corporation';
        def4.Section_Number__c = '33-929';
        def4.Mailing_Status__c = 'SOS Agent';
        def4.Mail_Type__c = 'Registered';
        def4.Mail_Number__c = '123456789';
        def4.WRIT_Case__c = wc.id;
        insert def4;
        
        def4.Account__c = acc2.id;
        update def4;
        
        delete def4;
        delete def2;
    }
}