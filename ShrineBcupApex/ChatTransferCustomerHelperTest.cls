@isTest
public with sharing class ChatTransferCustomerHelperTest {

    @isTest
    static void testGetMetadataRecords() {
        ChatTransferCustomerHelper.isNoRecordFoundTest = true;
        try {
            ChatTransferCustomerHelper.getMetadataRecords(null);
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('No metadata records found for InterOrgChatCallout'));
        }

        ChatTransferCustomerHelper.isTest = true;
        List<Inter_Org_Transfer_Detail__mdt> results = ChatTransferCustomerHelper.getMetadataRecords(null);
        System.assertEquals('Test Metadata', results[0].MasterLabel);
    }

    @isTest
    static void testIsWithinBusinessHours() {
        List<Boolean> withinBusinessHours = ChatTransferCustomerHelper.isWithinBusinessHours(new List<String>{'Test'});
        System.assertEquals(true, withinBusinessHours[0]);
    }
}