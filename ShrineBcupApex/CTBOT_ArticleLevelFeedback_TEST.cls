@isTest
public with sharing class CTBOT_ArticleLevelFeedback_TEST {

    @testSetup
    static void makeData() {
        CTBOT_TestDataFactory.createTestChatTranscript('https://www.test.com');
    }
    
    @isTest
    static void testSubmitFeedback() {
        CTBOT_ArticleLevelFeedback.submitFeedback('testID', '123', 1);

        List<Bot_Article_Feedback__c> insertedRecords = [
            SELECT Id, Chat_Key__c, Value__c
            FROM Bot_Article_Feedback__c
        ];

        System.assertEquals(1, insertedRecords.size());
        System.assertEquals('123', insertedRecords[0].Chat_Key__c);
        System.assertEquals(1, insertedRecords[0].Value__c);
    }

    @isTest
    static void testGetMainMenuIds() {
        CTBOT_ArticleLevelFeedback.isTest = true;
        
        List<String> testResults = CTBOT_ArticleLevelFeedback.getMainMenuIds();

        System.assertEquals('EEB72F59-8689-4AF7-A0FA-3C7ED7F6FE5D', testResults[0]);
    }

    @isTest
    static void testErrors() {
        CTBOT_ArticleLevelFeedback.isTest = true;
        CTBOT_ArticleLevelFeedback.throwError = true;

        try {
            CTBOT_ArticleLevelFeedback.submitFeedback('testID', '123', 1);
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('An error occurred when submitting feedback in CTBOT_ArticleLevelFeedback'));
        }

        try {
            CTBOT_ArticleLevelFeedback.getMainMenuIds();
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('An error occurred when getting Main Menu IDs in CTBOT_ArticleLevelFeedback'));
        }
    }
}