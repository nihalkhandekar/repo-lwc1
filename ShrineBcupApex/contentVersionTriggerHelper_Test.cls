@isTest
public class contentVersionTriggerHelper_Test {
    testmethod static void test1() {
        ContentVersion objContVer = new ContentVersion();
        objContVer.VersionData = Blob.valueOf('string');
        objContVer.Title = 'title'; 
        objContVer.PathOnClient='title.pdf';
        objContVer.File_Type_fileupload__c = 'pdf';   
        insert objContVer;
        
        Map<Id,ContentVersion> ContentVersions = new Map<Id,ContentVersion>();
        ContentVersions.put(objContVer.Id,objContVer);
        
        test.startTest();
        contentVersionTriggerHelper.createContentDistribution(objContVer);
        test.stopTest();
    }
    
    testmethod static void ContentVersionTriggerHandler() {
        ContentVersion conv = BRS_TestDataFactory.contentVersionData();
        List<ContentVersion> newItems = new List<ContentVersion>();
        newItems.add(conv);
        Map<Id, SObject> newItems1 = new Map<Id, SObject>();
        newItems1.put(conv.Id,conv);
        test.startTest();
        ContentVersionTriggerHandler ch = new ContentVersionTriggerHandler();
        ch.afterDelete(newItems1);
        ch.afterUndelete(newItems, newItems1);
        ch.afterUpdate(newItems1, newItems1);
        ch.beforeDelete(newItems, newItems1);
        ch.beforeInsert(newItems);
        ch.beforeUpdate(newItems1, newItems1);
        test.stopTest();
    }
}