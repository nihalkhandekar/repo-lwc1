public with sharing class SAP_HistoryTrackerController {
    @AuraEnabled(cacheable=true)
    public static Map<String, ContactHistory> getLatestHistoryRecords(Id recordId){
        
        system.debug('recordId=='+recordId);
        // Fetch all history records for the specified fields
        List<ContactHistory> historyRecords = [
            SELECT Field, OldValue, NewValue
            FROM ContactHistory
            WHERE ContactId = :recordId
            AND Field IN ('FirstName', 'MiddleName', 'LastName', 'SAP_Start_Term__c', 'SAP_End_Term__c')
            WITH SECURITY_ENFORCED
            ORDER BY CreatedDate DESC
        ];
        system.debug('historyRecords=='+historyRecords);

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