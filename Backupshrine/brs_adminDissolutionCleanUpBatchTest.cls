@isTest
public class brs_adminDissolutionCleanUpBatchTest {
    @isTest static void testAdminDissolutionAttachBatch(){
        test.startTest();
        Id RecordTypeIdMaintenance = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('New Business').getRecordTypeId();
        System.debug('RecordTypeIdMaintenance@@@'+RecordTypeIdMaintenance);
        Account acc=BRS_TestDataFactory.createAccountObject();
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Contact123';
        con.Email = 'testConBrs@test.com';
        con.Allow_negative_balances__c = true;
        con.AccountId = acc.id;
        insert con;
        Work_Order__c workOrder = new Work_Order__c();
        workOrder.Source__c = 'Online';
        workOrder.Received_Date__c = System.Now().AddDays(-35);
        workOrder.Completed_Date__c = System.Today();
        workOrder.Status__c = 'Open';
        workOrder.Total_Hold_Amount__c=3010;
        workOrder.Payments_Verified__c=true;
        workOrder.Customer__c=con.id;
        insert workOrder;
        
        acc.Status__c='Active';
        update acc;
        Business_Filing__c bf=new Business_Filing__c();
            bf.RecordTypeId = RecordTypeIdMaintenance;
            bf.Account__c = acc.Id;
            bf.Status__c = 'Approved';
            bf.Work_Order__c=workOrder.id;
        	bf.Source__c='Online';
            bf.Type__c = 'Business Formation';
            bf.Filing_Type__c = 'Certificate of Organization';
            bf.Filing_Date__c = Date.valueOf('2022-07-05');
        insert bf;
        System.debug('bf@@@@'+bf);
        Blob b = Blob.valueOf('Test Data');
        Attachment attachment = new Attachment();
        attachment.ParentId = bf.ID;
        attachment.Name = 'Test Attachment for Parent';
        attachment.Body = b;
        insert(attachment);
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body to be insert in test class for testing the'); 
        
        ContentVersion contentVersion_1 = new ContentVersion(
            Title='SampleTitle', 
            PathOnClient ='SampleTitle.jpg',
            VersionData = bodyBlob, 
            origin = 'H'
        );
        insert contentVersion_1;
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId 
                                           FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = bf.ID;
        contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
        contentlink.ShareType = 'V';
        insert contentlink;
        //List<Business_Filing__c> buslist=new List<Business_Filing__c>();
       // buslist.add(bf);
        List<Business_Filing__c> buslist =[Select id,name,work_Order__c,Work_order__r.Received_Date__c,Filing_Time__c,Filing_Date__c,Business_Type__c,(SELECT parentId,OldValue, NewValue,CreatedDate FROM Histories)  from Business_Filing__c where TYPE__c IN ('Business Formation','Business Registration') and Work_Order__r.Received_Date__c >=2023-10-25T19:00:00.362+05:30 and Source__c='Online' and Status__c='Approved'];
        brs_adminDissolutionAttachUpdateBatch da=new brs_adminDissolutionAttachUpdateBatch();
        Database.executeBatch(da);
        String sch ='0 48 * * * ?'; 
        System.schedule('ScheduleTest', sch,da);
        //da.execute(null,buslist);
        test.stopTest();
    }
}