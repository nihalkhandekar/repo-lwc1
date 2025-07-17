/*********************************************************************************************
 * NAME:  brs_MarkExpirationScheduler 
 * DESCRIPTION: Schedule class to update Mark object with expiration status when expiration date passed.
 *
 * @AUTHOR: Rahul Sharma
 * @DATE: 06/30/2021
 *
 *
 * MODIFICATION LOG:
 * DEVELOPER                         DATE                               DESCRIPTION
 * _____________________________________________________________________________________________
 * Rahul Sharma                     06/30/2021                        Created the first version
 *
*************************************************************************************************/
global without sharing class brs_MarkExpirationScheduler implements Schedulable {
      
  global void execute(SchedulableContext SC) {
        String query  = system.label.Mark_Expiration_Batch_Query;
        brs_MarkExpirationBatch updateBatch = new brs_MarkExpirationBatch(query);
        Database.executeBatch(updateBatch);
   }
}