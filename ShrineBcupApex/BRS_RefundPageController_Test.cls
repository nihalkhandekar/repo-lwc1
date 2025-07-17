@isTest
public class BRS_RefundPageController_Test {
      @isTest
     static void testMethod1()  
 {
    Account acc=new Account();
    acc=BRS_TestDataFactory.createAccountObject();
    Contact con=new Contact();
    con=BRS_TestDataFactory.createContactObject(acc.id);
     List<Customer_Balance_Transaction__c> customerBalList= new List<Customer_Balance_Transaction__c>();
    Customer_Balance_Transaction__c customerBal=new Customer_Balance_Transaction__c();
    customerBal=BRS_TestDataFactory.createCustomerBalanceTransactionObject(con.id,'Debit',100);
     customerBalList.add(customerBal);
      Test.startTest();
        Test.setCurrentPage(Page.BRS_RefundPage);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(customerBalList);
        stdSetController.setSelected(customerBalList);
        BRS_RefundPageController ext = new BRS_RefundPageController(stdSetController);
        ext.getTotalAmount();
         ext.save();
    Test.stopTest();
 }
}