/*********************************************************************************************
 * NAME:  BRS_SendNotificationBusinessFiling
 * DESCRIPTION: Schedule class to send email notification for first report businesses.
 *
 * @AUTHOR: Avinash Shukla
 * @DATE: 2021-05-11
 *
 *
 * MODIFICATION LOG:
 * DEVELOPER                         DATE                               DESCRIPTION
 * _____________________________________________________________________________________________
 * Avinash Shukla                   2021-05-11                         Created the first version
 *
*************************************************************************************************/
global class scheduleFirstReportNotifications implements Schedulable {
    global void execute(SchedulableContext ctx){
        brs_SendFirstReportNotifications batch = new brs_SendFirstReportNotifications();
        Database.executebatch(batch, 1);
    }
}