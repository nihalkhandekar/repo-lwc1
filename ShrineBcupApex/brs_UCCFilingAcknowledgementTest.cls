@isTest
private class brs_UCCFilingAcknowledgementTest {
    @TestSetup
    static void setup() {
        OnOff_Filing_Auto_Refund__c onoff = BRS_TestDataFactory.onOffCustomSetting();   
    }

    @isTest
    private static void brs_UCCFilingAcknowledgement() {
        UCC_Lien__c ucclien = BRS_TestDataFactory.createUCCLien('OFS');
        UCC_Filing__c uccfiling = BRS_TestDataFactory.createUCCFiling('Not Applicable', 'Approved', ucclien.Id, 'OFS');
        
        Map<Id, Id> mapRecordsWithSdocs = new Map<Id, Id> {
            uccfiling.id => uccfiling.id
        };

        Test.startTest(); 
            System.enqueueJob(new UCCFilingAcknowledgement(mapRecordsWithSdocs, UCCFilingAcknowledgement.Operation.REJECTION));
        Test.stopTest();
    }
}