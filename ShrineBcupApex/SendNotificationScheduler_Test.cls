@isTest
public class SendNotificationScheduler_Test {
  testMethod static void SendNotificationSchedulerTest()
  {
      Test.startTest();
      SendNotificationScheduler sh1 = new SendNotificationScheduler();
		String sch = '0 0 23 * * ?'; 
	system.schedule('Test Territory Check', sch, sh1); 
	Test.stopTest();
  }


}