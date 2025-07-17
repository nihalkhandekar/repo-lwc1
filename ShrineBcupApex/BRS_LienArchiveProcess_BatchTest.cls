@isTest
private class BRS_LienArchiveProcess_BatchTest {
    
   @isTest
    static void testBRSLienArchiveProcessExecute(){
        Integer noOfDays = Integer.valueOf(System.Label.BRS_CheckDaysforArchive);
        Date oneYearPrior = System.today().addDays(-noOfDays-1);
        
        UCC_Lien__c uccLien = new UCC_Lien__c();
        uccLien.Status__c = 'Active';
        uccLien.Status_Change_Date__c = oneYearPrior;
        insert uccLien;
        uccLien.Lapse_Date__c = oneYearPrior;
        update uccLien;
        Test.startTest();
        system.debug('Result--> '+[Select Id, Lapse_Date__c,Status__c,Status_Change_Date__c from UCC_Lien__c]);
        BRS_LienArchiveProcess_Batch lienArchiveProcessBatch = new BRS_LienArchiveProcess_Batch();
        try
        {
            lienArchiveProcessBatch.execute(null);
            ID batchprocessid = Database.executeBatch(lienArchiveProcessBatch);
            
        }
        catch(Exception e)
        {
            System.debug('Error message'+e.getMessage());
        }
        Test.stopTest();
    }
}