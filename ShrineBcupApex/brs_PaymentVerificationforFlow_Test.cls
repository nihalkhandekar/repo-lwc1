@isTest
public class brs_PaymentVerificationforFlow_Test {
    testmethod static void test1(){
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
      	Account acc = BRS_TestDataFactory.createAccountObject();
        Contact con = BRS_TestDataFactory.createContactObject(acc.Id);
        Work_Order__c workorder =BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Completed');
        OnOff_Filing_Auto_Refund__c onoff = BRS_TestDataFactory.onOffCustomSetting();
        Business_Filing__c filing = BRS_TestDataFactory.createBusinessFilingObject(RecordTypeIdMaintenance,acc.Id,workorder.Id,System.label.Name_Change_Amendment,System.label.BRS_Submitted_Agent_acceptance_pending);
		brs_PaymentVerificationforFlow.Requests req1 = new brs_PaymentVerificationforFlow.Requests();
        req1.recordid = [Select Id From Work_Order__c][0].Id;
        List<brs_PaymentVerificationforFlow.Requests> Requests = new List<brs_PaymentVerificationforFlow.Requests>();
        Requests.add(req1);
        test.startTest();
        brs_PaymentVerificationforFlow.getPaymentVerificationStatusFlow(Requests);
        test.stopTest();
    }
}