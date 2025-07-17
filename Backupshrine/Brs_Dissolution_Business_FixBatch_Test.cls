@IsTest
public class Brs_Dissolution_Business_FixBatch_Test {
    
    testmethod public static void Brs_Dissolution_Business_FixBatchTest() {
        Id RecordTypeIdAnnual = [Select Id,name,developername From RecordType where sobjecttype = 'Business_Filing__c' and developername='Annual_Report_First_Report' limit 1].id;
        Account testAcc1 = BRS_TestDataFactory.createAccountObject();//Annual Report / First Report
        Contact con = BRS_TestDataFactory.createContactObject(testAcc1.Id);
        Work_Order__c workorder =BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Completed');
        OnOff_Filing_Auto_Refund__c onoff = BRS_TestDataFactory.onOffCustomSetting();
        List<Business_Filing__c> busFileLst = new List<Business_Filing__c>();
        List<Business_Filing__c> busFileLst2 = new List<Business_Filing__c>();
        Business_Filing__c filing = new Business_Filing__c();
        filing.recordtypeid=RecordTypeIdAnnual;
        filing.Account__c=testAcc1.Id;
        filing.Filing_Fee__c=30;
        filing.Work_Order__c=workorder.Id;
        filing.Type__c = 'Annual Report';
        filing.Filing_Type__c ='Annual Report';
        filing.Filing_Date__c = System.Today().addDays(-30);
        filing.Due_Date__c = (System.today() + 5);
        filing.Status__c='Approved';
        filing.Citizenship__c='Domestic';
        busFileLst.add(filing);
            Business_Filing__c filing1 = new Business_Filing__c();
        filing1.recordtypeid=RecordTypeIdAnnual;
        filing1.Account__c=testAcc1.Id;
        filing1.Filing_Fee__c=30;
        filing1.Work_Order__c=workorder.Id;
        filing1.Type__c = 'Annual Report';
        filing1.Filing_Type__c ='Annual Report';
        filing1.Filing_Date__c = System.Today().addDays(-30);
        filing1.Due_Date__c = (System.today() + 5);
        filing1.Status__c='Past Due';
        filing1.Citizenship__c='Domestic';
        busFileLst.add(filing1);
        testAcc1.status__c='Dissolved';
        insert busFileLst;
        update testAcc1;
        Test.startTest();

            Brs_Dissolution_Business_Data_FixBatch obj = new Brs_Dissolution_Business_Data_FixBatch();
            DataBase.executeBatch(obj); 
            
        Test.stopTest();
        
        
    }
    testmethod public static void Brs_Dissolution_Business_FixBatchTest1() {
        Id RecordTypeIdAnnual = [Select Id,name,developername From RecordType where sobjecttype = 'Business_Filing__c' and developername='Annual_Report_First_Report' limit 1].id;
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Citizenship__c='Domestic';
        acc.Business_Type__c='Stock';
        acc.ClientAccountNum__c='12345';
        acc.Total_Authorized_Shares__c=1;
        acc.Purpose_of_Business__c = 'Test business run';
        acc.Status__c='Active';
        insert acc;
        Contact con = BRS_TestDataFactory.createContactObject(acc.Id);
        Work_Order__c workorder =BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Completed');
        OnOff_Filing_Auto_Refund__c onoff = BRS_TestDataFactory.onOffCustomSetting();
        List<Business_Filing__c> busFileLst = new List<Business_Filing__c>();
        List<Business_Filing__c> busFileLst2 = new List<Business_Filing__c>();
        Business_Filing__c filing = new Business_Filing__c();
        filing.recordtypeid=RecordTypeIdAnnual;
        filing.Account__c=acc.Id;
        filing.Filing_Fee__c=30;
        filing.Work_Order__c=workorder.Id;
        filing.Type__c = 'Annual Report';
        filing.Filing_Type__c ='Annual Report';
        filing.Filing_Date__c = System.Today().addDays(-30);
        filing.Due_Date__c = (System.today() + 5);
        filing.Status__c='Approved';
        filing.Citizenship__c='Domestic';
        busFileLst.add(filing);
            Business_Filing__c filing1 = new Business_Filing__c();
        filing1.recordtypeid=RecordTypeIdAnnual;
        filing1.Account__c=acc.Id;
        filing1.Filing_Fee__c=30;
        filing1.Work_Order__c=workorder.Id;
        filing1.Type__c = 'Annual Report';
        filing1.Filing_Type__c ='Annual Report';
        filing1.Filing_Date__c = System.Today().addDays(-30);
        filing1.Due_Date__c = (System.today() + 5);
        filing1.Status__c='Past Due';
        filing1.Citizenship__c='Domestic';
        busFileLst.add(filing1);
        acc.status__c='Forfeited';
        insert busFileLst;
        update acc;
        Test.startTest();

            Brs_Dissolution_Business_Data_FixBatch obj = new Brs_Dissolution_Business_Data_FixBatch();
            DataBase.executeBatch(obj); 
            
        Test.stopTest();
        
        
    }

}