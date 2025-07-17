@isTest
public with sharing class CTBOT_SitecoreArticleFeedback_TEST {

    @testSetup
    static void makeData() {
        List<Bot_Article_Feedback__c> testRecords = CTBOT_TestDataFactory.createBotFeedbackRecords(1);
        insert testRecords;
    }
    
    @isTest
    static void testSendFeedback() {
        CTBOT_SitecoreArticleFeedback.Input testInput = new CTBOT_SitecoreArticleFeedback.Input();
        List<CTBOT_SitecoreArticleFeedback.Input> testInputList = new List<CTBOT_SitecoreArticleFeedback.Input>();
        CTBOT_SitecoreAPIService.isTest = true;
        testInput.feedbackRecords = CTBOT_TestDataFactory.createBotFeedbackRecords(2);
        testInputList.add(testInput);

        CTBOT_SitecoreAPIService_MOCK mockInstance = new CTBOT_SitecoreAPIService_MOCK();
        Test.setMock(HttpCalloutMock.class, mockInstance);
        Test.startTest();
        CTBOT_SitecoreArticleFeedback.sendFeedback(testInputList);
        Test.stopTest();

        System.assertEquals(200, CTBOT_SitecoreArticleFeedback.responseCode);
    }
}