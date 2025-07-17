@isTest
public without sharing class CTBOT_GetMenuButtonsTest {

    private static String HANDLED_EXCEPTION_SUBSTRNG = 'There was a problem retrieving data from Sitecore';

    @isTest
    public static void getResponseTest(){

        List<CTBOT_SitecoreConfusedSearch.output> request = new List<CTBOT_SitecoreConfusedSearch.Output>();
        List<CTBOT_GetMenuButtonsForRelatedArticles.Response> response = new List<CTBOT_GetMenuButtonsForRelatedArticles.Response>();
        CTBOT_SitecoreAPIService.SitecoreItem sitecoreItem = new CTBOT_SitecoreAPIService.SitecoreItem();
        CTBOT_SitecoreConfusedSearch.Output newRequest = new CTBOT_SitecoreConfusedSearch.Output();

        sitecoreItem.chatbotOnly = true;
        sitecoreItem.chatbotTitle = 'chatbotTitle';
        sitecoreItem.keywords = 'keywords';
        sitecoreItem.id = 'an id';
        sitecoreItem.chatbotContent = 'chatbotContent';
        sitecoreItem.relatedItems = new List<CTBOT_SitecoreAPIService.RelatedItem>();
        
        
        newRequest.sitecoreItems = new List<CTBOT_SitecoreAPIService.SitecoreItem>();

        CTBOT_GetMenuButtonsForRelatedArticles.Response responseLineArticlesRelatedArticles;
        CTBOT_GetMenuButtonsForRelatedArticles.Response responseLineArticles;
        CTBOT_GetMenuButtonsForRelatedArticles.Response responseLine;
        CTBOT_GetMenuButtonsForRelatedArticles.Response responseLineArticlesRelatedArticlesKeyword;
        CTBOT_GetMenuButtonsForRelatedArticles.Response responseLineArticleskeyWord;
        CTBOT_GetMenuButtonsForRelatedArticles.Response responseLineKeyword;


        Test.startTest();
        
        newRequest.sitecoreItems.add(sitecoreItem);
        request.add(newRequest);
        responseLineArticles = CTBOT_GetMenuButtonsForRelatedArticles.getResponse(request, null)[0];
        responseLineArticleskeyWord = CTBOT_GetMenuButtonsForRelatedArticles.getResponse(request, 'a keyword')[0];

        CTBOT_SitecoreAPIService.RelatedItem newRelatedItem = new CTBOT_SitecoreAPIService.RelatedItem();
        newRelatedItem.chatbotTitle = 'relatedTitle';
        newRelatedItem.id = 'relatedId';
        sitecoreItem.relatedItems = new List<CTBOT_SitecoreAPIService.RelatedItem>();
        sitecoreItem.relatedItems.add(newRelatedItem);
        responseLineArticlesRelatedArticles = CTBOT_GetMenuButtonsForRelatedArticles.getResponse(request, null)[0];
        responseLineArticlesRelatedArticlesKeyword = CTBOT_GetMenuButtonsForRelatedArticles.getResponse(request, 'a keyword')[0];

        Test.stopTest();

        //Test expectations when there are articles but no related articles and no keyword is sent
        System.assertEquals('chatbotTitle', responseLineArticles.articleTitle, 'The chatbot title returned was missing or incorrect');
        System.assertEquals('chatbotContent', responseLineArticles.articleContent, 'The chatbot message was missing or incorrect');
        System.assertEquals(0, responseLineArticles.relatedArticles.size(), 'Expected zero options to be returned but got ' + responseLineArticles.relatedArticles.size());

        //Test expectations when there are articles but no related articles and a keyword was sent
        System.assertEquals(1, responseLineArticleskeyWord.articles.size(), 'Expecte one article to come back but got ' + responseLineArticleskeyWord.articles.size());
        System.assertEquals(null, responseLineArticleskeyWord.articleTitle, 'The chatbot title returned was missing or incorrect');
        System.assertEquals(null, responseLineArticleskeyWord.articleContent, 'The chatbot message was missing or incorrect');
        System.assertEquals(1, responseLineArticleskeyWord.relatedArticles.size(), 'Expected only 1 options to be returned but got ' + responseLineArticleskeyWord.relatedArticles.size());

        //Test expectations when there are articles and related articles and no keyword was sent
        System.assertEquals('chatbotTitle', responseLineArticlesRelatedArticles.articleTitle, 'The chatbot title returned was missing or incorrect');
        System.assertEquals('chatbotContent', responseLineArticlesRelatedArticles.articleContent, 'The chatbot message was missing or incorrect');
        System.assertEquals(1, responseLineArticlesRelatedArticles.relatedArticles.size(), 'Expected only 1 options to be returned but got ' + responseLineArticlesRelatedArticles.relatedArticles.size());

        //Test expectattions when tehre are articles and related articles and a keyword was sent.
        System.assertEquals(1, responseLineArticlesRelatedArticlesKeyword.articles.size(), 'Expecte two articles to come back but only got ' + responseLineArticlesRelatedArticlesKeyword.articles.size());
        System.assertEquals(false, responseLineArticlesRelatedArticlesKeyword.noArticlesFound, 'Expected no articles found to be set to false, but it was true');
        System.assertEquals(null, responseLineArticlesRelatedArticlesKeyword.articleTitle, 'The chatbot title returned was missing or incorrect');
        System.assertEquals(null, responseLineArticlesRelatedArticlesKeyword.articleContent, 'The chatbot message was missing or incorrect');
        System.assertEquals(1, responseLineArticlesRelatedArticlesKeyword.relatedArticles.size(), 'Expected only 1 options to be returned but got ' + responseLineArticlesRelatedArticlesKeyword.relatedArticles.size());
    }

    @isTest
    public static void getMenuOptionsTest(){
        List<CTBOT_GetMenuButtonsForRelatedArticles.Request> requestList = new List<CTBOT_GetMenuButtonsForRelatedArticles.Request>();
        CTBOT_GetMenuButtonsForRelatedArticles.Request newRequest = new CTBOT_GetMenuButtonsForRelatedArticles.Request();

        CTBOT_GetMenuButtonsForRelatedArticles.Response exceptionResponse;
        CTBOT_GetMenuButtonsForRelatedArticles.Response noArticlesFoundResponse;
        CTBOT_GetMenuButtonsForRelatedArticles.Response noresultResponse;
        CTBOT_GetMenuButtonsForRelatedArticles.Response resultResponse;

        LiveChatVisitor visitor = new LiveChatVisitor();
        insert visitor;

        LiveChatTranscript transcript = new LiveChatTranscript();
        transcript.LiveChatVisitorId = visitor.Id;
        insert transcript;

        
        newRequest.utterance = null;
        newRequest.agency = null;
        newRequest.numberOfResults = 1;
        newRequest.routableId = transcript.Id;

        requestList.add(newRequest);

        Test.startTest();

        noArticlesFoundResponse = CTBOT_GetMenuButtonsForRelatedArticles.getMenuOptions(requestList)[0];

        Test.stopTest();

        System.assertEquals(true, noArticlesFoundResponse.noArticlesFound, 'Expected the noArticlesFound flag to be set, but it was not');
    }
}