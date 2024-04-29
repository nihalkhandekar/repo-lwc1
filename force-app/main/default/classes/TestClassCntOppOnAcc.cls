@isTest
public class TestClassCntOppOnAcc {
@isTest
    public static void TestClassCntOppOnAcc(){
        Account acc = new Account();
        acc.Name = 'Test OppAcc Count';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp Count';
        opp.Amount = 7000;
        opp.CloseDate = system.today()+7;
        opp.StageName = 'Closed Won';
        opp.AccountId = acc.Id;
        
        system.Test.startTest();
        insert opp;
       // update opp;
       // delete opp;
       // undelete opp;
        system.Test.stopTest();
        system.assertEquals(2, [select id,Count_of_Opportunities__c from Account where id =: acc.Id].Count_of_Opportunities__c);
    }
}