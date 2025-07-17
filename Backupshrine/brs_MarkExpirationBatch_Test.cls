/*********************************************************************************************
* NAME:  brs_MarkExpirationBatch_Test
* DESCRIPTION: Test class for brs_adminDissolveController and BRSMostRecentFilingDateBatch
*          
*
* @AUTHOR: Rahul Sharma
* @DATE: 30/06/2021
*
*
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* ----------------------------------------------------------------------------
  Rahul Sharma          30/06/2021                             Created
*********************************************************************************************/
@isTest(seeAllData = false)
private class brs_MarkExpirationBatch_Test{
    @testSetup
    private static void setup() {
    Mark__c mk = new Mark__c();
    mk.Status__c = 'Active';
    mk.Expiration_Date__c = system.Today().addDays(-1);
    insert mk;
    }
    @isTest
    private static void testVFbrs_administrivateDissolutionIntentPage() {
        Test.startTest();
        brs_MarkExpirationScheduler m = new brs_MarkExpirationScheduler();
        String sch = '0 45 06 30 06 ?';
        String jobID = system.schedule('Mark Expire Job'+System.now(), sch, m);
        Test.stopTest();
    }
    @isTest
    private static void testVFbrs_administrivateDissolutionIntentPage1() {
        try{
        Test.startTest();
            Database.BatchableContext BC;
            brs_MarkExpirationBatch abc = new brs_MarkExpirationBatch('abc');
            List<Mark__c> markList = new List<Mark__c>();
            abc.execute(BC, markList);
        Test.stopTest();
        }catch (Exception e){
            System.debug(e);
        }
    }
}