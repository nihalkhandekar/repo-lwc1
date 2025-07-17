@isTest
private class brs_IsPaymentSuccessfulTest {

    @testSetup 
    static void setup() {
        UCC_Lien__c uccLien = new UCC_Lien__c();
        uccLien = BRS_TestDataFactory.createUCCLien('OFS');
        OnOff_Filing_Auto_Refund__c onOff1 = BRS_TestDataFactory.onOffCustomSetting();
        UCC_Filing__c uccFiling = new UCC_Filing__c();      
        uccFiling = BRS_TestDataFactory.createUCCFiling('Not Applicable','In-Progress',uccLien.Id,'Aircraft');
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Citizenship__c='Domestic';
        acc.Business_Type__c='LLP';
        acc.ClientAccountNum__c='12345';
        acc.Purpose_of_Business__c = 'Test';
        insert acc;
        
        Contact con = new Contact();
        con = BRS_TestDataFactory.createContactObject(acc.Id);        
        
        Work_Order__c workOrder = new Work_Order__c();
        workOrder = BRS_TestDataFactory.createWorkOrderObject(con.id,'online','Completed');
    
        bt_stripe__Transaction__c txn = new bt_stripe__Transaction__c();
        txn = BRS_TestDataFactory.createStripeTransactionObject(workOrder.id);
    }
    
    @isTest
    static void testIsPaymentSuccess() {
        OnOff_Filing_Auto_Refund__c onOff1 = BRS_TestDataFactory.onOffCustomSetting();
        UCC_Filing__c uccFiling = new UCC_Filing__c(); 
        Work_Order__c workOrder = new Work_Order__c();        
        uccFiling = [Select id from UCC_Filing__c ];   
        workOrder= [Select id from Work_Order__c] ;     
        List<brs_IsPaymentSuccessful.Input> inpList =  new List<brs_IsPaymentSuccessful.Input>();
        brs_IsPaymentSuccessful.Input inp = new brs_IsPaymentSuccessful.Input();
        inp.recordId = uccFiling.Id;
        inp.workOrderId = workOrder.Id;
        inpList.add(inp);
        test.startTest();
        brs_IsPaymentSuccessful.isPaymentSuccess(inpList);
        test.stopTest();
    }
    
}