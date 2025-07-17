@isTest
public class brs_BatchRefundQueueable_Test {
	  @TestSetup
    static void testSetup() {
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
        Account testAcc1 = BRS_TestDataFactory.createAccountObject();//Annual Report / First Report
        Contact con = BRS_TestDataFactory.createContactObject(testAcc1.Id);
        Work_Order__c workorder =BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Completed');
        OnOff_Filing_Auto_Refund__c onoff = BRS_TestDataFactory.onOffCustomSetting();
        List<Business_Filing__c> busFileLst = new List<Business_Filing__c>();
        Business_Filing__c filing = new Business_Filing__c();
        filing.recordtypeid=RecordTypeIdMaintenance;
        filing.Account__c=testAcc1.Id;
        filing.Filing_Fee__c=30;
        filing.Work_Order__c=workorder.Id;
        filing.Type__c = 'Amendment';
        filing.Amendment_Type__c ='Amend Name';
        filing.Filing_Date__c = System.Today().addDays(-30);
        filing.Due_Date__c = (System.today() + 5);
        filing.Status__c='Approved';
        busFileLst.add(filing);
        insert busFileLst;
    }
    testmethod public static void processMaintenanceFilings() {
                OnOff_Filing_Auto_Refund__c onOffSwich = OnOff_Filing_Auto_Refund__c.getall().values()[0];
        onOffSwich.Auto_Refund_Business_Filing__c=true;
        update onOffSwich;
        Business_filing__c filing = [select id, Type__c, Status__c,Work_Order__c from Business_filing__c limit 1];
        update new Work_Order__c(Id=filing.Work_Order__c,Status__c='Completed',Source__c='Online');
        BRS_TestDataFactory.createStripeTransactionObject(filing.Work_Order__c);
        Test.startTest();
        System.enqueueJob(new brs_BatchRefundQueueable(new Set<Id>{filing.Id}));
        test.stopTest();
    }
}