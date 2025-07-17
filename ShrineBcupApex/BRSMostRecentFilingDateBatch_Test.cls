@isTest
public class BRSMostRecentFilingDateBatch_Test {
    @testSetup static void dataSetup(){
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Annual Report / First Report').getRecordTypeId();
        Account acc = BRS_TestDataFactory.createAccountObject();
        Contact con = BRS_TestDataFactory.createContactObject(acc.Id);
        Work_Order__c workorder =BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Completed');
        OnOff_Filing_Auto_Refund__c onoff = BRS_TestDataFactory.onOffCustomSetting();
        
        Business_Filing__c filing = BRS_TestDataFactory.createBusinessFilingObject(RecordTypeIdMaintenance,acc.Id,workorder.Id,'Annual Report',System.label.Approved);
        filing.Filing_Date__c=System.today()-100;
        System.debug('***filing'+filing);
        update filing;
        Business_Filing__c filing1 = BRS_TestDataFactory.createBusinessFilingObject(RecordTypeIdMaintenance,acc.Id,workorder.Id,'Annual Report',System.label.Approved);
    }
    @isTest static void executeBatchTest(){
        Test.startTest();
        String query='SELECT ID FROM Account WHERE status__c not in: statuses';
       BRSMostRecentFilingDateBatch bmr=new BRSMostRecentFilingDateBatch(query);
         Database.executeBatch(bmr);
         Test.stopTest();
    }
    
    @isTest static void executeBatchTest2(){
          Test.startTest();
          Account acc = [Select id from account limit 1];
          Agent__c ag = BRS_TestDataFactory.createAgent(acc.Id);
            acc.Sub_Status__c = system.label.brs_AgentResign_AccountSubStatus;
            acc.BillingStreet= 'Test';
            acc.Reason_for_Administrative_Dissolution__c = null;
            update acc;
          Business_Filing__c busFile = [Select id from Business_Filing__c where Account__c =: acc.Id and Type__c = 'Annual Report' limit 1];
          busFile.Due_Date__c = system.today().addDays(-370);
          busFile.Status__c = 'Past Due';
          busFile.Type__c= 'First Report';
          update busFile;  
          String query='SELECT ID,sub_status__c,status__c,citizenship__c,business_type__c,billingstate FROM Account WHERE Reason_for_Administrative_Dissolution__c = null and status__c not in: statuses and sub_status__c in: substatuses'; 
          brs_AdminDissolutionBatch bmr=new brs_AdminDissolutionBatch(query);
          Database.executeBatch(bmr);
          Test.stopTest();
    }
    @isTest static void executeBatchTest4(){
          Test.startTest();
          Account acc = [Select id from account limit 1];
          Agent__c ag = BRS_TestDataFactory.createAgent(acc.Id);
            acc.Sub_Status__c = system.label.brs_AgentResign_AccountSubStatus;
            acc.BillingStreet= 'Test';
            acc.Reason_for_Administrative_Dissolution__c = null;
            update acc;
          Business_Filing__c busFile = [Select id from Business_Filing__c where Account__c =: acc.Id and Type__c = 'Annual Report' limit 1];
          busFile.Due_Date__c = system.today().addDays(-370);
          busFile.Status__c = 'Past Due';
          update busFile;  
          String query='SELECT ID,sub_status__c,status__c,citizenship__c,business_type__c,billingstate FROM Account WHERE Reason_for_Administrative_Dissolution__c = null and status__c not in: statuses and sub_status__c in: substatuses'; 
          brs_AdminDissolutionBatch bmr=new brs_AdminDissolutionBatch(query);
          Database.executeBatch(bmr);
          Test.stopTest();
    }
    @isTest static void executeBatchTest5(){
          Test.startTest();
          Account acc = [Select id from account limit 1];
          Agent__c ag = BRS_TestDataFactory.createAgent(acc.Id);
            acc.Sub_Status__c = system.label.Account_Annual_report_past_due;
            acc.BillingStreet= 'Test';
            acc.Reason_for_Administrative_Dissolution__c = null;
            update acc;
          Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Close / Reinstate').getRecordTypeId();
          List<Business_Filing__c> busFile2 = new List<Business_Filing__c>();
          List<Business_Filing__c> busFile = [Select id,Filing_Date__c,Account__c from Business_Filing__c where Account__c =: acc.Id and Type__c = 'Annual Report' limit 2];
          for(Business_Filing__c file :busFile )
          {
              if(file.filing_date__c == System.today()-100)
              {
              file.Date_Intend_Forfeited__c = system.today().addDays(10);
              file.Status__c = 'Approved';
              file.RecordTypeId= RecordTypeIdMaintenance;
              file.Filing_Type__c= system.label.Notice_of_Intent_to_Dissolve_Revoke_Label;
              }
              else
              {
              file.Due_Date__c = system.today().addDays(-370);
              file.Status__c = 'Past Due';
              }
              busFile2.add(file);
          }
          update busFile2;  
          String query='SELECT ID,sub_status__c,status__c,citizenship__c,business_type__c,billingstate FROM Account WHERE Reason_for_Administrative_Dissolution__c = null and status__c not in: statuses and sub_status__c in: substatuses'; 
          brs_AdminDissolutionBatch bmr=new brs_AdminDissolutionBatch(query);
          Database.executeBatch(bmr);
          Test.stopTest();
    }
    @isTest static void executeBatchTest6(){
          Test.startTest();
          Account acc = [Select id from account limit 1];
          Agent__c ag = BRS_TestDataFactory.createAgent(acc.Id);
            acc.Sub_Status__c ='Ready for dissolution';
            acc.BillingStreet= 'Test';
            acc.business_type__c= 'LLC';
            acc.Reason_for_Administrative_Dissolution__c = null;
            acc.Mailing_International_Address__c = 'jghgdgfdfdfdsfdfdf';
            update acc;
            acc.Sub_Status__c = system.label.Admin_Dissolution_Initiated_Label;
            update acc;
           delete ag; 
          Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Close / Reinstate').getRecordTypeId();
          List<Business_Filing__c> busFile2 = new List<Business_Filing__c>();
          List<Business_Filing__c> busFile = [Select id,Filing_Date__c,Account__c from Business_Filing__c where Account__c =: acc.Id and Type__c = 'Annual Report' limit 2];
          for(Business_Filing__c file :busFile )
          {
              if(file.filing_date__c == System.today()-100)
              {
              file.Date_Intend_Forfeited__c = system.today().addDays(-10);
              file.Status__c = 'Approved';
              file.RecordTypeId= RecordTypeIdMaintenance;
              file.Filing_Type__c= system.label.Notice_of_Intent_to_Dissolve_Revoke_Label;
              }
              else
              {
              file.Due_Date__c = system.today().addDays(-370);
              file.Status__c = 'Past Due';
              }
              busFile2.add(file);
          }
          update busFile2;  
          String query='SELECT ID,sub_status__c,status__c,citizenship__c,business_type__c,billingstate FROM Account WHERE Reason_for_Administrative_Dissolution__c = null and status__c not in: statuses and sub_status__c in: substatuses'; 
          brs_AdminDissolutionBatch bmr=new brs_AdminDissolutionBatch(query);
          Database.executeBatch(bmr);
          Test.stopTest();
    }
    @isTest static void executeBatchTest3(){
          Test.startTest();
          Account acc = [Select id from account limit 1];
          Agent__c ag = BRS_TestDataFactory.createAgent(acc.Id);
            acc.Sub_Status__c = system.label.brs_AgentResign_AccountSubStatus;
            acc.BillingStreet= 'Test';
            acc.Reason_for_Administrative_Dissolution__c = null;
            acc.business_type__c= 'LLC';
            acc.Mailing_International_Address__c = 'jghgdgfdfdfdsfdfdf';
            update acc;
          delete ag;  
          String query='SELECT ID,sub_status__c,status__c,citizenship__c,business_type__c,billingstate FROM Account WHERE Reason_for_Administrative_Dissolution__c = null and status__c not in: statuses and sub_status__c in: substatuses'; 
          brs_AdminDissolutionBatch bmr=new brs_AdminDissolutionBatch(query);
          Database.executeBatch(bmr);
          Test.stopTest();
    }
    @isTest static void executeBatchTestw(){
       Test.startTest();
      String query='SELECT ID FROM Account WHERE status__c = \'Reserved\'';
      BRSMostRecentFilingDateBatch bmr=new BRSMostRecentFilingDateBatch(query);
      Database.executeBatch(bmr);
      Test.stopTest();
  }
}