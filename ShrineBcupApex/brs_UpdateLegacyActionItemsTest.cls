@isTest public class brs_UpdateLegacyActionItemsTest {
 @testSetup static void testData(){
        Account testAcc1 = BRS_TestDataFactory.createAccountObject();
        
        Contact con = BRS_TestDataFactory.createContactObject(testAcc1.Id);
        
        Work_Order__c workorder =BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Completed');
        
        OnOff_Filing_Auto_Refund__c onOff1 = BRS_TestDataFactory.onOffCustomSetting();
        
        Id annualFirstrecTypeId = Wizard_Utlity.getRecordTypeId(system.label.Annual_First_recordtype_label,Schema.Business_Filing__c.getSObjectType());
        Business_Filing__c filing = new Business_Filing__c();
        filing.Account__c=testAcc1.Id;
        filing.Filing_Fee__c=30;
        filing.Type__c = System.Label.First_Report_Label;
        filing.Citizenship__c = 'Domestic';
        filing.Filing_Date__c = System.Today().addDays(-30);
        filing.Due_Date__c = (System.today() + 5);
        filing.recordtypeId=annualFirstrecTypeId;
        filing.Work_Order__c=workorder.Id;
        filing.Status__c='Due';
        insert filing;
        
        Business_Filing__c filing1 = new Business_Filing__c();
        filing1.Account__c=testAcc1.Id;
        filing1.Filing_Fee__c=30;
        filing1.Type__c = 'Annual Report';
        filing1.Citizenship__c = 'Domestic';
        filing1.Filing_Date__c = System.Today().addDays(-30);
        filing1.Due_Date__c = (System.today() + 5);
        filing1.recordtypeId=annualFirstrecTypeId;
        filing1.Work_Order__c=workorder.Id;
        filing1.Status__c='Due';
        insert filing1;
     
     	Action_Item__c act= new Action_Item__c(Action_Item_Name__c = filing1.Type__c,
                                                               Account__c = filing1.Account__c,
                                                               Contact__c = con.Id,                                                              
                                                               Status__c = 'Open',
                                                               Due_Date__c = filing1.Due_Date__c);
     	insert act;
      
    }
    @isTest static void actionItemTesting(){
         List<Business_Filing__c> bflings= [Select id,Account__c,Type__c,Due_Date__c From Business_Filing__c where Type__c='First Report'];
        Test.startTest();
        Database.executeBatch(new brs_UpdateLegacyActionItems('update'));
        Database.executeBatch(new brs_UpdateLegacyActionItems('create',System.today()+1));
        String q='Select Id,Action_Item_Name__c,Account__r.Status__c,Status__c,Business_Filing__c From Action_Item__c where Status__c=\'Open\' AND Action_Item_Name__c=\'Annual Report\' AND Account__c!=null AND Account__r.Status__c=\'Active\' AND Business_Filing__c=null';
         Database.executeBatch(new brs_UpdateLegacyActionItems('update',q));
        Test.stopTest();
        
    }
}