@isTest
public with sharing class BRS_FilerInfoDailyBatchTest {
     public static testmethod void testfilerdailyjob(){
        List<Profile> lstProfileId = [Select Id From Profile Where Name = 'CT Community User']; 
        Account accInst = BRS_TestDataFactory.createAccountObject();
        Contact con = BRS_TestDataFactory.createContactObject(accInst.id);
        User user = BRS_TestDataFactory.createCommunityUser(con,lstProfileId[0].Id);
		 String networkID = [Select Id from Network where Name = 'business'].Id;   
         List<User> userlist =  [Select Id, Name, Email,Filer_Information_email_sent__c from User where Id =: user.id];
         system.debug('USERLIST@@'+user);
         userlist.add(user);
         Test.startTest();
          Database.QueryLocator QL;
        Database.BatchableContext BC;
        BRS_FilerInfoDailyBatch batchInstance = new BRS_FilerInfoDailyBatch();
        QL = batchInstance.start(bc);
         try{
        batchInstance.execute(BC, userlist);
         }catch(Exception e){System.debug(e);}
        batchInstance.finish(BC);   
            test.stopTest();
     }   
}