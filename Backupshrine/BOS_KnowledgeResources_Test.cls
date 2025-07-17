@isTest
public class BOS_KnowledgeResources_Test {
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
    
    @isTest
    public static void testbusinessDataCategoryStructure(){
        testData();
        
        Test.startTest();
        try{
            Knowledge__kav kwPub = [Select id,knowledgeArticleId from Knowledge__kav where id=:kw.id];
            KbManagement.PublishingService.publishArticle((kwPub.KnowledgeArticleId), true);
            List<String>cat = new List<String>{'Starting_my_business'};
                Topic tp = [Select id from Topic Limit 1];
            
            BOS_KnowledgeResources.businessDataCategoryStructure();
            BOS_KnowledgeResources.getKnowledgeByTopicANDCategory(tp.id,cat,'en_US');
            BOS_KnowledgeResources.getKnowledgeByTopicANDCategory(tp.id,null,'en_US');
        }catch(Exception e){}
        Test.stopTest();
    }
    
    @isTest
    public static void testgetFeaturedPopularArticleRecords(){ 
        Test.startTest();
        testData();
        
        Organization org = [Select Id from Organization];
        Resource_Center_Admin_Selected__c rc = new Resource_Center_Admin_Selected__c();
        rc.Show_Admin_Selected_Resources__c = true;
        rc.Show_Featured_Topics__c = true;
        rc.SetupOwnerId = org.id;
        insert rc;
        
        Id p = [select id from profile where name='System Administrator'].id;
        User user = QnA_TestDataFactory.createAdminUser(p);
              
        system.runAs(user){
        Knowledge__kav kwPub = [Select id,knowledgeArticleId from Knowledge__kav where id=:kw.id];
        KbManagement.PublishingService.publishArticle((kwPub.KnowledgeArticleId), true);
        Knowledge__kav kw2Pub = [Select id,knowledgeArticleId from Knowledge__kav where id=:kw2.id];
        KbManagement.PublishingService.publishArticle((kw2Pub.KnowledgeArticleId), true);
        
        
        
        try{
            BOS_KnowledgeResources.setViewStatKnowledgeRecords(kwPub.knowledgeArticleId);
            BOS_KnowledgeResources.getFeaturedPopularArticleRecords('en_US');
            BOS_KnowledgeResources.getMediaArticleRecords('en_US');
            BOS_KnowledgeResources.getFeaturedPopularTopicRecords('en_US');
        }catch(Exception e){}
        }
        Test.stopTest();
    }
    
    @IsTest(SeeAllData=true)
    public static void getAllTopics_Test(){
        Test.startTest();
        testData();
        List<Resource_Center_Admin_Selected__c> rcList = new List<Resource_Center_Admin_Selected__c>();
        rcList = [Select id,Show_Admin_Selected_Resources__c from Resource_Center_Admin_Selected__c limit 1];
        if(rcList != null && !rcList.isEmpty()){
            rcList[0].Show_Admin_Selected_Resources__c = false;
            rcList[0].Show_Featured_Topics__c = true;
            update rcList ;
        }
        else{
        Organization org = [Select Id from Organization];
        Resource_Center_Admin_Selected__c rc = new Resource_Center_Admin_Selected__c();
        rc.Show_Admin_Selected_Resources__c = false;
        rc.Show_Featured_Topics__c = true;
        rc.SetupOwnerId = org.id;
        insert rc;
        }
        
        Id p = [select id from profile where name='System Administrator'].id;
        User user = QnA_TestDataFactory.createAdminUser(p);
              
        system.runAs(user){
        Knowledge__kav kwPub = [Select id,knowledgeArticleId from Knowledge__kav where id=:kw.id];
        KbManagement.PublishingService.publishArticle((kwPub.KnowledgeArticleId), true);
        Knowledge__kav kw2Pub = [Select id,knowledgeArticleId from Knowledge__kav where id=:kw2.id];
        KbManagement.PublishingService.publishArticle((kw2Pub.KnowledgeArticleId), true);
            
        ID TopicID;
        List<String> categoryList = new List<String>();
        String language;
        

        try{
            String cid = [Select Id from Network where Name = 'business'].Id;
            ConnectApi.KnowledgeArticleVersionCollection testPage = new ConnectApi.KnowledgeArticleVersionCollection();
            List<ConnectApi.KnowledgeArticleVersion> testItemList = new List<ConnectApi.KnowledgeArticleVersion>();
            ConnectApi.KnowledgeArticleVersion conAPIV = new ConnectApi.KnowledgeArticleVersion();
            conAPIV.id=kwPub.id;
            conAPIV.knowledgeArticleId=kwPub.knowledgeArticleId;
            ConnectApi.KnowledgeArticleVersion conAPIV2 = new ConnectApi.KnowledgeArticleVersion();
            conAPIV2.id=kw2Pub.id;
            conAPIV2.knowledgeArticleId=kw2Pub.knowledgeArticleId;
            testItemList.add(conAPIV);
            testItemList.add(conAPIV2);
            testPage.items = testItemList;
            
            // Set the test data
            ConnectApi.Knowledge.setTestGetTrendingArticles(cid, 10, testPage);
            
            BOS_KnowledgeResources.getFeaturedPopularArticleRecords('en_US');
            BOS_KnowledgeResources.getMediaArticleRecords('en_US');
            BOS_KnowledgeResources.getFeaturedPopularTopicRecords('en_US');
            BOS_KnowledgeResources.businessDataCategoryStructure();
            BOS_KnowledgeResources.getKnowledgeByTopicANDCategory(TopicID,categoryList,language);
        }catch(Exception e){}
            
        }
        Test.stopTest();
        
    }
    
    
}