@isTest
public class BRSMaintenanceFilingScheduler_Test {   
@isTest 
static void testschedule() {
 SchedulableContext SC;
Test.StartTest();
BRSMaintenanceFilingScheduler sh1 = new BRSMaintenanceFilingScheduler();
String sch = '0 0 23 * * ?';
system.schedule('Test Territory Check', sch, sh1);
  sh1.execute(SC);
Test.stopTest(); 
}
}