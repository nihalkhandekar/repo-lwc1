@isTest
private class BOS_TopicController_Test {
	@isTest
    private static void searchByTopicName_Test(){
        Test.startTest();
        String result = BOS_TopicController.searchByTopicName('abc');
        Test.stopTest();
        
    }
    @IsTest(SeeAllData=true)
    private static void getAllTopics_Test(){
        Test.startTest();
    String cid=    [Select Id from Network where Name = 'business'].Id;
         ConnectApi.KnowledgeArticleVersionCollection testPage = new ConnectApi.KnowledgeArticleVersionCollection();
        List<ConnectApi.KnowledgeArticleVersion> testItemList = new List<ConnectApi.KnowledgeArticleVersion>();
        testItemList.add(new ConnectApi.KnowledgeArticleVersion());
        testItemList.add(new ConnectApi.KnowledgeArticleVersion());
        
        testPage.items = testItemList;
 
        // Set the test data
        ConnectApi.Knowledge.setTestGetTrendingArticles(cid, 25, testPage);
        
         BOS_TopicController.getAllTopics('en_US');
        BOS_TopicController.getFeaturedTopics();
        BOS_TopicController.getPopularTopics();
        Test.stopTest();
        
    }
}