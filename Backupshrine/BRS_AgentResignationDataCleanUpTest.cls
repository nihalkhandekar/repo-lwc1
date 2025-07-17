@isTest
public class BRS_AgentResignationDataCleanUpTest {
    @isTest public static void testMethod1(){
        Account testAcc1 = BRS_TestDataFactory.createAccountObject();
        Contact con = BRS_TestDataFactory.createContactObject(testAcc1.Id);
        Work_Order__c workorder =BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Completed');        
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
        BRS_TestDataFactory.createAgent(testAcc1.Id);
                List<Business_Filing__c> busFileLst = new List<Business_Filing__c>();

        Business_Filing__c filing = new Business_Filing__c();
        filing.recordtypeid=RecordTypeIdMaintenance;
        filing.Account__c=testAcc1.Id;
        filing.Filing_Fee__c=30;
        filing.Work_Order__c=workorder.Id;
        filing.Type__c = 'Agent Resignation';
        filing.Filing_Date__c = System.Today();
        filing.Due_Date__c = (System.today() + 5);
        filing.Status__c='Approved';
        busFileLst.add(filing);
        
        Business_Filing__c filing2 = new Business_Filing__c();
        filing2.recordtypeid=RecordTypeIdMaintenance;
        filing2.Account__c=testAcc1.Id;
        filing2.Filing_Fee__c=30;
        filing2.Work_Order__c=workorder.Id;
        filing2.Type__c = 'Change of Agent';
        filing2.Amendment_Type__c ='Amend Name';
        filing2.Filing_Date__c = System.Today();
        filing2.Due_Date__c = (System.today() + 5);
         filing2.Filing_Date__c = System.Today().addDays(-32);
        filing2.Status__c='Approved';
        busFileLst.add(filing2);
        insert busFileLst;
        Test.startTest();
       
        List<Account> accList=[Select Id,Name,Sub_status__c,Reason_for_Administrative_Dissolution__c,(Select Id,Account__c,Type__c,status__c,Filing_Date__c From Business_Filings__r where status__c = 'Approved' AND (Type__c ='Change Agent' OR Type__c = 'Agent Resignation' OR Type__c = 'Change of Agent') ORDER BY Filing_Date__c DESC),(Select Id,Name,Business_ID__c from Agents__r) From Account where Id =:testAcc1.Id];
        Set<Id> accIds=new Set<Id>{accList[0].Id};
        BRS_AgentResignationDataCleanUp bar=new BRS_AgentResignationDataCleanUp(accIds);
		bar.execute(null,accList);
        bar.finish(null);
        bar.start(null);
        Test.stopTest();
    }
}