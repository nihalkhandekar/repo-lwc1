@isTest
private class BRS_FilingUpdatesClassTest {
  testmethod static void testUpdateFilingRecordType() {
        UCC_Lien__c uccLien = new UCC_Lien__c();
        uccLien=BRS_TestDataFactory.createUCCLien('OFS');
      	OnOff_Filing_Auto_Refund__c onOff1 = BRS_TestDataFactory.onOffCustomSetting();
        UCC_Filing__c uccFiling = new UCC_Filing__c();
        uccFiling = BRS_TestDataFactory.createUCCFiling('Not Applicable','In-Progress',uccLien.Id,'Aircraft');
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Citizenship__c='Domestic';
        acc.Business_Type__c='LLP';
        acc.ClientAccountNum__c='12345';
        acc.Purpose_of_Business__c = 'Test';
        insert acc;
        
        List<BRS_FilingUpdatesClass.Request> reqList =  new List<BRS_FilingUpdatesClass.Request>();
        BRS_FilingUpdatesClass.Request req = new BRS_FilingUpdatesClass.Request();
        req.FilingID = uccFiling.id;
        req.UCCLIenID = uccLien.id;
        reqList.add(req);
        test.startTest();
        BRS_FilingUpdatesClass.updateFilingRecordType(reqList);
        test.stopTest();
    }
   
}