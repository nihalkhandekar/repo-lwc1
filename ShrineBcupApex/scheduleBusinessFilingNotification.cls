/*********************************************************************************************
 * NAME:  BRS_SendNotificationBusinessFiling
 * DESCRIPTION: Batch class to send email/sms based on annual report status.
 *
 * @AUTHOR: Avinash Shukla
 * @DATE: 2021-03-31
 *
 *
 * MODIFICATION LOG:
 * DEVELOPER                         DATE                               DESCRIPTION
 * _____________________________________________________________________________________________
 * Avinash Shukla                   2021-03-31                         Created the first version
 *
*************************************************************************************************/
global class scheduleBusinessFilingNotification implements Schedulable {
    global void execute(SchedulableContext ctx){
        BRS_SendNotificationBusinessFiling batch = new BRS_SendNotificationBusinessFiling();
      Database.executebatch(batch, 1);
    }
}