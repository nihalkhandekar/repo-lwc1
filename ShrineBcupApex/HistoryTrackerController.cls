public with sharing class HistoryTrackerController {
    @AuraEnabled(cacheable=true)
    public static Map<String, ContactHistory> getLatestHistoryRecords(Id recordId){
        // Fetch all history records for the specified fields
        List<ContactHistory> historyRecords = [
            SELECT Field, OldValue, NewValue
            FROM ContactHistory
            WHERE ContactId = :recordId
            AND Field IN ('FirstName', 'MiddleName', 'LastName	', 'Start_Term__c', 'End_Term__c')
            WITH SECURITY_ENFORCED
            ORDER BY CreatedDate DESC
        ];

        // Map to hold the latest record for each field
        Map<String, ContactHistory> latestRecords = new Map<String, ContactHistory>();

        // Loop through history records to get the latest for each field
        for (ContactHistory record : historyRecords) {
            if (!latestRecords.containsKey(record.Field)) {
                latestRecords.put(record.Field, record);
            }
        }

        return latestRecords;
    }
}