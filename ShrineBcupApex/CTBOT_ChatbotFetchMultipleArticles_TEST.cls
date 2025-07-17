@isTest
private class CTBOT_ChatbotFetchMultipleArticles_TEST {
    static testmethod void fetchArticlesForChatbot(){
        List<Knowledge__kav> setupTestArticle = CTBOT_TestDataFactory.createArticles(5);

        List<CTBOT_ChatbotFetchMultipleArticles.ResponsesOutput> outputList = new List<CTBOT_ChatbotFetchMultipleArticles.ResponsesOutput>();
        List<CTBOT_ChatbotFetchMultipleArticles.ResponsesInput> inputList = new List<CTBOT_ChatbotFetchMultipleArticles.ResponsesInput>();

        CTBOT_ChatbotFetchMultipleArticles.ResponsesInput input = new CTBOT_ChatbotFetchMultipleArticles.ResponsesInput();
        input.lastCustomerInput = 'Apex Test';
        inputList.add(input);

        Test.startTest();
            outputList = CTBOT_ChatbotFetchMultipleArticles.getMultipleArticles(inputList);
        Test.stopTest();

        system.assert(outputList[0].theArticles.size() == 3);
        
    }

    static testmethod void testSingleCharacterSearchException(){
        List<Knowledge__kav> setupTestArticle = CTBOT_TestDataFactory.createArticles(5);

        List<CTBOT_ChatbotFetchMultipleArticles.ResponsesOutput> outputList = new List<CTBOT_ChatbotFetchMultipleArticles.ResponsesOutput>();
        List<CTBOT_ChatbotFetchMultipleArticles.ResponsesInput> inputList = new List<CTBOT_ChatbotFetchMultipleArticles.ResponsesInput>();

        CTBOT_ChatbotFetchMultipleArticles.ResponsesInput input = new CTBOT_ChatbotFetchMultipleArticles.ResponsesInput();
        input.lastCustomerInput = 'H';
        inputList.add(input);

        Test.startTest();
            outputList = CTBOT_ChatbotFetchMultipleArticles.getMultipleArticles(inputList);
        Test.stopTest();

        
    }
}