@isTest
public class brs_FilingDocsDataFixTest {
    
    @isTest static void createTestData(){
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
        Account acc=BRS_TestDataFactory.createAccountObject();
        acc.Status__c='Forfeited';
        update acc;
        Contact con = BRS_TestDataFactory.createContactObject(acc.Id);
        Work_Order__c workorder =BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Completed');
        Business_Filing__c filing=new Business_Filing__c();
        filing.RecordTypeId = RecordTypeIdMaintenance;
        filing.Account__c=acc.Id;
        filing.Citizenship__c=acc.Citizenship__c;
        filing.Business_Type__c=acc.Business_Type__c;
        filing.Status__c='Approved';
        filing.Type__c='Name Change Amendment';
        filing.Work_Order__c=workorder.Id;
        insert filing;
        Blob b = Blob.valueOf('Test Data');
        Attachment attachment = new Attachment();
        attachment.ParentId = filing.ID;
        attachment.Name = UCCFileMerge.getFilingOutputName(filing);
        attachment.Body = b;
        insert(attachment);  
        test.startTest();
        Database.executeBatch(new brs_FilingDocsDataFix('Business_Filing__c',System.today().addDays(-2),true,true));
        test.stopTest();
    }
    @isTest static void createTestData1(){
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
        Account acc=BRS_TestDataFactory.createAccountObject();
        acc.Status__c='Forfeited';
        update acc;
        Contact con = BRS_TestDataFactory.createContactObject(acc.Id);
        Work_Order__c workorder =BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Completed');
        Business_Filing__c filing=new Business_Filing__c();
        filing.RecordTypeId = RecordTypeIdMaintenance;
        filing.Account__c=acc.Id;
        filing.Citizenship__c=acc.Citizenship__c;
        filing.Business_Type__c=acc.Business_Type__c;
        filing.Status__c='Approved';
        filing.Type__c='Name Change Amendment';
        filing.Work_Order__c=workorder.Id;
        insert filing;
        Business_Filing__c bf=[Select Id, Work_Order__r.Source__c, Sdoc_Filing_Number__c, Filing_Type__c,Status__c,Work_Order__c,Type__c from BUsiness_Filing__c LIMIT 1];
        Blob b = Blob.valueOf('Test Data');
        Attachment attachment = new Attachment();
        attachment.ParentId = bf.ID;
        attachment.Name = UCCFileMerge.getFilingOutputName(bf);
        attachment.Body = b;
        insert(attachment); 
        delete [Select Id from ContentDocumentLink where LinkedEntityId=:bf.Id];
        test.startTest();
        Database.executeBatch(new brs_FilingDocsDataFix('Business_Filing__c',System.today().addDays(-2),false,false));
        test.stopTest();
    }
     @isTest static void createTestData2(){
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
        Account acc=BRS_TestDataFactory.createAccountObject();
        acc.Status__c='Forfeited';
        update acc;
        Contact con = BRS_TestDataFactory.createContactObject(acc.Id);
        Work_Order__c workorder =BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Completed');
        Business_Filing__c filing=new Business_Filing__c();
        filing.RecordTypeId = RecordTypeIdMaintenance;
        filing.Account__c=acc.Id;
        filing.Citizenship__c=acc.Citizenship__c;
        filing.Business_Type__c=acc.Business_Type__c;
        filing.Status__c='Approved';
        filing.Type__c='Name Change Amendment';
        filing.Work_Order__c=workorder.Id;
        insert filing;
        Business_Filing__c bf=[Select Id, Work_Order__r.Source__c, Sdoc_Filing_Number__c, Filing_Type__c,Status__c,Work_Order__c,Type__c from BUsiness_Filing__c LIMIT 1];
        Blob b = Blob.valueOf('Test Data');
        Attachment attachment = new Attachment();
        attachment.ParentId = bf.ID;
        attachment.Name = UCCFileMerge.getFilingOutputName(bf);
        attachment.Body = b;
        insert(attachment);  
        test.startTest();
        Database.executeBatch(new brs_FilingDocsDataFix('Business_Filing__c',System.today().addDays(-2),true,false));
        test.stopTest();
    }
     @isTest static void createTestData3(){
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
        Account acc=BRS_TestDataFactory.createAccountObject();
        acc.Status__c='Forfeited';
        update acc;
        Contact con = BRS_TestDataFactory.createContactObject(acc.Id);
        Work_Order__c workorder =BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Completed');
        Business_Filing__c filing=new Business_Filing__c();
        filing.RecordTypeId = RecordTypeIdMaintenance;
        filing.Account__c=acc.Id;
        filing.Citizenship__c=acc.Citizenship__c;
        filing.Business_Type__c=acc.Business_Type__c;
        filing.Status__c='Approved';
        filing.Type__c='Name Change Amendment';
        filing.Work_Order__c=workorder.Id;
        insert filing;
        Business_Filing__c bf=[Select Id, Work_Order__r.Source__c, Sdoc_Filing_Number__c, Filing_Type__c,Status__c,Work_Order__c,Type__c from BUsiness_Filing__c LIMIT 1];
        Blob b = Blob.valueOf('Test Data');
        Attachment attachment = new Attachment();
        attachment.ParentId = bf.ID;
        attachment.Name = UCCFileMerge.getFilingOutputName(bf);
        attachment.Body = b;
        insert(attachment);  
        test.startTest();
        Database.executeBatch(new brs_FilingDocsDataFix('Business_Filing__c',System.today().addDays(-2),false,true));
        test.stopTest();
    }
    @isTest static void createTestData4(){
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
        Account acc=BRS_TestDataFactory.createAccountObject();
        acc.Status__c='Forfeited';
        update acc;
        Contact con = BRS_TestDataFactory.createContactObject(acc.Id);
        Work_Order__c workorder =BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Completed');
        Business_Filing__c filing=new Business_Filing__c();
        filing.RecordTypeId = RecordTypeIdMaintenance;
        filing.Account__c=acc.Id;
        filing.Citizenship__c=acc.Citizenship__c;
        filing.Business_Type__c=acc.Business_Type__c;
        filing.Status__c='Approved';
        filing.Type__c='Name Change Amendment';
        filing.Work_Order__c=workorder.Id;
        insert filing;
        Business_Filing__c bf=[Select Id, Work_Order__r.Source__c, Sdoc_Filing_Number__c, Filing_Type__c,Status__c,Work_Order__c,Type__c from BUsiness_Filing__c LIMIT 1];
        Blob b = Blob.valueOf('Test Data');
        Attachment attachment = new Attachment();
        attachment.ParentId = bf.ID;
        attachment.Name = UCCFileMerge.getFilingOutputName(bf);
        attachment.Body = b;
        insert(attachment);  
        test.startTest();
        Database.executeBatch(new brs_FilingDocsDataFix('Business_Filing__c',new Set<Id>{bf.Id},false,true));
        test.stopTest();
    }
    @isTest static void createTestData5(){
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
        Account acc=BRS_TestDataFactory.createAccountObject();
        acc.Status__c='Forfeited';
        update acc;
        Contact con = BRS_TestDataFactory.createContactObject(acc.Id);
        Work_Order__c workorder =BRS_TestDataFactory.createWorkOrderObject(con.Id, 'Online', 'Completed');
        Business_Filing__c filing=new Business_Filing__c();
        filing.RecordTypeId = RecordTypeIdMaintenance;
        filing.Account__c=acc.Id;
        filing.Citizenship__c=acc.Citizenship__c;
        filing.Business_Type__c=acc.Business_Type__c;
        filing.Status__c='Approved';
        filing.Type__c='Name Change Amendment';
        filing.Work_Order__c=workorder.Id;
        insert filing;
        Business_Filing__c bf=[Select Id, Work_Order__r.Source__c, Sdoc_Filing_Number__c, Filing_Type__c,Status__c,Work_Order__c,Type__c from BUsiness_Filing__c LIMIT 1];
        Blob b = Blob.valueOf('Test Data');
        Attachment attachment = new Attachment();
        attachment.ParentId = bf.ID;
        attachment.Name = UCCFileMerge.getFilingOutputName(bf);
        attachment.Body = b;
        insert(attachment);  
        test.startTest();
        String q1= 'Select Id, Work_Order__r.Source__c, Sdoc_Filing_Number__c, Filing_Type__c,Status__c,Work_Order__c,Type__c,(SELECT Id,Name FROM Attachments),(SELECT ContentDocument.Title FROM ContentDocumentLinks) FROM Business_Filing__c WHERE LastModifiedDate >=: dateAfter AND Status__c IN (\'Approved\') AND Work_Order__r.Source__c != \'API\' AND Work_Order__c != null AND Type__c NOT IN(\'Mass Agent Change – Name\',\'Mass Agent Change – Address\',\'Administrative Dissolution\') LIMIT 1';
        Database.executeBatch(new brs_FilingDocsDataFix('Business_Filing__c',q1,false,true));
        test.stopTest();
    }
}