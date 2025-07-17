@IsTest
public with sharing class CTBOT_ChatbotFetchArticle_TEST {

/**
 * Start test for CTBOT_ChatbotFetchArticleByTitle
**/
    static testmethod void fetchArticleByTitle(){
        List<Knowledge__kav> setupTestArticle = CTBOT_TestDataFactory.createArticles(5);

        List<CTBOT_ChatbotFetchArticleByTitle.ResponsesOutput> outputList = new List<CTBOT_ChatbotFetchArticleByTitle.ResponsesOutput>();
        List<CTBOT_ChatbotFetchArticleByTitle.ResponsesInput> inputList = new List<CTBOT_ChatbotFetchArticleByTitle.ResponsesInput>();

        CTBOT_ChatbotFetchArticleByTitle.ResponsesInput input = new CTBOT_ChatbotFetchArticleByTitle.ResponsesInput();
        input.title = 'Apex Test 1';
        inputList.add(input);

        Test.startTest();
            outputList = CTBOT_ChatbotFetchArticleByTitle.getKnowledgeArticles(inputList);
        Test.stopTest();

        system.assert(outputList[0].theArticles[0].title == input.title);
        
    }

    static testmethod void fetchArticleByTitleNeg(){
        List<Knowledge__kav> setupTestArticle = CTBOT_TestDataFactory.createArticles(5);

        List<CTBOT_ChatbotFetchArticleByTitle.ResponsesOutput> outputList = new List<CTBOT_ChatbotFetchArticleByTitle.ResponsesOutput>();
        List<CTBOT_ChatbotFetchArticleByTitle.ResponsesInput> inputList = new List<CTBOT_ChatbotFetchArticleByTitle.ResponsesInput>();

        CTBOT_ChatbotFetchArticleByTitle.ResponsesInput input = new CTBOT_ChatbotFetchArticleByTitle.ResponsesInput();
        input.title = 'Apex Test-Does not exist';
        inputList.add(input);

        Test.startTest();
            outputList = CTBOT_ChatbotFetchArticleByTitle.getKnowledgeArticles(inputList);
        Test.stopTest();
        
        system.assert(outputList[0].theArticles.isEmpty());
        
    }

    static testmethod void fetchArticleByTitleWithAgency(){
        List<Knowledge__kav> setupTestArticle = CTBOT_TestDataFactory.createGetSupportArticles(5);

        List<CTBOT_ChatbotFetchArticleByTitle.ResponsesOutput> outputList = new List<CTBOT_ChatbotFetchArticleByTitle.ResponsesOutput>();
        List<CTBOT_ChatbotFetchArticleByTitle.ResponsesInput> inputList = new List<CTBOT_ChatbotFetchArticleByTitle.ResponsesInput>();

        CTBOT_ChatbotFetchArticleByTitle.ResponsesInput input = new CTBOT_ChatbotFetchArticleByTitle.ResponsesInput();
        input.title = 'Get Support';
        input.agencyOrigination = 'TEST';
        inputList.add(input);

        Test.startTest();
            outputList = CTBOT_ChatbotFetchArticleByTitle.getKnowledgeArticles(inputList);
        Test.stopTest();
        
        system.assert(outputList[0].theArticles.isEmpty());
        
    }
/**
 * End test for CTBOT_ChatbotFetchArticleByTitle
**/

/**
 * Start test for CTBOT_ChatbotFetchArticlesByDialogTag
**/
static testmethod void fetchArticleByDialogTag(){
    List<Knowledge__kav> setupTestArticle = CTBOT_TestDataFactory.createArticlesWithDialogTags(5);

    List<CTBOT_ChatbotFetchArticlesByDialogTag.ResponsesOutput> outputList = new List<CTBOT_ChatbotFetchArticlesByDialogTag.ResponsesOutput>();
    List<CTBOT_ChatbotFetchArticlesByDialogTag.ResponsesInput> inputList = new List<CTBOT_ChatbotFetchArticlesByDialogTag.ResponsesInput>();

    CTBOT_ChatbotFetchArticlesByDialogTag.ResponsesInput input = new CTBOT_ChatbotFetchArticlesByDialogTag.ResponsesInput();
    input.dialogTag = 'Apex Test Dialog Tag';
    inputList.add(input);

    Test.startTest();
        outputList = CTBOT_ChatbotFetchArticlesByDialogTag.getKnowledgeArticles(inputList);
    Test.stopTest();

    system.assert(outputList[0].theArticles.size() == 5);
    
}

static testmethod void fetchArticleByDialogTagNeg(){
    List<Knowledge__kav> setupTestArticle = CTBOT_TestDataFactory.createArticlesWithDialogTags(5);

    List<CTBOT_ChatbotFetchArticlesByDialogTag.ResponsesOutput> outputList = new List<CTBOT_ChatbotFetchArticlesByDialogTag.ResponsesOutput>();
    List<CTBOT_ChatbotFetchArticlesByDialogTag.ResponsesInput> inputList = new List<CTBOT_ChatbotFetchArticlesByDialogTag.ResponsesInput>();

    CTBOT_ChatbotFetchArticlesByDialogTag.ResponsesInput input = new CTBOT_ChatbotFetchArticlesByDialogTag.ResponsesInput();
    input.dialogTag = 'Apex Test Dialog Tag that does not exist';
    inputList.add(input);

    Test.startTest();
        outputList = CTBOT_ChatbotFetchArticlesByDialogTag.getKnowledgeArticles(inputList);
    Test.stopTest();

    system.assert(outputList[0].theArticles.isEmpty());
    
}
/**
* End test for CTBOT_ChatbotFetchArticlesByDialogTag
**/

/**
 * Start test for CTBOT_ChatbotFetchArticleBySelected
**/
static testmethod void fetchArticleBySelectedArticle(){
    List<Knowledge__kav> setupTestArticle = CTBOT_TestDataFactory.createArticlesWithRelatedArticleTags(5);

    List<CTBOT_ChatbotFetchArticleBySelected.ResponsesOutput> outputList = new List<CTBOT_ChatbotFetchArticleBySelected.ResponsesOutput>();
    List<CTBOT_ChatbotFetchArticleBySelected.ResponsesInput> inputList = new List<CTBOT_ChatbotFetchArticleBySelected.ResponsesInput>();

    CTBOT_ChatbotFetchArticleBySelected.ResponsesInput input = new CTBOT_ChatbotFetchArticleBySelected.ResponsesInput();
    input.selectedArticle = setupTestArticle[0];
    inputList.add(input);

    Test.startTest();
        outputList = CTBOT_ChatbotFetchArticleBySelected.getKnowledgeArticles(inputList);
    Test.stopTest();

    system.assert(outputList[0].theArticles.size() == 1);
    
}

static testmethod void fetchArticleBySelectedArticleNeg(){
    List<Knowledge__kav> setupTestArticle = CTBOT_TestDataFactory.createArticlesWithDialogTags(5);

    List<CTBOT_ChatbotFetchArticleBySelected.ResponsesOutput> outputList = new List<CTBOT_ChatbotFetchArticleBySelected.ResponsesOutput>();
    List<CTBOT_ChatbotFetchArticleBySelected.ResponsesInput> inputList = new List<CTBOT_ChatbotFetchArticleBySelected.ResponsesInput>();

    CTBOT_ChatbotFetchArticleBySelected.ResponsesInput input = new CTBOT_ChatbotFetchArticleBySelected.ResponsesInput();
    input.selectedArticle = setupTestArticle[0];
    inputList.add(input);

    Test.startTest();
        outputList = CTBOT_ChatbotFetchArticleBySelected.getKnowledgeArticles(inputList);
    Test.stopTest();

    system.assert(outputList[0].theArticles.isEmpty());
}


/**
 * End test for CTBOT_ChatbotFetchArticleBySelected
**/
}