public with sharing class RobinQueueBasedRouting {

    @testVisible private static final String DCP_COMPLAINT_CENTER = 'DCP - Complaint Center - CHAT';
    private static final String CANNABIS = 'Cannabis';

    @InvocableMethod(label='Get queue IDs')
    public static List<Output> getQueueId(List<Id> ids) {

        Output toReturn = new Output();
        Group queue;
        LiveChatTranscript transcript = [
            SELECT Agency_ID__c, DCP_Division__c
            FROM LiveChatTranscript
            WHERE Id = :ids[0]
            LIMIT 1
        ];

        String dcpDivision = transcript.Agency_ID__c == CANNABIS ? 'Drug Control' : transcript.DCP_Division__c;

        if (dcpDivision != null) {
            String queueName = 'DCP - ' + dcpDivision + ' - CHAT';
            queue = [
                SELECT Id
                FROM Group
                WHERE Type = 'Queue'
                AND Name = :queueName
                LIMIT 1
            ];
        } else {
            queue = [
                SELECT Id
                FROM Group
                WHERE Type = 'Queue'
                AND Name = :DCP_COMPLAINT_CENTER
                LIMIT 1
            ];
        }

        toReturn.queueId = queue.Id.to15();
        toReturn.division = dcpDivision;

        return new List<Output>{toReturn};
    }

    public class Output {
        @InvocableVariable(label='Queue ID' description='The retrieved queue ID')
        public String queueId;

        @InvocableVariable(label='Division Name' description='The retrieved division name')
        public String division;
    }
}