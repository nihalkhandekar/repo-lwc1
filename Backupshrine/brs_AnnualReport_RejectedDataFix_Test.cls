@isTest
public class brs_AnnualReport_RejectedDataFix_Test {
        @testSetup static void dataSetup(){
        Account acc = BRS_TestDataFactory.createAccountObject();
        Contact con = BRS_TestDataFactory.createContactObject(acc.Id);
        Work_Order__c workorder =BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Completed');
        OnOff_Filing_Auto_Refund__c onoff = BRS_TestDataFactory.onOffCustomSetting();
    }
    
    testmethod static void testGetBusiness() {
                Id mainRecTypeId = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Annual Report / First Report').getRecordTypeId(); 
        Account ac = [Select id, citizenship__c, business_type__c,Date_Intend_Forfeited__c from account limit 1];
          List<Business_Filing__c> lstFile = new List<Business_Filing__c>();
              Business_Filing__c filing3 = new Business_Filing__c();
        filing3.recordtypeid=mainRecTypeId;
        filing3.Account__c=ac.Id;
        filing3.Filing_Fee__c=30;
        filing3.Type__c = 'Annual Report';
        filing3.Citizenship__c = ac.citizenship__c;
        filing3.business_type__c = ac.business_type__c;
        filing3.Due_Date__c = System.today().addDays(-366);
        filing3.Status__c='Rejected';
        filing3.Filing_Date__c=System.today();
        filing3.Is_Rejected_Instantiated__c=false;
        lstFile.add(filing3);
        Business_Filing__c filing4 = new Business_Filing__c();
        filing4.recordtypeid=mainRecTypeId;
        filing4.Account__c=ac.Id;
        filing4.Filing_Fee__c=30;
        filing4.Type__c = 'Annual Report';
        filing4.Citizenship__c = ac.citizenship__c;
        filing4.business_type__c = ac.business_type__c;
        filing4.Is_Rejected_Instantiated__c=false;
        filing4.Due_Date__c = System.today().addDays(-366);
        filing4.Status__c='Rejected';
        lstFile.add(filing4);
             Business_Filing__c filing5 = new Business_Filing__c();
        filing5.recordtypeid=mainRecTypeId;
        filing5.Account__c=ac.Id;
        filing5.Filing_Fee__c=30;
        filing5.Type__c = 'Annual Report';
        filing5.Citizenship__c = ac.citizenship__c;
        filing5.business_type__c = ac.business_type__c;
        filing5.Is_Rejected_Instantiated__c=false;
        filing5.Due_Date__c = System.today();
        filing5.Status__c='Rejected';
        lstFile.add(filing5);
            Business_Filing__c filing6 = new Business_Filing__c();
        filing6.recordtypeid=mainRecTypeId;
        filing6.Account__c=ac.Id;
        filing6.Filing_Fee__c=30;
        filing6.Type__c = 'Annual Report';
        filing6.Citizenship__c = ac.citizenship__c;
        filing6.business_type__c = ac.business_type__c;
        filing6.Is_Rejected_Instantiated__c=false;
        filing6.Due_Date__c = System.today();
        filing6.Status__c='Approved';
        lstFile.add(filing6);
        insert lstFile;

        Test.startTest();
            brs_AnnualReport_RejectedDataFix obj = new brs_AnnualReport_RejectedDataFix();
            DataBase.executeBatch(obj); 
        Test.stopTest();
    }

}