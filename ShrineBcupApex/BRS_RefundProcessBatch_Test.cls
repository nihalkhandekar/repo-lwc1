@isTest
public class BRS_RefundProcessBatch_Test {
    
    @testSetup static void setup() {
               
        
        Contact con = new Contact(); 
        con = BRS_TestDataFactory.createContactObject('');
        
       /* List<Customer_Balance_Transaction__c> lstCB = new List<Customer_Balance_Transaction__c>();
        Customer_Balance_Transaction__c cb1 = new Customer_Balance_Transaction__c();
        cb1.Contact__c = con.id;
        cb1.Amount__c = 2;
        cb1.Payment_Source__c ='Check';
        cb1.Type__c = 'Debit';
        lstCB.add(cb1);
        
        Customer_Balance_Transaction__c cb2 = new Customer_Balance_Transaction__c();
        cb2.Contact__c = con.id;
        cb2.Amount__c = 5;
        cb2.Payment_Source__c = 'Check';
        cb2.Type__c = 'Credit';
        lstCB.add(cb2);
        insert lstCB;*/
        
        Customer_Balance_Transaction__c cb1 = new Customer_Balance_Transaction__c();
        Customer_Balance_Transaction__c cb2 = new Customer_Balance_Transaction__c();
        cb1 = BRS_TestDataFactory.createCustomerBalanceTransactionObject(con.id,'Debit',2);
        cb2 = BRS_TestDataFactory.createCustomerBalanceTransactionObject(con.id,'Credit',5);
        
    }
    
    @isTest
    static void BRS_RefundProcessBatchTest(){
        
        test.startTest();
        BRS_RefundProcessBatch obj = new BRS_RefundProcessBatch();
        DataBase.executeBatch(obj);
        String sch = '0 0 2 * * ?'; 
        system.schedule('Test Territory Check', sch, obj); 
        test.stopTest();
    }
    
}