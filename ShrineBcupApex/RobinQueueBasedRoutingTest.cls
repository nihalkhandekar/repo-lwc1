@isTest
public with sharing class RobinQueueBasedRoutingTest {

    private static final String GAMING_DIVISION = 'Gaming';
    private static final String GAMING_DIVISION_PICKLIST_VAL = 'DCP - ' + GAMING_DIVISION;

    @testSetup
    static void makeData() {
        Group testGroup = new Group(
            Type = 'Queue',
            Name = GAMING_DIVISION_PICKLIST_VAL
        );
        Group catchAllGroup = new Group(
            Type = 'Queue',
            Name = RobinQueueBasedRouting.DCP_COMPLAINT_CENTER
        );
        LiveChatVisitor testVisitor = new LiveChatVisitor();
        List<SObject> testData = new List<SObject>{ testGroup, catchAllGroup, testVisitor };
        insert testData;
        LiveChatTranscript testTranscriptDivisionSet = new LiveChatTranscript(
            DCP_Division__c = GAMING_DIVISION, 
            LiveChatVisitorId = testVisitor.Id
        );
        LiveChatTranscript testTranscriptNoDivision = new LiveChatTranscript(
            LiveChatVisitorId = testVisitor.Id
        );
        List<SObject> testTranscripts = new List<SObject>{ testTranscriptDivisionSet, testTranscriptNoDivision };
        insert testTranscripts;
    }

    @isTest
    static void testGetQueueIdDivisionSet() {
        LiveChatTranscript testTranscript = [
            SELECT Id
            FROM LiveChatTranscript
            WHERE DCP_Division__c != null
            LIMIT 1
        ];
        Group testGroupDivisionIsSet = [
            SELECT Id
            FROM Group
            WHERE Type = 'Queue'
            AND Name = :GAMING_DIVISION_PICKLIST_VAL + ' - CHAT'
            LIMIT 1
        ];

        List<RobinQueueBasedRouting.Output> result = RobinQueueBasedRouting.getQueueId(new List<Id>{ testTranscript.Id });
        System.assertEquals(testGroupDivisionIsSet.Id, result[0].queueId);
    }

    @isTest
    static void testGetQueueIdDivisionNull() {
        LiveChatTranscript testTranscript = [
            SELECT Id
            FROM LiveChatTranscript
            WHERE DCP_Division__c = null
            LIMIT 1
        ];
        Group testGroupDivisionNull = [
            SELECT Id
            FROM Group
            WHERE Type = 'Queue'
            AND Name = :RobinQueueBasedRouting.DCP_COMPLAINT_CENTER
            LIMIT 1
        ];

        List<RobinQueueBasedRouting.Output> result = RobinQueueBasedRouting.getQueueId(new List<Id>{ testTranscript.Id });
        System.assertEquals(testGroupDivisionNull.Id, result[0].queueId);
    }
}