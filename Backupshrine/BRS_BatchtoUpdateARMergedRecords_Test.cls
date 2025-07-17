@isTest public with sharing class BRS_BatchtoUpdateARMergedRecords_Test {
    @isTest static void testAdminDissolutionAttachBatch(){
        Set<id> filingids=new Set<id>();
        RecordType rt = [
            SELECT Id 
            FROM RecordType 
            WHERE DeveloperName = 'Annual_Report_First_Report'
        ];
        Account acc=BRS_TestDataFactory.createAccountObject();
        acc.Status__c='Active';
        update acc;
        Business_Filing__c bf=new Business_Filing__c(
            RecordTypeId = rt.id,
            Account__c = acc.Id,
            Status__c = 'Approved',
            Type__c = 'Annual Report'
        );
        insert bf;
        filingids.add(bf.id);
        Blob b = Blob.valueOf('Test Data');
		Attachment attachment = new Attachment();
		attachment.ParentId = bf.ID;
		attachment.Name = bf.Sdoc_Filing_Number__c +' - Acceptance Notice';
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
        test.startTest();
        Database.executeBatch(new BRS_BatchtoUpdateARMergedRecords(filingids));
        test.stopTest();
    }
}