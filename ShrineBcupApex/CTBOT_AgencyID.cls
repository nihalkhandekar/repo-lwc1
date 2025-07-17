public with sharing class CTBOT_AgencyID {
    
    @InvocableMethod(label='Get agency ID')
    public static List<String> getAgencyID(List<Id> ids) {
        return new List<String>{[
            SELECT Agency_ID__c
            FROM LiveChatTranscript
            WHERE Id = :ids[0]
            LIMIT 1
        ].Agency_ID__c};
    }
}