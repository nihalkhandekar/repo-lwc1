@isTest
public class BRS_CreateAccountTriggerHelper_Test {
    @isTest
    static void creatAccTest()
    {
        List<Create_Account__e> publishEvents = BRS_TestDataFactory.createPlatformEvent();
        Test.startTest();
        try
        {
            BRS_CreateAccountTriggerHelper.creatAcc(publishEvents);
        }
        catch(Exception e)
        {
            System.debug('Error Message '+e.getMessage());
        }
        Test.stopTest();
    }
    @istest
    static void handlertest(){
        
        BRS_CreateAccountHandler ca= new BRS_CreateAccountHandler();
        Test.startTest();
        ca.beforeInsert(null);
        ca.beforeUpdate(null,null);
        ca.beforeDelete(null,null);
        ca.afterUpdate(null,null);
        ca.afterDelete(null);
        ca.afterUndelete(null,null);
        Test.stopTest();
    }
}