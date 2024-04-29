@isTest
public class TestClassPreventAccDel {
@isTest
    public static void TestClassPreventAccDel(){
     Account acc = new Account();
        acc.Name = 'Account555';
        acc.Industry = 'Banking';
		insert acc; 
     Opportunity opp = new Opportunity();
        opp.Name = 'Opp555';
        opp.CloseDate = system.today() + 7;
        opp.StageName = 'Prospecting';
        opp.AccountId = acc.Id;
    system.test.startTest();
        delete acc;
    system.test.stopTest(); 
    }
}