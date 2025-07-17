@isTest
public with sharing class CTBOT_SitecoreArticleSearchById_TEST {

    @isTest
    static void testOtherOptions() {
        List<CTBOT_SitecoreArticleSearchById.Input> testInputList = generateTestInputs();

        CTBOT_SitecoreAPIService_MOCK mockInstance = new CTBOT_SitecoreAPIService_MOCK();
        Test.setMock(HttpCalloutMock.class, mockInstance);
        Test.startTest();
        List<CTBOT_SitecoreArticleSearchById.Output> testOutputsOtherOptions = CTBOT_SitecoreArticleSearchById.searchById(testInputList);
        Test.stopTest();

        System.assertEquals(4, testOutputsOtherOptions[0].buttons.size());
        System.assertEquals('Test Article Title', testOutputsOtherOptions[0].sitecoreItem.chatbotTitle);
        System.assert(testOutputsOtherOptions[0].sitecoreItem.chatbotContent.contains('Test chatbot content'));
        System.assert(testOutputsOtherOptions[0].articleTitlesToCompare.equals('Test Related Article Title 1,,Test Related Article Title 2'));
        System.assertEquals(true, testOutputsOtherOptions[0].relatedArticlesFound);
        System.assertEquals(2, testOutputsOtherOptions[0].mainMenuDisplayFrequency);
    }

    @isTest
    static void testFinalOptions() {
        List<CTBOT_SitecoreArticleSearchById.Input> testInputList = generateTestInputs();

        CTBOT_SitecoreAPIService_MOCK mockInstance = new CTBOT_SitecoreAPIService_MOCK();
        mockInstance.returnRelatedItems = false;
        Test.setMock(HttpCalloutMock.class, mockInstance);
        Test.startTest();
        List<CTBOT_SitecoreArticleSearchById.Output> testOutputsFinalOptions = CTBOT_SitecoreArticleSearchById.searchById(testInputList);
        Test.stopTest();

        System.assertEquals(3, testOutputsFinalOptions[0].buttons.size());
        System.assertEquals(null, testOutputsFinalOptions[0].articleTitlesToCompare);
        System.assertEquals(false, testOutputsFinalOptions[0].relatedArticlesFound);
    }

    private static List<CTBOT_SitecoreArticleSearchById.Input> generateTestInputs() {
        CTBOT_SitecoreArticleSearchById.Input testInput = new CTBOT_SitecoreArticleSearchById.Input();
        List<CTBOT_SitecoreArticleSearchById.Input> testInputList = new List<CTBOT_SitecoreArticleSearchById.Input>();
        CTBOT_SitecoreAPIService.isTest = true;

        testInput.articleId = 'EEB72F59-8689-4AF7-A0FA-3C7ED7F6FE5D';
        testInput.displayCount = 2;
        testInput.otherOptions = 'Other Option 1,, Other Option 2';
        testInput.finalOptions = 'Final Option 1,, Final Option 2,, Final Option 3';
        testInput.displayFrequency = 2;
        testInputList.add(testInput);

        return testInputList;
    }
}