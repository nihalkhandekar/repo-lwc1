@IsTest
public class scheduleBusinessFilingNotification_Test {
    testmethod static void scheduleBusinessFilingNotification1() {
        SchedulableContext ctx;
        scheduleBusinessFilingNotification sbf = new scheduleBusinessFilingNotification();
        test.startTest();
        sbf.execute(ctx);
        test.stopTest();
    }
    
    testmethod static void scheduleFirstReportNotifications1(){
        SchedulableContext ctx;
        scheduleFirstReportNotifications sfrn = new scheduleFirstReportNotifications();
        test.startTest();
        sfrn.execute(ctx);
        test.stopTest();
    }

}