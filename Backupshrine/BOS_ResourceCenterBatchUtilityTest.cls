@isTest
public class BOS_ResourceCenterBatchUtilityTest{

    public static Knowledge__kav kw;
    public static Knowledge__kav kw2;
    public static void testData(){
        Id BOSKnowledgeRecordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName().get('BOS Resource Content').getRecordTypeId();
        kw = new Knowledge__kav();
        kw.title = 'Test';
        kw.UrlName = 'test';
        kw.Language='en_US';
        kw.Selected_Featured_Resource__c=true;
        kw.Resource_Type__c='Resource';
        kw.RecordTypeID=BOSKnowledgeRecordTypeId;
        insert kw;
        
        kw2 = new Knowledge__kav();
        kw2.title = 'Test2';
        kw2.UrlName = 'test2';
        kw2.Language='en_US';
        kw2.Selected_Featured_Resource__c=true;
        kw2.Resource_Type__c='Media';
        kw2.RecordTypeID=BOSKnowledgeRecordTypeId;
        insert kw2;
        
        Topic t = new Topic();
        String networkID = [Select Id from Network where Name = 'business'].Id;
        t.Name ='service members';
        t.NetworkId = networkID;
        insert t;
        
        TopicAssignment tA = new TopicAssignment();
        tA.EntityId = kw.id;
        tA.NetworkId = networkID;
        tA.TopicId = t.id;
        insert tA;
        Knowledge__DataCategorySelection kdc = new Knowledge__DataCategorySelection();
        kdc.DataCategoryGroupName = 'Business';
        kdc.DataCategoryName = 'Starting_my_business';
        kdc.ParentId = kw.id;
        insert kdc;
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Res2';
        cv.Description = 'Res2';
        cv.VersionData = Blob.valueOf('Unit Test ContentVersion Body');
        cv.PathOnClient = 'Res 2.jpg';
        cv.FirstPublishLocationId  = kw.id;
        insert cv;
        
        ContentDistribution cvd = new ContentDistribution( 
            Name = 'test', 
            ContentVersionId = cv.id, 
            PreferencesAllowOriginalDownload = true, 
            PreferencesAllowViewInBrowser = true, 
            PreferencesNotifyOnVisit = false 
        );
        //insert cvd;
    }
    
    public static testmethod void testArticleUpdateWithBatch(){
        testData();
        Knowledge__kav kw_1 = [Select id,knowledgeArticleId from Knowledge__kav where id=:kw.id];
        Knowledge__kav kw_2 = [Select id,knowledgeArticleId from Knowledge__kav where id=:kw2.id];
        
        test.StartTest();
        
        Database.QueryLocator QL;
        Database.BatchableContext BC;
        List<Knowledge__kav> KavList = new List<Knowledge__kav>();
        KavList.add(kw_1);
        KavList.add(kw_2);
        BOS_ResourceCenterBatchUtility batchInstance = new BOS_ResourceCenterBatchUtility('PublishArticles');
        QL = batchInstance.start(bc);
        batchInstance.execute(BC, KavList);
        batchInstance.finish(BC); 
    test.StopTest();
    
    }
    
    public static testmethod void testArticleUpdateWithBatch2(){
        testData();
        test.StartTest();
        Id p = [select id from profile where name='System Administrator'].id;
        User user = QnA_TestDataFactory.createAdminUser(p);
              
        system.runAs(user){
        Knowledge__kav kwPub = [Select id,knowledgeArticleId from Knowledge__kav where id=:kw.id];
        KbManagement.PublishingService.publishArticle((kwPub.KnowledgeArticleId), true);
        Knowledge__kav kw2Pub = [Select id,knowledgeArticleId from Knowledge__kav where id=:kw2.id];
        KbManagement.PublishingService.publishArticle((kw2Pub.KnowledgeArticleId), true);
        
        Database.QueryLocator QL;
        Database.BatchableContext BC;
        List<Knowledge__kav> KavList = new List<Knowledge__kav>();
        KavList.add(kwPub);
        KavList.add(kw2Pub);
        BOS_ResourceCenterBatchUtility batchInstance = new BOS_ResourceCenterBatchUtility('CreateTranslatedVersions');
        QL = batchInstance.start(bc);
        batchInstance.execute(BC, KavList);
        batchInstance.finish(BC);
        }
    test.StopTest();
    
    }
    
    public static testmethod void testArticleUpdateWithBatch3(){
        testData();
        test.StartTest();
        Id p = [select id from profile where name='System Administrator'].id;
        User user = QnA_TestDataFactory.createAdminUser(p);
              
        system.runAs(user){
        Knowledge__kav kwPub = [Select id,knowledgeArticleId from Knowledge__kav where id=:kw.id];
        KbManagement.PublishingService.publishArticle((kwPub.KnowledgeArticleId), true);
        Knowledge__kav kw2Pub = [Select id,knowledgeArticleId from Knowledge__kav where id=:kw2.id];
        KbManagement.PublishingService.publishArticle((kw2Pub.KnowledgeArticleId), true);
        
        String language = 'es';
        String assigneeId = userInfo.getUserId();
        Datetime dueDate = System.now();
        String idSp = KbManagement.PublishingService.submitForTranslation(kw2Pub.KnowledgeArticleId, language, assigneeId, dueDate);
            
        Knowledge__kav kw2PubSp = [Select id,knowledgeArticleId from Knowledge__kav where id=:idSp];
        
        Database.QueryLocator QL;
        Database.BatchableContext BC;
        List<Knowledge__kav> KavList = new List<Knowledge__kav>();
        KavList.add(kw2PubSp);
        BOS_ResourceCenterBatchUtility batchInstance = new BOS_ResourceCenterBatchUtility('CompleteTranslations');
        QL = batchInstance.start(bc);
        batchInstance.execute(BC, KavList);
        batchInstance.finish(BC); 
        }
    test.StopTest();
    
    }
}