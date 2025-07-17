@isTest
public class BRS_UpdateAnnualReportDate_Batch_Test {
        @testSetup static void dataSetup(){
        Account acc = BRS_TestDataFactory.createAccountObject();
        acc.Annual_Report_Due_Date__c=System.today().addDays(-366);
        update acc;
        Contact con = BRS_TestDataFactory.createContactObject(acc.Id);
        Work_Order__c workorder =BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Completed');
        OnOff_Filing_Auto_Refund__c onoff = BRS_TestDataFactory.onOffCustomSetting();
    }
    
    testmethod static void testGetBusiness() {
       Id RecordTypeIdCloseReinstate = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Close / Reinstate').getRecordTypeId();
                Id mainRecTypeId = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Annual Report / First Report').getRecordTypeId(); 
        Account ac = [Select id, citizenship__c, business_type__c,Annual_Report_Due_Date__c,Date_Intend_Forfeited__c from account limit 1];
          List<Business_Filing__c> lstFile = new List<Business_Filing__c>();
              Business_Filing__c filing3 = new Business_Filing__c();
        filing3.recordtypeid=mainRecTypeId;
        filing3.Account__c=ac.Id;
        filing3.Filing_Fee__c=30;
        filing3.Type__c = 'Annual Report';
        filing3.Citizenship__c = ac.citizenship__c;
        filing3.business_type__c = ac.business_type__c;
        filing3.Filing_Date__c = System.Today().addDays(-30);
        filing3.Due_Date__c = System.today().addDays(-366);
        filing3.Status__c='Past Due';
        filing3.Filing_Date__c=System.today();
        filing3.Date_Intend_Forfeited__c =System.today().addDays(2);
        lstFile.add(filing3);
        Business_Filing__c filing4 = new Business_Filing__c();
        filing4.recordtypeid=mainRecTypeId;
        filing4.Account__c=ac.Id;
        filing4.Filing_Fee__c=30;
        filing4.Type__c = 'Annual Report';
        filing4.Citizenship__c = ac.citizenship__c;
        filing4.business_type__c = ac.business_type__c;
        filing4.Due_Date__c = System.today().addDays(366);
        filing4.Status__c='Due';
        lstFile.add(filing4);
        
        insert lstFile;
        ac.Status__c = 'Forfeited';
        update ac;
 
             Business_Filing__c filing2 = new Business_Filing__c();
        filing2.recordtypeid=RecordTypeIdCloseReinstate ;
        filing2.Account__c=ac.Id;
        filing2.Filing_Fee__c=30;
        filing2.Type__c = 'Reinstatement';
        filing2.Citizenship__c = ac.citizenship__c;
        filing2.business_type__c = ac.business_type__c;
        filing2.Filing_Date__c = System.Today();
        filing2.Due_Date__c = (System.today() + 5);
        filing2.Status__c=System.label.Approved;
        filing2.Date_Intend_Forfeited__c =System.today().addDays(2);
        insert filing2;
        ac.Status__c = 'Active';
        ac.Date_Intend_Forfeited__c  = null;
        update ac;
        Test.startTest();
            BRS_UpdateAnnualReportDate_Batch obj = new BRS_UpdateAnnualReportDate_Batch();
            DataBase.executeBatch(obj); 
        Test.stopTest();
    }

}