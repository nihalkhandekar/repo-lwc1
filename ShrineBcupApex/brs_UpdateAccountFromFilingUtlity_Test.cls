@isTest
public class brs_UpdateAccountFromFilingUtlity_Test {
    testMethod static void updateAccountFromFilingfromTrigger() {
        RecordType rt =[select id,Name,developername from RecordType where developername='Annual_Report_First_Report'];
        
        Account acc=new Account();
        acc=BRS_TestDataFactory.createAccountObject();
        
        OnOff_Filing_Auto_Refund__c onoffCustomSetting = new OnOff_Filing_Auto_Refund__c();
        onoffCustomSetting.Name = 'On Off Switch';
        onoffCustomSetting.Auto_Refund_UCC_Filing__c = true;
        onoffCustomSetting.Auto_Refund_Business_Filing__c = false;
        insert onoffCustomSetting;
        
        List<Business_Filing__c> filingList=new List<Business_Filing__c>();
        for(Integer i=0;i<2;i++)
        {
            Business_Filing__c filing1 = new Business_Filing__c();
            filing1.Account__c=acc.Id;
            filing1.Filing_Fee__c=30;
            filing1.Type__c = system.label.Annual_Report;
            filing1.Citizenship__c = 'Domestic';
            filing1.Filing_Date__c = System.Today().addDays(-30);
            filing1.Due_Date__c = (System.today() + 5);
            filing1.Status__c='Approved';
            filingList.add(filing1);
        }
        insert filingList;
        
        Map<Id, Boolean> busFilingIDList = new Map<Id, Boolean>();
        busFilingIDList.put(filingList[0].Id, false);
        System.debug('filing id @@@@@@'+filingList[0].Id);
        
        Principal__c princ= new Principal__c();
        princ=BRS_TestDataFactory.createPrincipal();
        
        Temp_History__c tmpHistory = new Temp_History__c();
        tmpHistory=BRS_TestDataFactory.createTempHistoryObject2(filingList[0].Id,princ.id,acc.id,'Principal','Created');
        tmpHistory=BRS_TestDataFactory.createTempHistoryObject2(filingList[0].Id,princ.id,acc.id,'Principal','Deleted');
        tmpHistory=BRS_TestDataFactory.createTempHistoryObject2(filingList[0].Id,princ.id,acc.id,'Agent','Created');
        tmpHistory=BRS_TestDataFactory.createTempHistoryObject2(filingList[0].Id,princ.id,acc.id,'Agent','Deleted');
        tmpHistory=BRS_TestDataFactory.createTempHistoryObject2(filingList[0].Id,princ.id,acc.id,'Account','Created');
        
        brs_UpdateAccountFromFilingUtlity.Requests req = new brs_UpdateAccountFromFilingUtlity.Requests();
        list<brs_UpdateAccountFromFilingUtlity.Requests> lstReq = new list<brs_UpdateAccountFromFilingUtlity.Requests>();
        req.busFilObj = filingList[0];
        lstReq.add(req);
        
        test.startTest();
        brs_UpdateAccountFromFilingUtlity.updateAccountFromFilingfromTrigger(null);
        brs_UpdateAccountFromFilingUtlity.updateAccountFromFilingfromTrigger(busFilingIdList);
        brs_UpdateAccountFromFilingUtlity.updateAccountFromFiling(filingList);
        brs_UpdateAccountFromFilingUtlity.updateAccountFromFiling(lstReq);
        test.stopTest();
    }   
}