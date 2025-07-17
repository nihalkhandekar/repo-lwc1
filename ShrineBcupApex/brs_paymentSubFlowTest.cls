@isTest
private class brs_paymentSubFlowTest {
    
    @testSetup static void setup() {
        Id mainRecTypeId = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('New Business').getRecordTypeId();  
        List<Profile> lstProfileId = [Select Id From Profile Where Name = 'CT Community User']; 
        Account acc = new Account();
        acc = BRS_TestDataFactory.createAccountObject();
        Contact con = new Contact();
        con = BRS_TestDataFactory.createContactObject(acc.id);
        User user = new User();
        user = BRS_TestDataFactory.createCommunityUser(con,lstProfileId[0].Id);
        UCC_Lien__c uccLien = new UCC_Lien__c();
        uccLien = BRS_TestDataFactory.createUCCLien('Aircraft');
        OnOff_Filing_Auto_Refund__c  onOff = BRS_TestDataFactory.onOffCustomSetting();
        UCC_Filing__c uccFiling = new UCC_Filing__c();
        BRS_TestDataFactory.createUCCFiling('Not Applicable','In-Progress',uccLien.Id,'');
        Work_Order__c workorder = BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Completed');
        Business_Filing__c businessFiling = new Business_Filing__c();
        businessFiling = BRS_TestDataFactory.createBusinessFilingObject(mainRecTypeId,acc.id,workorder.Id,'Business Formation','Approved'); 
        BRS_TestDataFactory.createTempHistoryObject();
        Id mainCertTypeId = Schema.SObjectType.Certficate__c.getRecordTypeInfosByName().get('Certificate Request').getRecordTypeId();
        Certficate__c cert = BRS_TestDataFactory.createCertificate(mainCertTypeId, acc.Id, WorkOrder.Id);
        
    }
    @isTest
    static void testPaymentSubFlowServerCall_UCCFiling() {
        List<brs_paymentSubFlow.Request> lstRequest = new List<brs_paymentSubFlow.Request>();
        brs_paymentSubFlow.Request req1 = new brs_paymentSubFlow.Request();
        req1.parentRecordId = [Select Id From UCC_Filing__c][0].Id;
        User u = [Select id from User where isActive = TRUE LIMIT 1];
        lstRequest.add(req1);
        System.runAs(u){
            test.startTest();
            brs_paymentSubFlow.paymentSubFlowServerCall(lstRequest);
            test.stopTest();           
        }       
    }
    @isTest
    static void testPaymentSubFlowServerCall_BusinessFiling() {
        List<brs_paymentSubFlow.Request> lstRequest = new List<brs_paymentSubFlow.Request>();
        brs_paymentSubFlow.Request req2 = new brs_paymentSubFlow.Request();
        req2.parentRecordId = [Select Id From Business_Filing__c][0].Id;
        lstRequest.add(req2);
        test.startTest();
        brs_paymentSubFlow.paymentSubFlowServerCall(lstRequest);
        test.stopTest();
    }
    @isTest
    static void testPaymentSubFlowServerCall_TmpHistory() {
        List<brs_paymentSubFlow.Request> lstRequest = new List<brs_paymentSubFlow.Request>();
        brs_paymentSubFlow.Request req3 = new brs_paymentSubFlow.Request();
        req3.parentRecordId = [Select Id From Temp_History__c][0].Id;
        lstRequest.add(req3);
        test.startTest();
        brs_paymentSubFlow.paymentSubFlowServerCall(lstRequest);
        test.stopTest();
        //brs_paymentSubFlow.paymentWrapperSubflow('test','');
    }    
    
    @isTest
    static void testPaymentSubFlowServerCall_Certficate() {
        List<brs_paymentSubFlow.Request> lstRequest = new List<brs_paymentSubFlow.Request>();
        brs_paymentSubFlow.Request req4 = new brs_paymentSubFlow.Request();
        req4.parentRecordId = [Select Id From Certficate__c][0].Id;
        lstRequest.add(req4);
        test.startTest();
        brs_paymentSubFlow.paymentSubFlowServerCall(lstRequest);
        test.stopTest();
    }  
}