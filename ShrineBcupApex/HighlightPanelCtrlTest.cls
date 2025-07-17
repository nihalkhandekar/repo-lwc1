@isTest
public with sharing class HighlightPanelCtrlTest {
    
    @testSetup
    static void makeData() {
        List<Contact> testContacts = CTBOT_TestDataFactory.createContacts(1);
        String chatKey = CTBOT_TestDataFactory.createTestChatTranscript('https://www.test.com');
        CTBOT_TestDataFactory.createTestChatTranscript('https://www.testing.com');
        LiveChatTranscript testTranscript = [
            SELECT Id, ContactId
            FROM LiveChatTranscript
            WHERE ChatKey = :chatKey
            LIMIT 1
        ];
        testTranscript.ContactId = testContacts[0].Id;
        update testTranscript;
    }

    @isTest
    static void testGetContactDetails() {
        LiveChatTranscript testTranscript = [
            SELECT Id
            FROM LiveChatTranscript
            LIMIT 1
        ];
        Contact testContact = [
            SELECT Id
            FROM Contact
            LIMIT 1
        ];
        Test.startTest();
        Contact result = HighlightPanelCtrl.getContactDetails(testTranscript.Id);
        Test.stopTest();

        System.assertEquals(testContact.Id, result.Id);
    }

    @isTest
    static void testBlankContact() {
        LiveChatTranscript testTranscript = [
            SELECT Id
            FROM LiveChatTranscript
            WHERE Origination__c = 'https://www.testing.com'
            LIMIT 1
        ];
        Test.startTest();
        Contact result = HighlightPanelCtrl.getContactDetails(testTranscript.Id);
        Test.stopTest();

        System.assertEquals(null, result.Name);
    }
}