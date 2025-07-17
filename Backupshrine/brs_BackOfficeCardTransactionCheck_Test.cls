@isTest 
public class brs_BackOfficeCardTransactionCheck_Test {
    @TestSetup
    static void testSetup() {
        Account testAcc1 = BRS_TestDataFactory.createAccountObject();
        Contact con = BRS_TestDataFactory.createContactObject(testAcc1.Id);
        Work_Order__c workorder =BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'In-Progress');
        Payment_Method__c pm=BRS_TestDataFactory.cardPaymentMethod(workorder.Id);        
    }
    @isTest 
    static void getPaymentVerificationStatusFlowTest(){
        Work_Order__c wo=[Select Id,Name from Work_Order__c LIMIT 1];
        brs_BackOfficeCardTransactionCheck.Requests req=new brs_BackOfficeCardTransactionCheck.Requests();
        req.workOrderId=wo.Id;       
        brs_BackOfficeCardTransactionCheck.getPaymentVerificationStatusFlow(new List<brs_BackOfficeCardTransactionCheck.Requests>{req});
    }
}