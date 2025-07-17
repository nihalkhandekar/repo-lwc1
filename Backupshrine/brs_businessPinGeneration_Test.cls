@isTest
public class brs_businessPinGeneration_Test {
     testmethod static void updateAccountPinTest()
    {
        List<Account> AccountList=BRS_TestDataFactory.listOfAccount();
       	List<String> accountId=new List<String>();
         for(Account acc:AccountList)
        {
            accountId.add(acc.id);
        }
        Test.startTest();
        brs_businessPinGeneration.updateAccountPin(accountId);
        try {
            brs_businessPinGeneration.updateAccountPin(null);
        } catch (Exception e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        Test.stopTest();
    }

}