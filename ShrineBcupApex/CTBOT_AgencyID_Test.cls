@isTest
public with sharing class CTBOT_AgencyID_Test {
    
    @testSetup
    static void makeData() {
        CTBOT_TestDataFactory.createTestChatTranscript(null);
    }

    @isTest
    static void testGetAgencyID() {
        LiveChatTranscript testTranscript = [
            SELECT Id
            FROM LiveChatTranscript
            LIMIT 1
        ];
        List<String> results = CTBOT_AgencyID.getAgencyID(new List<Id>{ testTranscript.Id });
        System.assertEquals(null, results[0]);
    }
}