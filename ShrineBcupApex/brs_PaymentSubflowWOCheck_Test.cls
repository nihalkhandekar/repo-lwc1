@isTest
public class brs_PaymentSubflowWOCheck_Test {

        testmethod static void test1(){
            brs_PaymentSubflowWOCheck.Requests req=new brs_PaymentSubflowWOCheck.Requests();
            req.refrenceRecordid='sd222323232';
            List<brs_PaymentSubflowWOCheck.Requests> reqList=new List<brs_PaymentSubflowWOCheck.Requests>();
            reqList.add(req);
            Test.startTest();
            brs_PaymentSubflowWOCheck.checkWorkorder(reqList);
            Test.stopTest();
        }
}