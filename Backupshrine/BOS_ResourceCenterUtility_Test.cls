@isTest
public with sharing class BOS_ResourceCenterUtility_Test {
    //Test class BOS_ResourceCenterUtility_Test and BOS_TopicController_Test cover BOS_ResourceCenterUtility
    @testSetup
    public static void setup() {
        Map<Account, List<Contact>> AccountsVsContacts = QnA_TestDataFactory.createAccountWithContacts();
        Contact con = AccountsVsContacts.values().get(0).get(0);
        Id p = [SELECT id FROM profile WHERE name = 'CT Community User'].id;
        User user = QnA_TestDataFactory.createCommunityUser(con, p);
        Collection__c col1 = new Collection__c(
            Name = 'Test1',
            Contact__c = con.id
        );
        Collection__c col2 = new Collection__c(
            Name = 'Test3',
            Contact__c = con.id
        );
        Collection__c col3 = new Collection__c(
            Name = 'Test2',
            Contact__c = con.id
        );
        List<Collection__c> collection = new List<Collection__c>();
        collection.add(col1);
        collection.add(col2);
        collection.add(col3);
        insert collection;
        
        Id BOSKnowledgeRecordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName()
            .get('BOS Resource Content')
            .getRecordTypeId();

        Knowledge__kav kw0 = new Knowledge__kav();
        kw0.title = 'Test';
        kw0.UrlName = 'test';
        kw0.Language = 'en_US';
        kw0.Selected_Featured_Resource__c = true;
        kw0.Resource_Type__c = 'Resource';
        kw0.RecordTypeID = BOSKnowledgeRecordTypeId;
        insert kw0;

        Knowledge__kav kw1 = new Knowledge__kav();
        kw1.title = 'Test1';
        kw1.UrlName = 'test1';
        kw1.Language='es';
        kw1.Selected_Featured_Resource__c=false;
        kw1.Resource_Type__c='Resource';
        kw1.RecordTypeID=BOSKnowledgeRecordTypeId;
        insert kw1;

        Knowledge__kav kw2 = new Knowledge__kav();
        kw2.title = 'Test2';
        kw2.UrlName = 'test2';
        kw2.Language = 'en_US';
        kw2.Selected_Featured_Resource__c = true;
        kw2.Resource_Type__c = 'Media';
        kw2.RecordTypeID = BOSKnowledgeRecordTypeId;
        insert kw2;

        ContentVersion content = new ContentVersion();
        content.Title = 'Header_Picture1';
        content.PathOnClient = '/' + content.Title + '.jpg';
        Blob bodyBlob = Blob.valueOf('Unit Test ContentVersion Body');
        content.VersionData = bodyBlob;
        // uncomment FirstPublishLocationId
        //content.FirstPublishLocationId =kw2.id;
        content.origin = 'H';
        insert content;

        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = kw2.id;
        contentlink.contentdocumentid = [
            SELECT contentdocumentid
            FROM contentversion
            WHERE id = :content.id
        ]
        .contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers';
        insert contentlink;

        Topic t = new Topic();
        String networkID = [SELECT Id FROM Network WHERE Name = 'business'].Id;
        t.Name = 'service members';
        t.NetworkId = networkID;
        insert t;

        TopicAssignment tA0 = new TopicAssignment();
        tA0.EntityId = kw0.id;
        tA0.NetworkId = networkID;
        tA0.TopicId = t.id;
        insert tA0;

        TopicAssignment tA1 = new TopicAssignment();
        tA1.EntityId = kw1.id;
        tA1.NetworkId = networkID;
        tA1.TopicId = t.id;
        insert tA1;

        TopicAssignment tA2 = new TopicAssignment();
        tA2.EntityId = kw2.id;
        tA2.NetworkId = networkID;
        tA2.TopicId = t.id;
        insert tA2;

        Topic_Image__c tImg = new Topic_Image__c();
        tImg.Name = t.id;
        tImg.Topic_Name__c = 'Running my business';
        tImg.Topic_Image_Source__c = '/business/sfsites/c/file-asset/Running_my_business?v=1';
        insert tImg;

        Knowledge__DataCategorySelection kdc0 = new Knowledge__DataCategorySelection();
        kdc0.DataCategoryGroupName = 'Business';
        kdc0.DataCategoryName = 'Starting_my_business';
        kdc0.ParentId = kw0.id;
        insert kdc0;

        Knowledge__DataCategorySelection kdc1 = new Knowledge__DataCategorySelection();
        kdc1.DataCategoryGroupName = 'Business';
        kdc1.DataCategoryName = 'Starting_my_business';
        kdc1.ParentId = kw1.id;
        insert kdc1;

        Knowledge__DataCategorySelection kdc2 = new Knowledge__DataCategorySelection();
        kdc2.DataCategoryGroupName = 'Business';
        kdc2.DataCategoryName = 'Starting_my_business';
        kdc2.ParentId = kw2.id;
        insert kdc2;

        ContentVersion cv = new ContentVersion();
        cv.Title = 'Res2';
        cv.Description = 'Res2';
        cv.VersionData = Blob.valueOf('Unit Test ContentVersion Body');
        cv.PathOnClient = 'Res 2.jpg';
        cv.FirstPublishLocationId = kw0.id;
        insert cv;

        /*
        ContentDistribution cvd = new ContentDistribution(
            Name = 'test',
            ContentVersionId = cv.id,
            PreferencesAllowOriginalDownload = true,
            PreferencesAllowViewInBrowser = true,
            PreferencesNotifyOnVisit = false
        );
        // uncomment insert cvd
        insert cvd;
        */
    }
    @isTest
    private static void testCollection() {
        User u = [SELECT Id FROM user LIMIT 1];
        System.runAs(u) {
            Test.startTest();
            BOS_ResourceCenterUtility.getAllCollections();
            BOS_ResourceCenterUtility.getCommunityId();
            Test.stopTest();
        }
    }

    @isTest
    public static void testmethod1() {
        Test.startTest();
        Collection__c coln = [SELECT ID, Name FROM Collection__c LIMIT 1];
        Knowledge__kav kwPub = [
            SELECT
                id,
                knowledgeArticleId,
                MasterVersionId,
                Title,
                Summary,
                Resource_Type__c,
                Resource_Title_URL__c
            FROM Knowledge__kav
            WHERE title = 'Test'
        ]; //id=:kw0.id];
        ContentVersion content = new ContentVersion();
        content.Title = 'Header_Picture1';
        content.PathOnClient = '/' + content.Title + '.jpg';
        Blob bodyBlob = Blob.valueOf('Unit Test ContentVersion Body');
        content.VersionData = bodyBlob;
        content.origin = 'H';
        insert content;

        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = kwPub.id;
        contentlink.contentdocumentid = [
            SELECT contentdocumentid
            FROM contentversion
            WHERE id = :content.id
        ]
        .contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers';
        insert contentlink;

        Id p = [SELECT id FROM profile WHERE name = 'System Administrator'].id;
        User user = QnA_TestDataFactory.createAdminUser(p);

        System.runAs(user) {
            KbManagement.PublishingService.publishArticle(
                (kwPub.KnowledgeArticleId),
                true
            );
            Knowledge__kav kw2Pub = [
                SELECT
                    id,
                    knowledgeArticleId,
                    MasterVersionId,
                    Title,
                    Summary,
                    Resource_Type__c,
                    Resource_Title_URL__c
                FROM Knowledge__kav
                WHERE title = 'test2'
            ]; //id=:kw2.id];
            KbManagement.PublishingService.publishArticle(
                (kw2Pub.KnowledgeArticleId),
                true
            );
            List<Knowledge__kav> KavList = new List<Knowledge__kav>();
            KavList.add(kwPub);
            KavList.add(kw2Pub);
            BOS_ResourceCenterUtility.CollectionWrapper rcWrap = new BOS_ResourceCenterUtility.CollectionWrapper(
                coln
            );
            BOS_ResourceCenterUtility.LandingPageWrapper landingWrap = new BOS_ResourceCenterUtility.LandingPageWrapper();
            BOS_ResourceCenterUtility.OptionWrapper opWrap = new BOS_ResourceCenterUtility.OptionWrapper(
                'test',
                'test'
            );
            BOS_ResourceCenterUtility.SavedCollectionWrapper svColnWrap = new BOS_ResourceCenterUtility.SavedCollectionWrapper(
                true,
                coln
            );
            // uncomment try catch
            try{
            List<String> strList = new List<String>();
            strList.add('Starting_my_business');
            String str = JSON.serialize(strList);
            BOS_ResourceCenterUtility.getResourceMap(KavList, str);

            Topic tp = [SELECT id FROM Topic LIMIT 1];
            BOS_KnowledgeResources.businessDataCategoryStructure();
            BOS_KnowledgeResources.getKnowledgeByTopicANDCategory(
                tp.id,
                strList,
                'en_US'
            );
            BOS_KnowledgeResources.getKnowledgeByTopicANDCategory(
                tp.id,
                strList,
                'es'
            );
            } catch(Exception e){}
        }
        Test.stopTest();
    }
}