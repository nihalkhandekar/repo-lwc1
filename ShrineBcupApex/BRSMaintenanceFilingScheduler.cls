global without sharing class BRSMaintenanceFilingScheduler implements Schedulable {
      
  global void execute(SchedulableContext SC) {
        String query  = system.label.Update_Sobject_Business_Filing_Query;
        BRSUpdateAccountUsingMaintenanceFiling updateBatch = new BRSUpdateAccountUsingMaintenanceFiling (query);
        /**
        * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: BRS-3859
        * Change(s)/Modification(s) Description : Adding size for records to be 1. Since if one record fails all other records fail.
        * Change(s)/Modification(s) Made on : 2021-04-30
        * Change(s)/Modification(s) Made by : Avinash Shukla
        */
        Database.executeBatch(updateBatch);
   }
}