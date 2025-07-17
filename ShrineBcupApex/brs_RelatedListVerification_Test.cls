@isTest
public class brs_RelatedListVerification_Test {
    class RecordDetail{
        public String objectname;
        public String record;
    }
    
    testmethod static void testPositiveScenario(){
        Account acc = BRS_TestDataFactory.createAccountObject();
        acc.Business_Type__c='LLP';
        acc.BillingState='CT';
        update acc;
        List<Account> acclist = new List<Account>();
        acclist.add(acc);
        brs_RelatedListVerification.Requests req1 = new brs_RelatedListVerification.Requests();
        req1.accountID = [Select Id From Account][0].Id;
        String[] objList = new String[]{'Agent__c','Account'};
        req1.objectList= JSON.serialize(objList);
         List<RecordDetail> recDetailList = new List<RecordDetail>();
        RecordDetail recDetail = new RecordDetail();
        recDetail.objectname='Agent__c';
        recDetail.record=acc.Id;
        recDetailList.add(recDetail);
        req1.recordList=JSON.serialize(recDetailList);
        
        List<brs_RelatedListVerification.Requests> Requests = new List<brs_RelatedListVerification.Requests>();
        Requests.add(req1);
        test.startTest();
        brs_RelatedListVerification.getRelatedVerificationStatusFlow(Requests);
        test.stopTest();
    }
    
     testmethod static void testNegativeScenario(){
        Account acc = BRS_TestDataFactory.createAccountObject();
        acc.Business_Type__c='LLP';
        acc.BillingState='CT';
        update acc;
        List<Account> acclist = new List<Account>();
        acclist.add(acc);
        brs_RelatedListVerification.Requests req1 = new brs_RelatedListVerification.Requests();
        req1.accountID = [Select Id From Account][0].Id;
        String[] objList = new String[]{'Principal__c','Account'};
        req1.objectList= JSON.serialize(objList);
         List<RecordDetail> recDetailList = new List<RecordDetail>();
        RecordDetail recDetail = new RecordDetail();
        recDetail.objectname='Principal__c';
        recDetail.record=acc.Id;
        recDetailList.add(recDetail);
       // req1.recordList=JSON.serialize(recDetailList);
        
        List<brs_RelatedListVerification.Requests> Requests = new List<brs_RelatedListVerification.Requests>();
        Requests.add(req1);
        test.startTest();
        brs_RelatedListVerification.getRelatedVerificationStatusFlow(Requests);
        test.stopTest();
    }
}