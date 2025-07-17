@isTest
private class CTBOT_DynamicDialogTest {
    @isTest
    static void testRetrieveArticle() {
        CTBOT_DynamicDialog.Input input = new CTBOT_DynamicDialog.Input();
        input.dialogName = 'I Need to File a Complaint';
        input.origination = 'DCP';
        List<CTBOT_DynamicDialog.Output> output = CTBOT_DynamicDialog.retrieveArticle(new List<CTBOT_DynamicDialog.Input>{input});

        List<Robin_Dynamic_Dialog__mdt> articleIdRecords = [
            SELECT MasterLabel, Fallback_ID__c
            FROM Robin_Dynamic_Dialog__mdt
            WHERE Dialog_Name__c = :input.dialogName
            AND Bot_Agency_Origination__r.MasterLabel = :input.origination
        ];
        System.assertEquals(articleIdRecords[0].MasterLabel, output[0].dynamicArticleId);
    }

    @isTest
    static void testRetrieveArticleFallback() {
        // 1 mdt match
        CTBOT_DynamicDialog.Input input = new CTBOT_DynamicDialog.Input();
        input.dialogName = 'Licenses, Permits, & Forms';
        input.origination = 'DCP';
        input.dcpDivision = 'Complaint Center';
        List<CTBOT_DynamicDialog.Output> output = CTBOT_DynamicDialog.retrieveArticle(new List<CTBOT_DynamicDialog.Input>{input});

        List<Robin_Dynamic_Dialog__mdt> articleIdRecords = [
            SELECT MasterLabel, Fallback_ID__c
            FROM Robin_Dynamic_Dialog__mdt
            WHERE Dialog_Name__c = :input.dialogName
            AND Bot_Agency_Origination__r.MasterLabel = :input.origination
        ];
        System.assertEquals(articleIdRecords[0].Fallback_ID__c, output[0].dynamicArticleId);
    }
}