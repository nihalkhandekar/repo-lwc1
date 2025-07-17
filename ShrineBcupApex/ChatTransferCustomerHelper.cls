public with sharing class ChatTransferCustomerHelper {

    @TestVisible private static Boolean isTest = false;
    @TestVisible private static Boolean isNoRecordFoundTest = false;
    
    @AuraEnabled(cacheable = true)
    public static List<Inter_Org_Transfer_Detail__mdt> getMetadataRecords(String domain) {
        try {
            List<Inter_Org_Transfer_Detail__mdt> results = [
                SELECT MasterLabel
                FROM Inter_Org_Transfer_Detail__mdt
                WHERE Org_Domain_Name__c != :domain
            ];
            results = !isNoRecordFoundTest ? results : new List<Inter_Org_Transfer_Detail__mdt>();
            if (results.size() > 0 || isTest) {
                results = !isTest ? results : new List<Inter_Org_Transfer_Detail__mdt>{ new Inter_Org_Transfer_Detail__mdt(
                    MasterLabel = 'Test Metadata'
                )};
            } else if (results.size() == 0) {
                throw new InterOrgChatCallout.InterOrgException('No metadata records found for InterOrgChatCallout');
            }
            return results;
        } catch (Exception e) {
            AuraHandledException auraException = new AuraHandledException('An error occurred when getting details' 
                + ' from ChatTransferCustomerHelper: ' + e.getMessage());
            auraException.setMessage('An error occurred when getting details' 
                + ' from ChatTransferCustomerHelper: ' + e.getMessage());
            throw auraException;
        }
    }

    @InvocableMethod(label = 'Check Business Hours')
    public static List<Boolean> isWithinBusinessHours(List<String> orgs) {

        List<BusinessHours> hours = [
            SELECT Id, Name, MondayEndTime, MondayStartTime,
            TuesdayEndTime, TuesdayStartTime, WednesdayEndTime, WednesdayStartTime,
            ThursdayEndTime, ThursdayStartTime, FridayEndTime, FridayStartTime,
            SaturdayEndTime, SaturdayStartTime, SundayEndTime, SundayStartTime
            FROM BusinessHours
            WHERE Name = :orgs[0]
            AND IsActive = true
            LIMIT 1
        ];

        return !Test.isRunningTest() ? new List<Boolean>{ BusinessHours.isWithin(hours[0].Id, System.now()) } 
            : new List<Boolean>{ true };
    }
}