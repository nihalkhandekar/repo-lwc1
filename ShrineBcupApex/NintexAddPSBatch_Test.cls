@isTest
public class NintexAddPSBatch_Test {
    testMethod static void NintexAddPSBatchTestExecution()
    {
        Account acc=BRS_TestDataFactory.createAccountObject();
        Contact con=new Contact();
        con.AccountId=acc.id;
        con.firstName='sam';
        con.LastName='man';
        con.Email='sbabarabbani@deloitte.com';
        insert con;
        Profile prof = [select id, name from Profile where  name = 'System Administrator' LIMIT 1];
        User user = new User();
        user = BRS_TestDataFactory.createUser(prof.Id);
       
        Test.startTest();
        
        List<User> ul = [Select Id,Name from User where username='testerAdmin12345@noemail.com' LIMIT 1];
        PermissionSet psUser = [SELECT Id FROM PermissionSet WHERE Name = 'DDP_User_All'].get(0);
        List<PermissionSetAssignment> psa=[Select Id from PermissionSetAssignment where PermissionSetId=:psUser.Id AND AssigneeId=:ul[0].Id];
        if(!psa.isEmpty()){delete psa;}
        
        NintexAddPSBatch napsb = new NintexAddPSBatch();    
        napsb.execute(null,ul);
        napsb.finish(null);
        Test.stopTest();
    }
}