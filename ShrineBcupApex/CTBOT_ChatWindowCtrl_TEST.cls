@isTest
public with sharing class CTBOT_ChatWindowCtrl_TEST {
    static testmethod void setOrigination(){

        String testOriginationUrl = 'https://business.ct.gov';
        String testChatKey = CTBOT_TestDataFactory.createTestChatTranscript(testOriginationUrl);

        Test.startTest();
            CTBOT_ChatWindowCtrl.setTranscriptOrigination(testOriginationUrl, testChatKey);
        Test.stopTest();

        LiveChatTranscript theTranscript = [SELECT Id, Origination__c
                                                FROM LiveChatTranscript
                                                WHERE ChatKey = :testChatKey];

        system.assert(theTranscript.Origination__c == testOriginationUrl);
        
    }
}